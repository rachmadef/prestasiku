<?php

namespace Tests\Feature;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\Organizer;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class CompetitionAdminManagementTest extends TestCase
{
    use RefreshDatabase;

    protected User $superAdmin;
    protected User $schoolAdmin;
    protected Organizer $organizer;
    protected CompetitionCategory $category;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@prestasiku.id',
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->superAdmin->assignRole('super_admin');

        $this->schoolAdmin = User::create([
            'name' => 'School Admin',
            'email' => 'schooladmin@sekolah.id',
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->schoolAdmin->assignRole('school_admin');

        $this->organizer = Organizer::create([
            'name' => 'Kementerian Riset',
            'type' => 'kementerian',
        ]);

        $this->category = CompetitionCategory::create([
            'name' => 'Riset Ilmiah',
            'slug' => 'riset-ilmiah',
        ]);
    }

    public function test_super_admin_can_create_competition_with_form_and_eligibility(): void
    {
        $payload = [
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'Lomba Karya Ilmiah Remaja 2026',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Kompetisi karya tulis ilmiah se-Indonesia.',
            'participation_type' => 'team',
            'min_team_members' => 2,
            'max_team_members' => 3,
            'registration_open_at' => now()->startOfMonth()->format('Y-m-d H:i:s'),
            'registration_deadline' => now()->endOfMonth()->format('Y-m-d H:i:s'),
            'event_start_at' => now()->addMonth()->format('Y-m-d H:i:s'),
            'event_end_at' => now()->addMonth()->addDays(3)->format('Y-m-d H:i:s'),
            'verification_status' => 'draft',

            'eligibility' => [
                'allowed_educational_levels' => ['slta'],
                'allowed_grades' => [10, 11],
            ],

            'sources' => [
                [
                    'source_type' => 'official_website',
                    'source_url' => 'https://lomba.example.com',
                    'source_title' => 'Website Resmi LKIR 2026',
                    'is_verified' => true,
                ],
            ],

            'form' => [
                'title' => 'Formulir Pendaftaran Tim LKIR',
                'fields' => [
                    [
                        'label' => 'Judul Makalah Penelitian',
                        'field_key' => 'judul_penelitian',
                        'field_type' => 'text',
                        'is_required' => true,
                    ],
                    [
                        'label' => 'Upload Abstrak (PDF)',
                        'field_key' => 'file_abstrak',
                        'field_type' => 'file',
                        'is_required' => true,
                    ],
                ],
            ],
        ];

        $response = $this->actingAs($this->superAdmin)
            ->postJson('/api/v1/admin/competitions', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'Lomba Karya Ilmiah Remaja 2026')
            ->assertJsonPath('data.verification_status', 'draft')
            ->assertJsonCount(2, 'data.active_form.fields');

        $this->assertDatabaseHas('competitions', [
            'title' => 'Lomba Karya Ilmiah Remaja 2026',
            'verification_status' => 'draft',
        ]);

        $this->assertDatabaseHas('competition_eligibilities', [
            'gender_restriction' => 'any',
        ]);

        $this->assertDatabaseHas('form_fields', [
            'field_key' => 'judul_penelitian',
        ]);
    }

    public function test_super_admin_can_verify_and_publish_competition(): void
    {
        $comp = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'Kompetisi Verifikasi Test',
            'slug' => 'kompetisi-verifikasi-test',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Desc',
            'registration_open_at' => now(),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(15),
            'event_end_at' => now()->addDays(17),
            'verification_status' => 'draft',
            'visibility' => 'public',
        ]);

        $response = $this->actingAs($this->superAdmin)
            ->postJson("/api/v1/admin/competitions/{$comp->id}/verify", [
                'status' => 'published',
                'verification_notes' => 'Sumber resmi tervalidasi.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.verification_status', 'published');

        $comp->refresh();
        $this->assertEquals('published', $comp->verification_status);
        $this->assertNotNull($comp->published_at);
        $this->assertEquals($this->superAdmin->id, $comp->verified_by);
    }

    public function test_super_admin_can_add_new_form_version(): void
    {
        $comp = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'Kompetisi Versioning Form',
            'slug' => 'kompetisi-versioning-form',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Desc',
            'registration_open_at' => now(),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(15),
            'event_end_at' => now()->addDays(17),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        $response = $this->actingAs($this->superAdmin)
            ->postJson("/api/v1/admin/competitions/{$comp->id}/forms", [
                'title' => 'Formulir Baru Versi 2',
                'fields' => [
                    [
                        'label' => 'Nama Anggota Tambahan',
                        'field_key' => 'anggota_tambahan',
                        'field_type' => 'textarea',
                    ],
                ],
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.version', 1) // First form version created
            ->assertJsonPath('data.is_active', true);
    }

    public function test_non_super_admin_forbidden_from_competition_management(): void
    {
        $response = $this->actingAs($this->schoolAdmin)
            ->getJson('/api/v1/admin/competitions');

        $response->assertStatus(403);
    }
}
