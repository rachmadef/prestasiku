<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Http\Requests\School\StoreStudentRequest;
use App\Http\Requests\School\UpdateStudentRequest;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class StudentManagementController extends Controller
{
    /**
     * List students for the authenticated school admin's tenant.
     */
    public function index(Request $request): JsonResponse
    {
        $school = $request->user()->school;

        $query = Student::with('user:id,name,email,username,status');
        if ($school && \Schema::hasColumn('students', 'school_id')) {
            $query->where('school_id', $school->id);
        }

        if ($request->filled('grade_level')) {
            $query->where('grade_level', $request->input('grade_level'));
        }

        if ($request->filled('class_name')) {
            $query->where('class_name', $request->input('class_name'));
        }

        if ($request->filled('gender')) {
            $query->where('gender', $request->input('gender'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', "%{$search}%")
                    ->orWhere('nis', 'like', "%{$search}%")
                    ->orWhere('nisn', 'like', "%{$search}%");
            });
        }

        if ($request->input('per_page') === 'all' || $request->input('all') == 1) {
            $students = $query->orderBy('grade_level')->orderBy('class_name')->orderBy('full_name')->get();
            return response()->json([
                'success' => true,
                'data' => $students,
            ]);
        }

        $perPage = (int) $request->input('per_page', 20);
        if ($perPage <= 0) {
            $perPage = 20;
        }

        $students = $query->orderBy('grade_level')->orderBy('class_name')->orderBy('full_name')
            ->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $students,
        ]);
    }

    /**
     * Store a new student manually and generate a student account.
     */
    public function store(StoreStudentRequest $request): JsonResponse
    {
        $school = $request->user()->school;
        $schoolId = $school ? $school->id : null;

        $validated = $request->validated();
        $username = User::generateUsernameFromName($validated['full_name']);
        $userEmail = $validated['email'] ?? ($username . '@siswa.prestasiku.id');

        if (User::where('email', $userEmail)->exists()) {
            $userEmail = $username . '_' . uniqid() . '@siswa.prestasiku.id';
        }

        DB::beginTransaction();
        try {
            $userData = [
                'name' => $validated['full_name'],
                'email' => $userEmail,
                'username' => $username,
                'phone' => $validated['phone_number'] ?? null,
                'password' => Hash::make('1234'),
                'must_change_password' => true,
                'status' => 'active',
            ];
            if (\Schema::hasColumn('users', 'school_id') && $schoolId) {
                $userData['school_id'] = $schoolId;
            }

            // 1. Create User account with initial password '1234'
            $user = User::create($userData);
            $user->assignRole('student');

            // 2. Create Student record
            $studentData = [
                'user_id' => $user->id,
                'nis' => $validated['nis'],
                'nisn' => $validated['nisn'] ?? null,
                'full_name' => $validated['full_name'],
                'grade_level' => $validated['grade_level'],
                'class_name' => $validated['class_name'],
                'gender' => $validated['gender'],
                'birth_date' => !empty($validated['birth_date']) ? $validated['birth_date'] : '2008-01-01',
                'birth_place' => $validated['birth_place'] ?? null,
                'phone_number' => $validated['phone_number'] ?? null,
                'public_profile_enabled' => false,
                'status' => 'active',
            ];
            if (\Schema::hasColumn('students', 'school_id') && $schoolId) {
                $studentData['school_id'] = $schoolId;
            }

            $student = Student::create($studentData);

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan siswa: ' . $e->getMessage(),
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil ditambahkan. Akun siswa aktif dengan password awal 1234.',
            'data' => [
                'student' => $student->load('user:id,name,email,username,status,must_change_password'),
                'initial_credentials' => [
                    'nis' => $student->nis,
                    'username' => $username,
                    'email' => $userEmail,
                    'default_password' => '1234',
                ],
            ],
        ], 201);
    }

    /**
     * Show single student detail.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $student = Student::with('user:id,name,email,username,status,must_change_password,last_login_at')
            ->findOrFail($id);

        if (! $request->user()->can('view', $student)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki otorisasi untuk mengakses data siswa dari sekolah lain.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $student,
        ]);
    }

    /**
     * Update student details.
     */
    public function update(UpdateStudentRequest $request, int $id): JsonResponse
    {
        $student = Student::findOrFail($id);

        if (! $request->user()->can('update', $student)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki otorisasi untuk mengubah data siswa ini.',
            ], 403);
        }

        $validated = $request->validated();
        $student->update($validated);

        if (isset($validated['full_name']) && $student->user) {
            $student->user->update(['name' => $validated['full_name']]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil diperbarui.',
            'data' => $student->fresh('user:id,name,email,username,status'),
        ]);
    }

    /**
     * Soft delete student and associated user account.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $student = Student::findOrFail($id);

        if (! $request->user()->can('delete', $student)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki otorisasi untuk menghapus siswa ini.',
            ], 403);
        }

        DB::transaction(function () use ($student) {
            $student->user?->delete();
            $student->delete();
        });

        return response()->json([
            'success' => true,
            'message' => 'Data siswa dan akunnya berhasil dihapus.',
        ]);
    }

    /**
     * Reset student password to default '1234'.
     */
    public function resetPassword(Request $request, int $id): JsonResponse
    {
        $student = Student::with('user')->findOrFail($id);

        if (! $request->user()->can('resetPassword', $student)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki otorisasi untuk mereset password siswa ini.',
            ], 403);
        }

        if (! $student->user) {
            return response()->json([
                'success' => false,
                'message' => 'Akun pengguna siswa tidak ditemukan.',
            ], 404);
        }

        $student->user->update([
            'password' => Hash::make('1234'),
            'must_change_password' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => "Password siswa '{$student->full_name}' berhasil direset ke default '1234'. Siswa akan diminta mengganti password saat login.",
        ]);
    }
}
