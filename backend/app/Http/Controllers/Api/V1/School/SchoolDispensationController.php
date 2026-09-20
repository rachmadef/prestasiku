<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Models\KbmDispensation;
use App\Models\Student;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class SchoolDispensationController extends Controller
{
    public function __construct(protected QrCodeService $qrCodeService)
    {
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
        ]);

        $attachmentPath = null;
        if ($request->hasFile('attachment_file')) {
            $attachmentPath = $request->file('attachment_file')->store('dispensations', 'local');
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

        return response()->json([
            'success' => true,
            'data' => [
                'dispensation' => $dispensation,
                'school' => $dispensation->school,
                'students' => $dispensation->students,
                'verification_url' => $verificationUrl,
                'qr_code_data_uri' => $qrDataUri,
                'printed_at' => now()->translatedFormat('d F Y'),
            ],
        ]);
    }
}
