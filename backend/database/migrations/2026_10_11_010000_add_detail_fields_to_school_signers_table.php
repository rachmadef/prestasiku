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
        Schema::table('school_signers', function (Blueprint $table) {
            $table->string('photo_path')->nullable()->after('signature_token');
            $table->string('birth_place')->nullable()->after('photo_path');
            $table->date('birth_date')->nullable()->after('birth_place');
            $table->text('address')->nullable()->after('birth_date');
            $table->text('education_history')->nullable()->after('address');
            $table->text('biography')->nullable()->after('education_history');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('school_signers', function (Blueprint $table) {
            $table->dropColumn([
                'photo_path',
                'birth_place',
                'birth_date',
                'address',
                'education_history',
                'biography',
            ]);
        });
    }
};
