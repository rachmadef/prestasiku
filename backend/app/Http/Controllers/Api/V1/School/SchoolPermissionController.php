<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Http\Controllers\Controller;
use App\Models\CompetitionPermission;
use App\Services\DocxTemplateParserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SchoolPermissionController extends Controller
{
    public function __construct(
        protected DocxTemplateParserService $docxParser
    ) {}

    /**
     * List all competition permission requests.
     */
    public function index(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        if (!$school) {
            return response()->json(['success' => false, 'message' => 'Akun tidak terikat sekolah.'], 403);
        }

        $query = CompetitionPermission::where('school_id', $school->id)
            ->with(['student:id,full_name,nis,class_name', 'requestedBy:id,name', 'approvedBy:id,name']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('reference_number', 'like', "%{$search}%")
                  ->orWhere('competition_name', 'like', "%{$search}%")
                  ->orWhere('purpose', 'like', "%{$search}%")
                  ->orWhereHas('student', function ($sq) use ($search) {
                      $sq->where('full_name', 'like', "%{$search}%")
                        ->orWhere('nis', 'like', "%{$search}%");
                  });
            });
        }

        $permissions = $query->latest()->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $permissions,
        ]);
    }

    /**
     * Get form schema for Surat Perizinan Mengikuti Lomba.
     */
    public function getFormSchema(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        return response()->json([
            'success' => true,
            'data' => [
                'school_id' => $school->id,
                'school_name' => $school->name,
                'schema' => $school->permission_form_schema ?? [],
            ],
        ]);
    }

    /**
     * Update form schema for Surat Perizinan Mengikuti Lomba.
     */
    public function updateFormSchema(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        $validated = $request->validate([
            'schema' => ['required', 'array'],
        ]);

        $school->update([
            'permission_form_schema' => $validated['schema'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengaturan formulir perizinan lomba berhasil disimpan.',
            'data' => ['schema' => $school->permission_form_schema],
        ]);
    }

    /**
     * Parse uploaded DOCX file and auto-generate form schema for Surat Perizinan.
     */
    public function parseDocxSchema(Request $request): JsonResponse
    {
        $request->validate([
            'docx_file' => ['required', 'file', 'mimes:docx', 'max:5120'],
        ]);

        $file = $request->file('docx_file');
        $extractedSchema = $this->docxParser->parseVariablesFromDocx($file->getRealPath());

        return response()->json([
            'success' => true,
            'message' => 'Berhasil memindai file DOCX. ' . count($extractedSchema) . ' kolom variabel terdeteksi secara otomatis.',
            'data' => [
                'extracted_schema' => $extractedSchema,
                'count' => count($extractedSchema),
            ],
        ]);
    }

    /**
     * Get letter format template & DOCX settings for Surat Perizinan.
     */
    public function getLetterTemplate(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        return response()->json([
            'success' => true,
            'data' => [
                'letterhead_type' => $school->letterhead_type,
                'letterhead_image_url' => $school->letterhead_image_path ? Storage::disk('public')->url($school->letterhead_image_path) : null,
                'permission_letter_format_config' => $school->permission_letter_format_config ?? [
                    'institution_level1' => 'PEMERINTAH DAERAH PROVINSI',
                    'institution_level2' => 'DINAS PENDIDIKAN DAN KEBUDAYAAN',
                    'document_title' => 'SURAT REKOMENDASI & PERIZINAN MENGIKUTI LOMBA',
                    'reference_number_prefix' => '421.3/IZIN-LOMBA',
                    'closing_text' => 'Demikian surat perizinan mengikuti lomba ini diterbitkan untuk dipergunakan sebagaimana mestinya.',
                ],
                'has_custom_docx' => !empty($school->permission_docx_template_path),
                'docx_template_name' => $school->permission_docx_template_path ? basename($school->permission_docx_template_path) : null,
            ],
        ]);
    }

    /**
     * Update letter template & DOCX file for Surat Perizinan.
     */
    public function updateLetterTemplate(Request $request): JsonResponse
    {
        $school = $request->user()->school;
        $updates = [];

        if ($request->boolean('remove_docx_template')) {
            if ($school->permission_docx_template_path) {
                Storage::disk('public')->delete($school->permission_docx_template_path);
            }
            $updates['permission_docx_template_path'] = null;
        } elseif ($request->hasFile('docx_template')) {
            if ($school->permission_docx_template_path) {
                Storage::disk('public')->delete($school->permission_docx_template_path);
            }
            $path = $request->file('docx_template')->store("schools/{$school->id}/permission_templates", 'public');
            $updates['permission_docx_template_path'] = $path;
        }

        $config = $school->permission_letter_format_config ?? [];
        $config['institution_level1'] = $request->input('institution_level1', $config['institution_level1'] ?? 'PEMERINTAH DAERAH PROVINSI');
        $config['institution_level2'] = $request->input('institution_level2', $config['institution_level2'] ?? 'DINAS PENDIDIKAN DAN KEBUDAYAAN');
        $config['document_title'] = $request->input('document_title', $config['document_title'] ?? 'SURAT REKOMENDASI & PERIZINAN MENGIKUTI LOMBA');
        $config['reference_number_prefix'] = $request->input('reference_number_prefix', $config['reference_number_prefix'] ?? '421.3/IZIN-LOMBA');
        $config['closing_text'] = $request->input('closing_text', $config['closing_text'] ?? 'Demikian surat perizinan mengikuti lomba ini diterbitkan.');
        $config['header_width_mode'] = $request->input('header_width_mode', $config['header_width_mode'] ?? 'contained');
        $config['header_max_height'] = (int) $request->input('header_max_height', $config['header_max_height'] ?? 130);
        $config['header_alignment'] = $request->input('header_alignment', $config['header_alignment'] ?? 'center');
        $config['header_margin_bottom'] = (int) $request->input('header_margin_bottom', $config['header_margin_bottom'] ?? 10);

        $updates['permission_letter_format_config'] = $config;
        $school->update($updates);

        return response()->json([
            'success' => true,
            'message' => 'Format surat perizinan lomba berhasil diperbarui.',
            'data' => [
                'permission_letter_format_config' => $school->permission_letter_format_config,
                'has_custom_docx' => !empty($school->permission_docx_template_path),
                'docx_template_name' => $school->permission_docx_template_path ? basename($school->permission_docx_template_path) : null,
            ],
        ]);
    }

    /**
     * Store new competition permission request.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $school = $user->school;

        $validated = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'competition_name' => ['required', 'string', 'max:255'],
            'competition_level' => ['required', 'in:kabupaten,provinsi,nasional,internasional'],
            'news_url' => ['nullable', 'url', 'max:500'],
            'purpose' => ['nullable', 'string'],
            'event_start_date' => ['required', 'date'],
            'event_end_date' => ['required', 'date', 'after_or_equal:event_start_date'],
            'parent_name' => ['nullable', 'string', 'max:255'],
            'custom_fields_data' => ['nullable', 'array'],
        ]);

        $permission = CompetitionPermission::create([
            'school_id' => $school->id,
            'student_id' => $validated['student_id'],
            'competition_name' => $validated['competition_name'],
            'competition_level' => $validated['competition_level'],
            'news_url' => $validated['news_url'] ?? null,
            'purpose' => $validated['purpose'] ?? null,
            'event_start_date' => $validated['event_start_date'],
            'event_end_date' => $validated['event_end_date'],
            'parent_name' => $validated['parent_name'] ?? null,
            'status' => 'approved',
            'custom_fields_data' => $validated['custom_fields_data'] ?? [],
            'requested_by' => $user->id,
            'approved_by' => $user->id,
            'approved_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Surat perizinan mengikuti lomba berhasil diterbitkan secara resmi.',
            'data' => $permission->load('student'),
        ], 201);
    }
}
