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
            $table->string('letterhead_image_path')->nullable()->after('dispensation_form_schema');
            $table->string('letterhead_type')->default('text')->after('letterhead_image_path'); // 'image' | 'text'
            $table->json('letter_format_config')->nullable()->after('letterhead_type');
            $table->string('dispensation_docx_template_path')->nullable()->after('letter_format_config');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('schools', function (Blueprint $table) {
            $table->dropColumn([
                'letterhead_image_path',
                'letterhead_type',
                'letter_format_config',
                'dispensation_docx_template_path',
            ]);
        });
    }
};
