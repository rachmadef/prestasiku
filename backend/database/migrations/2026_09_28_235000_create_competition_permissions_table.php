<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('competition_permissions', function (Blueprint $table) {
            $table->id();
            $table->string('reference_number')->nullable();
            $table->foreignId('school_id')->constrained('schools')->onDelete('cascade');
            $table->foreignId('student_id')->constrained('students')->onDelete('cascade');
            $table->foreignId('competition_id')->nullable()->constrained('competitions')->onDelete('set null');
            $table->string('competition_name');
            $table->enum('competition_level', ['kabupaten', 'provinsi', 'nasional', 'internasional'])->default('kabupaten');
            $table->string('news_url')->nullable();
            $table->text('purpose')->nullable();
            $table->date('event_start_date')->nullable();
            $table->date('event_end_date')->nullable();
            $table->string('parent_name')->nullable();
            $table->enum('parent_approval_status', ['pending', 'approved', 'rejected'])->default('approved');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->json('custom_fields_data')->nullable();
            $table->foreignId('requested_by')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->string('verification_token')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competition_permissions');
    }
};
