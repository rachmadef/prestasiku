<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'competition_id',
    'school_id',
    'team_name',
    'leader_student_id',
    'created_by',
])]
class Team extends Model
{
    use HasFactory, SoftDeletes;

    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function leader(): BelongsTo
    {
        return $this->belongsTo(Student::class, 'leader_student_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function members(): HasMany
    {
        return $this->hasMany(TeamMember::class);
    }

    public function students(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'team_members')
            ->withPivot('role_in_team')
            ->withTimestamps();
    }

    public function registration(): HasOne
    {
        return $this->hasOne(Registration::class);
    }
}
