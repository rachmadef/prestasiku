<?php

namespace App\Policies;

use App\Models\School;
use App\Models\User;

class SchoolPolicy
{
    public function before(User $user, string $ability): ?bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return null;
    }

    public function view(User $user, School $school): bool
    {
        return $user->school_id === $school->id;
    }

    public function update(User $user, School $school): bool
    {
        return $user->hasRole('school_admin') && $user->school_id === $school->id;
    }
}
