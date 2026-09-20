<?php

namespace App\Services;

use App\Models\Competition;
use App\Models\Student;

class EligibilityService
{
    /**
     * Check if a student meets all eligibility criteria for a given competition.
     */
    public function checkEligibility(Student $student, Competition $competition): array
    {
        $passedCriteria = [];
        $failedCriteria = [];

        $student->loadMissing('school');
        $competition->loadMissing('eligibility');
        $eligibility = $competition->eligibility;

        // 1. Check School Educational Level
        $schoolLevel = $student->school?->educational_level ?? 'slta';
        $compTarget = $competition->target_level;

        $levelMatches = ($compTarget === 'both')
            || ($schoolLevel === 'both')
            || ($schoolLevel === $compTarget);

        if ($levelMatches) {
            $passedCriteria[] = "Jenjang pendidikan sekolah ({$schoolLevel}) sesuai target kompetisi ({$compTarget}).";
        } else {
            $failedCriteria[] = "Jenjang sekolah siswa ({$schoolLevel}) tidak memenuhi target jenjang kompetisi ({$compTarget}).";
        }

        // 2. Check Allowed Educational Levels in Eligibility rule
        if ($eligibility && ! empty($eligibility->allowed_educational_levels)) {
            $allowedLevels = $eligibility->allowed_educational_levels;
            if (in_array($schoolLevel, $allowedLevels) || $schoolLevel === 'both') {
                $passedCriteria[] = 'Tingkat pendidikan instansi masuk dalam daftar yang diizinkan.';
            } else {
                $failedCriteria[] = 'Tingkat pendidikan instansi tidak masuk dalam kriteria yang diizinkan: ' . implode(', ', $allowedLevels) . '.';
            }
        }

        // 3. Check Grade Level
        if ($eligibility && ! empty($eligibility->allowed_grades)) {
            if (in_array((int) $student->grade_level, $eligibility->allowed_grades)) {
                $passedCriteria[] = "Tingkat kelas siswa (Kelas {$student->grade_level}) memenuhi syarat.";
            } else {
                $failedCriteria[] = "Tingkat kelas siswa (Kelas {$student->grade_level}) tidak memenuhi syarat (yang diizinkan: Kelas " . implode(', ', $eligibility->allowed_grades) . ').';
            }
        }

        // 4. Check Age Criteria
        if ($student->birth_date) {
            $age = $student->birth_date->age;

            if ($eligibility && $eligibility->min_age && $age < $eligibility->min_age) {
                $failedCriteria[] = "Usia siswa ({$age} tahun) kurang dari batas minimal ({$eligibility->min_age} tahun).";
            } elseif ($eligibility && $eligibility->min_age) {
                $passedCriteria[] = "Usia siswa ({$age} tahun) memenuhi batas minimal ({$eligibility->min_age} tahun).";
            }

            if ($eligibility && $eligibility->max_age && $age > $eligibility->max_age) {
                $failedCriteria[] = "Usia siswa ({$age} tahun) melebihi batas maksimal ({$eligibility->max_age} tahun).";
            } elseif ($eligibility && $eligibility->max_age) {
                $passedCriteria[] = "Usia siswa ({$age} tahun) memenuhi batas maksimal ({$eligibility->max_age} tahun).";
            }
        }

        // 5. Check Regional / Province restriction for Provincial Competitions
        if ($competition->level === 'provinsi' && $eligibility && ! empty($eligibility->allowed_provinces)) {
            $schoolProvince = $student->school?->province;
            if ($schoolProvince && in_array($schoolProvince, $eligibility->allowed_provinces)) {
                $passedCriteria[] = "Wilayah domisili sekolah ({$schoolProvince}) memenuhi cakupan kompetisi.";
            } else {
                $failedCriteria[] = "Wilayah provinsi sekolah ({$schoolProvince}) tidak termasuk cakupan kompetisi provinsi ini (" . implode(', ', $eligibility->allowed_provinces) . ').';
            }
        }

        // 6. Check Gender Restriction
        if ($eligibility && $eligibility->gender_restriction && $eligibility->gender_restriction !== 'any') {
            if ($student->gender === $eligibility->gender_restriction) {
                $passedCriteria[] = 'Jenis kelamin siswa sesuai dengan persyaratan kompetisi.';
            } else {
                $expected = $eligibility->gender_restriction === 'L' ? 'Laki-laki' : 'Perempuan';
                $failedCriteria[] = "Kompetisi ini dibatasi khusus peserta berjenis kelamin {$expected}.";
            }
        }

        // 7. Check Registration Window
        $now = now();
        if ($now->lt($competition->registration_open_at)) {
            $failedCriteria[] = 'Pendaftaran belum dibuka (dibuka pada ' . $competition->registration_open_at->format('d M Y H:i') . ').';
        } elseif ($now->gt($competition->registration_deadline)) {
            $failedCriteria[] = 'Batas akhir pendaftaran telah berakhir pada ' . $competition->registration_deadline->format('d M Y H:i') . '.';
        } else {
            $passedCriteria[] = 'Periode pendaftaran sedang aktif (dibuka s.d. ' . $competition->registration_deadline->format('d M Y H:i') . ').';
        }

        return [
            'is_eligible' => count($failedCriteria) === 0,
            'student' => [
                'id' => $student->id,
                'full_name' => $student->full_name,
                'nis' => $student->nis,
                'grade_level' => $student->grade_level,
                'gender' => $student->gender,
                'school' => [
                    'id' => $student->school?->id,
                    'name' => $student->school?->name,
                    'province' => $student->school?->province,
                    'educational_level' => $student->school?->educational_level,
                ],
            ],
            'competition' => [
                'id' => $competition->id,
                'title' => $competition->title,
                'level' => $competition->level,
                'target_level' => $competition->target_level,
                'registration_deadline' => $competition->registration_deadline,
            ],
            'passed_criteria' => $passedCriteria,
            'failed_criteria' => $failedCriteria,
        ];
    }
}
