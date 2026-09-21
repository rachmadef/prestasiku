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
        Schema::table('schools', function (Blueprint $table) {
            if (! Schema::hasColumn('schools', 'dispensation_form_schema')) {
                $table->json('dispensation_form_schema')->nullable()->after('verification_notes');
            }
        });

        Schema::table('kbm_dispensations', function (Blueprint $table) {
            if (! Schema::hasColumn('kbm_dispensations', 'custom_fields_data')) {
                $table->json('custom_fields_data')->nullable()->after('supervisor_name');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kbm_dispensations', function (Blueprint $table) {
            if (Schema::hasColumn('kbm_dispensations', 'custom_fields_data')) {
                $table->dropColumn('custom_fields_data');
            }
        });

        Schema::table('schools', function (Blueprint $table) {
            if (Schema::hasColumn('schools', 'dispensation_form_schema')) {
                $table->dropColumn('dispensation_form_schema');
            }
        });
    }
};
