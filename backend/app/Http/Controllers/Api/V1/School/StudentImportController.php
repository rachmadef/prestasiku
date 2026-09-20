<?php

namespace App\Http\Controllers\Api\V1\School;

use App\Exports\StudentTemplateExport;
use App\Http\Controllers\Controller;
use App\Http\Requests\School\ImportStudentRequest;
use App\Imports\StudentsImport;
use App\Models\ImportRecord;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class StudentImportController extends Controller
{
    /**
     * Download Excel template for student bulk import.
     */
    public function downloadTemplate(): BinaryFileResponse
    {
        return Excel::download(new StudentTemplateExport, 'template_import_siswa_prestasiku.xlsx');
    }

    /**
     * Upload and execute Excel/CSV bulk student import.
     */
    public function import(ImportStudentRequest $request): JsonResponse
    {
        $school = $request->user()->school;

        if (! $school) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak terikat dengan instansi sekolah manapun.',
            ], 403);
        }

        $file = $request->file('file');
        $originalName = $file->getClientOriginalName();
        $storedPath = $file->store('imports/students', 'local');

        $importer = new StudentsImport($school, $request->user());

        try {
            Excel::import($importer, $file);
        } catch (\Throwable $e) {
            ImportRecord::create([
                'school_id' => $school->id,
                'user_id' => $request->user()->id,
                'file_name' => $originalName,
                'file_path' => $storedPath,
                'total_rows' => 0,
                'successful_rows' => 0,
                'failed_rows' => 0,
                'errors' => [['row' => 0, 'message' => 'Gagal membaca format file: ' . $e->getMessage()]],
                'status' => 'failed',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Gagal memproses file import: ' . $e->getMessage(),
            ], 422);
        }

        $importStatus = ($importer->failedRows > 0 && $importer->successfulRows === 0) ? 'failed' : 'completed';

        $record = ImportRecord::create([
            'school_id' => $school->id,
            'user_id' => $request->user()->id,
            'file_name' => $originalName,
            'file_path' => $storedPath,
            'total_rows' => $importer->totalRows,
            'successful_rows' => $importer->successfulRows,
            'failed_rows' => $importer->failedRows,
            'errors' => $importer->errors,
            'status' => $importStatus,
        ]);

        return response()->json([
            'success' => true,
            'message' => "Proses import selesai. Berhasil: {$importer->successfulRows}, Gagal/Dilewati: {$importer->failedRows}.",
            'data' => [
                'import_id' => $record->id,
                'total_rows' => $importer->totalRows,
                'successful_rows' => $importer->successfulRows,
                'failed_rows' => $importer->failedRows,
                'errors' => $importer->errors,
            ],
        ]);
    }

    /**
     * Get import history for this school.
     */
    public function history(Request $request): JsonResponse
    {
        $school = $request->user()->school;

        $history = ImportRecord::where('school_id', $school->id)
            ->with('user:id,name,email')
            ->latest()
            ->paginate($request->input('per_page', 10));

        return response()->json([
            'success' => true,
            'data' => $history,
        ]);
    }
}
