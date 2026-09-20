<?php

namespace App\Http\Controllers\Api\V1\Public;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\CompetitionCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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

        // Timeline filter: this_month or next_month
        if ($request->input('timeline') === 'this_month') {
            $query->thisMonth();
        } elseif ($request->input('timeline') === 'next_month') {
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
}
