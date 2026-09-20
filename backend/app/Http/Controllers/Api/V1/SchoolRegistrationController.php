<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\School\RegisterSchoolRequest;
use App\Models\SchoolRegistration;
use Illuminate\Http\JsonResponse;

class SchoolRegistrationController extends Controller
{
    /**
     * Handle incoming public school self-registration.
     */
    public function register(RegisterSchoolRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $documentPath = null;

        if ($request->hasFile('document')) {
            $documentPath = $request->file('document')->store('school_registrations', 'local');
        }

        $registration = SchoolRegistration::create([
            'npsn' => $validated['npsn'],
            'school_name' => $validated['school_name'],
            'educational_level' => $validated['educational_level'],
            'province' => $validated['province'],
            'city' => $validated['city'],
            'district' => $validated['district'] ?? null,
            'address' => $validated['address'] ?? null,
            'pic_name' => $validated['pic_name'],
            'pic_email' => $validated['pic_email'],
            'pic_phone' => $validated['pic_phone'],
            'pic_position' => $validated['pic_position'],
            'document_path' => $documentPath,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran instansi sekolah berhasil diajukan. Mohon menunggu proses verifikasi oleh Super Admin.',
            'data' => [
                'id' => $registration->id,
                'npsn' => $registration->npsn,
                'school_name' => $registration->school_name,
                'status' => $registration->status,
                'submitted_at' => $registration->created_at,
            ],
        ], 201);
    }
}
