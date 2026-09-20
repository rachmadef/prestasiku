<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

#[Fillable([
    'user_id',
    'school_id',
    'nis',
    'nisn',
    'full_name',
    'grade_level',
    'class_name',
    'gender',
    'birth_date',
    'birth_place',
    'phone_number',
    'public_id',
    'public_profile_enabled',
    'status',
])]
class Student extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'public_profile_enabled' => 'boolean',
            'grade_level' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Student $student) {
            if (empty($student->public_id)) {
                $student->public_id = 'PKU-STD-' . strtoupper(Str::random(8));
            }
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function achievements(): HasMany
    {
        return $this->hasMany(Achievement::class);
    }

    public function dispensations()
    {
        return $this->belongsToMany(KbmDispensation::class, 'kbm_dispensation_students', 'student_id', 'dispensation_id')
            ->withPivot('notes')
            ->withTimestamps();
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active');
    }
}
