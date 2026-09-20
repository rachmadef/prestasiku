<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'npsn',
    'school_name',
    'educational_level',
    'province',
    'city',
    'district',
    'address',
    'pic_name',
    'pic_email',
    'pic_phone',
    'pic_position',
    'document_path',
    'status',
    'reviewed_by',
    'reviewed_at',
    'review_notes',
])]
class SchoolRegistration extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'reviewed_at' => 'datetime',
        ];
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function scopePending(Builder $query): Builder
    {
        return $query->where('status', 'pending');
    }
}
