<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSchoolStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSuperAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'in:verified,suspended,rejected,pending'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
