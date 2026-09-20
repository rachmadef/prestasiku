<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreOrganizerRequest;
use App\Models\Organizer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrganizerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Organizer::withCount('competitions');

        if ($request->filled('type')) {
            $query->where('type', $request->input('type'));
        }

        if ($request->filled('verification_status')) {
            $query->where('verification_status', $request->input('verification_status'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('website', 'like', "%{$search}%");
            });
        }

        $organizers = $query->latest()->paginate($request->input('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $organizers,
        ]);
    }

    public function store(StoreOrganizerRequest $request): JsonResponse
    {
        $organizer = Organizer::create($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Penyelenggara berhasil ditambahkan.',
            'data' => $organizer,
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $organizer = Organizer::withCount('competitions')->with('competitions')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $organizer,
        ]);
    }

    public function update(StoreOrganizerRequest $request, int $id): JsonResponse
    {
        $organizer = Organizer::findOrFail($id);
        $organizer->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Data penyelenggara berhasil diperbarui.',
            'data' => $organizer,
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $organizer = Organizer::findOrFail($id);
        $organizer->delete();

        return response()->json([
            'success' => true,
            'message' => 'Penyelenggara berhasil dihapus.',
        ]);
    }
}
