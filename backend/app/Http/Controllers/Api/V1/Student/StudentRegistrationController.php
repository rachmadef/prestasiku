<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Student\RegisterCompetitionRequest;
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

class StudentRegistrationController extends Controller
{
    public function __construct(
        protected EligibilityService $eligibilityService
    ) {}

    /**
     * List all registrations for the logged in student.
     */
    public function index(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Profil siswa tidak ditemukan.',
            ], 403);
        }

        $studentId = $student->id;

        $registrations = Registration::where(function ($q) use ($studentId) {
            $q->where('student_id', $studentId)
                ->orWhereHas('team.members', function ($tm) use ($studentId) {
                    $tm->where('student_id', $studentId);
                });
        })
            ->with([
                'competition:id,title,slug,level,target_level,registration_deadline,event_start_at',
                'team:id,team_name',
                'school:id,name',
            ])
            ->latest()
            ->paginate($request->input('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $registrations,
        ]);
    }

    /**
     * Submit competition registration as a student (individual or team).
     */
    public function store(RegisterCompetitionRequest $request): JsonResponse
    {
        $student = $request->user()->student;
        $competition = Competition::with(['eligibility', 'activeForm.fields'])
            ->findOrFail($request->input('competition_id'));

        // 1. Validate competition status & timeline
        if ($competition->verification_status !== 'published') {
            return response()->json([
                'success' => false,
                'message' => 'Kompetisi ini belum dipublikasikan secara resmi.',
            ], 422);
        }

        $now = now();
        if ($now->lt($competition->registration_open_at)) {
            return response()->json([
                'success' => false,
                'message' => 'Pendaftaran untuk kompetisi ini belum dibuka.',
            ], 422);
        }

        if ($now->gt($competition->registration_deadline)) {
            return response()->json([
                'success' => false,
                'message' => 'Periode pendaftaran untuk kompetisi ini telah ditutup.',
            ], 422);
        }

        // 2. Validate current student's eligibility
        $eval = $this->eligibilityService->checkEligibility($student, $competition);
        if (! $eval['is_eligible']) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memenuhi kriteria kelayakan kompetisi ini.',
                'failed_criteria' => $eval['failed_criteria'],
            ], 422);
        }

        $type = $request->input('registration_type');
        $team = null;
        $memberStudents = collect([$student]);

        // 3. Team registration validations
        if ($type === 'team') {
            if ($competition->participation_type === 'individual') {
                return response()->json([
                    'success' => false,
                    'message' => 'Kompetisi ini hanya memperbolehkan pendaftaran individu.',
                ], 422);
            }

            $memberIds = $request->input('team_members', []);
            if (! in_array($student->id, $memberIds)) {
                $memberIds[] = $student->id;
            }

            $totalMembers = count($memberIds);
            if ($totalMembers < $competition->min_team_members || $totalMembers > $competition->max_team_members) {
                return response()->json([
                    'success' => false,
                    'message' => "Jumlah anggota tim harus antara {$competition->min_team_members} s.d. {$competition->max_team_members} orang.",
                ], 422);
            }

            $memberStudents = Student::whereIn('id', $memberIds)->get();

            // Verify all members belong to the same school
            foreach ($memberStudents as $member) {
                if ($member->school_id !== $student->school_id) {
                    return response()->json([
                        'success' => false,
                        'message' => "Siswa '{$member->full_name}' bukan berasal dari sekolah yang sama dengan Anda.",
                    ], 422);
                }

                // Check eligibility for each member
                $memberEval = $this->eligibilityService->checkEligibility($member, $competition);
                if (! $memberEval['is_eligible']) {
                    return response()->json([
                        'success' => false,
                        'message' => "Anggota tim '{$member->full_name}' tidak memenuhi syarat kelayakan.",
                        'failed_criteria' => $memberEval['failed_criteria'],
                    ], 422);
                }
            }
        }

        // 4. Validate active form & required fields
        $activeForm = $competition->activeForm;
        if (! $activeForm) {
            return response()->json([
                'success' => false,
                'message' => 'Formulir pendaftaran belum disiapkan oleh panitia.',
            ], 422);
        }

        $answersInput = collect($request->input('answers', []))->keyBy('field_key');

        foreach ($activeForm->fields as $field) {
            if ($field->is_required && (! $answersInput->has($field->field_key) || empty($answersInput[$field->field_key]['value']))) {
                return response()->json([
                    'success' => false,
                    'message' => "Bidang '{$field->label}' pada formulir wajib diisi.",
                ], 422);
            }
        }

        // 5. Determine approval workflow
        $requiresApproval = $competition->requires_school_approval;
        $status = $requiresApproval ? 'pending_school_approval' : 'submitted';
        $schoolApprovalStatus = $requiresApproval ? 'pending' : 'approved';

        $registration = null;

        DB::beginTransaction();
        try {
            // Create team if applicable
            if ($type === 'team') {
                $team = Team::create([
                    'competition_id' => $competition->id,
                    'school_id' => $student->school_id,
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

            // Create Registration
            $registration = Registration::create([
                'competition_id' => $competition->id,
                'form_version_id' => $activeForm->id,
                'school_id' => $student->school_id,
                'student_id' => $student->id,
                'team_id' => $team?->id,
                'registration_type' => $type,
                'registered_by' => $request->user()->id,
                'status' => $status,
                'school_approval_status' => $schoolApprovalStatus,
            ]);

            // Save Form Answers
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

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal memproses pendaftaran: ' . $e->getMessage(),
            ], 500);
        }

        $message = $requiresApproval
            ? 'Pendaftaran berhasil dikirim. Menunggu persetujuan dan surat tugas dari pihak sekolah.'
            : 'Pendaftaran berhasil dikirim ke penyelenggara lomba.';

        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $registration->load(['competition:id,title', 'team.students', 'answers']),
        ], 201);
    }

    /**
     * Show registration detail for student.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $registration = Registration::with([
            'competition',
            'formVersion.fields',
            'team.students',
            'answers',
            'school',
        ])->findOrFail($id);

        if (! $request->user()->can('view', $registration)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki hak akses ke data pendaftaran ini.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $registration,
        ]);
    }
}
