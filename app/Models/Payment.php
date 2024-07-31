<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Payment extends Model
{
    use HasFactory;

    protected $table = 'payment';
    protected $primaryKey = 'paymentCode';
    protected $fillable = [
        'paymentAmount',
        'paymentDate',
        'paymentType',
        'paymentStatus',
    ];
    public static function updatePaymentStatus($paymentID, $newStatus)
    {
        DB::statement("CALL updatePaymentStatus(?, ?)", [$paymentID, $newStatus]);
    }
}
