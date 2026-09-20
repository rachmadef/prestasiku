<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveUser
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user) {
            if ($user->status !== 'active') {
                return response()->json([
                    'success' => false,
                    'message' => 'Akun Anda saat ini sedang dinonaktifkan atau ditangguhkan.',
                    'code' => 'ACCOUNT_SUSPENDED',
                ], 403);
            }

            if ($user->school_id && $user->school && $user->school->status === 'suspended') {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses instansi sekolah Anda sedang ditangguhkan. Silakan hubungi Super Admin.',
                    'code' => 'SCHOOL_SUSPENDED',
                ], 403);
            }
        }

        return $next($request);
    }
}
