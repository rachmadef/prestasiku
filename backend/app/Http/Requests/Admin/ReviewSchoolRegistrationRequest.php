<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class ReviewSchoolRegistrationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSuperAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'action' => ['required', 'in:approve,reject'],
            'review_notes' => ['nullable', 'string', 'max:1000'],
            'admin_password' => ['nullable', 'string', 'min:6'],
        ];
    }

    public function messages(): array
    {
        return [
            'action.required' => 'Aksi persetujuan (approve atau reject) wajib dipilih.',
            'action.in' => 'Aksi harus berupa approve atau reject.',
        ];
    }
}
