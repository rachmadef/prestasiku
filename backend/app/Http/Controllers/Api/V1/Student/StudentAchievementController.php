<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Student\StoreAchievementRequest;
use App\Models\Achievement;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class StudentAchievementController extends Controller
{
    public function __construct(protected QrCodeService $qrCodeService)
    {
    }

    /**
     * List all achievements submitted by the authenticated student.
     */
    public function index(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Profil siswa tidak ditemukan.',
            ], 404);
        }

        $query = Achievement::with(['competition:id,title,level', 'documents'])
            ->where('student_id', $student->id);

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
                    ->orWhere('rank', 'like', "%{$search}%");
            });
        }

        $achievements = $query->latest()->paginate($request->query('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $achievements,
        ]);
    }

    /**
     * Submit a new achievement for verification by the school.
     */
    public function store(StoreAchievementRequest $request): JsonResponse
    {
        $student = $request->user()->student;

        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Profil siswa tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validated();

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
            'status' => 'pending_verification',
            'is_public' => $validated['is_public'] ?? false,
        ]);

        // Handle uploaded file if present
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

        $achievement->load(['competition', 'documents']);

        return response()->json([
            'success' => true,
            'message' => 'Prestasi berhasil dicatat dan menunggu verifikasi pihak sekolah.',
            'data' => $achievement,
        ], 201);
    }

    /**
     * Show detail of an achievement.
     */
    public function show(Achievement $achievement): JsonResponse
    {
        Gate::authorize('view', $achievement);

        $achievement->load([
            'school:id,name,npsn,educational_level',
            'competition:id,title,level',
            'documents',
            'verifiedBy:id,name',
        ]);

        $data = $achievement->toArray();
        if ($achievement->status === 'verified') {
            $data['qr_code_data_uri'] = $this->qrCodeService->generateDataUri($achievement->public_id, 200);
            $data['verification_url'] = $this->qrCodeService->getVerificationUrl($achievement->public_id);
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Toggle public visibility of student name on public verification.
     */
    public function togglePublic(Achievement $achievement): JsonResponse
    {
        Gate::authorize('togglePublic', $achievement);

        $achievement->update([
            'is_public' => ! $achievement->is_public,
        ]);

        return response()->json([
            'success' => true,
            'message' => $achievement->is_public
                ? 'Nama lengkap Anda kini ditampilkan secara publik pada verifikasi QR.'
                : 'Nama lengkap Anda kini disamarkan secara anonim pada verifikasi QR demi privasi.',
            'data' => [
                'id' => $achievement->id,
                'public_id' => $achievement->public_id,
                'is_public' => $achievement->is_public,
            ],
        ]);
    }

    /**
     * Delete achievement if still in draft or pending.
     */
    public function destroy(Achievement $achievement): JsonResponse
    {
        Gate::authorize('delete', $achievement);

        // Delete associated files from private storage
        foreach ($achievement->documents as $doc) {
            if ($doc->file_path && Storage::disk('local')->exists($doc->file_path)) {
                Storage::disk('local')->delete($doc->file_path);
            }
        }

        $achievement->delete();

        return response()->json([
            'success' => true,
            'message' => 'Prestasi berhasil dihapus.',
        ]);
    }
}
