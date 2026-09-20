<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RoleAndPermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        // Define permissions
        $permissions = [
            // Schools
            'schools.view',
            'schools.create',
            'schools.edit',
            'schools.delete',
            'schools.verify',
            // Students
            'students.view',
            'students.create',
            'students.edit',
            'students.delete',
            'students.import',
            // Competitions
            'competitions.view',
            'competitions.create',
            'competitions.edit',
            'competitions.delete',
            'competitions.verify',
            // Registrations
            'registrations.view',
            'registrations.create',
            'registrations.approve',
            // Achievements
            'achievements.view',
            'achievements.create',
            'achievements.verify',
            // Audit & Monitoring
            'audit_logs.view',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create Roles and assign permissions
        $superAdmin = Role::firstOrCreate(['name' => 'super_admin']);
        $superAdmin->syncPermissions(Permission::all());

        $schoolAdmin = Role::firstOrCreate(['name' => 'school_admin']);
        $schoolAdmin->syncPermissions([
            'schools.view',
            'schools.edit',
            'students.view',
            'students.create',
            'students.edit',
            'students.delete',
            'students.import',
            'competitions.view',
            'registrations.view',
            'registrations.approve',
            'achievements.view',
            'achievements.verify',
        ]);

        $student = Role::firstOrCreate(['name' => 'student']);
        $student->syncPermissions([
            'competitions.view',
            'registrations.create',
            'registrations.view',
            'achievements.create',
            'achievements.view',
        ]);
    }
}
