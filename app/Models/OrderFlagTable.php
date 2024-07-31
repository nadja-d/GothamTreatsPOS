<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderFlagTable extends Model
{
    use HasFactory;

    protected $table = 'orderFlagTable';
    protected $primaryKey = 'id';
    protected $fillable = [
        'orderID_created'
    ];
}
