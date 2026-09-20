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
        Schema::create('achievement_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('achievement_id')->constrained('achievements')->cascadeOnDelete();
            $table->enum('document_type', [
                'certificate',
                'decree_sk',
                'assignment_letter',
                'result_link',
                'photo_documentation'
            ])->default('certificate');
            $table->string('document_number')->nullable();
            $table->string('file_path')->nullable();
            $table->string('external_url', 500)->nullable();
            $table->string('file_name')->nullable();
            $table->unsignedInteger('file_size')->nullable(); // bytes
            $table->string('file_mime', 100)->nullable();
            $table->timestamps();

            $table->index(['achievement_id', 'document_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('achievement_documents');
    }
};
