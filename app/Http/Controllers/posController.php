<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
use App\Models\Product;
use App\Models\Order;
use App\Models\orderDetail;
use App\Models\Delivery;
use App\Models\Voucher;
use App\Models\Payment;
use Illuminate\Support\Facades\Auth;

class posController extends Controller
{
    public function viewCart()
    {
        $cartData = Session::get('cart', []);
        $totalPrice = 0;
        $productsInCart = [];

        if ($cartData) {
            $productIds = array_column($cartData, 'productID');
            $productsInCart = Product::whereIn('productID', $productIds)->get();

            foreach ($productsInCart as $product) {
                // Find the corresponding cart data for the product
                $cartItem = collect($cartData)->first(function ($item) use ($product) {
                    return $item['productID'] == $product->productID;
                });

                if ($cartItem) {
                    // Set the quantity for each product
                    $product->quantity = $cartItem['quantity'];
                }
            }
        }

        return view('cart', ['cartData' => $cartData, 'productsInCart' => $productsInCart]);
    }

    public function addToCart(Request $request)
    {
        $cartData = Session::get('cart', []);

        // Check if the product already exists in the cart
        $existingItemKey = array_search($request->input('productID'), array_column($cartData, 'productID'));

        if ($existingItemKey !== false) {
            // Update the quantity if the product already exists
            $cartData[$existingItemKey]['quantity'] += $request->input('quantity');
        } else {
            // Add the new item to the cart if it doesn't exist
            $newItem = [
                'productID' => $request->input('productID'),
                'quantity' => $request->input('quantity'),
            ];

            $cartData[] = $newItem;
        }

        // Store updated cart data in session
        Session::put('cart', $cartData);

        return redirect()->route('cart');
    }

    public function clearSession()
    {
        // Get the customerID from the session
        $customerID = session('customerID');

        // Forget all keys except customerID
        $keysToKeep = ['customerID'];
        $allKeys = array_keys(session()->all());

        $keysToForget = array_diff($allKeys, $keysToKeep);

        Session::forget($keysToForget);

        return redirect()->route('cart');
    }

    public function removeFromCart($productId)
    {
        $cartData = Session::get('cart', []);

        // Find the index of the item with the specified productID
        $index = array_search($productId, array_column($cartData, 'productID'));

        // Remove the item if found
        if ($index !== false) {
            array_splice($cartData, $index, 1);
            // Alternatively, you can use unset($cartData[$index]); if you prefer
        }

        // Update the 'cart' session key
        Session::put('cart', $cartData);

        return redirect()->route('cart');
    }
    public function viewOrder($orderStatus)
    {
        $orders = Order::where("orderStatus", $orderStatus)->get();

        return view('orderlist', ['orders' => $orders]);
    }
    public function viewOrderDetail($orderID)
    {
        $order = Order::where("orderID", $orderID)->firstOrFail();
        $orderDetails = OrderDetail::where("orderID", $orderID)->get();
        $delivery = Delivery::where("orderID", $orderID)->firstOrFail();

        return view('orderdetail', compact('order', 'orderDetails', 'delivery'));
    }
    public function proceedToPayment(Request $request)
    {
        // Get the selected product IDs from the form
        $selectedProductIds = $request->input('productID', []);

        // Get the cart data from the session
        $cartData = Session::get('cart', []);

        // Filter the cart data to include only selected products
        $selectedProducts = array_filter($cartData, function ($item) use ($selectedProductIds) {
            return in_array($item['productID'], $selectedProductIds);
        });

        // Store selected products in the session
        Session::put('selected_products', $selectedProducts);

        return redirect()->route('viewPayment');
    }
    public function viewPayment()
    {
        $totalPrice = 0;
        $getVoucher = null; // Initialize to null in case no suitable voucher is found

        // Fetch selected products from the session
        $selectedProducts = Session::get('selected_products', []);

        // Fetch products based on the IDs
        $products = Product::whereIn('productID', array_column($selectedProducts, 'productID'))->get();

        // Attach quantity information to each product
        foreach ($products as $product) {
            $selectedProduct = collect($selectedProducts)->first(function ($item) use ($product) {
                return $item['productID'] == $product->productID;
            });

            if ($selectedProduct) {
                // Attach quantity to the product
                $product->quantity = $selectedProduct['quantity'];
                $totalPrice += $product->productPrice * $selectedProduct['quantity'];

                // Fetch suitable voucher (assuming you want to use the first suitable voucher)
                if (!$getVoucher) { // Only fetch a voucher if not already found
                    $getVoucher = Voucher::where("voucherStatus", 'Activated')
                        ->where('voucherRequirements', '<=', $totalPrice)
                        ->first();

                    session(['applied_voucher' => $getVoucher]);
                }
            }
        }

        // Calculate total price with voucher if applicable
        $discount = $getVoucher->discountPercentage * $totalPrice / 100;

        return view('payment', ['selectedProducts' => $products, 'totalPrice' => $totalPrice, 'getVoucher' => $getVoucher, 'discount' => $discount]);
    }
    public function placeOrder(Request $request)
    {
        // Retrieve selected products from the session
        $selectedProducts = Session::get('selected_products', []);

        // Prepare data for stored procedure
        $productsData = collect($selectedProducts)->map(function ($product) {
            return [
                'productID' => $product['productID'],
                'quantity' => $product['quantity'],
                'note' => $product['note'] ?? '' // Assuming there's a 'note' key; adjust as needed
            ];
        });

        // JSON encode the product data
        $productsJson = json_encode($productsData);

        // Other details for the stored procedure
        $deliveryAddress = $request->input('inputField');
        $customerID = Session::get('customerID');
        $getVoucher = Session::get('applied_voucher');
        $voucherID = $getVoucher ? $getVoucher->voucherID : null;
        $outletID = 'OL1';

        // Call the stored procedure
        DB::statement('CALL createOrderFinal(?, ?, ?, ?, ?)', [
            $customerID,
            $voucherID,
            $productsJson, // Pass the JSON encoded product details
            $outletID,
            $deliveryAddress,
        ]);

        // Clear session data
        Session::forget('selected_products');
        Session::forget('cart');
        Session::forget('applied_voucher');
        Session::put('customerID', $customerID);

        return redirect()->route('cart');
    }
    public function updateQuantity(Request $request)
    {
        $cartData = Session::get('cart', []);

        // Find the index of the item with the specified productID
        $index = array_search($request->input('productID'), array_column($cartData, 'productID'));

        // Remove the item if found
        if ($index !== false) {
            // Ensure the quantity won't go below 1
            $cartData[$index]['quantity'] = max($cartData[$index]['quantity'] + $request->input('quantity'), 1);
        }

        // Update the 'cart' session key
        Session::put('cart', $cartData);

        return redirect()->route('cart');
    }
}
