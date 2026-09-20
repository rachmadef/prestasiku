<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UpdateSchoolStatusRequest;
use App\Models\School;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SchoolManagementController extends Controller
{
    /**
     * List all registered schools.
     */
    public function index(Request $request): JsonResponse
    {
        $query = School::withCount('students');

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->filled('educational_level')) {
            $query->where('educational_level', $request->input('educational_level'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('npsn', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('province', 'like', "%{$search}%");
            });
        }

        $schools = $query->latest()->paginate($request->input('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $schools,
        ]);
    }

    /**
     * Show detail of a single school.
     */
    public function show(int $id): JsonResponse
    {
        $school = School::withCount('students')
            ->with(['users' => function ($q) {
                $q->role('school_admin');
            }])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $school,
        ]);
    }

    /**
     * Update school status (e.g. suspend or reactivate).
     */
    public function updateStatus(UpdateSchoolStatusRequest $request, int $id): JsonResponse
    {
        $school = School::findOrFail($id);
        $newStatus = $request->input('status');
        $notes = $request->input('notes');

        $school->update([
            'status' => $newStatus,
            'verification_notes' => $notes ?: $school->verification_notes,
        ]);

        return response()->json([
            'success' => true,
            'message' => "Status sekolah berhasil diperbarui menjadi '{$newStatus}'.",
            'data' => $school,
        ]);
    }
}
