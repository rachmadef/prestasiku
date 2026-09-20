<?php

namespace App\Policies;

use App\Models\Registration;
use App\Models\User;

class RegistrationPolicy
{
    public function before(User $user, string $ability): ?bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return null;
    }

    public function view(User $user, Registration $registration): bool
    {
        // School Admin can view all registrations of their own school
        if ($user->isSchoolAdmin() && $user->school_id === $registration->school_id) {
            return true;
        }

        // Student can view if they are the registrant, individual candidate, or a team member
        if ($user->isStudent() && $user->student) {
            $studentId = $user->student->id;

            if ($registration->student_id === $studentId || $registration->registered_by === $user->id) {
                return true;
            }

            if ($registration->team_id && $registration->team) {
                return $registration->team->members()->where('student_id', $studentId)->exists();
            }
        }

        return false;
    }

    public function review(User $user, Registration $registration): bool
    {
        return $user->isSchoolAdmin() && $user->school_id === $registration->school_id;
    }
}
