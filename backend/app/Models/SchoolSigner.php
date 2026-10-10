<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class SchoolSigner extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'school_id',
        'name',
        'nip',
        'position_title',
        'role_type',
        'signature_token',
        'photo_path',
        'birth_place',
        'birth_date',
        'address',
        'education_history',
        'biography',
        'phone',
        'email',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'birth_date' => 'date',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    protected static function booted()
    {
        static::creating(function ($signer) {
            if (empty($signer->signature_token)) {
                $signer->signature_token = Str::random(40);
            }
        });
    }
}
