<?php

namespace App\Http\Controllers\Api\V1\Public;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\CompetitionSupervisor;
use App\Models\KbmDispensation;
use App\Models\Registration;
use App\Models\School;
use App\Models\Student;
use App\Services\SupervisorDocumentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class PublicSupervisorController extends Controller
{
    public function __construct(protected SupervisorDocumentService $documentService)
    {
    }

    /**
     * Get competition options, student history, and duty rates for public form.
     */
    public function getOptions(): JsonResponse
    {
        $schoolId = 1; // Default: MA Unggulan K.H. Abd. Wahab Hasbulloh
        $school = School::find($schoolId);

        // Curated competitions catalog
        $competitions = Competition::whereIn('curation_type', ['resmi_negara', 'terkurasi_puspresnas'])
            ->select(['id', 'title', 'level', 'curation_type'])
            ->orderBy('title')
            ->get();

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

        // Competitions from Registration
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

        $participated = collect([...$dispensations, ...$registrations])
            ->unique('competition_name')
            ->values();

        // Students list for quick lookup
        $students = Student::where('school_id', $schoolId)
            ->select(['id', 'full_name', 'class_name', 'nisn'])
            ->orderBy('full_name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'school_name' => $school?->name ?? 'MA Unggulan K.H. Abd. Wahab Hasbulloh',
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
     * Submit supervisor form from public link without login.
     */
    public function submit(Request $request): JsonResponse
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
            'supervisor_phone' => ['required', 'string', 'max:30'],
            'supervisor_category' => ['required', 'string', 'max:100'],
            'supervisor_gender' => ['required', 'string', 'max:20'],
            'role_title' => ['required', 'string', 'max:100'],
            'duty_zone' => ['nullable', 'string', 'in:dalam_kota,luar_kota,luar_provinsi,luar_negeri'],
            'bisyaroh_amount' => ['nullable', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string'],
            'statement_agreed' => ['required', 'boolean', 'accepted'],
        ]);

        $schoolId = 1;

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

        $bisyarohAmount = $validated['bisyaroh_amount'] ?? 0;
        $sopCategory = $bisyarohAmount > 0
            ? 'SOP Bisyaroh Tingkat ' . ucfirst($competitionLevel)
            : 'Pendamping Resmi Madrasah';

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
            'supervisor_phone' => $validated['supervisor_phone'],
            'supervisor_category' => $validated['supervisor_category'],
            'supervisor_gender' => $validated['supervisor_gender'],
            'role_title' => $validated['role_title'],
            'duty_zone' => $validated['duty_zone'] ?? 'dalam_kota',
            'bisyaroh_amount' => $bisyarohAmount,
            'sop_category' => $sopCategory,
            'notes' => $validated['notes'] ?? null,
            'statement_agreed' => true,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Formulir Pendamping Perlombaan berhasil dikirim. Terima kasih Bapak/Ibu Pendamping!',
            'data' => [
                'id' => $supervisor->id,
                'public_token' => $supervisor->public_token,
                'reference_number' => $supervisor->reference_number,
                'supervisor_name' => $supervisor->supervisor_name,
                'competition_name' => $supervisor->competition_name,
            ],
        ], 201);
    }

    /**
     * Show detail of submitted form by token.
     */
    public function show(string $token): JsonResponse
    {
        $supervisor = CompetitionSupervisor::with(['competition', 'school'])
            ->where('public_token', $token)
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $supervisor,
        ]);
    }

    /**
     * Download DOCX file via public token.
     */
    public function downloadDocx(string $token): BinaryFileResponse
    {
        $supervisor = CompetitionSupervisor::where('public_token', $token)->firstOrFail();

        $path = $this->documentService->generateDocx($supervisor);
        $safeName = preg_replace('/[^a-zA-Z0-9_-]/', '_', $supervisor->supervisor_name ?: 'Pendamping');

        return response()->download($path, "Form_Pendamping_{$safeName}.docx")->deleteFileAfterSend(true);
    }

    /**
     * Download PDF file via public token.
     */
    public function downloadPdf(string $token)
    {
        $supervisor = CompetitionSupervisor::where('public_token', $token)->firstOrFail();

        $pdf = $this->documentService->generatePdf($supervisor);
        $safeName = preg_replace('/[^a-zA-Z0-9_-]/', '_', $supervisor->supervisor_name ?: 'Pendamping');

        return $pdf->download("Form_Pendamping_{$safeName}.pdf");
    }
}
