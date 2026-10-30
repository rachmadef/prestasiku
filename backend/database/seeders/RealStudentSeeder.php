<?php

namespace Database\Seeders;

use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use PhpOffice\PhpSpreadsheet\IOFactory;

class RealStudentSeeder extends Seeder
{
    /**
     * Seed database with all 638 real students from Data Siswa.xlsx.
     */
    public function run(): void
    {
        $file = database_path('seeders/data/Data Siswa.xlsx');
        if (! file_exists($file)) {
            $this->command?->error("File {$file} tidak ditemukan!");

            return;
        }

        $school = School::firstOrCreate(
            ['npsn' => '20579998'],
            [
                'name' => 'MA Unggulan K.H. Abd. Wahab Hasbulloh',
                'educational_level' => 'slta',
                'province' => 'Jawa Timur',
                'city' => 'Jombang',
                'address' => 'Tambakberas, Jombang',
                'phone' => '0321-123456',
                'email' => 'info@mau-tb.sch.id',
                'status' => 'verified',
                'verified_at' => now(),
            ]
        );

        $reader = IOFactory::createReaderForFile($file);
        $reader->setReadDataOnly(true);
        $spreadsheet = $reader->load($file);

        $sheetMap = [
            'SISWA KELAS X' => 10,
            'SISWA KELAS XI' => 11,
            'SISWA KELAS XII' => 12,
        ];

        $imported = 0;
        $skipped = 0;

        $existingNiss = Student::where('school_id', $school->id)->pluck('nis')->toArray();
        $nisCounter = 1000;
        $defaultPassword = Hash::make('1234');

        foreach ($sheetMap as $sheetName => $defaultGrade) {
            $sheet = $spreadsheet->getSheetByName($sheetName);
            if (! $sheet) {
                continue;
            }

            $highestRow = $sheet->getHighestRow();

            for ($r = 3; $r <= $highestRow; $r++) {
                $rawNisn = trim((string) $sheet->getCell('A' . $r)->getValue());
                $fullName = trim((string) $sheet->getCell('B' . $r)->getValue());
                $className = trim((string) $sheet->getCell('C' . $r)->getValue());

                if (empty($fullName)) {
                    continue; // Row kosong
                }

                // Tentukan Grade Level dari kelas
                $gradeLevel = $defaultGrade;
                if (str_starts_with($className, 'X-') || str_starts_with($className, 'X ')) {
                    $gradeLevel = 10;
                } elseif (str_starts_with($className, 'XI ')) {
                    $gradeLevel = 11;
                } elseif (str_starts_with($className, 'XII ')) {
                    $gradeLevel = 12;
                }

                // Tentukan NIS & NISN
                $nisn = ! empty($rawNisn) ? $rawNisn : null;
                $nis = $rawNisn;

                if (empty($nis)) {
                    $nis = (string) (30000000 + $nisCounter);
                    $nisCounter++;
                }

                // Pastikan NIS unik per sekolah
                if (in_array($nis, $existingNiss)) {
                    // Update data jika siswa NIS sudah ada
                    $student = Student::where('school_id', $school->id)->where('nis', $nis)->first();
                    if ($student) {
                        $student->update([
                            'full_name' => $fullName,
                            'class_name' => $className,
                            'grade_level' => $gradeLevel,
                            'nisn' => $nisn,
                        ]);
                        $student->user?->update(['name' => $fullName]);
                        $skipped++;
                        continue;
                    }
                }

                $existingNiss[] = $nis;

                // Gender heuristic sederhana based on common Indonesian female names
                $gender = 'L';
                $nameUpper = strtoupper($fullName);
                $femaleKeywords = ['AMELIA', 'AYU', 'AZALEA', 'BUNGA', 'CALLYSTA', 'CLAUDIA', 'DINTA', 'PUTRI', 'SITI', 'NUR', 'CITRA', 'DESI', 'DIAN', 'INTAN', 'LIA', 'MAYA', 'NITA', 'RATNA', 'RINA', 'SEKAR', 'TANIA', 'AULIA', 'SAFITRI', 'NURIYAH', 'LESTRAI', 'LILI', 'NISA', 'ZAHRA', 'SABRINA', 'NABILA'];
                foreach ($femaleKeywords as $kw) {
                    if (str_contains($nameUpper, $kw)) {
                        $gender = 'P';
                        break;
                    }
                }

                $birthYear = match ($gradeLevel) {
                    10 => 2009,
                    11 => 2008,
                    12 => 2007,
                    default => 2008
                };
                $birthDate = "{$birthYear}-01-01";

                $username = $school->npsn . '_' . $nis;
                $email = $username . '@siswa.prestasiku.id';

                DB::beginTransaction();
                try {
                    $user = User::create([
                        'name' => $fullName,
                        'email' => $email,
                        'username' => $username,
                        'school_id' => $school->id,
                        'password' => $defaultPassword,
                        'must_change_password' => true,
                        'status' => 'active',
                    ]);
                    $user->assignRole('student');

                    Student::create([
                        'user_id' => $user->id,
                        'school_id' => $school->id,
                        'nis' => $nis,
                        'nisn' => $nisn,
                        'full_name' => $fullName,
                        'grade_level' => $gradeLevel,
                        'class_name' => $className,
                        'gender' => $gender,
                        'birth_date' => $birthDate,
                        'public_id' => 'std_' . Str::random(24),
                        'public_profile_enabled' => false,
                        'status' => 'active',
                    ]);

                    DB::commit();
                    $imported++;
                } catch (\Throwable $e) {
                    DB::rollBack();
                    $this->command?->warn("Gagal import {$fullName}: " . $e->getMessage());
                }
            }
        }

        $this->command?->info("Sukses mengimpor {$imported} siswa dari Data Siswa.xlsx into Database!");
    }
}
