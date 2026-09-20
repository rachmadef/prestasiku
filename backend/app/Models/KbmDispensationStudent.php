<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'dispensation_id',
    'student_id',
    'notes',
])]
class KbmDispensationStudent extends Model
{
    use HasFactory;

    public function dispensation(): BelongsTo
    {
        return $this->belongsTo(KbmDispensation::class, 'dispensation_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
