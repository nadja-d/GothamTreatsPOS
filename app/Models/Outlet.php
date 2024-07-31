<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Outlet extends Model
{
    use HasFactory;
    protected $table = 'outlet';
    protected $primaryKey = 'outletCode';
    protected $fillable = [
        'outletLocation',
        'outletAddress',
        'outletPostalCode',
        'outletPhoneNumber',
        'outletOpeningHour',
        'outletClosingHour',
        'outletStartingDay',
        'outletClosingDay',
    ];
    public static function readOutlet($outletID)
    {
        // Call the readOutlet stored procedure
        return DB::select("CALL readOutlet(?)", [$outletID]);
    }
}
