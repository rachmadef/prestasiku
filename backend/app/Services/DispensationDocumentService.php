<?php

namespace App\Services;

use App\Models\KbmDispensation;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use PhpOffice\PhpWord\Element\Table;
use PhpOffice\PhpWord\IOFactory;
use PhpOffice\PhpWord\PhpWord;
use PhpOffice\PhpWord\SimpleType\Jc;
use PhpOffice\PhpWord\SimpleType\JcTable;
use PhpOffice\PhpWord\Style\Language;

class DispensationDocumentService
{
    public function __construct(protected QrCodeService $qrCodeService)
    {
    }

    /**
     * Generate PDF response for a dispensation.
     */
    public function generatePdf(KbmDispensation $dispensation)
    {
        $dispensation->loadMissing(['school', 'students', 'approvedBy']);
        $school = $dispensation->school;

        $letterheadImageBase64 = null;
        if (! empty($school->letterhead_image_path)) {
            $path = Storage::disk('public')->path($school->letterhead_image_path);
            if (File::exists($path)) {
                $mime = mime_content_type($path) ?: 'image/png';
                $letterheadImageBase64 = 'data:' . $mime . ';base64,' . base64_encode(File::get($path));
            }
        }

        $qrCodeDataUri = $this->qrCodeService->generateDispensationDataUri($dispensation->verification_token, 180);

        $pdf = Pdf::loadView('letters.dispensation_pdf', [
            'dispensation' => $dispensation,
            'school' => $school,
            'students' => $dispensation->students,
            'letterheadImageBase64' => $letterheadImageBase64,
            'letterConfig' => $school->letter_format_config ?? [],
            'qrCodeDataUri' => $qrCodeDataUri,
        ]);

        $pdf->setPaper('a4', 'portrait');

        return $pdf;
    }

    /**
     * Generate DOCX document for a dispensation.
     * Returns absolute path to generated temporary file.
     */
    public function generateDocx(KbmDispensation $dispensation): string
    {
        $dispensation->loadMissing(['school', 'students', 'approvedBy']);
        $school = $dispensation->school;

        $tempDir = storage_path('app/temp');
        if (! File::isDirectory($tempDir)) {
            File::makeDirectory($tempDir, 0755, true);
        }

        $safeRef = preg_replace('/[^a-zA-Z0-9_-]/', '_', $dispensation->reference_number ?: 'DISP');
        $fileName = "Surat_Dispensasi_{$safeRef}_" . time() . '.docx';
        $targetPath = $tempDir . DIRECTORY_SEPARATOR . $fileName;

        // Cek jika sekolah mengunggah custom template .docx
        if (! empty($school->dispensation_docx_template_path)) {
            $templateDiskPath = Storage::disk('public')->path($school->dispensation_docx_template_path);
            if (File::exists($templateDiskPath)) {
                return $this->processCustomDocxTemplate($templateDiskPath, $dispensation, $targetPath);
            }
        }

        // Jika tidak ada template kustom, bangun dokumen DOCX resmi menggunakan PhpWord
        $phpWord = new PhpWord();
        $phpWord->getSettings()->setThemeFontLang(new Language('id-ID'));

        // Section Setup A4
        $section = $phpWord->addSection([
            'paperSize' => 'A4',
            'marginTop' => 1134,    // ~20mm
            'marginBottom' => 1134, // ~20mm
            'marginLeft' => 1417,   // ~25mm
            'marginRight' => 1134,  // ~20mm
        ]);

        // 1. KOP SURAT SEKOLAH
        $letterheadImagePath = null;
        if (! empty($school->letterhead_image_path)) {
            $diskPath = Storage::disk('public')->path($school->letterhead_image_path);
            if (File::exists($diskPath)) {
                $letterheadImagePath = $diskPath;
            }
        }

        if ($letterheadImagePath && ($school->letterhead_type ?? 'text') === 'image') {
            $section->addImage($letterheadImagePath, [
                'width' => 450,
                'alignment' => Jc::CENTER,
                'wrappingStyle' => 'inline',
            ]);
            $section->addTextBreak(1);
        } else {
            // Textual Kop Surat Standar Kedinasan
            $config = $school->letter_format_config ?? [];
            $govLine = $config['institution_level1'] ?? 'PEMERINTAH DAERAH PROVINSI';
            $agencyLine = $config['institution_level2'] ?? 'DINAS PENDIDIKAN DAN KEBUDAYAAN';

            $section->addText(strtoupper($govLine), ['name' => 'Times New Roman', 'size' => 11, 'bold' => true], ['alignment' => Jc::CENTER, 'spaceAfter' => 0]);
            $section->addText(strtoupper($agencyLine), ['name' => 'Times New Roman', 'size' => 12, 'bold' => true], ['alignment' => Jc::CENTER, 'spaceAfter' => 0]);
            $section->addText(strtoupper($school->name), ['name' => 'Times New Roman', 'size' => 14, 'bold' => true], ['alignment' => Jc::CENTER, 'spaceAfter' => 60]);

            $metaText = $school->address . ' • NPSN: ' . $school->npsn;
            if ($school->phone) {
                $metaText .= ' • Telp: ' . $school->phone;
            }
            if ($school->email) {
                $metaText .= ' • Email: ' . $school->email;
            }
            $section->addText($metaText, ['name' => 'Arial', 'size' => 9, 'color' => '4B5563'], ['alignment' => Jc::CENTER, 'spaceAfter' => 120]);

            // Garis Ganda Kedinasan
            $section->addLine(['weight' => 2.5, 'width' => 480, 'height' => 0, 'color' => '000000']);
            $section->addLine(['weight' => 1.0, 'width' => 480, 'height' => 0, 'color' => '000000']);
            $section->addTextBreak(1);
        }

        // 2. JUDUL DOKUMEN & NOMOR
        $docTitle = ($school->letter_format_config['document_title'] ?? null) ?: 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)';
        $section->addText($docTitle, [
            'name' => 'Times New Roman',
            'size' => 12,
            'bold' => true,
            'underline' => 'single',
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 40]);

