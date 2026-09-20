<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        $student = $this->route('student');
        if (is_numeric($student)) {
            $student = \App\Models\Student::find($student);
        }

        return $student && $this->user()?->can('update', $student);
    }

    public function rules(): array
    {
        return [
            'full_name' => ['sometimes', 'required', 'string', 'max:150'],
            'grade_level' => ['sometimes', 'required', 'integer', 'between:7,12'],
            'class_name' => ['sometimes', 'required', 'string', 'max:50'],
            'gender' => ['sometimes', 'required', 'in:L,P'],
            'birth_date' => ['sometimes', 'required', 'date'],
            'birth_place' => ['nullable', 'string', 'max:100'],
            'phone_number' => ['nullable', 'string', 'max:25'],
            'status' => ['sometimes', 'required', 'in:active,graduated,transferred,inactive'],
            'public_profile_enabled' => ['sometimes', 'boolean'],
        ];
    }
}
