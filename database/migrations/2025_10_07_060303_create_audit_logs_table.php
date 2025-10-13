<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Enums\JenisRequest;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->string('triggered_by')->nullable(); // user/system
            $table->string('method', 10)->nullable(); // GET, POST, etc
            $table->string('endpoint')->nullable();
            $table->string('status_code', 10)->nullable();
            $table->string('jenis')->nullable();
            $table->text('req_header')->nullable();
            $table->text('req_body')->nullable();
            $table->text('res_header')->nullable();
            $table->text('res_body')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
