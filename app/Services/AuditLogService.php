<?php
namespace App\Services;
use App\Models\AuditLog;

class AuditLogService
{
    public function log($triggered_by, $endpoint, $method, $status_code, $jenis, $req_header, $req_body, $res_header, $res_body){
        AuditLog::create([
            'triggered_by' => $triggered_by,
            'endpoint' => $endpoint,
            'method' => $method,
            'status_code' => $status_code,
            'jenis' => $jenis,
            'req_header' => $req_header,
            'req_body' => $req_body,
            'res_header' => $res_header,
            'res_body' => $res_body,
        ]);
    }
    }