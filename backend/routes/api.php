<?php

use App\Http\Controllers\WisataController;
use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::apiResource('/wisatas', WisataController::class);
Route::put('/wisatas/{id}/favorit', [WisataController::class, 'updateFavorit']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
