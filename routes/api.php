<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\InboundController;
use App\Http\Controllers\OutboundController;

// Public API routes (no authentication required)
Route::get('/status', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API is working!',
        'timestamp' => now()->toISOString()
    ]);
});

// Outbound routes
Route::get('/health', [OutboundController::class, 'health']);
Route::get('/login', [OutboundController::class, 'login']);
Route::get('/set-remote-credential', [OutboundController::class, 'set_remote_credential']);
Route::get('/license-final', [OutboundController::class, 'license_final']);
Route::get('/license-update', [OutboundController::class, 'license_update']);

// Inbound routes
Route::post('/receive-nib', [InboundController::class, 'receive_nib']);
Route::post('/receive-file-izin', [InboundController::class, 'receive_file_izin']);
Route::post('/receive-status', [InboundController::class, 'receive_status']);


// Protected API routes (authentication required)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});
