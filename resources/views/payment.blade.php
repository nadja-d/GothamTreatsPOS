<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="{{ asset('css/payment.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        <form id="orderForm" action="{{ route('placeOrder') }}" method="post" class="container">
            @csrf
            @include('navbar');

            <a href="/cart">
                <button class="backButton">Back</button>
            </a>

            <div class="delivery">
                <div class="deliveryLocation">
                    <i class="fa fa-dot-circle-o"></i>
                    <h>Delivery Location</h>
                </div>

                <div class="locationDetail">
                    <i class="fa fa-sticky-note-o"></i>
                    <input type="text" class="inputField" name="inputField" placeholder="Please input delivery location">
                </div>
            </div>

            <div class="order">
                <h>Ordered Item (s)</h>
                <div class="orderDetail">
                    @foreach ($selectedProducts as $product)
                    <div class="orderItems">
                        <img src="{{ $product->productImage }}" class="itemPicture">

                        <div class="itemDetail">
                            <h>{{ $product->productName }}</h>
                            <p>Rp. {{ $product->productPrice*$product->quantity }}</p>
                        </div>

                        <div class="qtyIncrementDecrement">
                            <p>Qty: </p>
                            <p>{{ $product->quantity }}</p>
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>

            <div class="payment">
                <div class="paymentMethod">
                    <h>QRIS Payment</h>
                </div>

                <div class="addVoucher">
                </div>
            </div>

            <div class="summary">
                <h>Summary</h>

                <div class="paymentDetail">
                    <div class="subTotal">
                        <h1>Sub Total</h1>
                        <p>Rp. {{$totalPrice}}</p>
                    </div>

                    <div class="additionalFee">
                        <div>
                            <h1>Delivery Fee</h1>
                            <p>Rp. 25000</p>
                        </div>
                        <div>
                            <h1>Promo Applied</h1>
                            <p>Rp. {{$discount}}</p>
                        </div>
                    </div>

                    <div class="totalPrice">
                        <h1>Total Price</h1>
                        <p>Rp. {{$totalPrice - $discount + 25000}}</p>
                    </div>
                </div>
            </div>
            <button type="button" onclick="showQRCode()" class="placeOrder">Order</button>

            @include('footer');

            <div id="qrCodeModal" class="modal">
                <div class="modal-content">
                    <span class="close" onclick="closeQRCodeModal()">&times;</span>
                    <!-- Insert QR code image or content here -->
                    <img src="{{ asset('assets/images/siImutDariLautJawa.png') }}" alt="QR Code">
                </div>
            </div>
        </form>
    </div>
    <script src="{{ asset('js/showQR.js') }}"></script>
</body>

</html>