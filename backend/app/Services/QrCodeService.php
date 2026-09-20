<?php

namespace App\Services;

use SimpleSoftwareIO\QrCode\Facades\QrCode;

class QrCodeService
{
    /**
     * Get the verification URL for a given public_id.
     */
    public function getVerificationUrl(string $publicId): string
    {
        $baseUrl = rtrim(config('app.url', 'http://localhost:8000'), '/');
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
}
