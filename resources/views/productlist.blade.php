<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="{{ asset('css/productlist.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        @include('navbar');
        <div class="productList">
            <div class="blueRanger">
                <div class="productCategory">
                    <ul>
                        <li><a href="Cookie" class="{{request()->is('productlist/Cookie') ? 'active' : ''}}">Cookie</a></li>
                        <li><a href="Pudding" class="{{request()->is('productlist/Pudding') ? 'active' : ''}}">Pudding</a></li>
                        <li><a href="Milk" class="{{request()->is('productlist/Milk') ? 'active' : ''}}">Milk</a></li>
                        <li><a href="Pie" class="{{request()->is('productlist/Pie') ? 'active' : ''}}">Pie</a></li>
                        <li><a href="DessertBox" class="{{request()->is('productlist/DessertBox') ? 'active' : ''}}">Desset Box</a></li>
                    </ul>
                </div>

                <input type="text" class="searchBar" placeholder="Search">
            </div>

            <div class="redRanger">
                @foreach ($filteredProducts as $product)
                <div class="product">
                    <div class="haiya">
                        <img src="{{ $product->productImage }}" class="picture">
                    </div>

                    <div class="desc">
                        <h>{{ $product->productName }}</h>
                        <p>{{ $product->productDescription }}</p>
                    </div>  

                    <a href="/productdetail/{{ $product->productName }}" class="order">
                        <button class="order">Order</button>
                    </a>
                </div>
                @endforeach
            </div>
        </div>
        @include('footer');
    </div>
</body>

</html>