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
        Schema::create('achievements', function (Blueprint $table) {
            $table->id();
            $table->string('public_id', 40)->unique();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->foreignId('school_id')->constrained('schools')->cascadeOnDelete();
            $table->foreignId('competition_id')->nullable()->constrained('competitions')->nullOnDelete();
            $table->foreignId('registration_id')->nullable()->constrained('registrations')->nullOnDelete();
            $table->string('title');
            $table->enum('level', ['kota_kabupaten', 'provinsi', 'nasional', 'internasional'])->default('nasional');
            $table->string('rank', 100);
            $table->string('event_name');
            $table->string('organizer_name');
            $table->date('event_date');
            $table->enum('status', ['draft', 'pending_verification', 'verified', 'rejected'])->default('pending_verification');
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('verified_at')->nullable();
            $table->text('verification_notes')->nullable();
            $table->boolean('is_public')->default(false); // Privacy by default
            $table->timestamps();
            $table->softDeletes();

            $table->index(['public_id', 'status']);
            $table->index(['school_id', 'status']);
            $table->index(['student_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('achievements');
    }
};
