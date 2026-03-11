<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HealthCheckLog extends Model
{
    protected $fillable = [
        'owner_id',
        'ip_address',
        'status',
        'response_code',
    ];

    protected $casts = [
        'status' => 'array',
    ];
}
