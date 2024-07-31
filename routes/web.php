<?php

use App\Http\Controllers\posController;
use App\Http\Controllers\userController;
use App\Http\Controllers\productController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/
Route::get("/", [userController::class, 'viewLoginPage']);

Route::get("/forgetpassword", [userController::class, 'viewForgetPasswordPage']);

Route::get("/profile/{customerID}", [userController::class, 'viewProfilePage'])->name('profile');

Route::get('login', [userController::class, 'viewLoginPage'])->name('login');
Route::post('logout', [userController::class, 'logout'])->name('logout');

Route::post('login', [userController::class, 'login'])->name('login');

Route::get("/aboutus/{category}", [productController::class, 'viewAboutUs']);

// Homepage routes
Route::get('/homepage/{category}/{customerID}', [productController::class,'index'])->name('homepage');

// Cart routes
Route::get('/cart', [posController::class,'viewCart'])->name('cart');
Route::post('/add-to-cart', [posController::class,'addToCart'])->name('addToCart');
Route::get('/clearSession', [posController::class,'clearSession'])->name('clearSession');
Route::get('/remove-from-cart/{productId}', [posController::class, 'removeFromCart'])->name('removeFromCart');
Route::get('/update-quantity', [posController::class, 'updateQuantity'])->name('updateQuantity');

// Order routes
Route::get('/orderlist/{orderStatus}', [posController::class,'viewOrder']);
Route::get('/orderdetail/{orderID}', [posController::class, 'viewOrderDetail']);
Route::post('/proceedToPayment', [posController::class,'proceedToPayment'])->name('proceedToPayment');
Route::post('/place-order', [posController::class, 'placeOrder'])->name('placeOrder');

// Payment routes
Route::get('/payment', [posController::class,'viewPayment'])->name('viewPayment');

// Product routes
Route::get('/productdetail/{productName}', [ProductController::class,'viewProductDetail']);
Route::get('/productlist/{category}', [ProductController::class,'getProductsByCategory']);

// User routes
Route::post('/createUser', [userController::class, 'createUser'])->name('createUser');
Route::post('/updatepassword', [userController::class, 'updatePasswordByEmail'])->name('updatePassword');