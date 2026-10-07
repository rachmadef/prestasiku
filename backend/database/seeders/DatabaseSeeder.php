<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     * Hanya menyertakan Role, Super Admin, Kategori, dan Kompetisi Riil Puspresnas.
     * Tidak menyertakan data dummy/demo apa pun.
     */
    public function run(): void
    {
        // 1. Seed Roles & Permissions (RBAC)
        $this->call(RoleAndPermissionSeeder::class);

        // 2. Seed Super Administrator
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

        // 3. Seed Master Kategori Kompetisi
        $this->call(CompetitionCategorySeeder::class);

        // 4. Seed Kompetisi Riil Pusat Prestasi Nasional & BPTI Kemendikdasmen
        $this->call(PuspresnasOfficialSeeder::class);

        // 5. Seed Data Siswa Riil dari Data Siswa.xlsx
        $this->call(RealStudentSeeder::class);
    }
}
