<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Product extends Model
{
    use HasFactory;
    protected $table = 'product';
    protected $primaryKey = 'productCode';
    protected $fillable = [
        'productName',
        'productPrice',
        'dailyStock',
        'productCategory',
        'productImage'
    ];

    public static function readProductDetail($productID)
    {
        // Call the readProductDetail stored procedure
        return DB::select("CALL readProductDetail(?)", [$productID]);
    }

    public static function readProductCategory($productCategory)
    {
        // Call the readProductCategory stored procedure
        return DB::select("CALL readProductCategory(?)", [$productCategory]);
    }
    
}
