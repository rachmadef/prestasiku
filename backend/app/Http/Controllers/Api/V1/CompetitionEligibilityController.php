<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\Student;
use App\Services\EligibilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompetitionEligibilityController extends Controller
{
    public function __construct(
        protected EligibilityService $eligibilityService
    ) {}

    /**
     * Check if a student is eligible for the specified competition.
     */
    public function check(Request $request, int $id): JsonResponse
    {
        $competition = Competition::with('eligibility')->findOrFail($id);
        $user = $request->user();
        $student = null;

        if ($user->isStudent()) {
            $student = $user->student;
        } elseif ($request->filled('student_id')) {
            $student = Student::findOrFail($request->input('student_id'));

            // If caller is school admin, ensure the student belongs to their school
            if ($user->isSchoolAdmin() && $student->school_id !== $user->school_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda hanya dapat memeriksa kelayakan siswa dari sekolah Anda sendiri.',
                ], 403);
            }
        }

        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil siswa tidak ditemukan untuk pemeriksaan eligibility.',
            ], 422);
        }

        $result = $this->eligibilityService->checkEligibility($student, $competition);

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }
}
