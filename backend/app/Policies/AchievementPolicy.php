<?php

namespace App\Policies;

use App\Models\Achievement;
use App\Models\User;

class AchievementPolicy
{
    public function before(User $user, string $ability): ?bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return null;
    }

    public function view(User $user, Achievement $achievement): bool
    {
        // School admin can view if achievement belongs to their school
        if ($user->isSchoolAdmin() && $user->school_id === $achievement->school_id) {
            return true;
        }

        // Student can view their own achievement
        if ($user->isStudent() && $user->student && $user->student->id === $achievement->student_id) {
            return true;
        }

        return false;
    }

    public function verify(User $user, Achievement $achievement): bool
    {
        return $user->isSchoolAdmin() && $user->school_id === $achievement->school_id;
    }

    public function togglePublic(User $user, Achievement $achievement): bool
    {
        // Only the student who owns the achievement or school admin can toggle public status
        if ($user->isStudent() && $user->student && $user->student->id === $achievement->student_id) {
            return true;
        }

        return $user->isSchoolAdmin() && $user->school_id === $achievement->school_id;
    }

    public function update(User $user, Achievement $achievement): bool
    {
        if ($user->isSchoolAdmin() && $user->school_id === $achievement->school_id) {
            return true;
        }

        if ($user->isStudent() && $user->student && $user->student->id === $achievement->student_id) {
            return in_array($achievement->status, ['draft', 'pending_verification', 'rejected']);
        }

        return false;
    }

    public function delete(User $user, Achievement $achievement): bool
    {
        if ($user->isSchoolAdmin() && $user->school_id === $achievement->school_id) {
            return true;
        }

        if ($user->isStudent() && $user->student && $user->student->id === $achievement->student_id) {
            return in_array($achievement->status, ['draft', 'pending_verification']);
        }

        return false;
    }
}
