<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Outlet;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index($category, $customerID) {
        $filteredProducts = Product::where('productCategory', $category)->paginate(3);
        $outlets = Outlet::all();
    
       
    
        return view("homepage", [
            'customerID' => $customerID,
            'filteredProducts' => $filteredProducts,
            'outlets' => $outlets
        ]);
    }
    
    public function getProductsByCategory($category){
        $filteredProducts = Product::where('productCategory', $category)->get();

        return view('productlist', ['filteredProducts'=> $filteredProducts]);
    }

    public function viewProductDetail($productName){
        $filteredProduct = Product::where('productName', $productName)->first();

        return view('productdetail', ['filteredProduct'=> $filteredProduct]);
    }

    public function viewAboutUs($category){
        $filteredProducts = Product::where('productCategory', $category)->paginate(3);
        $outlets = Outlet::all();

        return view("aboutus", ["filteredProducts" => $filteredProducts, "outlets"=> $outlets]);
    }
}