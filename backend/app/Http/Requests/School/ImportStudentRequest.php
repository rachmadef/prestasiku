<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;

class ImportStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->hasRole('school_admin') && ! empty($this->user()->school_id);
    }

    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'mimes:xlsx,xls,csv,txt', 'max:10240'], // Max 10MB
        ];
    }

    public function messages(): array
    {
        return [
            'file.required' => 'File dokumen import wajib diunggah.',
            'file.mimes' => 'Format file harus berupa Excel (.xlsx, .xls) atau CSV (.csv).',
            'file.max' => 'Ukuran file tidak boleh lebih dari 10MB.',
        ];
    }
}
