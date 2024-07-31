@isset(session($customerID'))
<div class="navbarBackground">
    <div class="topnav">
        <img src="{{ asset('assets/images/gothamtreats_logo.png') }}" class="logo">
        <div class="item">
            <ul>
                <li>
                    <a href="/homepage/Cookie/{{ session('customerID') }}" class="{{ 
        request()->is('homepage/Cookie/' . session('customerID')) || 
        request()->is('homepage/Milk/' . session('customerID')) || 
        request()->is('homepage/Pudding/' . session('customerID')) || 
        request()->is('homepage/DessertBox/' . session('customerID')) || 
        request()->is('homepage/Pie/' . session('customerID')) ? 'active' : '' }}">
                        Home
                    </a>
                </li>
                <li>
                    <a href="/orderlist/Processing" class="{{ request()->is('orderlist/Processing') || request()->is('orderlist/Completed') ? 'active' : '' }}">
                        Orders
                    </a>
                </li>
                <li>
                    <a href="/productlist/Cookie" class="{{ 
        request()->is('productlist/Cookie') || 
        request()->is('productlist/Milk') || 
        request()->is('productlist/Pie') || 
        request()->is('productlist/Pudding') || 
        request()->is('homepage/DessertBox') ? 'active' : '' }}">
                        Products
                    </a>
                </li>
                <li>
                    <a href="/aboutus/Cookie" class="{{ 
        request()->is('aboutus/Cookie') || 
        request()->is('aboutus/Milk') || 
        request()->is('aboutus/Pie') || 
        request()->is('aboutus/Pudding') || 
        request()->is('aboutus/DessertBox') ? 'active' : '' }}">
                        About Us
                    </a>
                </li>

            </ul>

            <input type="text" class="searchBar" placeholder="Search">

            <ul>
                <li><a href="/cart" class="{{request()->is('cart') ? 'active' : ''}}"><i class="fa fa-shopping-cart"></i></a></li>
                <li>
                    <a href="{{ route('profile', ['customerID' => session('customerID')]) }}" class="{{ request()->is('profile/' . session('customerID')) ? 'active' : '' }}">
                        <i class="fa fa-user-circle-o"></i>
                    </a>
                </li>
                <li><a href="{{ route('logout') }}"><i class="fa fa-sign-out"></i></a></li>
            </ul>
        </div>
    </div>
</div>
@endisset