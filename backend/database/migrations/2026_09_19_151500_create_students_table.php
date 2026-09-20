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
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->foreignId('school_id')->constrained('schools')->cascadeOnDelete();
            $table->string('nis', 30);
            $table->string('nisn', 20)->nullable()->index();
            $table->string('full_name');
            $table->tinyInteger('grade_level'); // 7-9 (SLTP), 10-12 (SLTA)
            $table->string('class_name', 50);
            $table->enum('gender', ['L', 'P']);
            $table->date('birth_date');
            $table->string('birth_place', 100)->nullable();
            $table->string('phone_number', 25)->nullable();
            $table->string('public_id', 40)->unique();
            $table->boolean('public_profile_enabled')->default(false); // privacy-by-default
            $table->enum('status', ['active', 'graduated', 'transferred', 'inactive'])->default('active');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['school_id', 'nis']);
            $table->index(['school_id', 'grade_level']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
