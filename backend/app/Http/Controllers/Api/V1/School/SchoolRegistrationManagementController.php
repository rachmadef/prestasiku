<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Http\Requests\School\SchoolDirectRegistrationRequest;
use App\Http\Requests\School\SchoolReviewRegistrationRequest;
use App\Models\Competition;
use App\Models\Registration;
use App\Models\RegistrationAnswer;
use App\Models\Student;
use App\Models\Team;
use App\Models\TeamMember;
use App\Services\EligibilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SchoolRegistrationManagementController extends Controller
{
    public function __construct(
        protected EligibilityService $eligibilityService
    ) {}

    /**
     * List all registrations belonging to the authenticated school.
     */
    public function index(Request $request): JsonResponse
    {
        $school = $request->user()->school;

        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah manapun.',
            ], 403);
        }

        $query = Registration::where('school_id', $school->id)
            ->with([
                'competition:id,title,level,target_level,registration_deadline,event_start_at',
                'student:id,full_name,nis,class_name',
                'team:id,team_name',
                'registeredBy:id,name,email',
            ]);

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->filled('school_approval_status')) {
            $query->where('school_approval_status', $request->input('school_approval_status'));
        }

        if ($request->filled('competition_id')) {
            $query->where('competition_id', $request->input('competition_id'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('registration_code', 'like', "%{$search}%")
                    ->orWhereHas('student', function ($sq) use ($search) {
                        $sq->where('full_name', 'like', "%{$search}%")
                            ->orWhere('nis', 'like', "%{$search}%");
                    })
                    ->orWhereHas('team', function ($tq) use ($search) {
                        $tq->where('team_name', 'like', "%{$search}%");
                    });
            });
        }

        $registrations = $query->latest()->paginate($request->input('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $registrations,
        ]);
    }

    /**
     * Show registration detail for school admin review.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $registration = Registration::with([
            'competition',
            'student',
            'team.students',
            'answers.field',
            'approvedBy:id,name',
            'registeredBy:id,name,email',
        ])->findOrFail($id);

        if (! $request->user()->can('view', $registration)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki hak akses ke data pendaftaran sekolah lain.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $registration,
        ]);
    }

    /**
     * Approve or reject a student registration for competition delegation.
     */
    public function review(SchoolReviewRegistrationRequest $request, int $id): JsonResponse
    {
        $registration = Registration::findOrFail($id);

        if (! $request->user()->can('review', $registration)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki otorisasi untuk meninjau pendaftaran ini.',
            ], 403);
        }

        $action = $request->input('action');
        $notes = $request->input('notes');

        if ($action === 'approve') {
            $letterFile = $registration->assignment_letter_file;
            if ($request->hasFile('assignment_letter_file')) {
                $letterFile = $request->file('assignment_letter_file')->store('assignment_letters', 'local');
            }

            $registration->update([
                'status' => 'approved_by_school',
                'school_approval_status' => 'approved',
                'school_approved_by' => $request->user()->id,
                'school_approved_at' => now(),
                'school_notes' => $notes,
                'assignment_letter_number' => $request->input('assignment_letter_number') ?: $registration->assignment_letter_number,
                'assignment_letter_file' => $letterFile,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pendaftaran delegasi siswa berhasil disetujui.',
                'data' => $registration->fresh(['student', 'team', 'competition:id,title']),
            ]);
        }

        // Action: Reject
        $registration->update([
            'status' => 'rejected_by_school',
            'school_approval_status' => 'rejected',
            'school_approved_by' => $request->user()->id,
            'school_approved_at' => now(),
            'school_notes' => $notes,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran delegasi siswa ditolak.',
            'data' => $registration->fresh(['student', 'team']),
        ]);
    }

    /**
     * Direct registration by school admin (auto-approved delegation).
     */
    public function directRegister(SchoolDirectRegistrationRequest $request): JsonResponse
    {
        $school = $request->user()->school;
        $competition = Competition::with(['eligibility', 'activeForm.fields'])
            ->findOrFail($request->input('competition_id'));

        $type = $request->input('registration_type');
        $team = null;
        $student = null;
        $memberStudents = collect();

        if ($type === 'individual') {
            $student = Student::where('school_id', $school->id)->findOrFail($request->input('student_id'));

            $eval = $this->eligibilityService->checkEligibility($student, $competition);
            if (! $eval['is_eligible']) {
                return response()->json([
                    'success' => false,
                    'message' => "Siswa '{$student->full_name}' tidak memenuhi syarat kelayakan lomba.",
                    'failed_criteria' => $eval['failed_criteria'],
                ], 422);
            }
        } else {
            // Team
            $leaderId = $request->input('leader_student_id');
            $memberIds = $request->input('team_members', []);
            if (! in_array($leaderId, $memberIds)) {
                $memberIds[] = $leaderId;
            }

            $memberStudents = Student::where('school_id', $school->id)
                ->whereIn('id', $memberIds)
                ->get();

            if ($memberStudents->count() !== count($memberIds)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Beberapa siswa yang dipilih tidak terdaftar di sekolah Anda.',
                ], 422);
            }

            foreach ($memberStudents as $m) {
                $mEval = $this->eligibilityService->checkEligibility($m, $competition);
                if (! $mEval['is_eligible']) {
                    return response()->json([
                        'success' => false,
                        'message' => "Anggota tim '{$m->full_name}' tidak memenuhi syarat kelayakan.",
                        'failed_criteria' => $mEval['failed_criteria'],
                    ], 422);
                }
            }

            $student = $memberStudents->firstWhere('id', $leaderId);
        }

        $activeForm = $competition->activeForm;
        if (! $activeForm) {
            $activeForm = CompetitionForm::firstOrCreate(
                ['competition_id' => $competition->id, 'version' => 1],
                ['title' => 'Formulir Pendaftaran', 'is_active' => true]
            );
        }
        $answersInput = collect($request->input('answers', []))->keyBy('field_key');

        $letterFile = null;
        if ($request->hasFile('assignment_letter_file')) {
            $letterFile = $request->file('assignment_letter_file')->store('assignment_letters', 'local');
        }

        $registration = null;

        DB::beginTransaction();
        try {
            if ($type === 'team') {
                $team = Team::create([
                    'competition_id' => $competition->id,
                    'school_id' => $school->id,
                    'team_name' => $request->input('team_name'),
                    'leader_student_id' => $student->id,
                    'created_by' => $request->user()->id,
                ]);

                foreach ($memberStudents as $m) {
                    TeamMember::create([
                        'team_id' => $team->id,
                        'student_id' => $m->id,
                        'role_in_team' => $m->id === $student->id ? 'leader' : 'member',
                    ]);
                }
            }

            $registration = Registration::create([
                'competition_id' => $competition->id,
                'form_version_id' => $activeForm ? $activeForm->id : 1,
                'school_id' => $school->id,
                'student_id' => $student->id,
                'team_id' => $team?->id,
                'registration_type' => $type,
                'registered_by' => $request->user()->id,
                'status' => 'approved_by_school',
                'school_approval_status' => 'approved',
                'school_approved_by' => $request->user()->id,
                'school_approved_at' => now(),
                'assignment_letter_number' => $request->input('assignment_letter_number'),
                'assignment_letter_file' => $letterFile,
            ]);

            if ($activeForm) {
                foreach ($activeForm->fields as $field) {
                    if ($answersInput->has($field->field_key)) {
                        $rawVal = $answersInput[$field->field_key]['value'] ?? null;
                        $answerVal = is_array($rawVal) ? json_encode($rawVal) : (string) $rawVal;

                        RegistrationAnswer::create([
                            'registration_id' => $registration->id,
                            'form_field_id' => $field->id,
                            'field_key' => $field->field_key,
                            'field_label' => $field->label,
                            'answer_value' => $answerVal,
                        ]);
                    }
                }
            }

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal mendaftarkan delegasi: ' . $e->getMessage(),
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Delegasi sekolah berhasil didaftarkan dan berstatus terverifikasi sekolah.',
            'data' => $registration->load(['competition:id,title', 'student:id,full_name', 'team.students']),
        ], 201);
    }

    /**
     * Record competition result (participant/kalah, finalist, winner) and upload certificate.
     */
    public function recordResult(Request $request, int $id): JsonResponse
    {
        $school = $request->user()->school;
        $registration = Registration::where('school_id', $school->id)
            ->with(['student.user', 'competition'])
            ->findOrFail($id);

        $validated = $request->validate([
            'result_status' => 'required|in:participant,finalist,winner',
            'rank_details' => 'required|string|max:100', // e.g. "Peserta", "Juara 1", "Finalis"
            'result_notes' => 'nullable|string',
            'certificate_file' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        $certificatePath = $registration->certificate_file;
        if ($request->hasFile('certificate_file')) {
            $certificatePath = $request->file('certificate_file')->store('participation_certificates', 'local');
        }

        $registration->update([
            'result_status' => $validated['result_status'],
            'rank_details' => $validated['rank_details'],
            'result_notes' => $validated['result_notes'] ?? null,
            'certificate_file' => $certificatePath,
            'result_recorded_at' => now(),
            'status' => 'confirmed',
        ]);

        // If winner, also record in achievements table for official verified achievement record
        if ($validated['result_status'] === 'winner' && $registration->student_id) {
            $achievement = \App\Models\Achievement::firstOrNew([
                'registration_id' => $registration->id,
            ]);

            $achievement->fill([
                'student_id' => $registration->student_id,
                'school_id' => $registration->school_id,
                'competition_id' => $registration->competition_id,
                'title' => "{$validated['rank_details']} - {$registration->competition->title}",
                'level' => $registration->competition->level ?? 'nasional',
                'rank' => $validated['rank_details'],
                'event_name' => $registration->competition->title,
                'organizer_name' => $registration->competition->organizer?->name ?? 'Penyelenggara Lomba',
                'event_date' => $registration->competition->event_start_at ?? now(),
                'status' => 'verified',
                'verified_by' => $request->user()->id,
                'verified_at' => now(),
                'is_public' => true,
            ]);
            $achievement->save();

            if ($certificatePath) {
                $achievement->documents()->create([
                    'document_type' => 'certificate',
                    'file_path' => $certificatePath,
                    'file_name' => "Sertifikat-{$validated['rank_details']}.pdf",
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Hasil lomba dan arsip sertifikat keikutsertaan siswa berhasil didokumentasikan.',
            'data' => $registration->fresh(['student', 'team', 'competition:id,title']),
        ]);
    }

    /**
     * Download participation or winner certificate.
     */
    public function downloadCertificate(Request $request, int $id)
    {
        $school = $request->user()->school;
        $registration = Registration::where('school_id', $school->id)->findOrFail($id);

        if (! $registration->certificate_file || ! \Illuminate\Support\Facades\Storage::disk('local')->exists($registration->certificate_file)) {
            return response()->json([
                'success' => false,
                'message' => 'Berkas sertifikat tidak ditemukan di server.',
            ], 404);
        }

        return \Illuminate\Support\Facades\Storage::disk('local')->download($registration->certificate_file);
    }
}

