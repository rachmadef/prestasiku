<?php

namespace Tests\Feature;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\Organizer;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CompetitionDiscoveryTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);
    }

    public function test_public_can_browse_only_published_competitions(): void
    {
        $organizer = Organizer::create([
            'name' => 'Kemendikbud',
            'type' => 'kementerian',
            'verification_status' => 'official',
        ]);

        $category = CompetitionCategory::create([
            'name' => 'Sains',
            'slug' => 'sains',
        ]);

        // Published competition
        Competition::create([
            'organizer_id' => $organizer->id,
            'category_id' => $category->id,
            'title' => 'Lomba Sains Nasional Terbuka',
            'slug' => 'lomba-sains-nasional-terbuka',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Kompetisi sains terbuka.',
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(15),
            'event_end_at' => now()->addDays(17),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        // Draft competition (should be hidden)
        Competition::create([
            'organizer_id' => $organizer->id,
            'category_id' => $category->id,
            'title' => 'Lomba Rahasia Draft',
            'slug' => 'lomba-rahasia-draft',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Draft tidak boleh tampil.',
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(15),
            'event_end_at' => now()->addDays(17),
            'verification_status' => 'draft',
            'visibility' => 'public',
        ]);

        $response = $this->getJson('/api/v1/competitions');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.slug', 'lomba-sains-nasional-terbuka');
    }

    public function test_public_can_filter_competitions_by_month(): void
    {
        \Illuminate\Support\Carbon::setTestNow('2026-09-15 12:00:00');

        $organizer = Organizer::create(['name' => 'Org', 'type' => 'kementerian']);
        $category = CompetitionCategory::create(['name' => 'Sains', 'slug' => 'sains']);

        // Competition in current month
        Competition::create([
            'organizer_id' => $organizer->id,
            'category_id' => $category->id,
            'title' => 'Lomba Bulan Ini',
            'slug' => 'lomba-bulan-ini',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Deskripsi',
            'registration_open_at' => now()->startOfMonth(),
            'registration_deadline' => now()->endOfMonth(),
            'event_start_at' => now()->addDays(5),
            'event_end_at' => now()->addDays(7),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        // Competition in next month
        Competition::create([
            'organizer_id' => $organizer->id,
            'category_id' => $category->id,
            'title' => 'Lomba Bulan Depan',
            'slug' => 'lomba-bulan-depan',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Deskripsi',
            'registration_open_at' => now()->addMonth()->startOfMonth(),
            'registration_deadline' => now()->addMonth()->endOfMonth(),
            'event_start_at' => now()->addMonth()->addDays(10),
            'event_end_at' => now()->addMonth()->addDays(12),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        // Filter this_month
        $responseThis = $this->getJson('/api/v1/competitions?timeline=this_month');
        $responseThis->assertStatus(200)
            ->assertJsonPath('data.data.0.slug', 'lomba-bulan-ini');

        // Filter next_month
        $responseNext = $this->getJson('/api/v1/competitions?timeline=next_month');
        $responseNext->assertStatus(200)
            ->assertJsonPath('data.data.0.slug', 'lomba-bulan-depan');

        \Illuminate\Support\Carbon::setTestNow();
    }

    public function test_public_can_view_competition_detail(): void
    {
        $organizer = Organizer::create(['name' => 'Org Resmi', 'type' => 'kementerian']);
        $category = CompetitionCategory::create(['name' => 'Teknologi', 'slug' => 'teknologi']);

        $comp = Competition::create([
            'organizer_id' => $organizer->id,
            'category_id' => $category->id,
            'title' => 'Lomba AI Pelajar 2026',
            'slug' => 'lomba-ai-pelajar-2026',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Kompetisi kecerdasan buatan.',
            'registration_open_at' => now()->subDays(1),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(15),
            'event_end_at' => now()->addDays(17),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        $response = $this->getJson("/api/v1/competitions/{$comp->slug}");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'Lomba AI Pelajar 2026')
            ->assertJsonPath('data.organizer.name', 'Org Resmi');
    }
}
