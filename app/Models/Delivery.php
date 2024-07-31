<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Delivery extends Model
{
    use HasFactory;
    protected $table = 'delivery';
    protected $primaryKey = 'deliveryCode';
    protected $fillable = [
        'outletID',
        'deliveryType',
        'deliveryAddress',
        'deliveryFee',
        'deliveryStatus',
    ];

    public static function updateDeliveryStatus($deliveryID, $newStatus)
    {
        DB::statement("CALL updateDeliveryStatus(?, ?)", [$deliveryID, $newStatus]);
    }  

    public static function updateDeliveryStatus2($deliveryID, $deliveryStatus)
    {
        // Call the updateDeliveryStatus stored procedure
        try {
            DB::beginTransaction();

            DB::select("CALL updateDeliveryStatus(?, ?)", [
                $deliveryID,
                $deliveryStatus,
            ]);

            DB::commit();
        } catch (\Exception $e) {
            // Handle any exceptions or errors
            DB::rollBack();
            throw $e;
        }
    }
}
