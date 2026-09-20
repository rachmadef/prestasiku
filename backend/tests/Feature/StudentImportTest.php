<?php

namespace Tests\Feature;

use App\Models\School;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class StudentImportTest extends TestCase
{
    use RefreshDatabase;

    protected School $school;
    protected User $schoolAdmin;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);

        $this->school = School::create([
            'npsn' => '77889900',
            'name' => 'SMA Prestasi Mandiri',
            'educational_level' => 'slta',
            'province' => 'Jawa Timur',
            'city' => 'Surabaya',
            'status' => 'verified',
        ]);

        $this->schoolAdmin = User::create([
            'name' => 'Admin Import',
            'email' => 'admin.import@sekolah.id',
            'school_id' => $this->school->id,
            'password' => Hash::make('secret'),
            'status' => 'active',
        ]);
        $this->schoolAdmin->assignRole('school_admin');
    }

    public function test_school_admin_can_download_import_template(): void
    {
        $response = $this->actingAs($this->schoolAdmin)
            ->get('/api/v1/school/students-import/template');

        $response->assertStatus(200);
    }

    public function test_school_admin_can_import_students_via_csv(): void
    {
        $csvContent = implode("\n", [
            'nis,full_name,grade_level,class_name,gender,birth_date,birth_place,phone_number',
            '3001,Citra Lestari,10,X MIPA 1,P,2009-06-15,Bandung,08123456701',
            '3002,Doni Prasetyo,10,X MIPA 2,L,2009-07-20,Jakarta,08123456702',
        ]);

        $file = UploadedFile::fake()->createWithContent('siswa_baru.csv', $csvContent);

        $response = $this->actingAs($this->schoolAdmin)
            ->postJson('/api/v1/school/students-import', [
                'file' => $file,
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.total_rows', 2)
            ->assertJsonPath('data.successful_rows', 2)
            ->assertJsonPath('data.failed_rows', 0);

        // Check both students created
        $this->assertDatabaseHas('students', [
            'school_id' => $this->school->id,
            'nis' => '3001',
            'full_name' => 'Citra Lestari',
        ]);

        $this->assertDatabaseHas('students', [
            'school_id' => $this->school->id,
            'nis' => '3002',
            'full_name' => 'Doni Prasetyo',
        ]);

        // Check both user accounts created with must_change_password = true
        $this->assertDatabaseHas('users', [
            'username' => '77889900_3001',
            'must_change_password' => true,
        ]);

        $this->assertDatabaseHas('users', [
            'username' => '77889900_3002',
            'must_change_password' => true,
        ]);

        // Check import record
        $this->assertDatabaseHas('imports', [
            'school_id' => $this->school->id,
            'successful_rows' => 2,
            'status' => 'completed',
        ]);

        // Check import history
        $historyResponse = $this->actingAs($this->schoolAdmin)
            ->getJson('/api/v1/school/students-import/history');

        $historyResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data');
    }
}
