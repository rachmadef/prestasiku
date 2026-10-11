<?php

namespace App\Services;

use App\Models\CompetitionSupervisor;
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

class SupervisorDocumentService
{
    /**
     * Generate PDF response for supervisor & honorarium receipt.
     */
    public function generatePdf(CompetitionSupervisor $supervisor)
    {
        $supervisor->loadMissing(['school', 'competition', 'creator']);
        $school = $supervisor->school ?: \App\Models\School::find(1);

        $letterheadImageBase64 = null;
        if (! empty($school->letterhead_image_path)) {
            $path = Storage::disk('public')->path($school->letterhead_image_path);
            if (File::exists($path)) {
                $mime = mime_content_type($path) ?: 'image/png';
                $letterheadImageBase64 = 'data:' . $mime . ';base64,' . base64_encode(File::get($path));
            }
        }

        $pdf = Pdf::loadView('letters.supervisor_pdf', [
            'supervisor' => $supervisor,
            'school' => $school,
            'letterheadImageBase64' => $letterheadImageBase64,
            'letterConfig' => $school->letter_format_config ?? [],
        ]);

        $pdf->setPaper('a4', 'portrait');

        return $pdf;
    }

    /**
     * Generate Word DOCX matching FORM PENDAMPING PERLOMBAAN.docx
     */
    public function generateDocx(CompetitionSupervisor $supervisor): string
    {
        $supervisor->loadMissing(['school', 'competition', 'creator']);
        $school = $supervisor->school ?: \App\Models\School::find(1);

        $tempDir = storage_path('app/temp');
        if (! File::isDirectory($tempDir)) {
            File::makeDirectory($tempDir, 0755, true);
        }

        $safeRef = preg_replace('/[^a-zA-Z0-9_-]/', '_', $supervisor->reference_number ?: 'SUPERVISOR');
        $fileName = "Form_Pendamping_{$safeRef}_" . time() . '.docx';
        $targetPath = $tempDir . DIRECTORY_SEPARATOR . $fileName;

        $phpWord = new PhpWord();
        $phpWord->getSettings()->setThemeFontLang(new Language('id-ID'));

        // Document 1 Section Setup A4
        $section = $phpWord->addSection([
            'paperSize' => 'A4',
            'marginTop' => 1134,    // ~20mm
            'marginBottom' => 1134, // ~20mm
            'marginLeft' => 1417,   // ~25mm
            'marginRight' => 1134,  // ~20mm
        ]);

        // 1. KOP SURAT
        $section->addText('FORM PENDAMPING PERLOMBAAN', [
            'name' => 'Times New Roman',
            'size' => 14,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 0]);

        $section->addText(strtoupper($school->name ?? 'MA UNGGULAN K.H. ABD. WAHAB HASBULLOH'), [
            'name' => 'Times New Roman',
            'size' => 12,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 0]);

        $section->addText('TAMBAKBERAS JOMBANG', [
            'name' => 'Times New Roman',
            'size' => 11,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 180]);

        // A. DATA PERLOMBAAN
        $section->addText('A. DATA PERLOMBAAN', [
            'name' => 'Times New Roman',
            'size' => 11,
            'bold' => true,
        ], ['alignment' => Jc::LEFT, 'spaceAfter' => 60]);

        $compName = $supervisor->competition_name ?: ($supervisor->competition->title ?? '-');
        $section->addText("Nama Penyelenggara/nama perlombaan: {$compName}", ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 40]);
        $section->addText("Cabang Lomba yang Diikuti: " . ($supervisor->competition_branch ?: '-'), ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 40]);
        $section->addText("Nama Peserta / Tim yang Didampingi: " . ($supervisor->student_names ?: '-'), ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 40]);
        $section->addText("Kategori Lomba (misal: SD / SMP / SMA / Umum): " . ($supervisor->competition_category ?: 'SMA / MA'), ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 40]);
        $section->addText("Tempat Perlombaan: " . ($supervisor->competition_place ?: '-'), ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 40]);

        $lvl = strtolower($supervisor->competition_level ?: ($supervisor->competition->level ?? ''));
        $section->addText('Tingkat Perlombaan:', ['name' => 'Times New Roman', 'size' => 11, 'bold' => true], ['spaceAfter' => 20]);
        $section->addText(($lvl === 'kabupaten' ? '[ X ]' : '[   ]') . ' Kabupaten/Kota', ['name' => 'Times New Roman', 'size' => 10.5], ['spaceAfter' => 10]);
        $section->addText(($lvl === 'provinsi' ? '[ X ]' : '[   ]') . ' Provinsi', ['name' => 'Times New Roman', 'size' => 10.5], ['spaceAfter' => 10]);
        $section->addText(($lvl === 'nasional' ? '[ X ]' : '[   ]') . ' Nasional', ['name' => 'Times New Roman', 'size' => 10.5], ['spaceAfter' => 10]);
        $section->addText(($lvl === 'internasional' ? '[ X ]' : '[   ]') . ' Internasional', ['name' => 'Times New Roman', 'size' => 10.5], ['spaceAfter' => 100]);

        // B. DATA DIRI PENDAMPING (Table Style)
        $section->addText('B. DATA DIRI PENDAMPING', [
            'name' => 'Times New Roman',
            'size' => 11,
            'bold' => true,
        ], ['alignment' => Jc::LEFT, 'spaceAfter' => 60]);

        $tableStyle = [
            'borderColor' => '000000',
            'borderSize' => 6,
            'cellMargin' => 50,
            'alignment' => JcTable::CENTER,
        ];
        $phpWord->addTableStyle('PendampingTable', $tableStyle);
        $table = $section->addTable('PendampingTable');

        // Headers
        $table->addRow(280);
        $table->addCell(500)->addText('No', ['bold' => true, 'size' => 10]);
        $table->addCell(3000)->addText('Informasi', ['bold' => true, 'size' => 10]);
        $table->addCell(4500)->addText('Isian Data', ['bold' => true, 'size' => 10]);

        // Row 1
        $table->addRow();
        $table->addCell(500)->addText('1', ['size' => 10]);
        $table->addCell(3000)->addText('Nama Lengkap dan Gelar', ['size' => 10]);
        $table->addCell(4500)->addText($supervisor->supervisor_name, ['bold' => true, 'size' => 10]);

        // Row 2
        $table->addRow();
        $table->addCell(500)->addText('2', ['size' => 10]);
        $table->addCell(3000)->addText('Kategori Pendamping', ['size' => 10]);
        $cat = strtolower($supervisor->supervisor_category ?? 'guru');
        $catText = (str_contains($cat, 'guru') ? '[ X ]' : '[   ]') . " Guru   " .
                   (str_contains($cat, 'pelatih') ? '[ X ]' : '[   ]') . " Pelatih   " .
                   (str_contains($cat, 'tenaga') ? '[ X ]' : '[   ]') . " Tenaga Kependidikan\n" .
                   (str_contains($cat, 'pembimbing') ? '[ X ]' : '[   ]') . " Pembimbing   " .
                   (str_contains($cat, 'koordinator') ? '[ X ]' : '[   ]') . " Koordinator Prestasi";
        $table->addCell(4500)->addText($catText, ['size' => 9.5]);

        // Row 3
        $table->addRow();
        $table->addCell(500)->addText('3', ['size' => 10]);
        $table->addCell(3000)->addText('Jabatan / Mata Pelajaran / Unit Kerja', ['size' => 10]);
        $table->addCell(4500)->addText($supervisor->role_title ?: '-', ['size' => 10]);

        // Row 4
        $table->addRow();
        $table->addCell(500)->addText('4', ['size' => 10]);
        $table->addCell(3000)->addText('Jenis Kelamin', ['size' => 10]);
        $gen = strtolower($supervisor->supervisor_gender ?? '');
        $genText = ($gen === 'laki-laki' || $gen === 'l' ? '[ X ]' : '[   ]') . " Laki-laki    " .
                   ($gen === 'perempuan' || $gen === 'p' ? '[ X ]' : '[   ]') . " Perempuan";
        $table->addCell(4500)->addText($genText, ['size' => 10]);

        // Row 5
        $table->addRow();
        $table->addCell(500)->addText('5', ['size' => 10]);
        $table->addCell(3000)->addText('Nomor WhatsApp / HP (Aktif)', ['size' => 10]);
        $table->addCell(4500)->addText($supervisor->supervisor_phone ?: '-', ['size' => 10]);

        $section->addTextBreak(1);

        // C. PERNYATAAN DAN PERSETUJUAN
        $section->addText('C. PERNYATAAN DAN PERSETUJUAN', [
            'name' => 'Times New Roman',
            'size' => 11,
            'bold' => true,
        ], ['alignment' => Jc::LEFT, 'spaceAfter' => 40]);

        $section->addText('Dengan mengisi formulir ini, saya menyatakan bahwa:', ['name' => 'Times New Roman', 'size' => 10.5], ['spaceAfter' => 20]);
        $section->addText('1. Data yang saya isikan di atas adalah benar dan dapat dipertanggungjawabkan.', ['name' => 'Times New Roman', 'size' => 10], ['spaceAfter' => 10]);
        $section->addText('2. Saya ditugaskan secara resmi oleh sekolah/instansi/lembaga sebagai pendamping peserta perlombaan.', ['name' => 'Times New Roman', 'size' => 10], ['spaceAfter' => 10]);
        $section->addText('3. Saya bersedia mendampingi peserta, serta mematuhi seluruh tata tertib dan regulasi perlombaan yang ditetapkan panitia.', ['name' => 'Times New Roman', 'size' => 10], ['spaceAfter' => 80]);

        // Signatures 1
        $dateStr = 'Jombang, ' . Carbon::parse($supervisor->created_at)->translatedFormat('d F Y');
        $sigTable = $section->addTable(['alignment' => JcTable::CENTER]);
        $sigTable->addRow();
        $sigTable->addCell(4000)->addText('');
        $cellRight = $sigTable->addCell(4000);
        $cellRight->addText($dateStr, ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cellRight->addText('Pendamping Perlombaan,', ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cellRight->addTextBreak(3);
        $cellRight->addText("( {$supervisor->supervisor_name} )", ['name' => 'Times New Roman', 'size' => 10.5, 'bold' => true], ['alignment' => Jc::CENTER]);

        // =========================================================
        // SECTION 2: FORM TANDA TERIMA HONORARIUM
        // =========================================================
        $section2 = $phpWord->addSection([
            'paperSize' => 'A4',
            'marginTop' => 1134,
            'marginBottom' => 1134,
            'marginLeft' => 1417,
            'marginRight' => 1134,
        ]);

        $section2->addText('FORM TANDA TERIMA HONORARIUM PENDAMPING PERLOMBAAN', [
            'name' => 'Times New Roman',
            'size' => 12,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 0]);

        $section2->addText(strtoupper($school->name ?? 'MA UNGGULAN K.H. ABD. WAHAB HASBULLOH'), [
            'name' => 'Times New Roman',
            'size' => 12,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 0]);

        $section2->addText('TAMBAKBERAS JOMBANG', [
            'name' => 'Times New Roman',
            'size' => 11,
            'bold' => true,
        ], ['alignment' => Jc::CENTER, 'spaceAfter' => 180]);

        $section2->addText("Nama Pendamping Perlombaan: {$supervisor->supervisor_name}", ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 40]);
        $section2->addText("Nama Penyelenggara/nama perlombaan: {$compName}", ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 100]);

        $section2->addText('Kategori Wilayah Tugas:', ['name' => 'Times New Roman', 'size' => 11, 'bold' => true], ['spaceAfter' => 30]);

        $zone = strtolower($supervisor->duty_zone ?? 'dalam_kota');
        $section2->addText(($zone === 'dalam_kota' ? '[ X ]' : '[   ]') . ' Dalam Kota : Rp 50.000', ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 20]);
        $section2->addText(($zone === 'luar_kota' ? '[ X ]' : '[   ]') . ' Luar Kota : Rp 100.000', ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 20]);
        $section2->addText(($zone === 'luar_provinsi' ? '[ X ]' : '[   ]') . ' Luar Provinsi : Rp 150.000', ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 20]);
        $section2->addText(($zone === 'luar_negeri' ? '[ X ]' : '[   ]') . ' Luar Negeri : Rp 200.000', ['name' => 'Times New Roman', 'size' => 11], ['spaceAfter' => 80]);

        $bisyarohFmt = number_format($supervisor->bisyaroh_amount, 0, ',', '.');
        $section2->addText("Nominal Bisyaroh Disetujui: Rp {$bisyarohFmt}", ['name' => 'Times New Roman', 'size' => 11, 'bold' => true], ['spaceAfter' => 120]);

        // Signatures 2
        $sigTable2 = $section2->addTable(['alignment' => JcTable::CENTER]);
        $sigTable2->addRow();
        
        $cLeft = $sigTable2->addCell(4000);
        $cLeft->addText('Yang Menerima,', ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cLeft->addText('Pendamping Perlombaan', ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cLeft->addTextBreak(3);
        $cLeft->addText("( {$supervisor->supervisor_name} )", ['name' => 'Times New Roman', 'size' => 10.5, 'bold' => true], ['alignment' => Jc::CENTER]);

        $cRight = $sigTable2->addCell(4000);
        $cRight->addText($dateStr, ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cRight->addText('Mengetahui,', ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cRight->addText('Koordinator Prestasi', ['name' => 'Times New Roman', 'size' => 10.5], ['alignment' => Jc::CENTER]);
        $cRight->addTextBreak(2);
        $cRight->addText('( Sariyanti, S.Pd. )', ['name' => 'Times New Roman', 'size' => 10.5, 'bold' => true], ['alignment' => Jc::CENTER]);

        $objWriter = IOFactory::createWriter($phpWord, 'Word2007');
        $objWriter->save($targetPath);

        return $targetPath;
    }
}
