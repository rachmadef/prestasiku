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
        Schema::table('kbm_dispensations', function (Blueprint $table) {
            if (! Schema::hasColumn('kbm_dispensations', 'competition_field')) {
                $table->string('competition_field')->nullable()->after('competition_name');
            }
            if (! Schema::hasColumn('kbm_dispensations', 'competition_level')) {
                $table->string('competition_level')->nullable()->after('competition_field');
            }
            if (! Schema::hasColumn('kbm_dispensations', 'organizer')) {
                $table->string('organizer')->nullable()->after('competition_level');
            }
            if (! Schema::hasColumn('kbm_dispensations', 'execution_type')) {
                $table->string('execution_type')->nullable()->after('organizer');
            }
            if (! Schema::hasColumn('kbm_dispensations', 'location')) {
                $table->string('location')->nullable()->after('execution_type');
            }
            if (! Schema::hasColumn('kbm_dispensations', 'homeroom_teacher')) {
                $table->string('homeroom_teacher')->nullable()->after('supervisor_name');
            }
            if (! Schema::hasColumn('kbm_dispensations', 'phone_number')) {
                $table->string('phone_number', 50)->nullable()->after('homeroom_teacher');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kbm_dispensations', function (Blueprint $table) {
            $cols = [];
            foreach (['competition_field', 'competition_level', 'organizer', 'execution_type', 'location', 'homeroom_teacher', 'phone_number'] as $col) {
                if (Schema::hasColumn('kbm_dispensations', $col)) {
                    $cols[] = $col;
                }
            }
            if (! empty($cols)) {
                $table->dropColumn($cols);
            }
        });
    }
};
