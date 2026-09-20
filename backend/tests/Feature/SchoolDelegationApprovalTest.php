<?php

namespace Tests\Feature;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\CompetitionEligibility;
use App\Models\CompetitionForm;
use App\Models\Organizer;
use App\Models\Registration;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class SchoolDelegationApprovalTest extends TestCase
{
    use RefreshDatabase;

    protected School $schoolA;
    protected School $schoolB;
    protected User $adminSchoolA;
    protected User $adminSchoolB;
    protected Student $studentA;

    protected Organizer $organizer;
    protected CompetitionCategory $category;
    protected Competition $competition;
    protected CompetitionForm $form;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->schoolA = School::create([
            'npsn' => '10001000',
            'name' => 'SMAN 1 Jaya',
            'educational_level' => 'slta',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'status' => 'verified',
        ]);

        $this->schoolB = School::create([
            'npsn' => '20002000',
            'name' => 'SMAN 2 Maju',
            'educational_level' => 'slta',
            'province' => 'Jawa Barat',
            'city' => 'Bogor',
            'status' => 'verified',
        ]);

        $this->adminSchoolA = User::create([
            'name' => 'Admin SMAN 1',
            'email' => 'admin.sman1@sekolah.id',
            'school_id' => $this->schoolA->id,
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->adminSchoolA->assignRole('school_admin');

        $this->adminSchoolB = User::create([
            'name' => 'Admin SMAN 2',
            'email' => 'admin.sman2@sekolah.id',
            'school_id' => $this->schoolB->id,
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->adminSchoolB->assignRole('school_admin');

        $userStudentA = User::create([
            'name' => 'Bintang Siswa',
            'email' => 'bintang@sekolah.id',
            'school_id' => $this->schoolA->id,
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $userStudentA->assignRole('student');

        $this->studentA = Student::create([
            'user_id' => $userStudentA->id,
            'school_id' => $this->schoolA->id,
            'nis' => 'BIN01',
            'full_name' => 'Bintang Siswa',
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
            'name' => 'Sains',
            'slug' => 'sains',
        ]);

        $this->competition = Competition::create([
            'organizer_id' => $this->organizer->id,
            'category_id' => $this->category->id,
            'title' => 'OSN Biologi 2026',
            'slug' => 'osn-biologi-2026',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'OSN',
            'requires_school_approval' => true,
            'registration_open_at' => now()->subDays(2),
            'registration_deadline' => now()->addDays(10),
            'event_start_at' => now()->addDays(20),
            'event_end_at' => now()->addDays(25),
            'verification_status' => 'published',
            'visibility' => 'public',
        ]);

        CompetitionEligibility::create([
            'competition_id' => $this->competition->id,
            'allowed_educational_levels' => ['slta'],
            'allowed_grades' => [10, 11],
        ]);

        $this->form = CompetitionForm::create([
            'competition_id' => $this->competition->id,
            'title' => 'Formulir OSN Biologi',
            'version' => 1,
            'is_active' => true,
        ]);
    }

    public function test_school_admin_can_view_and_approve_registration_with_assignment_letter(): void
    {
        $reg = Registration::create([
            'competition_id' => $this->competition->id,
            'form_version_id' => $this->form->id,
            'school_id' => $this->schoolA->id,
            'student_id' => $this->studentA->id,
            'registration_type' => 'individual',
            'registered_by' => $this->studentA->user_id,
            'status' => 'pending_school_approval',
            'school_approval_status' => 'pending',
        ]);

        $response = $this->actingAs($this->adminSchoolA)
            ->postJson("/api/v1/school/registrations/{$reg->id}/review", [
                'action' => 'approve',
                'assignment_letter_number' => '421.3/089/SMAN1/2026',
                'notes' => 'Disetujui untuk mewakili sekolah.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'approved_by_school')
            ->assertJsonPath('data.school_approval_status', 'approved');

        $this->assertDatabaseHas('registrations', [
            'id' => $reg->id,
            'status' => 'approved_by_school',
            'assignment_letter_number' => '421.3/089/SMAN1/2026',
            'school_approved_by' => $this->adminSchoolA->id,
        ]);
    }

    public function test_school_admin_can_reject_registration(): void
    {
        $reg = Registration::create([
            'competition_id' => $this->competition->id,
            'form_version_id' => $this->form->id,
            'school_id' => $this->schoolA->id,
            'student_id' => $this->studentA->id,
            'registration_type' => 'individual',
            'registered_by' => $this->studentA->user_id,
            'status' => 'pending_school_approval',
            'school_approval_status' => 'pending',
        ]);

        $response = $this->actingAs($this->adminSchoolA)
            ->postJson("/api/v1/school/registrations/{$reg->id}/review", [
                'action' => 'reject',
                'notes' => 'Kuota perwakilan sekolah untuk cabang ini sudah penuh.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'rejected_by_school');

        $this->assertDatabaseHas('registrations', [
            'id' => $reg->id,
            'status' => 'rejected_by_school',
            'school_notes' => 'Kuota perwakilan sekolah untuk cabang ini sudah penuh.',
        ]);
    }

    public function test_tenant_isolation_admin_b_cannot_review_registration_of_school_a(): void
    {
        $regA = Registration::create([
            'competition_id' => $this->competition->id,
            'form_version_id' => $this->form->id,
            'school_id' => $this->schoolA->id,
            'student_id' => $this->studentA->id,
            'registration_type' => 'individual',
            'registered_by' => $this->studentA->user_id,
            'status' => 'pending_school_approval',
            'school_approval_status' => 'pending',
        ]);

        // Admin B tries to review Registration A -> 403 Forbidden
        $response = $this->actingAs($this->adminSchoolB)
            ->postJson("/api/v1/school/registrations/{$regA->id}/review", [
                'action' => 'approve',
            ]);

        $response->assertStatus(403);
    }

    public function test_school_admin_can_register_direct_delegation(): void
    {
        $payload = [
            'competition_id' => $this->competition->id,
            'registration_type' => 'individual',
            'student_id' => $this->studentA->id,
            'assignment_letter_number' => 'ST/001/SMAN1/2026',
        ];

        $response = $this->actingAs($this->adminSchoolA)
            ->postJson('/api/v1/school/registrations/direct', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'approved_by_school')
            ->assertJsonPath('data.school_approval_status', 'approved');

        $this->assertDatabaseHas('registrations', [
            'competition_id' => $this->competition->id,
            'school_id' => $this->schoolA->id,
            'student_id' => $this->studentA->id,
            'status' => 'approved_by_school',
            'assignment_letter_number' => 'ST/001/SMAN1/2026',
        ]);
    }
}
