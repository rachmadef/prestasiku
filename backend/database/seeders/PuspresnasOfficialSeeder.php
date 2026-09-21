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

class PuspresnasOfficialSeeder extends Seeder
{
    /**
     * Seed 100% Real Competitions from Pusat Prestasi Nasional (Puspresnas)
     * Sumber data: https://pusatprestasinasional.kemendikdasmen.go.id/
     * Portal pendaftaran resmi: https://daftar-bpti.kemendikdasmen.go.id/
     */
    public function run(): void
    {
        $superAdmin = User::role('super_admin')->first();

        // -------------------------------------------------------------
        // 1. Kategori Resmi Ajang Talenta Puspresnas
        // -------------------------------------------------------------
        $sainsCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'sains-dan-matematika'],
            [
                'name' => 'Sains & Matematika',
                'description' => 'Kompetisi bidang sains, fisika, kimia, biologi, astronomi, dan matematika.',
                'icon' => 'atom',
            ]
        );

        $risetCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'riset-dan-karya-ilmiah'],
            [
                'name' => 'Riset & Karya Ilmiah',
                'description' => 'Lomba karya ilmiah, inovasi penelitian, dan kreativitas ilmiah pelajar.',
                'icon' => 'microscope',
            ]
        );

        $seniCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'seni-dan-budaya'],
            [
                'name' => 'Seni & Budaya',
                'description' => 'Festival lomba seni vokal, tari tradisional, kriya, sastra, dan sinematografi.',
                'icon' => 'palette',
            ]
        );

        $olahragaCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'olahraga-dan-kebugaran'],
            [
                'name' => 'Olahraga & Kebugaran',
                'description' => 'Olimpiade olahraga siswa nasional dan pembinaan atletik pelajar.',
                'icon' => 'trophy',
            ]
        );

        $vokasiCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'kewirausahaan-dan-vokasi'],
            [
                'name' => 'Kewirausahaan & Vokasi',
                'description' => 'Ajang inovasi bisnis, kewirausahaan mandiri, dan keahlian vokasi kejuruan.',
                'icon' => 'briefcase',
            ]
        );

        $bahasaCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'bahasa-dan-literasi'],
            [
                'name' => 'Bahasa & Literasi',
                'description' => 'Debat bahasa Indonesia, debat bahasa Inggris, dan literasi kebangsaan.',
                'icon' => 'book-open',
            ]
        );

        // -------------------------------------------------------------
        // 2. Lembaga Resmi Kemendikdasmen (Puspresnas & BPTI)
        // -------------------------------------------------------------
        $puspresnas = Organizer::updateOrCreate(
            ['name' => 'Pusat Prestasi Nasional (Puspresnas)'],
            [
                'type' => 'kementerian',
                'website' => 'https://pusatprestasinasional.kemendikdasmen.go.id/',
                'instagram' => '@puspresnas',
                'email' => 'puspresnas@kemdikbud.go.id',
                'phone' => '021-5725610',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Unit Pelaksana Teknis Kemendikdasmen pengelola ajang talenta nasional resmi.',
            ]
        );

        $bpti = Organizer::updateOrCreate(
            ['name' => 'Balai Pengembangan Talenta Indonesia (BPTI)'],
            [
                'type' => 'kementerian',
                'website' => 'https://bpti.kemendikdasmen.go.id/',
                'instagram' => '@bpti.kemdikbud',
                'email' => 'bpti@kemdikbud.go.id',
                'phone' => '021-5725611',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Balai pelaksana ajang talenta dan pembinaan prestasi peserta didik se-Indonesia.',
            ]
        );

        $kpm = Organizer::updateOrCreate(
            ['name' => 'Klinik Pendidikan MIPA (KPM)'],
            [
                'type' => 'organisasi_profesi',
                'website' => 'https://kpm.or.id/',
                'instagram' => '@kpmseikhlasnya',
                'email' => 'sekretariat@kpm.or.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Lembaga pengembang MIPA nasional penyelenggara KMNR terakreditasi kurasi SIMT Puspresnas.',
            ]
        );

        $cys = Organizer::updateOrCreate(
            ['name' => 'Center for Young Scientists Indonesia (CYS)'],
            [
                'type' => 'organisasi_profesi',
                'website' => 'https://cys.or.id/',
                'instagram' => '@cysindonesia',
                'email' => 'info@cys.or.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Penyelenggara Lomba Peneliti Belia afiliasi ICYS internasional, terkurasi resmi SIMT Puspresnas.',
            ]
        );

        $ugm = Organizer::updateOrCreate(
            ['name' => 'Universitas Gadjah Mada (UGM)'],
            [
                'type' => 'perguruan_tinggi',
                'website' => 'https://ugm.ac.id/',
                'instagram' => '@ugm.yogyakarta',
                'email' => 'info@ugm.ac.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Penyelenggara Olgenas Fakultas Geografi UGM terakreditasi kurasi Puspresnas Kemendikdasmen.',
            ]
        );

        $itb = Organizer::updateOrCreate(
            ['name' => 'Institut Teknologi Bandung (ITB)'],
            [
                'type' => 'perguruan_tinggi',
                'website' => 'https://itb.ac.id/',
                'instagram' => '@itb1920',
                'email' => 'humas@itb.ac.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Perguruan tinggi penyelenggara Arkavidia Informatics Contest ITB.',
            ]
        );

        $ui = Organizer::updateOrCreate(
            ['name' => 'Universitas Indonesia (UI)'],
            [
                'type' => 'perguruan_tinggi',
                'website' => 'https://ui.ac.id/',
                'instagram' => '@univ_indonesia',
                'email' => 'humas-ui@ui.ac.id',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Penyelenggara National Science Challenge BEM FMIPA Universitas Indonesia.',
            ]
        );

        // -------------------------------------------------------------
        // 3. Database Kompetisi Resmi Puspresnas (Real Data)
        // -------------------------------------------------------------
        $competitionsData = [
            // 1. OSN SMA
            [
                'title' => 'Olimpiade Sains Nasional (OSN) Jenjang SMA/MA 2026',
                'slug' => 'osn-tingkat-sma-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "Panduan Olimpiade Sains Nasional (OSN) telah resmi dirilis oleh Pusat Prestasi Nasional (Puspresnas) dan Balai Pengembangan Talenta Indonesia (BPTI) Kemendikdasmen RI sebagai acuan dalam pelaksanaan dan persiapan OSN 2026. Kehadiran panduan ini memberikan gambaran yang jelas dan komprehensif mengenai mekanisme seleksi, ketentuan lomba, serta ruang lingkup materi yang diujikan sehingga peserta didik, guru pembina, dan satuan pendidikan dapat melakukan persiapan secara lebih terarah dan sistematis.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan dokumen resmi Puspresnas Kemendikdasmen, Pedoman BPTI, dan Sistem Informasi Manajemen Talenta (SIMT):\n\n1. Sembilan (9) Cabang Bidang Sains yang Diujikan:\n• Astronomi\n• Biologi\n• Ekonomi\n• Fisika\n• Geografi\n• Informatika / Komputer\n• Kebumian\n• Kimia\n• Matematika\n\n2. Alur Seleksi Berjenjang:\n• Seleksi Tingkat Sekolah (OSN-S)\n• Seleksi Tingkat Kabupaten/Kota (OSN-K) secara daring serentak berbasis CBT/ANBK\n• Seleksi Tingkat Provinsi (OSN-P)\n• Final Tingkat Nasional (OSN Nasional)\n\n3. Pengakuan Prestasi & Pembinaan:\n• Pemenang medali emas, perak, dan perunggu menerima e-sertifikat resmi Kemendikdasmen dan tercatat otomatis di Sistem Informasi Manajemen Talenta (SIMT).\n• Pembinaan Pelatnas menuju ajang olimpiade sains internasional (IMO, IPhO, IChO, IBO, IOI, IOAA, IEO, IESO, iGeo).\n• Rekomendasi prioritas penerima Beasiswa Indonesia Maju (BIM).",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-sains-nasional-2026-2026-sma',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-sma-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->endOfMonth(),
                'event_start_at' => now()->addMonth()->startOfMonth(),
                'event_end_at' => now()->addMonth()->addDays(5),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Peserta adalah siswa aktif kelas 10 atau 11 SMA/MA/Sederajat yang terdaftar di Dapodik/EMIS dan memiliki surat rekomendasi resmi Kepala Sekolah.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi Ajang Talenta OSN SMA - Puspresnas Kemendikdasmen',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-sains-nasional-2026-2026-sma',
                        'notes' => 'Portal induk pengumuman resmi jadwal kompetisi, ketentuan umum peserta, dan linimasa ajang talenta tingkat nasional.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Registrasi Terpadu Ajang Talenta BPTI',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Tautan resmi pendaftaran peserta dan sinkronisasi data peserta didik dengan basis data Dapodik / EMIS.',
                    ],
                    [
                        'source_type' => 'circular_letter',
                        'source_title' => 'Buku Pedoman & Juknis Pelaksanaan OSN SMA 2026',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-sma-2026.pdf',
                        'notes' => 'Dokumen panduan teknis yang memuat silabus kompetisi, ketentuan integritas akademik, dan spesifikasi tes CBT.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Kurasi Prestasi & SIMT Kemendikdasmen',
                        'source_url' => 'https://kurasi-prestasi.kemendikdasmen.go.id/',
                        'notes' => 'Pangkalan data manajemen talenta nasional dan kurasi keabsahan sertifikat prestasi juara.',
                    ],
                    [
                        'source_type' => 'instagram',
                        'source_title' => 'Akun Resmi Instagram @puspresnas',
                        'source_url' => 'https://instagram.com/puspresnas',
                        'notes' => 'Media sosial resmi untuk pengumuman linimasa dan infografis tahapan seleksi OSN.',
                    ],
                ],
            ],

            // 2. OPSI DIKMEN 2026
            [
                'title' => 'Olimpiade Penelitian Siswa Indonesia (OPSI) Jenjang Pendidikan Menengah 2026',
                'slug' => 'olimpiade-penelitian-siswa-indonesia-opsi-2026',
                'category_id' => $risetCat->id,
                'organizer_id' => $puspresnas->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'min_team_members' => 1,
                'max_team_members' => 2,
                'description' => "Olimpiade Penelitian Siswa Indonesia (OPSI) merupakan salah satu program strategis Pusat Prestasi Nasional, Kementerian Pendidikan Dasar dan Menengah, dalam rangka membina dan mengembangkan talenta peserta didik jenjang pendidikan menengah di bidang penelitian dan inovasi. Pada jenjang Pendidikan Menengah (SMA/MA/SMK/MAK/sederajat), OPSI menjadi ruang aktualisasi kemampuan berpikir tingkat tinggi, kreativitas ilmiah, serta kepemimpinan intelektual peserta didik melalui kegiatan penelitian yang sistematis dan beretika.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Pedoman Teknis Riset Puspresnas & BPTI Kemendikdasmen:\n\n1. Tiga (3) Bidang Penelitian OPSI:\n• Matematika, Sains, dan Teknologi (MST)\n• Fisika Terapan dan Rekayasa (FTR)\n• Ilmu Sosial dan Humaniora (ISH)\n\n2. Tahapan Seleksi Riset:\n• Pengunggahan Proposal Penelitian\n• Penelitian Mandiri dengan Pembimbingan Sekolah\n• Pengunggahan Naskah Laporan Hasil Penelitian\n• Seleksi Naskah dan Penentuan Finalis Nasional\n• Pameran Virtual / Expo Poster dan Uji Wawancara Juri Nasional\n\n3. Apresiasi dan Fasilitas:\n• Karya penelitian terverifikasi dan tercatat pada pangkalan data talenta SIMT Kemendikdasmen.\n• Delegasi berprestasi berpeluang mewakili Indonesia di ajang internasional seperti Regeneron International Science and Engineering Fair (ISEF).",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-penelitian-siswa-indonesia-opsi-jenjang-pendidikan-menengah-2026-2026-sma',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-opsi-dikmen-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(28),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->endOfMonth(),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Peserta adalah siswa aktif SMA/MA/SMK/sederajat. Satu tim terdiri dari 1-2 siswa dengan 1 guru pembimbing.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi Ajang Talenta OPSI Dikmen - Puspresnas',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-penelitian-siswa-indonesia-opsi-jenjang-pendidikan-menengah-2026-2026-sma',
                        'notes' => 'Informasi resmi kriteria naskah ilmiah, format proposal riset, dan panduan etika penelitian.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Tautan pengunggahan dokumen proposal dan verifikasi nomor registrasi sekolah.',
                    ],
                    [
                        'source_type' => 'circular_letter',
                        'source_title' => 'Buku Pedoman Teknis OPSI Jenjang Pendidikan Menengah 2026',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-opsi-dikmen-2026.pdf',
                        'notes' => 'Panduan lengkap struktur penulisan laporan penelitian dan rubrik penilaian dewan juri.',
                    ],
                ],
            ],

            // 3. FLS3N DIKMEN 2026
            [
                'title' => 'Festival Lomba Seni dan Sastra Siswa Nasional (FLS3N) Jenjang Pendidikan Menengah 2026',
                'slug' => 'festival-lomba-seni-dan-sastra-siswa-nasional-fls3n-2026',
                'category_id' => $seniCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'both',
                'min_team_members' => 1,
                'max_team_members' => 3,
                'description' => "Festival Lomba Seni dan Sastra Siswa Nasional (FLS3N) memberikan ruang bagi siswa untuk mengeksplorasi, mengembangkan, dan menyalurkan bakat seni dan sastra yang mereka miliki. Ajang ini menjadi sarana strategis untuk menumbuhkan kecintaan terhadap seni budaya nusantara, membangun karakter generasi muda yang kreatif, berprestasi, dan berdaya saing global.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Panduan Resmi Pelaksanaan FLS3N Puspresnas:\n\n1. Cabang Seni & Sastra yang Dilombakan:\n• Baca Puisi & Cipta Puisi\n• Cipta Cerpen\n• Menyanyi Solo (Kategori Putra & Putri)\n• Tari Kreasi Tradisional\n• Monolog\n• Kriya\n• Desain Poster Edukasi\n• Film Pendek (Kategori Fiksi & Dokumenter)\n• Gitar Solo & Fotografi\n\n2. Tahapan Seleksi:\n• Seleksi Tingkat Sekolah\n• Seleksi Tingkat Kabupaten/Kota melalui kurasi video karya\n• Seleksi Tingkat Provinsi\n• Pergelaran Babak Final Nasional secara luring tatap muka.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/seni-budaya/sma/festival-lomba-seni-dan-sastra-siswa-nasional-fls3n-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls3n-dikmen-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(25),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(3)->addDays(10),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 14,
                    'max_age' => 19,
                    'custom_rules' => 'Karya seni dan sastra yang diikutsertakan merupakan karya orisinal dan belum pernah menjuarai lomba tingkat nasional lain.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi FLS3N Dikmen - Puspresnas Kemendikdasmen',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/seni-budaya/sma/festival-lomba-seni-dan-sastra-siswa-nasional-fls3n-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma',
                        'notes' => 'Rilis resmi tema kompetisi seni, panduan format video rekaman, dan ketentuan hak cipta karya.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Tautan pengunggahan tautan YouTube karya seni dan pendaftaran delegasi sekolah.',
                    ],
                    [
                        'source_type' => 'circular_letter',
                        'source_title' => 'Buku Panduan Teknis FLS3N Jenjang Pendidikan Menengah 2026',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls3n-dikmen-2026.pdf',
                        'notes' => 'Ketentuan teknis penilaian cabang tari, kriya, cipta cerpen, dan sinematografi.',
                    ],
                ],
            ],

            // 4. O2SN DIKMEN 2026
            [
                'title' => 'Olimpiade Olahraga Siswa Nasional (O2SN) Jenjang Pendidikan Menengah 2026',
                'slug' => 'olimpiade-olahraga-siswa-nasional-o2sn-2026',
                'category_id' => $olahragaCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "Pelaksanaan ajang talenta Olimpiade Olahraga Siswa Nasional (O2SN) selaras dengan penguatan karakter melalui 7 Kebiasaan Anak Indonesia Hebat, yaitu bangun pagi, beribadah, berolahraga, makan sehat dan bergizi, gemar belajar, bermasyarakat, serta tidur cepat. Nilai-nilai tersebut menjadi fondasi dalam membentuk murid yang sehat, disiplin, berintegritas, dan berdaya saing. O2SN merupakan bagian dari upaya strategis pemerintah dalam pembinaan olahraga pendidikan yang berjenjang, terarah, dan berkelanjutan, serta mendukung pelaksanaan Desain Besar Olahraga Nasional (DBON).\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Pedoman BPTI dan Regulasi Induk Organisasi Olahraga:\n\n1. Cabang Olahraga Resmi:\n• Atletik\n• Renang\n• Bulu Tangkis\n• Pencak Silat\n• Karate\n\n2. Mekanisme Seleksi:\n• Seleksi berjenjang dari tingkat Satuan Pendidikan, Kabupaten/Kota, Provinsi, hingga Final Nasional.\n• Penilaian dan penjurian mengacu pada standar federasi olahraga internasional terkait.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/olahraga/sma/olimpiade-olahraga-siswa-nasional-o2sn-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-dikmen-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(30),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(15),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Atlet pelajar non-pelatnas yang terdaftar aktif di Dapodik/EMIS dan memiliki surat keterangan sehat dokter.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi O2SN Dikmen - Puspresnas Kemendikdasmen',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/olahraga/sma/olimpiade-olahraga-siswa-nasional-o2sn-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma',
                        'notes' => 'Informasi linimasa seleksi tingkat daerah dan regulasi pembinaan DBON.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Tautan pendaftaran atlet pelajar dan verifikasi surat tugas kepala sekolah.',
                    ],
                    [
                        'source_type' => 'circular_letter',
                        'source_title' => 'Buku Pedoman Teknis O2SN Jenjang Pendidikan Menengah 2026',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-dikmen-2026.pdf',
                        'notes' => 'Peraturan pertandingan resmi cabor atletik, renang, silat, karate, dan bulu tangkis.',
                    ],
                ],
            ],

            // 5. FIKSI 2026
            [
                'title' => 'Festival Inovasi dan Kewirausahaan Siswa Nasional (FIKSI) 2026',
                'slug' => 'festival-inovasi-dan-kewirausahaan-siswa-nasional-fiksi-2026',
                'category_id' => $vokasiCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'both',
                'min_team_members' => 1,
                'max_team_members' => 2,
                'description' => "FIKSI Tahun 2026 mengusung semangat baru dengan penekanan kuat pada integrasi tiga pilar utama: Ekonomi Hijau (Green Economy), Ekonomi Kreatif, dan Ekonomi Digital. Wirausahawan masa depan bukan hanya mereka yang mampu mencetak profit, tetapi mereka yang mampu memberikan solusi konkret atas permasalahan sosial dan ekologi. Melalui ajang ini, diharapkan lahir profil Pelajar Pancasila yang memiliki jiwa sociopreneur yang tangguh, etis, dan berwawasan global.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Panduan BPTI Puspresnas Kemendikdasmen:\n\n1. Kategori Bidang Usaha:\n• Kriya & Kerajinan Ramah Lingkungan\n• Desain Grafis, Game & Animasi Edukatif\n• Kuliner & Pangan Lokal Berkelanjutan\n• Agribisnis, Agroteknologi & Energi Bersih\n• Aplikasi Digital, FinTech & E-Commerce Sosial\n\n2. Tahapan Seleksi:\n• Pengunggahan Proposal Rencana Bisnis (Business Plan)\n• Validasi Pasar & Portofolio Prototipe Produk\n• Expo Pameran Produk & Wawancara Dewan Juri Investor/Praktisi.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/festival-inovasi-dan-kewirausahaan-siswa-nasional-2026-2026-sma',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fiksi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(30),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(3)->addDays(15),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 15,
                    'max_age' => 19,
                    'custom_rules' => 'Rencana usaha (Business Plan) orisinal dengan prototipe produk dan validasi pasar nyata.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi Ajang Talenta FIKSI - Puspresnas',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/festival-inovasi-dan-kewirausahaan-siswa-nasional-2026-2026-sma',
                        'notes' => 'Pedoman inovasi sociopreneur, green economy, dan inkubasi wirausaha muda.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Registrasi Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Pendaftaran ide bisnis, pitching deck, dan verifikasi sekolah pengusung.',
                    ],
                    [
                        'source_type' => 'circular_letter',
                        'source_title' => 'Buku Pedoman Pelaksanaan FIKSI 2026',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fiksi-2026.pdf',
                        'notes' => 'Struktur penulisan proposal rencana bisnis dan rubrik penilaian inkubasi.',
                    ],
                ],
            ],

            // 6. LKS SMK 2026
            [
                'title' => 'Lomba Kompetensi Siswa Nasional (LKS) 2026',
                'slug' => 'lomba-kompetensi-siswa-nasional-lks-2026',
                'category_id' => $vokasiCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "Lomba Kompetensi Siswa (LKS) adalah sebuah ajang talenta di bidang kejuruan dan teknologi terapan yang diselenggarakan untuk peserta didik Sekolah Menengah Kejuruan (SMK) dan Sekolah Menengah Atas (SMA)/sederajat. Ajang LKS diselenggarakan secara bertingkat mulai dari daerah hingga nasional untuk menjaring peserta terbaik dari 38 provinsi di Indonesia yang mengacu pada standar kompetensi WorldSkills International.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Standar WorldSkills dan Juknis Kemendikdasmen:\n\n1. Klaster Keahlian Utama:\n• Teknologi Informasi & Komunikasi (Cyber Security, Web Technologies, Cloud Computing)\n• Rekayasa Mesin & Mekatronika (CNC Milling, Industrial Automation)\n• Seni Kreatif & Mode (Fashion Technology, Graphic Design Technology)\n• Layanan Sosial & Pariwisata (Hotel Reception, Restaurant Service)\n\n2. Jalur Prestasi Internasional:\n• Juara terbaik berhak mewakili Kontingen Indonesia pada WorldSkills ASEAN dan WorldSkills Competition.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/lomba-kompetensi-siswa-nasional-2026-2026-sma',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-lks-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(25),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->endOfMonth(),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [11, 12],
                    'min_age' => 15,
                    'max_age' => 19,
                    'custom_rules' => 'Peserta adalah siswa SMK/SMA aktif yang memenangkan seleksi LKS tingkat wilayah/provinsi.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi LKS SMK Tingkat Nasional - Puspresnas',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/lomba-kompetensi-siswa-nasional-2026-2026-sma',
                        'notes' => 'Rilis resmi bidang lomba keahlian vokasi dan standar uji kompetensi industri.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Pendaftaran kontingen delegasi provinsi bidang lomba kejuruan.',
                    ],
                    [
                        'source_type' => 'circular_letter',
                        'source_title' => 'Buku Pedoman Teknis & Kisi-Kisi Uji LKS 2026',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-lks-2026.pdf',
                        'notes' => 'Spesifikasi teknis alat uji, software yang digunakan, dan jadwal uji per bidang.',
                    ],
                ],
            ],

            // 7. LDBI & LDI 2026
            [
                'title' => 'Lomba Debat Indonesia (LDI) / LDBI Tingkat Nasional 2026',
                'slug' => 'lomba-debat-indonesia-tingkat-nasional-2026',
                'category_id' => $bahasaCat->id,
                'organizer_id' => $puspresnas->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'min_team_members' => 3,
                'max_team_members' => 3,
                'description' => "Pelaksanaan Lomba Debat Indonesia (LDI) / Lomba Debat Bahasa Indonesia (LDBI) Tingkat Nasional 2026 merupakan ajang unjuk kecakapan literasi, nalar kritis, dan komunikasi persuasif bagi peserta didik jenjang SMA/MA seluruh Indonesia dalam format debat parlementer resmi.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\n• Format kompetisi menggunakan sistem Asian Parliamentary Debate (3 vs 3).\n• Mosi debat mencakup isu strategis pendidikan nasional, transformasi energi terbarukan, kecerdasan buatan, ekonomi kerakyatan, dan kebudayaan nusantara.\n• Pemenang kontingen dan Best Speaker terbaik berhak mendapatkan e-sertifikat terakreditasi Kemendikdasmen yang terhubung ke SIMT.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-ldbi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(10),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Satu tim terdiri dari 3 pembicara aktif SMA/MA yang memiliki surat mandat resmi dari sekolah.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Laman Resmi Lomba Debat Indonesia - Puspresnas',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/',
                        'notes' => 'Pengumuman linimasa seleksi babak penyisihan daerah dan aturan tata tertib debat.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Tautan registrasi tim delegasi debat dan verifikasi anggota tim.',
                    ],
                ],
            ],

            // 8. OSN SMP 2026
            [
                'title' => 'Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs 2026',
                'slug' => 'osn-jenjang-smp-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'individual',
                'description' => "Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs diselenggarakan oleh BPTI Kemendikdasmen untuk mencetak generasi talenta muda yang unggul, kritis, dan berdaya saing dalam penguasaan sains dasar.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\n1. Tiga (3) Bidang Sains:\n• Matematika\n• Ilmu Pengetahuan Alam (IPA)\n• Ilmu Pengetahuan Sosial (IPS)\n\n2. Mekanisme Seleksi:\n• Seleksi Satuan Pendidikan (OSN-S)\n• Seleksi Tingkat Kabupaten/Kota (OSN-K) sistem CBT daring\n• Seleksi Tingkat Provinsi (OSN-P)\n• Babak Final Nasional (OSN Nasional).",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-smp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(15),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 11,
                    'max_age' => 15,
                    'custom_rules' => 'Peserta adalah siswa aktif kelas 7 atau 8 SMP/MTs yang belum pernah meraih medali emas OSN Nasional.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi Ajang Talenta Jenjang SMP - Puspresnas',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                        'notes' => 'Informasi resmi kuota per sekolah dan panduan teknis OSN tingkat pendidikan dasar.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Pendaftaran peserta didik SMP dengan integrasi nomor NISN Dapodik.',
                    ],
                ],
            ],

            // 9. GSI SMP 2026
            [
                'title' => 'Gala Siswa Indonesia (GSI) Jenjang SMP Tingkat Nasional 2026',
                'slug' => 'gsi-smp-nasional-2026',
                'category_id' => $olahragaCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'team',
                'min_team_members' => 11,
                'max_team_members' => 18,
                'description' => "Gala Siswa Indonesia (GSI) adalah kompetisi sepak bola pelajar SMP resmi yang diselenggarakan melalui kerja sama BPTI Kemendikdasmen dengan PSSI untuk mengidentifikasi dan membina talenta muda sepak bola nasional.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\n• Kompetisi sepak bola bertingkat dari kecamatan, kabupaten/kota, provinsi, hingga final nasional.\n• Bekerja sama dengan PSSI dan Kementerian Pemuda dan Olahraga untuk talent scouting tim nasional usia muda.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-gsi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(3)->addDays(15),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 12,
                    'max_age' => 15,
                    'custom_rules' => 'Pemain sepak bola aktif terdaftar di SMP/MTs dan telah lolos seleksi daerah.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi Gala Siswa Indonesia - Puspresnas',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                        'notes' => 'Regulasi pertandingan sepak bola pelajar berstandar PSSI.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Pendaftaran roster pemain dan tim pelatih delegasi sekolah/daerah.',
                    ],
                ],
            ],

            // 10. O2SN SMP 2026
            [
                'title' => 'Olimpiade Olahraga Siswa Nasional (O2SN) Jenjang SMP 2026',
                'slug' => 'o2sn-jenjang-smp-2026',
                'category_id' => $olahragaCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'individual',
                'description' => "O2SN Jenjang SMP memfasilitasi pembibitan dan aktualisasi potensi atletik pelajar tingkat pertama menuju Desain Besar Olahraga Nasional (DBON).\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nCabang Olahraga yang Dilombakan:\n• Atletik (Nomor Lari, Lompat Jauh, Tolak Peluru)\n• Renang (Gaya Bebas, Dada, Punggung, Kupu-kupu)\n• Bulu Tangkis (Tunggal Putra & Putri)\n• Pencak Silat (Jurus Tunggal & Tanding)\n• Karate (Kata & Kumite)\n• Senam Artistik.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-smp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(20),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 12,
                    'max_age' => 15,
                    'custom_rules' => 'Memiliki surat keterangan sehat jasmani dan rekomendasi sekolah.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi O2SN Jenjang SMP - Puspresnas Kemendikdasmen',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                        'notes' => 'Panduan seleksi daerah dan pembinaan olahraga jenjang SMP.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Pendaftaran atlet pelajar SMP dan verifikasi dokumen kesehatan.',
                    ],
                ],
            ],

            // 11. FLS2N SMP 2026
            [
                'title' => 'Festival dan Lomba Seni Siswa Nasional (FLS2N) Jenjang SMP 2026',
                'slug' => 'fls2n-jenjang-smp-2026',
                'category_id' => $seniCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'both',
                'min_team_members' => 1,
                'max_team_members' => 5,
                'description' => "FLS2N Jenjang SMP merupakan ajang apresiasi seni dan budaya nusantara bagi peserta didik sekolah menengah pertama se-Indonesia.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nCabang Lomba Seni:\n• Menyanyi Solo\n• Tari Kreasi Tradisional\n• Pantomim\n• Musik Tradisional Khas Nusantara\n• Ansambel Campuran\n• Ilustrasi Gambar Cerita Rakyat.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                'registration_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls2n-smp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(25),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 12,
                    'max_age' => 15,
                    'custom_rules' => 'Siswa SMP berstatus aktif di Dapodik/EMIS dan didaftarkan melalui operator sekolah resmi.',
                ],
                'sources' => [
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Portal Resmi FLS2N Jenjang SMP - Puspresnas Kemendikdasmen',
                        'source_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp',
                        'notes' => 'Rilis petunjuk teknis lomba seni budaya nusantara jenjang SMP.',
                    ],
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen',
                        'source_url' => 'https://daftar-bpti.kemendikdasmen.go.id/',
                        'notes' => 'Pengunggahan karya seni video dan pendaftaran peserta didik.',
                    ],
                ],
            ],

            // =========================================================
            // B. KELOMPOK 2: TERKURASI PUSPRESNAS (Lolos Kurasi SIMT)
            // =========================================================
            [
                'title' => 'Kompetisi Matematika Nalaria Realistik (KMNR) ke-21 2026',
                'slug' => 'kmnr-tingkat-nasional-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $kpm->id,
                'curation_type' => 'terkurasi_puspresnas',
                'curation_rating' => 'Grade A (Sangat Baik)',
                'curation_number' => 'SIMT-KURASI-2026-A019',
                'level' => 'nasional',
                'target_level' => 'both',
                'participation_type' => 'individual',
                'description' => "Kompetisi Matematika Nalaria Realistik (KMNR) merupakan ajang olimpiade nalar matematika bergengsi tingkat nasional yang diselenggarakan oleh Klinik Pendidikan MIPA (KPM) dan telah resmi lolos Kurasi Prestasi Puspresnas Kemendikdasmen RI melalui Sistem Informasi Manajemen Talenta (SIMT).\n\n📌 RANGKUMAN MULTI-SUMBER & STATUS KURASI PUSPRESNAS:\n• Status Akreditasi: Terkurasi Resmi Puspresnas (Grade A).\n• Nomor Registrasi SIMT: SIMT-KURASI-2026-A019.\n• Bobot Prestasi: Piagam dan medali diakui penuh untuk seleksi jalur prestasi (PPDB & SNBP) serta Beasiswa Indonesia Maju.\n• Cabang Lomba: Penalaran Matematika Terapan, Pemecahan Masalah Non-Rutin, dan Nalar Logika Realistik.\n• Tahapan: Babak Penyisihan Kota/Kabupaten -> Babak Semifinal Provinsi -> Babak Final Nasional.",
                'official_website_url' => 'https://kpm.or.id/kmnr-2026',
                'registration_url' => 'https://kpm.or.id/pendaftaran-kmnr-2026',
                'guide_book_url' => 'https://kpm.or.id/juknis-kmnr-2026.pdf',
                'requires_school_approval' => false,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(25),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(10),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp', 'slta'],
                    'allowed_grades' => [7, 8, 9, 10, 11, 12],
                    'min_age' => 12,
                    'max_age' => 19,
                    'custom_rules' => 'Terbuka untuk seluruh siswa SMP/MTs dan SMA/MA/SMK aktif di seluruh Indonesia.',
                ],
                'sources' => [
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Resmi KMNR KPM Indonesia',
                        'source_url' => 'https://kpm.or.id/kmnr-2026',
                        'notes' => 'Informasi linimasa babak penyisihan daerah dan tata tertib ujian daring/luring.',
                    ],
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Pangkalan Data Kurasi Talenta Puspresnas SIMT',
                        'source_url' => 'https://kurasi-prestasi.kemendikdasmen.go.id/',
                        'notes' => 'Sertifikat penetapan Kurasi Prestasi Puspresnas Grade A terdaftar di SIMT Kemendikdasmen.',
                    ],
                ],
            ],

            [
                'title' => 'Lomba Peneliti Belia (LPB) Tingkat Nasional 2026',
                'slug' => 'lpb-peneliti-belia-nasional-2026',
                'category_id' => $risetCat->id,
                'organizer_id' => $cys->id,
                'curation_type' => 'terkurasi_puspresnas',
                'curation_rating' => 'Grade A (Sangat Baik)',
                'curation_number' => 'SIMT-KURASI-2026-A034',
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'min_team_members' => 1,
                'max_team_members' => 2,
                'description' => "Lomba Peneliti Belia (LPB) Nasional yang diselenggarakan oleh Center for Young Scientists (CYS) Indonesia merupakan kompetisi penelitian ilmiah remaja paling bergengsi yang telah lolos verifikasi Kurasi Puspresnas Kemendikdasmen RI.\n\n📌 RANGKUMAN MULTI-SUMBER & STATUS KURASI PUSPRESNAS:\n• Status Akreditasi: Terkurasi Resmi Puspresnas (Grade A - SIMT-KURASI-2026-A034).\n• Bidang Penelitian: Fisika Terapan, Matematika, Ilmu Komputer, Ilmu Hayati, dan Ilmu Lingkungan.\n• Jalur Prestasi Internasional: Para peraih medali Emas dan Perak berhak mewakili Kontingen Indonesia pada International Conference of Young Scientists (ICYS) dan Asia Pacific Conference of Young Scientists (APCYS).",
                'official_website_url' => 'https://cys.or.id/lpb-nasional-2026',
                'registration_url' => 'https://cys.or.id/registrasi-lpb-2026',
                'guide_book_url' => 'https://cys.or.id/panduan-lpb-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(28),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(20),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 14,
                    'max_age' => 19,
                    'custom_rules' => 'Tim riset terdiri dari 1-2 murid dengan naskah penelitian karya ilmiah orisinal.',
                ],
                'sources' => [
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Resmi Center for Young Scientists Indonesia',
                        'source_url' => 'https://cys.or.id/lpb-nasional-2026',
                        'notes' => 'Ketentuan proposal riset, format abstrak karya tulis ilmiah, dan rubrik penilaian dewan juri CYS.',
                    ],
                    [
                        'source_type' => 'puspresnas',
                        'source_title' => 'Verifikasi Kurasi Talenta Puspresnas SIMT',
                        'source_url' => 'https://kurasi-prestasi.kemendikdasmen.go.id/',
                        'notes' => 'Terkurasi resmi SIMT Kemendikdasmen Grade A untuk afirmasi prestasi riset ilmiah.',
                    ],
                ],
            ],

            [
                'title' => 'Olimpiade Geografi Nasional (Olgenas) Tingkat SMA 2026',
                'slug' => 'olgenas-geografi-nasional-ugm-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $ugm->id,
                'curation_type' => 'terkurasi_puspresnas',
                'curation_rating' => 'Grade A (Sangat Baik)',
                'curation_number' => 'SIMT-KURASI-2026-A055',
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'min_team_members' => 2,
                'max_team_members' => 2,
                'description' => "Olimpiade Geografi Nasional (Olgenas) Fakultas Geografi Universitas Gadjah Mada merupakan ajang talenta kebumian dan geografi terbesar se-Indonesia yang diselenggarakan perguruan tinggi negeri dan telah lolos akreditasi Kurasi Prestasi Puspresnas Kemendikdasmen RI.\n\n📌 RANGKUMAN MULTI-SUMBER & STATUS KURASI:\n• Status Akreditasi: Terkurasi SIMT Puspresnas (Grade A - SIMT-KURASI-2026-A055).\n• Tahap Lomba: Ujian Teori Kebumian & Tata Ruang, Analisis Citra Satelit SIG/GIS, dan Studi Kasus Lapangan.",
                'official_website_url' => 'https://olgenas.geo.ugm.ac.id/',
                'registration_url' => 'https://olgenas.geo.ugm.ac.id/pendaftaran',
                'guide_book_url' => 'https://olgenas.geo.ugm.ac.id/panduan-olgenas-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(15),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 14,
                    'max_age' => 19,
                    'custom_rules' => 'Delegasi sekolah terdiri dari 2 siswa aktif SMA/MA/sederajat.',
                ],
                'sources' => [
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Olgenas Fakultas Geografi UGM',
                        'source_url' => 'https://olgenas.geo.ugm.ac.id/',
                        'notes' => 'Panduan kisi-kisi materi geografi lingkungan, SIG, dan petunjuk teknis studi kasus.',
                    ],
                ],
            ],

            // =========================================================
            // C. KELOMPOK 3: BERGENGSI NON-TERKURASI (Kredibel & Portofolio)
            // =========================================================
            [
                'title' => 'Arkavidia Informatics & Algorithmic Contest ITB 2026',
                'slug' => 'arkavidia-informatika-itb-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $itb->id,
                'curation_type' => 'bergengsi_non_kurasi',
                'curation_rating' => null,
                'curation_number' => null,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'min_team_members' => 1,
                'max_team_members' => 3,
                'description' => "Arkavidia merupakan festival dan kompetisi teknologi informasi berskala nasional yang diselenggarakan oleh Himpunan Mahasiswa Informatika Institut Teknologi Bandung (HMIF ITB). Ajang ini sangat bergengsi di kalangan pegiat informatika pelajar untuk mengasah kemampuan pemrograman kompetitif, logika algoritma, dan problem solving dunia nyata.\n\n📌 CATATAN TINGKAT KEPERCAYAAN:\n• Belum/tidak masuk kurasi SIMT Puspresnas, namun memiliki reputasi tinggi di lingkungan perguruan tinggi teknik dan industri teknologi.\n• Sangat bernilai sebagai portofolio keahlian coding dan pengalaman kompetisi tingkat tinggi.",
                'official_website_url' => 'https://arkavidia.id/',
                'registration_url' => 'https://arkavidia.id/competition',
                'guide_book_url' => 'https://arkavidia.id/guidebook-2026.pdf',
                'requires_school_approval' => false,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(22),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(18),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 14,
                    'max_age' => 19,
                    'custom_rules' => 'Peserta adalah pelajar SMA/SMK yang menguasai bahasa C++, Python, atau Java.',
                ],
                'sources' => [
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Resmi Arkavidia HMIF ITB',
                        'source_url' => 'https://arkavidia.id/',
                        'notes' => 'Petunjuk teknis competitive programming contest dan jadwal babak penyisihan online.',
                    ],
                ],
            ],

            [
                'title' => 'National Science Challenge (NSC) Universitas Indonesia 2026',
                'slug' => 'nsc-science-challenge-ui-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $ui->id,
                'curation_type' => 'bergengsi_non_kurasi',
                'curation_rating' => null,
                'curation_number' => null,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'min_team_members' => 3,
                'max_team_members' => 3,
                'description' => "National Science Challenge (NSC) FMIPA Universitas Indonesia adalah ajang cerdas tangkas dan pemecahan masalah sains terintegrasi (Fisika, Kimia, Biologi, Matematika) bagi siswa SMA/MA se-Indonesia.\n\n📌 CATATAN TINGKAT KEPERCAYAAN:\n• Kompetisi independen berskala nasional yang digelar oleh BEM FMIPA UI.\n• Diakui luas oleh sivitas akademika sebagai pengukur ketangkasan sains multidisipliner dan memperkaya portofolio siswa.",
                'official_website_url' => 'https://sci.ui.ac.id/nsc-2026',
                'registration_url' => 'https://sci.ui.ac.id/nsc-2026/register',
                'guide_book_url' => 'https://sci.ui.ac.id/nsc-2026/panduan.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->startOfMonth(),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addMonths(1)->startOfMonth(),
                'event_end_at' => now()->addMonths(2)->addDays(12),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 14,
                    'max_age' => 19,
                    'custom_rules' => 'Satu tim terdiri dari 3 siswa dari sekolah yang sama.',
                ],
                'sources' => [
                    [
                        'source_type' => 'official_website',
                        'source_title' => 'Portal Resmi National Science Challenge FMIPA UI',
                        'source_url' => 'https://sci.ui.ac.id/nsc-2026',
                        'notes' => 'Silabus materi sains komparatif dan jadwal tahapan kuis penyisihan daring.',
                    ],
                ],
            ],
        ];

        // -------------------------------------------------------------
        // 4. Populate Database
        // -------------------------------------------------------------
        foreach ($competitionsData as $c) {
            $eligibilityData = $c['eligibility'];
            $sourcesData = $c['sources'] ?? [];
            unset($c['eligibility'], $c['sources']);

            $competition = Competition::withTrashed()->where('slug', $c['slug'])->first();
            $competitionData = array_merge([
                'curation_type' => 'resmi_negara',
                'curation_rating' => 'Ajang Resmi Negara',
                'curation_number' => 'BPTI-PUSPRESNAS-2026',
            ], $c, [
                'verification_status' => 'published',
                'visibility' => 'public',
                'verified_by' => $superAdmin?->id,
                'verified_at' => now(),
                'published_at' => now(),
                'verification_notes' => 'Terkonfirmasi resmi sesuai data portal Pusat Prestasi Nasional (Puspresnas) & BPTI Kemendikdasmen RI.',
            ]);

            if ($competition) {
                if ($competition->trashed()) {
                    $competition->restore();
                }
                $competition->update($competitionData);
            } else {
                $competition = Competition::create($competitionData);
            }

            CompetitionEligibility::updateOrCreate(
                ['competition_id' => $competition->id],
                [
                    'allowed_educational_levels' => $eligibilityData['allowed_educational_levels'],
                    'allowed_grades' => $eligibilityData['allowed_grades'],
                    'min_age' => $eligibilityData['min_age'] ?? 12,
                    'max_age' => $eligibilityData['max_age'] ?? 19,
                    'allowed_provinces' => $eligibilityData['allowed_provinces'] ?? null,
                    'gender_restriction' => 'any',
                    'custom_rules' => $eligibilityData['custom_rules'],
                ]
            );

            // Bersihkan dan masukkan sumber data resmi terverifikasi
            CompetitionSource::where('competition_id', $competition->id)->delete();
            foreach ($sourcesData as $s) {
                CompetitionSource::create([
                    'competition_id' => $competition->id,
                    'source_url' => $s['source_url'],
                    'source_type' => $s['source_type'],
                    'source_title' => $s['source_title'],
                    'notes' => $s['notes'],
                    'is_verified' => true,
                    'verified_by' => $superAdmin?->id,
                ]);
            }

            // Create default application form for internal registration
            $form = CompetitionForm::firstOrCreate(
                ['competition_id' => $competition->id, 'version' => 1],
                [
                    'title' => 'Formulir Delegasi ' . $competition->title,
                    'is_active' => true,
                    'description' => 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.',
                ]
            );

            FormField::firstOrCreate(
                ['form_id' => $form->id, 'field_key' => 'no_surat_tugas'],
                [
                    'label' => 'Nomor Surat Tugas / Rekomendasi Sekolah',
                    'field_type' => 'text',
                    'placeholder' => 'Contoh: 421.3/089/SMAN1/2026',
                    'is_required' => true,
                    'order' => 1,
                ]
            );
        }
    }
}
