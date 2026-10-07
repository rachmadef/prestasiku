<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class CompetitionPermission extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'reference_number',
        'school_id',
        'student_id',
        'competition_id',
        'competition_name',
        'competition_level',
        'news_url',
        'purpose',
        'event_start_date',
        'event_end_date',
        'parent_name',
        'parent_approval_status',
        'status',
        'custom_fields_data',
        'requested_by',
        'approved_by',
        'approved_at',
        'rejection_reason',
        'verification_token',
    ];

    protected $casts = [
        'event_start_date' => 'date',
        'event_end_date' => 'date',
        'approved_at' => 'datetime',
        'custom_fields_data' => 'array',
    ];

    protected static function booted(): void
    {
        static::creating(function (CompetitionPermission $perm) {
            if (empty($perm->verification_token)) {
                $perm->verification_token = Str::random(40);
            }
            if (empty($perm->reference_number)) {
                $year = date('Y');
                $random = strtoupper(Str::random(6));
                $perm->reference_number = "IZIN-{$year}-{$random}";
            }
        });
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
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
}
