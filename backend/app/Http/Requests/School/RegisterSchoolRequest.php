<?php

namespace App\Http\Requests\School;

use Illuminate\Foundation\Http\FormRequest;

class RegisterSchoolRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Prepare inputs before validation.
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('name') && !$this->filled('school_name')) {
            $this->merge([
                'school_name' => $this->input('name'),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'npsn' => ['required', 'string', 'max:20', 'unique:schools,npsn'],
            'school_name' => ['required', 'string', 'max:255'],
            'educational_level' => ['required', 'in:sltp,slta,both'],
            'province' => ['required', 'string', 'max:100'],
            'city' => ['required', 'string', 'max:100'],
            'district' => ['nullable', 'string', 'max:100'],
            'address' => ['nullable', 'string'],
            'pic_name' => ['required', 'string', 'max:150'],
            'pic_email' => ['required', 'email', 'max:150'],
            'pic_phone' => ['required', 'string', 'max:25'],
            'pic_position' => ['required', 'string', 'max:100'],
            'document' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'], // Max 5MB
        ];
    }

    public function messages(): array
    {
        return [
            'npsn.required' => 'NPSN sekolah wajib diisi.',
            'npsn.unique' => 'NPSN sudah terdaftar di sistem.',
            'school_name.required' => 'Nama sekolah wajib diisi.',
            'educational_level.required' => 'Jenjang pendidikan wajib dipilih.',
            'educational_level.in' => 'Jenjang pendidikan harus berupa SLTP, SLTA, atau Keduanya.',
            'province.required' => 'Provinsi wajib diisi.',
            'city.required' => 'Kota/Kabupaten wajib diisi.',
            'pic_name.required' => 'Nama penanggung jawab wajib diisi.',
            'pic_email.required' => 'Email penanggung jawab wajib diisi.',
            'pic_email.email' => 'Format email tidak valid.',
            'pic_phone.required' => 'Nomor HP/WhatsApp penanggung jawab wajib diisi.',
            'pic_position.required' => 'Jabatan penanggung jawab wajib diisi.',
            'document.mimes' => 'Format berkas harus berupa PDF, JPG, atau PNG.',
            'document.max' => 'Ukuran berkas maksimal adalah 5MB.',
        ];
    }
}
