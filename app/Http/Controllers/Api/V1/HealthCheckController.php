<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\HealthCheckLog;
use App\Services\HealthCheckService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HealthCheckController extends Controller
{
    public function __construct(private readonly HealthCheckService $healthCheckService)
    {

    }

    public function __invoke(Request $request): JsonResponse
    {
        $status = $this->healthCheckService->check();
        $responseCode = in_array(false, $status, strict: true) ? 500 : 200;

        HealthCheckLog::query()->create([
            'owner_id'      => $request->header('X-Owner'),
            'ip_address'    => $request->ip(),
            'status'        => $status,
            'response_code' => $responseCode,
        ]);

        return response()->json($status, $responseCode);
    }
}
