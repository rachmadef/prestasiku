<?php

namespace Tests\Feature;

use App\Models\KbmDispensation;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Tests\TestCase;

class SecurityHardeningTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);
        RateLimiter::clear('login:target@sekolah.id|127.0.0.1');
    }

    /**
     * Test HTTP security headers are present on API responses.
     */
    public function test_http_security_headers_are_attached(): void
    {
        $response = $this->getJson('/api/v1/competitions');

        $response->assertHeader('X-Frame-Options', 'SAMEORIGIN')
            ->assertHeader('X-Content-Type-Options', 'nosniff')
            ->assertHeader('X-XSS-Protection', '1; mode=block')
            ->assertHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
            ->assertHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    }

    /**
     * Test brute force login protection kicks in after 5 failed attempts.
     */
    public function test_brute_force_login_rate_limiting(): void
    {
        $user = User::create([
            'name' => 'Target User',
            'email' => 'target@sekolah.id',
            'password' => Hash::make('correct_password'),
            'status' => 'active',
        ]);
        $user->assignRole('student');

        // 5 consecutive failed attempts
        for ($i = 1; $i <= 5; $i++) {
            $res = $this->postJson('/api/v1/auth/login', [
                'identifier' => 'target@sekolah.id',
                'password' => 'wrong_password_' . $i,
            ]);
            $res->assertStatus(401);
        }

        // 6th attempt should be blocked with 429 Too Many Requests
        $blocked = $this->postJson('/api/v1/auth/login', [
            'identifier' => 'target@sekolah.id',
            'password' => 'wrong_password_6',
        ]);

        $blocked->assertStatus(429)
            ->assertJsonPath('success', false)
            ->assertHeader('Retry-After');
    }

    /**
     * Test input sanitization middleware automatically strips dangerous HTML tags (Anti-XSS).
     */
    public function test_xss_input_sanitization(): void
    {
        $school = School::create([
            'npsn' => '11223344',
            'name' => 'SMA XSS Shield',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'status' => 'verified',
        ]);

        $studentUser = User::create([
            'name' => 'Siswa Test',
            'email' => 'siswa.xss@test.id',
            'school_id' => $school->id,
            'password' => Hash::make('password123'),
            'status' => 'active',
            'must_change_password' => false,
        ]);
        $studentUser->assignRole('student');

        $student = Student::create([
            'user_id' => $studentUser->id,
            'school_id' => $school->id,
            'nis' => '889900',
            'full_name' => 'Siswa XSS Test',
            'grade_level' => 10,
            'class_name' => 'X-1',
            'gender' => 'L',
            'birth_date' => '2008-01-01',
            'status' => 'active',
        ]);

        // Submit dispensation with injected <script> and <iframe> tags
        $response = $this->actingAs($studentUser, 'sanctum')->postJson('/api/v1/student/dispensations', [
            'competition_name' => 'OSN <script>alert("hacked")</script>',
            'dispensation_type' => 'persiapan_latihan',
            'purpose' => 'Latihan intensif <iframe src="evil.com"></iframe>.',
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDays(2)->toDateString(),
            'supervisor_name' => 'Guru Pembimbing <b onmouseover=alert(1)>Test</b>',
        ]);

        $response->assertStatus(201);

        // Verify the database does not contain <script> or <iframe> tags
        $this->assertDatabaseMissing('kbm_dispensations', [
            'competition_name' => 'OSN <script>alert("hacked")</script>',
        ]);

        $this->assertDatabaseHas('kbm_dispensations', [
            'competition_name' => 'OSN alert("hacked")',
            'purpose' => 'Latihan intensif .',
            'supervisor_name' => 'Guru Pembimbing Test',
        ]);
    }

    /**
     * Test multi-tenant isolation: School A cannot access or review School B's dispensation.
     */
    public function test_multi_tenant_isolation_anti_idor(): void
    {
        // School A
        $schoolA = School::create([
            'npsn' => '11111111',
            'name' => 'SMA Nusa Bangsa A',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'status' => 'verified',
        ]);
        $adminA = User::create([
            'name' => 'Admin A',
            'email' => 'admin.a@sekolah.id',
            'school_id' => $schoolA->id,
            'password' => Hash::make('password123'),
            'status' => 'active',
            'must_change_password' => false,
        ]);
        $adminA->assignRole('school_admin');

        // School B
        $schoolB = School::create([
            'npsn' => '22222222',
            'name' => 'SMA Nusa Bangsa B',
            'province' => 'Jawa Barat',
            'city' => 'Bandung',
            'status' => 'verified',
        ]);
        $adminB = User::create([
            'name' => 'Admin B',
            'email' => 'admin.b@sekolah.id',
            'school_id' => $schoolB->id,
            'password' => Hash::make('password123'),
            'status' => 'active',
            'must_change_password' => false,
        ]);
        $adminB->assignRole('school_admin');

        // Create dispensation belonging to School B
        $dispensationB = KbmDispensation::create([
            'school_id' => $schoolB->id,
            'competition_name' => 'Lomba Rahasia B',
            'dispensation_type' => 'pelaksanaan_lomba',
            'purpose' => 'Kegiatan Internal B',
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDay()->toDateString(),
            'status' => 'pending',
            'requested_by' => $adminB->id,
        ]);

        // Admin A attempts to access School B's dispensation -> must fail with 404 (Not Found in tenant scope)
        $viewAttempt = $this->actingAs($adminA, 'sanctum')
            ->getJson("/api/v1/school/dispensations/{$dispensationB->id}");
        $viewAttempt->assertStatus(404);

        // Admin A attempts to review / approve School B's dispensation -> must fail with 404
        $reviewAttempt = $this->actingAs($adminA, 'sanctum')
            ->postJson("/api/v1/school/dispensations/{$dispensationB->id}/review", [
                'action' => 'approve',
            ]);
        $reviewAttempt->assertStatus(404);
    }

    /**
     * Test token revocation on password change.
     */
    public function test_token_revocation_on_password_change(): void
    {
        $user = User::create([
            'name' => 'User Multi-Session',
            'email' => 'multi@test.id',
            'password' => Hash::make('old_secret_123'),
            'status' => 'active',
            'must_change_password' => false,
        ]);
        $user->assignRole('student');

        // Create 2 session tokens (representing 2 devices)
        $tokenSession1 = $user->createToken('device-phone')->plainTextToken;
        $tokenSession2 = $user->createToken('device-laptop')->plainTextToken;

        $this->assertCount(2, $user->tokens);

        // User changes password using Device 1 token
        $response = $this->withToken($tokenSession1)->postJson('/api/v1/auth/change-password', [
            'current_password' => 'old_secret_123',
            'password' => 'new_secret_456',
            'password_confirmation' => 'new_secret_456',
        ]);

        $response->assertStatus(200);

        // Device 2's token must be revoked / deleted from database
        $user->refresh();
        $this->assertCount(1, $user->tokens);
        $this->assertEquals('device-phone', $user->tokens->first()->name);

        // Clear in-memory guard cache so Sanctum resolves fresh token
        app('auth')->forgetGuards();

        // Device 2 should no longer be able to access protected endpoints
        $unauthorized = $this->withToken($tokenSession2)->getJson('/api/v1/auth/me');
        $unauthorized->assertStatus(401);
    }
}
