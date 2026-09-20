<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', \App\Models\Student::class) ?? false;
    }

    public function rules(): array
    {
        $schoolId = $this->user()->school_id;

        return [
            'nis' => [
                'required',
                'string',
                'max:30',
                Rule::unique('students', 'nis')->where('school_id', $schoolId),
            ],
            'nisn' => ['nullable', 'string', 'max:20'],
            'full_name' => ['required', 'string', 'max:150'],
            'grade_level' => ['required', 'integer', 'between:7,12'],
            'class_name' => ['required', 'string', 'max:50'],
            'gender' => ['required', 'in:L,P'],
            'birth_date' => ['required', 'date'],
            'birth_place' => ['nullable', 'string', 'max:100'],
            'phone_number' => ['nullable', 'string', 'max:25'],
            'email' => ['nullable', 'email', 'max:150', 'unique:users,email'],
        ];
    }

    public function messages(): array
    {
        return [
            'nis.required' => 'NIS siswa wajib diisi.',
            'nis.unique' => 'NIS ini sudah terdaftar di sekolah Anda.',
            'full_name.required' => 'Nama lengkap siswa wajib diisi.',
            'grade_level.required' => 'Tingkat kelas wajib diisi (7-9 untuk SLTP, 10-12 untuk SLTA).',
            'class_name.required' => 'Nama kelas wajib diisi (misal: X IPA 1, VIII-B).',
            'gender.required' => 'Jenis kelamin wajib dipilih (L / P).',
            'birth_date.required' => 'Tanggal lahir wajib diisi.',
        ];
    }
}
