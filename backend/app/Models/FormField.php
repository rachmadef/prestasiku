<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'form_id',
    'label',
    'field_key',
    'field_type',
    'placeholder',
    'help_text',
    'is_required',
    'options',
    'validation_rules',
    'conditional_rule',
    'order',
])]
class FormField extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'is_required' => 'boolean',
            'options' => 'array',
            'validation_rules' => 'array',
            'conditional_rule' => 'array',
            'order' => 'integer',
        ];
    }

    public function form(): BelongsTo
    {
        return $this->belongsTo(CompetitionForm::class, 'form_id');
    }
}
