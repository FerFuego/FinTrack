<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GroupController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\DeviceTokenController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — FinTrack
|--------------------------------------------------------------------------
*/

// ── Public: Auth ──────────────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('register',         [AuthController::class, 'register']);
    Route::post('login',            [AuthController::class, 'login']);
    Route::post('forgot-password',  [AuthController::class, 'forgotPassword']);
    Route::post('reset-password',   [AuthController::class, 'resetPassword']);
});

// ── Protected: Require Sanctum token ─────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // User profile & Devices
    Route::get('user',              [AuthController::class, 'me']);
    Route::post('auth/logout',      [AuthController::class, 'logout']);
    Route::post('devices/token',    [DeviceTokenController::class, 'register']);
    Route::delete('devices/token',  [DeviceTokenController::class, 'unregister']);

    // Groups
    Route::get('groups',            [GroupController::class, 'index']);
    Route::post('groups',           [GroupController::class, 'store']);
    Route::get('groups/{group}',    [GroupController::class, 'show']);
    Route::put('groups/{group}',    [GroupController::class, 'update']);
    Route::delete('groups/{group}', [GroupController::class, 'destroy']);

    // Group summary
    Route::get('groups/{group}/summary', [GroupController::class, 'summary']);

    // Group invitations
    Route::post('groups/{group}/invite',     [GroupController::class, 'createInvitation']);
    Route::post('groups/join',               [GroupController::class, 'joinByCode']);
    Route::delete('groups/{group}/leave',    [GroupController::class, 'leave']);
    Route::delete('groups/{group}/members/{userId}', [GroupController::class, 'removeMember']);

    // Transactions
    Route::get('groups/{group}/transactions',                     [TransactionController::class, 'index']);
    Route::post('groups/{group}/transactions',                    [TransactionController::class, 'store']);
    Route::get('groups/{group}/transactions/{transaction}',       [TransactionController::class, 'show']);
    Route::put('groups/{group}/transactions/{transaction}',       [TransactionController::class, 'update']);
    Route::delete('groups/{group}/transactions/{transaction}',    [TransactionController::class, 'destroy']);
});
