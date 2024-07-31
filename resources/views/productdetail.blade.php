<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="{{ asset('css/productdetail.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        @include('navbar');

        <a href="/productlist/Cookie">
            <button class="backButton">Back</button>
        </a>

        <div class="upperBox">
            <img src="{{ $filteredProduct->productImage }}" class="itemPicture">

            <div class="itemDescription">
                <h>{{ $filteredProduct->productName }}</h>

                <div class="gwenchana">
                    <div class="leftBox">
                        <div class="rating">
                            <i class="fa fa-star" aria-hidden="true"></i>
                            <i class="fa fa-star" aria-hidden="true"></i>
                            <i class="fa fa-star" aria-hidden="true"></i>
                            <i class="fa fa-star" aria-hidden="true"></i>
                            <i class="fa fa-star-o"></i>

                            <p>4.5/32 reviews</p>
                        </div>

                        <div class="huh">
                            <p>In Stock</p>
                            <p1>Rp. {{ $filteredProduct->productPrice }}, -</p1>
                        </div>

                        <div class="qtyIncrementDecrement">
                            <p>Qty: </p>
                            <i class="fa fa-minus-circle"></i>
                            <p class="num">1</p>
                            <i class="fa fa-plus-circle"></i>
                        </div>
                    </div>

                    <div class="rightBox">
                        <h>Description</h>
                        <p>{{ $filteredProduct->productDescription }}</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="haheng">
            <h>Add Notes</h>
            <input type="text" class="hahengInputField">
        </div>

        <form action="{{ route('addToCart') }}" method="post">
            @csrf
            <input type="hidden" name="productID" value="{{ $filteredProduct->productID }}">
            <input type="number" name="quantity" value="1" min="1" class="quantity-input">
            <button class="addToCart" type="submit">Add To Cart</button>
        </form>

        @include('footer');
    </div>
    <script src="{{ asset('js/qtyincredecre.js') }}"></script>
</body>

</html>