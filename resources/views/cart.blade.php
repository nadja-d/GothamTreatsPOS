<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="{{ asset('css/cart.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png" ;>
</head>

<body data-csrf-token="{{ csrf_token() }}">
    <div class="container">
        @include('navbar');

        <div class="allProducts">
            <div class="checkboxAllProducts">
                <input type="checkbox" id="myCheckbox" name="myCheckbox" value="1" class="checkboxAll">
                <h>Select All Products</h>
            </div>

            <a href="{{ route('clearSession') }}" class="trash"><i class="fa fa-trash-o"></i></a>
        </div>

        <form action="{{ route('proceedToPayment') }}" method="post" class="order">
            @csrf
            <div>
                <h>Item (s)</h>

                <div class="orderDetail">
                    @foreach($productsInCart as $product)
                    <div class="orderItems">
                        <input type="checkbox" name="productID[]" value="{{ $product->productID }}" class="checkbox">
                        <img src="{{ $product->productImage }}" class="itemPicture">

                        <div class="itemDetail">
                            <h>{{ $product->productName }}</h>
                            <p>Rp. {{ $product->quantity*$product->productPrice }}</p>
                        </div>

                        <div class="qtyIncrementDecrement">
                            <a href="{{ route('removeFromCart', ['productId' => $product->productID]) }}"><i class="fa fa-trash-o"></i></a>
                            <a href="{{ route('updateQuantity', ['productID' => $product->productID, 'quantity' => -1]) }}"><i class="fa fa-minus-circle"></i></a>
                            <input type="text" class="num" value="{{ $product->quantity }}" id="quantity_{{ $product->productID }}">
                            <a href="{{ route('updateQuantity', ['productID' => $product->productID, 'quantity' => 1]) }}"><i class="fa fa-plus-circle"></i></a>
                        </div>


                    </div>
                    @endforeach
                </div>
            </div>
            <button class="checkout" type="submit">Checkout</button>
        </form>
        @include('footer');
    </div>
    <script src="{{ asset('js/checkbox.js') }}"></script>
</body>

</html>