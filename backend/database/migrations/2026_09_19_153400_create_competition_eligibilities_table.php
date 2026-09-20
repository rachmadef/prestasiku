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
        Schema::create('competition_eligibilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('competition_id')->unique()->constrained('competitions')->cascadeOnDelete();
            $table->json('allowed_educational_levels')->nullable(); // e.g. ['sltp', 'slta']
            $table->json('allowed_grades')->nullable();             // e.g. [10, 11, 12]
            $table->tinyInteger('min_age')->nullable();
            $table->tinyInteger('max_age')->nullable();
            $table->json('allowed_provinces')->nullable();          // e.g. ['DKI Jakarta', 'Jawa Barat'] or null for all
            $table->enum('gender_restriction', ['any', 'L', 'P'])->default('any');
            $table->text('custom_rules')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competition_eligibilities');
    }
};
