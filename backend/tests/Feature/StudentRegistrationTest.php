<?php

namespace Tests\Feature;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\CompetitionEligibility;
use App\Models\CompetitionForm;
use App\Models\FormField;
use App\Models\Organizer;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class StudentRegistrationTest extends TestCase
{
    use RefreshDatabase;

    protected School $schoolA;
    protected School $schoolB;
    protected User $studentUser1;
    protected Student $student1;
    protected User $studentUser2;
    protected Student $student2;
    protected User $studentUserB;
    protected Student $studentB;

    protected Organizer $organizer;
    protected CompetitionCategory $category;
    protected Competition $compOsn;
    protected Competition $compTeam;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->schoolA = School::create([
            'npsn' => '11112222',
            'name' => 'SMA Prestasi A',
            'educational_level' => 'slta',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'status' => 'verified',
        ]);

        $this->schoolB = School::create([
            'npsn' => '33334444',
            'name' => 'SMA Prestasi B',
            'educational_level' => 'slta',
            'province' => 'Jawa Barat',
            'city' => 'Bandung',
            'status' => 'verified',
        ]);

        // Student 1 (School A, Grade 10)
        $this->studentUser1 = User::create([
            'name' => 'Siswa Satu',
            'email' => 'siswa1@sekolah.id',
            'school_id' => $this->schoolA->id,
            'password' => Hash::make('password'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $this->studentUser1->assignRole('student');

        $this->student1 = Student::create([
            'user_id' => $this->studentUser1->id,
            'school_id' => $this->schoolA->id,
            'nis' => '1001',
            'full_name' => 'Siswa Satu',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => now()->subYears(16)->format('Y-m-d'),
            'status' => 'active',
        ]);

        // Student 2 (School A, Grade 10)
        $this->studentUser2 = User::create([
            'name' => 'Siswa Dua',
            'email' => 'siswa2@sekolah.id',
            'school_id' => $this->schoolA->id,
            'password' => Hash::make('password'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $this->studentUser2->assignRole('student');

        $this->student2 = Student::create([
            'user_id' => $this->studentUser2->id,
            'school_id' => $this->schoolA->id,
            'nis' => '1002',
            'full_name' => 'Siswa Dua',
            'grade_level' => 10,
            'class_name' => 'X MIPA 2',
            'gender' => 'P',
            'birth_date' => now()->subYears(16)->format('Y-m-d'),
            'status' => 'active',
        ]);

        // Student B (School B, Grade 10)
        $this->studentUserB = User::create([
            'name' => 'Siswa Luar',
            'email' => 'siswaluar@sekolahb.id',
            'school_id' => $this->schoolB->id,
            'password' => Hash::make('password'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $this->studentUserB->assignRole('student');

        $this->studentB = Student::create([
            'user_id' => $this->studentUserB->id,
            'school_id' => $this->schoolB->id,
            'nis' => 'B001',
            'full_name' => 'Siswa Luar',
            'grade_level' => 10,
            'class_name' => 'X-1',
            'gender' => 'L',
            'birth_date' => now()->subYears(16)->format('Y-m-d'),
            'status' => 'active',
        ]);

        $this->organizer = Organizer::create([
            'name' => 'Puspresnas',
            'type' => 'kementerian',
        ]);

        $this->category = CompetitionCategory::create([
            'name' => 'Sains & Robotik',
            'slug' => 'sains-robotik',
        ]);

        // Individual Competition with dynamic form
        $this->compOsn = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'OSN Fisika 2026',
            'slug' => 'osn-fisika-2026',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'OSN Fisika',
            'participation_type' => 'individual',
            'requires_school_approval' => true,
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(20),
            'event_end_at' => now()->addDays(25),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        CompetitionEligibility::create([
            'competition_id' => $this->compOsn->id,
            'allowed_educational_levels' => ['slta'],
            'allowed_grades' => [10, 11],
        ]);

        $form = CompetitionForm::create([
            'competition_id' => $this->compOsn->id,
            'title' => 'Form OSN',
            'version' => 1,
            'is_active' => true,
        ]);

        FormField::create([
            'form_id' => $form->id,
            'label' => 'Bidang Sains',
            'field_key' => 'bidang',
            'field_type' => 'text',
            'is_required' => true,
        ]);

        // Team Competition
        $this->compTeam = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'Lomba Cerdas Cermat Sains',
            'slug' => 'lomba-cerdas-cermat-sains',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'LCC beregu',
            'participation_type' => 'team',
            'min_team_members' => 2,
            'max_team_members' => 3,
            'requires_school_approval' => true,
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(20),
            'event_end_at' => now()->addDays(25),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        CompetitionEligibility::create([
            'competition_id' => $this->compTeam->id,
            'allowed_educational_levels' => ['slta'],
            'allowed_grades' => [10, 11],
        ]);

        $teamForm = CompetitionForm::create([
            'competition_id' => $this->compTeam->id,
            'title' => 'Form LCC',
            'version' => 1,
            'is_active' => true,
        ]);

        FormField::create([
            'form_id' => $teamForm->id,
            'label' => 'Yel-Yel Tim',
            'field_key' => 'yel_yel',
            'field_type' => 'text',
            'is_required' => false,
        ]);
    }

    public function test_student_can_register_individual_competition(): void
    {
        $payload = [
            'competition_id' => $this->compOsn->id,
            'registration_type' => 'individual',
            'answers' => [
                ['field_key' => 'bidang', 'value' => 'Fisika Teori'],
            ],
        ];

        $response = $this->actingAs($this->studentUser1)
            ->postJson('/api/v1/student/registrations', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'pending_school_approval')
            ->assertJsonPath('data.registration_type', 'individual');

        $this->assertDatabaseHas('registrations', [
            'competition_id' => $this->compOsn->id,
            'student_id' => $this->student1->id,
            'school_id' => $this->schoolA->id,
            'status' => 'pending_school_approval',
        ]);

        $this->assertDatabaseHas('registration_answers', [
            'field_key' => 'bidang',
            'answer_value' => 'Fisika Teori',
        ]);
    }

    public function test_student_can_register_team_competition_with_same_school_members(): void
    {
        $payload = [
            'competition_id' => $this->compTeam->id,
            'registration_type' => 'team',
            'team_name' => 'Tim Garuda Prestasi',
            'team_members' => [$this->student1->id, $this->student2->id],
            'answers' => [
                ['field_key' => 'yel_yel', 'value' => 'Maju Terus Pantang Menyerah'],
            ],
        ];

        $response = $this->actingAs($this->studentUser1)
            ->postJson('/api/v1/student/registrations', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.registration_type', 'team');

        $this->assertDatabaseHas('teams', [
            'team_name' => 'Tim Garuda Prestasi',
            'leader_student_id' => $this->student1->id,
        ]);

        $this->assertDatabaseHas('team_members', [
            'student_id' => $this->student2->id,
            'role_in_team' => 'member',
        ]);
    }

    public function test_team_registration_fails_if_member_from_different_school(): void
    {
        $payload = [
            'competition_id' => $this->compTeam->id,
            'registration_type' => 'team',
            'team_name' => 'Tim Campuran Ilegal',
            'team_members' => [$this->student1->id, $this->studentB->id], // studentB is from School B
        ];

        $response = $this->actingAs($this->studentUser1)
            ->postJson('/api/v1/student/registrations', $payload);

        $response->assertStatus(422)
            ->assertJsonPath('success', false);

        $this->assertStringContainsString('bukan berasal dari sekolah yang sama', $response->json('message'));
    }

    public function test_student_can_view_registration_history(): void
    {
        // First register
        $this->actingAs($this->studentUser1)
            ->postJson('/api/v1/student/registrations', [
                'competition_id' => $this->compOsn->id,
                'registration_type' => 'individual',
                'answers' => [['field_key' => 'bidang', 'value' => 'Fisika']],
            ]);

        $response = $this->actingAs($this->studentUser1)
            ->getJson('/api/v1/student/registrations');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data');
    }
}
