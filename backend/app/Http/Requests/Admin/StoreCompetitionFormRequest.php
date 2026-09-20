<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreCompetitionFormRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSuperAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'fields' => ['required', 'array', 'min:1'],
            'fields.*.label' => ['required', 'string', 'max:150'],
            'fields.*.field_key' => ['required', 'string', 'max:100'],
            'fields.*.field_type' => ['required', 'in:text,textarea,number,date,select,radio,checkbox,file,email,phone'],
            'fields.*.placeholder' => ['nullable', 'string', 'max:150'],
            'fields.*.help_text' => ['nullable', 'string', 'max:255'],
            'fields.*.is_required' => ['nullable', 'boolean'],
            'fields.*.options' => ['nullable', 'array'],
            'fields.*.validation_rules' => ['nullable', 'array'],
            'fields.*.conditional_rule' => ['nullable', 'array'],
            'fields.*.order' => ['nullable', 'integer'],
        ];
    }
}
