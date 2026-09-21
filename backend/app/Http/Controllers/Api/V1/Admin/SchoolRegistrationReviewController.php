<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ReviewSchoolRegistrationRequest;
use App\Mail\SchoolAdminAccountCreatedMail;
use App\Models\School;
use App\Models\SchoolRegistration;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class SchoolRegistrationReviewController extends Controller
{
    /**
     * List all submitted school registrations.
     */
    public function index(Request $request): JsonResponse
    {
        $query = SchoolRegistration::with('reviewer:id,name');

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('school_name', 'like', "%{$search}%")
                    ->orWhere('npsn', 'like', "%{$search}%")
                    ->orWhere('pic_name', 'like', "%{$search}%")
                    ->orWhere('pic_email', 'like', "%{$search}%");
            });
        }

        $registrations = $query->latest()->paginate($request->input('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $registrations,
        ]);
    }

    /**
     * Show detail of a single school registration.
     */
    public function show(int $id): JsonResponse
    {
        $registration = SchoolRegistration::with('reviewer:id,name')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $registration,
        ]);
    }

    /**
     * Approve or reject a school registration.
     */
    public function review(ReviewSchoolRegistrationRequest $request, int $id): JsonResponse
    {
        $registration = SchoolRegistration::findOrFail($id);

        if ($registration->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => "Pengajuan ini sudah berstatus '{$registration->status}' dan tidak dapat diproses ulang.",
            ], 400);
        }

        $action = $request->input('action');
        $notes = $request->input('review_notes');
        $reviewer = $request->user();

        if ($action === 'reject') {
            $registration->update([
                'status' => 'rejected',
                'reviewed_by' => $reviewer->id,
                'reviewed_at' => now(),
                'review_notes' => $notes,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan pendaftaran sekolah berhasil ditolak.',
                'data' => $registration->fresh(),
            ]);
        }

        // Action: Approve
        // 1. Ensure school with NPSN doesn't already exist
        if (School::where('npsn', $registration->npsn)->exists()) {
            return response()->json([
                'success' => false,
                'message' => "Sekolah dengan NPSN {$registration->npsn} sudah terdaftar di sistem.",
            ], 422);
        }

        $temporaryPassword = $request->input('admin_password') ?: 'password123';
        $adminUser = null;
        $school = null;

        DB::beginTransaction();
        try {
            // 2. Create School tenant
            $school = School::create([
                'npsn' => $registration->npsn,
                'name' => $registration->school_name,
                'educational_level' => $registration->educational_level,
                'status' => 'verified',
                'province' => $registration->province,
                'city' => $registration->city,
                'district' => $registration->district,
                'address' => $registration->address,
                'email' => $registration->pic_email,
                'phone' => $registration->pic_phone,
                'verified_at' => now(),
                'verified_by' => $reviewer->id,
                'verification_notes' => $notes ?: 'Pendaftaran mandiri disetujui oleh Super Admin.',
            ]);

            // 3. Create or assign School Admin user
            $adminUsername = 'admin_' . $registration->npsn;
            $adminEmail = $registration->pic_email;

            // Handle email collision if needed
            if (User::where('email', $adminEmail)->exists()) {
                $adminEmail = 'admin.' . $registration->npsn . '@prestasiku.id';
            }

            $adminUser = User::create([
                'name' => $registration->pic_name,
                'email' => $adminEmail,
                'username' => $adminUsername,
                'phone' => $registration->pic_phone,
                'school_id' => $school->id,
                'password' => Hash::make($temporaryPassword),
                'must_change_password' => false,
                'status' => 'active',
            ]);
            $adminUser->assignRole('school_admin');

            // 4. Update registration status
            $registration->update([
                'status' => 'approved',
                'reviewed_by' => $reviewer->id,
                'reviewed_at' => now(),
                'review_notes' => $notes,
            ]);

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal menyetujui pendaftaran sekolah: ' . $e->getMessage(),
            ], 500);
        }

        // 5. Send automated account credential email to PIC
        try {
            Mail::to($adminEmail)->send(new SchoolAdminAccountCreatedMail(
                school: $school,
                registration: $registration,
                adminUser: $adminUser,
                temporaryPassword: $temporaryPassword
            ));
        } catch (\Throwable $mailErr) {
            Log::warning('Gagal mengirim email kredensial akun sekolah ke PIC: ' . $mailErr->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran sekolah berhasil disetujui. Akun Admin Sekolah telah dibuat.',
            'data' => [
                'registration' => $registration->fresh(),
                'school' => $school,
                'admin_account' => [
                    'id' => $adminUser->id,
                    'name' => $adminUser->name,
                    'email' => $adminUser->email,
                    'username' => $adminUser->username,
                    'temporary_password' => $temporaryPassword,
                ],
            ],
        ]);
    }
}
