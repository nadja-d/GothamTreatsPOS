<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="{{ asset('css/orderlist.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        @include('navbar');

        <div class="allProducts">
            <h>Order(s)</h>
        </div>

        <div class="orderStatus">
            <a href="{{ url('/orderlist/Processing') }}" class="{{request()->is('orderlist/Processing') ? 'active' : ''}}">Ongoing</a>
            <a href="{{ url('/orderlist/Completed') }}" class="{{request()->is('orderlist/Completed') ? 'active' : ''}}">History</a>
        </div>

        <div class="order">
            <div class="orderDetail">
                @foreach ($orders as $order)
                <div class="orderItems">
                    <img src="{{ asset('assets/images/gothamtreats_logo.png') }}" class="itemPicture">

                    <div class="itemDetail">
                        <h>{{ $order->orderID }}</h>

                        <div class="status{{request()->is('orderlist/Completed') ? 'Completed' : ''}}">
                            <i class="fa fa-clock-o"></i>
                            <i class="fa fa-check-circle-o"></i>
                            <div>{{ $order->orderStatus }}</div>
                        </div>

                        <p>Rp. {{ $order->orderTotalAfterDiscount  }}, -</p>
                    </div>

                    <div class="view{{request()->is('orderlist/Completed') ? 'Completed' : ''}}OrderDetail">
                        <button type="submit" class="btn1"><a href="/orderdetail/{{$order->orderID}}">View Order</a></button>
                        <div>
                        </div>
                    </div>
                </div>@endforeach
            </div>
        </div>

        @include('footer');
    </div>
</body>

</html>