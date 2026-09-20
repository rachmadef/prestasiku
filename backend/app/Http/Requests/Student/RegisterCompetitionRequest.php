<?php

namespace App\Http\Requests\Student;

use Illuminate\Foundation\Http\FormRequest;

class RegisterCompetitionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isStudent() && ! empty($this->user()->student);
    }

    public function rules(): array
    {
        return [
            'competition_id' => ['required', 'exists:competitions,id'],
            'registration_type' => ['required', 'in:individual,team'],
            'team_name' => ['required_if:registration_type,team', 'nullable', 'string', 'max:150'],
            'team_members' => ['required_if:registration_type,team', 'nullable', 'array'],
            'team_members.*' => ['integer', 'exists:students,id'],
            'answers' => ['nullable', 'array'],
            'answers.*.field_key' => ['required_with:answers', 'string'],
            'answers.*.value' => ['nullable'],
        ];
    }

    public function messages(): array
    {
        return [
            'competition_id.required' => 'Kompetisi yang ingin didaftar wajib dipilih.',
            'registration_type.required' => 'Tipe pendaftaran (individual / team) wajib dipilih.',
            'team_name.required_if' => 'Nama tim wajib diisi untuk pendaftaran beregu.',
            'team_members.required_if' => 'Daftar anggota tim wajib dicantumkan untuk pendaftaran beregu.',
        ];
    }
}
