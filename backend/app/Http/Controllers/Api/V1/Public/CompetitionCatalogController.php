<?php

namespace App\Http\Controllers\Api\V1\Public;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\CompetitionCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class CompetitionCatalogController extends Controller
{
    /**
     * Browse published competitions with filters and search.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Competition::published()
            ->with([
                'organizer:id,name,type,verification_status',
                'category:id,name,slug,icon',
                'eligibility:id,competition_id,allowed_educational_levels,allowed_grades,allowed_provinces,gender_restriction',
            ]);

        // Timeline / Registration Status filter: open, not_started, completed, etc.
        $timeline = $request->input('timeline', $request->input('registration_status'));
        if ($timeline === 'open') {
            $query->registrationOpen();
        } elseif ($timeline === 'not_started' || $timeline === 'not_open') {
            $query->registrationNotStarted();
        } elseif ($timeline === 'completed' || $timeline === 'ended' || $timeline === 'past') {
            $query->completed();
        } elseif ($timeline === 'upcoming' || $request->boolean('upcoming') || $request->input('upcoming') === '1') {
            $query->upcoming();
        } elseif ($timeline === 'this_month') {
            $query->thisMonth();
        } elseif ($timeline === 'next_month') {
            $query->nextMonth();
        }

        // Level filter: provinsi or nasional (support both scope and level)
        $level = $request->input('scope', $request->input('level'));
        if (!empty($level)) {
            $query->where('level', $level);
        }

        // Target education level: sltp or slta (support both educational_level and target_level)
        $target = $request->input('educational_level', $request->input('target_level'));
        if (!empty($target)) {
            $query->where(function ($q) use ($target) {
                $q->where('target_level', $target)->orWhere('target_level', 'both');
            });
        }

        // Curation Type filter: resmi_negara, terkurasi_puspresnas, bergengsi_non_kurasi
        if ($request->filled('curation_type') && Schema::hasColumn('competitions', 'curation_type')) {
            $query->where('curation_type', $request->input('curation_type'));
        }

        // Category filter
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->input('category_id'));
        } elseif ($request->filled('category_slug')) {
            $slug = $request->input('category_slug');
            $query->whereHas('category', function ($q) use ($slug) {
                $q->where('slug', $slug);
            });
        }

        // Keyword Search (support both q and search)
        $search = $request->input('q', $request->input('search'));
        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhereHas('category', function ($catQ) use ($search) {
                        $catQ->where('name', 'like', "%{$search}%");
                    })
                    ->orWhereHas('organizer', function ($orgQ) use ($search) {
                        $orgQ->where('name', 'like', "%{$search}%");
                    });
            });
        }

        $competitions = $query->orderBy('registration_deadline', 'asc')
            ->paginate($request->input('per_page', 12));

        return response()->json([
            'success' => true,
            'data' => $competitions,
        ]);
    }

    /**
     * Show detail of a published competition.
     */
    public function show(string $slug): JsonResponse
    {
        $competition = Competition::where('slug', $slug)
            ->published()
            ->with([
                'organizer',
                'category',
                'sources' => function ($q) {
                    $q->where('is_verified', true);
                },
                'eligibility',
                'activeForm.fields',
            ])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $competition,
        ]);
    }

    /**
     * List all competition categories with active counts.
     */
    public function categories(): JsonResponse
    {
        $categories = CompetitionCategory::withCount([
            'competitions' => function ($q) {
                $q->published();
            },
        ])->get();

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }

    /**
     * Get competition counts and meta for the 3 curation groups:
     * 1. Resmi Negara
     * 2. Terkurasi Puspresnas
     * 3. Bergengsi Non-Terkurasi
     */
    public function curationGroups(Request $request): JsonResponse
    {
        $query = Competition::published();

        $target = $request->input('educational_level', $request->input('target_level'));
        if (!empty($target)) {
            $query->where(function ($q) use ($target) {
                $q->where('target_level', $target)->orWhere('target_level', 'both');
            });
        }

        $total = (clone $query)->count();

        $counts = collect();
        if (Schema::hasColumn('competitions', 'curation_type')) {
            $counts = (clone $query)
                ->selectRaw("curation_type, count(*) as count")
                ->groupBy('curation_type')
                ->pluck('count', 'curation_type');
        } else {
            $counts = collect(['resmi_negara' => $total]);
        }

        $groups = [
            [
                'key' => 'resmi_negara',
                'title' => 'Resmi Negara',
                'subtitle' => 'Ajang resmi berjenjang yang digelar pemerintah dan terkurasi Puspresnas.',
                'badge' => 'Pemerintah & BPTI',
                'icon' => 'fa-shield-halved',
                'theme' => 'blue',
                'count' => (int) ($counts['resmi_negara'] ?? 0),
            ],
            [
                'key' => 'terkurasi_puspresnas',
                'title' => 'Terkurasi Puspresnas',
                'subtitle' => 'Sudah lolos kurasi Puspresnas lewat SIMT. Punya rating kurasi dan rincian cabangnya.',
                'badge' => 'SIMT Terakreditasi',
                'icon' => 'fa-circle-check',
                'theme' => 'amber',
                'count' => (int) ($counts['terkurasi_puspresnas'] ?? 0),
            ],
            [
                'key' => 'bergengsi_non_kurasi',
                'title' => 'Bergengsi Non-Terkurasi',
                'subtitle' => 'Belum masuk kurasi Puspresnas. Tetap berguna sebagai pengalaman dan pelengkap portofolio.',
                'badge' => 'Kredibel & Portofolio',
                'icon' => 'fa-star',
                'theme' => 'purple',
                'count' => (int) ($counts['bergengsi_non_kurasi'] ?? 0),
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'total' => $total,
                'groups' => $groups,
            ],
        ]);
    }

    /**
     * Perform live Gemini AI ground verification and link audit for a competition.
     */
    public function aiVerify(int $id, \App\Services\GeminiCompetitionVerifierService $verifier): JsonResponse
    {
        $competition = Competition::with(['organizer', 'category', 'sources'])->findOrFail($id);

        $result = $verifier->verifyAndUpdate($competition);

        return response()->json($result);
    }

    /**
     * Get platform stats (students, achievements, competitions).
     */
    public function stats(): JsonResponse
    {
        $totalStudents = \App\Models\Student::count();
        $totalAchievements = \App\Models\Achievement::count();
        $totalCompetitions = Competition::published()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_students' => $totalStudents,
                'total_achievements' => $totalAchievements,
                'total_competitions' => $totalCompetitions,
            ],
        ]);
    }
}
