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
        Schema::create('registration_answers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('registration_id')->constrained('registrations')->cascadeOnDelete();
            $table->foreignId('form_field_id')->constrained('form_fields')->cascadeOnDelete();
            $table->string('field_key', 100);
            $table->string('field_label');
            $table->text('answer_value')->nullable();
            $table->string('file_path')->nullable();
            $table->timestamps();

            $table->index(['registration_id', 'field_key']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registration_answers');
    }
};
