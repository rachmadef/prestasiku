<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class CompetitionSupervisor extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'school_id',
        'competition_id',
        'competition_name',
        'organizer_name',
        'competition_branch',
        'student_names',
        'student_ids',
        'competition_category',
        'competition_place',
        'competition_level',
        'event_date',
        'supervisor_name',
        'supervisor_nip',
        'supervisor_phone',
        'supervisor_category',
        'supervisor_gender',
        'role_title',
        'duty_zone',
        'bisyaroh_amount',
        'reference_number',
        'statement_agreed',
        'public_token',
        'sop_category',
        'notes',
        'status',
        'created_by',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'bisyaroh_amount' => 'decimal:2',
        'student_ids' => 'array',
        'statement_agreed' => 'boolean',
        'approved_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function (CompetitionSupervisor $supervisor) {
            if (empty($supervisor->public_token)) {
                $supervisor->public_token = \Illuminate\Support\Str::random(32);
            }
            if (empty($supervisor->reference_number)) {
                $count = static::where('school_id', $supervisor->school_id)->count() + 1;
                $romanMonth = match ((int) date('n')) {
                    1 => 'I', 2 => 'II', 3 => 'III', 4 => 'IV', 5 => 'V', 6 => 'VI',
                    7 => 'VII', 8 => 'VIII', 9 => 'IX', 10 => 'X', 11 => 'XI', 12 => 'XII',
                    default => 'X',
                };
                $supervisor->reference_number = sprintf('%03d/MAU.WH/PENDAMPING/%s/%s', $count, $romanMonth, date('Y'));
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

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}

