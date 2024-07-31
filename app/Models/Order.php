<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class order extends Model
{
    use HasFactory;
    protected $table = 'order';
    protected $primaryKey = 'orderCode';
    protected $fillable = [
        'customerID',
        'voucherID',
        'paymentID',
        'orderDateTime',
        'orderStatus',
        'orderTotalPrice',
        'orderTotalAfterDiscount'
    ];
    public function voucher()
    {
        return $this->hasOne(Voucher::class, 'voucherID', 'voucherID');
    }
    public function payment()
    {
        return $this->belongsTo(Payment::class, 'paymentID', 'paymentID');
    }
    public static function readOrderData($orderID)
    {
        // Call the readOrderData stored procedure
        return DB::select("CALL readOrderData(?)", [$orderID]);
    }

    public static function createOrderAll(
        $customerID,
        $voucherID,
        $orderDateTime,
        $orderStatus,
        $productID,
        $toppingDetailID,
        $quantityOrdered,
        $notes,
        $outletID,
        $deliveryAddress
    ) {
        // Call the createOrderAll stored procedure
        try {
            DB::beginTransaction();

            $result = DB::select("CALL createOrderAll(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [
                $customerID,
                $voucherID,
                $orderDateTime,
                $orderStatus,
                $productID,
                $toppingDetailID,
                $quantityOrdered,
                $notes,
                $outletID,
                $deliveryAddress,
            ]);

            DB::commit();

            return $result;
        } catch (\Exception $e) {
            // Handle any exceptions or errors
            DB::rollBack();
            throw $e;
        }
    }
}
