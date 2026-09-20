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
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->name('api.v1.')->group(function () {
    // -------------------------------------------------------------
    // Public Endpoints
    // -------------------------------------------------------------
    Route::post('/auth/login', [AuthController::class, 'login'])->name('auth.login');
    Route::post('/school-registration', [SchoolRegistrationController::class, 'register'])->name('school-registration.register');

    // Public Competition Directory & Categories
    Route::get('/competitions', [CompetitionCatalogController::class, 'index'])->name('competitions.index');
    Route::get('/competitions/{slug}', [CompetitionCatalogController::class, 'show'])->name('competitions.show');
    Route::get('/categories', [CompetitionCatalogController::class, 'categories'])->name('categories.index');

    // Public QR Verification (Privacy-by-default)
    Route::get('/verify/{public_id}', [PublicVerificationController::class, 'verify'])->name('verify.show');
    Route::get('/verify/{public_id}/qr', [PublicVerificationController::class, 'qr'])->name('verify.qr');

    // Public QR Verification for KBM Dispensation
    Route::get('/dispensations/verify/{token}', [PublicDispensationVerificationController::class, 'verify'])->name('dispensations.verify');

    // -------------------------------------------------------------
    // Protected Endpoints (Sanctum + Active User + Password Changed Check)
    // -------------------------------------------------------------
    Route::middleware(['auth:sanctum', 'user.active', 'password.changed'])->group(function () {
        // Auth profile & credential management
        Route::get('/auth/me', [AuthController::class, 'me'])->name('auth.me');
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

            // Student KBM Dispensations
            Route::get('/dispensations', [StudentDispensationController::class, 'index'])->name('dispensations.index');
            Route::post('/dispensations', [StudentDispensationController::class, 'store'])->name('dispensations.store');
            Route::get('/dispensations/{id}', [StudentDispensationController::class, 'show'])->name('dispensations.show');

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
            Route::get('/competitions/{id}', [CompetitionManagementController::class, 'show'])->name('competitions.show');
            Route::post('/competitions/{id}/verify', [CompetitionManagementController::class, 'verify'])->name('competitions.verify');
            Route::post('/competitions/{id}/forms', [CompetitionManagementController::class, 'storeForm'])->name('competitions.forms.store');
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

            // KBM Dispensations Management
            Route::get('/dispensations', [SchoolDispensationController::class, 'index'])->name('dispensations.index');
            Route::post('/dispensations', [SchoolDispensationController::class, 'store'])->name('dispensations.store');
            Route::get('/dispensations/{id}', [SchoolDispensationController::class, 'show'])->name('dispensations.show');
            Route::post('/dispensations/{id}/review', [SchoolDispensationController::class, 'review'])->name('dispensations.review');
            Route::get('/dispensations/{id}/print-letter', [SchoolDispensationController::class, 'printLetter'])->name('dispensations.print-letter');

            // Achievements Management & Verification
            Route::get('/achievements', [SchoolAchievementController::class, 'index'])->name('achievements.index');
            Route::post('/achievements', [SchoolAchievementController::class, 'store'])->name('achievements.store');
            Route::get('/achievements/{achievement}', [SchoolAchievementController::class, 'show'])->name('achievements.show');
            Route::post('/achievements/{achievement}/verify', [SchoolAchievementController::class, 'verify'])->name('achievements.verify');
            Route::get('/achievements/{achievement}/documents/{document}', [SchoolAchievementController::class, 'downloadDocument'])->name('achievements.documents.download');
        });
    });
});
