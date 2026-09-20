<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePasswordIsChanged
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user && $user->must_change_password) {
            // Whitelist routes allowed while password change is required
            $allowedRoutes = [
                'api.v1.auth.change-password',
                'api.v1.auth.logout',
                'api.v1.auth.me',
            ];

            if (! in_array($request->route()?->getName(), $allowedRoutes)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda wajib mengganti password default Anda terlebih dahulu sebelum dapat mengakses fitur aplikasi demi keamanan akun Anda.',
                    'code' => 'MUST_CHANGE_PASSWORD',
                ], 403);
            }
        }

        return $next($request);
    }
}
