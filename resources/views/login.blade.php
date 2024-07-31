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
        <div class="form-container sign-up-container">
            <form action="{{ route('createUser') }}" method="post">
                @csrf
                <h1>Create Account</h1>
                <input type="text" name="username" placeholder="Username" required />
                <input type="text" name="fullName" placeholder="Name" required />
                <input type="email" name="email" placeholder="Email" required />
                <input type="password" name="password" placeholder="Password" required/>
                <input type="text" name="phone" placeholder="Phone" required />
                <input type="date" name="birthday" placeholder="Birthday" required />
                <input type="text" name="address" placeholder="Address" required />
                <button type="submit">Sign Up</button>
            </form>
            <!-- Your Blade View File -->
            @if(session('message'))
            <div class="message">
                {{ session('message') }}
            </div>
            @endif
        </div>

        <div class="form-container sign-in-container">
        <form action="{{ route('login') }}" method="post">
    @csrf
    <h1>Log in</h1>
    <input type="text" name="username" placeholder="Username" />
    <input type="password" name="password" placeholder="Password" />
    <a href="/forgetpassword">Forgot your password?</a>
    <button type="submit">Login</button>
</form>

        </div>
        <div class="overlay-container">
            <div class="overlay">
                <div class="overlay-panel overlay-left">
                    <img src="data:image/png;base64,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" class="logo">
                    <h1>Hello, Friend!</h1>
                    <p>Enter your personal details and start cookie with us</p>
                    <button class="ghost" id="signIn">Login</button>
                </div>
                <div class="overlay-panel overlay-right">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAllBMVEUoOY7///8mN40jNYwbL4ofMosYLYkTKokhM4z4+fwAIoYVK4mrr8v19voAGIPz9PmEjLoLJofg4u7t7/a5vddBT5mNlcDCxt0yQpPW2enn6PFGU5sAHYTR1OY4R5WUm8J4grdRXZ9ga6l+hreiqctsdq5VYKGvs8+aosi+wtpVYaQ2RpZdZqMADoFocqx7hblteLMAAH/A9g5ZAAAOkUlEQVR4nO1biXLiyg61u71hs3gDg9kXxxAYcu///9xrSd22ScjcSSbJTF7pVE0VY7Ddam1HUseyGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDA+GW4UyT+9ho+ACIL7cvhVfVgFX7yaT0AwfbiO74go5MG27Z4lvn5JH4vgXGT2rHJffOHtB0pCe+L9gUV9JOR0CXL0oxdfeD34wp6Ff2JZHwcR1PZdCYVb4Bd2+s0llPMU5Vg/t0X3OiIJi+SPLOzD4G5QjMHeub0ugpwEtJ+c+3d+F0RHFCN7fJYU/IMWMFv8mYV9GEIy0nJ6mxPkXAtoT765Co0k5Tbxw7BNislSC7hcfXNSE020JMU6n6VbI42z1pcH1bdWoZCeZ3SF+EenfTme6Ssn5xszGukn4/hGwJmRxtmbS+dvbKNylXels7PlP56WUPiZvrj2/+wifwveqStfsX5MXKNC9x+j1HuE/NsgUWliNqmJe2aB1+ZDEWnb7e1f0vFvBGFtVqE3pIS/73I2p9J8rZ984zBjAbWWJqa0aQKuW+SggxdU9VsiQWly2VGWW2kyEwhIKI7nuHdUKQLPD33v3ld/FcS0BH/rFrnCL9EHN8pERbS6xJNJdX7eyRDO6nKsZ/mxmv5ljEA6UdTN4Q6W8YNu+RA9UZ5QVaFjxUuMRKf5rYiOWNMXKgjv/5ZwK6QMouE4PtSx1S5XopH24lZC54IqTOdShruZFsPOu8RcJpWhPHBz/aI78EcQBJfLpaYYqVZvrlKV25HQ8LVcuiusn3oocPbQ7Ipwxrr472X0vOHf4IvuQz0YGIXYR7PrIa21I6Hha/0fpKdlPIfflG2wdSqst0bLerK79kHG3dfGXOlFL33fuRoalsKHkd51adnPJBQ/tP2d1gOyTmcIV5YrQ+iSPSouva5cL3A96BCUm6+MNsF8Uu+f76lcGfm2wyEoKbdQJf7puYQuWObA6Hqw9mWABWRf/0DIGG/Ihy4mmGhDNvxl0UaIPZjQ5RnZklqS0cWxRAiUrA+RQ67Ax2YdCd0nZcmlCSMD0E0E9/Z0F0cILCd7a50/3bkJS+3LAif4RL/0Y/S15W1F4Gy0Vg5wnTytcpXBwa97E/hHAjgYeGItYLaJhE6YpRbBIzIQaxnklPy4bmVyk+3TNfg0OhvMjdV5N9toqghsSLhX+Lh3hBeDT+5BoD5uiXvGbdCFxXIFxh7s4EcFtUwDsvZ1SE8XAT24bLNltEMDeN7W+jgJTT1bxk77juDhptqTlwzs1adkcLImRsIAo2Y/Ir2kU3yCuxmRxuFOq+japJz26bF50zKONvSqQ6QiXhL6jS6llB9huo01Ki0ut20CMGZnlytX6zAb02aXc99ISIS7iOa0yDjSN4Ml42fhUB0y0ev2TS/H9D4s56GkK/3FYrxepnU1xG1yFufxKvE/QLEnCAL6JWWToxPYeUrcxdiPAljngH5VRoEHEh6VQSag0+IcUZ+0r2/GdipNLnSqPOqSqmmoDowK2+5OsdefZpdAOBT+7Py3Iy5a4yE0LZaTfrHApLc80xuPx05pXygHQgnXkeVDEKlXDjX5czNSE6DYGt2UOqvFAr8RTTcOTJLgTewXyKogNm8st78poqesMdtGlXn4loyHOqL1MH/+8nQDbSZcVu6G4EEHKX20xNTSa6GpBuYK9xF3ilJ/4BgN2oOdNhbxY3Tz+Am+cbRsqFTLpdQGJcnbjTacQdBzGwlTYss4mOjF0XjWfb+d1QEWGfj7UVzAb0JBLGc5NW9HH55BaJEWhDH0ZFU7r9qHHRxDkOAHAyPQMYlk0Szl+gTSl8aehbWfzXZvFtFTz9g4rYT2GoMNKknldPfSvFC9K9/phNL+vhDCQi8cXZsotQAVnvAjKu1IaWXXCrickrqFi2Y70fG1VsJERs/53KM5z7C7cfVb+3jBTt01lW3k1BaF7wHW4k43tfmqTkz8ayVU2VJMQaJlU0HKhrL59FjQpggpJ9DAY6Itj9jCISJnKMCPjYQnqdwduYiRcAgPeDmT/Q9Eavm9oRbohC5xVWII7GpjFS9cfzi3tvZNMRFcKDuMrvCLqVLOoO0Ce+CV2S4Q3pYW+wPSIAaU9NFHm9iSrbljtBqf2EU6Dtr5XA3HIPBJetYqPFB0OX9j3BG+2tNlQiOVfLGHLQOWJinf11qkAGToPl2OkSaMnlCp7mPdb20Ud81OXeFSxQRKkFM0hPQSUdSl3CFXS9ScftoTqEeccQtmtGEguW5tuRXk7TcfD0AarcrtH6CivYfD+YF6fURRvdDuQv89dVxAPsBPr9owA5Uw2+9Iwh9hbOLhv5GDIvTmroNlBTmTwNCqaBDxp9SHp8ltSQ7R7OOGqBHGvOLNnQEkkIqsgTemK+kg28odedbxJU6webiBtfasroEE4Xkc3B/AYJLPKjRL5EubSUb75RKRyNBIBfKCdO5qVkD1YoAEmEbIJOEVNy+BbZu9fWiHPaXKRaahvF8I2KjBxt/p7R8dqnGSYKXQRAcDKV4hjdTeR9lmkzbbnZQs1gL+vxxjIlmj3aqLHn4iH6D5+Yz0CRJSVxbLg8E7RudIICsHguHJtQwbXQJH65GQozI/oOucfpkEt5Nge+6m5mONrayhrSUMMHDYSIRDCC4nvSJUPVWWlFdhOwSa+fIdjQ/cvQpKvhExUlwB1Ld2um8YOZrYG46qheamKgrmuo9VUXDB56tFE8/LsFlDO5KTSaATa6a2gBXkFgRYTCHvGdpFsJFX4BUFcRm/oWnLRTxrqVM2fcPT9ZTfnqhFOw+HPK+PK21fGLR7VyfGRsEOgwgde1iTE6Cj5hRqp6h7RyenLH5HA1Jg5/NYtbmuTeV7xxnvrjr9Zq+MrUUUKvjPuvS05EGFWpFKTZ5n9ofyeZnC3qVI5tQzwGQyTbATu2l/kD+r5CWHBUSHd/U5Ik2XIJDiBXMUyLYhK0o3OU/SNJ2sXhHwXKtv07x69nLx1D9smjZ5NyLJrSmsldXotI8tvZpOGGFe0twYDbY3SZwxdhTCd1XDjmFkrQXoqsXwP+kpJXm3Jhp4WmBw48Ht7fq5UfRK1yXYkGP2DrqJLgSugaaqFMwP9G6t70Mf6cY7O1W+0WGTaFy9gjunDhHS9YbbtW5CqduPD9fr2h4ZK3ZcN/hp70EEF+RPldEwpfiUThi5OITUi2mGyuCyzzuBvwrH8I72OOgCk/0rB2JUDKygH6C5opLwrGQKJ81kO95fHx7mZ8d/XchAmd2wHY5TBRx7JH7eGqxaipkqZ5t3NzOMxvL2nB2FifpO6pFOOF5Do7QsiI+CkWOeVktB5oEJLCtnRV03zocj1Wfoik8cj9I96fNq1CVXh2WZzfLJ2XufiVqNDgdtXanH8flLs3fmT0tYQH7ZmlrXq7GhJJQS0apVrqmPRPiMhDAW/2migRSf6fcjfeu0LaSz2j7MLe8debB5BPHcQ0swyROoQr8Bctcss9PEbfxMWamqnr1VZQ8u8PukLC0/Cc+7QzOUCGedo6Zwn4AeYdBxVcefLvSOwTkIFWM7bxXylcPkvwy0q9Oq8z7KgL0X3YLgUhb93WPaPa0HEi6u9dIexKAzcS4L2CsZNJHUASJtmt3RNAmT8+UyHu+2nac0Bi2x8fXBh/6Euz/GHTNqenvxi/eI7dRzw3rUkV1JWOQDKIRRJ8Fu9Ow2KeFxVP+I1bJUybPMslL9O9whKAJIzHL6bp+7D+HeDrBNO2P9cgUghcqAnSIUk03ZsysKnerLcxI5bVgQsm/n86zA/BZc0hHS+UxJOXi5g/CG8dN18cmTU99QgDS6+yaVo/IbK53F435DD0523j/U67H5hSptR55MyzM64PRxt4kPdu8xWe0u0xePBgj3008bDSHOZLDTD/czUDDozK6VhLvE2w1oZK2bEdQMRyQH+zBc1D2iDyII3Gg1KxYqfJhHuJEf3Uknnwdqxw9r+9W2XdQ1UyXhWIrpiRK2Csy9zWadzzZaEa4qi9K4mnXukJde58FCbOq8/o908qEQFoTrOARnTO/rUNXgp4YegISqQKoGmLFVXRKHrueH5rzp1Ey16iY5qIx37Hi4CtzKaGZf9wc22LbpeRi1X5xSJygx0uaUOupQ3ZbiGMI7tnTE0lOnYjariw4HVBytVai76fUm231qbz7d+wy8ifJApaJh785fGhAgnSSdjA8SujtMYsnyZoriVj17P1TV479ly+PVBrUnaVRY24TSW8Vfdx4VOaKyIqzEj/e7IiJvh7VkpaA9iJYOtZgMwsIeYU2nBGmyH0jYyKPKo4MK2fLrDmXQuFOZDPYy+q/s7Kk1KrV2PaoXSOtqTyLgUjA2/Vtn3f4VlMq3efNcxRDsw5dGUpqWKs6Cef/+hEB0JbSmHdaobjopnjy+XGBCB0HrQEQguNqlcV2lts7xTJhrzKYfMOX9dZxoDIwz7VcOiqpa4H5gABPPsnQ2GJXK7YLdINNnEaAzYqKlkrDr38lhZJ++9Nz7iQ6jQckxeq3Kt47ju8GdxiipyjfZBUQ7Vlo58qG0Tami7PrmuWJXqsrmw9b/3zjBgQuJo+9XsoVFTnf3+nCoQmc4XIR00sBIIsaFKdtF0j3OBxe8bXs47PNBTQRlgyDhK9niPVBbZpoyq27liVu1KHqXr/NEzBbK/7CGulffvBdNS8OyT005OD1Yvuv8KF/ten0CcFCjIrvcpq9ni99CdGxIgRjb2aHaLO3e5etCTfAIzdmpDC69j9Vhi07PRehi+3C/kvoUCA9eegoXE/snsfSjILFzN4jfMhL5bTh4IP00uW0wfhakFw6Hiy/+OzenNE3mzzzv+Sdh/rYn/9Z/nfVTOOd13a93yf+tgHio/dXBEYPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAzG34T/ARGF4u0N4067AAAAAElFTkSuQmCC" class="logo">
                    <h1>Welcome Back!</h1>
                    <p>To keep connected with us please login with your personal info</p>
                    <button class="ghost" id="signUp">Sign Up</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        const signUpButton = document.getElementById('signUp');
        const signInButton = document.getElementById('signIn');
        const container = document.getElementById('container');

        signUpButton.addEventListener('click', () => {
            container.classList.add("right-panel-active");
        });

        signInButton.addEventListener('click', () => {
            container.classList.remove("right-panel-active");
        });
    </script>


</body>

</html>