<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Models\CompetitionPermission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentPermissionController extends Controller
{
    /**
     * Get list of competition permissions requested by the student.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $student = $user->student;
        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil siswa tidak ditemukan.',
            ], 404);
        }

        $permissions = CompetitionPermission::where('student_id', $student->id)
            ->orWhere('requested_by', $user->id)
            ->with(['student:id,full_name,nis,class_name', 'approvedBy:id,name'])
            ->latest()
            ->paginate($request->query('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $permissions,
        ]);
    }

    /**
     * Get form schema for competition permissions configured by the school.
     */
    public function getFormSchema(Request $request): JsonResponse
    {
        $student = $request->user()->student;
        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil siswa tidak ditemukan.',
            ], 404);
        }

        $school = $student->school;
        $schema = $school ? ($school->permission_form_schema ?? []) : [];

        return response()->json([
            'success' => true,
            'data' => [
                'school_id' => $school?->id,
                'school_name' => $school?->name,
                'schema' => $schema,
            ],
        ]);
    }

    /**
     * Submit a new competition permission request by student.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $student = $user->student;
        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil siswa tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'competition_name' => ['nullable', 'string', 'max:255'],
            'competition_level' => ['nullable', 'in:kabupaten,provinsi,nasional,internasional'],
            'news_url' => ['nullable', 'url', 'max:500'],
            'purpose' => ['nullable', 'string'],
            'event_start_date' => ['nullable', 'date'],
            'event_end_date' => ['nullable', 'date'],
            'parent_name' => ['nullable', 'string', 'max:255'],
            'custom_fields_data' => ['nullable', 'array'],
        ]);

        $customData = $validated['custom_fields_data'] ?? [];
        $compName = $validated['competition_name'] ?? null;
        if (! $compName) {
            foreach ($customData as $val) {
                if (is_string($val) && strlen($val) > 1) {
                    $compName = $val;
                    break;
                }
            }
        }
        $compName = $compName ?: 'Pengajuan Perizinan Lomba';

        $startDate = $validated['event_start_date'] ?? now()->toDateString();
        $endDate = $validated['event_end_date'] ?? $startDate;

        $permission = CompetitionPermission::create([
            'school_id' => $student->school_id,
            'student_id' => $student->id,
            'competition_name' => $compName,
            'competition_level' => $validated['competition_level'] ?? 'nasional',
            'news_url' => $validated['news_url'] ?? null,
            'purpose' => $validated['purpose'] ?? null,
            'event_start_date' => $startDate,
            'event_end_date' => $endDate,
            'parent_name' => $validated['parent_name'] ?? null,
            'status' => 'pending',
            'custom_fields_data' => $customData,
            'requested_by' => $user->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Permohonan surat perizinan mengikuti lomba berhasil diajukan.',
            'data' => $permission->load('student'),
        ], 201);
    }

    /**
     * Show detail of a permission request.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;
        $permission = CompetitionPermission::where('student_id', $student->id)
            ->orWhere('requested_by', $request->user()->id)
            ->with(['student', 'school', 'approvedBy'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $permission,
        ]);
    }
}
