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
        Schema::table('competition_supervisors', function (Blueprint $table) {
            $table->foreignId('competition_id')->nullable()->change();
            $table->string('competition_name')->nullable()->after('competition_id');
            $table->string('organizer_name')->nullable()->after('competition_name');
            $table->string('competition_branch')->nullable()->after('organizer_name');
            $table->text('student_names')->nullable()->after('competition_branch');
            $table->json('student_ids')->nullable()->after('student_names');
            $table->string('competition_category')->nullable()->default('SMA / MA')->after('student_ids');
            $table->string('competition_place')->nullable()->after('competition_category');
            $table->string('competition_level')->nullable()->default('kabupaten')->after('competition_place');
            $table->string('event_date')->nullable()->after('competition_level');
            $table->string('supervisor_category')->nullable()->default('Guru')->after('role_title');
            $table->string('supervisor_gender')->nullable()->after('supervisor_category');
            $table->string('duty_zone')->nullable()->default('dalam_kota')->after('bisyaroh_amount');
            $table->string('reference_number')->nullable()->after('duty_zone');
            $table->boolean('statement_agreed')->default(true)->after('reference_number');
            $table->string('public_token', 64)->nullable()->unique()->after('statement_agreed');
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null')->after('created_by');
            $table->timestamp('approved_at')->nullable()->after('approved_by');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('competition_supervisors', function (Blueprint $table) {
            $table->dropForeign(['approved_by']);
            $table->dropColumn([
                'competition_name',
                'organizer_name',
                'competition_branch',
                'student_names',
                'student_ids',
                'competition_category',
                'competition_place',
                'competition_level',
                'event_date',
                'supervisor_category',
                'supervisor_gender',
                'duty_zone',
                'reference_number',
                'statement_agreed',
                'public_token',
                'approved_by',
                'approved_at',
            ]);
        });
    }
};
