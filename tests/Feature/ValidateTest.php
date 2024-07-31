<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Support\Facades\Session;

class ValidateTest extends TestCase
{

    public function testDisplayLogin(): void
    {
        $response = $this->get('/login');

        $response->assertStatus(200);
    }

    public function testLoginWithCorrectCredentials()
    {
        $response = $this->post('/login', [
            'username' => 'Kimberly123',
            'password' => 'password123',
        ]);
    
        $response->assertRedirect(route('homepage', ['category' => 'cookie', 'customerID' => Session::get('customerID')]));
        $response->assertCookie('category');
        $this->assertEquals('C1', Session::get('customerID'));
    }
    
    public function testLoginWithIncorrectCredentials()
    {
        $response = $this->post('/login', [
            'username' => 'invaliduser',
            'password' => 'invalidpassword',
        ]);

        $response->assertRedirect(route('login'));
        $this->assertNull(Session::get('customerID'));
    }
}
