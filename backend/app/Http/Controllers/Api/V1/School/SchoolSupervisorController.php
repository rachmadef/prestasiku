<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\CompetitionSupervisor;
use App\Models\KbmDispensation;
use App\Models\Registration;
use App\Models\Student;
use App\Services\SupervisorDocumentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class SchoolSupervisorController extends Controller
{
    public function __construct(protected SupervisorDocumentService $documentService)
    {
    }

    /**
     * Get list of supervisor & bisyaroh assignments for the school.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user();
        $schoolId = $user->school_id;

        $query = CompetitionSupervisor::with(['competition', 'creator', 'approver'])
            ->where('school_id', $schoolId);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('supervisor_name', 'like', "%{$search}%")
                  ->orWhere('supervisor_nip', 'like', "%{$search}%")
                  ->orWhere('competition_name', 'like', "%{$search}%")
                  ->orWhere('student_names', 'like', "%{$search}%")
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
     * Get curated competitions and participated competition history eligible for supervisor form.
     */
    public function eligibleCompetitions(): JsonResponse
    {
        $user = Auth::user();
        $schoolId = $user->school_id;

        // Curated competitions catalog
        $competitions = Competition::whereIn('curation_type', ['resmi_negara', 'terkurasi_puspresnas'])
            ->select(['id', 'title', 'level', 'curation_type', 'official_website_url', 'registration_url'])
            ->orderBy('title')
            ->get()
            ->map(function ($comp) {
                $comp->sop_bisyaroh_recommendation = match ($comp->level) {
                    'kabupaten' => 50000,
                    'provinsi' => 100000,
                    'nasional' => 150000,
                    'internasional' => 200000,
                    default => 50000,
                };
                return $comp;
            });

        // Competitions participated by students (from KbmDispensation)
        $dispensations = KbmDispensation::with(['students:id,full_name,class_name,nisn'])
            ->where('school_id', $schoolId)
            ->latest()
            ->get()
            ->map(function ($disp) {
                $studentNames = $disp->students->pluck('full_name')->implode(', ');
                return [
                    'source' => 'dispensation',
                    'dispensation_id' => $disp->id,
                    'competition_name' => $disp->competition_name,
                    'competition_level' => $disp->competition_level ?: 'kabupaten',
                    'competition_branch' => $disp->dispensation_type === 'hari_h_lomba' ? 'Perlombaan Utama' : 'Persiapan & Pembinaan Lomba',
                    'competition_place' => $disp->location ?: 'Kampus/Penyelenggara Lomba',
                    'event_date' => $disp->start_date ? date('Y-m-d', strtotime($disp->start_date)) : null,
                    'student_names' => $studentNames,
                    'students' => $disp->students,
                ];
            });

        // Competitions participated by students (from Registration)
        $registrations = Registration::with(['competition', 'student:id,full_name,class_name,nisn'])
            ->where('school_id', $schoolId)
            ->whereNotNull('competition_id')
            ->latest()
            ->get()
            ->map(function ($reg) {
                return [
                    'source' => 'registration',
                    'competition_id' => $reg->competition_id,
                    'competition_name' => $reg->competition?->title ?? '-',
                    'competition_level' => $reg->competition?->level ?? 'kabupaten',
                    'competition_branch' => 'Kompetisi Siswa',
                    'competition_place' => 'Penyelenggara Resmi',
                    'student_names' => $reg->student?->full_name ?? '',
                    'students' => $reg->student ? [$reg->student] : [],
                ];
            });

        // Merge & deduplicate participated competitions by title
        $participated = collect([...$dispensations, ...$registrations])
            ->unique('competition_name')
            ->values();

        // Students list for picker
        $students = Student::where('school_id', $schoolId)
            ->select(['id', 'full_name', 'class_name', 'nisn'])
            ->orderBy('full_name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'curated_competitions' => $competitions,
                'participated_competitions' => $participated,
                'students' => $students,
                'duty_rates' => [
                    ['key' => 'dalam_kota', 'label' => 'Dalam Kota', 'rate' => 50000],
                    ['key' => 'luar_kota', 'label' => 'Luar Kota', 'rate' => 100000],
                    ['key' => 'luar_provinsi', 'label' => 'Luar Provinsi', 'rate' => 150000],
                    ['key' => 'luar_negeri', 'label' => 'Luar Negeri', 'rate' => 200000],
                ],
            ],
        ]);
    }

    /**
     * Store a new supervisor & bisyaroh form assignment.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'competition_id' => ['nullable', 'exists:competitions,id'],
            'competition_name' => ['required', 'string', 'max:255'],
            'organizer_name' => ['nullable', 'string', 'max:255'],
            'competition_branch' => ['nullable', 'string', 'max:255'],
            'student_names' => ['nullable', 'string'],
            'student_ids' => ['nullable', 'array'],
            'competition_category' => ['nullable', 'string', 'max:100'],
            'competition_place' => ['nullable', 'string', 'max:255'],
            'competition_level' => ['nullable', 'string', 'in:kabupaten,provinsi,nasional,internasional'],
            'event_date' => ['nullable', 'string', 'max:100'],
            'supervisor_name' => ['required', 'string', 'max:255'],
            'supervisor_nip' => ['nullable', 'string', 'max:50'],
            'supervisor_phone' => ['nullable', 'string', 'max:30'],
            'supervisor_category' => ['nullable', 'string', 'max:100'],
            'supervisor_gender' => ['nullable', 'string', 'max:20'],
            'role_title' => ['required', 'string', 'max:100'],
            'duty_zone' => ['nullable', 'string', 'in:dalam_kota,luar_kota,luar_provinsi,luar_negeri'],
            'bisyaroh_amount' => ['required', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string'],
            'statement_agreed' => ['nullable', 'boolean'],
        ]);

        $user = Auth::user();
        $schoolId = $user->school_id;

        $competitionLevel = $validated['competition_level'] ?? 'kabupaten';
        if (!empty($validated['competition_id'])) {
            $competition = Competition::find($validated['competition_id']);
            if ($competition) {
                $competitionLevel = $competition->level ?: $competitionLevel;
                if (empty($validated['competition_name'])) {
                    $validated['competition_name'] = $competition->title;
                }
            }
        }

        $sopCategory = 'SOP Bisyaroh Tingkat ' . ucfirst($competitionLevel);

        $supervisor = CompetitionSupervisor::create([
            'school_id' => $schoolId,
            'competition_id' => $validated['competition_id'] ?? null,
            'competition_name' => $validated['competition_name'],
            'organizer_name' => $validated['organizer_name'] ?? null,
            'competition_branch' => $validated['competition_branch'] ?? null,
            'student_names' => $validated['student_names'] ?? null,
            'student_ids' => $validated['student_ids'] ?? null,
            'competition_category' => $validated['competition_category'] ?? 'SMA / MA',
            'competition_place' => $validated['competition_place'] ?? null,
            'competition_level' => $competitionLevel,
            'event_date' => $validated['event_date'] ?? null,
            'supervisor_name' => $validated['supervisor_name'],
            'supervisor_nip' => $validated['supervisor_nip'] ?? null,
            'supervisor_phone' => $validated['supervisor_phone'] ?? null,
            'supervisor_category' => $validated['supervisor_category'] ?? 'Guru',
            'supervisor_gender' => $validated['supervisor_gender'] ?? 'Laki-laki',
            'role_title' => $validated['role_title'],
            'duty_zone' => $validated['duty_zone'] ?? 'dalam_kota',
            'bisyaroh_amount' => $validated['bisyaroh_amount'],
            'sop_category' => $sopCategory,
            'notes' => $validated['notes'] ?? null,
            'statement_agreed' => $validated['statement_agreed'] ?? true,
            'status' => 'approved',
            'created_by' => $user->id,
            'approved_by' => $user->id,
            'approved_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Form Pendamping Lomba & Pembagian Bisyaroh berhasil diterbitkan.',
            'data' => $supervisor->load(['competition', 'school']),
        ], 201);
    }

    /**
     * Show detail of a supervisor & bisyaroh assignment.
     */
    public function show(int $id): JsonResponse
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::with(['competition', 'school', 'creator', 'approver'])
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
            'competition_id' => ['nullable', 'exists:competitions,id'],
            'competition_name' => ['sometimes', 'required', 'string', 'max:255'],
            'competition_branch' => ['nullable', 'string', 'max:255'],
            'student_names' => ['nullable', 'string'],
            'student_ids' => ['nullable', 'array'],
            'competition_category' => ['nullable', 'string', 'max:100'],
            'competition_place' => ['nullable', 'string', 'max:255'],
            'competition_level' => ['nullable', 'string', 'in:kabupaten,provinsi,nasional,internasional'],
            'supervisor_name' => ['sometimes', 'required', 'string', 'max:255'],
            'supervisor_nip' => ['nullable', 'string', 'max:50'],
            'supervisor_phone' => ['nullable', 'string', 'max:30'],
            'supervisor_category' => ['nullable', 'string', 'max:100'],
            'supervisor_gender' => ['nullable', 'string', 'max:20'],
            'role_title' => ['sometimes', 'required', 'string', 'max:100'],
            'duty_zone' => ['nullable', 'string', 'in:dalam_kota,luar_kota,luar_provinsi,luar_negeri'],
            'bisyaroh_amount' => ['sometimes', 'required', 'numeric', 'min:0'],
            'status' => ['sometimes', 'required', 'in:pending,approved,disbursed'],
            'notes' => ['nullable', 'string'],
        ]);

        if (isset($validated['status']) && $validated['status'] === 'approved' && !$supervisor->approved_by) {
            $validated['approved_by'] = $user->id;
            $validated['approved_at'] = now();
        }

        $supervisor->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Data Pendamping & Bisyaroh berhasil diperbarui.',
            'data' => $supervisor->fresh(['competition', 'school']),
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

    /**
     * Download DOCX file.
     */
    public function downloadDocx(int $id): BinaryFileResponse
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::where('school_id', $user->school_id)->findOrFail($id);

        $path = $this->documentService->generateDocx($supervisor);
        $safeName = preg_replace('/[^a-zA-Z0-9_-]/', '_', $supervisor->supervisor_name ?: 'Pendamping');

        return response()->download($path, "Form_Pendamping_{$safeName}.docx")->deleteFileAfterSend(true);
    }

    /**
     * Download PDF file.
     */
    public function downloadPdf(int $id)
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::where('school_id', $user->school_id)->findOrFail($id);

        $pdf = $this->documentService->generatePdf($supervisor);
        $safeName = preg_replace('/[^a-zA-Z0-9_-]/', '_', $supervisor->supervisor_name ?: 'Pendamping');

        return $pdf->download("Form_Pendamping_{$safeName}.pdf");
    }

    /**
     * Print letter preview data.
     */
    public function printLetter(int $id): JsonResponse
    {
        $user = Auth::user();
        $supervisor = CompetitionSupervisor::with(['competition', 'school', 'creator'])
            ->where('school_id', $user->school_id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $supervisor,
        ]);
    }
}
