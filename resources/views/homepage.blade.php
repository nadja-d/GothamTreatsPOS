<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css" integrity="sha512-5A8nwdMOWrSz20fDsjczgUidUBR8liPYU+WymTZP1lmY9G6Oc7HlZv156XqnsgNUzTyMefFTcsFH/tnJE/+xBg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <link rel="stylesheet" href="{{ asset('css/homepage.css') }}" />
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png" ;>
</head>

<body>
    <div class="container">
        @include('navbar')


        <div id="welcome" class="Welcome">
            <h1>Welcome to <br>Gotham Treats</h1>

            <div class="pictures">
                <img src="{{ asset('assets/images/gothamtreats_logo.png') }}" class="wecomePicture">
            </div>
        </div>

        <div id="products" class="products">
            <div class="category">
                <ul>
                    <li>
                        <a href="/homepage/Cookie/{{ session('customerID') }}" class="{{ request()->is('homepage/Cookie/' . session('customerID')) ? 'active' : '' }}">
                            Cookie
                        </a>
                    </li>
                    <li>
                        <a href="/homepage/Pudding/{{ session('customerID') }}" class="{{ request()->is('homepage/Pudding/' . session('customerID')) ? 'active' : '' }}">
                            Pudding
                        </a>
                    </li>
                    <li>
                        <a href="/homepage/Milk/{{ session('customerID') }}" class="{{ request()->is('homepage/Milk/' . session('customerID')) ? 'active' : '' }}">
                            Milk
                        </a>
                    </li>
                    <li>
                        <a href="/homepage/Pie/{{ session('customerID') }}" class="{{ request()->is('homepage/Pie/' . session('customerID')) ? 'active' : '' }}">
                            Pie
                        </a>
                    </li>
                    <li>
                        <a href="/homepage/DessertBox/{{ session('customerID') }}" class="{{ request()->is('homepage/DessertBox/' . session('customerID')) ? 'active' : '' }}">
                            Dessert Box
                        </a>
                    </li>

                </ul>
            </div>

            <div class="soldProducts">
                @foreach ($filteredProducts as $product)
                <div class="soldProductsItems">
                    <img src="{{ $product->productImage }}" class="image">
                    <h1>{{ $product->productName }}</h1>
                </div>
                @endforeach
            </div>

            <div class="next">
                @if ($filteredProducts->currentPage() > 1)
                <a href="{{ $filteredProducts->previousPageUrl() }}"><i class="fa fa-chevron-circle-left"></i></a>
                @endif

                @for ($i = 1; $i <= $filteredProducts->lastPage(); $i++)
                    <a href="{{ $filteredProducts->url($i) }}"><i class="fa fa-circle {{ $filteredProducts->currentPage() == $i ? 'active' : '' }}"></i></a>
                    @endfor

                    @if ($filteredProducts->currentPage() < $filteredProducts->lastPage())
                        <a href="{{ $filteredProducts->nextPageUrl() }}"><i class="fa fa-chevron-circle-right"></i></a>
                        @endif
            </div>
        </div>

        <div id="openingHours" class="openingHours">
            <div class="openingHoursContent">
                <h1>Opening Hour</h1>
                @foreach ($outlets as $outlet)
                <h2>{{ $outlet->outletLocation }}</h2>
                <p>{{ $outlet->outletAddress }}</p>
                <p>{{ $outlet->outletOpeningHour }} - {{ $outlet->outletClosingHour }}</p>
                @endforeach
            </div>
            <img src="https://images.squarespace-cdn.com/content/v1/51c8b108e4b050e44c477323/0de6db0f-cb2a-4ce4-8ac8-9f42de7a75d3/Greysuitcase+-+Gotham+Treats+01.jpg?format=1500w" class="fotobawah">
        </div>

        @include('footer');
    </div>
</body>

</html>