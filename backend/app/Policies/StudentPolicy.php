<?php

namespace App\Policies;

use App\Models\Student;
use App\Models\User;

class StudentPolicy
{
    /**
     * Super Admin bypasses all checks.
     */
    public function before(User $user, string $ability): ?bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return null;
    }

    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('students.view');
    }

    public function view(User $user, Student $student): bool
    {
        return $user->hasPermissionTo('students.view') && $user->school_id === $student->school_id;
    }

    public function create(User $user): bool
    {
        return $user->hasPermissionTo('students.create') && ! empty($user->school_id);
    }

    public function update(User $user, Student $student): bool
    {
        return $user->hasPermissionTo('students.edit') && $user->school_id === $student->school_id;
    }

    public function delete(User $user, Student $student): bool
    {
        return $user->hasPermissionTo('students.delete') && $user->school_id === $student->school_id;
    }

    public function resetPassword(User $user, Student $student): bool
    {
        return $user->hasRole('school_admin') && $user->school_id === $student->school_id;
    }
}
