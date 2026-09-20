<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;

class VerifyAchievementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && ($this->user()->isSchoolAdmin() || $this->user()->isSuperAdmin());
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'in:verified,rejected'],
            'verification_notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
