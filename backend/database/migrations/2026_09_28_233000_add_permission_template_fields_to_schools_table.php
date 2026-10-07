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
            $table->json('permission_form_schema')->nullable()->after('dispensation_docx_template_path');
            $table->string('permission_docx_template_path')->nullable()->after('permission_form_schema');
            $table->json('permission_letter_format_config')->nullable()->after('permission_docx_template_path');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('schools', function (Blueprint $table) {
            $table->dropColumn([
                'permission_form_schema',
                'permission_docx_template_path',
                'permission_letter_format_config',
            ]);
        });
    }
};
