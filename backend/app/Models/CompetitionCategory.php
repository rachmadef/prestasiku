<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'name',
    'slug',
    'description',
    'icon',
])]
class CompetitionCategory extends Model
{
    use HasFactory;

    public function competitions(): HasMany
    {
        return $this->hasMany(Competition::class, 'category_id');
    }
}
