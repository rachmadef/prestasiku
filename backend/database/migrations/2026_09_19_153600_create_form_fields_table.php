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
        Schema::create('form_fields', function (Blueprint $table) {
            $table->id();
            $table->foreignId('form_id')->constrained('competition_forms')->cascadeOnDelete();
            $table->string('label');
            $table->string('field_key', 100);
            $table->enum('field_type', [
                'text',
                'textarea',
                'number',
                'date',
                'select',
                'radio',
                'checkbox',
                'file',
                'email',
                'phone',
            ])->default('text');
            $table->string('placeholder')->nullable();
            $table->string('help_text')->nullable();
            $table->boolean('is_required')->default(false);
            $table->json('options')->nullable();           // e.g. [{"label": "Fisika", "value": "fisika"}]
            $table->json('validation_rules')->nullable();  // e.g. {"mimes": "pdf", "max_size_kb": 2048}
            $table->json('conditional_rule')->nullable();  // e.g. {"field": "kategori", "value": "robotik"}
            $table->integer('order')->default(0);
            $table->timestamps();

            $table->index(['form_id', 'order']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('form_fields');
    }
};
