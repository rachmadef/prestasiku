<?php

namespace Tests\Feature;

use App\Models\Achievement;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SchoolAchievementVerificationTest extends TestCase
{
    use RefreshDatabase;

    protected School $schoolA;
    protected User $adminA;
    protected Student $studentA;

    protected School $schoolB;
    protected User $adminB;
    protected Student $studentB;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        // School A
        $this->schoolA = School::create([
            'npsn' => '10101010',
            'name' => 'SMA Negeri 1 Prestasi',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'DKI Jakarta',
            'city' => 'Kota Jakarta Selatan',
            'district' => 'Kebayoran Baru',
            'address' => 'Jl. Prestasi No. 1',
            'phone' => '021-1234567',
            'email' => 'info@sman1prestasi.sch.id',
        ]);

        $this->adminA = User::create([
            'name' => 'Admin SMA 1',
            'email' => 'admin1@prestasiku.id',
            'username' => 'admin1',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $this->schoolA->id,
        ]);
        $this->adminA->assignRole('school_admin');

        $studentUserA = User::create([
            'name' => 'Ahmad Siswa A',
            'email' => 'ahmad@siswa.prestasiku.id',
            'username' => 'ahmad_a',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $this->schoolA->id,
        ]);
        $studentUserA->assignRole('student');

        $this->studentA = Student::create([
            'user_id' => $studentUserA->id,
            'school_id' => $this->schoolA->id,
            'nis' => '2026001',
            'nisn' => '0081234567',
            'full_name' => 'Ahmad Siswa A',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => '2009-05-15',
            'birth_place' => 'Jakarta',
            'phone_number' => '081298765432',
            'status' => 'active',
        ]);

        // School B
        $this->schoolB = School::create([
            'npsn' => '20202020',
            'name' => 'SMA Negeri 2 Prestasi',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'Jawa Barat',
            'city' => 'Kota Bandung',
            'district' => 'Coblong',
            'address' => 'Jl. Dago No. 1',
            'phone' => '022-7654321',
            'email' => 'info@sman2prestasi.sch.id',
        ]);

        $this->adminB = User::create([
            'name' => 'Admin SMA 2',
            'email' => 'admin2@prestasiku.id',
            'username' => 'admin2',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $this->schoolB->id,
        ]);
        $this->adminB->assignRole('school_admin');

        $studentUserB = User::create([
            'name' => 'Budi Siswa B',
            'email' => 'budi@siswa.prestasiku.id',
            'username' => 'budi_b',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $this->schoolB->id,
        ]);
        $studentUserB->assignRole('student');

        $this->studentB = Student::create([
            'user_id' => $studentUserB->id,
            'school_id' => $this->schoolB->id,
            'nis' => '2026002',
            'nisn' => '0087654321',
            'full_name' => 'Budi Siswa B',
            'grade_level' => 11,
            'class_name' => 'XI IPA 1',
            'gender' => 'L',
            'birth_date' => '2008-08-20',
            'birth_place' => 'Bandung',
            'phone_number' => '081233344455',
            'status' => 'active',
        ]);
    }

    public function test_school_admin_can_list_school_achievements_with_isolation(): void
    {
        Sanctum::actingAs($this->adminA);

        Achievement::create([
            'student_id' => $this->studentA->id,
            'school_id' => $this->schoolA->id,
            'title' => 'Juara 1 Fisika SMA 1',
            'level' => 'nasional',
            'rank' => 'Juara 1',
            'event_name' => 'OSN 2026',
            'organizer_name' => 'Puspresnas',
            'event_date' => '2026-05-01',
            'status' => 'pending_verification',
        ]);

        Achievement::create([
            'student_id' => $this->studentB->id,
            'school_id' => $this->schoolB->id,
            'title' => 'Juara 2 Biologi SMA 2',
            'level' => 'nasional',
            'rank' => 'Juara 2',
            'event_name' => 'OSN 2026',
            'organizer_name' => 'Puspresnas',
            'event_date' => '2026-05-01',
            'status' => 'pending_verification',
        ]);

        $response = $this->getJson('/api/v1/school/achievements');

        $response->assertStatus(200)
            ->assertJsonPath('data.total', 1)
            ->assertJsonFragment(['title' => 'Juara 1 Fisika SMA 1'])
            ->assertJsonMissing(['title' => 'Juara 2 Biologi SMA 2']);
    }

    public function test_school_admin_cannot_verify_achievement_from_another_school(): void
    {
        Sanctum::actingAs($this->adminA);

        $achievementB = Achievement::create([
            'student_id' => $this->studentB->id,
            'school_id' => $this->schoolB->id,
            'title' => 'Juara Robotika Sekolah B',
            'level' => 'provinsi',
            'rank' => 'Juara 1',
            'event_name' => 'Lomba Robotika',
            'organizer_name' => 'Disdik Jabar',
            'event_date' => '2026-06-01',
            'status' => 'pending_verification',
        ]);

        $response = $this->postJson("/api/v1/school/achievements/{$achievementB->id}/verify", [
            'status' => 'verified',
            'verification_notes' => 'Mencoba verifikasi sekolah lain',
        ]);

        $response->assertStatus(403);
    }

    public function test_school_admin_can_verify_pending_achievement(): void
    {
        Sanctum::actingAs($this->adminA);

        $achievement = Achievement::create([
            'student_id' => $this->studentA->id,
            'school_id' => $this->schoolA->id,
            'title' => 'Juara 1 Kimia Tingkat Provinsi',
            'level' => 'provinsi',
            'rank' => 'Juara 1 (Emas)',
            'event_name' => 'Olimpiade Kimia Provinsi DKI 2026',
            'organizer_name' => 'Disdik DKI',
            'event_date' => '2026-05-15',
            'status' => 'pending_verification',
        ]);

        $response = $this->postJson("/api/v1/school/achievements/{$achievement->id}/verify", [
            'status' => 'verified',
            'verification_notes' => 'Berkas sertifikat telah dicocokkan dengan panitia resmi.',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $achievement->id,
                    'status' => 'verified',
                    'verification_notes' => 'Berkas sertifikat telah dicocokkan dengan panitia resmi.',
                ],
            ]);

        $verifiedById = is_array($response->json('data.verified_by'))
            ? $response->json('data.verified_by.id')
            : $response->json('data.verified_by');
        $this->assertEquals($this->adminA->id, $verifiedById);

        $this->assertNotNull($response->json('data.qr_code_data_uri'));
        $this->assertNotNull($response->json('data.verification_url'));

        $this->assertEquals('verified', $achievement->fresh()->status);
        $this->assertNotNull($achievement->fresh()->verified_at);
    }

    public function test_school_admin_can_reject_achievement(): void
    {
        Sanctum::actingAs($this->adminA);

        $achievement = Achievement::create([
            'student_id' => $this->studentA->id,
            'school_id' => $this->schoolA->id,
            'title' => 'Juara Lomba Tidak Resmi',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara 1',
            'event_name' => 'Lomba Online Anonim',
            'organizer_name' => 'Penyelenggara Bodong',
            'event_date' => '2026-05-15',
            'status' => 'pending_verification',
        ]);

        $response = $this->postJson("/api/v1/school/achievements/{$achievement->id}/verify", [
            'status' => 'rejected',
            'verification_notes' => 'Penyelenggara lomba tidak terakreditasi dan sertifikat meragukan.',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'rejected',
                    'verification_notes' => 'Penyelenggara lomba tidak terakreditasi dan sertifikat meragukan.',
                ],
            ]);

        $this->assertEquals('rejected', $achievement->fresh()->status);
        $this->assertNull($achievement->fresh()->verified_at);
    }

    public function test_school_admin_can_directly_store_verified_achievement(): void
    {
        Sanctum::actingAs($this->adminA);

        $response = $this->postJson('/api/v1/school/achievements', [
            'student_id' => $this->studentA->id,
            'title' => 'Medali Perunggu OSN Astronomi 2026',
            'level' => 'nasional',
            'rank' => 'Juara 3 (Perunggu)',
            'event_name' => 'Olimpiade Sains Nasional 2026',
            'organizer_name' => 'Puspresnas',
            'event_date' => '2026-08-20',
            'status' => 'verified',
            'is_public' => true,
            'document_type' => 'certificate',
            'document_number' => 'SK/PUSPRESNAS/2026/099',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'verified',
                    'verified_by' => $this->adminA->id,
                ],
            ]);

        $ach = Achievement::where('title', 'Medali Perunggu OSN Astronomi 2026')->first();
        $this->assertNotNull($ach);
        $this->assertNotNull($ach->verified_at);
    }

    public function test_school_admin_can_download_document(): void
    {
        Storage::fake('local');
        Sanctum::actingAs($this->adminA);

        $file = UploadedFile::fake()->create('sertifikat_resmi.pdf', 500, 'application/pdf');
        $storedPath = $file->store('achievements/test', 'local');

        $achievement = Achievement::create([
            'student_id' => $this->studentA->id,
            'school_id' => $this->schoolA->id,
            'title' => 'Juara 1 Pidato Bahasa Indonesia',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara 1',
            'event_name' => 'Festival Bahasa 2026',
            'organizer_name' => 'Disdik',
            'event_date' => '2026-04-10',
            'status' => 'verified',
        ]);

        $doc = $achievement->documents()->create([
            'document_type' => 'certificate',
            'document_number' => 'CERT-001',
            'file_path' => $storedPath,
            'file_name' => 'sertifikat_resmi.pdf',
            'file_size' => 500,
            'file_mime' => 'application/pdf',
        ]);

        $response = $this->get("/api/v1/school/achievements/{$achievement->id}/documents/{$doc->id}");

        $response->assertStatus(200);
        $response->assertHeader('content-disposition');
    }
}
