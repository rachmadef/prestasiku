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

        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah manapun.',
            ], 403);
        }

        $query = Student::where('school_id', $school->id)->with('user:id,name,email,username,status');

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

        $students = $query->orderBy('grade_level')->orderBy('class_name')->orderBy('full_name')
            ->paginate($request->input('per_page', 20));

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

        $validated = $request->validated();
        $username = $school->npsn . '_' . $validated['nis'];
        $userEmail = $validated['email'] ?? ($username . '@siswa.prestasiku.id');

        if (User::where('email', $userEmail)->exists()) {
            $userEmail = $username . '_' . uniqid() . '@siswa.prestasiku.id';
        }

        DB::beginTransaction();
        try {
            // 1. Create User account with initial password '1234'
            $user = User::create([
                'name' => $validated['full_name'],
                'email' => $userEmail,
                'username' => $username,
                'phone' => $validated['phone_number'] ?? null,
                'school_id' => $school->id,
                'password' => Hash::make('1234'),
                'must_change_password' => true,
                'status' => 'active',
            ]);
            $user->assignRole('student');

            // 2. Create Student record
            $student = Student::create([
                'user_id' => $user->id,
                'school_id' => $school->id,
                'nis' => $validated['nis'],
                'nisn' => $validated['nisn'] ?? null,
                'full_name' => $validated['full_name'],
                'grade_level' => $validated['grade_level'],
                'class_name' => $validated['class_name'],
                'gender' => $validated['gender'],
                'birth_date' => $validated['birth_date'],
                'birth_place' => $validated['birth_place'] ?? null,
                'phone_number' => $validated['phone_number'] ?? null,
                'public_profile_enabled' => false,
                'status' => 'active',
            ]);

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
