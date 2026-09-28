<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCompetitionFormRequest;
use App\Http\Requests\Admin\StoreCompetitionRequest;
use App\Http\Requests\Admin\VerifyCompetitionRequest;
use App\Models\Competition;
use App\Models\CompetitionEligibility;
use App\Models\CompetitionForm;
use App\Models\CompetitionSource;
use App\Models\FormField;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CompetitionManagementController extends Controller
{
    /**
     * List all competitions for administrative management.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Competition::with(['organizer:id,name', 'category:id,name', 'eligibility']);

        if ($request->filled('verification_status')) {
            $query->where('verification_status', $request->input('verification_status'));
        }

        if ($request->filled('level')) {
            $query->where('level', $request->input('level'));
        }

        if ($request->filled('target_level')) {
            $query->where('target_level', $request->input('target_level'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhereHas('organizer', function ($org) use ($search) {
                        $org->where('name', 'like', "%{$search}%");
                    });
            });
        }

        $competitions = $query->latest()->paginate($request->input('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $competitions,
        ]);
    }

    /**
     * Create a competition with eligibility rules, official sources, and dynamic form.
     */
    public function store(StoreCompetitionRequest $request): JsonResponse
    {
        $validated = $request->validated();

        if (empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['title']) . '-' . Str::random(5);
        }

        DB::beginTransaction();
        try {
            // 1. Create main Competition record
            $competition = Competition::create([
                'organizer_id' => $validated['organizer_id'],
                'category_id' => $validated['category_id'],
                'title' => $validated['title'],
                'slug' => $validated['slug'],
                'level' => $validated['level'],
                'target_level' => $validated['target_level'],
                'description' => $validated['description'],
                'official_website_url' => $validated['official_website_url'] ?? null,
                'registration_url' => $validated['registration_url'] ?? null,
                'guide_book_url' => $validated['guide_book_url'] ?? null,
                'poster_url' => $validated['poster_url'] ?? null,
                'participation_type' => $validated['participation_type'],
                'min_team_members' => $validated['min_team_members'] ?? 1,
                'max_team_members' => $validated['max_team_members'] ?? 1,
                'requires_school_approval' => $validated['requires_school_approval'] ?? true,
                'registration_fee' => $validated['registration_fee'] ?? 0,
                'registration_open_at' => $validated['registration_open_at'],
                'registration_deadline' => $validated['registration_deadline'],
                'event_start_at' => $validated['event_start_at'],
                'event_end_at' => $validated['event_end_at'],
                'verification_status' => $validated['verification_status'] ?? 'draft',
                'visibility' => $validated['visibility'] ?? 'public',
            ]);

            // 2. Create Eligibility Criteria
            $eligibilityData = $validated['eligibility'] ?? [];
            CompetitionEligibility::create([
                'competition_id' => $competition->id,
                'allowed_educational_levels' => $eligibilityData['allowed_educational_levels'] ?? [$validated['target_level']],
                'allowed_grades' => $eligibilityData['allowed_grades'] ?? ($validated['target_level'] === 'sltp' ? [7, 8, 9] : [10, 11, 12]),
                'min_age' => $eligibilityData['min_age'] ?? null,
                'max_age' => $eligibilityData['max_age'] ?? null,
                'allowed_provinces' => $eligibilityData['allowed_provinces'] ?? null,
                'gender_restriction' => $eligibilityData['gender_restriction'] ?? 'any',
                'custom_rules' => $eligibilityData['custom_rules'] ?? null,
            ]);

            // 3. Create Sources if provided
            if (! empty($validated['sources'])) {
                foreach ($validated['sources'] as $source) {
                    CompetitionSource::create([
                        'competition_id' => $competition->id,
                        'source_type' => $source['source_type'],
                        'source_url' => $source['source_url'],
                        'source_title' => $source['source_title'] ?? null,
                        'is_verified' => $source['is_verified'] ?? false,
                        'verified_by' => $source['is_verified'] ?? false ? $request->user()->id : null,
                    ]);
                }
            }

            // 4. Create Initial Dynamic Form if provided
            if (! empty($validated['form'])) {
                $form = CompetitionForm::create([
                    'competition_id' => $competition->id,
                    'title' => $validated['form']['title'] ?? 'Formulir Pendaftaran',
                    'version' => 1,
                    'is_active' => true,
                ]);

                if (! empty($validated['form']['fields'])) {
                    foreach ($validated['form']['fields'] as $order => $field) {
                        FormField::create([
                            'form_id' => $form->id,
                            'label' => $field['label'],
                            'field_key' => $field['field_key'],
                            'field_type' => $field['field_type'],
                            'placeholder' => $field['placeholder'] ?? null,
                            'help_text' => $field['help_text'] ?? null,
                            'is_required' => $field['is_required'] ?? false,
                            'options' => $field['options'] ?? null,
                            'validation_rules' => $field['validation_rules'] ?? null,
                            'conditional_rule' => $field['conditional_rule'] ?? null,
                            'order' => $order,
                        ]);
                    }
                }
            }

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat data kompetisi: ' . $e->getMessage(),
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kompetisi berhasil dibuat.',
            'data' => $competition->load(['organizer', 'category', 'eligibility', 'sources', 'activeForm.fields']),
        ], 201);
    }

    /**
     * Show full administrative details of a competition.
     */
    public function show(int $id): JsonResponse
    {
        $competition = Competition::with([
            'organizer',
            'category',
            'sources',
            'eligibility',
            'forms.fields',
            'verifier:id,name',
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $competition,
        ]);
    }

    /**
     * Update verification status (Verification Pipeline).
     */
    public function verify(VerifyCompetitionRequest $request, int $id): JsonResponse
    {
        $competition = Competition::findOrFail($id);
        $status = $request->input('status');
        $notes = $request->input('verification_notes');
        $visibility = $request->input('visibility', $competition->visibility);

        $updateData = [
            'verification_status' => $status,
            'visibility' => $visibility,
            'verified_by' => $request->user()->id,
            'verified_at' => now(),
            'verification_notes' => $notes ?: $competition->verification_notes,
        ];

        if ($status === 'published' && ! $competition->published_at) {
            $updateData['published_at'] = now();
        }

        $competition->update($updateData);

        return response()->json([
            'success' => true,
            'message' => "Status verifikasi kompetisi berhasil diubah menjadi '{$status}'.",
            'data' => $competition->fresh(['organizer', 'category', 'verifier']),
        ]);
    }

    /**
     * Create a new version of the Dynamic Form for this competition.
     */
    public function storeForm(StoreCompetitionFormRequest $request, int $id): JsonResponse
    {
        $competition = Competition::findOrFail($id);
        $validated = $request->validated();

        DB::beginTransaction();
        try {
            // Deactivate existing forms
            CompetitionForm::where('competition_id', $competition->id)->update(['is_active' => false]);

            $latestVersion = (int) CompetitionForm::where('competition_id', $competition->id)->max('version');
            $newVersion = $latestVersion + 1;

            $form = CompetitionForm::create([
                'competition_id' => $competition->id,
                'title' => $validated['title'],
                'description' => $validated['description'] ?? null,
                'version' => $newVersion,
                'is_active' => true,
            ]);

            foreach ($validated['fields'] as $order => $field) {
                FormField::create([
                    'form_id' => $form->id,
                    'label' => $field['label'],
                    'field_key' => $field['field_key'],
                    'field_type' => $field['field_type'],
                    'placeholder' => $field['placeholder'] ?? null,
                    'help_text' => $field['help_text'] ?? null,
                    'is_required' => $field['is_required'] ?? false,
                    'options' => $field['options'] ?? null,
                    'validation_rules' => $field['validation_rules'] ?? null,
                    'conditional_rule' => $field['conditional_rule'] ?? null,
                    'order' => $field['order'] ?? $order,
                ]);
            }

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat versi formulir baru: ' . $e->getMessage(),
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => "Formulir versi {$newVersion} berhasil dibuat dan diaktifkan.",
            'data' => $form->load('fields'),
        ], 201);
    }

    /**
     * Batch audit and synchronize all competitions using Gemini AI Grounding.
     */
    public function syncAllAI(Request $request, \App\Services\GeminiCompetitionVerifierService $verifier): JsonResponse
    {
        $competitions = Competition::all();
        $updatedCount = 0;

        foreach ($competitions as $c) {
            $res = $verifier->verifyAndUpdate($c);
            if (!empty($res['success'])) {
                $updatedCount++;
            }
        }

        return response()->json([
            'success' => true,
            'message' => "Berhasil memverifikasi dan memperbarui {$updatedCount} data kompetisi secara otomatis menggunakan Gemini AI!",
            'updated_count' => $updatedCount,
        ]);
    }
}
