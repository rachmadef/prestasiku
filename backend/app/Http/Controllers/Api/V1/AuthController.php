<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\LoginEvent;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Authenticate user and issue Sanctum token.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $identifier = trim($request->input('identifier'));
        $password = $request->input('password');

        // 1. Search by email or username
        $user = User::with(['roles', 'school', 'student'])
            ->where(function ($query) use ($identifier) {
                $query->where('email', $identifier)
                    ->orWhere('username', $identifier);
            })
            ->first();

        // 2. If not found, attempt search by Student NIS
        if (! $user) {
            $student = Student::with('user.roles', 'user.school')
                ->where('nis', $identifier)
                ->first();

            if ($student && $student->user) {
                $user = $student->user;
                $user->setRelation('student', $student);
            }
        }

        // 3. Verify user existence & password
        if (! $user || ! Hash::check($password, $user->password)) {
            $this->logLoginEvent($user?->id, $identifier, $request, 'failed', 'Invalid credentials');

            return response()->json([
                'success' => false,
                'message' => 'Email, username, NIS, atau password yang Anda masukkan salah.',
            ], 401);
        }

        // 4. Check user status
        if ($user->status !== 'active') {
            $this->logLoginEvent($user->id, $identifier, $request, 'failed', 'User account inactive/suspended');

            return response()->json([
                'success' => false,
                'message' => 'Akun Anda saat ini sedang dinonaktifkan atau ditangguhkan.',
                'code' => 'ACCOUNT_SUSPENDED',
            ], 403);
        }

        // 5. Check school status if user is linked to a school
        if ($user->school_id && $user->school && $user->school->status === 'suspended') {
            $this->logLoginEvent($user->id, $identifier, $request, 'failed', 'School tenant suspended');

            return response()->json([
                'success' => false,
                'message' => 'Akses sekolah Anda sedang ditangguhkan.',
                'code' => 'SCHOOL_SUSPENDED',
            ], 403);
        }

        // 6. Record successful login event
        $this->logLoginEvent($user->id, $identifier, $request, 'success');

        // 7. Update last login metadata
        $user->forceFill([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ])->saveQuietly();

        // 8. Generate Sanctum token
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'username' => $user->username,
                    'phone' => $user->phone,
                    'must_change_password' => (bool) $user->must_change_password,
                    'roles' => $user->getRoleNames(),
                    'permissions' => $user->getAllPermissions()->pluck('name'),
                    'school' => $user->school ? [
                        'id' => $user->school->id,
                        'npsn' => $user->school->npsn,
                        'name' => $user->school->name,
                        'educational_level' => $user->school->educational_level,
                        'status' => $user->school->status,
                    ] : null,
                    'student' => $user->student ? [
                        'id' => $user->student->id,
                        'nis' => $user->student->nis,
                        'nisn' => $user->student->nisn,
                        'full_name' => $user->student->full_name,
                        'grade_level' => $user->student->grade_level,
                        'class_name' => $user->student->class_name,
                        'public_id' => $user->student->public_id,
                    ] : null,
                ],
            ],
        ]);
    }

    /**
     * Get current authenticated user profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['roles', 'school', 'student']);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'username' => $user->username,
                'phone' => $user->phone,
                'must_change_password' => (bool) $user->must_change_password,
                'password_changed_at' => $user->password_changed_at,
                'roles' => $user->getRoleNames(),
                'permissions' => $user->getAllPermissions()->pluck('name'),
                'school' => $user->school ? [
                    'id' => $user->school->id,
                    'npsn' => $user->school->npsn,
                    'name' => $user->school->name,
                    'educational_level' => $user->school->educational_level,
                    'status' => $user->school->status,
                    'province' => $user->school->province,
                    'city' => $user->school->city,
                ] : null,
                'student' => $user->student ? [
                    'id' => $user->student->id,
                    'nis' => $user->student->nis,
                    'nisn' => $user->student->nisn,
                    'full_name' => $user->student->full_name,
                    'grade_level' => $user->student->grade_level,
                    'class_name' => $user->student->class_name,
                    'gender' => $user->student->gender,
                    'public_id' => $user->student->public_id,
                    'public_profile_enabled' => $user->student->public_profile_enabled,
                ] : null,
            ],
        ]);
    }

    /**
     * Mandatory / voluntary change password.
     */
    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = $request->user();

        $user->forceFill([
            'password' => Hash::make($request->input('password')),
            'must_change_password' => false,
            'password_changed_at' => now(),
        ])->save();

        return response()->json([
            'success' => true,
            'message' => 'Password Anda berhasil diperbarui.',
        ]);
    }

    /**
     * Revoke current access token.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }

    /**
     * Helper to persist login audit events.
     */
    private function logLoginEvent(?int $userId, string $identifier, Request $request, string $status, ?string $failureReason = null): void
    {
        LoginEvent::create([
            'user_id' => $userId,
            'identifier' => $identifier,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'status' => $status,
            'failure_reason' => $failureReason,
            'created_at' => now(),
        ]);
    }
}
