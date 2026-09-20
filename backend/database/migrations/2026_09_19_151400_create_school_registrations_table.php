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
        Schema::create('school_registrations', function (Blueprint $table) {
            $table->id();
            $table->string('npsn', 20)->index();
            $table->string('school_name');
            $table->enum('educational_level', ['sltp', 'slta', 'both'])->default('slta');
            $table->string('province');
            $table->string('city');
            $table->string('district')->nullable();
            $table->text('address')->nullable();
            $table->string('pic_name');
            $table->string('pic_email');
            $table->string('pic_phone', 25);
            $table->string('pic_position');
            $table->string('document_path')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->text('review_notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('school_registrations');
    }
};
