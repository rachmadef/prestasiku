<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;

class SchoolDirectRegistrationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSchoolAdmin() && ! empty($this->user()->school_id);
    }

    public function rules(): array
    {
        return [
            'competition_id' => ['required', 'exists:competitions,id'],
            'registration_type' => ['required', 'in:individual,team'],
            'student_id' => ['required_if:registration_type,individual', 'nullable', 'integer', 'exists:students,id'],
            'team_name' => ['required_if:registration_type,team', 'nullable', 'string', 'max:150'],
            'leader_student_id' => ['required_if:registration_type,team', 'nullable', 'integer', 'exists:students,id'],
            'team_members' => ['required_if:registration_type,team', 'nullable', 'array'],
            'team_members.*' => ['integer', 'exists:students,id'],
            'assignment_letter_number' => ['nullable', 'string', 'max:100'],
            'assignment_letter_file' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
            'answers' => ['nullable', 'array'],
            'answers.*.field_key' => ['required_with:answers', 'string'],
            'answers.*.value' => ['nullable'],
        ];
    }
}
