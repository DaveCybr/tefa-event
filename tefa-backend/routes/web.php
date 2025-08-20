<?php
// routes/api.php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\FcmTokenController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);

// Events (public access)
Route::get('/events', [EventController::class, 'index']);
Route::get('/events/{id}', [EventController::class, 'show']);

// Protected routes
Route::middleware(['auth:sanctum'])->group(function () {

    // Auth routes
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Event management (protected)
    Route::post('/events', [EventController::class, 'store']);
    Route::put('/events/{id}', [EventController::class, 'update']);
    Route::delete('/events/{id}', [EventController::class, 'destroy']);

    // Orders
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::put('/orders/{id}', [OrderController::class, 'update']);
    Route::delete('/orders/{id}', [OrderController::class, 'destroy']);
    Route::get('/me/orders', [OrderController::class, 'myOrders']);

    // FCM Token management
    Route::get('/me/fcm-tokens', [FcmTokenController::class, 'index']);
    Route::post('/me/fcm-token', [FcmTokenController::class, 'store']);
    Route::put('/me/fcm-tokens/{id}', [FcmTokenController::class, 'update']);
    Route::delete('/me/fcm-tokens/{id}', [FcmTokenController::class, 'destroy']);
    Route::post('/me/fcm-token/refresh', [FcmTokenController::class, 'updateByToken']);
    Route::post('/me/fcm-tokens/deactivate-all', [FcmTokenController::class, 'deactivateAll']);
});

// Fallback route for API
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'API endpoint not found',
        'data' => null
    ], 404);
});
