<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

#[Fillable([
    'reference_number',
    'school_id',
    'competition_id',
    'competition_name',
    'dispensation_type',
    'purpose',
    'start_date',
    'end_date',
    'start_time',
    'end_time',
    'is_all_day',
    'supervisor_name',
    'attachment_path',
    'status',
    'requested_by',
    'approved_by',
    'approved_at',
    'rejection_reason',
    'verification_token',
])]
class KbmDispensation extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
            'is_all_day' => 'boolean',
            'approved_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (KbmDispensation $dispensation) {
            if (empty($dispensation->verification_token)) {
                $dispensation->verification_token = Str::random(40);
            }
            if (empty($dispensation->reference_number)) {
                $year = date('Y');
                $random = strtoupper(Str::random(6));
                $dispensation->reference_number = "DISP-{$year}-{$random}";
            }
        });
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }

    public function requestedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function dispensationStudents(): HasMany
    {
        return $this->hasMany(KbmDispensationStudent::class, 'dispensation_id');
    }

    public function students(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'kbm_dispensation_students', 'dispensation_id', 'student_id')
            ->withPivot('notes')
            ->withTimestamps();
    }

    public function scopeApproved(Builder $query): Builder
    {
        return $query->where('status', 'approved');
    }

    public function scopePending(Builder $query): Builder
    {
        return $query->where('status', 'pending');
    }
}
