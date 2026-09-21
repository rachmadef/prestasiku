<?php

namespace App\Mail;

use App\Models\School;
use App\Models\SchoolRegistration;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class SchoolAdminAccountCreatedMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     */
    public function __construct(
        public School $school,
        public SchoolRegistration $registration,
        public User $adminUser,
        public string $temporaryPassword,
        public ?string $loginUrl = null
    ) {
        $this->loginUrl = $loginUrl ?: config('app.frontend_url', 'http://localhost:5173') . '/login';
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Persetujuan Registrasi Sekolah & Kredensial Akun Admin - ' . $this->school->name,
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.school_admin_account_created',
            with: [
                'school' => $this->school,
                'registration' => $this->registration,
                'adminUser' => $this->adminUser,
                'temporaryPassword' => $this->temporaryPassword,
                'loginUrl' => $this->loginUrl,
            ],
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
