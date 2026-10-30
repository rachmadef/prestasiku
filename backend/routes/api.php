<?php

use App\Http\Controllers\Api\V1\Admin\CompetitionCategoryController;
use App\Http\Controllers\Api\V1\Admin\CompetitionManagementController;
use App\Http\Controllers\Api\V1\Admin\OrganizerController;
use App\Http\Controllers\Api\V1\Admin\SchoolManagementController;
use App\Http\Controllers\Api\V1\Admin\SchoolRegistrationReviewController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CompetitionEligibilityController;
use App\Http\Controllers\Api\V1\Public\CompetitionCatalogController;
use App\Http\Controllers\Api\V1\Public\PublicDispensationVerificationController;
use App\Http\Controllers\Api\V1\Public\PublicVerificationController;
use App\Http\Controllers\Api\V1\School\SchoolAchievementController;
use App\Http\Controllers\Api\V1\School\SchoolDispensationController;
use App\Http\Controllers\Api\V1\School\SchoolRegistrationManagementController;
use App\Http\Controllers\Api\V1\School\StudentImportController;
use App\Http\Controllers\Api\V1\School\StudentManagementController;
use App\Http\Controllers\Api\V1\SchoolRegistrationController;
use App\Http\Controllers\Api\V1\Student\StudentAchievementController;
use App\Http\Controllers\Api\V1\Student\StudentDispensationController;
use App\Http\Controllers\Api\V1\Student\StudentRegistrationController;
use App\Http\Controllers\Api\V1\Student\StudentPermissionController;
use App\Http\Controllers\Api\V1\School\SchoolSupervisorController;
use App\Http\Controllers\Api\V1\School\SchoolPermissionController;
use App\Http\Controllers\Api\V1\School\SchoolSignerController;
use App\Http\Controllers\Api\V1\Public\PublicSignerVerificationController;
use App\Http\Controllers\Api\V1\ChatbotController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->name('api.v1.')->group(function () {
    // -------------------------------------------------------------
    // Public Endpoints (Throttled for brute-force & scraping protection)
    // -------------------------------------------------------------
    Route::post('/chatbot/chat', [ChatbotController::class, 'chat'])
        ->middleware('throttle:30,1')
        ->name('chatbot.chat');

    Route::post('/auth/login', [AuthController::class, 'login'])
        ->middleware('throttle:10,1')
        ->name('auth.login');

    Route::post('/school-registration', [SchoolRegistrationController::class, 'register'])
        ->middleware('throttle:5,1')
        ->name('school-registration.register');

    Route::get('/districts/{cityId}', function ($cityId) {
        return \Illuminate\Support\Facades\Cache::remember("districts_{$cityId}", 86400, function () use ($cityId) {
            $response = \Illuminate\Support\Facades\Http::withHeaders([
                'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            ])->timeout(8)->get("https://emsifa.github.io/api-wilayah-indonesia/api/districts/{$cityId}.json");

            if ($response->successful()) {
                return $response->json();
            }
            return [];
        });
    })->name('public.districts');

    // Public Competition Directory & Categories
    Route::get('/curation-groups', [CompetitionCatalogController::class, 'curationGroups'])->name('competitions.curation_groups');
    Route::get('/competitions', [CompetitionCatalogController::class, 'index'])->name('competitions.index');
    Route::get('/competitions/{slug}', [CompetitionCatalogController::class, 'show'])->name('competitions.show');
    Route::post('/competitions/{id}/ai-verify', [CompetitionCatalogController::class, 'aiVerify'])
        ->middleware('throttle:20,1')
        ->name('competitions.ai_verify');
    Route::get('/categories', [CompetitionCatalogController::class, 'categories'])->name('categories.index');
    Route::get('/hero-sliders', [\App\Http\Controllers\Api\V1\Admin\HeroSliderController::class, 'publicIndex'])->name('public.hero-sliders');
    Route::get('/public-stats', [CompetitionCatalogController::class, 'stats'])->name('public.stats');

    // Public QR Verification (Privacy-by-default & Anti-scraping Throttled)
    Route::get('/verify/{public_id}', [PublicVerificationController::class, 'verify'])
        ->middleware('throttle:60,1')
        ->name('verify.show');
    Route::get('/verify/{public_id}/qr', [PublicVerificationController::class, 'qr'])
        ->middleware('throttle:60,1')
        ->name('verify.qr');

    // Public QR Verification for KBM Dispensation (Anti-enumeration Throttled)
    Route::get('/dispensations/verify/{token}', [PublicDispensationVerificationController::class, 'verify'])
        ->middleware('throttle:60,1')
        ->name('dispensations.verify');

    // Public QR Verification for Teacher/Signer TTD
    Route::get('/signers/verify/{token}', [PublicSignerVerificationController::class, 'verify'])
        ->middleware('throttle:60,1')
        ->name('signers.verify');

    // Public Form Pendamping Perlombaan (Direct Link Tanpa Login)
    Route::get('/public/supervisor-form/options', [\App\Http\Controllers\Api\V1\Public\PublicSupervisorController::class, 'getOptions'])
        ->middleware('throttle:60,1')
        ->name('public.supervisor-form.options');
    Route::post('/public/supervisor-form/submit', [\App\Http\Controllers\Api\V1\Public\PublicSupervisorController::class, 'submit'])
        ->middleware('throttle:30,1')
        ->name('public.supervisor-form.submit');
    Route::get('/public/supervisor-form/{token}', [\App\Http\Controllers\Api\V1\Public\PublicSupervisorController::class, 'show'])
        ->name('public.supervisor-form.show');
    Route::get('/public/supervisor-form/{token}/download-docx', [\App\Http\Controllers\Api\V1\Public\PublicSupervisorController::class, 'downloadDocx'])
        ->name('public.supervisor-form.download-docx');
    Route::get('/public/supervisor-form/{token}/download-pdf', [\App\Http\Controllers\Api\V1\Public\PublicSupervisorController::class, 'downloadPdf'])
        ->name('public.supervisor-form.download-pdf');

    // -------------------------------------------------------------
    // Protected Endpoints (Sanctum + Active User + Password Changed + Throttled)
    // -------------------------------------------------------------
    Route::middleware(['auth:sanctum', 'user.active', 'password.changed', 'throttle:120,1'])->group(function () {
        // Auth profile & credential management
        Route::get('/auth/me', [AuthController::class, 'me'])->name('auth.me');
        Route::put('/auth/profile', [AuthController::class, 'updateProfile'])->name('auth.profile.update');
        Route::post('/auth/change-password', [AuthController::class, 'changePassword'])->name('auth.change-password');
        Route::post('/auth/logout', [AuthController::class, 'logout'])->name('auth.logout');

        // Test dashboard route
        Route::get('/user/dashboard-summary', function (Request $request) {
            return response()->json([
                'success' => true,
                'message' => 'Selamat datang di dashboard PrestasiKu.',
                'data' => [
                    'user_id' => $request->user()->id,
                    'name' => $request->user()->name,
                    'roles' => $request->user()->getRoleNames(),
                ],
            ]);
        })->name('dashboard.summary');

        // Eligibility Check Endpoint
        Route::get('/competitions/{id}/eligibility', [CompetitionEligibilityController::class, 'check'])->name('competitions.eligibility');

        // =========================================================
        // Student Endpoints
        // =========================================================
        Route::middleware(['role:student'])->prefix('student')->name('student.')->group(function () {
            Route::get('/registrations', [StudentRegistrationController::class, 'index'])->name('registrations.index');
            Route::post('/registrations', [StudentRegistrationController::class, 'store'])->name('registrations.store');
            Route::get('/registrations/{id}', [StudentRegistrationController::class, 'show'])->name('registrations.show');
            Route::post('/registrations/{id}/upload-certificate', [StudentRegistrationController::class, 'uploadCertificate'])->name('registrations.upload-certificate');
            Route::get('/registrations/{id}/certificate', [StudentRegistrationController::class, 'downloadCertificate'])->name('registrations.download-certificate');

            // Portfolio: Complete competition history (Menang & Kalah/Partisipan)
            Route::get('/portfolio', [StudentRegistrationController::class, 'portfolio'])->name('portfolio');

            // Student KBM Dispensations & Form Schema
            Route::get('/dispensations/form-schema', [StudentDispensationController::class, 'getFormSchema'])->name('dispensations.form-schema');
            Route::get('/dispensations/classmates', [StudentDispensationController::class, 'getClassmates'])->name('dispensations.classmates');
            Route::get('/dispensations', [StudentDispensationController::class, 'index'])->name('dispensations.index');
            Route::post('/dispensations', [StudentDispensationController::class, 'store'])->name('dispensations.store');
            Route::get('/dispensations/{id}', [StudentDispensationController::class, 'show'])->name('dispensations.show');
            Route::get('/dispensations/{id}/download-docx', [StudentDispensationController::class, 'downloadDocx'])->name('dispensations.download-docx');
            Route::get('/dispensations/{id}/download-pdf', [StudentDispensationController::class, 'downloadPdf'])->name('dispensations.download-pdf');

            // Student Competition Permissions & Form Schema
            Route::get('/permissions/form-schema', [StudentPermissionController::class, 'getFormSchema'])->name('permissions.form-schema');
            Route::get('/permissions', [StudentPermissionController::class, 'index'])->name('permissions.index');
            Route::post('/permissions', [StudentPermissionController::class, 'store'])->name('permissions.store');
            Route::get('/permissions/{id}', [StudentPermissionController::class, 'show'])->name('permissions.show');

            // Student Achievements
            Route::get('/achievements', [StudentAchievementController::class, 'index'])->name('achievements.index');
            Route::post('/achievements', [StudentAchievementController::class, 'store'])->name('achievements.store');
            Route::get('/achievements/{achievement}', [StudentAchievementController::class, 'show'])->name('achievements.show');
            Route::patch('/achievements/{achievement}/toggle-public', [StudentAchievementController::class, 'togglePublic'])->name('achievements.toggle-public');
            Route::delete('/achievements/{achievement}', [StudentAchievementController::class, 'destroy'])->name('achievements.destroy');
        });

        // =========================================================
        // Super Admin Endpoints
        // =========================================================
        Route::middleware(['role:super_admin'])->prefix('admin')->name('admin.')->group(function () {
            // School Registration Review
            Route::get('/school-registrations', [SchoolRegistrationReviewController::class, 'index'])->name('school-registrations.index');
            Route::get('/school-registrations/{id}', [SchoolRegistrationReviewController::class, 'show'])->name('school-registrations.show');
            Route::post('/school-registrations/{id}/review', [SchoolRegistrationReviewController::class, 'review'])->name('school-registrations.review');

            // School Management
            Route::get('/schools', [SchoolManagementController::class, 'index'])->name('schools.index');
            Route::get('/schools/{id}', [SchoolManagementController::class, 'show'])->name('schools.show');
            Route::patch('/schools/{id}/status', [SchoolManagementController::class, 'updateStatus'])->name('schools.update-status');

            // Organizers CRUD
            Route::get('/organizers', [OrganizerController::class, 'index'])->name('organizers.index');
            Route::post('/organizers', [OrganizerController::class, 'store'])->name('organizers.store');
            Route::get('/organizers/{id}', [OrganizerController::class, 'show'])->name('organizers.show');
            Route::put('/organizers/{id}', [OrganizerController::class, 'update'])->name('organizers.update');
            Route::delete('/organizers/{id}', [OrganizerController::class, 'destroy'])->name('organizers.destroy');

            // Competition Categories CRUD
            Route::get('/categories', [CompetitionCategoryController::class, 'index'])->name('categories.index');
            Route::post('/categories', [CompetitionCategoryController::class, 'store'])->name('categories.store');
            Route::get('/categories/{id}', [CompetitionCategoryController::class, 'show'])->name('categories.show');
            Route::put('/categories/{id}', [CompetitionCategoryController::class, 'update'])->name('categories.update');
            Route::delete('/categories/{id}', [CompetitionCategoryController::class, 'destroy'])->name('categories.destroy');

            // Competition Management, Verification Pipeline, & Dynamic Forms
            Route::get('/competitions', [CompetitionManagementController::class, 'index'])->name('competitions.index');
            Route::post('/competitions', [CompetitionManagementController::class, 'store'])->name('competitions.store');
            Route::post('/competitions/sync-all-ai', [CompetitionManagementController::class, 'syncAllAI'])->name('competitions.sync_all_ai');
            Route::get('/competitions/{id}', [CompetitionManagementController::class, 'show'])->name('competitions.show');
            Route::post('/competitions/{id}/verify', [CompetitionManagementController::class, 'verify'])->name('competitions.verify');
            // Hero Slider Banner CRUD
            Route::get('/hero-sliders', [\App\Http\Controllers\Api\V1\Admin\HeroSliderController::class, 'adminIndex'])->name('hero-sliders.index');
            Route::post('/hero-sliders', [\App\Http\Controllers\Api\V1\Admin\HeroSliderController::class, 'store'])->name('hero-sliders.store');
            Route::post('/hero-sliders/{id}', [\App\Http\Controllers\Api\V1\Admin\HeroSliderController::class, 'update'])->name('hero-sliders.update');
            Route::patch('/hero-sliders/{id}/toggle-active', [\App\Http\Controllers\Api\V1\Admin\HeroSliderController::class, 'toggleActive'])->name('hero-sliders.toggle-active');
            Route::delete('/hero-sliders/{id}', [\App\Http\Controllers\Api\V1\Admin\HeroSliderController::class, 'destroy'])->name('hero-sliders.destroy');
        });

        // =========================================================
        // School Admin Endpoints (Tenant-isolated)
        // =========================================================
        Route::middleware(['role:school_admin'])->prefix('school')->name('school.')->group(function () {
            // Student CRUD & Password Reset
            Route::get('/students', [StudentManagementController::class, 'index'])->name('students.index');
            Route::post('/students', [StudentManagementController::class, 'store'])->name('students.store');
            Route::get('/students/{id}', [StudentManagementController::class, 'show'])->name('students.show');
            Route::put('/students/{id}', [StudentManagementController::class, 'update'])->name('students.update');
            Route::delete('/students/{id}', [StudentManagementController::class, 'destroy'])->name('students.destroy');
            Route::post('/students/{id}/reset-password', [StudentManagementController::class, 'resetPassword'])->name('students.reset-password');

            // Student Bulk Import via Excel/CSV
            Route::get('/students-import/template', [StudentImportController::class, 'downloadTemplate'])->name('students.import.template');
            Route::post('/students-import', [StudentImportController::class, 'import'])->name('students.import');
            Route::get('/students-import/history', [StudentImportController::class, 'history'])->name('students.import.history');

            // Delegation & Registration Review + Participation Result Recording
            Route::get('/registrations', [SchoolRegistrationManagementController::class, 'index'])->name('registrations.index');
            Route::get('/registrations/{id}', [SchoolRegistrationManagementController::class, 'show'])->name('registrations.show');
            Route::post('/registrations/{id}/review', [SchoolRegistrationManagementController::class, 'review'])->name('registrations.review');
            Route::post('/registrations/direct', [SchoolRegistrationManagementController::class, 'directRegister'])->name('registrations.direct');
            Route::post('/registrations/{id}/result', [SchoolRegistrationManagementController::class, 'recordResult'])->name('registrations.result');
            Route::get('/registrations/{id}/certificate', [SchoolRegistrationManagementController::class, 'downloadCertificate'])->name('registrations.certificate');

            // KBM Dispensations Management, Form Schema, Kop Surat & Exports
            Route::get('/dispensations/form-schema', [SchoolDispensationController::class, 'getFormSchema'])->name('dispensations.form-schema.get');
            Route::put('/dispensations/form-schema', [SchoolDispensationController::class, 'updateFormSchema'])->name('dispensations.form-schema.update');
            Route::post('/dispensations/parse-docx-schema', [SchoolDispensationController::class, 'parseDocxSchema'])->name('dispensations.parse-docx-schema');
            Route::get('/dispensations/letter-template', [SchoolDispensationController::class, 'getLetterTemplate'])->name('dispensations.letter-template.get');
            Route::post('/dispensations/letter-template', [SchoolDispensationController::class, 'updateLetterTemplate'])->name('dispensations.letter-template.update');
            Route::get('/dispensations', [SchoolDispensationController::class, 'index'])->name('dispensations.index');
            Route::post('/dispensations', [SchoolDispensationController::class, 'store'])->name('dispensations.store');
            Route::get('/dispensations/{id}', [SchoolDispensationController::class, 'show'])->name('dispensations.show');
            Route::post('/dispensations/{id}/review', [SchoolDispensationController::class, 'review'])->name('dispensations.review');
            Route::get('/dispensations/{id}/print-letter', [SchoolDispensationController::class, 'printLetter'])->name('dispensations.print-letter');
            Route::get('/dispensations/{id}/download-docx', [SchoolDispensationController::class, 'downloadDocx'])->name('dispensations.download-docx');
            Route::get('/dispensations/{id}/download-pdf', [SchoolDispensationController::class, 'downloadPdf'])->name('dispensations.download-pdf');

            // Surat Perizinan Mengikuti Lomba (Izin Lomba & Rekomendasi)
            Route::get('/permissions/form-schema', [SchoolPermissionController::class, 'getFormSchema'])->name('permissions.form-schema.get');
            Route::put('/permissions/form-schema', [SchoolPermissionController::class, 'updateFormSchema'])->name('permissions.form-schema.update');
            Route::post('/permissions/parse-docx-schema', [SchoolPermissionController::class, 'parseDocxSchema'])->name('permissions.parse-docx-schema');
            Route::get('/permissions/letter-template', [SchoolPermissionController::class, 'getLetterTemplate'])->name('permissions.letter-template.get');
            Route::post('/permissions/letter-template', [SchoolPermissionController::class, 'updateLetterTemplate'])->name('permissions.letter-template.update');
            Route::get('/permissions', [SchoolPermissionController::class, 'index'])->name('permissions.index');
            Route::post('/permissions', [SchoolPermissionController::class, 'store'])->name('permissions.store');

            // Achievements Management & Verification
            Route::get('/achievements', [SchoolAchievementController::class, 'index'])->name('achievements.index');
            Route::post('/achievements', [SchoolAchievementController::class, 'store'])->name('achievements.store');
            Route::get('/achievements/{achievement}', [SchoolAchievementController::class, 'show'])->name('achievements.show');
            Route::match(['put', 'patch', 'post'], '/achievements/{achievement}', [SchoolAchievementController::class, 'update'])->name('achievements.update');
            Route::delete('/achievements/{achievement}', [SchoolAchievementController::class, 'destroy'])->name('achievements.destroy');
            Route::post('/achievements/{achievement}/verify', [SchoolAchievementController::class, 'verify'])->name('achievements.verify');
            Route::get('/achievements/{achievement}/documents/{document}', [SchoolAchievementController::class, 'downloadDocument'])->name('achievements.documents.download');

            // Pendamping Lomba & Pembagian Bisyaroh (SOP Lomba Resmi & Terkurasi)
            Route::get('/supervisors', [SchoolSupervisorController::class, 'index'])->name('supervisors.index');
            Route::get('/supervisors/eligible-competitions', [SchoolSupervisorController::class, 'eligibleCompetitions'])->name('supervisors.eligible-competitions');
            Route::post('/supervisors', [SchoolSupervisorController::class, 'store'])->name('supervisors.store');
            Route::get('/supervisors/{id}', [SchoolSupervisorController::class, 'show'])->name('supervisors.show');
            Route::put('/supervisors/{id}', [SchoolSupervisorController::class, 'update'])->name('supervisors.update');
            Route::delete('/supervisors/{id}', [SchoolSupervisorController::class, 'destroy'])->name('supervisors.destroy');
            Route::get('/supervisors/{id}/print-letter', [SchoolSupervisorController::class, 'printLetter'])->name('supervisors.print-letter');
            Route::get('/supervisors/{id}/download-docx', [SchoolSupervisorController::class, 'downloadDocx'])->name('supervisors.download-docx');
            Route::get('/supervisors/{id}/download-pdf', [SchoolSupervisorController::class, 'downloadPdf'])->name('supervisors.download-pdf');

            // Guru Penandatangan Dispen (Waka Kesiswaan & Guru PJ Lomba/Olimpiade)
            Route::get('/signers', [SchoolSignerController::class, 'index'])->name('signers.index');
            Route::post('/signers', [SchoolSignerController::class, 'store'])->name('signers.store');
            Route::get('/signers/{id}', [SchoolSignerController::class, 'show'])->name('signers.show');
            Route::put('/signers/{id}', [SchoolSignerController::class, 'update'])->name('signers.update');
            Route::delete('/signers/{id}', [SchoolSignerController::class, 'destroy'])->name('signers.destroy');
            Route::get('/signers/{id}/qr', [SchoolSignerController::class, 'qr'])->name('signers.qr');
        });
    });
});
