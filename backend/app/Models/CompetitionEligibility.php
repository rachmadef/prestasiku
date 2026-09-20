<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'competition_id',
    'allowed_educational_levels',
    'allowed_grades',
    'min_age',
    'max_age',
    'allowed_provinces',
    'gender_restriction',
    'custom_rules',
])]
class CompetitionEligibility extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'allowed_educational_levels' => 'array',
            'allowed_grades' => 'array',
            'allowed_provinces' => 'array',
            'min_age' => 'integer',
            'max_age' => 'integer',
        ];
    }

    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }
}
