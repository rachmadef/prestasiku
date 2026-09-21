<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SanitizeInputMiddleware
{
    /**
     * Input fields that should be exempted from sanitization (e.g. passwords, binary tokens).
     *
     * @var array<int, string>
     */
    protected array $except = [
        'password',
        'current_password',
        'password_confirmation',
        'new_password',
        'new_password_confirmation',
    ];

    /**
     * Handle an incoming request and sanitize string inputs against XSS.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $input = $request->all();

        if (! empty($input)) {
            $sanitized = $this->sanitizeArray($input);
            $request->merge($sanitized);
        }

        return $next($request);
    }

    /**
     * Recursively sanitize input array values.
     */
    protected function sanitizeArray(array $data): array
    {
        foreach ($data as $key => $value) {
            if (in_array($key, $this->except, true)) {
                continue;
            }

            if (is_array($value)) {
                $data[$key] = $this->sanitizeArray($value);
            } elseif (is_string($value)) {
                // Strip HTML tags and trim whitespace to prevent Stored XSS
                $data[$key] = trim(strip_tags($value));
            }
        }

        return $data;
    }
}
