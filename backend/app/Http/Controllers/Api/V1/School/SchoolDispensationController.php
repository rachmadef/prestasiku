<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Models\KbmDispensation;
use App\Models\Student;
use App\Services\DispensationDocumentService;
use App\Services\DocxTemplateParserService;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class SchoolDispensationController extends Controller
{
    public function __construct(
        protected QrCodeService $qrCodeService,
        protected DispensationDocumentService $documentService,
        protected DocxTemplateParserService $docxParser
    ) {
    }

    /**
     * List all KBM dispensation requests for the school.
     */
    public function index(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah.',
            ], 403);
        }

        $query = KbmDispensation::where('school_id', $school->id)
            ->with([
                'students:id,full_name,nis,class_name',
                'requestedBy:id,name,email',
                'approvedBy:id,name',
                'competition:id,title',
            ]);

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('dispensation_type')) {
            $query->where('dispensation_type', $request->query('dispensation_type'));
        }

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('reference_number', 'like', "%{$search}%")
                    ->orWhere('competition_name', 'like', "%{$search}%")
                    ->orWhere('purpose', 'like', "%{$search}%")
                    ->orWhere('supervisor_name', 'like', "%{$search}%")
                    ->orWhereHas('students', function ($sq) use ($search) {
                        $sq->where('full_name', 'like', "%{$search}%")
                            ->orWhere('nis', 'like', "%{$search}%")
                            ->orWhere('class_name', 'like', "%{$search}%");
                    });
            });
        }

        $dispensations = $query->latest()->paginate($request->query('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $dispensations,
        ]);
    }

    /**
     * Get the school's dispensation custom form schema.
     */
    public function getFormSchema(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah.',
            ], 403);
        }

        $schema = $school->dispensation_form_schema ?? [];

        return response()->json([
            'success' => true,
            'data' => [
                'school_id' => $school->id,
                'school_name' => $school->name,
                'schema' => $schema,
            ],
        ]);
    }

    /**
     * Update the school's dispensation custom form schema.
     */
    public function updateFormSchema(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah.',
            ], 403);
        }

        $validated = $request->validate([
            'schema' => 'nullable|array',
            'schema.*.id' => 'required|string',
            'schema.*.name' => 'required|string|regex:/^[a-zA-Z0-9_]+$/',
            'schema.*.label' => 'required|string|max:255',
            'schema.*.type' => 'required|in:text,textarea,select,number,checkbox,date',
            'schema.*.placeholder' => 'nullable|string|max:255',
            'schema.*.description' => 'nullable|string|max:500',
            'schema.*.options' => 'nullable|array',
            'schema.*.options.*' => 'nullable|string',
            'schema.*.is_required' => 'boolean',
        ]);

        $schemaData = $validated['schema'] ?? [];

        $school->update([
            'dispensation_form_schema' => $schemaData,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengaturan kolom formulir dispensasi sekolah berhasil disimpan.',
            'data' => [
                'school_id' => $school->id,
                'schema' => $schemaData,
            ],
        ]);
    }

    /**
     * Direct creation of KBM dispensation by school admin/kesiswaan.
     */
    public function store(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah.',
            ], 403);
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
            'student_ids' => 'required|array|min:1',
            'student_ids.*' => [
                'required',
                Rule::exists('students', 'id')->where(fn ($q) => $q->where('school_id', $school->id)),
            ],
            'notes' => 'nullable|string|max:255',
            'reference_number' => 'nullable|string|max:100',
            'custom_fields_data' => 'nullable',
        ]);

        $attachmentPath = null;
        if ($request->hasFile('attachment_file')) {
            $attachmentPath = $request->file('attachment_file')->store('dispensations', 'local');
        }

        // Process custom_fields_data (support both JSON string in multipart/form-data and direct array)
        $customFieldsData = null;
        if ($request->has('custom_fields_data')) {
            $rawCustom = $request->input('custom_fields_data');
            $customFieldsData = is_string($rawCustom) ? json_decode($rawCustom, true) : $rawCustom;
        }

        DB::beginTransaction();
        try {
            $dispensation = KbmDispensation::create([
                'school_id' => $school->id,
                'reference_number' => $validated['reference_number'] ?? null,
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
                'status' => 'approved', // Langsung approved jika dibuat oleh admin sekolah
                'requested_by' => $request->user()->id,
                'approved_by' => $request->user()->id,
                'approved_at' => now(),
            ]);

            // Hubungkan siswa
            $pivotData = [];
            foreach ($validated['student_ids'] as $studentId) {
                $pivotData[$studentId] = ['notes' => $validated['notes'] ?? null];
            }
            $dispensation->students()->sync($pivotData);

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menerbitkan surat dispensasi: ' . $e->getMessage(),
            ], 500);
        }

        $dispensation->load(['students:id,full_name,nis,class_name', 'approvedBy:id,name']);

        return response()->json([
            'success' => true,
            'message' => 'Surat perizinan dispensasi KBM berhasil diterbitkan.',
            'data' => $dispensation,
        ], 201);
    }

    /**
     * Show single dispensation detail with QR code.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $school = $request->user()->school;
        $dispensation = KbmDispensation::where('school_id', $school->id)
            ->with([
                'school',
                'students:id,full_name,nis,nisn,class_name,gender',
                'requestedBy:id,name,email',
                'approvedBy:id,name',
                'competition:id,title',
            ])
            ->findOrFail($id);

        $data = $dispensation->toArray();
        $data['verification_url'] = $this->qrCodeService->getDispensationVerificationUrl($dispensation->verification_token);
        $data['qr_code_data_uri'] = $this->qrCodeService->generateDispensationDataUri($dispensation->verification_token, 200);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Approve or reject a student-submitted dispensation request.
     */
    public function review(Request $request, int $id): JsonResponse
    {
        $school = $request->user()->school;
        $dispensation = KbmDispensation::where('school_id', $school->id)->findOrFail($id);

        $validated = $request->validate([
            'action' => ['required', Rule::in(['approve', 'reject'])],
            'rejection_reason' => 'nullable|string',
            'reference_number' => 'nullable|string|max:100',
        ]);

        if ($validated['action'] === 'approve') {
            $referenceNumber = $validated['reference_number'] ?: $dispensation->reference_number;
            if (empty($referenceNumber) || str_starts_with($referenceNumber, 'DISP-')) {
                // Generate nomor surat formal sekolah jika belum ada format khusus
                $year = date('Y');
                $count = KbmDispensation::where('school_id', $school->id)
                    ->whereYear('created_at', $year)
                    ->where('status', 'approved')
                    ->count() + 1;
                $formattedCount = str_pad((string) $count, 3, '0', STR_PAD_LEFT);
                $referenceNumber = "421.3/DISP-KBM/{$school->id}/{$year}/{$formattedCount}";
            }

            $dispensation->update([
                'status' => 'approved',
                'reference_number' => $referenceNumber,
                'approved_by' => $request->user()->id,
                'approved_at' => now(),
                'rejection_reason' => null,
            ]);

            $message = 'Permohonan dispensasi KBM berhasil disetujui.';
        } else {
            $dispensation->update([
                'status' => 'rejected',
                'rejection_reason' => $validated['rejection_reason'] ?? 'Permohonan dispensasi ditolak oleh sekolah.',
                'approved_by' => $request->user()->id,
                'approved_at' => now(),
            ]);

            $message = 'Permohonan dispensasi KBM ditolak.';
        }

        $dispensation->load(['students:id,full_name,nis,class_name', 'approvedBy:id,name']);

        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $dispensation,
        ]);
    }

    /**
     * Get complete printable letter data for generating or rendering official dispensation letter.
     */
    public function printLetter(Request $request, int $id): JsonResponse
    {
        $school = $request->user()->school;
        $dispensation = KbmDispensation::where('school_id', $school->id)
            ->with([
                'school',
                'students:id,full_name,nis,nisn,class_name,gender',
                'approvedBy:id,name',
            ])
            ->findOrFail($id);

        $verificationUrl = $this->qrCodeService->getDispensationVerificationUrl($dispensation->verification_token);
        $qrDataUri = $this->qrCodeService->generateDispensationDataUri($dispensation->verification_token, 180);

        $letterheadImageUrl = null;
        if (! empty($school->letterhead_image_path)) {
            $letterheadImageUrl = Storage::disk('public')->url($school->letterhead_image_path);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'dispensation' => $dispensation,
                'school' => $dispensation->school,
                'students' => $dispensation->students,
                'verification_url' => $verificationUrl,
                'qr_code_data_uri' => $qrDataUri,
                'printed_at' => now()->translatedFormat('d F Y'),
                'form_schema' => $dispensation->school->dispensation_form_schema ?? [],
                'custom_fields_data' => $dispensation->custom_fields_data ?? [],
                'letterhead_type' => $school->letterhead_type ?? 'text',
                'letterhead_image_url' => $letterheadImageUrl,
                'letter_format_config' => $school->letter_format_config ?? [],
                // 2 Kolom Tanda Tangan:
                // Tanda Tangan 1: Guru Pembina Lomba (Otomatis terisi dari supervisor_name)
                // Tanda Tangan 2: Guru Mapel / Guru Piket (Dikosongkan untuk tanda tangan basah di kelas)
                'signatures' => [
                    'pembina' => [
                        'title' => 'Guru Pembina Lomba',
                        'name' => $dispensation->supervisor_name ?: 'Guru Pembina Lomba',
                        'nip' => 'NIP. - / Pembina Prestasi Sekolah',
                    ],
                    'mapel' => [
                        'title' => 'Guru Mata Pelajaran / Guru Piket',
                        'name' => '( .................................................. )',
                        'nip' => 'NIP. ..............................................',
                        'note' => '* Ditandatangani saat jam KBM di kelas',
                    ],
                ],
            ],
        ]);
    }

    /**
     * Get the school's letterhead and dispensation letter template configuration.
     */
    public function getLetterTemplate(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah.',
            ], 403);
        }

        $letterheadImageUrl = null;
        if (! empty($school->letterhead_image_path)) {
            $letterheadImageUrl = Storage::disk('public')->url($school->letterhead_image_path);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'school_id' => $school->id,
                'school_name' => $school->name,
                'letterhead_type' => $school->letterhead_type ?? 'text',
                'letterhead_image_url' => $letterheadImageUrl,
                'letter_format_config' => $school->letter_format_config ?? [
                    'institution_level1' => 'PEMERINTAH DAERAH PROVINSI',
                    'institution_level2' => 'DINAS PENDIDIKAN DAN KEBUDAYAAN',
                    'document_title' => 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)',
                    'reference_number_prefix' => '421.3/DISP-KBM',
                    'closing_text' => 'Demikian surat dispensasi ini dibuat agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa tetap berkewajiban menyelesaikan materi pelajaran serta tugas-tugas yang tertinggal.',
                ],
                'has_custom_docx' => ! empty($school->dispensation_docx_template_path),
                'docx_template_name' => $school->dispensation_docx_template_path ? basename($school->dispensation_docx_template_path) : null,
            ],
        ]);
    }

    /**
     * Upload letterhead image, configure format, or upload custom docx template.
     */
    public function updateLetterTemplate(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah.',
            ], 403);
        }

        $validated = $request->validate([
            'letterhead_type' => 'required|in:image,text',
            'letterhead_image' => 'nullable|file|mimes:png,jpg,jpeg,webp|max:5120',
            'remove_letterhead_image' => 'nullable|boolean',
            'docx_template' => 'nullable|file|mimes:docx|max:10240',
            'remove_docx_template' => 'nullable|boolean',
            'institution_level1' => 'nullable|string|max:255',
            'institution_level2' => 'nullable|string|max:255',
            'document_title' => 'nullable|string|max:255',
            'reference_number_prefix' => 'nullable|string|max:100',
            'closing_text' => 'nullable|string|max:1000',
            'header_width_mode' => 'nullable|string|in:contained,full',
            'header_max_height' => 'nullable|integer|min:30|max:300',
            'header_alignment' => 'nullable|string|in:left,center,right',
            'header_margin_bottom' => 'nullable|integer|min:0|max:100',
        ]);

        $updates = [
            'letterhead_type' => $validated['letterhead_type'],
        ];

        // Handle letterhead image
        if ($request->boolean('remove_letterhead_image')) {
            if ($school->letterhead_image_path) {
                Storage::disk('public')->delete($school->letterhead_image_path);
            }
            $updates['letterhead_image_path'] = null;
        } elseif ($request->hasFile('letterhead_image')) {
            if ($school->letterhead_image_path) {
                Storage::disk('public')->delete($school->letterhead_image_path);
            }
            $path = $request->file('letterhead_image')->store("schools/{$school->id}/letterhead", 'public');
            $updates['letterhead_image_path'] = $path;
            $updates['letterhead_type'] = 'image';
        }

        // Handle custom DOCX template
        if ($request->boolean('remove_docx_template')) {
            if ($school->dispensation_docx_template_path) {
                Storage::disk('public')->delete($school->dispensation_docx_template_path);
            }
            $updates['dispensation_docx_template_path'] = null;
        } elseif ($request->hasFile('docx_template')) {
            if ($school->dispensation_docx_template_path) {
                Storage::disk('public')->delete($school->dispensation_docx_template_path);
            }
            $path = $request->file('docx_template')->store("schools/{$school->id}/templates", 'public');
            $updates['dispensation_docx_template_path'] = $path;
        }

        // Handle letter format configuration
        $config = $school->letter_format_config ?? [];
        $config['institution_level1'] = $validated['institution_level1'] ?? ($config['institution_level1'] ?? 'PEMERINTAH DAERAH PROVINSI');
        $config['institution_level2'] = $validated['institution_level2'] ?? ($config['institution_level2'] ?? 'DINAS PENDIDIKAN DAN KEBUDAYAAN');
        $config['document_title'] = $validated['document_title'] ?? ($config['document_title'] ?? 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)');
        $config['reference_number_prefix'] = $validated['reference_number_prefix'] ?? ($config['reference_number_prefix'] ?? '421.3/DISP-KBM');
        $config['closing_text'] = $validated['closing_text'] ?? ($config['closing_text'] ?? 'Demikian surat dispensasi ini dibuat agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya.');
        $config['header_width_mode'] = $request->input('header_width_mode', $config['header_width_mode'] ?? 'contained');
        $config['header_max_height'] = (int) $request->input('header_max_height', $config['header_max_height'] ?? 130);
        $config['header_alignment'] = $request->input('header_alignment', $config['header_alignment'] ?? 'center');
        $config['header_margin_bottom'] = (int) $request->input('header_margin_bottom', $config['header_margin_bottom'] ?? 10);
        $updates['letter_format_config'] = $config;

        $school->update($updates);

        $letterheadImageUrl = $school->letterhead_image_path ? Storage::disk('public')->url($school->letterhead_image_path) : null;

        return response()->json([
            'success' => true,
            'message' => 'Format surat dan kop sekolah berhasil diperbarui.',
            'data' => [
                'letterhead_type' => $school->letterhead_type,
                'letterhead_image_url' => $letterheadImageUrl,
                'letter_format_config' => $school->letter_format_config,
                'has_custom_docx' => ! empty($school->dispensation_docx_template_path),
                'docx_template_name' => $school->dispensation_docx_template_path ? basename($school->dispensation_docx_template_path) : null,
            ],
        ]);
    }

    /**
     * Download dispensation as Microsoft Word (.docx) file.
     */
    public function downloadDocx(Request $request, int $id)
    {
        $school = $request->user()->school;
        $dispensation = KbmDispensation::where('school_id', $school->id)
            ->with(['school', 'students', 'approvedBy'])
            ->findOrFail($id);

        if ($dispensation->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Surat dispensasi belum disetujui, belum dapat diunduh.',
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
                'message' => 'Gagal menghasilkan dokumen DOCX: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Download dispensation as PDF file.
     */
    public function downloadPdf(Request $request, int $id)
    {
        $school = $request->user()->school;
        $dispensation = KbmDispensation::where('school_id', $school->id)
            ->with(['school', 'students', 'approvedBy'])
            ->findOrFail($id);

        if ($dispensation->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Surat dispensasi belum disetujui, belum dapat diunduh.',
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
                'message' => 'Gagal menghasilkan dokumen PDF: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Parse uploaded DOCX file and auto-generate form schema for KBM Dispensations.
     */
    public function parseDocxSchema(Request $request): JsonResponse
    {
        $request->validate([
            'docx_file' => ['required', 'file', 'mimes:docx', 'max:5120'],
        ]);

        $file = $request->file('docx_file');
        $extractedSchema = $this->docxParser->parseVariablesFromDocx($file->getRealPath());

        return response()->json([
            'success' => true,
            'message' => 'Berhasil memindai file DOCX. ' . count($extractedSchema) . ' kolom variabel terdeteksi secara otomatis.',
            'data' => [
                'extracted_schema' => $extractedSchema,
                'count' => count($extractedSchema),
            ],
        ]);
    }
}
