<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Redirect public verification SPA routes from Laravel backend port (8000) to Vue frontend port (5173)
Route::get('/signer/verify/{token}', function (string $token) {
    $frontendUrl = rtrim(env('FRONTEND_URL', 'http://localhost:5173'), '/');
    return redirect("{$frontendUrl}/signer/verify/{$token}");
});

Route::get('/dispensasi/verifikasi/{token}', function (string $token) {
    $frontendUrl = rtrim(env('FRONTEND_URL', 'http://localhost:5173'), '/');
    return redirect("{$frontendUrl}/dispensasi/verifikasi/{$token}");
});

Route::get('/verify/{publicId}', function (string $publicId) {
    $frontendUrl = rtrim(env('FRONTEND_URL', 'http://localhost:5173'), '/');
    return redirect("{$frontendUrl}/verify/{$publicId}");
});
