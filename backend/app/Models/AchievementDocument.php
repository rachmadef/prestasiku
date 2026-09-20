<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AchievementDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'achievement_id',
        'document_type',
        'document_number',
        'file_path',
        'external_url',
        'file_name',
        'file_size',
        'file_mime',
    ];

    public function achievement(): BelongsTo
    {
        return $this->belongsTo(Achievement::class);
    }
}
