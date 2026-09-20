<?php

namespace App\Http\Controllers\Api\V1\Public;

use App\Http\Controllers\Controller;
use App\Models\Achievement;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class PublicVerificationController extends Controller
{
    public function __construct(protected QrCodeService $qrCodeService)
    {
    }

    /**
     * Public verification endpoint for student achievement.
     * Privacy-by-default: Sensitive PII (NISN, phone, address) is NEVER exposed.
     * Student name is masked unless student/school explicitly enables is_public.
     */
    public function verify(string $publicId): JsonResponse
    {
        $achievement = Achievement::with([
            'school:id,name,npsn,educational_level,city,province',
            'competition:id,title,level,organizer_id',
            'competition.organizer:id,name',
            'student.user:id,name',
            'documents',
        ])
            ->where('public_id', $publicId)
            ->where('status', 'verified')
            ->first();

        if (! $achievement) {
            return response()->json([
                'success' => false,
                'message' => 'Prestasi tidak ditemukan atau belum diverifikasi resmi oleh pihak sekolah.',
            ], 404);
        }

        $isPublic = (bool) $achievement->is_public;
        $studentName = $isPublic
            ? ($achievement->student?->user?->name ?? 'Siswa')
            : $achievement->getMaskedStudentName();

        $verificationUrl = $this->qrCodeService->getVerificationUrl($achievement->public_id);
        $qrCodeApiUrl = url("/api/v1/verify/{$achievement->public_id}/qr");

        return response()->json([
            'success' => true,
            'data' => [
                'public_id' => $achievement->public_id,
                'student_name' => $studentName,
                'is_name_masked' => ! $isPublic,
                'school' => [
                    'name' => $achievement->school?->name,
                    'npsn' => $achievement->school?->npsn,
                    'educational_level' => $achievement->school?->educational_level,
                    'city' => $achievement->school?->city,
                    'province' => $achievement->school?->province,
                ],
                'competition' => $achievement->competition ? [
                    'id' => $achievement->competition->id,
                    'title' => $achievement->competition->title,
                    'organizer_name' => $achievement->competition->organizer?->name ?? $achievement->organizer_name,
                    'level' => $achievement->competition->level,
                ] : null,
                'achievement' => [
                    'title' => $achievement->title,
                    'level' => $achievement->level,
                    'rank' => $achievement->rank,
                    'event_name' => $achievement->event_name,
                    'organizer_name' => $achievement->organizer_name,
                    'event_date' => $achievement->event_date?->format('Y-m-d'),
                    'verified_at' => $achievement->verified_at?->toIso8601String(),
                ],
                'documents' => $achievement->documents->map(function ($doc) {
                    return [
                        'document_type' => $doc->document_type,
                        'document_number' => $doc->document_number,
                    ];
                }),
                'verification' => [
                    'status' => 'VALID_OFFICIAL_ACHIEVEMENT',
                    'verified_by_school' => $achievement->school?->name,
                    'verification_url' => $verificationUrl,
                    'qr_code_url' => $qrCodeApiUrl,
                ],
            ],
        ]);
    }

    /**
     * Direct SVG QR Code endpoint.
     */
    public function qr(string $publicId): Response
    {
        $achievement = Achievement::where('public_id', $publicId)
            ->where('status', 'verified')
            ->firstOrFail();

        $svg = $this->qrCodeService->generateSvg($achievement->public_id, 300);

        return response($svg, 200, [
            'Content-Type' => 'image/svg+xml',
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }
}
