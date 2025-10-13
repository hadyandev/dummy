<?php

namespace App\Console\Commands;

use App\Models\AuditLog;
use Illuminate\Console\Command;

class ShowAuditLogs extends Command
{
    protected $signature = 'audit:show {--limit=10 : Number of records to show}';
    protected $description = 'Show recent audit logs';

    public function handle()
    {
        $limit = $this->option('limit');
        
        $logs = AuditLog::latest()
            ->take($limit)
            ->get();

        if ($logs->isEmpty()) {
            $this->info('No audit logs found.');
            return;
        }

        $this->table(
            ['ID', 'Endpoint', 'Method', 'IP', 'User Agent', 'Status', 'Created At'],
            $logs->map(function ($log) {
                return [
                    $log->id,
                    $log->endpoint_tujuan ?? 'N/A',
                    $log->method ?? 'N/A',
                    $log->ip_address ?? 'N/A',
                    substr($log->user_agent ?? 'N/A', 0, 30) . '...',
                    $log->response_status ?? 'N/A',
                    $log->created_at->format('Y-m-d H:i:s'),
                ];
            })->toArray()
        );

        $this->info("Showing {$logs->count()} most recent audit logs.");
    }
}