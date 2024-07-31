<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Voucher extends Model
{
    use HasFactory;
    protected $table = 'voucher';
    protected $primaryKey = 'voucherIDCode';
    protected $fillable = [
        'voucherCode',
        'discountPercentages',
        'voucherRequirements',
        'voucherStatus',
    ];
    public static function readVoucher($voucherID)
    {
        return DB::select("CALL readVoucher(?)", [$voucherID]);
    }
}
