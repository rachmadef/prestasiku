<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

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

        // 2. Seed Super Administrator & Admin Sekolah
        $this->call(AdminSeeder::class);

        // 3. Seed Master Kategori Kompetisi
        $this->call(CompetitionCategorySeeder::class);

        // 4. Seed Kompetisi Riil Pusat Prestasi Nasional & BPTI Kemendikdasmen
        $this->call(PuspresnasOfficialSeeder::class);

        // 5. Seed Data Siswa Riil dari Data Siswa.xlsx
        $this->call(RealStudentSeeder::class);
    }
}
