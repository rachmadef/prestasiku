<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\CompetitionSupervisor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SchoolSupervisorController extends Controller
{
    /**
     * Get list of supervisor & bisyaroh assignments for the school.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user();
        $schoolId = $user->school_id;

        $query = CompetitionSupervisor::with(['competition'])
            ->where('school_id', $schoolId);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('supervisor_name', 'like', "%{$search}%")
                  ->orWhere('supervisor_nip', 'like', "%{$search}%")
                  ->orWhereHas('competition', function ($cq) use ($search) {
                      $cq->where('title', 'like', "%{$search}%");
                  });
            });
        }

        $supervisors = $query->latest()->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $supervisors,
        ]);
    }

    /**
     * Get curated competitions eligible for supervisor bisyaroh form.
     */
    public function eligibleCompetitions(): JsonResponse
    {
        // Only competitions with curation_type = resmi_negara or terkurasi_puspresnas
        $competitions = Competition::whereIn('curation_type', ['resmi_negara', 'terkurasi_puspresnas'])
            ->select(['id', 'title', 'level', 'curation_type', 'official_website_url', 'registration_url'])
            ->orderBy('title')
            ->get()
            ->map(function ($comp) {
                // Determine standard SOP bisyaroh recommendation
                $sopAmount = match ($comp->level) {
                    'kabupaten' => 250000,
                    'provinsi' => 500000,
                    'nasional' => 1000000,
                    'internasional' => 2000000,
                    default => 250000,
                };
                $comp->sop_bisyaroh_recommendation = $sopAmount;
                return $comp;
            });

        return response()->json([
            'success' => true,
            'data' => $competitions,
        ]);
    }

    /**
     * Store a new supervisor & bisyaroh form assignment.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'competition_id' => ['required', 'exists:competitions,id'],
            'supervisor_name' => ['required', 'string', 'max:255'],
            'supervisor_nip' => ['nullable', 'string', 'max:50'],
            'supervisor_phone' => ['nullable', 'string', 'max:20'],
            'role_title' => ['required', 'string', 'max:100'],
            'bisyaroh_amount' => ['required', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string'],
        ]);

        $competition = Competition::findOrFail($validated['competition_id']);

        // Strict SOP Check: Only official/curated competitions eligible
        if (!in_array($competition->curation_type, ['resmi_negara', 'terkurasi_puspresnas'])) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan Form Bisyaroh Pendamping HANYA berlaku untuk Lomba Resmi Negara / Terkurasi Puspresnas sesuai SOP.',
            ], 422);
        }

        $user = Auth::user();

        // Calculate SOP Category Label
        $sopCategory = 'SOP Bisyaroh Tingkat ' . ucfirst($competition->level);

        $supervisor = CompetitionSupervisor::create([
            'school_id' => $user->school_id,
            'competition_id' => $competition->id,
            'supervisor_name' => $validated['supervisor_name'],
            'supervisor_nip' => $validated['supervisor_nip'] ?? null,
            'supervisor_phone' => $validated['supervisor_phone'] ?? null,
            'role_title' => $validated['role_title'],
            'bisyaroh_amount' => $validated['bisyaroh_amount'],
            'sop_category' => $sopCategory,
            'notes' => $validated['notes'] ?? null,
            'status' => 'approved', // Auto-approved for school admin
            'created_by' => $user->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Form Pendamping Lomba & Pembagian Bisyaroh berhasil diterbitkan sesuai SOP.',
            'data' => $supervisor->load('competition'),
        ], 201);
    }

    /**
     * Show detail of a supervisor & bisyaroh assignment.
     */
    public function show(int $id): JsonResponse
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::with(['competition', 'school'])
            ->where('school_id', $user->school_id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $supervisor,
        ]);
    }

    /**
     * Update supervisor & bisyaroh assignment.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::where('school_id', $user->school_id)->findOrFail($id);

        $validated = $request->validate([
            'supervisor_name' => ['sometimes', 'required', 'string', 'max:255'],
            'supervisor_nip' => ['nullable', 'string', 'max:50'],
            'supervisor_phone' => ['nullable', 'string', 'max:20'],
            'role_title' => ['sometimes', 'required', 'string', 'max:100'],
            'bisyaroh_amount' => ['sometimes', 'required', 'numeric', 'min:0'],
            'status' => ['sometimes', 'required', 'in:pending,approved,disbursed'],
            'notes' => ['nullable', 'string'],
        ]);

        $supervisor->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Data Pendamping & Bisyaroh berhasil diperbarui.',
            'data' => $supervisor->fresh(['competition']),
        ]);
    }

    /**
     * Delete supervisor assignment.
     */
    public function destroy(int $id): JsonResponse
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::where('school_id', $user->school_id)->findOrFail($id);
        $supervisor->delete();

        return response()->json([
            'success' => true,
            'message' => 'Form Pendamping & Bisyaroh telah dihapus.',
        ]);
    }
}
