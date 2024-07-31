<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="{{ asset('css/orderdetail.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        @include('navbar');

        <a href="/orderlist/Processing">
            <button type="submit" class="backButton">Back</button>
        </a>

        <div class="delivery">
            <div class="deliveryLocation">
                <i class="fa fa-dot-circle-o"></i>
                <h>Delivery Location</h>
            </div>

            <div class="locationDetail">
                <i class="fa fa-sticky-note-o"></i>
                <input type="text" class="inputField" value="{{$delivery->deliveryAddress}}">
            </div>
        </div>

        <div class="order">
            <h>Ordered Item (s)</h>

            @foreach ($orderDetails as $detail)
            <div class="orderDetail">
                <div class="orderItems">
                    <img src="{{$detail->product->productImage}}" class="itemPicture">

                    <div class="itemDetail">
                        <h>{{ $detail->product->productName }}</h>
                        <p>Rp. {{$detail->quantityOrdered * $detail->product->productPrice}}</p>
                    </div>

                    <div class="qtyIncrementDecrement">
                        <p>Qty: {{$detail->quantityOrdered}}</p>
                    </div>
                </div>
            </div>
            @endforeach
        </div>

        <div class="payment">
            <div class="paymentMethod">
                <h>Payment Method: Cash</h>
            </div>
            <div class="addVoucher">
            </div>
        </div>

        <div class="summary">
            <h>Summary</h>

            <div class="paymentDetail">
                <div class="subTotal">
                    <h1>Sub Total</h1>
                    <p>Rp. {{$order->orderTotalPrice}}</p>
                </div>

                <div class="additionalFee">
                    <div>
                        <h1>Delivery Fee</h1>
                        <p>Rp. 25000</p>
                    </div>
                    <div>
                        <h1>Promo Applied</h1>
                        <p>Rp. {{ $order->orderTotalPrice / 100 * optional($order->voucher)->discountPercentage ?? 0 }}</p>
                    </div>
                </div>

                <div class="totalPrice">
                    <h1>Total Price</h1>
                    <p>Rp. {{$order->payment->paymentAmount}}</p>
                </div>
            </div>
        </div>

        @include('footer');
    </div>
</body>

</html>