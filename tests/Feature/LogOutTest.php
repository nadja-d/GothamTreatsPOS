<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Support\Facades\Session;

class LogOutTest extends TestCase
{
    public function testLogoutWithCorrectWebRouting()
    {
        $this->post('/login', [
            'username' => 'Kimberly123',
            'password' => 'password123',
        ]);

        $response = $this->post('logout');

        $response->assertRedirect(route('login'));
        $this->assertNull(Session::get('customerID')); 
    }

    public function testLogoutWithWrongWebRouting()
    {
        $this->post('/login', [
            'username' => 'Kimberly123',
            'password' => 'password123',
        ]);

        $response = $this->post('/logout-wrong-route');
        $response->assertStatus(404); 
    }
    
}