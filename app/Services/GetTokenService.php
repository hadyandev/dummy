<?php
namespace App\Services;

use GuzzleHttp\Client;

class GetTokenService
{
    public function getToken(){
        try {
            // Using service will automatically create audit log
            $client = new Client([
                'base_uri' => env('OSSHUB_ENDPOINT'),
            ]);
            $response = $client->post('auth/login', [
                'form_params' => [
                    'username' => env('OSSHUB_USERNAME'),
                    'password' => env('OSSHUB_PASSWORD') // Will be hidden in audit log
                ]
            ]);

            $body = $response->getBody()->getContents();

            $data = json_decode($body, true);
            $accessToken = $data['access_token'] ?? null;

            return $accessToken;

            // return response($body, $response->getStatusCode())
            //     ->header('Content-Type', 'application/json');
        } catch (\Exception $e) {
            // return response()->json([
            //     'error' => 'Login failed',
            //     'message' => $e->getMessage()
            // ], 500);

            return 'no_token';
        }
    }
}