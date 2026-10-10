<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\HeroSlider;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HeroSliderController extends Controller
{
    /**
     * Get active hero sliders for public landing page.
     */
    public function publicIndex(): JsonResponse
    {
        $sliders = HeroSlider::where('is_active', true)
            ->orderBy('order', 'asc')
            ->orderBy('id', 'desc')
            ->get();

        // Fallback default slider if none exists
        if ($sliders->isEmpty()) {
            $sliders = collect([
                [
                    'id' => 0,
                    'title' => 'Juara 1 KSN Matematika & Sains 2026',
                    'student_name' => 'Achmad Azam & Tim Prestasi',
                    'caption' => 'Portofolio Prestasi Resmi MA Unggulan K.H. Abd. Wahab Hasbulloh',
                    'image_url' => '/img/hero-illustration.webp',
                    'is_active' => true,
                    'order' => 0,
                ]
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $sliders,
        ]);
    }

    /**
     * Get all hero sliders for Super Admin management.
     */
    public function adminIndex(Request $request): JsonResponse
    {
        $sliders = HeroSlider::orderBy('order', 'asc')
            ->orderBy('id', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $sliders,
        ]);
    }

    /**
     * Store new hero slider.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'student_name' => 'nullable|string|max:255',
            'caption' => 'nullable|string|max:255',
            'image_file' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:5120',
            'image_path' => 'nullable|string|max:500',
            'order' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
        ]);

        $imagePath = $validated['image_path'] ?? '/img/hero-illustration.webp';

        if ($request->hasFile('image_file')) {
            $file = $request->file('image_file');
            $imagePath = $file->store('hero_sliders', 'public');
        }

        $slider = HeroSlider::create([
            'title' => $validated['title'],
            'student_name' => $validated['student_name'] ?? null,
            'caption' => $validated['caption'] ?? null,
            'image_path' => $imagePath,
            'order' => $validated['order'] ?? 0,
            'is_active' => $request->boolean('is_active', true),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Foto juara hero berhasil ditambahkan!',
            'data' => $slider,
        ], 201);
    }

    /**
     * Update existing hero slider.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $slider = HeroSlider::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'student_name' => 'nullable|string|max:255',
            'caption' => 'nullable|string|max:255',
            'image_file' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:5120',
            'image_path' => 'nullable|string|max:500',
            'order' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
        ]);

        if ($request->hasFile('image_file')) {
            // Delete old file if stored locally
            if ($slider->image_path && !str_starts_with($slider->image_path, '/img/')) {
                Storage::disk('public')->delete($slider->image_path);
            }
            $file = $request->file('image_file');
            $slider->image_path = $file->store('hero_sliders', 'public');
        } elseif (!empty($validated['image_path'])) {
            $slider->image_path = $validated['image_path'];
        }

        $slider->title = $validated['title'];
        $slider->student_name = $validated['student_name'] ?? null;
        $slider->caption = $validated['caption'] ?? null;
        if (isset($validated['order'])) {
            $slider->order = $validated['order'];
        }
        if ($request->has('is_active')) {
            $slider->is_active = $request->boolean('is_active');
        }

        $slider->save();

        return response()->json([
            'success' => true,
            'message' => 'Foto juara hero berhasil diperbarui!',
            'data' => $slider,
        ]);
    }

    /**
     * Toggle slider active status.
     */
    public function toggleActive(int $id): JsonResponse
    {
        $slider = HeroSlider::findOrFail($id);
        $slider->is_active = !$slider->is_active;
        $slider->save();

        return response()->json([
            'success' => true,
            'message' => 'Status aktif foto slider berhasil diubah.',
            'data' => $slider,
        ]);
    }

    /**
     * Delete hero slider.
     */
    public function destroy(int $id): JsonResponse
    {
        $slider = HeroSlider::findOrFail($id);
        if ($slider->image_path && !str_starts_with($slider->image_path, '/img/')) {
            Storage::disk('public')->delete($slider->image_path);
        }
        $slider->delete();

        return response()->json([
            'success' => true,
            'message' => 'Foto slider berhasil dihapus.',
        ]);
    }
}
