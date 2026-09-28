<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'organizer_id',
    'category_id',
    'curation_type',
    'curation_rating',
    'curation_number',
    'title',
    'slug',
    'level',
    'target_level',
    'description',
    'official_website_url',
    'registration_url',
    'guide_book_url',
    'poster_url',
    'participation_type',
    'min_team_members',
    'max_team_members',
    'requires_school_approval',
    'registration_fee',
    'registration_open_at',
    'registration_deadline',
    'event_start_at',
    'event_end_at',
    'result_published_at',
    'verification_status',
    'visibility',
    'verified_by',
    'verified_at',
    'verification_notes',
    'published_at',
])]
class Competition extends Model
{
    use HasFactory, SoftDeletes;

    protected function casts(): array
    {
        return [
            'registration_open_at' => 'datetime',
            'registration_deadline' => 'datetime',
            'event_start_at' => 'datetime',
            'event_end_at' => 'datetime',
            'result_published_at' => 'datetime',
            'verified_at' => 'datetime',
            'published_at' => 'datetime',
            'requires_school_approval' => 'boolean',
            'registration_fee' => 'decimal:2',
            'min_team_members' => 'integer',
            'max_team_members' => 'integer',
        ];
    }

    protected $appends = [
        'name',
        'educational_level',
        'scope',
        'official_url',
    ];

    public function getNameAttribute(): string
    {
        return $this->attributes['title'] ?? '';
    }

    public function getEducationalLevelAttribute(): string
    {
        return $this->attributes['target_level'] ?? 'slta';
    }

    public function getScopeAttribute(): string
    {
        return $this->attributes['level'] ?? 'nasional';
    }

    public function getOfficialUrlAttribute(): ?string
    {
        return $this->attributes['official_website_url'] ?? null;
    }

    public function organizer(): BelongsTo
    {
        return $this->belongsTo(Organizer::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(CompetitionCategory::class, 'category_id');
    }

    public function sources(): HasMany
    {
        return $this->hasMany(CompetitionSource::class);
    }

    public function eligibility(): HasOne
    {
        return $this->hasOne(CompetitionEligibility::class);
    }

    public function forms(): HasMany
    {
        return $this->hasMany(CompetitionForm::class);
    }

    public function activeForm(): HasOne
    {
        return $this->hasOne(CompetitionForm::class)->where('is_active', true)->latestOfMany();
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('verification_status', 'published')
            ->where('visibility', 'public');
    }

    public function scopeUpcoming(Builder $query): Builder
    {
        $now = now();
        return $query->where(function (Builder $q) use ($now) {
            $q->where('registration_deadline', '>=', $now)
                ->orWhere('event_start_at', '>=', $now)
                ->orWhere('event_end_at', '>=', $now)
                ->orWhereNull('registration_deadline');
        });
    }

    public function scopeRegistrationOpen(Builder $query): Builder
    {
        $now = now();
        return $query->where(function (Builder $q) use ($now) {
            $q->where(function (Builder $sub) use ($now) {
                $sub->whereNull('registration_open_at')
                    ->orWhere('registration_open_at', '<=', $now);
            })->where(function (Builder $sub) use ($now) {
                $sub->whereNull('registration_deadline')
                    ->orWhere('registration_deadline', '>=', $now);
            });
        });
    }

    public function scopeRegistrationNotStarted(Builder $query): Builder
    {
        $now = now();
        return $query->where('registration_open_at', '>', $now);
    }

    public function scopeCompleted(Builder $query): Builder
    {
        $now = now();
        return $query->where(function (Builder $q) use ($now) {
            $q->where('event_end_at', '<', $now)
                ->orWhere('registration_deadline', '<', $now);
        });
    }

    public function scopeThisMonth(Builder $query): Builder
    {
        $start = now()->startOfMonth();
        $end = now()->endOfMonth();

        return $query->where(function (Builder $q) use ($start, $end) {
            $q->whereBetween('registration_deadline', [$start, $end])
                ->orWhereBetween('event_start_at', [$start, $end])
                ->orWhere(function (Builder $sub) use ($start, $end) {
                    $sub->where('registration_open_at', '<=', $end)
                        ->where('registration_deadline', '>=', $start);
                });
        });
    }

    public function scopeNextMonth(Builder $query): Builder
    {
        $start = now()->addMonth()->startOfMonth();
        $end = now()->addMonth()->endOfMonth();

        return $query->where(function (Builder $q) use ($start, $end) {
            $q->whereBetween('registration_deadline', [$start, $end])
                ->orWhereBetween('event_start_at', [$start, $end])
                ->orWhere(function (Builder $sub) use ($start, $end) {
                    $sub->where('registration_open_at', '<=', $end)
                        ->where('registration_deadline', '>=', $start);
                });
        });
    }

    public function scopeCurationType(Builder $query, string $type): Builder
    {
        return $query->where('curation_type', $type);
    }

    public function scopeResmiNegara(Builder $query): Builder
    {
        return $query->where('curation_type', 'resmi_negara');
    }

    public function scopeTerkurasiPuspresnas(Builder $query): Builder
    {
        return $query->where('curation_type', 'terkurasi_puspresnas');
    }

    public function scopeBergengsiNonKurasi(Builder $query): Builder
    {
        return $query->where('curation_type', 'bergengsi_non_kurasi');
    }
}
