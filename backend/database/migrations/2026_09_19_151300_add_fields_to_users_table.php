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
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->nullable()->unique()->after('email');
            $table->string('phone', 25)->nullable()->after('username');
            $table->foreignId('school_id')->nullable()->after('phone')->constrained('schools')->nullOnDelete();
            $table->boolean('must_change_password')->default(false)->after('password');
            $table->timestamp('password_changed_at')->nullable()->after('must_change_password');
            $table->timestamp('last_login_at')->nullable()->after('password_changed_at');
            $table->string('last_login_ip', 45)->nullable()->after('last_login_at');
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active')->after('last_login_ip');
            $table->softDeletes()->after('updated_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['school_id']);
            $table->dropColumn([
                'username',
                'phone',
                'school_id',
                'must_change_password',
                'password_changed_at',
                'last_login_at',
                'last_login_ip',
                'status',
                'deleted_at'
            ]);
        });
    }
};
