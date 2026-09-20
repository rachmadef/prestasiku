<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreCompetitionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSuperAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'organizer_id' => ['required', 'exists:organizers,id'],
            'category_id' => ['required', 'exists:competition_categories,id'],
            'title' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'unique:competitions,slug'],
            'level' => ['required', 'in:provinsi,nasional'],
            'target_level' => ['required', 'in:sltp,slta,both'],
            'description' => ['required', 'string'],
            'official_website_url' => ['nullable', 'url', 'max:255'],
            'guide_book_url' => ['nullable', 'url', 'max:255'],
            'poster_url' => ['nullable', 'url', 'max:255'],
            'participation_type' => ['required', 'in:individual,team,both'],
            'min_team_members' => ['nullable', 'integer', 'min:1'],
            'max_team_members' => ['nullable', 'integer', 'min:1'],
            'requires_school_approval' => ['nullable', 'boolean'],
            'registration_fee' => ['nullable', 'numeric', 'min:0'],
            'registration_open_at' => ['required', 'date'],
            'registration_deadline' => ['required', 'date', 'after_or_equal:registration_open_at'],
            'event_start_at' => ['required', 'date'],
            'event_end_at' => ['required', 'date', 'after_or_equal:event_start_at'],
            'verification_status' => ['nullable', 'in:draft,pending_verification,source_verified,published'],
            'visibility' => ['nullable', 'in:public,school_only,hidden'],

            // Eligibility Rules
            'eligibility' => ['nullable', 'array'],
            'eligibility.allowed_educational_levels' => ['nullable', 'array'],
            'eligibility.allowed_grades' => ['nullable', 'array'],
            'eligibility.min_age' => ['nullable', 'integer', 'min:5', 'max:25'],
            'eligibility.max_age' => ['nullable', 'integer', 'min:5', 'max:25'],
            'eligibility.allowed_provinces' => ['nullable', 'array'],
            'eligibility.gender_restriction' => ['nullable', 'in:any,L,P'],
            'eligibility.custom_rules' => ['nullable', 'string'],

            // Sources
            'sources' => ['nullable', 'array'],
            'sources.*.source_type' => ['required_with:sources', 'in:puspresnas,official_website,instagram,news_portal,circular_letter,other'],
            'sources.*.source_url' => ['required_with:sources', 'url'],
            'sources.*.source_title' => ['nullable', 'string', 'max:255'],
            'sources.*.is_verified' => ['nullable', 'boolean'],

            // Dynamic Form Fields
            'form' => ['nullable', 'array'],
            'form.title' => ['nullable', 'string', 'max:150'],
            'form.fields' => ['nullable', 'array'],
            'form.fields.*.label' => ['required_with:form.fields', 'string', 'max:150'],
            'form.fields.*.field_key' => ['required_with:form.fields', 'string', 'max:100'],
            'form.fields.*.field_type' => ['required_with:form.fields', 'in:text,textarea,number,date,select,radio,checkbox,file,email,phone'],
            'form.fields.*.is_required' => ['nullable', 'boolean'],
            'form.fields.*.options' => ['nullable', 'array'],
            'form.fields.*.validation_rules' => ['nullable', 'array'],
        ];
    }
}
