<?php

namespace Tests\Feature;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\CompetitionEligibility;
use App\Models\Organizer;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class EligibilityEngineTest extends TestCase
{
    use RefreshDatabase;

    protected School $schoolJakarta;
    protected School $schoolBandung;
    protected User $studentJakartaUser;
    protected Student $studentJakarta;

    protected Organizer $organizer;
    protected CompetitionCategory $category;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->schoolJakarta = School::create([
            'npsn' => '10101010',
            'name' => 'SMA Jakarta',
            'educational_level' => 'slta',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'status' => 'verified',
        ]);

        $this->studentJakartaUser = User::create([
            'name' => 'Siswa Jakarta',
            'email' => 'siswa.jakarta@sekolah.id',
            'school_id' => $this->schoolJakarta->id,
            'password' => Hash::make('password'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $this->studentJakartaUser->assignRole('student');

        $this->studentJakarta = Student::create([
            'user_id' => $this->studentJakartaUser->id,
            'school_id' => $this->schoolJakarta->id,
            'nis' => 'JKT001',
            'full_name' => 'Siswa Jakarta',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => now()->subYears(16)->format('Y-m-d'), // 16 years old
            'status' => 'active',
        ]);

        $this->organizer = Organizer::create([
            'name' => 'Puspresnas',
            'type' => 'kementerian',
        ]);

        $this->category = CompetitionCategory::create([
            'name' => 'Sains',
            'slug' => 'sains',
        ]);
    }

    public function test_student_is_eligible_for_matching_national_competition(): void
    {
        $comp = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'OSN SMA 2026',
            'slug' => 'osn-sma-2026',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'OSN',
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(20),
            'event_end_at' => now()->addDays(25),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        CompetitionEligibility::create([
            'competition_id' => $comp->id,
            'allowed_educational_levels' => ['slta'],
            'allowed_grades' => [10, 11],
            'min_age' => 14,
            'max_age' => 18,
            'gender_restriction' => 'any',
        ]);

        $response = $this->actingAs($this->studentJakartaUser)
            ->getJson("/api/v1/competitions/{$comp->id}/eligibility");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_eligible', true)
            ->assertJsonCount(0, 'data.failed_criteria');
    }

    public function test_student_ineligible_for_provincial_competition_of_different_province(): void
    {
        // Competition restricted to Jawa Barat
        $compJabar = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'Olimpiade Sains Jawa Barat',
            'slug' => 'olimpiade-sains-jawa-barat',
            'level' => 'provinsi',
            'target_level' => 'slta',
            'description' => 'Khusus Jabar',
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(20),
            'event_end_at' => now()->addDays(25),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        CompetitionEligibility::create([
            'competition_id' => $compJabar->id,
            'allowed_educational_levels' => ['slta'],
            'allowed_grades' => [10, 11, 12],
            'allowed_provinces' => ['Jawa Barat'],
        ]);

        // Student is from DKI Jakarta -> must fail eligibility
        $response = $this->actingAs($this->studentJakartaUser)
            ->getJson("/api/v1/competitions/{$compJabar->id}/eligibility");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_eligible', false);

        $this->assertStringContainsString('tidak termasuk cakupan kompetisi', $response->json('data.failed_criteria.0'));
    }

    public function test_student_ineligible_for_sltp_competition(): void
    {
        $compSltp = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'OSN Tingkat SMP',
            'slug' => 'osn-tingkat-smp',
            'level' => 'nasional',
            'target_level' => 'sltp',
            'description' => 'Khusus SMP',
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(20),
            'event_end_at' => now()->addDays(25),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        CompetitionEligibility::create([
            'competition_id' => $compSltp->id,
            'allowed_educational_levels' => ['sltp'],
            'allowed_grades' => [7, 8, 9],
        ]);

        // Student is SLTA Grade 10 -> must fail
        $response = $this->actingAs($this->studentJakartaUser)
            ->getJson("/api/v1/competitions/{$compSltp->id}/eligibility");

        $response->assertStatus(200)
            ->assertJsonPath('data.is_eligible', false);
    }
}
