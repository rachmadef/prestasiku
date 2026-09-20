<?php

namespace Tests\Feature;

use App\Models\SchoolRegistration;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class SchoolRegistrationApprovalTest extends TestCase
{
    use RefreshDatabase;

    protected User $superAdmin;
    protected User $schoolAdmin;

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
            'email' => 'admin@sekolah.id',
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->schoolAdmin->assignRole('school_admin');
    }

    public function test_super_admin_can_list_school_registrations(): void
    {
        SchoolRegistration::create([
            'npsn' => '11223344',
            'school_name' => 'SMA Prestasi Unggul',
            'educational_level' => 'slta',
            'province' => 'Jawa Barat',
            'city' => 'Bandung',
            'pic_name' => 'Pak Joko',
            'pic_email' => 'joko@smanunggul.sch.id',
            'pic_phone' => '0812345678',
            'pic_position' => 'Kepala Sekolah',
            'status' => 'pending',
        ]);

        $response = $this->actingAs($this->superAdmin)
            ->getJson('/api/v1/admin/school-registrations');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data');
    }

    public function test_super_admin_can_approve_school_registration(): void
    {
        $reg = SchoolRegistration::create([
            'npsn' => '55667788',
            'school_name' => 'SMA Bintang Gemilang',
            'educational_level' => 'slta',
            'province' => 'Jawa Tengah',
            'city' => 'Semarang',
            'pic_name' => 'Dra. Endang',
            'pic_email' => 'endang@smabintang.sch.id',
            'pic_phone' => '0813456789',
            'pic_position' => 'Kepala Sekolah',
            'status' => 'pending',
        ]);

        $response = $this->actingAs($this->superAdmin)
            ->postJson("/api/v1/admin/school-registrations/{$reg->id}/review", [
                'action' => 'approve',
                'review_notes' => 'Dokumen sah dan diverifikasi.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.registration.status', 'approved')
            ->assertJsonPath('data.school.npsn', '55667788');

        // Check school exists
        $this->assertDatabaseHas('schools', [
            'npsn' => '55667788',
            'status' => 'verified',
            'verified_by' => $this->superAdmin->id,
        ]);

        // Check school admin user created
        $this->assertDatabaseHas('users', [
            'email' => 'endang@smabintang.sch.id',
            'username' => 'admin_55667788',
            'status' => 'active',
        ]);
    }

    public function test_super_admin_can_reject_school_registration(): void
    {
        $reg = SchoolRegistration::create([
            'npsn' => '99887766',
            'school_name' => 'SMA Tidak Lengkap',
            'educational_level' => 'slta',
            'province' => 'Bali',
            'city' => 'Denpasar',
            'pic_name' => 'Pak Made',
            'pic_email' => 'made@smatidaklengkap.sch.id',
            'pic_phone' => '0815678901',
            'pic_position' => 'Staff',
            'status' => 'pending',
        ]);

        $response = $this->actingAs($this->superAdmin)
            ->postJson("/api/v1/admin/school-registrations/{$reg->id}/review", [
                'action' => 'reject',
                'review_notes' => 'SK Penugasan tidak dilampirkan.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'rejected')
            ->assertJsonPath('data.review_notes', 'SK Penugasan tidak dilampirkan.');

        $this->assertDatabaseMissing('schools', [
            'npsn' => '99887766',
        ]);
    }

    public function test_non_super_admin_forbidden_from_admin_review(): void
    {
        $response = $this->actingAs($this->schoolAdmin)
            ->getJson('/api/v1/admin/school-registrations');

        $response->assertStatus(403);
    }
}
