<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Models\SchoolSigner;
use App\Services\QrCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class SchoolSignerController extends Controller
{
    public function __construct(protected QrCodeService $qrCodeService)
    {
    }

    /**
     * Get list of signers/teachers for the logged-in school admin.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user();
        $schoolId = $user->school_id;

        $query = SchoolSigner::where('school_id', $schoolId);

        if ($request->filled('role_type')) {
            $query->where('role_type', $request->role_type);
        }

        if ($request->filled('is_active')) {
            $query->where('is_active', filter_var($request->is_active, FILTER_VALIDATE_BOOLEAN));
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('nip', 'like', "%{$search}%")
                  ->orWhere('position_title', 'like', "%{$search}%");
            });
        }

        $signers = $query->orderBy('role_type')->latest()->get()->map(function ($signer) {
            $signer->qr_code_url = $this->qrCodeService->getSignerVerificationUrl($signer->signature_token);
            $signer->qr_code_data_uri = $this->qrCodeService->generateSignerDataUri($signer->signature_token, 200);
            return $signer;
        });

        return response()->json([
            'success' => true,
            'data' => $signers,
        ]);
    }

    /**
     * Store a new school signer.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'nip' => ['nullable', 'string', 'max:50'],
            'position_title' => ['required', 'string', 'max:150'],
            'role_type' => ['required', 'string', 'in:waka_kesiswaan,pj_lomba,kepala_sekolah,other'],
            'birth_place' => ['nullable', 'string', 'max:100'],
            'birth_date' => ['nullable', 'date'],
            'address' => ['nullable', 'string'],
            'education_history' => ['nullable', 'string'],
            'biography' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'is_active' => ['sometimes', 'boolean'],
            'photo' => ['nullable', 'image', 'max:5120'], // Max 5MB photo
        ]);

        $user = Auth::user();
        $schoolId = $user->school_id;

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('signers/photos', 'public');
        }

        $signer = SchoolSigner::create([
            'school_id' => $schoolId,
            'name' => $validated['name'],
            'nip' => $validated['nip'] ?? null,
            'position_title' => $validated['position_title'],
            'role_type' => $validated['role_type'],
            'birth_place' => $validated['birth_place'] ?? null,
            'birth_date' => $validated['birth_date'] ?? null,
            'address' => $validated['address'] ?? null,
            'education_history' => $validated['education_history'] ?? null,
            'biography' => $validated['biography'] ?? null,
            'photo_path' => $photoPath,
            'phone' => $validated['phone'] ?? null,
            'email' => $validated['email'] ?? null,
            'is_active' => $validated['is_active'] ?? true,
            'signature_token' => Str::random(40),
        ]);

        $signer->qr_code_url = $this->qrCodeService->getSignerVerificationUrl($signer->signature_token);
        $signer->qr_code_data_uri = $this->qrCodeService->generateSignerDataUri($signer->signature_token, 200);

        return response()->json([
            'success' => true,
            'message' => 'Guru Penandatangan (Signer) berhasil ditambahkan.',
            'data' => $signer,
        ], 201);
    }

    /**
     * Show detail of a signer with QR Code.
     */
    public function show(int $id): JsonResponse
    {
        $user = Auth::user();
        $signer = SchoolSigner::where('school_id', $user->school_id)->findOrFail($id);

        $signer->qr_code_url = $this->qrCodeService->getSignerVerificationUrl($signer->signature_token);
        $signer->qr_code_data_uri = $this->qrCodeService->generateSignerDataUri($signer->signature_token, 200);

        return response()->json([
            'success' => true,
            'data' => $signer,
        ]);
    }

    /**
     * Update signer details.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $user = Auth::user();
        $signer = SchoolSigner::where('school_id', $user->school_id)->findOrFail($id);

        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'nip' => ['nullable', 'string', 'max:50'],
            'position_title' => ['sometimes', 'required', 'string', 'max:150'],
            'role_type' => ['sometimes', 'required', 'string', 'in:waka_kesiswaan,pj_lomba,kepala_sekolah,other'],
            'birth_place' => ['nullable', 'string', 'max:100'],
            'birth_date' => ['nullable', 'date'],
            'address' => ['nullable', 'string'],
            'education_history' => ['nullable', 'string'],
            'biography' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'is_active' => ['sometimes', 'boolean'],
            'photo' => ['nullable', 'image', 'max:5120'],
        ]);

        if ($request->hasFile('photo')) {
            $validated['photo_path'] = $request->file('photo')->store('signers/photos', 'public');
        }

        $signer->update($validated);

        $signer->qr_code_url = $this->qrCodeService->getSignerVerificationUrl($signer->signature_token);
        $signer->qr_code_data_uri = $this->qrCodeService->generateSignerDataUri($signer->signature_token, 200);

        return response()->json([
            'success' => true,
            'message' => 'Data Guru Penandatangan berhasil diperbarui.',
            'data' => $signer,
        ]);
    }

    /**
     * Delete a signer.
     */
    public function destroy(int $id): JsonResponse
    {
        $user = Auth::user();
        $signer = SchoolSigner::where('school_id', $user->school_id)->findOrFail($id);
        $signer->delete();

        return response()->json([
            'success' => true,
            'message' => 'Guru Penandatangan telah dihapus.',
        ]);
    }

    /**
     * Generate / return QR Code data URI for a signer.
     */
    public function qr(int $id): JsonResponse
    {
        $user = Auth::user();
        $signer = SchoolSigner::where('school_id', $user->school_id)->findOrFail($id);

        $dataUri = $this->qrCodeService->generateSignerDataUri($signer->signature_token, 300);
        $verificationUrl = $this->qrCodeService->getSignerVerificationUrl($signer->signature_token);

        return response()->json([
            'success' => true,
            'data' => [
                'signer_id' => $signer->id,
                'name' => $signer->name,
                'position_title' => $signer->position_title,
                'verification_url' => $verificationUrl,
                'qr_code_data_uri' => $dataUri,
            ],
        ]);
    }
}
