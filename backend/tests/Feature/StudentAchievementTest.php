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

class StudentAchievementTest extends TestCase
{
    use RefreshDatabase;

    protected School $school;
    protected User $studentUser;
    protected Student $student;

    protected User $otherStudentUser;
    protected Student $otherStudent;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->school = School::create([
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

        $this->studentUser = User::create([
            'name' => 'Ahmad Bintang Pratama',
            'email' => 'ahmad@siswa.prestasiku.id',
            'username' => 'ahmad123',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $this->school->id,
        ]);
        $this->studentUser->assignRole('student');

        $this->student = Student::create([
            'user_id' => $this->studentUser->id,
            'school_id' => $this->school->id,
            'nis' => '2026001',
            'nisn' => '0081234567',
            'full_name' => 'Ahmad Bintang Pratama',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => '2009-05-15',
            'birth_place' => 'Jakarta',
            'phone_number' => '081298765432',
            'status' => 'active',
        ]);

        // Second student in another school
        $otherSchool = School::create([
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

        $this->otherStudentUser = User::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@siswa.prestasiku.id',
            'username' => 'budi123',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $otherSchool->id,
        ]);
        $this->otherStudentUser->assignRole('student');

        $this->otherStudent = Student::create([
            'user_id' => $this->otherStudentUser->id,
            'school_id' => $otherSchool->id,
            'nis' => '2026002',
            'nisn' => '0087654321',
            'full_name' => 'Budi Santoso',
            'grade_level' => 11,
            'class_name' => 'XI IPA 2',
            'gender' => 'L',
            'birth_date' => '2008-08-20',
            'birth_place' => 'Bandung',
            'phone_number' => '081233344455',
            'status' => 'active',
        ]);
    }

    public function test_student_can_list_their_own_achievements(): void
    {
        Sanctum::actingAs($this->studentUser);

        Achievement::create([
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Juara 1 Debat Bahasa Inggris',
            'level' => 'provinsi',
            'rank' => 'Juara 1',
            'event_name' => 'Provincial English Debate 2026',
            'organizer_name' => 'Disdik DKI',
            'event_date' => '2026-03-01',
            'status' => 'verified',
            'is_public' => false,
        ]);

        // Achievement belonging to another student
        Achievement::create([
            'student_id' => $this->otherStudent->id,
            'school_id' => $this->otherStudent->school_id,
            'title' => 'Juara 3 Olimpiade Kimia',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara 3',
            'event_name' => 'Olimpiade Kimia Bandung',
            'organizer_name' => 'ITB',
            'event_date' => '2026-04-01',
            'status' => 'verified',
            'is_public' => false,
        ]);

        $response = $this->getJson('/api/v1/student/achievements');

        $response->assertStatus(200)
            ->assertJsonPath('data.total', 1)
            ->assertJsonFragment(['title' => 'Juara 1 Debat Bahasa Inggris'])
            ->assertJsonMissing(['title' => 'Juara 3 Olimpiade Kimia']);
    }

    public function test_student_can_submit_achievement_with_file(): void
    {
        Storage::fake('local');
        Sanctum::actingAs($this->studentUser);

        $file = UploadedFile::fake()->create('sertifikat.pdf', 1024, 'application/pdf');

        $response = $this->postJson('/api/v1/student/achievements', [
            'title' => 'Juara 1 Renang Gaya Bebas 100m',
            'level' => 'provinsi',
            'rank' => 'Juara 1 (Emas)',
            'event_name' => 'Kejurda Renang DKI 2026',
            'organizer_name' => 'PRSI DKI Jakarta',
            'event_date' => '2026-04-15',
            'document_type' => 'certificate',
            'document_number' => 'PRSI/DKI/2026/045',
            'certificate_file' => $file,
            'is_public' => true,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'title' => 'Juara 1 Renang Gaya Bebas 100m',
                    'status' => 'pending_verification',
                    'is_public' => true,
                ],
            ]);

        $achievement = Achievement::where('title', 'Juara 1 Renang Gaya Bebas 100m')->first();
        $this->assertNotNull($achievement);
        $this->assertStringStartsWith('PKU-ACH-', $achievement->public_id);
        $this->assertEquals($this->student->id, $achievement->student_id);

        $this->assertCount(1, $achievement->documents);
        $doc = $achievement->documents->first();
        $this->assertEquals('certificate', $doc->document_type);
        Storage::disk('local')->assertExists($doc->file_path);
    }

    public function test_student_can_toggle_public_visibility(): void
    {
        Sanctum::actingAs($this->studentUser);

        $achievement = Achievement::create([
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Juara 2 Lomba Puisi',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara 2',
            'event_name' => 'Festival Puisi Pelajar',
            'organizer_name' => 'Disdik',
            'event_date' => '2026-03-10',
            'status' => 'verified',
            'is_public' => false,
        ]);

        $response = $this->patchJson("/api/v1/student/achievements/{$achievement->id}/toggle-public");

        $response->assertStatus(200)
            ->assertJsonPath('data.is_public', true);

        $this->assertTrue($achievement->fresh()->is_public);
    }

    public function test_student_cannot_view_or_modify_other_students_achievement(): void
    {
        Sanctum::actingAs($this->studentUser);

        $otherAchievement = Achievement::create([
            'student_id' => $this->otherStudent->id,
            'school_id' => $this->otherStudent->school_id,
            'title' => 'Juara 1 Robotika Nasional',
            'level' => 'nasional',
            'rank' => 'Juara 1',
            'event_name' => 'Kontes Robotika',
            'organizer_name' => 'Puspresnas',
            'event_date' => '2026-05-01',
            'status' => 'verified',
            'is_public' => false,
        ]);

        // Attempt view
        $viewResponse = $this->getJson("/api/v1/student/achievements/{$otherAchievement->id}");
        $viewResponse->assertStatus(403);

        // Attempt toggle-public
        $toggleResponse = $this->patchJson("/api/v1/student/achievements/{$otherAchievement->id}/toggle-public");
        $toggleResponse->assertStatus(403);
    }

    public function test_student_can_delete_pending_achievement_but_not_verified(): void
    {
        Sanctum::actingAs($this->studentUser);

        $pendingAch = Achievement::create([
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Prestasi Yang Salah Kirim',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara 3',
            'event_name' => 'Lomba Test',
            'organizer_name' => 'Panitia',
            'event_date' => '2026-01-01',
            'status' => 'pending_verification',
        ]);

        $delPendingResponse = $this->deleteJson("/api/v1/student/achievements/{$pendingAch->id}");
        $delPendingResponse->assertStatus(200);

        $verifiedAch = Achievement::create([
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Prestasi Terverifikasi Resmi',
            'level' => 'nasional',
            'rank' => 'Juara 1',
            'event_name' => 'Lomba Resmi',
            'organizer_name' => 'Puspresnas',
            'event_date' => '2026-02-01',
            'status' => 'verified',
        ]);

        $delVerifiedResponse = $this->deleteJson("/api/v1/student/achievements/{$verifiedAch->id}");
        $delVerifiedResponse->assertStatus(403);
    }
}
