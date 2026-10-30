<?php

namespace App\Http\Requests\School;

use App\Models\Student;
use Illuminate\Foundation\Http\FormRequest;

class StoreSchoolAchievementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && ($this->user()->isSchoolAdmin() || $this->user()->isSuperAdmin());
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
            'title' => ['required', 'string', 'max:255'],
            'level' => ['required', 'in:kota_kabupaten,provinsi,nasional,internasional'],
            'rank' => ['required', 'string', 'max:100'],
            'event_name' => ['required', 'string', 'max:255'],
            'organizer_name' => ['required', 'string', 'max:255'],
            'event_date' => ['required', 'date'],
            'competition_id' => ['nullable', 'exists:competitions,id'],
            'registration_id' => ['nullable', 'exists:registrations,id'],
            'is_public' => ['boolean'],
            'status' => ['nullable', 'in:draft,pending_verification,verified'],
            'document_type' => ['nullable', 'in:certificate,decree_sk,assignment_letter,result_link,photo_documentation'],
            'document_number' => ['nullable', 'string', 'max:100'],
            'certificate_file' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
            'external_url' => ['nullable', 'url', 'max:500'],
        ];
    }
}
