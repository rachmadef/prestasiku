<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'npsn',
    'name',
    'educational_level',
    'status',
    'province',
    'city',
    'district',
    'address',
    'postal_code',
    'phone',
    'email',
    'website',
    'verified_at',
    'verified_by',
    'verification_notes',
    'dispensation_form_schema',
    'letterhead_image_path',
    'letterhead_type',
    'letter_format_config',
    'dispensation_docx_template_path',
])]
class School extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
            'dispensation_form_schema' => 'array',
            'letter_format_config' => 'array',
        ];
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }

    public function imports(): HasMany
    {
        return $this->hasMany(ImportRecord::class);
    }

    public function achievements(): HasMany
    {
        return $this->hasMany(Achievement::class);
    }

    public function dispensations(): HasMany
    {
        return $this->hasMany(KbmDispensation::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function scopeVerified(Builder $query): Builder
    {
        return $query->where('status', 'verified');
    }
}
