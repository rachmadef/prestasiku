<?php

namespace Tests\Feature;

use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);
    }

    public function test_super_admin_can_login_with_email(): void
    {
        $admin = User::create([
            'name' => 'Super Admin Test',
            'email' => 'admin@test.id',
            'username' => 'superadmintest',
            'password' => Hash::make('secret123'),
            'status' => 'active',
        ]);
        $admin->assignRole('super_admin');

        $response = $this->postJson('/api/v1/auth/login', [
            'identifier' => 'admin@test.id',
            'password' => 'secret123',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'token',
                    'user' => ['id', 'name', 'email', 'roles', 'must_change_password'],
                ],
            ]);

        $this->assertDatabaseHas('login_events', [
            'user_id' => $admin->id,
            'identifier' => 'admin@test.id',
            'status' => 'success',
        ]);
    }

    public function test_student_can_login_with_nis_and_requires_password_change(): void
    {
        $school = School::create([
            'npsn' => '12345678',
            'name' => 'SMA Test',
            'province' => 'Jawa Barat',
            'city' => 'Bandung',
            'status' => 'verified',
        ]);

        $studentUser = User::create([
            'name' => 'Siswa Test',
            'email' => 'siswa@test.id',
            'username' => '12345678_1001',
            'school_id' => $school->id,
            'password' => Hash::make('1234'),
            'must_change_password' => true,
            'status' => 'active',
        ]);
        $studentUser->assignRole('student');

        $student = Student::create([
            'user_id' => $studentUser->id,
            'school_id' => $school->id,
            'nis' => '1001',
            'full_name' => 'Siswa Test',
            'grade_level' => 10,
            'class_name' => 'X-1',
            'gender' => 'L',
            'birth_date' => '2009-01-01',
            'status' => 'active',
        ]);

        // Login using NIS '1001'
        $response = $this->postJson('/api/v1/auth/login', [
            'identifier' => '1001',
            'password' => '1234',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.must_change_password', true)
            ->assertJsonPath('data.user.student.nis', '1001');

        $token = $response->json('data.token');

        // Accessing regular protected feature is blocked by EnsurePasswordIsChanged
        $dashboardResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/user/dashboard-summary');

        $dashboardResponse->assertStatus(403)
            ->assertJsonPath('code', 'MUST_CHANGE_PASSWORD');

        // Calling /api/v1/auth/me is allowed
        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200)
            ->assertJsonPath('data.must_change_password', true);

        // Calling /api/v1/auth/change-password
        $changePasswordResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/auth/change-password', [
                'current_password' => '1234',
                'password' => 'newpassword123',
                'password_confirmation' => 'newpassword123',
            ]);

        $changePasswordResponse->assertStatus(200)
            ->assertJsonPath('success', true);

        // Verify must_change_password is now false in database
        $this->assertDatabaseHas('users', [
            'id' => $studentUser->id,
            'must_change_password' => false,
        ]);

        // Accessing regular protected feature is now permitted!
        $dashboardAllowed = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/user/dashboard-summary');

        $dashboardAllowed->assertStatus(200)
            ->assertJsonPath('success', true);
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'identifier' => 'nonexistent@prestasiku.id',
            'password' => 'wrongpass',
        ]);

        $response->assertStatus(401)
            ->assertJsonPath('success', false);

        $this->assertDatabaseHas('login_events', [
            'identifier' => 'nonexistent@prestasiku.id',
            'status' => 'failed',
        ]);
    }
}
