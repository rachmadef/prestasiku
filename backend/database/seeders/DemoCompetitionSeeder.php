<?php

namespace Database\Seeders;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\CompetitionEligibility;
use App\Models\CompetitionForm;
use App\Models\CompetitionSource;
use App\Models\FormField;
use App\Models\Organizer;
use App\Models\User;
use Illuminate\Database\Seeder;

class DemoCompetitionSeeder extends Seeder
{
    public function run(): void
    {
        $superAdmin = User::role('super_admin')->first();

        // 1. Organizers
        $puspresnas = Organizer::firstOrCreate(
            ['name' => 'Pusat Prestasi Nasional (Puspresnas)'],
            [
                'type' => 'kementerian',
                'website' => 'https://pusatprestasinasional.kemendikdasmen.go.id/',
                'instagram' => '@puspresnas',
                'email' => 'puspresnas@kemendikbud.go.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Instansi resmi kementerian pengelola kompetisi prestasi nasional.',
            ]
        );

        $disdikDki = Organizer::firstOrCreate(
            ['name' => 'Dinas Pendidikan Provinsi DKI Jakarta'],
            [
                'type' => 'dinas_pendidikan',
                'website' => 'https://disdik.jakarta.go.id',
                'instagram' => '@disdikdki',
                'email' => 'disdik@jakarta.go.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Dinas Pendidikan Provinsi DKI Jakarta resmi.',
            ]
        );

        $sainsCat = CompetitionCategory::where('slug', 'sains-dan-matematika')->first();
        $seniCat = CompetitionCategory::where('slug', 'seni-dan-budaya')->first();
        $teknoCat = CompetitionCategory::where('slug', 'teknologi-dan-robotika')->first();

        // 2. Competition 1: OSN SMA 2026 (Nasional, SLTA, Available This Month)
        $osn = Competition::firstOrCreate(
            ['slug' => 'osn-tingkat-sma-2026'],
            [
                'organizer_id' => $puspresnas->id,
                'category_id' => $sainsCat->id,
                'title' => 'Olimpiade Sains Nasional (OSN) Tingkat SMA/MA 2026',
                'level' => 'nasional',
                'target_level' => 'slta',
                'description' => 'Ajang talenta bergengsi tahunan bagi peserta didik jenjang SMA/MA/Sederajat seluruh Indonesia di bidang Sains dan Matematika.',
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/lomba/osn-sma-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman-osn-2026.pdf',
                'participation_type' => 'individual',
                'min_team_members' => 1,
                'max_team_members' => 1,
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->endOfMonth(),
                'event_start_at' => now()->addMonth()->startOfMonth(),
                'event_end_at' => now()->addMonth()->addDays(5),
                'verification_status' => 'published',
                'visibility' => 'public',
                'verified_by' => $superAdmin?->id,
                'verified_at' => now(),
                'published_at' => now(),
                'verification_notes' => 'Terkonfirmasi resmi sesuai edaran Puspresnas.',
            ]
        );

        CompetitionEligibility::firstOrCreate(
            ['competition_id' => $osn->id],
            [
                'allowed_educational_levels' => ['slta'],
                'allowed_grades' => [10, 11],
                'min_age' => 14,
                'max_age' => 18,
                'allowed_provinces' => null, // Seluruh Indonesia
                'gender_restriction' => 'any',
                'custom_rules' => 'Peserta adalah siswa aktif kelas 10 atau 11 yang memiliki NISN valid dan surat rekomendasi sekolah.',
            ]
        );

        CompetitionSource::firstOrCreate(
            ['competition_id' => $osn->id, 'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/berita/pedoman-osn-2026'],
            [
                'source_type' => 'puspresnas',
                'source_title' => 'Rilis Resmi Pedoman OSN SMA 2026',
                'is_verified' => true,
                'verified_by' => $superAdmin?->id,
            ]
        );

        $osnForm = CompetitionForm::firstOrCreate(
            ['competition_id' => $osn->id, 'version' => 1],
            [
                'title' => 'Formulir Registrasi OSN 2026',
                'is_active' => true,
                'description' => 'Isi data cabang sains yang dipilih dan nomor surat rekomendasi sekolah.',
            ]
        );

        FormField::firstOrCreate(
            ['form_id' => $osnForm->id, 'field_key' => 'bidang_sains'],
            [
                'label' => 'Bidang Sains yang Diikuti',
                'field_type' => 'select',
                'is_required' => true,
                'options' => [
                    ['label' => 'Matematika', 'value' => 'matematika'],
                    ['label' => 'Fisika', 'value' => 'fisika'],
                    ['label' => 'Kimia', 'value' => 'kimia'],
                    ['label' => 'Biologi', 'value' => 'biologi'],
                    ['label' => 'Informatika / Komputer', 'value' => 'informatika'],
                ],
                'order' => 1,
            ]
        );

        FormField::firstOrCreate(
            ['form_id' => $osnForm->id, 'field_key' => 'no_surat_tugas'],
            [
                'label' => 'Nomor Surat Tugas Sekolah',
                'field_type' => 'text',
                'placeholder' => 'Contoh: 421.3/089/SMAN1/2026',
                'is_required' => true,
                'order' => 2,
            ]
        );

        // 3. Competition 2: FLS2N DKI Jakarta 2026 (Provinsi, Available Next Month)
        $fls2n = Competition::firstOrCreate(
            ['slug' => 'fls2n-provinsi-dki-jakarta-2026'],
            [
                'organizer_id' => $disdikDki->id,
                'category_id' => $seniCat->id,
                'title' => 'FLS2N Tingkat Provinsi DKI Jakarta 2026',
                'level' => 'provinsi',
                'target_level' => 'slta',
                'description' => 'Festival dan Lomba Seni Siswa Nasional tingkat Provinsi DKI Jakarta untuk menggali potensi talenta seni dan budaya.',
                'official_website_url' => 'https://disdik.jakarta.go.id/fls2n-2026',
                'participation_type' => 'individual',
                'min_team_members' => 1,
                'max_team_members' => 1,
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->addMonth()->startOfMonth(),
                'registration_deadline' => now()->addMonth()->endOfMonth(),
                'event_start_at' => now()->addMonths(2)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(4),
                'verification_status' => 'published',
                'visibility' => 'public',
                'verified_by' => $superAdmin?->id,
                'verified_at' => now(),
                'published_at' => now(),
                'verification_notes' => 'Surat edaran resmi Dinas Pendidikan DKI terverifikasi.',
            ]
        );

        CompetitionEligibility::firstOrCreate(
            ['competition_id' => $fls2n->id],
            [
                'allowed_educational_levels' => ['slta'],
                'allowed_grades' => [10, 11, 12],
                'min_age' => 14,
                'max_age' => 19,
                'allowed_provinces' => ['DKI Jakarta'],
                'gender_restriction' => 'any',
                'custom_rules' => 'Khusus siswa berdomisili sekolah di wilayah DKI Jakarta.',
            ]
        );

        // 4. Competition 3: Lomba Robotika (Status Draft / Pending - Not published)
        Competition::firstOrCreate(
            ['slug' => 'lomba-robotika-pelajar-2026'],
            [
                'organizer_id' => $puspresnas->id,
                'category_id' => $teknoCat->id,
                'title' => 'Kontes Robotika Pelajar Nasional 2026 (Draft Verifikasi)',
                'level' => 'nasional',
                'target_level' => 'both',
                'description' => 'Kompetisi rancang bangun robot otomatis tingkat pelajar.',
                'participation_type' => 'team',
                'min_team_members' => 2,
                'max_team_members' => 3,
                'registration_open_at' => now()->addDays(5),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addDays(25),
                'event_end_at' => now()->addDays(27),
                'verification_status' => 'pending_verification',
                'visibility' => 'public',
            ]
        );

        // 5. Seed Demo Achievements for Ahmad Bintang Pratama
        $student = \App\Models\Student::where('full_name', 'Ahmad Bintang Pratama')->first();
        $schoolAdmin = User::role('school_admin')->first();

        if ($student && $schoolAdmin) {
            // Achievement 1: Verified Nasional (Privacy masked by default)
            $ach1 = \App\Models\Achievement::firstOrCreate(
                ['public_id' => 'PKU-ACH-2026-DEMO0001'],
                [
                    'student_id' => $student->id,
                    'school_id' => $student->school_id,
                    'competition_id' => $osn->id,
                    'title' => 'Juara 1 Bidang Fisika - Olimpiade Sains Nasional SMA',
                    'level' => 'nasional',
                    'rank' => 'Juara 1 (Medali Emas)',
                    'event_name' => 'Olimpiade Sains Nasional Tingkat SMA/MA 2025',
                    'organizer_name' => 'Pusat Prestasi Nasional (Puspresnas)',
                    'event_date' => '2025-09-10',
                    'status' => 'verified',
                    'verified_by' => $schoolAdmin->id,
                    'verified_at' => now()->subMonths(5),
                    'verification_notes' => 'Dokumen sertifikat dan SK penetapan juara telah diverifikasi valid dengan SK Puspresnas No. 1294/J5/PN.01/2025.',
                    'is_public' => false,
                ]
            );

            $ach1->documents()->firstOrCreate(
                ['document_type' => 'certificate'],
                [
                    'document_number' => 'CERT/PUSPRESNAS/OSN-SMA/FIS-01/2025',
                    'external_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pengumuman-pemenang-osn-2025',
                    'file_name' => 'Sertifikat_Emas_OSN_Fisika_2025.pdf',
                ]
            );

            $ach1->documents()->firstOrCreate(
                ['document_type' => 'decree_sk'],
                [
                    'document_number' => 'SK Puspresnas No. 1294/J5/PN.01/2025',
                    'file_name' => 'SK_Pemenang_OSN_SMA_2025.pdf',
                ]
            );

            // Achievement 2: Verified Provinsi (Public Opt-in: Name is visible)
            $ach2 = \App\Models\Achievement::firstOrCreate(
                ['public_id' => 'PKU-ACH-2026-DEMO0002'],
                [
                    'student_id' => $student->id,
                    'school_id' => $student->school_id,
                    'title' => 'Juara 2 Lomba Peneliti Belia Tingkat Provinsi DKI Jakarta',
                    'level' => 'provinsi',
                    'rank' => 'Juara 2 (Medali Perak)',
                    'event_name' => 'Lomba Peneliti Belia DKI Jakarta 2025',
                    'organizer_name' => 'Center for Young Scientists Indonesia & Disdik DKI',
                    'event_date' => '2025-11-20',
                    'status' => 'verified',
                    'verified_by' => $schoolAdmin->id,
                    'verified_at' => now()->subMonths(3),
                    'verification_notes' => 'Sertifikat medali perak terverifikasi sesuai salinan asli.',
                    'is_public' => true,
                ]
            );

            $ach2->documents()->firstOrCreate(
                ['document_type' => 'certificate'],
                [
                    'document_number' => 'CYS-LPB-DKI/2025/088',
                    'file_name' => 'Sertifikat_Perak_LPB_2025.pdf',
                ]
            );

            // Achievement 3: Pending Verification
            \App\Models\Achievement::firstOrCreate(
                ['public_id' => 'PKU-ACH-2026-DEMO0003'],
                [
                    'student_id' => $student->id,
                    'school_id' => $student->school_id,
                    'title' => 'Juara 3 Kompetisi Sains Terbuka Se-Jabodetabek',
                    'level' => 'kota_kabupaten',
                    'rank' => 'Juara 3',
                    'event_name' => 'Science Fair Jabodetabek 2026',
                    'organizer_name' => 'Forum Guru Sains Jakarta',
                    'event_date' => '2026-02-14',
                    'status' => 'pending_verification',
                    'is_public' => false,
                ]
            );
        }
    }
}
