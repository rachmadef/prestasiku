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
        Schema::table('competitions', function (Blueprint $table) {
            $table->enum('curation_type', [
                'resmi_negara',
                'terkurasi_puspresnas',
                'bergengsi_non_kurasi',
            ])->default('resmi_negara')->after('category_id')->index();

            $table->string('curation_rating')->nullable()->after('curation_type');
            $table->string('curation_number')->nullable()->after('curation_rating');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('competitions', function (Blueprint $table) {
            $table->dropIndex(['curation_type']);
            $table->dropColumn(['curation_type', 'curation_rating', 'curation_number']);
        });
    }
};
