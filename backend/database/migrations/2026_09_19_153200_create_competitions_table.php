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
        Schema::create('competitions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organizer_id')->constrained('organizers')->cascadeOnDelete();
            $table->foreignId('category_id')->constrained('competition_categories')->cascadeOnDelete();
            $table->string('title');
            $table->string('slug')->unique();
            $table->enum('level', ['provinsi', 'nasional'])->default('nasional');
            $table->enum('target_level', ['sltp', 'slta', 'both'])->default('slta');
            $table->text('description');
            $table->string('official_website_url')->nullable();
            $table->string('guide_book_url')->nullable();
            $table->string('poster_url')->nullable();
            $table->enum('participation_type', ['individual', 'team', 'both'])->default('individual');
            $table->tinyInteger('min_team_members')->default(1);
            $table->tinyInteger('max_team_members')->default(1);
            $table->boolean('requires_school_approval')->default(true);
            $table->decimal('registration_fee', 12, 2)->default(0);
            $table->dateTime('registration_open_at');
            $table->dateTime('registration_deadline');
            $table->dateTime('event_start_at');
            $table->dateTime('event_end_at');
            $table->dateTime('result_published_at')->nullable();
            $table->enum('verification_status', [
                'draft',
                'pending_verification',
                'source_verified',
                'published',
                'cancelled',
                'rejected',
                'expired',
            ])->default('draft');
            $table->enum('visibility', ['public', 'school_only', 'hidden'])->default('public');
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('verified_at')->nullable();
            $table->text('verification_notes')->nullable();
            $table->dateTime('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['verification_status', 'visibility']);
            $table->index(['level', 'target_level']);
            $table->index(['registration_open_at', 'registration_deadline']);
            $table->index(['event_start_at', 'event_end_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competitions');
    }
};
