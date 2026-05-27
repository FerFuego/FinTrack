<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;

class DeviceTokenController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'token'    => 'required|string',
            'platform' => 'nullable|string|in:android,ios,web',
        ]);

        $deviceToken = DeviceToken::updateOrCreate(
            ['token' => $request->token],
            [
                'user_id'  => $request->user()->id,
                'platform' => $request->platform,
            ]
        );

        return response()->json([
            'message'      => 'Token de dispositivo registrado correctamente.',
            'device_token' => $deviceToken,
        ]);
    }

    public function unregister(Request $request): JsonResponse
    {
        $request->validate([
            'token' => 'required|string',
        ]);

        DeviceToken::where('token', $request->token)
            ->where('user_id', $request->user()->id)
            ->delete();

        return response()->json([
            'message' => 'Token de dispositivo eliminado correctamente.',
        ]);
    }
}
