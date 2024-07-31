<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class orderDetail extends Model
{
    use HasFactory;
    protected $table = 'orderdetail';
    protected $primaryKey = 'orderDetailCode';
    protected $fillable = [
        'productID',
        'quantityOrdered',
        'notes',
    ];
    public function product()
    {
        return $this->belongsTo(Product::class, 'productID', 'productID');
    }
}
