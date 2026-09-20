<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrganizerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSuperAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:kementerian,dinas_pendidikan,perguruan_tinggi,organisasi_profesi,swasta,komunitas,lainnya'],
            'website' => ['nullable', 'url', 'max:255'],
            'instagram' => ['nullable', 'string', 'max:100'],
            'email' => ['nullable', 'email', 'max:150'],
            'phone' => ['nullable', 'string', 'max:25'],
            'verification_status' => ['nullable', 'in:unverified,verified,official'],
            'verification_notes' => ['nullable', 'string'],
        ];
    }
}
