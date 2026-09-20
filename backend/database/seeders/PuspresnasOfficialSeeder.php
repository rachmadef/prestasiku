<?php

namespace Database\Seeders;

use App\Models\Competition;
use App\Models\CompetitionCategory;
use App\Models\CompetitionEligibility;
use App\Models\CompetitionSource;
use App\Models\Organizer;
use App\Models\User;
use Illuminate\Database\Seeder;

class PuspresnasOfficialSeeder extends Seeder
{
    public function run(): void
    {
        $superAdmin = User::role('super_admin')->first();

        // -------------------------------------------------------------
        // 1. Kategori Tambahan (Kewirausahaan & Vokasi)
        // -------------------------------------------------------------
        $vokasiCat = CompetitionCategory::firstOrCreate(
            ['slug' => 'kewirausahaan-dan-vokasi'],
            [
                'name' => 'Kewirausahaan & Vokasi',
                'description' => 'Ajang inovasi bisnis, kewirausahaan, dan kompetensi keahlian vokasi siswa kejuruan.',
                'icon' => 'briefcase',
            ]
        );

        $sainsCat = CompetitionCategory::where('slug', 'sains-dan-matematika')->first();
        $olahragaCat = CompetitionCategory::where('slug', 'olahraga-dan-kebugaran')->first();
        $seniCat = CompetitionCategory::where('slug', 'seni-dan-budaya')->first();
        $risetCat = CompetitionCategory::where('slug', 'riset-dan-karya-ilmiah')->first();
        $bahasaCat = CompetitionCategory::where('slug', 'bahasa-dan-literasi')->first();
        $teknoCat = CompetitionCategory::where('slug', 'teknologi-dan-robotika')->first();

        // -------------------------------------------------------------
        // 2. Lembaga Penyelenggara Resmi (Puspresnas & Mitra)
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

        $disdikDki = Organizer::updateOrCreate(
            ['name' => 'Dinas Pendidikan Provinsi DKI Jakarta'],
            [
                'type' => 'dinas_pendidikan',
                'website' => 'https://disdik.jakarta.go.id',
                'instagram' => '@disdikdki',
                'email' => 'disdik@jakarta.go.id',
                'phone' => '021-3848411',
                'verification_status' => 'official',
                'verified_at' => now(),
                'verified_by' => $superAdmin?->id,
                'verification_notes' => 'Instansi dinas pembina kompetisi seleksi tingkat provinsi DKI Jakarta.',
            ]
        );

        // -------------------------------------------------------------
        // 3. Database Kompetisi Resmi Puspresnas
        // -------------------------------------------------------------
        $competitionsData = [
            // 1. OSN SMA
            [
                'title' => 'Olimpiade Sains Nasional (OSN) Jenjang SMA/MA Tingkat Nasional 2026',
                'slug' => 'osn-sma-nasional-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "Olimpiade Sains Nasional (OSN) adalah ajang kompetisi sains tahunan bergengsi bagi peserta didik SMA/MA seluruh Indonesia yang diselenggarakan oleh Balai Pengembangan Talenta Indonesia (BPTI) Kemendikdasmen.\n\n9 Bidang Kompetisi:\n1. Matematika\n2. Fisika\n3. Kimia\n4. Biologi\n5. Informatika/Komputer\n6. Astronomi\n7. Ekonomi\n8. Kebumian\n9. Geografi\n\nPemenang medali emas, perak, dan perunggu akan mendapatkan pembinaan untuk mewakili Indonesia pada ajang olimpiade sains internasional (IMO, IPhO, IChO, IBO, IOI, IOAA, IEO, IESO, iGeo).",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/osn-sma-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-sma-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(10),
                'registration_deadline' => now()->addDays(25),
                'event_start_at' => now()->addDays(40),
                'event_end_at' => now()->addDays(46),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Peserta adalah siswa aktif kelas 10 atau 11 SMA/MA/Sederajat yang terdaftar di Dapodik/EMIS dan memiliki surat rekomendasi resmi dari Kepala Sekolah.',
                ],
            ],

            // 2. OSN SMP
            [
                'title' => 'Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs Tingkat Nasional 2026',
                'slug' => 'osn-smp-nasional-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'individual',
                'description' => "Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs diselenggarakan untuk mencetak generasi penerus yang unggul, kritis, dan berdaya saing dalam penguasaan sains dasar.\n\n3 Bidang Kompetisi:\n1. Matematika\n2. Ilmu Pengetahuan Alam (IPA)\n3. Ilmu Pengetahuan Sosial (IPS)\n\nDiselenggarakan secara berjenjang dari tingkat sekolah, kabupaten/kota, provinsi, hingga final nasional.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/osn-smp-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-smp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(10),
                'registration_deadline' => now()->addDays(20),
                'event_start_at' => now()->addDays(35),
                'event_end_at' => now()->addDays(39),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 11,
                    'max_age' => 15,
                    'custom_rules' => 'Peserta adalah siswa aktif kelas 7 atau 8 SMP/MTs yang belum pernah meraih medali emas pada OSN tingkat nasional sebelumnya.',
                ],
            ],

