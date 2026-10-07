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
        'supervisor_name',
        'supervisor_nip',
        'supervisor_phone',
        'role_title',
        'bisyaroh_amount',
        'sop_category',
        'notes',
        'status',
        'created_by',
    ];

    protected $casts = [
        'bisyaroh_amount' => 'decimal:2',
    ];

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
}
