<?php

namespace App\Services;

use SimpleSoftwareIO\QrCode\Facades\QrCode;

class QrCodeService
{
    /**
     * Get base URL for frontend SPA application.
     */
    protected function getFrontendBaseUrl(): string
    {
        $frontendUrl = env('FRONTEND_URL') ?: config('app.frontend_url');
        if ($frontendUrl) {
            return rtrim($frontendUrl, '/');
        }

        $appUrl = config('app.url', 'http://localhost:5173');
        // Map local Laravel dev server port 8000 to Vite SPA dev server port 5173
        $mappedUrl = str_replace(':8000', ':5173', $appUrl);

        return rtrim($mappedUrl, '/');
    }

    /**
     * Get the verification URL for a given public_id.
     */
    public function getVerificationUrl(string $publicId): string
    {
        $baseUrl = $this->getFrontendBaseUrl();
        return "{$baseUrl}/verify/{$publicId}";
    }

    /**
     * Generate raw SVG string for the QR code.
     */
    public function generateSvg(string $publicId, int $size = 250): string
    {
        $url = $this->getVerificationUrl($publicId);

        return (string) QrCode::size($size)
            ->margin(1)
            ->errorCorrection('M')
            ->generate($url);
    }

    /**
     * Generate base64 Data URI for embedding in HTML/JSON.
     */
    public function generateDataUri(string $publicId, int $size = 250): string
    {
        $svg = $this->generateSvg($publicId, $size);
        return 'data:image/svg+xml;base64,' . base64_encode($svg);
    }

    /**
     * Get the verification URL for a dispensation token.
     */
    public function getDispensationVerificationUrl(string $token): string
    {
        $baseUrl = $this->getFrontendBaseUrl();
        return "{$baseUrl}/dispensasi/verifikasi/{$token}";
    }

    /**
     * Generate raw SVG string for dispensation verification.
     */
    public function generateDispensationSvg(string $token, int $size = 250): string
    {
        $url = $this->getDispensationVerificationUrl($token);

        return (string) QrCode::size($size)
            ->margin(1)
            ->errorCorrection('M')
            ->generate($url);
    }

    /**
     * Generate base64 Data URI for dispensation QR code.
     */
    public function generateDispensationDataUri(string $token, int $size = 250): string
    {
        $svg = $this->generateDispensationSvg($token, $size);
        return 'data:image/svg+xml;base64,' . base64_encode($svg);
    }

    /**
     * Get the verification URL for a teacher/signer signature token.
     */
    public function getSignerVerificationUrl(string $token): string
    {
        $baseUrl = $this->getFrontendBaseUrl();
        return "{$baseUrl}/signer/verify/{$token}";
    }

    /**
     * Generate raw SVG string for teacher signature QR code verification.
     */
    public function generateSignerSvg(string $token, int $size = 250): string
    {
        $url = $this->getSignerVerificationUrl($token);

        return (string) QrCode::size($size)
            ->margin(1)
            ->errorCorrection('M')
            ->generate($url);
    }

    /**
     * Generate base64 Data URI for teacher signature QR code.
     */
    public function generateSignerDataUri(string $token, int $size = 250): string
    {
        $svg = $this->generateSignerSvg($token, $size);
        return 'data:image/svg+xml;base64,' . base64_encode($svg);
    }
}
