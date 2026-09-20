<?php

namespace Database\Seeders;

use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed Roles & Permissions
        $this->call(RoleAndPermissionSeeder::class);

        // 2. Seed Super Admin
        $superAdmin = User::create([
            'name' => 'Super Administrator',
            'email' => 'superadmin@prestasiku.id',
            'username' => 'superadmin',
            'phone' => '081100000001',
            'password' => Hash::make('password'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $superAdmin->assignRole('super_admin');

        // 3. Seed Verified Demo School
        $demoSchool = School::create([
            'npsn' => '10101010',
            'name' => 'SMA Negeri 1 Prestasi Nusantara',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'DKI Jakarta',
            'city' => 'Kota Jakarta Selatan',
            'district' => 'Kebayoran Baru',
            'address' => 'Jl. Pendidikan Karakter No. 10',
            'postal_code' => '12110',
            'phone' => '021-7890123',
            'email' => 'info@sman1prestasi.sch.id',
            'website' => 'https://sman1prestasi.sch.id',
            'verified_at' => now(),
            'verified_by' => $superAdmin->id,
            'verification_notes' => 'Instansi sekolah terverifikasi resmi untuk percontohan PrestasiKu.',
        ]);

        // 4. Seed School Admin
        $schoolAdmin = User::create([
            'name' => 'Admin SMAN 1 Prestasi',
            'email' => 'admin.sman1@prestasiku.id',
            'username' => 'adminsman1',
            'phone' => '081234567891',
            'school_id' => $demoSchool->id,
            'password' => Hash::make('password'),
            'must_change_password' => false,
            'status' => 'active',
        ]);
        $schoolAdmin->assignRole('school_admin');

        // 5. Seed Demo Student with default password '1234' and must_change_password = true
        $studentUser = User::create([
            'name' => 'Ahmad Bintang Pratama',
            'email' => 'ahmad.bintang@siswa.prestasiku.id',
            'username' => '10101010_2026001',
            'phone' => '081298765432',
            'school_id' => $demoSchool->id,
            'password' => Hash::make('1234'), // Default initial password
            'must_change_password' => true,   // Requires immediate password reset upon first login
            'status' => 'active',
        ]);
        $studentUser->assignRole('student');

        Student::create([
            'user_id' => $studentUser->id,
            'school_id' => $demoSchool->id,
            'nis' => '2026001',
            'nisn' => '0081234567',
            'full_name' => 'Ahmad Bintang Pratama',
            'grade_level' => 10,
            'class_name' => 'X MIPA 1',
            'gender' => 'L',
            'birth_date' => '2009-05-15',
            'birth_place' => 'Jakarta',
            'phone_number' => '081298765432',
            'public_profile_enabled' => false, // Privacy by default
            'status' => 'active',
        ]);

        // 6. Seed Competition Categories & Demo Competitions
        $this->call(CompetitionCategorySeeder::class);
        $this->call(DemoCompetitionSeeder::class);
    }
}

