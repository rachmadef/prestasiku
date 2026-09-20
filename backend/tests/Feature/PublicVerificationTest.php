<?php

namespace Tests\Feature;

use App\Models\Achievement;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PublicVerificationTest extends TestCase
{
    use RefreshDatabase;

    protected School $school;
    protected Student $student;
    protected User $studentUser;

    protected function setUp(): void
    {
        parent::setUp();

        $this->school = School::create([
            'npsn' => '10101010',
            'name' => 'SMA Negeri 1 Prestasi',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'DKI Jakarta',
            'city' => 'Kota Jakarta Selatan',
            'district' => 'Kebayoran Baru',
            'address' => 'Jl. Prestasi No. 1',
            'postal_code' => '12110',
            'phone' => '021-1234567',
            'email' => 'info@sman1prestasi.sch.id',
        ]);

        $this->studentUser = User::create([
            'name' => 'Ahmad Bintang Pratama',
            'email' => 'ahmad@example.com',
            'username' => 'ahmad123',
            'password' => bcrypt('password'),
            'status' => 'active',
            'must_change_password' => false,
            'school_id' => $this->school->id,
        ]);

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
    }

    public function test_can_verify_achievement_with_masked_name_by_default(): void
    {
        $achievement = Achievement::create([
            'public_id' => 'PKU-ACH-2026-TEST0001',
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Juara 1 Bidang Fisika Terapan',
            'level' => 'nasional',
            'rank' => 'Juara 1 (Emas)',
            'event_name' => 'Olimpiade Sains Nasional',
            'organizer_name' => 'Puspresnas',
            'event_date' => '2026-05-10',
            'status' => 'verified',
            'verified_at' => now(),
            'is_public' => false, // Privacy by default
        ]);

        $response = $this->getJson("/api/v1/verify/{$achievement->public_id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'public_id' => 'PKU-ACH-2026-TEST0001',
                    'student_name' => 'Ah*** Bi*** Pr***',
                    'is_name_masked' => true,
                    'school' => [
                        'name' => 'SMA Negeri 1 Prestasi',
                    ],
                    'achievement' => [
                        'title' => 'Juara 1 Bidang Fisika Terapan',
                        'level' => 'nasional',
                        'rank' => 'Juara 1 (Emas)',
                    ],
                    'verification' => [
                        'status' => 'VALID_OFFICIAL_ACHIEVEMENT',
                    ],
                ],
            ]);

        // CRITICAL: Ensure sensitive PII is NEVER leaked in public verification
        $response->assertJsonMissing(['nis' => '2026001']);
        $response->assertJsonMissing(['nisn' => '0081234567']);
        $response->assertJsonMissing(['phone_number' => '081298765432']);
        $response->assertJsonMissing(['birth_date' => '2009-05-15']);
    }

    public function test_can_verify_achievement_with_full_name_when_is_public_is_true(): void
    {
        $achievement = Achievement::create([
            'public_id' => 'PKU-ACH-2026-TEST0002',
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Juara 2 Lomba Karya Tulis Ilmiah',
            'level' => 'provinsi',
            'rank' => 'Juara 2',
            'event_name' => 'LKTI DKI 2026',
            'organizer_name' => 'Disdik DKI',
            'event_date' => '2026-06-15',
            'status' => 'verified',
            'verified_at' => now(),
            'is_public' => true, // Opt-in public display
        ]);

        $response = $this->getJson("/api/v1/verify/{$achievement->public_id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'public_id' => 'PKU-ACH-2026-TEST0002',
                    'student_name' => 'Ahmad Bintang Pratama',
                    'is_name_masked' => false,
                ],
            ]);
    }

    public function test_unverified_achievement_returns_404_on_public_endpoint(): void
    {
        $achievement = Achievement::create([
            'public_id' => 'PKU-ACH-2026-TESTPENDING',
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Prestasi Belum Terverifikasi',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara Harapan',
            'event_name' => 'Lomba Lokal',
            'organizer_name' => 'Panitia Lokal',
            'event_date' => '2026-07-01',
            'status' => 'pending_verification',
            'is_public' => false,
        ]);

        $response = $this->getJson("/api/v1/verify/{$achievement->public_id}");

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_non_existent_public_id_returns_404(): void
    {
        $response = $this->getJson('/api/v1/verify/PKU-ACH-NONEXISTENT');

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_public_qr_code_endpoint_returns_svg(): void
    {
        $achievement = Achievement::create([
            'public_id' => 'PKU-ACH-2026-TESTQR',
            'student_id' => $this->student->id,
            'school_id' => $this->school->id,
            'title' => 'Juara 1 Catur Cepat',
            'level' => 'kota_kabupaten',
            'rank' => 'Juara 1',
            'event_name' => 'Kejurcab Catur',
            'organizer_name' => 'Percasi',
            'event_date' => '2026-05-20',
            'status' => 'verified',
            'verified_at' => now(),
            'is_public' => false,
        ]);

        $response = $this->get("/api/v1/verify/{$achievement->public_id}/qr");

        $response->assertStatus(200);
        $response->assertHeader('Content-Type', 'image/svg+xml');
        $this->assertStringContainsString('<svg', $response->getContent());
    }
}
