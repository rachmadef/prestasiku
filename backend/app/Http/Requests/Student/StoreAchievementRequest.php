<?php

namespace App\Http\Requests\Student;

use Illuminate\Foundation\Http\FormRequest;

class StoreAchievementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isStudent();
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'level' => ['required', 'in:kota_kabupaten,provinsi,nasional,internasional'],
            'rank' => ['required', 'string', 'max:100'],
            'event_name' => ['required', 'string', 'max:255'],
            'organizer_name' => ['required', 'string', 'max:255'],
            'event_date' => ['required', 'date'],
            'competition_id' => ['nullable', 'exists:competitions,id'],
            'registration_id' => ['nullable', 'exists:registrations,id'],
            'is_public' => ['boolean'],
            'document_type' => ['nullable', 'in:certificate,decree_sk,assignment_letter,result_link,photo_documentation'],
            'document_number' => ['nullable', 'string', 'max:100'],
            'certificate_file' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
            'external_url' => ['nullable', 'url', 'max:500'],
        ];
    }
}