        $section->addText('Nomor: ' . $dispensation->reference_number, [
            'name' => 'Arial',
            'size' => 10,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 180]);

        // 3. PEMBUKA SURAT
        $section->addText(
            "Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {$school->name}, dengan ini menerangkan bahwa siswa-siswi tersebut di bawah ini:",
            ['name' => 'Times New Roman', 'size' => 11],
            ['alignment' => Jc::BOTH, 'spaceAfter' => 100]
        );

        // 4. TABEL DELEGASI SISWA
        $tableStyle = [
            'borderColor' => '4B5563',
            'borderSize' => 6,
            'cellMargin' => 80,
            'alignment' => JcTable::CENTER,
        ];
        $phpWord->addTableStyle('StudentTable', $tableStyle);
        $table = $section->addTable('StudentTable');

        // Header Tabel
        $table->addRow(350);
        $table->addCell(600, ['bgColor' => 'F3F4F6'])->addText('No', ['name' => 'Arial', 'size' => 9.5, 'bold' => true], ['alignment' => Jc::CENTER]);
        $table->addCell(3600, ['bgColor' => 'F3F4F6'])->addText('Nama Siswa', ['name' => 'Arial', 'size' => 9.5, 'bold' => true]);
        $table->addCell(1600, ['bgColor' => 'F3F4F6'])->addText('NIS / NISN', ['name' => 'Arial', 'size' => 9.5, 'bold' => true], ['alignment' => Jc::CENTER]);
        $table->addCell(1400, ['bgColor' => 'F3F4F6'])->addText('Kelas', ['name' => 'Arial', 'size' => 9.5, 'bold' => true], ['alignment' => Jc::CENTER]);

        foreach ($dispensation->students as $idx => $student) {
            $table->addRow(300);
            $table->addCell(600)->addText((string) ($idx + 1), ['name' => 'Arial', 'size' => 9], ['alignment' => Jc::CENTER]);
            $table->addCell(3600)->addText($student->full_name, ['name' => 'Arial', 'size' => 9, 'bold' => true]);
            $table->addCell(1600)->addText(($student->nis ?? '-') . ' / ' . ($student->nisn ?? '-'), ['name' => 'Arial', 'size' => 9], ['alignment' => Jc::CENTER]);
            $table->addCell(1400)->addText($student->class_name ?? '-', ['name' => 'Arial', 'size' => 9], ['alignment' => Jc::CENTER]);
        }

