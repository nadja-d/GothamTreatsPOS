<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css"
        integrity="sha512-5A8nwdMOWrSz20fDsjczgUidUBR8liPYU+WymTZP1lmY9G6Oc7HlZv156XqnsgNUzTyMefFTcsFH/tnJE/+xBg=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />
    <link rel="stylesheet" href="{{ asset('css/login.css') }}" />
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
<div class="container" id="container">
    <div class="form-container sign-in-container">
    <form action="{{ route('updatePassword') }}" method="post">
                @csrf
                <h1>Forgot Password</h1>
                <p>Enter your email address to reset your password</p>
                <input type="email" name="email" placeholder="email" required />
                <input type="password" name="password" placeholder="password" required/>
                <button type="submit">Reset Password</button>
            </form>
            <!-- Your Blade View File -->
            @if(session('message'))
            <div class="message">
                {{ session('message') }}
            </div>
            @endif
        </div>

        <div class="overlay-container">
            <div class="overlay">
                <img src="https://images.squarespace-cdn.com/content/v1/51c8b108e4b050e44c477323/cd00ac7e-c15c-4782-96a7-7ad0d569bb01/Greysuitcase+-+Gotham+Treats+03.jpg">>
            </div>
        </div>
    </div>

</body>

</html>