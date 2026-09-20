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
    'registration_code',
    'competition_id',
    'form_version_id',
    'school_id',
    'student_id',
    'team_id',
    'registration_type',
    'registered_by',
    'status',
    'school_approval_status',
    'school_approved_by',
    'school_approved_at',
    'school_notes',
    'assignment_letter_number',
    'assignment_letter_file',
    'result_status',
    'rank_details',
    'certificate_file',
    'result_notes',
    'result_recorded_at',
])]
class Registration extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'school_approved_at' => 'datetime',
            'result_recorded_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Registration $registration) {
            if (empty($registration->registration_code)) {
                $registration->registration_code = 'REG-' . date('Y') . '-' . strtoupper(Str::random(8));
            }
        });
    }

    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }

    public function formVersion(): BelongsTo
    {
        return $this->belongsTo(CompetitionForm::class, 'form_version_id');
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    public function registeredBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'registered_by');
    }

    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'school_approved_by');
    }

    public function answers(): HasMany
    {
        return $this->hasMany(RegistrationAnswer::class);
    }

    public function scopePendingSchoolApproval(Builder $query): Builder
    {
        return $query->where('status', 'pending_school_approval');
    }

    public function scopeApprovedBySchool(Builder $query): Builder
    {
        return $query->where('school_approval_status', 'approved');
    }
}
