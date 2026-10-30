<?php

namespace Database\Seeders;

use App\Models\School;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class AdminSeeder extends Seeder
{
    /**
     * Seed Super Administrator and School Administrator accounts.
     */
    public function run(): void
    {
        // Pastikan role sudah tersedia jika AdminSeeder dijalankan secara terpisah
        Role::firstOrCreate(['name' => 'super_admin']);
        Role::firstOrCreate(['name' => 'school_admin']);

        // 1. Akun Super Administrator (Platform / Pusat)
        $superAdmin = User::updateOrCreate(
            ['email' => 'superadmin@prestasiku.id'],
            [
                'name' => 'Super Administrator',
                'username' => 'superadmin',
                'phone' => '081100000001',
                'password' => Hash::make('password'),
                'must_change_password' => false,
                'status' => 'active',
            ]
        );
        $superAdmin->syncRoles(['super_admin']);

        // 2. Pastikan sekolah utama tersedia untuk Admin Sekolah
        $school = School::firstOrCreate(
            ['npsn' => '20579998'],
            [
                'name' => 'MA Unggulan K.H. Abd. Wahab Hasbulloh',
                'educational_level' => 'slta',
                'province' => 'Jawa Timur',
                'city' => 'Jombang',
                'address' => 'Tambakberas, Jombang',
                'phone' => '0321-123456',
                'email' => 'info@mau-tb.sch.id',
                'status' => 'verified',
                'verified_at' => now(),
                'verified_by' => $superAdmin->id,
            ]
        );

        // 3. Akun Admin Sekolah (MA Unggulan K.H. Abd. Wahab Hasbulloh)
        $schoolAdmin = User::updateOrCreate(
            ['email' => ' '],
            [
                'name' => 'Admin MAU K.H. Abd. Wahab Hasbulloh',
                'username' => 'admin_sekolah',
                'phone' => '0321-123456',
                'school_id' => $school->id,
                'password' => Hash::make('password'),
                'must_change_password' => false,
                'status' => 'active',
            ]
        );
        $schoolAdmin->syncRoles(['school_admin']);

        $this->command?->info('Berhasil membuat akun Super Admin & Admin Sekolah!');
    }
}

