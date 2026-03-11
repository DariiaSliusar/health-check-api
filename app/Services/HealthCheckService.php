<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class HealthCheckService
{
    public function check(): array
    {
        return [
            'db'    => $this->checkDatabase(),
            'cache' => $this->checkCache(),
        ];
    }

    private function checkDatabase(): bool
    {
        try {
            DB::connection()->getPdo();
            return true;
        } catch (\Throwable $e) {
            return false;
        }
    }

    private function checkCache(): bool
    {
        try {
            Cache::set('health_check_ping', true, 5);
            return Cache::get('health_check_ping') === true;
        } catch (\Throwable $e) {
            return false;
        }
    }
}
