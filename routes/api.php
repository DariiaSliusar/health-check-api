<?php

use App\Http\Controllers\Api\V1\HealthCheckController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(['owner.header', 'throttle:60,1'])
    ->prefix('v1')
    ->group(function () {
        Route::get('/health-check', HealthCheckController::class);
    });
