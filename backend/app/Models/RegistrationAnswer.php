<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'registration_id',
    'form_field_id',
    'field_key',
    'field_label',
    'answer_value',
    'file_path',
])]
class RegistrationAnswer extends Model
{
    use HasFactory;

    public function registration(): BelongsTo
    {
        return $this->belongsTo(Registration::class);
    }

    public function field(): BelongsTo
    {
        return $this->belongsTo(FormField::class, 'form_field_id');
    }
}
