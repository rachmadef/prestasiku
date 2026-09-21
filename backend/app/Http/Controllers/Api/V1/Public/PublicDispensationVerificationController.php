<?php

namespace App\Http\Controllers\Api\V1\Public;

use App\Http\Controllers\Controller;
use App\Models\KbmDispensation;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;

class PublicDispensationVerificationController extends Controller
{
    /**
     * Verify KBM dispensation token for teachers/school staff via QR code scan.
     */
    public function verify(string $token): JsonResponse
    {
        $dispensation = KbmDispensation::where('verification_token', $token)
            ->with([
                'school:id,name,npsn,address,phone,email',
                'students:id,full_name,nis,class_name,gender',
                'approvedBy:id,name',
            ])
            ->first();

        if (! $dispensation) {
            return response()->json([
                'success' => false,
                'is_valid' => false,
                'message' => 'Surat dispensasi tidak ditemukan atau kode QR tidak valid.',
            ], 404);
        }

        $today = Carbon::today();
        $startDate = Carbon::parse($dispensation->start_date);
        $endDate = Carbon::parse($dispensation->end_date);

        $isActiveNow = false;
        $periodStatus = 'upcoming'; // upcoming | active | completed

        if ($today->lt($startDate)) {
            $periodStatus = 'upcoming';
        } elseif ($today->gt($endDate)) {
            $periodStatus = 'completed';
        } else {
            $periodStatus = 'active';
            $isActiveNow = true;
        }

        $isApproved = $dispensation->status === 'approved';

        return response()->json([
            'success' => true,
            'is_valid' => $isApproved,
            'data' => [
                'reference_number' => $dispensation->reference_number,
                'school_name' => $dispensation->school->name,
                'competition_name' => $dispensation->competition_name,
                'dispensation_type' => $dispensation->dispensation_type,
                'purpose' => $dispensation->purpose,
                'start_date' => $dispensation->start_date->format('Y-m-d'),
                'end_date' => $dispensation->end_date->format('Y-m-d'),
                'is_all_day' => $dispensation->is_all_day,
                'start_time' => $dispensation->start_time,
                'end_time' => $dispensation->end_time,
                'supervisor_name' => $dispensation->supervisor_name,
                'status' => $dispensation->status,
                'is_active_today' => $isActiveNow && $isApproved,
                'period_status' => $periodStatus,
                'approved_by' => $dispensation->approvedBy?->name ?? 'Pihak Sekolah',
                'approved_at' => $dispensation->approved_at?->translatedFormat('d F Y H:i'),
                'students' => $dispensation->students->map(fn ($s) => [
                    'full_name' => $s->full_name,
                    'class_name' => $s->class_name,
                    'nis' => $s->nis,
                ]),
                'custom_fields_data' => $dispensation->custom_fields_data ?? [],
                'form_schema' => $dispensation->school->dispensation_form_schema ?? [],
            ],
        ]);
    }
}