        $section->addTextBreak(1);

        // 5. RINCIAN KEGIATAN
        $section->addText(
            'Diberikan izin untuk tidak mengikuti Kegiatan Belajar Mengajar (KBM) di kelas sehubungan dengan keikutsertaan pada agenda kompetisi / pembinaan prestasi:',
            ['name' => 'Times New Roman', 'size' => 11],
            ['alignment' => Jc::BOTH, 'spaceAfter' => 80]
        );

        $infoTableStyle = [
            'borderColor' => 'D1D5DB',
            'borderSize' => 4,
            'cellMargin' => 70,
            'alignment' => JcTable::CENTER,
        ];
        $phpWord->addTableStyle('InfoTable', $infoTableStyle);
        $infoTable = $section->addTable('InfoTable');

        $typeLabel = match ($dispensation->dispensation_type) {
            'persiapan_latihan' => 'Pembinaan & Latihan Intensif',
            'pelaksanaan_lomba' => 'Pelaksanaan Hari-H Lomba',
            default => 'Kegiatan Prestasi Sekolah',
        };

        $period = Carbon::parse($dispensation->start_date)->translatedFormat('d F Y') . ' s.d. ' . Carbon::parse($dispensation->end_date)->translatedFormat('d F Y');
        if (! $dispensation->is_all_day && $dispensation->start_time) {
            $period .= " ({$dispensation->start_time} - {$dispensation->end_time} WIB)";
        } else {
            $period .= ' (Seharian Penuh)';
        }

        $fields = [
            'Nama Kegiatan' => $dispensation->competition_name,
            'Jenis Dispensasi' => $typeLabel,
            'Keperluan Izin' => $dispensation->purpose,
            'Waktu Pelaksanaan' => $period,
            'Guru Pembina Lomba' => $dispensation->supervisor_name ?: 'Pembina Lomba Prestasi Sekolah',
        ];

        foreach ($fields as $label => $val) {
            $infoTable->addRow(280);
            $infoTable->addCell(2400)->addText($label, ['name' => 'Arial', 'size' => 9.5, 'bold' => true]);
            $infoTable->addCell(300)->addText(':', ['name' => 'Arial', 'size' => 9.5]);
            $infoTable->addCell(4500)->addText($val, ['name' => 'Arial', 'size' => 9.5]);
        }

        $section->addTextBreak(1);

        // 6. PENUTUP
        $section->addText(
            'Demikian surat dispensasi ini diterbitkan agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa yang bersangkutan tetap berkewajiban menyelesaikan materi serta tugas-tugas pelajaran yang tertinggal.',
            ['name' => 'Times New Roman', 'size' => 10.5, 'italic' => true],
            ['alignment' => Jc::BOTH, 'spaceAfter' => 140]
        );

        // 7. STRUKTUR 2 KOLOM TANDA TANGAN
        // Kolom Kiri: Tanda Tangan 1 (Guru Pembina Lomba - Terisi Otomatis)
        // Kolom Kanan: Tanda Tangan 2 (Guru Mata Pelajaran / Guru Piket - Dikosongkan)
        $sigTable = $section->addTable([
            'alignment' => JcTable::CENTER,
            'cellMargin' => 40,
        ]);

        $sigTable->addRow();

