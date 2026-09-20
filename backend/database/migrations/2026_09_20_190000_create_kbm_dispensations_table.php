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
        Schema::create('kbm_dispensations', function (Blueprint $table) {
            $table->id();
            $table->string('reference_number', 100)->nullable()->unique();
            $table->foreignId('school_id')->constrained('schools')->cascadeOnDelete();
            $table->foreignId('competition_id')->nullable()->constrained('competitions')->nullOnDelete();
            $table->string('competition_name');
            $table->enum('dispensation_type', ['persiapan_latihan', 'pelaksanaan_lomba', 'lainnya'])->default('persiapan_latihan');
            $table->text('purpose');
            $table->date('start_date');
            $table->date('end_date');
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();
            $table->boolean('is_all_day')->default(true);
            $table->string('supervisor_name')->nullable();
            $table->string('attachment_path')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'completed'])->default('pending');
            $table->foreignId('requested_by')->constrained('users')->cascadeOnDelete();
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->string('verification_token', 64)->unique();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['school_id', 'status']);
            $table->index(['start_date', 'end_date']);
            $table->index('verification_token');
        });

        Schema::create('kbm_dispensation_students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('dispensation_id')->constrained('kbm_dispensations')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->string('notes')->nullable();
            $table->timestamps();

            $table->unique(['dispensation_id', 'student_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kbm_dispensation_students');
        Schema::dropIfExists('kbm_dispensations');
    }
};