            // 3. O2SN SMA/SMK
            [
                'title' => 'Olimpiade Olahraga Siswa Nasional (O2SN) Tingkat SMA/SMK 2026',
                'slug' => 'o2sn-sma-smk-2026',
                'category_id' => $olahragaCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "O2SN SMA/SMK merupakan wahana aktualisasi bakat olahraga pelajar tingkat nasional untuk menumbuhkan sportivitas, daya juang, dan kebugaran jasmani.\n\n5 Cabang Olahraga:\n1. Atletik\n2. Renang\n3. Bulu Tangkis\n4. Pencak Silat\n5. Karate\n\nSetiap kontingen sekolah mewakili hasil seleksi ketat tingkat cabang dinas pendidikan wilayah.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/o2sn-sma-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(5),
                'registration_deadline' => now()->addDays(30),
                'event_start_at' => now()->addDays(50),
                'event_end_at' => now()->addDays(56),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Atlet pelajar non-pelatnas yang berstatus siswa aktif sekolah formal tingkat SLTA.',
                ],
            ],

            // 4. O2SN SMP
            [
                'title' => 'Olimpiade Olahraga Siswa Nasional (O2SN) Tingkat SMP/MTs 2026',
                'slug' => 'o2sn-smp-mts-2026',
                'category_id' => $olahragaCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'individual',
                'description' => "Kompetisi olahraga pelajar SMP tingkat nasional yang memfasilitasi pembibitan atlet usia muda.\n\nCabang Olahraga:\n1. Atletik (Lari, Lompat Jauh, Tolak Peluru)\n2. Renang (Gaya Bebas, Dada, Punggung, Kupu-kupu)\n3. Bulu Tangkis (Tunggal Putra & Putri)\n4. Pencak Silat (Jurus Tunggal & Tanding)\n5. Karate (Kata & Kumite)\n6. Senam Artistik",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/o2sn-smp-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-smp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(5),
                'registration_deadline' => now()->addDays(28),
                'event_start_at' => now()->addDays(45),
                'event_end_at' => now()->addDays(50),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 12,
                    'max_age' => 15,
                    'custom_rules' => 'Memiliki surat keterangan sehat jasmani dan rekomendasi sekolah.',
                ],
            ],

            // 5. FLS2N SMA
            [
                'title' => 'Festival dan Lomba Seni Siswa Nasional (FLS2N) Jenjang SMA/MA/SMK 2026',
                'slug' => 'fls2n-sma-smk-2026',
                'category_id' => $seniCat->id,
                'organizer_id' => $puspresnas->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'both',
                'description' => "FLS2N merupakan wadah ekspresi seni dan kreativitas budaya nusantara terbesar bagi pelajar SMA dan SMK di Indonesia.\n\nCabang Lomba Seni:\n1. Baca Puisi\n2. Gitar Solo\n3. Monolog\n4. Tari Kreasi\n5. Vokal Solo (Putra & Putri)\n6. Desain Poster Digital\n7. Film Pendek (Fiksi & Dokumenter)\n8. Kriya Anyam & Kayu\n9. Komik Digital\n10. Cipta Lagu & Aransemen Musik\n11. Jurnalistik Pelajar\n12. Fotografi Artistik",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/fls2n-sma-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls2n-sma-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(12),
                'registration_deadline' => now()->addDays(22),
                'event_start_at' => now()->addDays(38),
                'event_end_at' => now()->addDays(44),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Karya seni yang diikutsertakan adalah karya orisinal dan belum pernah memenangkan kejuaraan nasional lain.',
                ],
            ],

            // 6. FLS2N SMP
            [
                'title' => 'Festival dan Lomba Seni Siswa Nasional (FLS2N) Jenjang SMP/MTs 2026',
                'slug' => 'fls2n-smp-mts-2026',
                'category_id' => $seniCat->id,
                'organizer_id' => $puspresnas->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'both',
                'description' => "Ajang pelestarian budaya dan pengembangan talenta seni bagi peserta didik sekolah menengah pertama.\n\nCabang Lomba:\n1. Menyanyi Solo\n2. Tari Kreasi Tradisional\n3. Musik Tradisional Khas Daerah\n4. Pantomim Cerita Anak Nusantara\n5. Ansambel Musik Campuran\n6. Gambar Ilustrasi Berbasis Cerita Rakyat",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/fls2n-smp-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls2n-smp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(8),
                'registration_deadline' => now()->addDays(18),
                'event_start_at' => now()->addDays(34),
                'event_end_at' => now()->addDays(38),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 12,
                    'max_age' => 15,
                    'custom_rules' => 'Siswa SMP berstatus aktif di Dapodik/EMIS dan didaftarkan melalui operator sekolah resmi.',
                ],
            ],

            // 7. KoPSI SMA
            [
                'title' => 'Kompetisi Penelitian Siswa Indonesia (KoPSI) Jenjang SMA/MA 2026',
                'slug' => 'kopsi-sma-ma-2026',
                'category_id' => $risetCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'description' => "Kompetisi Penelitian Siswa Indonesia (KoPSI) bertujuan membina nalar kritis, rasa ingin tahu ilmiah, dan metodologi penelitian berstandar akademis bagi peneliti muda SMA/MA.\n\n3 Bidang Penelitian Ilmiah:\n1. Matematika, Sains, dan Teknologi (MST)\n2. Fisika Terapan dan Rekayasa (FTR)\n3. Ilmu Sosial dan Humaniora (ISH)\n\nKarya tulis terbaik berkesempatan dipublikasikan di jurnal ilmiah dan mewakili Indonesia pada ajang riset internasional (ISEF).",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/kopsi-sma-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-kopsi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(15),
                'registration_deadline' => now()->addDays(35),
                'event_start_at' => now()->addDays(60),
                'event_end_at' => now()->addDays(65),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Tim terdiri atas maksimal 2 orang siswa dengan bimbingan 1 guru pembimbing dari sekolah yang sama.',
                ],
            ],

            // 8. LDBI SMA
            [
                'title' => 'Lomba Debat Bahasa Indonesia (LDBI) Tingkat Nasional 2026',
                'slug' => 'ldbi-nasional-2026',
                'category_id' => $bahasaCat->id,
                'organizer_id' => $puspresnas->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'description' => "LDBI adalah kompetisi debat parlementer dalam Bahasa Indonesia untuk mengasah argumentasi kritis, logika berpikir terstruktur, pemahaman isu sosial-kebangsaan, dan wawasan global bagi pelajar SMA/SMK seluruh Indonesia.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/ldbi-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-ldbi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(7),
                'registration_deadline' => now()->addDays(21),
                'event_start_at' => now()->addDays(42),
                'event_end_at' => now()->addDays(47),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Delegasi sekolah terdiri atas 3 pembicara (1 tim debat) yang lolos seleksi awal tingkat provinsi.',
                ],
            ],

            // 9. NSDC SMA
            [
                'title' => 'National Schools Debating Championship (NSDC) 2026',
                'slug' => 'nsdc-nasional-2026',
                'category_id' => $bahasaCat->id,
                'organizer_id' => $puspresnas->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'team',
                'description' => "NSDC adalah kejuaraan debat bahasa Inggris resmi bagi pelajar SMA/MA/SMK tingkat nasional dengan format World Schools Debating Championship (WSDC). Best speaker nasional akan diseleksi masuk ke Team Indonesia WSDC.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/nsdc-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-nsdc-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(7),
                'registration_deadline' => now()->addDays(21),
                'event_start_at' => now()->addDays(42),
                'event_end_at' => now()->addDays(47),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'custom_rules' => 'Memiliki kemampuan komunikasi Bahasa Inggris aktif dan surat rekomendasi sekolah.',
                ],
            ],

            // 10. FIKSI SMA/SMK
            [
                'title' => 'Festival Inovasi dan Kewirausahaan Siswa Indonesia (FIKSI) 2026',
                'slug' => 'fiksi-nasional-2026',
                'category_id' => $vokasiCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'both',
                'description' => "FIKSI merupakan ajang kewirausahaan siswa SMA/SMK untuk memupuk jiwa 'entrepreneurship' muda berwawasan sosial, digital, dan berkelanjutan.\n\nKategori Produk Usaha:\n1. Rintisan Bisnis Digital & Game\n2. Kriya & Desain Kemasan Kreatif\n3. Agribisnis & Pangan Berkelanjutan\n4. Pariwisata & Kuliner Nusantara\n5. Industri Kreatif Mode & Fashion",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/fiksi-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fiksi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(14),
                'registration_deadline' => now()->addDays(32),
                'event_start_at' => now()->addDays(55),
                'event_end_at' => now()->addDays(60),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11, 12],
                    'min_age' => 15,
                    'max_age' => 19,
                    'custom_rules' => 'Rencana usaha (Business Plan) orisinal dengan prototipe produk yang telah diuji pasar.',
                ],
            ],

            // 11. GSI SMP
            [
                'title' => 'Gala Siswa Indonesia (GSI) Jenjang SMP Tingkat Nasional 2026',
                'slug' => 'gsi-smp-nasional-2026',
                'category_id' => $olahragaCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'sltp',
                'participation_type' => 'team',
                'description' => "Gala Siswa Indonesia (GSI) adalah kompetisi sepak bola pelajar SMP resmi yang diselenggarakan melalui kerja sama BPTI Kemendikdasmen dengan PSSI untuk mengidentifikasi talenta muda sepak bola nasional.",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/gsi-smp-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-gsi-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(20),
                'registration_deadline' => now()->addDays(15),
                'event_start_at' => now()->addDays(30),
                'event_end_at' => now()->addDays(38),
                'eligibility' => [
                    'allowed_educational_levels' => ['sltp'],
                    'allowed_grades' => [7, 8],
                    'min_age' => 12,
                    'max_age' => 14,
                    'custom_rules' => 'Pemain sepak bola terdaftar di sekolah dan telah lolos seleksi kecamatan/kabupaten.',
                ],
            ],

            // 12. LKS SMK
            [
                'title' => 'Lomba Kompetensi Siswa (LKS) SMK Tingkat Nasional XXXIV 2026',
                'slug' => 'lks-smk-nasional-2026',
                'category_id' => $vokasiCat->id,
                'organizer_id' => $bpti->id,
                'level' => 'nasional',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "LKS SMK merupakan ajang unjuk keahlian vokasi tertinggi bagi siswa SMK seluruh Indonesia yang mengacu pada standar kompetensi WorldSkills International (WSI).\n\nBidang Keahlian:\n- Cloud Computing & Cyber Security\n- Web Technologies & Software Application\n- Mechatronics & Industrial Automation\n- Automobile Technology & CNC Milling\n- Graphic Design Technology & 3D Animation\n- Hotel Reception & Restaurant Service",
                'official_website_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/ajang-talenta/lks-smk-2026',
                'guide_book_url' => 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-lks-smk-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(10),
                'registration_deadline' => now()->addDays(25),
                'event_start_at' => now()->addDays(48),
                'event_end_at' => now()->addDays(54),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [11, 12],
                    'min_age' => 15,
                    'max_age' => 19,
                    'custom_rules' => 'Peserta adalah siswa SMK aktif yang menjadi juara 1 di LKS tingkat provinsi masing-masing.',
                ],
            ],

            // 13. OSN-P Tingkat Provinsi DKI Jakarta
            [
                'title' => 'Seleksi Daerah Olimpiade Sains Tingkat Provinsi (OSN-P) DKI Jakarta 2026',
                'slug' => 'osn-p-dki-jakarta-2026',
                'category_id' => $sainsCat->id,
                'organizer_id' => $disdikDki->id,
                'level' => 'provinsi',
                'target_level' => 'slta',
                'participation_type' => 'individual',
                'description' => "Tahapan seleksi kompetisi sains resmi tingkat provinsi yang diselenggarakan oleh Dinas Pendidikan Provinsi DKI Jakarta untuk menyaring delegasi menuju final OSN Tingkat Nasional.",
                'official_website_url' => 'https://disdik.jakarta.go.id/osn-provinsi-2026',
                'guide_book_url' => 'https://disdik.jakarta.go.id/panduan-osnp-2026.pdf',
                'requires_school_approval' => true,
                'registration_fee' => 0,
                'registration_open_at' => now()->subDays(10),
                'registration_deadline' => now()->addDays(14),
                'event_start_at' => now()->addDays(25),
                'event_end_at' => now()->addDays(28),
                'eligibility' => [
                    'allowed_educational_levels' => ['slta'],
                    'allowed_grades' => [10, 11],
                    'min_age' => 14,
                    'max_age' => 18,
                    'allowed_provinces' => ['DKI Jakarta'],
                    'custom_rules' => 'Khusus siswa SMA/MA yang bersekolah di wilayah administratif Provinsi DKI Jakarta dan lolos passing grade OSN-K.',
                ],
            ],
        ];

        foreach ($competitionsData as $c) {
            $eligibilityData = $c['eligibility'];
            unset($c['eligibility']);

            $competition = Competition::updateOrCreate(
                ['slug' => $c['slug']],
                array_merge($c, [
                    'verification_status' => 'published',
                    'visibility' => 'public',
                    'verified_by' => $superAdmin?->id,
                    'verified_at' => now(),
                    'published_at' => now(),
                    'verification_notes' => 'Terkonfirmasi resmi sesuai pedoman Puspresnas Kemendikdasmen RI.',
                ])
            );

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

            CompetitionSource::updateOrCreate(
                [
                    'competition_id' => $competition->id,
                    'source_url' => $c['official_website_url'],
                ],
                [
                    'source_type' => 'puspresnas',
                    'source_title' => 'Portal Resmi Ajang Talenta Puspresnas',
                    'is_verified' => true,
                    'verified_by' => $superAdmin?->id,
                    'notes' => 'Portal resmi https://pusatprestasinasional.kemendikdasmen.go.id/',
                ]
            );
        }
    }
}
