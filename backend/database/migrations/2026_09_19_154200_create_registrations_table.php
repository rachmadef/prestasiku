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
        Schema::create('registrations', function (Blueprint $table) {
            $table->id();
            $table->string('registration_code', 40)->unique();
            $table->foreignId('competition_id')->constrained('competitions')->cascadeOnDelete();
            $table->foreignId('form_version_id')->constrained('competition_forms')->cascadeOnDelete();
            $table->foreignId('school_id')->constrained('schools')->cascadeOnDelete();
            $table->foreignId('student_id')->nullable()->constrained('students')->cascadeOnDelete();
            $table->foreignId('team_id')->nullable()->constrained('teams')->cascadeOnDelete();
            $table->enum('registration_type', ['individual', 'team'])->default('individual');
            $table->foreignId('registered_by')->constrained('users')->cascadeOnDelete();
            $table->enum('status', [
                'draft',
                'pending_school_approval',
                'approved_by_school',
                'rejected_by_school',
                'submitted',
                'confirmed',
                'cancelled',
            ])->default('pending_school_approval');
            $table->enum('school_approval_status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->foreignId('school_approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('school_approved_at')->nullable();
            $table->text('school_notes')->nullable();
            $table->string('assignment_letter_number')->nullable();
            $table->string('assignment_letter_file')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['competition_id', 'status']);
            $table->index(['school_id', 'school_approval_status']);
            $table->index(['student_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registrations');
    }
};
