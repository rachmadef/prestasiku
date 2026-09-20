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
        Schema::create('schools', function (Blueprint $table) {
            $table->id();
            $table->string('npsn', 20)->unique();
            $table->string('name');
            $table->enum('educational_level', ['sltp', 'slta', 'both'])->default('slta');
            $table->enum('status', ['pending', 'verified', 'rejected', 'suspended'])->default('pending');
            $table->string('province');
            $table->string('city');
            $table->string('district')->nullable();
            $table->text('address')->nullable();
            $table->string('postal_code', 10)->nullable();
            $table->string('phone', 25)->nullable();
            $table->string('email')->nullable();
            $table->string('website')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('verification_notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schools');
    }
};
