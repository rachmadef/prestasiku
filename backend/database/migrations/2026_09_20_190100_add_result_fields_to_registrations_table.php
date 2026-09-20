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
        Schema::table('registrations', function (Blueprint $table) {
            $table->enum('result_status', ['pending', 'participant', 'finalist', 'winner'])
                ->default('pending')
                ->after('status');
            $table->string('rank_details', 100)->nullable()->after('result_status'); // e.g. "Juara 1", "Peserta Terpilih"
            $table->string('certificate_file')->nullable()->after('rank_details'); // Dokumen sertifikat (peserta/juara)
            $table->text('result_notes')->nullable()->after('certificate_file');
            $table->dateTime('result_recorded_at')->nullable()->after('result_notes');

            $table->index(['school_id', 'result_status']);
            $table->index(['student_id', 'result_status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('registrations', function (Blueprint $table) {
            $table->dropIndex(['school_id', 'result_status']);
            $table->dropIndex(['student_id', 'result_status']);
            $table->dropColumn([
                'result_status',
                'rank_details',
                'certificate_file',
                'result_notes',
                'result_recorded_at',
            ]);
        });
    }
};
