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
        Schema::create('competition_supervisors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained('schools')->onDelete('cascade');
            $table->foreignId('competition_id')->constrained('competitions')->onDelete('cascade');
            $table->string('supervisor_name');
            $table->string('supervisor_nip')->nullable();
            $table->string('supervisor_phone')->nullable();
            $table->string('role_title')->default('Pendamping Utama');
            $table->decimal('bisyaroh_amount', 12, 2)->default(0);
            $table->string('sop_category')->nullable();
            $table->text('notes')->nullable();
            $table->enum('status', ['pending', 'approved', 'disbursed'])->default('pending');
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competition_supervisors');
    }
};
