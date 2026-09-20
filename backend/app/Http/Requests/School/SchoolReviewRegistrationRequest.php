<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;

class SchoolReviewRegistrationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSchoolAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'action' => ['required', 'in:approve,reject'],
            'assignment_letter_number' => ['nullable', 'string', 'max:100'],
            'assignment_letter_file' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'], // Max 5MB
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'action.required' => 'Keputusan persetujuan (approve atau reject) wajib dipilih.',
            'assignment_letter_file.mimes' => 'Berkas surat tugas harus berupa PDF, JPG, atau PNG.',
        ];
    }
}