        // Kolom 1: Guru Pembina
        $city = $school->city ?: 'Tempat';
        $appDate = Carbon::parse($dispensation->approved_at ?? now())->translatedFormat('d F Y');
        $cell1 = $sigTable->addCell(3700);
        $cell1->addText("Ditetapkan di: {$city}\nPada tanggal: {$appDate}", ['name' => 'Times New Roman', 'size' => 9.5, 'color' => '374151'], ['alignment' => Jc::CENTER]);
        $cell1->addText("Mengetahui,\nGuru Pembina Lomba", ['name' => 'Times New Roman', 'size' => 10, 'bold' => true], ['alignment' => Jc::CENTER]);
        $cell1->addTextBreak(3);
        $cell1->addText($dispensation->supervisor_name ?: 'Guru Pembina Lomba', ['name' => 'Times New Roman', 'size' => 10.5, 'bold' => true, 'underline' => 'single'], ['alignment' => Jc::CENTER]);
        $cell1->addText('NIP. - / Pembina Prestasi', ['name' => 'Arial', 'size' => 8.5, 'color' => '4B5563'], ['alignment' => Jc::CENTER]);

        // Kolom 2: Guru Mapel / Guru Piket (Dikosongkan karena jam mengajar dinamis)
        $cell2 = $sigTable->addCell(3700);
        $cell2->addText(" \n ", ['name' => 'Times New Roman', 'size' => 9.5, 'color' => 'FFFFFF'], ['alignment' => Jc::CENTER]);
        $cell2->addText("Menyetujui / Memaklumi,\nGuru Mata Pelajaran / Guru Piket", ['name' => 'Times New Roman', 'size' => 10, 'bold' => true], ['alignment' => Jc::CENTER]);
        $cell2->addTextBreak(3);
        $cell2->addText('( .................................................... )', ['name' => 'Times New Roman', 'size' => 10.5, 'bold' => true], ['alignment' => Jc::CENTER]);
        $cell2->addText("NIP. ..............................................\n*(Ditandatangani saat jam KBM di kelas)*", ['name' => 'Arial', 'size' => 8, 'italic' => true, 'color' => '6B7280'], ['alignment' => Jc::CENTER]);

        // Tulis file
        $writer = IOFactory::createWriter($phpWord, 'Word2007');
        $writer->save($targetPath);

        return $targetPath;
    }

    /**
     * Process custom uploaded .docx template with variable replacements.
     */
    protected function processCustomDocxTemplate(string $templatePath, KbmDispensation $dispensation, string $targetPath): string
    {
        $templateProcessor = new \PhpOffice\PhpWord\TemplateProcessor($templatePath);
        $school = $dispensation->school;

        $templateProcessor->setValue('NOMOR_SURAT', $dispensation->reference_number);
        $templateProcessor->setValue('NAMA_KEGIATAN', $dispensation->competition_name);
        $templateProcessor->setValue('KEPERLUAN', $dispensation->purpose);
        $templateProcessor->setValue('TANGGAL_MULAI', Carbon::parse($dispensation->start_date)->translatedFormat('d F Y'));
        $templateProcessor->setValue('TANGGAL_SELESAI', Carbon::parse($dispensation->end_date)->translatedFormat('d F Y'));
        $templateProcessor->setValue('GURU_PEMBINA', $dispensation->supervisor_name ?: 'Pembina Lomba');
        $templateProcessor->setValue('SEKOLAH_NAMA', $school->name);
        $templateProcessor->setValue('SEKOLAH_ALAMAT', $school->address);
        $templateProcessor->setValue('SEKOLAH_NPSN', $school->npsn);
        $templateProcessor->setValue('SEKOLAH_KOTA', $school->city ?: 'Tempat');
        $templateProcessor->setValue('TANGGAL_CETAK', now()->translatedFormat('d F Y'));

        // Handle student rows if template includes student_no variable
        if (count($dispensation->students) > 0) {
            try {
                $templateProcessor->cloneRow('student_no', count($dispensation->students));
                foreach ($dispensation->students as $i => $std) {
                    $row = $i + 1;
                    $templateProcessor->setValue("student_no#{$row}", (string) $row);
                    $templateProcessor->setValue("student_name#{$row}", $std->full_name);
                    $templateProcessor->setValue("student_nis#{$row}", $std->nis ?: '-');
                    $templateProcessor->setValue("student_class#{$row}", $std->class_name ?: '-');
                }
            } catch (\Throwable) {
                // If cloneRow is not in template, ignore silently
            }
        }

        $templateProcessor->saveAs($targetPath);
        return $targetPath;
    }
}
