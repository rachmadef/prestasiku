<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'name',
    'type',
    'website',
    'instagram',
    'email',
    'phone',
    'verification_status',
    'verified_at',
    'verified_by',
    'verification_notes',
])]
class Organizer extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
        ];
    }

    public function competitions(): HasMany
    {
        return $this->hasMany(Competition::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
