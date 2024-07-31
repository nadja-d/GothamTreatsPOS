<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css" integrity="sha512-5A8nwdMOWrSz20fDsjczgUidUBR8liPYU+WymTZP1lmY9G6Oc7HlZv156XqnsgNUzTyMefFTcsFH/tnJE/+xBg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <link rel="stylesheet" href="{{ asset('css/aboutus.css') }}" />
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        @include('navbar');

        <div class="Welcome">
            <img src="https://images.squarespace-cdn.com/content/v1/51c8b108e4b050e44c477323/969c4415-dd50-4874-a96c-ed8d7c6acb6a/Greysuitcase+-+Gotham+Treats+02.jpg?format=1500w" class="fotoawal">
            <div class="overview">
                <h1>About Us</h1>
                <p class="penjelasan">Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia,
                    molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum
                    numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentium
                    optio, eaque rerum! Provident similique accusantium nemo autem. Veritatis
                    obcaecati tenetur iure eius earum ut molestias architecto voluptate aliquam
                    nihil, eveniet aliquid culpa officia aut! Impedit sit sunt quaerat, odit,
                    tenetur error, harum nesciunt ipsum debitis quas aliquid. Reprehenderit,
                    quia. Quo neque error repudiandae fuga? Ipsa laudantium molestias eos
                    sapiente officiis modi at sunt excepturi expedita sint? Sed quibusdam
                    recusandae alias error harum maxime adipisci amet laborum. Perspiciatis
                    minima nesciunt dolorem! Officiis iure rerum voluptates a cumque velit
                    quibusdam sed amet tempora. Sit laborum ab, eius fugit doloribus tenetur
                    fugiat, temporibus enim commodi iusto libero magni deleniti quod quam
                    consequuntur! Commodi minima excepturi repudiandae velit hic maxime</p>
            </div>
        </div>

        <div class="products">
            <div class="pilihan">
                <ul>
                    <li><a href="/aboutus/Cookie" class="{{request()->is('aboutus/Cookie') ? 'active' : ''}}">Cookie</a></li>
                    <li><a href="/aboutus/Pudding" class="{{request()->is('aboutus/Pudding') ? 'active' : ''}}">Pudding</a></li>
                    <li><a href="/aboutus/Milk" class="{{request()->is('aboutus/Milk') ? 'active' : ''}}">Milk</a></li>
                    <li><a href="/aboutus/Pie" class="{{request()->is('aboutus/Pie') ? 'active' : ''}}">Pie</a></li>
                    <li><a href="/aboutus/DessertBox" class="{{request()->is('aboutus/DessertBox') ? 'active' : ''}}">Dessert Box</a></li>
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

        <div class="openingHours">
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