<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SchoolRegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_school_can_submit_registration_successfully(): void
    {
        $payload = [
            'npsn' => '87654321',
            'school_name' => 'SMP Negeri 5 Bintang Juara',
            'educational_level' => 'sltp',
            'province' => 'Jawa Timur',
            'city' => 'Surabaya',
            'district' => 'Genteng',
            'address' => 'Jl. Pemuda No. 45',
            'pic_name' => 'Budi Santoso, M.Pd.',
            'pic_email' => 'budi.santoso@smpn5surabaya.sch.id',
            'pic_phone' => '081345678901',
            'pic_position' => 'Kepala Sekolah',
        ];

        $response = $this->postJson('/api/v1/school-registration', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.npsn', '87654321')
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('school_registrations', [
            'npsn' => '87654321',
            'school_name' => 'SMP Negeri 5 Bintang Juara',
            'status' => 'pending',
        ]);
    }

    public function test_school_registration_fails_validation_if_npsn_missing(): void
    {
        $response = $this->postJson('/api/v1/school-registration', [
            'school_name' => 'SMP Tanpa NPSN',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['npsn', 'educational_level', 'pic_name', 'pic_email']);
    }

    public function test_school_can_submit_registration_with_name_alias(): void
    {
        $payload = [
            'npsn' => '10101010',
            'name' => 'MA Unggulan K.H. Abd. Wahab Hasbullah',
            'educational_level' => 'slta',
            'province' => 'Jawa Timur',
            'city' => 'Kabupaten Jombang',
            'district' => 'Jombang',
            'address' => 'Jl. K.H. Abd. Wahab Hasbulloh Gg. Pondok, Tambakberas',
            'pic_name' => 'Rachmad Eric F.',
            'pic_email' => 'jarakcomunitty@gmail.com',
            'pic_phone' => '08567743009',
            'pic_position' => 'Staff Humas',
        ];

        $response = $this->postJson('/api/v1/school-registration', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.school_name', 'MA Unggulan K.H. Abd. Wahab Hasbullah');

        $this->assertDatabaseHas('school_registrations', [
            'npsn' => '10101010',
            'school_name' => 'MA Unggulan K.H. Abd. Wahab Hasbullah',
        ]);
    }
}

