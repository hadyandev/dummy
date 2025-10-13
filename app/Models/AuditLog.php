<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuditLog extends Model
{
    protected $fillable = [
        'triggered_by',
        'endpoint',
        'method',
        'status_code',
        'jenis',
        'req_header',
        'req_body',
        'res_header',
        'res_body',
    ];

    protected $casts = [
        'req_header' => 'json',
        'req_body' => 'json',
        'res_header' => 'json',
        'res_body' => 'json',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
