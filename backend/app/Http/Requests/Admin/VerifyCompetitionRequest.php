<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class VerifyCompetitionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSuperAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'in:draft,pending_verification,source_verified,published,cancelled,rejected,expired'],
            'verification_notes' => ['nullable', 'string', 'max:1000'],
            'visibility' => ['nullable', 'in:public,school_only,hidden'],
        ];
    }
}
