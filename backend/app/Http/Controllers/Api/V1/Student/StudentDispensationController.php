<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Models\KbmDispensation;
use App\Models\Student;
use App\Services\DispensationDocumentService;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class StudentDispensationController extends Controller
{
    public function __construct(
        protected QrCodeService $qrCodeService,
        protected DispensationDocumentService $documentService
    ) {
    }

    /**
     * Get list of dispensations involving the authenticated student.
     */
    public function index(Request $request): JsonResponse
    {
        $student = $request->user()->student;
        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil siswa tidak ditemukan.',
            ], 404);
        }

        $dispensations = KbmDispensation::whereHas('students', function ($q) use ($student) {
            $q->where('students.id', $student->id);
        })
            ->orWhere('requested_by', $request->user()->id)
            ->with([
                'students:id,full_name,nis,class_name',
                'approvedBy:id,name',
                'competition:id,title',
            ])
            ->latest()
            ->paginate($request->query('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $dispensations,
        ]);
    }

    /**
     * Get the student's school dispensation custom form schema.
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
        $schema = $school ? ($school->dispensation_form_schema ?? []) : [];

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
     * Submit a new KBM dispensation request by student.
     */
    public function store(Request $request): JsonResponse
    {
        $student = $request->user()->student;
        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil siswa tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'competition_name' => 'required|string|max:255',
            'competition_id' => 'nullable|exists:competitions,id',
            'dispensation_type' => ['required', Rule::in(['persiapan_latihan', 'pelaksanaan_lomba', 'lainnya'])],
            'purpose' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'start_time' => 'nullable|string',
            'end_time' => 'nullable|string',
            'is_all_day' => 'boolean',
            'supervisor_name' => 'nullable|string|max:255',
            'attachment_file' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'additional_student_ids' => 'nullable|array',
            'additional_student_ids.*' => [
                Rule::exists('students', 'id')->where(fn ($q) => $q->where('school_id', $student->school_id)),
            ],
            'notes' => 'nullable|string|max:255',
            'custom_fields_data' => 'nullable',
        ]);

        $attachmentPath = null;
        if ($request->hasFile('attachment_file')) {
            $attachmentPath = $request->file('attachment_file')->store('dispensations', 'local');
        }

        // Process custom_fields_data (support JSON string in multipart/form-data or direct array)
        $customFieldsData = null;
        if ($request->has('custom_fields_data')) {
            $rawCustom = $request->input('custom_fields_data');
            $customFieldsData = is_string($rawCustom) ? json_decode($rawCustom, true) : $rawCustom;
        }

        DB::beginTransaction();
        try {
            $dispensation = KbmDispensation::create([
                'school_id' => $student->school_id,
                'competition_id' => $validated['competition_id'] ?? null,
                'competition_name' => $validated['competition_name'],
                'dispensation_type' => $validated['dispensation_type'],
                'purpose' => $validated['purpose'],
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'start_time' => $validated['start_time'] ?? null,
                'end_time' => $validated['end_time'] ?? null,
                'is_all_day' => $request->boolean('is_all_day', true),
                'supervisor_name' => $validated['supervisor_name'] ?? null,
                'attachment_path' => $attachmentPath,
                'custom_fields_data' => $customFieldsData,
                'status' => 'pending',
                'requested_by' => $request->user()->id,
            ]);

            // Selalu masukkan siswa pemohon
            $allStudentIds = collect([$student->id]);
            if (! empty($validated['additional_student_ids'])) {
                $allStudentIds = $allStudentIds->merge($validated['additional_student_ids'])->unique();
            }

            $pivotData = [];
            foreach ($allStudentIds as $id) {
                $pivotData[$id] = ['notes' => $validated['notes'] ?? null];
            }
            $dispensation->students()->sync($pivotData);

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengajukan dispensasi: ' . $e->getMessage(),
            ], 500);
        }

        $dispensation->load(['students:id,full_name,nis,class_name']);

        return response()->json([
            'success' => true,
            'message' => 'Permohonan dispensasi KBM berhasil diajukan dan sedang menunggu persetujuan sekolah.',
            'data' => $dispensation,
        ], 201);
    }

    /**
     * Show detail of student dispensation request.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;
        $dispensation = KbmDispensation::where(function ($q) use ($student, $request) {
            $q->whereHas('students', fn ($sq) => $sq->where('students.id', $student->id))
                ->orWhere('requested_by', $request->user()->id);
        })
            ->with([
                'school:id,name,address,phone,email',
                'students:id,full_name,nis,nisn,class_name',
                'approvedBy:id,name',
                'competition:id,title',
            ])
            ->findOrFail($id);

        $data = $dispensation->toArray();
        if ($dispensation->status === 'approved') {
            $data['verification_url'] = $this->qrCodeService->getDispensationVerificationUrl($dispensation->verification_token);
            $data['qr_code_data_uri'] = $this->qrCodeService->generateDispensationDataUri($dispensation->verification_token, 200);
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Download student approved dispensation as DOCX.
     */
    public function downloadDocx(Request $request, int $id)
    {
        $student = $request->user()->student;
        $dispensation = KbmDispensation::where(function ($q) use ($student, $request) {
            $q->whereHas('students', fn ($sq) => $sq->where('students.id', $student->id))
                ->orWhere('requested_by', $request->user()->id);
        })
            ->with(['school', 'students', 'approvedBy'])
            ->findOrFail($id);

        if ($dispensation->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Surat perizinan belum disahkan oleh sekolah.',
            ], 422);
        }

        try {
            $filePath = $this->documentService->generateDocx($dispensation);
            $safeRef = preg_replace('/[^a-zA-Z0-9_-]/', '_', $dispensation->reference_number ?: 'DISP');
            $downloadName = "Surat_Dispensasi_{$safeRef}.docx";

            return response()->download($filePath, $downloadName, [
                'Content-Type' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            ])->deleteFileAfterSend(true);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengunduh dokumen DOCX: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Download student approved dispensation as PDF.
     */
    public function downloadPdf(Request $request, int $id)
    {
        $student = $request->user()->student;
        $dispensation = KbmDispensation::where(function ($q) use ($student, $request) {
            $q->whereHas('students', fn ($sq) => $sq->where('students.id', $student->id))
                ->orWhere('requested_by', $request->user()->id);
        })
            ->with(['school', 'students', 'approvedBy'])
            ->findOrFail($id);

        if ($dispensation->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Surat perizinan belum disahkan oleh sekolah.',
            ], 422);
        }

        try {
            $pdf = $this->documentService->generatePdf($dispensation);
            $safeRef = preg_replace('/[^a-zA-Z0-9_-]/', '_', $dispensation->reference_number ?: 'DISP');
            $downloadName = "Surat_Dispensasi_{$safeRef}.pdf";

            return $pdf->download($downloadName);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengunduh dokumen PDF: ' . $e->getMessage(),
            ], 500);
        }
    }
}
