<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Enums\JenisRequest;
use App\Services\AuditLogService;
use App\Services\GetTokenService;
use GuzzleHttp\Client;

class InboundController
{
    public function __construct()
    {
        $this->httpClient = new Client([
            'base_uri' => env('OSSHUB_ENDPOINT'),
        ]);

        $this->auditLogService = new AuditLogService();
        $this->getTokenService = new GetTokenService();
    }

    public function receive_nib(Request $request){
        $response = response()->json(['message' => 'Received NIB successfully'], 200)
            ->header('Content-Type', 'application/json');
        
        $this->auditLogService->log(
            'osshub',
            $request->fullUrl(),
            'POST',
            '200',
            JenisRequest::INBOUND->value,
            json_encode($request->headers->all()),
            json_encode($request->all()),
            $response->headers->all(),
            $response->getContent()
        );

        return $response;
    }

    public function receive_file_izin(Request $request){
        $response = response()->json(['message' => 'Received file izin successfully'], 200)
            ->header('Content-Type', 'application/json');

        $this->auditLogService->log(
            'osshub',
            $request->fullUrl(),
            'POST',
            '200',
            JenisRequest::INBOUND->value,
            json_encode($request->headers->all()),
            json_encode($request->all()),
            $response->headers->all(),
            $response->getContent()
        );

        return $response;
    }

    public function receive_status(Request $request){
        $response = response()->json(['message' => 'Received status successfully'], 200)
            ->header('Content-Type', 'application/json');

        $this->auditLogService->log(
            'osshub',
            $request->fullUrl(),
            'POST',
            '200',
            JenisRequest::INBOUND->value,
            json_encode($request->headers->all()),
            json_encode($request->all()),
            $response->headers->all(),
            $response->getContent()
        );

        return $response;
    }
    
}
