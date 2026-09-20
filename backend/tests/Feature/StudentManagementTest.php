<?php

namespace Tests\Feature;

use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class StudentManagementTest extends TestCase
{
    use RefreshDatabase;

    protected School $schoolA;
    protected School $schoolB;
    protected User $adminSchoolA;
    protected User $adminSchoolB;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->schoolA = School::create([
            'npsn' => '10000001',
            'name' => 'SMA A',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'status' => 'verified',
        ]);

        $this->schoolB = School::create([
            'npsn' => '10000002',
            'name' => 'SMA B',
            'province' => 'Jawa Barat',
            'city' => 'Bogor',
            'status' => 'verified',
        ]);

        $this->adminSchoolA = User::create([
            'name' => 'Admin A',
            'email' => 'admin.a@sekolah.id',
            'school_id' => $this->schoolA->id,
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->adminSchoolA->assignRole('school_admin');

        $this->adminSchoolB = User::create([
            'name' => 'Admin B',
            'email' => 'admin.b@sekolah.id',
            'school_id' => $this->schoolB->id,
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->adminSchoolB->assignRole('school_admin');
    }

    public function test_school_admin_can_create_student_manually(): void
    {
        $payload = [
            'nis' => '9001',
            'nisn' => '0089999999',
            'full_name' => 'Andi Wijaya',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => '2009-03-10',
            'birth_place' => 'Jakarta',
            'phone_number' => '08123456789',
        ];

        $response = $this->actingAs($this->adminSchoolA)
            ->postJson('/api/v1/school/students', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.student.nis', '9001')
            ->assertJsonPath('data.initial_credentials.default_password', '1234');

        // Check user created with must_change_password = true
        $this->assertDatabaseHas('users', [
            'name' => 'Andi Wijaya',
            'school_id' => $this->schoolA->id,
            'must_change_password' => true,
        ]);

        // Check student created
        $this->assertDatabaseHas('students', [
            'school_id' => $this->schoolA->id,
            'nis' => '9001',
            'full_name' => 'Andi Wijaya',
        ]);
    }

    public function test_tenant_isolation_admin_a_cannot_access_student_of_school_b(): void
    {
        // Create student in School B
        $userB = User::create([
            'name' => 'Siswa Sekolah B',
            'email' => 'siswa.b@sekolah.id',
            'school_id' => $this->schoolB->id,
            'password' => Hash::make('1234'),
            'status' => 'active',
        ]);
        $userB->assignRole('student');

        $studentB = Student::create([
            'user_id' => $userB->id,
            'school_id' => $this->schoolB->id,
            'nis' => 'B001',
            'full_name' => 'Siswa Sekolah B',
            'grade_level' => 11,
            'class_name' => 'XI IPS 1',
            'gender' => 'P',
            'birth_date' => '2008-04-12',
            'status' => 'active',
        ]);

        // Admin A tries to view Student B -> 403 Forbidden
        $showResponse = $this->actingAs($this->adminSchoolA)
            ->getJson("/api/v1/school/students/{$studentB->id}");
        $showResponse->assertStatus(403);

        // Admin A tries to update Student B -> 403 Forbidden
        $updateResponse = $this->actingAs($this->adminSchoolA)
            ->putJson("/api/v1/school/students/{$studentB->id}", [
                'full_name' => 'Hacked Name',
            ]);
        $updateResponse->assertStatus(403);

        // Admin A tries to delete Student B -> 403 Forbidden
        $deleteResponse = $this->actingAs($this->adminSchoolA)
            ->deleteJson("/api/v1/school/students/{$studentB->id}");
        $deleteResponse->assertStatus(403);

        // Admin A tries to reset password for Student B -> 403 Forbidden
        $resetResponse = $this->actingAs($this->adminSchoolA)
            ->postJson("/api/v1/school/students/{$studentB->id}/reset-password");
        $resetResponse->assertStatus(403);
    }

    public function test_school_admin_can_reset_student_password(): void
    {
        $userA = User::create([
            'name' => 'Siswa Sekolah A',
            'email' => 'siswa.a@sekolah.id',
            'school_id' => $this->schoolA->id,
            'password' => Hash::make('custompassword'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $userA->assignRole('student');

        $studentA = Student::create([
            'user_id' => $userA->id,
            'school_id' => $this->schoolA->id,
            'nis' => 'A001',
            'full_name' => 'Siswa Sekolah A',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => '2009-01-01',
            'status' => 'active',
        ]);

        $response = $this->actingAs($this->adminSchoolA)
            ->postJson("/api/v1/school/students/{$studentA->id}/reset-password");

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        // Check password reset to 1234 and must_change_password = true
        $userA->refresh();
        $this->assertTrue($userA->must_change_password);
        $this->assertTrue(Hash::check('1234', $userA->password));
    }
}
