<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Http\Requests\School\StoreSchoolAchievementRequest;
use App\Http\Requests\School\VerifyAchievementRequest;
use App\Models\Achievement;
use App\Models\Student;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class SchoolAchievementController extends Controller
{
    public function __construct(protected QrCodeService $qrCodeService)
    {
    }

    /**
     * List all achievements within the school.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $schoolId = $user->isSuperAdmin()
            ? $request->query('school_id')
            : $user->school_id;

        $query = Achievement::with([
            'student.user:id,name,email',
            'competition:id,title,level',
            'documents',
            'verifiedBy:id,name',
        ]);

        if ($schoolId) {
            $query->where('school_id', $schoolId);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('level')) {
            $query->where('level', $request->query('level'));
        }

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('event_name', 'like', "%{$search}%")
                    ->orWhereHas('student.user', function ($uq) use ($search) {
                        $uq->where('name', 'like', "%{$search}%");
                    })
                    ->orWhereHas('student', function ($sq) use ($search) {
                        $sq->where('nis', 'like', "%{$search}%")
                            ->orWhere('nisn', 'like', "%{$search}%");
                    });
            });
        }

        $achievements = $query->latest()->paginate($request->query('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $achievements,
        ]);
    }

    /**
     * Directly create a verified (or pending) achievement by school administrator.
     */
    public function store(StoreSchoolAchievementRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();
        $student = Student::findOrFail($validated['student_id']);

        $status = $validated['status'] ?? 'verified';
        $isVerified = $status === 'verified';

        $achievement = Achievement::create([
            'student_id' => $student->id,
            'school_id' => $student->school_id,
            'competition_id' => $validated['competition_id'] ?? null,
            'registration_id' => $validated['registration_id'] ?? null,
            'title' => $validated['title'],
            'level' => $validated['level'],
            'rank' => $validated['rank'],
            'event_name' => $validated['event_name'],
            'organizer_name' => $validated['organizer_name'],
            'event_date' => $validated['event_date'],
            'status' => $status,
            'verified_by' => $isVerified ? $user->id : null,
            'verified_at' => $isVerified ? now() : null,
            'is_public' => $validated['is_public'] ?? false,
        ]);

        if ($request->hasFile('certificate_file')) {
            $file = $request->file('certificate_file');
            $fileName = $file->getClientOriginalName();
            $path = $file->store("achievements/{$achievement->id}", 'local');

            $achievement->documents()->create([
                'document_type' => $validated['document_type'] ?? 'certificate',
                'document_number' => $validated['document_number'] ?? null,
                'file_path' => $path,
                'external_url' => $validated['external_url'] ?? null,
                'file_name' => $fileName,
                'file_size' => $file->getSize(),
                'file_mime' => $file->getMimeType(),
            ]);
        } elseif (! empty($validated['external_url'])) {
            $achievement->documents()->create([
                'document_type' => $validated['document_type'] ?? 'result_link',
                'document_number' => $validated['document_number'] ?? null,
                'external_url' => $validated['external_url'],
            ]);
        }

        $achievement->load(['student.user', 'competition', 'documents']);

        return response()->json([
            'success' => true,
            'message' => 'Prestasi siswa berhasil dicatat oleh sekolah.',
            'data' => $achievement,
        ], 201);
    }

    /**
     * Show detail of an achievement for school admin.
     */
    public function show(Achievement $achievement): JsonResponse
    {
        Gate::authorize('view', $achievement);

        $achievement->load([
            'student.user',
            'school',
            'competition',
            'documents',
            'verifiedBy:id,name',
        ]);

        $data = $achievement->toArray();
        if ($achievement->status === 'verified') {
            $data['qr_code_data_uri'] = $this->qrCodeService->generateDataUri($achievement->public_id, 250);
            $data['verification_url'] = $this->qrCodeService->getVerificationUrl($achievement->public_id);
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Verify or reject an achievement submitted by student.
     */
    public function verify(VerifyAchievementRequest $request, Achievement $achievement): JsonResponse
    {
        Gate::authorize('verify', $achievement);

        $validated = $request->validated();
        $isVerified = $validated['status'] === 'verified';

        $achievement->update([
            'status' => $validated['status'],
            'verification_notes' => $validated['verification_notes'] ?? null,
            'verified_by' => $request->user()->id,
            'verified_at' => $isVerified ? now() : null,
        ]);

        $achievement->load(['student.user', 'documents', 'verifiedBy:id,name']);

        $data = $achievement->toArray();
        if ($isVerified) {
            $data['qr_code_data_uri'] = $this->qrCodeService->generateDataUri($achievement->public_id, 250);
            $data['verification_url'] = $this->qrCodeService->getVerificationUrl($achievement->public_id);
        }

        $statusLabel = $isVerified ? 'disetujui (terverifikasi resmi)' : 'ditolak';

        return response()->json([
            'success' => true,
            'message' => "Prestasi siswa berhasil {$statusLabel}.",
            'data' => $data,
        ]);
    }

    /**
     * Securely download or stream an achievement document.
     */
    public function downloadDocument(Achievement $achievement, int $documentId): StreamedResponse|JsonResponse
    {
        Gate::authorize('view', $achievement);

        $document = $achievement->documents()->findOrFail($documentId);

        if (! $document->file_path || ! Storage::disk('local')->exists($document->file_path)) {
            return response()->json([
                'success' => false,
                'message' => 'Berkas fisik tidak ditemukan di penyimpanan server.',
            ], 404);
        }

        return Storage::disk('local')->download($document->file_path, $document->file_name ?? 'dokumen_prestasi.pdf');
    }
}
