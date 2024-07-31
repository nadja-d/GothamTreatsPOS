<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="{{ asset('css/profile.css') }}" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>Gotham Treats</title>
    <link rel="icon" type="image/png" href="https://images.glints.com/unsafe/glints-dashboard.s3.amazonaws.com/company-logo/70e49131e8c325f0dc291e642ba4fa3b.png";>
</head>

<body>
    <div class="container">
        @include('navbar');

        <div class="header">
            <div>
                <i class="fa fa-ellipsis-v"></i>
                <h>My Profile</h>
            </div>
        </div>

        <div class="content">
            <div class="overview">
                <div class="wohoo">
                    <i class="fa fa-user-circle-o"></i>
                    <h>Name</h>
                    <p>{{ $customer->fullName }}</p>
                </div>

                <div class="itsYoBDay">
                    <h>Birthday</h>
                    <p>{{ $customer->birthday }}</p>
                </div>
            </div>

            <div class="profileDetail">
                <div class="detail">
                    <div class="email">
                        <h>Email</h>
                        <p>{{ $customer->email }}</p>
                    </div>

                    <div class="phone">
                        <h>Phone</h>
                        <p>{{ $customer->phone }}</p>
                    </div>

                    <div class="address">
                        <h>Address</h>
                        <p>{{ $customer->address }}</p>
                    </div>
                </div>

                <div class="aboutMe">
                    <h> About Me</h>
                    <input type="text" class="aboutMeInputField">
                </div>
                
            </div>
        </div>
        @include('footer');
    </div>
</body>

</html>