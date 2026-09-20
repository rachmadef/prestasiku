<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCompetitionCategoryRequest;
use App\Models\CompetitionCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class CompetitionCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = CompetitionCategory::withCount('competitions')->get();

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }

    public function store(StoreCompetitionCategoryRequest $request): JsonResponse
    {
        $validated = $request->validated();
        if (empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $category = CompetitionCategory::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Kategori kompetisi berhasil ditambahkan.',
            'data' => $category,
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $category = CompetitionCategory::withCount('competitions')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $category,
        ]);
    }

    public function update(StoreCompetitionCategoryRequest $request, int $id): JsonResponse
    {
        $category = CompetitionCategory::findOrFail($id);
        $validated = $request->validated();
        if (empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $category->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Kategori kompetisi berhasil diperbarui.',
            'data' => $category,
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $category = CompetitionCategory::findOrFail($id);
        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kategori kompetisi berhasil dihapus.',
        ]);
    }
}
