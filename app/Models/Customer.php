<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Customer extends Model
{
    use HasFactory;
    protected $table = 'customer';

    protected $primaryKey = 'customerID';

    protected $fillable = [
        'customerCode',
        'customerID',
        'username',
        'password',
        'fullName',
        'email',
        'phone',
        'birthday',
        'address',
    ];

    public static function authenticateUser($username, $password)
    {
        // Call the authenticateUser stored procedure
        return DB::select("CALL authenticateUser(?, ?)", [$username, $password]);
    }

    public static function createUserData($username, $password, $fullName, $email, $phone, $birthday, $address)
    {
        // Call the createUserData stored procedure
        try {
            DB::beginTransaction();

            $result = DB::select("CALL createUserData(?, ?, ?, ?, ?, ?, ?)", [
                $username,
                $password,
                $fullName,
                $email,
                $phone,
                $birthday,
                $address,
            ]);

            DB::commit();

            return $result;
        } catch (\Exception $e) {
            // Handle any exceptions or errors
            DB::rollBack();
            throw $e;
        }
    }

    public static function readUserData($customerID)
    {
        // Call the readUserData stored procedure
        return DB::select("CALL readUserData(?)", [$customerID]);
    }

    public function updatePasswordByEmail($email, $newPassword)
    {
        return DB::select("CALL updatePasswordByEmail(?, ?)", [$email, $newPassword]);
    }
}