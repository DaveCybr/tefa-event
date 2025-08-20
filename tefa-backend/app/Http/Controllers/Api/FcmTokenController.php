<?php
// app/Http/Controllers/Api/FcmTokenController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FcmToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class FcmTokenController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'device_type' => 'required|in:android,ios,web',
            'device_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        // Check if token already exists for this user
        $existingToken = FcmToken::where('user_id', Auth::id())
            ->where('token', $request->token)
            ->first();

        if ($existingToken) {
            // Update existing token
            $existingToken->update([
                'device_type' => $request->device_type,
                'device_id' => $request->device_id,
                'is_active' => true,
                'last_used_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'FCM token updated successfully',
                'data' => $existingToken
            ]);
        }

        // Create new token
        $fcmToken = FcmToken::create([
            'user_id' => Auth::id(),
            'token' => $request->token,
            'device_type' => $request->device_type,
            'device_id' => $request->device_id,
            'is_active' => true,
            'last_used_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token stored successfully',
            'data' => $fcmToken
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $fcmToken = FcmToken::where('id', $id)
            ->where('user_id', Auth::id())
            ->first();

        if (!$fcmToken) {
            return response()->json([
                'success' => false,
                'message' => 'FCM token not found',
                'data' => null
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'is_active' => 'boolean',
            'device_type' => 'in:android,ios,web',
            'device_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $fcmToken->update($request->all());

        if ($request->has('is_active') && $request->is_active) {
            $fcmToken->updateLastUsed();
        }

        return response()->json([
            'success' => true,
            'message' => 'FCM token updated successfully',
            'data' => $fcmToken
        ]);
    }

    public function destroy($id)
    {
        $fcmToken = FcmToken::where('id', $id)
            ->where('user_id', Auth::id())
            ->first();

        if (!$fcmToken) {
            return response()->json([
                'success' => false,
                'message' => 'FCM token not found',
                'data' => null
            ], 404);
        }

        $fcmToken->delete();

        return response()->json([
            'success' => true,
            'message' => 'FCM token deleted successfully',
            'data' => null
        ]);
    }

    public function index()
    {
        $tokens = FcmToken::where('user_id', Auth::id())
            ->orderBy('last_used_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'FCM tokens retrieved successfully',
            'data' => $tokens
        ]);
    }

    // Deactivate all tokens for user (useful for logout)
    public function deactivateAll()
    {
        FcmToken::where('user_id', Auth::id())
            ->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'All FCM tokens deactivated successfully',
            'data' => null
        ]);
    }

    // Update token by token string (useful for token refresh)
    public function updateByToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'old_token' => 'required|string',
            'new_token' => 'required|string',
            'device_type' => 'required|in:android,ios,web',
            'device_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $fcmToken = FcmToken::where('user_id', Auth::id())
            ->where('token', $request->old_token)
            ->first();

        if (!$fcmToken) {
            // Create new token if old one doesn't exist
            $fcmToken = FcmToken::create([
                'user_id' => Auth::id(),
                'token' => $request->new_token,
                'device_type' => $request->device_type,
                'device_id' => $request->device_id,
                'is_active' => true,
                'last_used_at' => now(),
            ]);
        } else {
            // Update existing token
            $fcmToken->update([
                'token' => $request->new_token,
                'device_type' => $request->device_type,
                'device_id' => $request->device_id,
                'is_active' => true,
                'last_used_at' => now(),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'FCM token refreshed successfully',
            'data' => $fcmToken
        ]);
    }
}
