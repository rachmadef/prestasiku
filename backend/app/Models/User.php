<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

#[Fillable([
    'name',
    'email',
    'username',
    'phone',
    'password',
    'school_id',
    'must_change_password',
    'password_changed_at',
    'last_login_at',
    'last_login_ip',
    'status',
])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable, SoftDeletes;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'must_change_password' => 'boolean',
            'password_changed_at' => 'datetime',
            'last_login_at' => 'datetime',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function student(): HasOne
    {
        return $this->hasOne(Student::class);
    }

    public function loginEvents(): HasMany
    {
        return $this->hasMany(LoginEvent::class);
    }

    public function isSuperAdmin(): bool
    {
        return $this->hasRole('super_admin');
    }

    public function isSchoolAdmin(): bool
    {
        return $this->hasRole('school_admin');
    }

    public function isStudent(): bool
    {
        return $this->hasRole('student');
    }

    /**
     * Generate a unique username based on the 1st word of a person's full name.
     */
    public static function generateUsernameFromName(string $name, ?int $ignoreUserId = null): string
    {
        $words = preg_split('/\s+/', trim($name));
        $firstWord = $words[0] ?? 'user';
        $baseUsername = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $firstWord));
        if (empty($baseUsername)) {
            $baseUsername = 'user';
        }

        $username = $baseUsername;
        $counter = 1;

        while (static::where('username', $username)->when($ignoreUserId, fn($q) => $q->where('id', '!=', $ignoreUserId))->exists()) {
            $username = $baseUsername . $counter;
            $counter++;
        }

        return $username;
    }
}
