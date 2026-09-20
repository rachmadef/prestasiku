<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Achievement extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'public_id',
        'student_id',
        'school_id',
        'competition_id',
        'registration_id',
        'title',
        'level',
        'rank',
        'event_name',
        'organizer_name',
        'event_date',
        'status',
        'verified_by',
        'verified_at',
        'verification_notes',
        'is_public',
    ];

    protected $casts = [
        'event_date' => 'date',
        'verified_at' => 'datetime',
        'is_public' => 'boolean',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->public_id)) {
                $year = date('Y');
                do {
                    $randomHex = strtoupper(Str::random(8));
                    $publicId = "PKU-ACH-{$year}-{$randomHex}";
                } while (static::where('public_id', $publicId)->exists());

                $model->public_id = $publicId;
            }
        });
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }

    public function registration(): BelongsTo
    {
        return $this->belongsTo(Registration::class);
    }

    public function verifiedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function documents(): HasMany
    {
        return $this->hasMany(AchievementDocument::class);
    }

    public function scopeVerified($query)
    {
        return $query->where('status', 'verified');
    }

    /**
     * Mask a person's name for privacy compliance (e.g. "Ahmad Bintang Pratama" -> "Ah*** Bin*** Pra***")
     */
    public function getMaskedStudentName(): string
    {
        $fullName = $this->student?->user?->name ?? 'Siswa';
        $words = explode(' ', trim($fullName));
        $maskedWords = array_map(function ($word) {
            $len = mb_strlen($word);
            if ($len <= 2) {
                return $word . '***';
            }
            return mb_substr($word, 0, 2) . '***';
        }, $words);

        return implode(' ', $maskedWords);
    }
}
