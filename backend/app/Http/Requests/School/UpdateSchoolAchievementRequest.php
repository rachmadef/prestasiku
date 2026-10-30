<?php

namespace App\Http\Requests\School;

use App\Models\Achievement;
use App\Models\Student;
use Illuminate\Foundation\Http\FormRequest;

class UpdateSchoolAchievementRequest extends FormRequest
{
    public function authorize(): bool
    {
        $achievement = $this->route('achievement');
        if (is_numeric($achievement)) {
            $achievement = Achievement::find($achievement);
        }

        return $achievement && $this->user()?->can('update', $achievement);
    }

    protected function prepareForValidation(): void
    {
        if ($this->level === 'kabupaten') {
            $this->merge(['level' => 'kota_kabupaten']);
        }
    }

    public function rules(): array
    {
        return [
            'student_id' => [
                'sometimes',
                'required',
                'exists:students,id',
                function ($attribute, $value, $fail) {
                    if ($this->user()->isSchoolAdmin()) {
                        $student = Student::find($value);
                        if ($student && $student->school_id !== $this->user()->school_id) {
                            $fail('Siswa tersebut bukan berasal dari sekolah Anda.');
                        }
                    }
                },
            ],
            'title' => ['sometimes', 'required', 'string', 'max:255'],
            'level' => ['sometimes', 'required', 'in:kota_kabupaten,provinsi,nasional,internasional'],
            'rank' => ['sometimes', 'required', 'string', 'max:100'],
            'event_name' => ['sometimes', 'required', 'string', 'max:255'],
            'organizer_name' => ['sometimes', 'required', 'string', 'max:255'],
            'event_date' => ['sometimes', 'required', 'date'],
            'competition_id' => ['nullable', 'exists:competitions,id'],
            'is_public' => ['nullable', 'boolean'],
            'status' => ['nullable', 'in:draft,pending_verification,verified,rejected'],
            'document_type' => ['nullable', 'in:certificate,decree_sk,assignment_letter,result_link,photo_documentation'],
            'document_number' => ['nullable', 'string', 'max:100'],
            'certificate_file' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
            'external_url' => ['nullable', 'url', 'max:500'],
        ];
    }
}

