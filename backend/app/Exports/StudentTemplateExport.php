<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithHeadings;

class StudentTemplateExport implements FromArray, WithHeadings, ShouldAutoSize
{
    public function headings(): array
    {
        return [
            'nis',
            'nisn',
            'full_name',
            'grade_level',
            'class_name',
            'gender',
            'birth_date',
            'birth_place',
            'phone_number',
            'email',
        ];
    }

    public function array(): array
    {
        return [
            [
                '2026101',
                '0091234567',
                'Budi Santoso',
                10,
                'X MIPA 1',
                'L',
                '2009-02-14',
                'Jakarta',
                '081234567890',
                'budi@example.com',
            ],
            [
                '2026102',
                '0091234568',
                'Siti Rahmawati',
                10,
                'X MIPA 2',
                'P',
                '2009-08-20',
                'Bandung',
                '081234567891',
                'siti@example.com',
            ],
        ];
    }
}
