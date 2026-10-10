<?php

namespace Tests\Feature;

use App\Models\School;
use App\Models\SchoolSigner;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SchoolSignerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);
    }

    public function test_school_admin_can_list_and_create_signers(): void
    {
        $school = School::create([
            'npsn' => '10203040',
            'name' => 'SMA Negeri 1 Prestasi',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'Jawa Timur',
            'city' => 'Jombang',
            'district' => 'Jombang',
            'address' => 'Jl. Merdeka No. 1',
        ]);

        $schoolAdmin = User::create([
            'name' => 'Admin Sekolah',
            'email' => 'admin@sman1prestasi.sch.id',
            'username' => 'admin_sman1',
            'password' => bcrypt('password123'),
            'school_id' => $school->id,
            'must_change_password' => false,
            'password_changed_at' => now(),
            'status' => 'active',
        ]);
        $schoolAdmin->assignRole('school_admin');

        // Create Signer
        $response = $this->actingAs($schoolAdmin)
            ->postJson('/api/v1/school/signers', [
                'name' => 'Drs. H. Abdul Haris, M.Pd.',
                'nip' => '197508122000031002',
                'position_title' => 'Waka Kesiswaan',
                'role_type' => 'waka_kesiswaan',
                'phone' => '08123456789',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Drs. H. Abdul Haris, M.Pd.')
            ->assertJsonPath('data.role_type', 'waka_kesiswaan');

        $this->assertDatabaseHas('school_signers', [
            'school_id' => $school->id,
            'name' => 'Drs. H. Abdul Haris, M.Pd.',
            'role_type' => 'waka_kesiswaan',
        ]);

        // List Signers
        $listResponse = $this->actingAs($schoolAdmin)
            ->getJson('/api/v1/school/signers');

        $listResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data');
    }

    public function test_public_can_verify_signer_qr_code_token(): void
    {
        $school = School::create([
            'npsn' => '10203040',
            'name' => 'SMA Negeri 1 Prestasi',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'Jawa Timur',
            'city' => 'Jombang',
            'district' => 'Jombang',
            'address' => 'Jl. Merdeka No. 1',
        ]);

        $signer = SchoolSigner::create([
            'school_id' => $school->id,
            'name' => 'Budi Santoso, S.Pd.',
            'nip' => '198001012010011005',
            'position_title' => 'Guru PJ Lomba & Olimpiade',
            'role_type' => 'pj_lomba',
            'is_active' => true,
            'signature_token' => 'test-signer-token-12345',
        ]);

        $response = $this->getJson('/api/v1/signers/verify/test-signer-token-12345');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('is_valid', true)
            ->assertJsonPath('data.name', 'Budi Santoso, S.Pd.')
            ->assertJsonPath('data.position_title', 'Guru PJ Lomba & Olimpiade')
            ->assertJsonPath('data.school.name', 'SMA Negeri 1 Prestasi');
    }
}
