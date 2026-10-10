<?php

namespace App\Imports;

use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use PhpOffice\PhpSpreadsheet\Shared\Date as ExcelDate;

class StudentsImport implements ToCollection, WithHeadingRow
{
    public int $totalRows = 0;
    public int $successfulRows = 0;
    public int $failedRows = 0;
    public array $errors = [];

    public function __construct(
        protected School $school,
        protected User $uploader
    ) {}

    public function collection(Collection $rows): void
    {
        $this->totalRows = $rows->count();

        foreach ($rows as $index => $row) {
            $rowNumber = $index + 2; // Accounting for 1-based index + header row

            $nis = trim((string) ($row['nis'] ?? ''));
            $fullName = trim((string) ($row['full_name'] ?? $row['nama_lengkap'] ?? $row['nama'] ?? ''));
            $gradeLevel = (int) ($row['grade_level'] ?? $row['tingkat_kelas'] ?? 0);
            $className = trim((string) ($row['class_name'] ?? $row['nama_kelas'] ?? $row['kelas'] ?? ''));
            $genderRaw = strtoupper(trim((string) ($row['gender'] ?? $row['jenis_kelamin'] ?? 'L')));
            $gender = in_array($genderRaw, ['L', 'LAKI-LAKI', 'PRIA', 'M']) ? 'L' : 'P';
            $rawBirthDate = $row['birth_date'] ?? $row['tanggal_lahir'] ?? null;
            $nisn = trim((string) ($row['nisn'] ?? '')) ?: null;
            $birthPlace = trim((string) ($row['birth_place'] ?? $row['tempat_lahir'] ?? '')) ?: null;
            $phoneNumber = trim((string) ($row['phone_number'] ?? $row['no_hp'] ?? '')) ?: null;
            $email = trim((string) ($row['email'] ?? '')) ?: null;

            // Validations
            if (empty($nis)) {
                $this->addError($rowNumber, 'Kolom NIS wajib diisi.');
                continue;
            }

            if (empty($fullName)) {
                $this->addError($rowNumber, "Nama lengkap untuk NIS {$nis} tidak boleh kosong.");
                continue;
            }

            if ($gradeLevel < 7 || $gradeLevel > 12) {
                $this->addError($rowNumber, "Tingkat kelas untuk NIS {$nis} harus antara 7 s.d. 12.");
                continue;
            }

            if (empty($className)) {
                $this->addError($rowNumber, "Nama kelas untuk NIS {$nis} tidak boleh kosong.");
                continue;
            }

            if (empty($rawBirthDate)) {
                $this->addError($rowNumber, "Tanggal lahir untuk NIS {$nis} wajib diisi.");
                continue;
            }

            // Parse birth date
            $birthDate = null;
            try {
                if (is_numeric($rawBirthDate)) {
                    $birthDate = ExcelDate::excelToDateTimeObject($rawBirthDate)->format('Y-m-d');
                } else {
                    $birthDate = date('Y-m-d', strtotime((string) $rawBirthDate));
                }
            } catch (\Throwable $e) {
                $this->addError($rowNumber, "Format tanggal lahir tidak valid untuk NIS {$nis}.");
                continue;
            }

            // Check if NIS already exists in this school
            $existingStudent = Student::where('school_id', $this->school->id)
                ->where('nis', $nis)
                ->first();

            if ($existingStudent) {
                $this->addError($rowNumber, "Siswa dengan NIS {$nis} sudah terdaftar di sekolah ini.");
                continue;
            }

            // Generate user email and username from 1st word of full_name
            $username = User::generateUsernameFromName($fullName);
            $userEmail = $email ?: ($username . '@siswa.prestasiku.id');

            // Handle potential email collisions
            if (User::where('email', $userEmail)->exists()) {
                $userEmail = $username . '_' . uniqid() . '@siswa.prestasiku.id';
            }

            DB::beginTransaction();
            try {
                $userData = [
                    'name' => $fullName,
                    'email' => $userEmail,
                    'username' => $username,
                    'phone' => $phoneNumber,
                    'password' => Hash::make('1234'),
                    'must_change_password' => true,
                    'status' => 'active',
                ];
                if (\Schema::hasColumn('users', 'school_id') && $this->school?->id) {
                    $userData['school_id'] = $this->school->id;
                }

                // 1. Create User account with default password '1234'
                $user = User::create($userData);
                $user->assignRole('student');

                // 2. Create Student record
                $studentData = [
                    'user_id' => $user->id,
                    'nis' => $nis,
                    'nisn' => $nisn,
                    'full_name' => $fullName,
                    'grade_level' => $gradeLevel,
                    'class_name' => $className,
                    'gender' => $gender,
                    'birth_date' => $birthDate,
                    'birth_place' => $birthPlace,
                    'phone_number' => $phoneNumber,
                    'public_profile_enabled' => false,
                    'status' => 'active',
                ];
                if (\Schema::hasColumn('students', 'school_id') && $this->school?->id) {
                    $studentData['school_id'] = $this->school->id;
                }

                Student::create($studentData);

                DB::commit();
                $this->successfulRows++;
            } catch (\Throwable $e) {
                DB::rollBack();
                $this->addError($rowNumber, "Gagal menyimpan data baris {$rowNumber}: " . $e->getMessage());
            }
        }
    }

    protected function addError(int $rowNumber, string $message): void
    {
        $this->failedRows++;
        $this->errors[] = [
            'row' => $rowNumber,
            'message' => $message,
        ];
    }
}
