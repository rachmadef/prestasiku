<?php

namespace App\Services;

use ZipArchive;

class DocxTemplateParserService
{
    /**
     * Parse uploaded .docx file and extract all placeholder variables like ${nama_variable} or {VARIABLE}.
     * Returns an array of field schema objects for the dynamic form builder.
     */
    public function parseVariablesFromDocx(string $filePath): array
    {
        $zip = new ZipArchive();
        if ($zip->open($filePath) !== true) {
            return [];
        }

        $xmlContent = '';

        // Extract main document XML
        $docXmlIndex = $zip->locateName('word/document.xml');
        if ($docXmlIndex !== false) {
            $xmlContent .= $zip->getFromIndex($docXmlIndex);
        }

        // Also check header and footer XMLs
        for ($i = 0; $i < $zip->numFiles; $i++) {
            $name = $zip->getNameIndex($i);
            if (str_starts_with($name, 'word/header') || str_starts_with($name, 'word/footer')) {
                $xmlContent .= ' ' . $zip->getFromIndex($i);
            }
        }

        $zip->close();

        if (empty($xmlContent)) {
            return [];
        }

        // Clean Word XML tags that might split variables across multiple tags like <w:t>${</w:t><w:t>var</w:t><w:t>}</w:t>
        $plainText = preg_replace('/<[^>]+>/', '', $xmlContent);

        // Match variables formatted as ${variable_name}, {variable_name}, or [VARIABLE_NAME]
        preg_match_all('/(?:\$\{([a-zA-Z0-9_]+)\}|\{([a-zA-Z0-9_]+)\}|\[([a-zA-Z0-9_]+)\])/', $plainText, $matches);

        $extractedVars = [];
        foreach ([1, 2, 3] as $group) {
            if (!empty($matches[$group])) {
                foreach ($matches[$group] as $var) {
                    if (!empty($var)) {
                        $extractedVars[] = trim($var);
                    }
                }
            }
        }

        $extractedVars = array_values(array_unique($extractedVars));

        // Exclude system default auto-filled variables
        $systemVars = [
            'NOMOR_SURAT', 'NAMA_SEKOLAH', 'SEKOLAH_NAMA', 'SEKOLAH_ALAMAT',
            'SEKOLAH_NPSN', 'SEKOLAH_KOTA', 'TANGGAL_CETAK', 'student_no',
            'student_name', 'student_nis', 'student_class', 'NOMOR_PERIZINAN'
        ];

        $schema = [];
        $counter = 1;

        foreach ($extractedVars as $var) {
            if (in_array(strtoupper($var), array_map('strtoupper', $systemVars))) {
                continue;
            }

            $name = strtolower($var);
            $label = ucwords(str_replace('_', ' ', $name));

            // Auto-detect field type based on name hints
            $type = 'text';
            if (str_contains($name, 'tanggal') || str_contains($name, 'date')) {
                $type = 'date';
            } elseif (str_contains($name, 'catatan') || str_contains($name, 'alasan') || str_contains($name, 'tujuan') || str_contains($name, 'deskripsi')) {
                $type = 'textarea';
            } elseif (str_contains($name, 'jumlah') || str_contains($name, 'total') || str_contains($name, 'jam') || str_contains($name, 'nominal')) {
                $type = 'number';
            } elseif (str_contains($name, 'setuju') || str_contains($name, 'komitmen') || str_contains($name, 'centang')) {
                $type = 'checkbox';
            } elseif (str_contains($name, 'kategori') || str_contains($name, 'jenis') || str_contains($name, 'sumber') || str_contains($name, 'tingkat')) {
                $type = 'select';
            }

            $schema[] = [
                'id' => "field_docx_{$counter}_" . substr(md5($name), 0, 4),
                'name' => $name,
                'label' => $label,
                'type' => $type,
                'placeholder' => $type === 'select' ? null : "Masukkan {$label}...",
                'description' => "Kolom otomatis terdeteksi dari variabel \${$var} pada template DOCX.",
                'options' => $type === 'select' ? ['Pilihan 1', 'Pilihan 2'] : [],
                'is_required' => true,
            ];

            $counter++;
        }

        return $schema;
    }
}
