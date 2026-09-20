<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'school_id',
    'user_id',
    'file_name',
    'file_path',
    'total_rows',
    'successful_rows',
    'failed_rows',
    'errors',
    'status',
])]
class ImportRecord extends Model
{
    use HasFactory;

    protected $table = 'imports';

    protected function casts(): array
    {
        return [
            'errors' => 'array',
            'total_rows' => 'integer',
            'successful_rows' => 'integer',
            'failed_rows' => 'integer',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
