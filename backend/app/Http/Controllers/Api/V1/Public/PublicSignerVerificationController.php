<?php

namespace App\Http\Controllers\Api\V1\Public;

use App\Http\Controllers\Controller;
use App\Models\SchoolSigner;
use Illuminate\Http\JsonResponse;

class PublicSignerVerificationController extends Controller
{
    /**
     * Publicly verify a teacher/signer's digital signature QR code token.
     */
    public function verify(string $token): JsonResponse
    {
        $signer = SchoolSigner::where('signature_token', $token)
            ->with(['school:id,name,npsn,address,province,city,district,phone,email'])
            ->first();

        if (! $signer) {
            return response()->json([
                'success' => false,
                'is_valid' => false,
                'message' => 'Tanda tangan digital tidak ditemukan atau QR Code tidak terdaftar di sistem PrestasiKu.',
            ], 404);
        }

        $roleLabels = [
            'waka_kesiswaan' => 'Waka Kesiswaan (Wakil Kepala Sekolah Bidang Kesiswaan)',
            'pj_lomba' => 'Guru Penanggung Jawab / Pembina Lomba & Olimpiade',
            'kepala_sekolah' => 'Kepala Sekolah',
            'other' => 'Guru / Pejabat Sekolah Pengesah Surat',
        ];

        $photoUrl = $signer->photo_path ? asset('storage/' . $signer->photo_path) : null;

        $ttlFormatted = null;
        if ($signer->birth_place || $signer->birth_date) {
            $dateStr = $signer->birth_date ? \Carbon\Carbon::parse($signer->birth_date)->translatedFormat('d F Y') : '';
            $ttlFormatted = trim(($signer->birth_place ? $signer->birth_place . ', ' : '') . $dateStr, ', ');
        }

        return response()->json([
            'success' => true,
            'is_valid' => (bool) $signer->is_active,
            'data' => [
                'signer_id' => $signer->id,
                'name' => $signer->name,
                'nip' => $signer->nip ?: 'NIP. Pengesah Resmi Sekolah',
                'position_title' => $signer->position_title,
                'role_type' => $signer->role_type,
                'role_label' => $roleLabels[$signer->role_type] ?? $signer->position_title,
                'photo_url' => $photoUrl,
                'birth_place' => $signer->birth_place,
                'birth_date' => $signer->birth_date ? $signer->birth_date->format('Y-m-d') : null,
                'ttl_formatted' => $ttlFormatted,
                'address' => $signer->address,
                'education_history' => $signer->education_history,
                'biography' => $signer->biography,
                'phone' => $signer->phone,
                'email' => $signer->email,
                'is_active' => (bool) $signer->is_active,
                'signature_token' => $signer->signature_token,
                'registered_at' => $signer->created_at ? $signer->created_at->translatedFormat('d F Y') : null,
                'school' => [
                    'name' => $signer->school->name,
                    'npsn' => $signer->school->npsn,
                    'address' => $signer->school->address,
                    'city' => $signer->school->city,
                    'province' => $signer->school->province,
                    'phone' => $signer->school->phone,
                    'email' => $signer->school->email,
                ],
                'verification_note' => 'Tanda tangan elektronik ini terverifikasi secara resmi di basis data PrestasiKu untuk pengesahan Surat Dispensasi KBM dan Perizinan Lomba.',
            ],
        ]);
    }
}
