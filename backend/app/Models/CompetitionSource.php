<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'competition_id',
    'source_type',
    'source_url',
    'source_title',
    'proof_document_path',
    'is_verified',
    'verified_by',
    'notes',
])]
class CompetitionSource extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'is_verified' => 'boolean',
        ];
    }

    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
