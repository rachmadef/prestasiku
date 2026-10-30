
CREATE TABLE `achievements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `public_id` varchar(40) NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED DEFAULT NULL,
  `registration_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `level` enum('kota_kabupaten','provinsi','nasional','internasional') NOT NULL DEFAULT 'nasional',
  `rank` varchar(100) NOT NULL,
  `event_name` varchar(255) NOT NULL,
  `organizer_name` varchar(255) NOT NULL,
  `event_date` date NOT NULL,
  `status` enum('draft','pending_verification','verified','rejected') NOT NULL DEFAULT 'pending_verification',
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `achievements`
--

INSERT INTO `achievements` (`id`, `public_id`, `student_id`, `school_id`, `competition_id`, `registration_id`, `title`, `level`, `rank`, `event_name`, `organizer_name`, `event_date`, `status`, `verified_by`, `verified_at`, `verification_notes`, `is_public`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'PKU-ACH-2026-JMCNZT7U', 416, 1, NULL, NULL, 'MTRQ Universitas Brawijaya', 'nasional', 'Final', 'MTRQ Universitas Brawijaya', 'Universitas Brawijaya', '2026-09-26', 'verified', 641, '2026-10-29 05:08:16', NULL, 1, '2026-10-28 22:08:16', '2026-10-28 22:08:16', NULL),
(2, 'PKU-ACH-2026-HK5KYJ5F', 401, 1, NULL, NULL, 'Olimnus Islamic 2026', 'nasional', 'Juara 1/Gold Medal', 'Olimnus Islamic 2026', 'Universitas Brawijaya', '2026-08-21', 'verified', 641, '2026-10-29 05:30:04', NULL, 1, '2026-10-28 22:30:04', '2026-10-28 22:30:04', NULL),
(3, 'PKU-ACH-2026-WVAZJ9GC', 1, 1, 15, NULL, 'Arkavidia Informatics & Algorithmic Contest ITB 2026', 'nasional', 'Juara 1', 'Arkavidia Informatics & Algorithmic Contest ITB 2026', 'Institut Teknologi Bandung (ITB)', '2026-10-29', 'pending_verification', NULL, NULL, NULL, 0, '2026-10-28 22:40:59', '2026-10-28 22:40:59', NULL),
(4, 'PKU-ACH-2026-GT9FMN1D', 255, 1, NULL, NULL, 'Musabaqoh Tilawatil Qur\'an  (MTQ) XXXII', 'kota_kabupaten', 'Juara 3', 'Musabaqoh Tilawatil Qur\'an  (MTQ) XXXII', 'Pemerintah Kabupaten Jombang', '2026-04-27', 'verified', 641, '2026-10-29 05:43:36', NULL, 1, '2026-10-28 22:43:36', '2026-10-28 22:43:36', NULL),
(5, 'PKU-ACH-2026-06L9VMCB', 255, 1, NULL, NULL, 'National Student Summit (NSS) 2026', 'nasional', 'Juara 1', 'National Student Summit (NSS) 2026', 'Fakultas Humaniora  Universitas Islam Negeri Maulana Malik Ibrahim', '2026-10-19', 'verified', 641, '2026-10-29 05:51:46', NULL, 1, '2026-10-28 22:51:46', '2026-10-28 22:51:46', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `achievement_documents`
--

CREATE TABLE `achievement_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `achievement_id` bigint(20) UNSIGNED NOT NULL,
  `document_type` enum('certificate','decree_sk','assignment_letter','result_link','photo_documentation') NOT NULL DEFAULT 'certificate',
  `document_number` varchar(255) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `external_url` varchar(500) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_size` int(10) UNSIGNED DEFAULT NULL,
  `file_mime` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `achievement_documents`
--

INSERT INTO `achievement_documents` (`id`, `achievement_id`, `document_type`, `document_number`, `file_path`, `external_url`, `file_name`, `file_size`, `file_mime`, `created_at`, `updated_at`) VALUES
(1, 2, 'certificate', NULL, 'achievements/2/SiEZ1l4TM8cZ7Wgy6iqZ08FWVcb66XmOKP3y7to8.pdf', NULL, 'Olimnus Islamic 2026 Achmad Rafi Ar-Rochman_2026.pdf', 241732, 'application/pdf', '2026-10-28 22:30:04', '2026-10-28 22:30:04'),
(2, 4, 'certificate', NULL, 'achievements/4/HVcZdxTPRWw6rSAE1lqFk2PxtW3xX4QTXI1S9U6Q.pdf', NULL, 'Piagam Prestasi MHQ_ Aida Azka Aulia_MAUWH.pdf', 360710, 'application/pdf', '2026-10-28 22:43:36', '2026-10-28 22:43:36'),
(3, 5, 'certificate', NULL, 'achievements/5/lQAUcv5BXIQhZqKMoGBfQwvh4Khusx8z4FxrQSJl.pdf', NULL, 'Sertifikat NSS 2026 UINMA _Aida Azka Aulia  (4).pdf', 323085, 'application/pdf', '2026-10-28 22:51:47', '2026-10-28 22:51:47');

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `competitions`
--

CREATE TABLE `competitions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `organizer_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `curation_type` enum('resmi_negara','terkurasi_puspresnas','bergengsi_non_kurasi') NOT NULL DEFAULT 'resmi_negara',
  `curation_rating` varchar(255) DEFAULT NULL,
  `curation_number` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `level` enum('provinsi','nasional') NOT NULL DEFAULT 'nasional',
  `target_level` enum('sltp','slta','both') NOT NULL DEFAULT 'slta',
  `description` text NOT NULL,
  `official_website_url` varchar(255) DEFAULT NULL,
  `registration_url` varchar(255) DEFAULT NULL,
  `guide_book_url` varchar(255) DEFAULT NULL,
  `poster_url` varchar(255) DEFAULT NULL,
  `participation_type` enum('individual','team','both') NOT NULL DEFAULT 'individual',
  `min_team_members` tinyint(4) NOT NULL DEFAULT 1,
  `max_team_members` tinyint(4) NOT NULL DEFAULT 1,
  `requires_school_approval` tinyint(1) NOT NULL DEFAULT 1,
  `registration_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `registration_open_at` datetime NOT NULL,
  `registration_deadline` datetime NOT NULL,
  `event_start_at` datetime NOT NULL,
  `event_end_at` datetime NOT NULL,
  `result_published_at` datetime DEFAULT NULL,
  `verification_status` enum('draft','pending_verification','source_verified','published','cancelled','rejected','expired') NOT NULL DEFAULT 'draft',
  `visibility` enum('public','school_only','hidden') NOT NULL DEFAULT 'public',
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `competitions`
--

INSERT INTO `competitions` (`id`, `organizer_id`, `category_id`, `curation_type`, `curation_rating`, `curation_number`, `title`, `slug`, `level`, `target_level`, `description`, `official_website_url`, `registration_url`, `guide_book_url`, `poster_url`, `participation_type`, `min_team_members`, `max_team_members`, `requires_school_approval`, `registration_fee`, `registration_open_at`, `registration_deadline`, `event_start_at`, `event_end_at`, `result_published_at`, `verification_status`, `visibility`, `verified_by`, `verified_at`, `verification_notes`, `published_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 2, 1, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Olimpiade Sains Nasional (OSN) Jenjang SMA/MA 2026', 'osn-tingkat-sma-2026', 'nasional', 'slta', 'Panduan Olimpiade Sains Nasional (OSN) telah resmi dirilis oleh Pusat Prestasi Nasional (Puspresnas) dan Balai Pengembangan Talenta Indonesia (BPTI) Kemendikdasmen RI sebagai acuan dalam pelaksanaan dan persiapan OSN 2026. Kehadiran panduan ini memberikan gambaran yang jelas dan komprehensif mengenai mekanisme seleksi, ketentuan lomba, serta ruang lingkup materi yang diujikan sehingga peserta didik, guru pembina, dan satuan pendidikan dapat melakukan persiapan secara lebih terarah dan sistematis.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan dokumen resmi Puspresnas Kemendikdasmen, Pedoman BPTI, dan Sistem Informasi Manajemen Talenta (SIMT):\n\n1. Sembilan (9) Cabang Bidang Sains yang Diujikan:\n• Astronomi\n• Biologi\n• Ekonomi\n• Fisika\n• Geografi\n• Informatika / Komputer\n• Kebumian\n• Kimia\n• Matematika\n\n2. Alur Seleksi Berjenjang:\n• Seleksi Tingkat Sekolah (OSN-S)\n• Seleksi Tingkat Kabupaten/Kota (OSN-K) secara daring serentak berbasis CBT/ANBK\n• Seleksi Tingkat Provinsi (OSN-P)\n• Final Tingkat Nasional (OSN Nasional)\n\n3. Pengakuan Prestasi & Pembinaan:\n• Pemenang medali emas, perak, dan perunggu menerima e-sertifikat resmi Kemendikdasmen dan tercatat otomatis di Sistem Informasi Manajemen Talenta (SIMT).\n• Pembinaan Pelatnas menuju ajang olimpiade sains internasional (IMO, IPhO, IChO, IBO, IOI, IOAA, IEO, IESO, iGeo).\n• Rekomendasi prioritas penerima Beasiswa Indonesia Maju (BIM).', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-sains-nasional-2026-2026-sma', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-sma-2026.pdf', NULL, 'individual', 1, 1, 1, 0.00, '2026-08-01 00:00:00', '2026-09-20 23:59:59', '2026-09-15 08:00:00', '2026-09-21 17:00:00', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:40', '2026-10-11 05:06:57', '2026-10-11 18:28:00', NULL),
(2, 1, 2, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Olimpiade Penelitian Siswa Indonesia (OPSI) Jenjang Pendidikan Menengah 2026', 'olimpiade-penelitian-siswa-indonesia-opsi-2026', 'nasional', 'slta', 'Olimpiade Penelitian Siswa Indonesia (OPSI) merupakan salah satu program strategis Pusat Prestasi Nasional, Kementerian Pendidikan Dasar dan Menengah, dalam rangka membina dan mengembangkan talenta peserta didik jenjang pendidikan menengah di bidang penelitian dan inovasi. Pada jenjang Pendidikan Menengah (SMA/MA/SMK/MAK/sederajat), OPSI menjadi ruang aktualisasi kemampuan berpikir tingkat tinggi, kreativitas ilmiah, serta kepemimpinan intelektual peserta didik melalui kegiatan penelitian yang sistematis dan beretika.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Pedoman Teknis Riset Puspresnas & BPTI Kemendikdasmen:\n\n1. Tiga (3) Bidang Penelitian OPSI:\n• Matematika, Sains, dan Teknologi (MST)\n• Fisika Terapan dan Rekayasa (FTR)\n• Ilmu Sosial dan Humaniora (ISH)\n\n2. Tahapan Seleksi Riset:\n• Pengunggahan Proposal Penelitian\n• Penelitian Mandiri dengan Pembimbingan Sekolah\n• Pengunggahan Naskah Laporan Hasil Penelitian\n• Seleksi Naskah dan Penentuan Finalis Nasional\n• Pameran Virtual / Expo Poster dan Uji Wawancara Juri Nasional\n\n3. Apresiasi dan Fasilitas:\n• Karya penelitian terverifikasi dan tercatat pada pangkalan data talenta SIMT Kemendikdasmen.\n• Delegasi berprestasi berpeluang mewakili Indonesia di ajang internasional seperti Regeneron International Science and Engineering Fair (ISEF).', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-penelitian-siswa-indonesia-opsi-jenjang-pendidikan-menengah-2026-2026-sma', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-opsi-dikmen-2026.pdf', NULL, 'team', 1, 2, 1, 0.00, '2026-10-01 00:00:00', '2026-11-08 12:15:40', '2026-11-01 00:00:00', '2026-12-31 23:59:59', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:41', '2026-10-11 05:06:57', '2026-10-11 18:28:00', NULL),
(3, 2, 4, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Festival Lomba Seni dan Sastra Siswa Nasional (FLS3N) Jenjang Pendidikan Menengah 2026', 'festival-lomba-seni-dan-sastra-siswa-nasional-fls3n-2026', 'nasional', 'slta', 'Festival Lomba Seni dan Sastra Siswa Nasional (FLS3N) memberikan ruang bagi siswa untuk mengeksplorasi, mengembangkan, dan menyalurkan bakat seni dan sastra yang mereka miliki. Ajang ini menjadi sarana strategis untuk menumbuhkan kecintaan terhadap seni budaya nusantara, membangun karakter generasi muda yang kreatif, berprestasi, dan berdaya saing global.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Panduan Resmi Pelaksanaan FLS3N Puspresnas:\n\n1. Cabang Seni & Sastra yang Dilombakan:\n• Baca Puisi & Cipta Puisi\n• Cipta Cerpen\n• Menyanyi Solo (Kategori Putra & Putri)\n• Tari Kreasi Tradisional\n• Monolog\n• Kriya\n• Desain Poster Edukasi\n• Film Pendek (Kategori Fiksi & Dokumenter)\n• Gitar Solo & Fotografi\n\n2. Tahapan Seleksi:\n• Seleksi Tingkat Sekolah\n• Seleksi Tingkat Kabupaten/Kota melalui kurasi video karya\n• Seleksi Tingkat Provinsi\n• Pergelaran Babak Final Nasional secara luring tatap muka.', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/seni-budaya/sma/festival-lomba-seni-dan-sastra-siswa-nasional-fls3n-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls3n-dikmen-2026.pdf', NULL, 'both', 1, 3, 1, 0.00, '2026-10-01 00:00:00', '2026-11-05 12:15:40', '2026-11-01 00:00:00', '2027-01-21 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:41', '2026-10-11 05:06:57', '2026-10-11 18:28:00', NULL),
(4, 2, 5, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Olimpiade Olahraga Siswa Nasional (O2SN) Jenjang Pendidikan Menengah 2026', 'olimpiade-olahraga-siswa-nasional-o2sn-2026', 'nasional', 'slta', 'Pelaksanaan ajang talenta Olimpiade Olahraga Siswa Nasional (O2SN) selaras dengan penguatan karakter melalui 7 Kebiasaan Anak Indonesia Hebat, yaitu bangun pagi, beribadah, berolahraga, makan sehat dan bergizi, gemar belajar, bermasyarakat, serta tidur cepat. Nilai-nilai tersebut menjadi fondasi dalam membentuk murid yang sehat, disiplin, berintegritas, dan berdaya saing. O2SN merupakan bagian dari upaya strategis pemerintah dalam pembinaan olahraga pendidikan yang berjenjang, terarah, dan berkelanjutan, serta mendukung pelaksanaan Desain Besar Olahraga Nasional (DBON).\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Pedoman BPTI dan Regulasi Induk Organisasi Olahraga:\n\n1. Cabang Olahraga Resmi:\n• Atletik\n• Renang\n• Bulu Tangkis\n• Pencak Silat\n• Karate\n\n2. Mekanisme Seleksi:\n• Seleksi berjenjang dari tingkat Satuan Pendidikan, Kabupaten/Kota, Provinsi, hingga Final Nasional.\n• Penilaian dan penjurian mengacu pada standar federasi olahraga internasional terkait.', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/olahraga/sma/olimpiade-olahraga-siswa-nasional-o2sn-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-dikmen-2026.pdf', NULL, 'individual', 1, 1, 1, 0.00, '2026-10-01 00:00:00', '2026-11-10 12:15:40', '2026-11-01 00:00:00', '2026-12-26 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:42', '2026-10-11 05:06:57', '2026-10-11 18:28:00', NULL),
(5, 2, 7, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Festival Inovasi dan Kewirausahaan Siswa Nasional (FIKSI) 2026', 'festival-inovasi-dan-kewirausahaan-siswa-nasional-fiksi-2026', 'nasional', 'slta', 'FIKSI Tahun 2026 mengusung semangat baru dengan penekanan kuat pada integrasi tiga pilar utama: Ekonomi Hijau (Green Economy), Ekonomi Kreatif, dan Ekonomi Digital. Wirausahawan masa depan bukan hanya mereka yang mampu mencetak profit, tetapi mereka yang mampu memberikan solusi konkret atas permasalahan sosial dan ekologi. Melalui ajang ini, diharapkan lahir profil Pelajar Pancasila yang memiliki jiwa sociopreneur yang tangguh, etis, dan berwawasan global.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Panduan BPTI Puspresnas Kemendikdasmen:\n\n1. Kategori Bidang Usaha:\n• Kriya & Kerajinan Ramah Lingkungan\n• Desain Grafis, Game & Animasi Edukatif\n• Kuliner & Pangan Lokal Berkelanjutan\n• Agribisnis, Agroteknologi & Energi Bersih\n• Aplikasi Digital, FinTech & E-Commerce Sosial\n\n2. Tahapan Seleksi:\n• Pengunggahan Proposal Rencana Bisnis (Business Plan)\n• Validasi Pasar & Portofolio Prototipe Produk\n• Expo Pameran Produk & Wawancara Dewan Juri Investor/Praktisi.', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/festival-inovasi-dan-kewirausahaan-siswa-nasional-2026-2026-sma', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fiksi-2026.pdf', NULL, 'both', 1, 2, 1, 0.00, '2026-10-01 00:00:00', '2026-11-10 12:15:40', '2026-11-01 00:00:00', '2027-01-26 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:43', '2026-10-11 05:06:57', '2026-10-11 18:28:00', NULL),
(6, 2, 7, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Lomba Kompetensi Siswa Nasional (LKS) 2026', 'lomba-kompetensi-siswa-nasional-lks-2026', 'nasional', 'slta', 'Lomba Kompetensi Siswa (LKS) adalah sebuah ajang talenta di bidang kejuruan dan teknologi terapan yang diselenggarakan untuk peserta didik Sekolah Menengah Kejuruan (SMK) dan Sekolah Menengah Atas (SMA)/sederajat. Ajang LKS diselenggarakan secara bertingkat mulai dari daerah hingga nasional untuk menjaring peserta terbaik dari 38 provinsi di Indonesia yang mengacu pada standar kompetensi WorldSkills International.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nBerdasarkan Standar WorldSkills dan Juknis Kemendikdasmen:\n\n1. Klaster Keahlian Utama:\n• Teknologi Informasi & Komunikasi (Cyber Security, Web Technologies, Cloud Computing)\n• Rekayasa Mesin & Mekatronika (CNC Milling, Industrial Automation)\n• Seni Kreatif & Mode (Fashion Technology, Graphic Design Technology)\n• Layanan Sosial & Pariwisata (Hotel Reception, Restaurant Service)\n\n2. Jalur Prestasi Internasional:\n• Juara terbaik berhak mewakili Kontingen Indonesia pada WorldSkills ASEAN dan WorldSkills Competition.', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/lomba-kompetensi-siswa-nasional-2026-2026-sma', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-lks-2026.pdf', NULL, 'individual', 1, 1, 1, 0.00, '2026-10-01 00:00:00', '2026-11-05 12:15:40', '2026-11-01 00:00:00', '2026-12-31 23:59:59', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:43', '2026-10-11 05:06:57', '2026-10-11 18:28:00', NULL),
(7, 1, 6, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Lomba Debat Indonesia (LDI) / LDBI Tingkat Nasional 2026', 'lomba-debat-indonesia-tingkat-nasional-2026', 'nasional', 'slta', 'Pelaksanaan Lomba Debat Indonesia (LDI) / Lomba Debat Bahasa Indonesia (LDBI) Tingkat Nasional 2026 merupakan ajang unjuk kecakapan literasi, nalar kritis, dan komunikasi persuasif bagi peserta didik jenjang SMA/MA seluruh Indonesia dalam format debat parlementer resmi.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\n• Format kompetisi menggunakan sistem Asian Parliamentary Debate (3 vs 3).\n• Mosi debat mencakup isu strategis pendidikan nasional, transformasi energi terbarukan, kecerdasan buatan, ekonomi kerakyatan, dan kebudayaan nusantara.\n• Pemenang kontingen dan Best Speaker terbaik berhak mendapatkan e-sertifikat terakreditasi Kemendikdasmen yang terhubung ke SIMT.', 'https://pusatprestasinasional.kemendikdasmen.go.id/', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-ldbi-2026.pdf', NULL, 'team', 3, 3, 1, 0.00, '2026-10-01 00:00:00', '2026-10-31 12:15:40', '2026-11-01 00:00:00', '2026-12-21 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:43', '2026-10-11 05:06:58', '2026-10-11 18:28:00', NULL),
(8, 2, 1, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs 2026', 'osn-jenjang-smp-2026', 'nasional', 'sltp', 'Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs diselenggarakan oleh BPTI Kemendikdasmen untuk mencetak generasi talenta muda yang unggul, kritis, dan berdaya saing dalam penguasaan sains dasar.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\n1. Tiga (3) Bidang Sains:\n• Matematika\n• Ilmu Pengetahuan Alam (IPA)\n• Ilmu Pengetahuan Sosial (IPS)\n\n2. Mekanisme Seleksi:\n• Seleksi Satuan Pendidikan (OSN-S)\n• Seleksi Tingkat Kabupaten/Kota (OSN-K) sistem CBT daring\n• Seleksi Tingkat Provinsi (OSN-P)\n• Babak Final Nasional (OSN Nasional).', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-smp-2026.pdf', NULL, 'individual', 1, 1, 1, 0.00, '2026-10-01 00:00:00', '2026-10-31 12:15:40', '2026-11-01 00:00:00', '2026-12-26 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:43', '2026-10-11 05:06:58', '2026-10-11 18:28:00', NULL),
(9, 2, 5, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Gala Siswa Indonesia (GSI) Jenjang SMP Tingkat Nasional 2026', 'gsi-smp-nasional-2026', 'nasional', 'sltp', 'Gala Siswa Indonesia (GSI) adalah kompetisi sepak bola pelajar SMP resmi yang diselenggarakan melalui kerja sama BPTI Kemendikdasmen dengan PSSI untuk mengidentifikasi dan membina talenta muda sepak bola nasional.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\n• Kompetisi sepak bola bertingkat dari kecamatan, kabupaten/kota, provinsi, hingga final nasional.\n• Bekerja sama dengan PSSI dan Kementerian Pemuda dan Olahraga untuk talent scouting tim nasional usia muda.', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-gsi-2026.pdf', NULL, 'team', 11, 18, 1, 0.00, '2026-10-01 00:00:00', '2026-10-31 12:15:40', '2026-11-01 00:00:00', '2027-01-26 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:43', '2026-10-11 05:06:58', '2026-10-11 18:28:00', NULL),
(10, 2, 5, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Olimpiade Olahraga Siswa Nasional (O2SN) Jenjang SMP 2026', 'o2sn-jenjang-smp-2026', 'nasional', 'sltp', 'O2SN Jenjang SMP memfasilitasi pembibitan dan aktualisasi potensi atletik pelajar tingkat pertama menuju Desain Besar Olahraga Nasional (DBON).\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nCabang Olahraga yang Dilombakan:\n• Atletik (Nomor Lari, Lompat Jauh, Tolak Peluru)\n• Renang (Gaya Bebas, Dada, Punggung, Kupu-kupu)\n• Bulu Tangkis (Tunggal Putra & Putri)\n• Pencak Silat (Jurus Tunggal & Tanding)\n• Karate (Kata & Kumite)\n• Senam Artistik.', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-smp-2026.pdf', NULL, 'individual', 1, 1, 1, 0.00, '2026-10-01 00:00:00', '2026-10-31 12:15:40', '2026-11-01 00:00:00', '2026-12-31 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:44', '2026-10-11 05:06:58', '2026-10-11 18:28:00', NULL),
(11, 2, 4, 'resmi_negara', 'Ajang Resmi Negara', 'BPTI-PUSPRESNAS-2026', 'Festival dan Lomba Seni Siswa Nasional (FLS2N) Jenjang SMP 2026', 'fls2n-jenjang-smp-2026', 'nasional', 'sltp', 'FLS2N Jenjang SMP merupakan ajang apresiasi seni dan budaya nusantara bagi peserta didik sekolah menengah pertama se-Indonesia.\n\n📌 RANGKUMAN INFORMASI MULTI-SUMBER:\nCabang Lomba Seni:\n• Menyanyi Solo\n• Tari Kreasi Tradisional\n• Pantomim\n• Musik Tradisional Khas Nusantara\n• Ansambel Campuran\n• Ilustrasi Gambar Cerita Rakyat.', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'https://daftar-bpti.kemendikdasmen.go.id/', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls2n-smp-2026.pdf', NULL, 'both', 1, 5, 1, 0.00, '2026-10-01 00:00:00', '2026-10-31 12:15:40', '2026-11-01 00:00:00', '2027-01-05 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:00', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:44', '2026-10-11 05:06:58', '2026-10-11 18:28:00', NULL),
(12, 3, 1, 'terkurasi_puspresnas', 'Grade A (Sangat Baik)', 'SIMT-KURASI-2026-A019', 'Kompetisi Matematika Nalaria Realistik (KMNR) ke-21 2026', 'kmnr-tingkat-nasional-2026', 'nasional', 'both', 'Kompetisi Matematika Nalaria Realistik (KMNR) merupakan ajang olimpiade nalar matematika bergengsi tingkat nasional yang diselenggarakan oleh Klinik Pendidikan MIPA (KPM) dan telah resmi lolos Kurasi Prestasi Puspresnas Kemendikdasmen RI melalui Sistem Informasi Manajemen Talenta (SIMT).\n\n📌 RANGKUMAN MULTI-SUMBER & STATUS KURASI PUSPRESNAS:\n• Status Akreditasi: Terkurasi Resmi Puspresnas (Grade A).\n• Nomor Registrasi SIMT: SIMT-KURASI-2026-A019.\n• Bobot Prestasi: Piagam dan medali diakui penuh untuk seleksi jalur prestasi (PPDB & SNBP) serta Beasiswa Indonesia Maju.\n• Cabang Lomba: Penalaran Matematika Terapan, Pemecahan Masalah Non-Rutin, dan Nalar Logika Realistik.\n• Tahapan: Babak Penyisihan Kota/Kabupaten -> Babak Semifinal Provinsi -> Babak Final Nasional.', 'https://kpm.or.id/kmnr-2026', 'https://kpm.or.id/pendaftaran-kmnr-2026', 'https://kpm.or.id/juknis-kmnr-2026.pdf', NULL, 'individual', 1, 1, 0, 0.00, '2026-10-01 00:00:00', '2026-11-05 12:15:40', '2026-11-01 00:00:00', '2026-12-21 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:01', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:44', '2026-10-11 05:06:58', '2026-10-11 18:28:01', NULL),
(13, 4, 2, 'terkurasi_puspresnas', 'Grade A (Sangat Baik)', 'SIMT-KURASI-2026-A034', 'Lomba Peneliti Belia (LPB) Tingkat Nasional 2026', 'lpb-peneliti-belia-nasional-2026', 'nasional', 'slta', 'Lomba Peneliti Belia (LPB) Nasional yang diselenggarakan oleh Center for Young Scientists (CYS) Indonesia merupakan kompetisi penelitian ilmiah remaja paling bergengsi yang telah lolos verifikasi Kurasi Puspresnas Kemendikdasmen RI.\n\n📌 RANGKUMAN MULTI-SUMBER & STATUS KURASI PUSPRESNAS:\n• Status Akreditasi: Terkurasi Resmi Puspresnas (Grade A - SIMT-KURASI-2026-A034).\n• Bidang Penelitian: Fisika Terapan, Matematika, Ilmu Komputer, Ilmu Hayati, dan Ilmu Lingkungan.\n• Jalur Prestasi Internasional: Para peraih medali Emas dan Perak berhak mewakili Kontingen Indonesia pada International Conference of Young Scientists (ICYS) dan Asia Pacific Conference of Young Scientists (APCYS).', 'https://cys.or.id/lpb-nasional-2026', 'https://cys.or.id/registrasi-lpb-2026', 'https://cys.or.id/panduan-lpb-2026.pdf', NULL, 'team', 1, 2, 1, 0.00, '2026-10-01 00:00:00', '2026-11-08 12:15:40', '2026-11-01 00:00:00', '2026-12-31 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:01', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:44', '2026-10-11 05:06:58', '2026-10-11 18:28:01', NULL),
(14, 5, 1, 'terkurasi_puspresnas', 'Grade A (Sangat Baik)', 'SIMT-KURASI-2026-A055', 'Olimpiade Geografi Nasional (Olgenas) Tingkat SMA 2026', 'olgenas-geografi-nasional-ugm-2026', 'nasional', 'slta', 'Olimpiade Geografi Nasional (Olgenas) Fakultas Geografi Universitas Gadjah Mada merupakan ajang talenta kebumian dan geografi terbesar se-Indonesia yang diselenggarakan perguruan tinggi negeri dan telah lolos akreditasi Kurasi Prestasi Puspresnas Kemendikdasmen RI.\n\n📌 RANGKUMAN MULTI-SUMBER & STATUS KURASI:\n• Status Akreditasi: Terkurasi SIMT Puspresnas (Grade A - SIMT-KURASI-2026-A055).\n• Tahap Lomba: Ujian Teori Kebumian & Tata Ruang, Analisis Citra Satelit SIG/GIS, dan Studi Kasus Lapangan.', 'https://olgenas.geo.ugm.ac.id/', 'https://olgenas.geo.ugm.ac.id/pendaftaran', 'https://olgenas.geo.ugm.ac.id/panduan-olgenas-2026.pdf', NULL, 'team', 2, 2, 1, 0.00, '2026-10-01 00:00:00', '2026-10-31 12:15:40', '2026-11-01 00:00:00', '2026-12-26 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:01', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:45', '2026-10-11 05:06:58', '2026-10-11 18:28:01', NULL),
(15, 6, 1, 'bergengsi_non_kurasi', NULL, NULL, 'Arkavidia Informatics & Algorithmic Contest ITB 2026', 'arkavidia-informatika-itb-2026', 'nasional', 'slta', 'Arkavidia merupakan festival dan kompetisi teknologi informasi berskala nasional yang diselenggarakan oleh Himpunan Mahasiswa Informatika Institut Teknologi Bandung (HMIF ITB). Ajang ini sangat bergengsi di kalangan pegiat informatika pelajar untuk mengasah kemampuan pemrograman kompetitif, logika algoritma, dan problem solving dunia nyata.\n\n📌 CATATAN TINGKAT KEPERCAYAAN:\n• Belum/tidak masuk kurasi SIMT Puspresnas, namun memiliki reputasi tinggi di lingkungan perguruan tinggi teknik dan industri teknologi.\n• Sangat bernilai sebagai portofolio keahlian coding dan pengalaman kompetisi tingkat tinggi.', 'https://arkavidia.id/', 'https://arkavidia.id/competition', 'https://arkavidia.id/guidebook-2026.pdf', NULL, 'team', 1, 3, 0, 0.00, '2026-10-01 00:00:00', '2026-11-02 12:15:40', '2026-11-01 00:00:00', '2026-12-29 12:15:40', NULL, 'published', 'public', 1, '2026-10-12 01:28:01', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:45', '2026-10-11 05:06:58', '2026-10-11 18:28:01', NULL),
(16, 1, 1, 'bergengsi_non_kurasi', NULL, NULL, 'National Science Competition (NSC) 2026', 'nsc-science-challenge-ui-2026', 'nasional', 'both', 'National Science Competition (NSC) 2026 Jenjang SD/MI, SMP/MTs, SMA/MA/SMK, dan Mahasiswa Tingkat Nasional yang diselenggarakan oleh Puskanas.\n\nBidang Lomba:\n• SMP/Sederajat: Matematika, IPA, IPS, PKN, SBdP, Bahasa Indonesia, Bahasa Inggris, Informatika, Kedokteran Dasar, Fisika Terpadu, Kimia Terpadu, Biologi Terpadu, Astronomi Dasar.\n• SD/Sederajat: Matematika, IPAS, PKN, Bahasa Indonesia, Bahasa Inggris.\n• SMA/SMK: Matematika, Fisika, Kimia, Biologi, Ekonomi, Geografi, Sosiologi, Astronomi, Kebumian, Informatika, Kedokteran.\n\nWaktu Pelaksanaan: Minggu, 29 Maret 2026 secara Online melalui portal https://app.puskanas.id.', 'https://app.puskanas.id', 'https://app.puskanas.id', 'https://app.puskanas.id', NULL, 'team', 1, 3, 1, 0.00, '2026-01-15 00:00:00', '2026-03-28 23:59:59', '2026-03-29 08:00:00', '2026-03-29 17:00:00', '2026-03-31 00:00:00', 'published', 'public', 1, '2026-10-12 01:28:01', '[AI Verified] Data lomba telah diverifikasi ulang dengan portal resmi Pusat Prestasi Nasional (Puspresnas / BPTI).', '2026-10-11 12:15:45', '2026-10-11 05:06:59', '2026-10-11 18:28:01', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `competition_categories`
--

CREATE TABLE `competition_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `competition_categories`
--

INSERT INTO `competition_categories` (`id`, `name`, `slug`, `description`, `icon`, `created_at`, `updated_at`) VALUES
(1, 'Sains & Matematika', 'sains-dan-matematika', 'Kompetisi bidang sains, fisika, kimia, biologi, astronomi, dan matematika.', 'atom', '2026-10-11 05:06:56', '2026-10-11 05:06:56'),
(2, 'Riset & Karya Ilmiah', 'riset-dan-karya-ilmiah', 'Lomba karya tulis ilmiah, inovasi teknologi terapan, dan penelitian pelajar.', 'microscope', '2026-10-11 05:06:56', '2026-10-11 05:06:56'),
(3, 'Teknologi & Robotika', 'teknologi-dan-robotika', 'Kompetisi pemrograman, AI, robotika, web development, dan cyber security.', 'cpu', '2026-10-11 05:06:56', '2026-10-11 05:06:56'),
(4, 'Seni & Budaya', 'seni-dan-budaya', 'Festival lomba seni vokal, tari tradisional, musik, lukis, kriya, dan sinematografi.', 'palette', '2026-10-11 05:06:56', '2026-10-11 05:06:56'),
(5, 'Olahraga & Kebugaran', 'olahraga-dan-kebugaran', 'Olimpiade olahraga siswa nasional seperti atletik, renang, catur, dan pencak silat.', 'trophy', '2026-10-11 05:06:56', '2026-10-11 05:06:56'),
(6, 'Bahasa & Literasi', 'bahasa-dan-literasi', 'Debat bahasa Inggris/Indonesia, pidato, cipta puisi, dan penulisan kreatif.', 'book-open', '2026-10-11 05:06:56', '2026-10-11 05:06:56'),
(7, 'Kewirausahaan & Vokasi', 'kewirausahaan-dan-vokasi', 'Ajang inovasi bisnis, kewirausahaan mandiri, dan keahlian vokasi kejuruan.', 'briefcase', '2026-10-11 05:06:56', '2026-10-11 05:06:56');

-- --------------------------------------------------------

--
-- Struktur dari tabel `competition_eligibilities`
--

CREATE TABLE `competition_eligibilities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED NOT NULL,
  `allowed_educational_levels` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`allowed_educational_levels`)),
  `allowed_grades` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`allowed_grades`)),
  `min_age` tinyint(4) DEFAULT NULL,
  `max_age` tinyint(4) DEFAULT NULL,
  `allowed_provinces` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`allowed_provinces`)),
  `gender_restriction` enum('any','L','P') NOT NULL DEFAULT 'any',
  `custom_rules` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `competition_eligibilities`
--

INSERT INTO `competition_eligibilities` (`id`, `competition_id`, `allowed_educational_levels`, `allowed_grades`, `min_age`, `max_age`, `allowed_provinces`, `gender_restriction`, `custom_rules`, `created_at`, `updated_at`) VALUES
(1, 1, '[\"slta\"]', '[10,11]', 14, 18, NULL, 'any', 'Peserta adalah siswa aktif kelas 10 atau 11 SMA/MA/Sederajat yang terdaftar di Dapodik/EMIS dan memiliki surat rekomendasi resmi Kepala Sekolah.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(2, 2, '[\"slta\"]', '[10,11]', 14, 18, NULL, 'any', 'Peserta adalah siswa aktif SMA/MA/SMK/sederajat. Satu tim terdiri dari 1-2 siswa dengan 1 guru pembimbing.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(3, 3, '[\"slta\"]', '[10,11,12]', 14, 19, NULL, 'any', 'Karya seni dan sastra yang diikutsertakan merupakan karya orisinal dan belum pernah menjuarai lomba tingkat nasional lain.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(4, 4, '[\"slta\"]', '[10,11]', 14, 18, NULL, 'any', 'Atlet pelajar non-pelatnas yang terdaftar aktif di Dapodik/EMIS dan memiliki surat keterangan sehat dokter.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(5, 5, '[\"slta\"]', '[10,11,12]', 15, 19, NULL, 'any', 'Rencana usaha (Business Plan) orisinal dengan prototipe produk dan validasi pasar nyata.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(6, 6, '[\"slta\"]', '[11,12]', 15, 19, NULL, 'any', 'Peserta adalah siswa SMK/SMA aktif yang memenangkan seleksi LKS tingkat wilayah/provinsi.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(7, 7, '[\"slta\"]', '[10,11]', 14, 18, NULL, 'any', 'Satu tim terdiri dari 3 pembicara aktif SMA/MA yang memiliki surat mandat resmi dari sekolah.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(8, 8, '[\"sltp\"]', '[7,8]', 11, 15, NULL, 'any', 'Peserta adalah siswa aktif kelas 7 atau 8 SMP/MTs yang belum pernah meraih medali emas OSN Nasional.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(9, 9, '[\"sltp\"]', '[7,8]', 12, 15, NULL, 'any', 'Pemain sepak bola aktif terdaftar di SMP/MTs dan telah lolos seleksi daerah.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(10, 10, '[\"sltp\"]', '[7,8]', 12, 15, NULL, 'any', 'Memiliki surat keterangan sehat jasmani dan rekomendasi sekolah.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(11, 11, '[\"sltp\"]', '[7,8]', 12, 15, NULL, 'any', 'Siswa SMP berstatus aktif di Dapodik/EMIS dan didaftarkan melalui operator sekolah resmi.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(12, 12, '[\"sltp\",\"slta\"]', '[7,8,9,10,11,12]', 12, 19, NULL, 'any', 'Terbuka untuk seluruh siswa SMP/MTs dan SMA/MA/SMK aktif di seluruh Indonesia.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(13, 13, '[\"slta\"]', '[10,11,12]', 14, 19, NULL, 'any', 'Tim riset terdiri dari 1-2 murid dengan naskah penelitian karya ilmiah orisinal.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(14, 14, '[\"slta\"]', '[10,11,12]', 14, 19, NULL, 'any', 'Delegasi sekolah terdiri dari 2 siswa aktif SMA/MA/sederajat.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(15, 15, '[\"slta\"]', '[10,11,12]', 14, 19, NULL, 'any', 'Peserta adalah pelajar SMA/SMK yang menguasai bahasa C++, Python, atau Java.', '2026-10-11 05:06:59', '2026-10-11 05:06:59'),
(16, 16, '[\"sltp\",\"slta\"]', '[7,8,9,10,11,12]', 12, 19, NULL, 'any', 'Terbuka untuk jenjang SD, SMP, SMA, SMK, dan Mahasiswa seluruh Indonesia.', '2026-10-11 05:06:59', '2026-10-11 05:06:59');

-- --------------------------------------------------------

--
-- Struktur dari tabel `competition_forms`
--

CREATE TABLE `competition_forms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT 'Formulir Pendaftaran',
  `version` int(11) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `competition_forms`
--

INSERT INTO `competition_forms` (`id`, `competition_id`, `title`, `version`, `is_active`, `description`, `created_at`, `updated_at`) VALUES
(1, 1, 'Formulir Delegasi Olimpiade Sains Nasional (OSN) Jenjang SMA/MA 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(2, 2, 'Formulir Delegasi Olimpiade Penelitian Siswa Indonesia (OPSI) Jenjang Pendidikan Menengah 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(3, 3, 'Formulir Delegasi Festival Lomba Seni dan Sastra Siswa Nasional (FLS3N) Jenjang Pendidikan Menengah 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(4, 4, 'Formulir Delegasi Olimpiade Olahraga Siswa Nasional (O2SN) Jenjang Pendidikan Menengah 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(5, 5, 'Formulir Delegasi Festival Inovasi dan Kewirausahaan Siswa Nasional (FIKSI) 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(6, 6, 'Formulir Delegasi Lomba Kompetensi Siswa Nasional (LKS) 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(7, 7, 'Formulir Delegasi Lomba Debat Indonesia (LDI) / LDBI Tingkat Nasional 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(8, 8, 'Formulir Delegasi Olimpiade Sains Nasional (OSN) Jenjang SMP/MTs 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(9, 9, 'Formulir Delegasi Gala Siswa Indonesia (GSI) Jenjang SMP Tingkat Nasional 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(10, 10, 'Formulir Delegasi Olimpiade Olahraga Siswa Nasional (O2SN) Jenjang SMP 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(11, 11, 'Formulir Delegasi Festival dan Lomba Seni Siswa Nasional (FLS2N) Jenjang SMP 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(12, 12, 'Formulir Delegasi Kompetisi Matematika Nalaria Realistik (KMNR) ke-21 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(13, 13, 'Formulir Delegasi Lomba Peneliti Belia (LPB) Tingkat Nasional 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(14, 14, 'Formulir Delegasi Olimpiade Geografi Nasional (Olgenas) Tingkat SMA 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(15, 15, 'Formulir Delegasi Arkavidia Informatics & Algorithmic Contest ITB 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:59', '2026-10-11 05:06:59'),
(16, 16, 'Formulir Delegasi National Science Competition (NSC) 2026', 1, 1, 'Lengkapi data pendaftaran internal sekolah dan nomor surat tugas.', '2026-10-11 05:06:59', '2026-10-11 05:06:59');

-- --------------------------------------------------------

--
-- Struktur dari tabel `competition_permissions`
--

CREATE TABLE `competition_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reference_number` varchar(255) DEFAULT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED DEFAULT NULL,
  `competition_name` varchar(255) NOT NULL,
  `competition_level` enum('kabupaten','provinsi','nasional','internasional') NOT NULL DEFAULT 'kabupaten',
  `news_url` varchar(255) DEFAULT NULL,
  `purpose` text DEFAULT NULL,
  `event_start_date` date DEFAULT NULL,
  `event_end_date` date DEFAULT NULL,
  `parent_name` varchar(255) DEFAULT NULL,
  `parent_approval_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'approved',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `custom_fields_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`custom_fields_data`)),
  `requested_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `competition_sources`
--

CREATE TABLE `competition_sources` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED NOT NULL,
  `source_type` enum('puspresnas','official_website','instagram','news_portal','circular_letter','other') NOT NULL DEFAULT 'official_website',
  `source_url` varchar(255) NOT NULL,
  `source_title` varchar(255) DEFAULT NULL,
  `proof_document_path` varchar(255) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `competition_sources`
--

INSERT INTO `competition_sources` (`id`, `competition_id`, `source_type`, `source_url`, `source_title`, `proof_document_path`, `is_verified`, `verified_by`, `notes`, `created_at`, `updated_at`) VALUES
(75, 1, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-sains-nasional-2026-2026-sma', 'Portal Resmi Ajang Talenta OSN SMA - Puspresnas Kemendikdasmen', NULL, 1, 1, 'Portal induk pengumuman resmi jadwal kompetisi, ketentuan umum peserta, dan linimasa ajang talenta tingkat nasional.', '2026-10-11 05:15:40', '2026-10-11 05:15:40'),
(76, 1, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Registrasi Terpadu Ajang Talenta BPTI', NULL, 1, 1, 'Tautan resmi pendaftaran peserta dan sinkronisasi data peserta didik dengan basis data Dapodik / EMIS.', '2026-10-11 05:15:40', '2026-10-11 05:15:40'),
(77, 1, 'circular_letter', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-osn-sma-2026.pdf', 'Buku Pedoman & Juknis Pelaksanaan OSN SMA 2026', NULL, 1, 1, 'Dokumen panduan teknis yang memuat silabus kompetisi, ketentuan integritas akademik, dan spesifikasi tes CBT.', '2026-10-11 05:15:41', '2026-10-11 05:15:41'),
(78, 1, 'official_website', 'https://kurasi-prestasi.kemendikdasmen.go.id/', 'Portal Kurasi Prestasi & SIMT Kemendikdasmen', NULL, 1, 1, 'Pangkalan data manajemen talenta nasional dan kurasi keabsahan sertifikat prestasi juara.', '2026-10-11 05:15:41', '2026-10-11 05:15:41'),
(79, 1, 'instagram', 'https://instagram.com/puspresnas', 'Akun Resmi Instagram @puspresnas', NULL, 1, 1, 'Media sosial resmi untuk pengumuman linimasa dan infografis tahapan seleksi OSN.', '2026-10-11 05:15:41', '2026-10-11 05:15:41'),
(80, 2, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/olimpiade-penelitian-siswa-indonesia-opsi-jenjang-pendidikan-menengah-2026-2026-sma', 'Portal Resmi Ajang Talenta OPSI Dikmen - Puspresnas', NULL, 1, 1, 'Informasi resmi kriteria naskah ilmiah, format proposal riset, dan panduan etika penelitian.', '2026-10-11 05:15:41', '2026-10-11 05:15:41'),
(81, 2, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Tautan pengunggahan dokumen proposal dan verifikasi nomor registrasi sekolah.', '2026-10-11 05:15:41', '2026-10-11 05:15:41'),
(82, 2, 'circular_letter', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-opsi-dikmen-2026.pdf', 'Buku Pedoman Teknis OPSI Jenjang Pendidikan Menengah 2026', NULL, 1, 1, 'Panduan lengkap struktur penulisan laporan penelitian dan rubrik penilaian dewan juri.', '2026-10-11 05:15:41', '2026-10-11 05:15:41'),
(83, 3, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/seni-budaya/sma/festival-lomba-seni-dan-sastra-siswa-nasional-fls3n-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma', 'Portal Resmi FLS3N Dikmen - Puspresnas Kemendikdasmen', NULL, 1, 1, 'Rilis resmi tema kompetisi seni, panduan format video rekaman, dan ketentuan hak cipta karya.', '2026-10-11 05:15:42', '2026-10-11 05:15:42'),
(84, 3, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Tautan pengunggahan tautan YouTube karya seni dan pendaftaran delegasi sekolah.', '2026-10-11 05:15:42', '2026-10-11 05:15:42'),
(85, 3, 'circular_letter', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fls3n-dikmen-2026.pdf', 'Buku Panduan Teknis FLS3N Jenjang Pendidikan Menengah 2026', NULL, 1, 1, 'Ketentuan teknis penilaian cabang tari, kriya, cipta cerpen, dan sinematografi.', '2026-10-11 05:15:42', '2026-10-11 05:15:42'),
(86, 4, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/olahraga/sma/olimpiade-olahraga-siswa-nasional-o2sn-jenjang-pendidikan-menengah-smamasmkmaksederajat-2026-2026-sma', 'Portal Resmi O2SN Dikmen - Puspresnas Kemendikdasmen', NULL, 1, 1, 'Informasi linimasa seleksi tingkat daerah dan regulasi pembinaan DBON.', '2026-10-11 05:15:42', '2026-10-11 05:15:42'),
(87, 4, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Tautan pendaftaran atlet pelajar dan verifikasi surat tugas kepala sekolah.', '2026-10-11 05:15:42', '2026-10-11 05:15:42'),
(88, 4, 'circular_letter', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-o2sn-dikmen-2026.pdf', 'Buku Pedoman Teknis O2SN Jenjang Pendidikan Menengah 2026', NULL, 1, 1, 'Peraturan pertandingan resmi cabor atletik, renang, silat, karate, dan bulu tangkis.', '2026-10-11 05:15:42', '2026-10-11 05:15:42'),
(89, 5, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/festival-inovasi-dan-kewirausahaan-siswa-nasional-2026-2026-sma', 'Portal Resmi Ajang Talenta FIKSI - Puspresnas', NULL, 1, 1, 'Pedoman inovasi sociopreneur, green economy, dan inkubasi wirausaha muda.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(90, 5, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Registrasi Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Pendaftaran ide bisnis, pitching deck, dan verifikasi sekolah pengusung.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(91, 5, 'circular_letter', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-fiksi-2026.pdf', 'Buku Pedoman Pelaksanaan FIKSI 2026', NULL, 1, 1, 'Struktur penulisan proposal rencana bisnis dan rubrik penilaian inkubasi.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(92, 6, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/event/riset-dan-inovasi/sma/lomba-kompetensi-siswa-nasional-2026-2026-sma', 'Portal Resmi LKS SMK Tingkat Nasional - Puspresnas', NULL, 1, 1, 'Rilis resmi bidang lomba keahlian vokasi dan standar uji kompetensi industri.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(93, 6, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Pendaftaran kontingen delegasi provinsi bidang lomba kejuruan.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(94, 6, 'circular_letter', 'https://pusatprestasinasional.kemendikdasmen.go.id/pedoman/pedoman-lks-2026.pdf', 'Buku Pedoman Teknis & Kisi-Kisi Uji LKS 2026', NULL, 1, 1, 'Spesifikasi teknis alat uji, software yang digunakan, dan jadwal uji per bidang.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(95, 7, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/', 'Laman Resmi Lomba Debat Indonesia - Puspresnas', NULL, 1, 1, 'Pengumuman linimasa seleksi babak penyisihan daerah dan aturan tata tertib debat.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(96, 7, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Tautan registrasi tim delegasi debat dan verifikasi anggota tim.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(97, 8, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'Portal Resmi Ajang Talenta Jenjang SMP - Puspresnas', NULL, 1, 1, 'Informasi resmi kuota per sekolah dan panduan teknis OSN tingkat pendidikan dasar.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(98, 8, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Pendaftaran peserta didik SMP dengan integrasi nomor NISN Dapodik.', '2026-10-11 05:15:43', '2026-10-11 05:15:43'),
(99, 9, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'Portal Resmi Gala Siswa Indonesia - Puspresnas', NULL, 1, 1, 'Regulasi pertandingan sepak bola pelajar berstandar PSSI.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(100, 9, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Pendaftaran roster pemain dan tim pelatih delegasi sekolah/daerah.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(101, 10, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'Portal Resmi O2SN Jenjang SMP - Puspresnas Kemendikdasmen', NULL, 1, 1, 'Panduan seleksi daerah dan pembinaan olahraga jenjang SMP.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(102, 10, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Pendaftaran atlet pelajar SMP dan verifikasi dokumen kesehatan.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(103, 11, 'puspresnas', 'https://pusatprestasinasional.kemendikdasmen.go.id/jenjang/smp', 'Portal Resmi FLS2N Jenjang SMP - Puspresnas Kemendikdasmen', NULL, 1, 1, 'Rilis petunjuk teknis lomba seni budaya nusantara jenjang SMP.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(104, 11, 'official_website', 'https://daftar-bpti.kemendikdasmen.go.id/', 'Portal Pendaftaran Terpadu BPTI Kemendikdasmen', NULL, 1, 1, 'Pengunggahan karya seni video dan pendaftaran peserta didik.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(105, 12, 'official_website', 'https://kpm.or.id/kmnr-2026', 'Portal Resmi KMNR KPM Indonesia', NULL, 1, 1, 'Informasi linimasa babak penyisihan daerah dan tata tertib ujian daring/luring.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(106, 12, 'puspresnas', 'https://kurasi-prestasi.kemendikdasmen.go.id/', 'Pangkalan Data Kurasi Talenta Puspresnas SIMT', NULL, 1, 1, 'Sertifikat penetapan Kurasi Prestasi Puspresnas Grade A terdaftar di SIMT Kemendikdasmen.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(107, 13, 'official_website', 'https://cys.or.id/lpb-nasional-2026', 'Portal Resmi Center for Young Scientists Indonesia', NULL, 1, 1, 'Ketentuan proposal riset, format abstrak karya tulis ilmiah, dan rubrik penilaian dewan juri CYS.', '2026-10-11 05:15:44', '2026-10-11 05:15:44'),
(108, 13, 'puspresnas', 'https://kurasi-prestasi.kemendikdasmen.go.id/', 'Verifikasi Kurasi Talenta Puspresnas SIMT', NULL, 1, 1, 'Terkurasi resmi SIMT Kemendikdasmen Grade A untuk afirmasi prestasi riset ilmiah.', '2026-10-11 05:15:45', '2026-10-11 05:15:45'),
(109, 14, 'official_website', 'https://olgenas.geo.ugm.ac.id/', 'Portal Olgenas Fakultas Geografi UGM', NULL, 1, 1, 'Panduan kisi-kisi materi geografi lingkungan, SIG, dan petunjuk teknis studi kasus.', '2026-10-11 05:15:45', '2026-10-11 05:15:45'),
(110, 15, 'official_website', 'https://arkavidia.id/', 'Portal Resmi Arkavidia HMIF ITB', NULL, 1, 1, 'Petunjuk teknis competitive programming contest dan jadwal babak penyisihan online.', '2026-10-11 05:15:45', '2026-10-11 05:15:45'),
(111, 16, 'instagram', 'https://app.puskanas.id', 'Pengumuman Resmi Instagram @info.lomba & Puskanas', NULL, 1, 1, 'Pendaftaran: 15 Januari - 28 Maret 2026. Pelaksanaan: Minggu, 29 Maret 2026.', '2026-10-11 05:15:45', '2026-10-11 05:15:45');

-- --------------------------------------------------------

--
-- Struktur dari tabel `competition_supervisors`
--

CREATE TABLE `competition_supervisors` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED DEFAULT NULL,
  `competition_name` varchar(255) DEFAULT NULL,
  `organizer_name` varchar(255) DEFAULT NULL,
  `competition_branch` varchar(255) DEFAULT NULL,
  `student_names` text DEFAULT NULL,
  `student_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`student_ids`)),
  `competition_category` varchar(255) DEFAULT 'SMA / MA',
  `competition_place` varchar(255) DEFAULT NULL,
  `competition_level` varchar(255) DEFAULT 'kabupaten',
  `event_date` varchar(255) DEFAULT NULL,
  `supervisor_name` varchar(255) NOT NULL,
  `supervisor_nip` varchar(255) DEFAULT NULL,
  `supervisor_phone` varchar(255) DEFAULT NULL,
  `role_title` varchar(255) NOT NULL DEFAULT 'Pendamping Utama',
  `supervisor_category` varchar(255) DEFAULT 'Guru',
  `supervisor_gender` varchar(255) DEFAULT NULL,
  `bisyaroh_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `duty_zone` varchar(255) DEFAULT 'dalam_kota',
  `reference_number` varchar(255) DEFAULT NULL,
  `statement_agreed` tinyint(1) NOT NULL DEFAULT 1,
  `public_token` varchar(64) DEFAULT NULL,
  `sop_category` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('pending','approved','disbursed') NOT NULL DEFAULT 'pending',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `form_fields`
--

CREATE TABLE `form_fields` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `form_id` bigint(20) UNSIGNED NOT NULL,
  `label` varchar(255) NOT NULL,
  `field_key` varchar(100) NOT NULL,
  `field_type` enum('text','textarea','number','date','select','radio','checkbox','file','email','phone') NOT NULL DEFAULT 'text',
  `placeholder` varchar(255) DEFAULT NULL,
  `help_text` varchar(255) DEFAULT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT 0,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `validation_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`validation_rules`)),
  `conditional_rule` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`conditional_rule`)),
  `order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `form_fields`
--

INSERT INTO `form_fields` (`id`, `form_id`, `label`, `field_key`, `field_type`, `placeholder`, `help_text`, `is_required`, `options`, `validation_rules`, `conditional_rule`, `order`, `created_at`, `updated_at`) VALUES
(1, 1, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(2, 2, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(3, 3, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(4, 4, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(5, 5, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:57', '2026-10-11 05:06:57'),
(6, 6, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(7, 7, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(8, 8, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(9, 9, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(10, 10, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(11, 11, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(12, 12, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(13, 13, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(14, 14, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:58', '2026-10-11 05:06:58'),
(15, 15, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:59', '2026-10-11 05:06:59'),
(16, 16, 'Nomor Surat Tugas / Rekomendasi Sekolah', 'no_surat_tugas', 'text', 'Contoh: 421.3/089/SMAN1/2026', NULL, 1, NULL, NULL, NULL, 1, '2026-10-11 05:06:59', '2026-10-11 05:06:59');

-- --------------------------------------------------------

--
-- Struktur dari tabel `hero_sliders`
--

CREATE TABLE `hero_sliders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `student_name` varchar(255) DEFAULT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `image_path` varchar(255) NOT NULL,
  `order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `hero_sliders`
--

INSERT INTO `hero_sliders` (`id`, `title`, `student_name`, `caption`, `image_path`, `order`, `is_active`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Kompetisi TKA Wajib MA se kabupaten Jombang tahun 2026.', 'Tim TKA MAUWH', 'Juara Umum', 'hero_sliders/qOn1bfX4P6BKGGgkbxCdQ0jZ1aXeKgILzWfrtk7z.jpg', 1, 1, '2026-10-11 17:52:04', '2026-10-11 17:52:04', NULL),
(2, 'Kompetisi pelajar berprestasi tingkat nasional 9.0 (KOMPASS).', 'Balques Salma', 'Medali Perunggu', 'hero_sliders/60sxfGSgsMqQJxjra9ap5TMkZPYVPv2AXvkN15YO.jpg', 2, 1, '2026-10-11 18:33:56', '2026-10-11 18:34:44', NULL),
(3, 'Kompetisi pelajar berprestasi tingkat nasional 9.0 (KOMPASS).', 'Nazla Azzahrotul A.', 'Medali Perunggu', 'hero_sliders/oTTj06V9LtjTopW2p5sa3adjkqvDEExsp6VwDOOh.jpg', 3, 1, '2026-10-11 18:35:56', '2026-10-11 18:35:56', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `imports`
--

CREATE TABLE `imports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `total_rows` int(11) NOT NULL DEFAULT 0,
  `successful_rows` int(11) NOT NULL DEFAULT 0,
  `failed_rows` int(11) NOT NULL DEFAULT 0,
  `errors` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`errors`)),
  `status` enum('completed','failed') NOT NULL DEFAULT 'completed',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kbm_dispensations`
--

CREATE TABLE `kbm_dispensations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED DEFAULT NULL,
  `competition_name` varchar(255) NOT NULL,
  `competition_field` varchar(255) DEFAULT NULL,
  `competition_level` varchar(255) DEFAULT NULL,
  `organizer` varchar(255) DEFAULT NULL,
  `execution_type` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `dispensation_type` enum('persiapan_latihan','pelaksanaan_lomba','lainnya') NOT NULL DEFAULT 'persiapan_latihan',
  `purpose` text NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `is_all_day` tinyint(1) NOT NULL DEFAULT 1,
  `supervisor_name` varchar(255) DEFAULT NULL,
  `homeroom_teacher` varchar(255) DEFAULT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `custom_fields_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`custom_fields_data`)),
  `attachment_path` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending',
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `verification_token` varchar(64) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `kbm_dispensations`
--

INSERT INTO `kbm_dispensations` (`id`, `reference_number`, `school_id`, `competition_id`, `competition_name`, `competition_field`, `competition_level`, `organizer`, `execution_type`, `location`, `dispensation_type`, `purpose`, `start_date`, `end_date`, `start_time`, `end_time`, `is_all_day`, `supervisor_name`, `homeroom_teacher`, `phone_number`, `custom_fields_data`, `attachment_path`, `status`, `requested_by`, `approved_by`, `approved_at`, `rejection_reason`, `verification_token`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, '421.3/DISP-KBM/1/2026/001', 1, NULL, 'Juara coding', 'Informatika', 'kabupaten', 'UNWAHA', 'online', 'GSG', 'lainnya', 'Mengikuti Lomba BABAK awal', '2026-10-28', '2026-10-29', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 'approved', 3, 641, '2026-10-26 01:23:51', NULL, 'Q7FzJr5oHjzOmXGCpm9lVtcPSDlYITfG4SISIHvF', '2026-10-25 18:23:26', '2026-10-25 18:23:51', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `kbm_dispensation_students`
--

CREATE TABLE `kbm_dispensation_students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `dispensation_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `kbm_dispensation_students`
--

INSERT INTO `kbm_dispensation_students` (`id`, `dispensation_id`, `student_id`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, '2026-10-25 18:23:26', '2026-10-25 18:23:26'),
(2, 1, 2, NULL, '2026-10-25 18:23:26', '2026-10-25 18:23:26');

-- --------------------------------------------------------

--
-- Struktur dari tabel `login_events`
--

CREATE TABLE `login_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `identifier` varchar(100) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `status` enum('success','failed') NOT NULL,
  `failure_reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `login_events`
--

INSERT INTO `login_events` (`id`, `user_id`, `identifier`, `ip_address`, `user_agent`, `status`, `failure_reason`, `created_at`) VALUES
(1, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-11 12:25:45'),
(2, NULL, 'jarakcomunitty@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-11 12:26:13'),
(3, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-11 12:26:31'),
(4, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-11 13:31:56'),
(5, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-11 13:32:53'),
(6, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-11 13:36:14'),
(7, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-11 13:37:03'),
(8, 1, 'superadmin@prestasiku.id', '160.22.31.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 00:23:42'),
(9, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 00:42:01'),
(10, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 00:43:27'),
(11, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'curl/8.13.0', 'success', NULL, '2026-10-12 00:44:15'),
(12, NULL, 'nonexistent@prestasiku.id', '114.5.221.219', 'curl/8.13.0', 'failed', 'Invalid credentials', '2026-10-12 00:45:21'),
(13, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'curl/8.13.0', 'failed', 'Invalid credentials', '2026-10-12 00:46:21'),
(14, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 00:49:49'),
(15, 641, 'mauwh.official@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 01:11:37'),
(16, 3, '109876976', '114.5.221.219', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-12 01:12:55'),
(17, 1, 'superadmin@prestasiku.id', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 01:25:53'),
(18, 641, 'mauwh.official@gmail.com', '114.5.247.64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 02:01:40'),
(19, 641, 'mauwh.official@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-12 02:08:57'),
(20, 641, 'mauwh.official@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-12 02:28:47'),
(21, 641, 'mauwh.official@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 02:55:32'),
(22, 641, 'mauwh.official@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 02:55:59'),
(23, 3, '109876976', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 03:06:38'),
(24, 641, 'mauwh.official@gmail.com', '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'success', NULL, '2026-10-12 03:19:17'),
(25, 641, 'mauwh.official@gmail.com', '110.139.47.109', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-18 17:15:39'),
(26, 641, 'mauwh.official@gmail.com', '110.139.47.109', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-18 17:16:11'),
(27, 641, 'mauwh.official@gmail.com', '103.142.255.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-19 01:52:36'),
(28, NULL, 'jarakcomunitty@gmail.com', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:14:39'),
(29, NULL, 'jarakcomunitty@gmail.com', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:01'),
(30, NULL, 'jarakcomunitty@gmail.com', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:06'),
(31, NULL, 'jarakcomunitty@gmail.com', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:16'),
(32, NULL, 'jarakcomunitty@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:37'),
(33, NULL, 'jarakcomunitty@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:44'),
(34, NULL, 'jarakcomunitty@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:47'),
(35, NULL, 'jarakcomunitty@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:15:50'),
(36, 641, 'mauwh.official@gmail.com', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-26 01:15:50'),
(37, NULL, 'supreadmin@prestasiku.id', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:16:07'),
(38, NULL, 'supreadmin@prestasiku.id', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:16:10'),
(39, NULL, 'jarakcomunitty@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:16:20'),
(40, 1, 'sistemprestasiku@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:18:43'),
(41, 1, 'sistemprestasiku@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:18:49'),
(42, NULL, '123456', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:20:13'),
(43, NULL, '123456', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:20:22'),
(44, 1, 'sistemprestasiku@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:21:02'),
(45, 641, 'mauwh.official@gmail.com', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-26 01:21:11'),
(46, NULL, 'superadmin@prestasiku.id', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:21:12'),
(47, 3, '109876976', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:21:38'),
(48, 3, '109876976', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-26 01:21:51'),
(49, 1, 'sistemprestasiku@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:22:20'),
(50, 1, 'sistemprestasiku@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'failed', 'Invalid credentials', '2026-10-26 01:22:25'),
(51, 641, 'mauwh.official@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-26 01:22:58'),
(52, 3, '109876976', '182.6.88.131', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'success', NULL, '2026-10-26 01:24:17'),
(53, 641, 'mauwh.official@gmail.com', '114.8.229.110', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-26 01:27:24'),
(54, 641, 'mauwh.official@gmail.com', '36.73.253.51', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', 'success', NULL, '2026-10-28 12:04:27'),
(55, 641, 'mauwh.official@gmail.com', '36.78.122.131', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', 'success', NULL, '2026-10-29 05:01:47'),
(56, NULL, 'mauwh. official@gmail.com', '114.8.224.113', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'failed', 'Invalid credentials', '2026-10-29 05:39:13'),
(57, 641, 'mauwh.official@gmail.com', '114.8.224.113', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-29 05:39:21'),
(58, 403, '98693294', '114.8.224.113', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'failed', 'Invalid credentials', '2026-10-29 05:39:54'),
(59, 641, 'mauwh.official@gmail.com', '114.8.224.113', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-29 05:40:15'),
(60, 3, '109876976', '114.8.224.113', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', 'success', NULL, '2026-10-29 05:40:38');

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_09_19_144240_create_personal_access_tokens_table', 1),
(5, '2026_09_19_151122_create_permission_tables', 1),
(6, '2026_09_19_151200_create_schools_table', 1),
(7, '2026_09_19_151300_add_fields_to_users_table', 1),
(8, '2026_09_19_151400_create_school_registrations_table', 1),
(9, '2026_09_19_151500_create_students_table', 1),
(10, '2026_09_19_151600_create_login_events_table', 1),
(11, '2026_09_19_152000_create_imports_table', 1),
(12, '2026_09_19_153000_create_organizers_table', 1),
(13, '2026_09_19_153100_create_competition_categories_table', 1),
(14, '2026_09_19_153200_create_competitions_table', 1),
(15, '2026_09_19_153300_create_competition_sources_table', 1),
(16, '2026_09_19_153400_create_competition_eligibilities_table', 1),
(17, '2026_09_19_153500_create_competition_forms_table', 1),
(18, '2026_09_19_153600_create_form_fields_table', 1),
(19, '2026_09_19_154000_create_teams_table', 1),
(20, '2026_09_19_154100_create_team_members_table', 1),
(21, '2026_09_19_154200_create_registrations_table', 1),
(22, '2026_09_19_154300_create_registration_answers_table', 1),
(23, '2026_09_19_155000_create_achievements_table', 1),
(24, '2026_09_19_155100_create_achievement_documents_table', 1),
(25, '2026_09_20_190000_create_kbm_dispensations_table', 1),
(26, '2026_09_20_190100_add_result_fields_to_registrations_table', 1),
(27, '2026_09_21_160500_add_registration_url_to_competitions_table', 1),
(28, '2026_09_21_165500_add_curation_fields_to_competitions_table', 1),
(29, '2026_09_21_223000_add_custom_fields_to_schools_and_dispensations_table', 1),
(30, '2026_09_22_000000_add_letterhead_and_template_to_schools_table', 1),
(31, '2026_09_28_230000_create_competition_supervisors_table', 1),
(32, '2026_09_28_233000_add_permission_template_fields_to_schools_table', 1),
(33, '2026_09_28_235000_create_competition_permissions_table', 1),
(34, '2026_10_07_000000_add_unified_fields_to_kbm_dispensations_table', 1),
(35, '2026_10_10_110000_create_hero_sliders_table', 1),
(36, '2026_10_11_000000_create_school_signers_table', 1),
(37, '2026_10_11_010000_add_detail_fields_to_school_signers_table', 1),
(38, '2026_10_11_120000_add_fields_to_competition_supervisors_table', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `model_has_permissions`
--

CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `model_has_roles`
--

CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `model_has_roles`
--

INSERT INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES
(1, 'App\\Models\\User', 1),
(3, 'App\\Models\\User', 3),
(3, 'App\\Models\\User', 4),
(3, 'App\\Models\\User', 5),
(3, 'App\\Models\\User', 6),
(3, 'App\\Models\\User', 7),
(3, 'App\\Models\\User', 8),
(3, 'App\\Models\\User', 9),
(3, 'App\\Models\\User', 10),
(3, 'App\\Models\\User', 11),
(3, 'App\\Models\\User', 12),
(3, 'App\\Models\\User', 13),
(3, 'App\\Models\\User', 14),
(3, 'App\\Models\\User', 15),
(3, 'App\\Models\\User', 16),
(3, 'App\\Models\\User', 17),
(3, 'App\\Models\\User', 18),
(3, 'App\\Models\\User', 19),
(3, 'App\\Models\\User', 20),
(3, 'App\\Models\\User', 21),
(3, 'App\\Models\\User', 22),
(3, 'App\\Models\\User', 23),
(3, 'App\\Models\\User', 24),
(3, 'App\\Models\\User', 25),
(3, 'App\\Models\\User', 26),
(3, 'App\\Models\\User', 27),
(3, 'App\\Models\\User', 28),
(3, 'App\\Models\\User', 29),
(3, 'App\\Models\\User', 30),
(3, 'App\\Models\\User', 31),
(3, 'App\\Models\\User', 32),
(3, 'App\\Models\\User', 33),
(3, 'App\\Models\\User', 34),
(3, 'App\\Models\\User', 35),
(3, 'App\\Models\\User', 36),
(3, 'App\\Models\\User', 37),
(3, 'App\\Models\\User', 38),
(3, 'App\\Models\\User', 39),
(3, 'App\\Models\\User', 40),
(3, 'App\\Models\\User', 41),
(3, 'App\\Models\\User', 42),
(3, 'App\\Models\\User', 43),
(3, 'App\\Models\\User', 44),
(3, 'App\\Models\\User', 45),
(3, 'App\\Models\\User', 46),
(3, 'App\\Models\\User', 47),
(3, 'App\\Models\\User', 48),
(3, 'App\\Models\\User', 49),
(3, 'App\\Models\\User', 50),
(3, 'App\\Models\\User', 51),
(3, 'App\\Models\\User', 52),
(3, 'App\\Models\\User', 53),
(3, 'App\\Models\\User', 54),
(3, 'App\\Models\\User', 55),
(3, 'App\\Models\\User', 56),
(3, 'App\\Models\\User', 57),
(3, 'App\\Models\\User', 58),
(3, 'App\\Models\\User', 59),
(3, 'App\\Models\\User', 60),
(3, 'App\\Models\\User', 61),
(3, 'App\\Models\\User', 62),
(3, 'App\\Models\\User', 63),
(3, 'App\\Models\\User', 64),
(3, 'App\\Models\\User', 65),
(3, 'App\\Models\\User', 66),
(3, 'App\\Models\\User', 67),
(3, 'App\\Models\\User', 68),
(3, 'App\\Models\\User', 69),
(3, 'App\\Models\\User', 70),
(3, 'App\\Models\\User', 71),
(3, 'App\\Models\\User', 72),
(3, 'App\\Models\\User', 73),
(3, 'App\\Models\\User', 74),
(3, 'App\\Models\\User', 75),
(3, 'App\\Models\\User', 76),
(3, 'App\\Models\\User', 77),
(3, 'App\\Models\\User', 78),
(3, 'App\\Models\\User', 79),
(3, 'App\\Models\\User', 80),
(3, 'App\\Models\\User', 81),
(3, 'App\\Models\\User', 82),
(3, 'App\\Models\\User', 83),
(3, 'App\\Models\\User', 84),
(3, 'App\\Models\\User', 85),
(3, 'App\\Models\\User', 86),
(3, 'App\\Models\\User', 87),
(3, 'App\\Models\\User', 88),
(3, 'App\\Models\\User', 89),
(3, 'App\\Models\\User', 90),
(3, 'App\\Models\\User', 91),
(3, 'App\\Models\\User', 92),
(3, 'App\\Models\\User', 93),
(3, 'App\\Models\\User', 94),
(3, 'App\\Models\\User', 95),
(3, 'App\\Models\\User', 96),
(3, 'App\\Models\\User', 97),
(3, 'App\\Models\\User', 98),
(3, 'App\\Models\\User', 99),
(3, 'App\\Models\\User', 100),
(3, 'App\\Models\\User', 101),
(3, 'App\\Models\\User', 102),
(3, 'App\\Models\\User', 103),
(3, 'App\\Models\\User', 104),
(3, 'App\\Models\\User', 105),
(3, 'App\\Models\\User', 106),
(3, 'App\\Models\\User', 107),
(3, 'App\\Models\\User', 108),
(3, 'App\\Models\\User', 109),
(3, 'App\\Models\\User', 110),
(3, 'App\\Models\\User', 111),
(3, 'App\\Models\\User', 112),
(3, 'App\\Models\\User', 113),
(3, 'App\\Models\\User', 114),
(3, 'App\\Models\\User', 115),
(3, 'App\\Models\\User', 116),
(3, 'App\\Models\\User', 117),
(3, 'App\\Models\\User', 118),
(3, 'App\\Models\\User', 119),
(3, 'App\\Models\\User', 120),
(3, 'App\\Models\\User', 121),
(3, 'App\\Models\\User', 122),
(3, 'App\\Models\\User', 123),
(3, 'App\\Models\\User', 124),
(3, 'App\\Models\\User', 125),
(3, 'App\\Models\\User', 126),
(3, 'App\\Models\\User', 127),
(3, 'App\\Models\\User', 128),
(3, 'App\\Models\\User', 129),
(3, 'App\\Models\\User', 130),
(3, 'App\\Models\\User', 131),
(3, 'App\\Models\\User', 132),
(3, 'App\\Models\\User', 133),
(3, 'App\\Models\\User', 134),
(3, 'App\\Models\\User', 135),
(3, 'App\\Models\\User', 136),
(3, 'App\\Models\\User', 137),
(3, 'App\\Models\\User', 138),
(3, 'App\\Models\\User', 139),
(3, 'App\\Models\\User', 140),
(3, 'App\\Models\\User', 141),
(3, 'App\\Models\\User', 142),
(3, 'App\\Models\\User', 143),
(3, 'App\\Models\\User', 144),
(3, 'App\\Models\\User', 145),
(3, 'App\\Models\\User', 146),
(3, 'App\\Models\\User', 147),
(3, 'App\\Models\\User', 148),
(3, 'App\\Models\\User', 149),
(3, 'App\\Models\\User', 150),
(3, 'App\\Models\\User', 151),
(3, 'App\\Models\\User', 152),
(3, 'App\\Models\\User', 153),
(3, 'App\\Models\\User', 154),
(3, 'App\\Models\\User', 155),
(3, 'App\\Models\\User', 156),
(3, 'App\\Models\\User', 157),
(3, 'App\\Models\\User', 158),
(3, 'App\\Models\\User', 159),
(3, 'App\\Models\\User', 160),
(3, 'App\\Models\\User', 161),
(3, 'App\\Models\\User', 162),
(3, 'App\\Models\\User', 163),
(3, 'App\\Models\\User', 164),
(3, 'App\\Models\\User', 165),
(3, 'App\\Models\\User', 166),
(3, 'App\\Models\\User', 167),
(3, 'App\\Models\\User', 168),
(3, 'App\\Models\\User', 169),
(3, 'App\\Models\\User', 170),
(3, 'App\\Models\\User', 171),
(3, 'App\\Models\\User', 172),
(3, 'App\\Models\\User', 173),
(3, 'App\\Models\\User', 174),
(3, 'App\\Models\\User', 175),
(3, 'App\\Models\\User', 176),
(3, 'App\\Models\\User', 177),
(3, 'App\\Models\\User', 178),
(3, 'App\\Models\\User', 179),
(3, 'App\\Models\\User', 180),
(3, 'App\\Models\\User', 181),
(3, 'App\\Models\\User', 182),
(3, 'App\\Models\\User', 183),
(3, 'App\\Models\\User', 184),
(3, 'App\\Models\\User', 185),
(3, 'App\\Models\\User', 186),
(3, 'App\\Models\\User', 187),
(3, 'App\\Models\\User', 188),
(3, 'App\\Models\\User', 189),
(3, 'App\\Models\\User', 190),
(3, 'App\\Models\\User', 191),
(3, 'App\\Models\\User', 192),
(3, 'App\\Models\\User', 193),
(3, 'App\\Models\\User', 194),
(3, 'App\\Models\\User', 195),
(3, 'App\\Models\\User', 196),
(3, 'App\\Models\\User', 197),
(3, 'App\\Models\\User', 198),
(3, 'App\\Models\\User', 199),
(3, 'App\\Models\\User', 200),
(3, 'App\\Models\\User', 201),
(3, 'App\\Models\\User', 202),
(3, 'App\\Models\\User', 203),
(3, 'App\\Models\\User', 204),
(3, 'App\\Models\\User', 205),
(3, 'App\\Models\\User', 206),
(3, 'App\\Models\\User', 207),
(3, 'App\\Models\\User', 208),
(3, 'App\\Models\\User', 209),
(3, 'App\\Models\\User', 210),
(3, 'App\\Models\\User', 211),
(3, 'App\\Models\\User', 212),
(3, 'App\\Models\\User', 213),
(3, 'App\\Models\\User', 214),
(3, 'App\\Models\\User', 215),
(3, 'App\\Models\\User', 216),
(3, 'App\\Models\\User', 217),
(3, 'App\\Models\\User', 218),
(3, 'App\\Models\\User', 219),
(3, 'App\\Models\\User', 220),
(3, 'App\\Models\\User', 221),
(3, 'App\\Models\\User', 222),
(3, 'App\\Models\\User', 223),
(3, 'App\\Models\\User', 224),
(3, 'App\\Models\\User', 225),
(3, 'App\\Models\\User', 226),
(3, 'App\\Models\\User', 227),
(3, 'App\\Models\\User', 228),
(3, 'App\\Models\\User', 229),
(3, 'App\\Models\\User', 230),
(3, 'App\\Models\\User', 231),
(3, 'App\\Models\\User', 232),
(3, 'App\\Models\\User', 233),
(3, 'App\\Models\\User', 234),
(3, 'App\\Models\\User', 235),
(3, 'App\\Models\\User', 236),
(3, 'App\\Models\\User', 237),
(3, 'App\\Models\\User', 238),
(3, 'App\\Models\\User', 239),
(3, 'App\\Models\\User', 240),
(3, 'App\\Models\\User', 241),
(3, 'App\\Models\\User', 242),
(3, 'App\\Models\\User', 243),
(3, 'App\\Models\\User', 244),
(3, 'App\\Models\\User', 245),
(3, 'App\\Models\\User', 246),
(3, 'App\\Models\\User', 247),
(3, 'App\\Models\\User', 248),
(3, 'App\\Models\\User', 249),
(3, 'App\\Models\\User', 250),
(3, 'App\\Models\\User', 251),
(3, 'App\\Models\\User', 252),
(3, 'App\\Models\\User', 253),
(3, 'App\\Models\\User', 254),
(3, 'App\\Models\\User', 255),
(3, 'App\\Models\\User', 256),
(3, 'App\\Models\\User', 257),
(3, 'App\\Models\\User', 258),
(3, 'App\\Models\\User', 259),
(3, 'App\\Models\\User', 260),
(3, 'App\\Models\\User', 261),
(3, 'App\\Models\\User', 262),
(3, 'App\\Models\\User', 263),
(3, 'App\\Models\\User', 264),
(3, 'App\\Models\\User', 265),
(3, 'App\\Models\\User', 266),
(3, 'App\\Models\\User', 267),
(3, 'App\\Models\\User', 268),
(3, 'App\\Models\\User', 269),
(3, 'App\\Models\\User', 270),
(3, 'App\\Models\\User', 271),
(3, 'App\\Models\\User', 272),
(3, 'App\\Models\\User', 273),
(3, 'App\\Models\\User', 274),
(3, 'App\\Models\\User', 275),
(3, 'App\\Models\\User', 276),
(3, 'App\\Models\\User', 277),
(3, 'App\\Models\\User', 278),
(3, 'App\\Models\\User', 279),
(3, 'App\\Models\\User', 280),
(3, 'App\\Models\\User', 281),
(3, 'App\\Models\\User', 282),
(3, 'App\\Models\\User', 283),
(3, 'App\\Models\\User', 284),
(3, 'App\\Models\\User', 285),
(3, 'App\\Models\\User', 286),
(3, 'App\\Models\\User', 287),
(3, 'App\\Models\\User', 288),
(3, 'App\\Models\\User', 289),
(3, 'App\\Models\\User', 290),
(3, 'App\\Models\\User', 291),
(3, 'App\\Models\\User', 292),
(3, 'App\\Models\\User', 293),
(3, 'App\\Models\\User', 294),
(3, 'App\\Models\\User', 295),
(3, 'App\\Models\\User', 296),
(3, 'App\\Models\\User', 297),
(3, 'App\\Models\\User', 298),
(3, 'App\\Models\\User', 299),
(3, 'App\\Models\\User', 300),
(3, 'App\\Models\\User', 301),
(3, 'App\\Models\\User', 302),
(3, 'App\\Models\\User', 303),
(3, 'App\\Models\\User', 304),
(3, 'App\\Models\\User', 305),
(3, 'App\\Models\\User', 306),
(3, 'App\\Models\\User', 307),
(3, 'App\\Models\\User', 308),
(3, 'App\\Models\\User', 309),
(3, 'App\\Models\\User', 310),
(3, 'App\\Models\\User', 311),
(3, 'App\\Models\\User', 312),
(3, 'App\\Models\\User', 313),
(3, 'App\\Models\\User', 314),
(3, 'App\\Models\\User', 315),
(3, 'App\\Models\\User', 316),
(3, 'App\\Models\\User', 317),
(3, 'App\\Models\\User', 318),
(3, 'App\\Models\\User', 319),
(3, 'App\\Models\\User', 320),
(3, 'App\\Models\\User', 321),
(3, 'App\\Models\\User', 322),
(3, 'App\\Models\\User', 323),
(3, 'App\\Models\\User', 324),
(3, 'App\\Models\\User', 325),
(3, 'App\\Models\\User', 326),
(3, 'App\\Models\\User', 327),
(3, 'App\\Models\\User', 328),
(3, 'App\\Models\\User', 329),
(3, 'App\\Models\\User', 330),
(3, 'App\\Models\\User', 331),
(3, 'App\\Models\\User', 332),
(3, 'App\\Models\\User', 333),
(3, 'App\\Models\\User', 334),
(3, 'App\\Models\\User', 335),
(3, 'App\\Models\\User', 336),
(3, 'App\\Models\\User', 337),
(3, 'App\\Models\\User', 338),
(3, 'App\\Models\\User', 339),
(3, 'App\\Models\\User', 340),
(3, 'App\\Models\\User', 341),
(3, 'App\\Models\\User', 342),
(3, 'App\\Models\\User', 343),
(3, 'App\\Models\\User', 344),
(3, 'App\\Models\\User', 345),
(3, 'App\\Models\\User', 346),
(3, 'App\\Models\\User', 347),
(3, 'App\\Models\\User', 348),
(3, 'App\\Models\\User', 349),
(3, 'App\\Models\\User', 350),
(3, 'App\\Models\\User', 351),
(3, 'App\\Models\\User', 352),
(3, 'App\\Models\\User', 353),
(3, 'App\\Models\\User', 354),
(3, 'App\\Models\\User', 355),
(3, 'App\\Models\\User', 356),
(3, 'App\\Models\\User', 357),
(3, 'App\\Models\\User', 358),
(3, 'App\\Models\\User', 359),
(3, 'App\\Models\\User', 360),
(3, 'App\\Models\\User', 361),
(3, 'App\\Models\\User', 362),
(3, 'App\\Models\\User', 363),
(3, 'App\\Models\\User', 364),
(3, 'App\\Models\\User', 365),
(3, 'App\\Models\\User', 366),
(3, 'App\\Models\\User', 367),
(3, 'App\\Models\\User', 368),
(3, 'App\\Models\\User', 369),
(3, 'App\\Models\\User', 370),
(3, 'App\\Models\\User', 371),
(3, 'App\\Models\\User', 372),
(3, 'App\\Models\\User', 373),
(3, 'App\\Models\\User', 374),
(3, 'App\\Models\\User', 375),
(3, 'App\\Models\\User', 376),
(3, 'App\\Models\\User', 377),
(3, 'App\\Models\\User', 378),
(3, 'App\\Models\\User', 379),
(3, 'App\\Models\\User', 380),
(3, 'App\\Models\\User', 381),
(3, 'App\\Models\\User', 382),
(3, 'App\\Models\\User', 383),
(3, 'App\\Models\\User', 384),
(3, 'App\\Models\\User', 385),
(3, 'App\\Models\\User', 386),
(3, 'App\\Models\\User', 387),
(3, 'App\\Models\\User', 388),
(3, 'App\\Models\\User', 389),
(3, 'App\\Models\\User', 390),
(3, 'App\\Models\\User', 391),
(3, 'App\\Models\\User', 392),
(3, 'App\\Models\\User', 393),
(3, 'App\\Models\\User', 394),
(3, 'App\\Models\\User', 395),
(3, 'App\\Models\\User', 396),
(3, 'App\\Models\\User', 397),
(3, 'App\\Models\\User', 398),
(3, 'App\\Models\\User', 399),
(3, 'App\\Models\\User', 400),
(3, 'App\\Models\\User', 401),
(3, 'App\\Models\\User', 402),
(3, 'App\\Models\\User', 403),
(3, 'App\\Models\\User', 404),
(3, 'App\\Models\\User', 405),
(3, 'App\\Models\\User', 406),
(3, 'App\\Models\\User', 407),
(3, 'App\\Models\\User', 408),
(3, 'App\\Models\\User', 409),
(3, 'App\\Models\\User', 410),
(3, 'App\\Models\\User', 411),
(3, 'App\\Models\\User', 412),
(3, 'App\\Models\\User', 413),
(3, 'App\\Models\\User', 414),
(3, 'App\\Models\\User', 415),
(3, 'App\\Models\\User', 416),
(3, 'App\\Models\\User', 417),
(3, 'App\\Models\\User', 418),
(3, 'App\\Models\\User', 419),
(3, 'App\\Models\\User', 420),
(3, 'App\\Models\\User', 421),
(3, 'App\\Models\\User', 422),
(3, 'App\\Models\\User', 423),
(3, 'App\\Models\\User', 424),
(3, 'App\\Models\\User', 425),
(3, 'App\\Models\\User', 426),
(3, 'App\\Models\\User', 427),
(3, 'App\\Models\\User', 428),
(3, 'App\\Models\\User', 429),
(3, 'App\\Models\\User', 430),
(3, 'App\\Models\\User', 431),
(3, 'App\\Models\\User', 432),
(3, 'App\\Models\\User', 433),
(3, 'App\\Models\\User', 434),
(3, 'App\\Models\\User', 435),
(3, 'App\\Models\\User', 436),
(3, 'App\\Models\\User', 437),
(3, 'App\\Models\\User', 438),
(3, 'App\\Models\\User', 439),
(3, 'App\\Models\\User', 440),
(3, 'App\\Models\\User', 441),
(3, 'App\\Models\\User', 442),
(3, 'App\\Models\\User', 443),
(3, 'App\\Models\\User', 444),
(3, 'App\\Models\\User', 445),
(3, 'App\\Models\\User', 446),
(3, 'App\\Models\\User', 447),
(3, 'App\\Models\\User', 448),
(3, 'App\\Models\\User', 449),
(3, 'App\\Models\\User', 450),
(3, 'App\\Models\\User', 451),
(3, 'App\\Models\\User', 452),
(3, 'App\\Models\\User', 453),
(3, 'App\\Models\\User', 454),
(3, 'App\\Models\\User', 455),
(3, 'App\\Models\\User', 456),
(3, 'App\\Models\\User', 457),
(3, 'App\\Models\\User', 458),
(3, 'App\\Models\\User', 459),
(3, 'App\\Models\\User', 460),
(3, 'App\\Models\\User', 461),
(3, 'App\\Models\\User', 462),
(3, 'App\\Models\\User', 463),
(3, 'App\\Models\\User', 464),
(3, 'App\\Models\\User', 465),
(3, 'App\\Models\\User', 466),
(3, 'App\\Models\\User', 467),
(3, 'App\\Models\\User', 468),
(3, 'App\\Models\\User', 469),
(3, 'App\\Models\\User', 470),
(3, 'App\\Models\\User', 471),
(3, 'App\\Models\\User', 472),
(3, 'App\\Models\\User', 473),
(3, 'App\\Models\\User', 474),
(3, 'App\\Models\\User', 475),
(3, 'App\\Models\\User', 476),
(3, 'App\\Models\\User', 477),
(3, 'App\\Models\\User', 478),
(3, 'App\\Models\\User', 479),
(3, 'App\\Models\\User', 480),
(3, 'App\\Models\\User', 481),
(3, 'App\\Models\\User', 482),
(3, 'App\\Models\\User', 483),
(3, 'App\\Models\\User', 484),
(3, 'App\\Models\\User', 485),
(3, 'App\\Models\\User', 486),
(3, 'App\\Models\\User', 487),
(3, 'App\\Models\\User', 488),
(3, 'App\\Models\\User', 489),
(3, 'App\\Models\\User', 490),
(3, 'App\\Models\\User', 491),
(3, 'App\\Models\\User', 492),
(3, 'App\\Models\\User', 493),
(3, 'App\\Models\\User', 494),
(3, 'App\\Models\\User', 495),
(3, 'App\\Models\\User', 496),
(3, 'App\\Models\\User', 497),
(3, 'App\\Models\\User', 498),
(3, 'App\\Models\\User', 499),
(3, 'App\\Models\\User', 500),
(3, 'App\\Models\\User', 501),
(3, 'App\\Models\\User', 502),
(3, 'App\\Models\\User', 503),
(3, 'App\\Models\\User', 504),
(3, 'App\\Models\\User', 505),
(3, 'App\\Models\\User', 506),
(3, 'App\\Models\\User', 507),
(3, 'App\\Models\\User', 508),
(3, 'App\\Models\\User', 509),
(3, 'App\\Models\\User', 510),
(3, 'App\\Models\\User', 511),
(3, 'App\\Models\\User', 512),
(3, 'App\\Models\\User', 513),
(3, 'App\\Models\\User', 514),
(3, 'App\\Models\\User', 515),
(3, 'App\\Models\\User', 516),
(3, 'App\\Models\\User', 517),
(3, 'App\\Models\\User', 518),
(3, 'App\\Models\\User', 519),
(3, 'App\\Models\\User', 520),
(3, 'App\\Models\\User', 521),
(3, 'App\\Models\\User', 522),
(3, 'App\\Models\\User', 523),
(3, 'App\\Models\\User', 524),
(3, 'App\\Models\\User', 525),
(3, 'App\\Models\\User', 526),
(3, 'App\\Models\\User', 527),
(3, 'App\\Models\\User', 528),
(3, 'App\\Models\\User', 529),
(3, 'App\\Models\\User', 530),
(3, 'App\\Models\\User', 531),
(3, 'App\\Models\\User', 532),
(3, 'App\\Models\\User', 533),
(3, 'App\\Models\\User', 534),
(3, 'App\\Models\\User', 535),
(3, 'App\\Models\\User', 536),
(3, 'App\\Models\\User', 537),
(3, 'App\\Models\\User', 538),
(3, 'App\\Models\\User', 539),
(3, 'App\\Models\\User', 540),
(3, 'App\\Models\\User', 541),
(3, 'App\\Models\\User', 542),
(3, 'App\\Models\\User', 543),
(3, 'App\\Models\\User', 544),
(3, 'App\\Models\\User', 545),
(3, 'App\\Models\\User', 546),
(3, 'App\\Models\\User', 547),
(3, 'App\\Models\\User', 548),
(3, 'App\\Models\\User', 549),
(3, 'App\\Models\\User', 550),
(3, 'App\\Models\\User', 551),
(3, 'App\\Models\\User', 552),
(3, 'App\\Models\\User', 553),
(3, 'App\\Models\\User', 554),
(3, 'App\\Models\\User', 555),
(3, 'App\\Models\\User', 556),
(3, 'App\\Models\\User', 557),
(3, 'App\\Models\\User', 558),
(3, 'App\\Models\\User', 559),
(3, 'App\\Models\\User', 560),
(3, 'App\\Models\\User', 561),
(3, 'App\\Models\\User', 562),
(3, 'App\\Models\\User', 563),
(3, 'App\\Models\\User', 564),
(3, 'App\\Models\\User', 565),
(3, 'App\\Models\\User', 566),
(3, 'App\\Models\\User', 567),
(3, 'App\\Models\\User', 568),
(3, 'App\\Models\\User', 569),
(3, 'App\\Models\\User', 570),
(3, 'App\\Models\\User', 571),
(3, 'App\\Models\\User', 572),
(3, 'App\\Models\\User', 573),
(3, 'App\\Models\\User', 574),
(3, 'App\\Models\\User', 575),
(3, 'App\\Models\\User', 576),
(3, 'App\\Models\\User', 577),
(3, 'App\\Models\\User', 578),
(3, 'App\\Models\\User', 579),
(3, 'App\\Models\\User', 580),
(3, 'App\\Models\\User', 581),
(3, 'App\\Models\\User', 582),
(3, 'App\\Models\\User', 583),
(3, 'App\\Models\\User', 584),
(3, 'App\\Models\\User', 585),
(3, 'App\\Models\\User', 586),
(3, 'App\\Models\\User', 587),
(3, 'App\\Models\\User', 588),
(3, 'App\\Models\\User', 589),
(3, 'App\\Models\\User', 590),
(3, 'App\\Models\\User', 591),
(3, 'App\\Models\\User', 592),
(3, 'App\\Models\\User', 593),
(3, 'App\\Models\\User', 594),
(3, 'App\\Models\\User', 595),
(3, 'App\\Models\\User', 596),
(3, 'App\\Models\\User', 597),
(3, 'App\\Models\\User', 598),
(3, 'App\\Models\\User', 599),
(3, 'App\\Models\\User', 600),
(3, 'App\\Models\\User', 601),
(3, 'App\\Models\\User', 602),
(3, 'App\\Models\\User', 603),
(3, 'App\\Models\\User', 604),
(3, 'App\\Models\\User', 605),
(3, 'App\\Models\\User', 606),
(3, 'App\\Models\\User', 607),
(3, 'App\\Models\\User', 608),
(3, 'App\\Models\\User', 609),
(3, 'App\\Models\\User', 610),
(3, 'App\\Models\\User', 611),
(3, 'App\\Models\\User', 612),
(3, 'App\\Models\\User', 613),
(3, 'App\\Models\\User', 614),
(3, 'App\\Models\\User', 615),
(3, 'App\\Models\\User', 616),
(3, 'App\\Models\\User', 617),
(3, 'App\\Models\\User', 618),
(3, 'App\\Models\\User', 619),
(3, 'App\\Models\\User', 620),
(3, 'App\\Models\\User', 621),
(3, 'App\\Models\\User', 622),
(3, 'App\\Models\\User', 623),
(3, 'App\\Models\\User', 624),
(3, 'App\\Models\\User', 625),
(3, 'App\\Models\\User', 626),
(3, 'App\\Models\\User', 627),
(3, 'App\\Models\\User', 628),
(3, 'App\\Models\\User', 629),
(3, 'App\\Models\\User', 630),
(3, 'App\\Models\\User', 631),
(3, 'App\\Models\\User', 632),
(3, 'App\\Models\\User', 633),
(3, 'App\\Models\\User', 634),
(3, 'App\\Models\\User', 635),
(3, 'App\\Models\\User', 636),
(3, 'App\\Models\\User', 637),
(3, 'App\\Models\\User', 638),
(3, 'App\\Models\\User', 639),
(3, 'App\\Models\\User', 640),
(2, 'App\\Models\\User', 641);

-- --------------------------------------------------------

--
-- Struktur dari tabel `organizers`
--

CREATE TABLE `organizers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('kementerian','dinas_pendidikan','perguruan_tinggi','organisasi_profesi','swasta','komunitas','lainnya') NOT NULL DEFAULT 'kementerian',
  `website` varchar(255) DEFAULT NULL,
  `instagram` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(25) DEFAULT NULL,
  `verification_status` enum('unverified','verified','official') NOT NULL DEFAULT 'unverified',
  `verified_at` timestamp NULL DEFAULT NULL,
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `organizers`
--

INSERT INTO `organizers` (`id`, `name`, `type`, `website`, `instagram`, `email`, `phone`, `verification_status`, `verified_at`, `verified_by`, `verification_notes`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Pusat Prestasi Nasional (Puspresnas)', 'kementerian', 'https://pusatprestasinasional.kemendikdasmen.go.id/', '@puspresnas', 'puspresnas@kemdikbud.go.id', '021-5725610', 'official', '2026-10-11 05:15:39', 1, 'Unit Pelaksana Teknis Kemendikdasmen pengelola ajang talenta nasional resmi.', '2026-10-11 05:06:56', '2026-10-11 05:15:39', NULL),
(2, 'Balai Pengembangan Talenta Indonesia (BPTI)', 'kementerian', 'https://bpti.kemendikdasmen.go.id/', '@bpti.kemdikbud', 'bpti@kemdikbud.go.id', '021-5725611', 'official', '2026-10-11 05:15:39', 1, 'Balai pelaksana ajang talenta dan pembinaan prestasi peserta didik se-Indonesia.', '2026-10-11 05:06:56', '2026-10-11 05:15:39', NULL),
(3, 'Klinik Pendidikan MIPA (KPM)', 'organisasi_profesi', 'https://kpm.or.id/', '@kpmseikhlasnya', 'sekretariat@kpm.or.id', NULL, 'official', '2026-10-11 05:15:39', 1, 'Lembaga pengembang MIPA nasional penyelenggara KMNR terakreditasi kurasi SIMT Puspresnas.', '2026-10-11 05:06:56', '2026-10-11 05:15:39', NULL),
(4, 'Center for Young Scientists Indonesia (CYS)', 'organisasi_profesi', 'https://cys.or.id/', '@cysindonesia', 'info@cys.or.id', NULL, 'official', '2026-10-11 05:15:39', 1, 'Penyelenggara Lomba Peneliti Belia afiliasi ICYS internasional, terkurasi resmi SIMT Puspresnas.', '2026-10-11 05:06:56', '2026-10-11 05:15:39', NULL),
(5, 'Universitas Gadjah Mada (UGM)', 'perguruan_tinggi', 'https://ugm.ac.id/', '@ugm.yogyakarta', 'info@ugm.ac.id', NULL, 'official', '2026-10-11 05:15:39', 1, 'Penyelenggara Olgenas Fakultas Geografi UGM terakreditasi kurasi Puspresnas Kemendikdasmen.', '2026-10-11 05:06:56', '2026-10-11 05:15:39', NULL),
(6, 'Institut Teknologi Bandung (ITB)', 'perguruan_tinggi', 'https://itb.ac.id/', '@itb1920', 'humas@itb.ac.id', NULL, 'official', '2026-10-11 05:15:40', 1, 'Perguruan tinggi penyelenggara Arkavidia Informatics Contest ITB.', '2026-10-11 05:06:56', '2026-10-11 05:15:40', NULL),
(7, 'Universitas Indonesia (UI)', 'perguruan_tinggi', 'https://ui.ac.id/', '@univ_indonesia', 'humas-ui@ui.ac.id', NULL, 'official', '2026-10-11 05:15:40', 1, 'Penyelenggara National Science Challenge BEM FMIPA Universitas Indonesia.', '2026-10-11 05:06:56', '2026-10-11 05:15:40', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'schools.view', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(2, 'schools.create', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(3, 'schools.edit', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(4, 'schools.delete', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(5, 'schools.verify', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(6, 'students.view', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(7, 'students.create', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(8, 'students.edit', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(9, 'students.delete', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(10, 'students.import', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(11, 'competitions.view', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(12, 'competitions.create', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(13, 'competitions.edit', 'web', '2026-10-11 05:06:54', '2026-10-11 05:06:54'),
(14, 'competitions.delete', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(15, 'competitions.verify', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(16, 'registrations.view', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(17, 'registrations.create', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(18, 'registrations.approve', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(19, 'achievements.view', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(20, 'achievements.create', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(21, 'achievements.verify', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(22, 'audit_logs.view', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55');

-- --------------------------------------------------------

--
-- Struktur dari tabel `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(4, 'App\\Models\\User', 641, 'auth-token', 'e5362048513176cb23e301b7126c94be25121de0e00c04372e65cf028a90deb6', '[\"*\"]', '2026-10-11 18:16:01', NULL, '2026-10-11 18:11:39', '2026-10-11 18:16:01'),
(5, 'App\\Models\\User', 3, 'auth-token', '1ca57d1badd3a41ee247493aa03643a2ccdc5e8b3738f50d41866319c435ecad', '[\"*\"]', '2026-10-11 18:14:02', NULL, '2026-10-11 18:12:55', '2026-10-11 18:14:02'),
(6, 'App\\Models\\User', 1, 'auth-token', '11c7250ff73e83aa9653bd7604692c66166594b424f55c29a7cb086b30002b66', '[\"*\"]', '2026-10-11 18:44:49', NULL, '2026-10-11 18:25:53', '2026-10-11 18:44:49'),
(7, 'App\\Models\\User', 641, 'auth-token', 'ad23d08a65c16279bfe669982922a26f4f3141a54fb27b5378d2b9f7d516c1ab', '[\"*\"]', '2026-10-11 22:51:45', NULL, '2026-10-11 19:01:41', '2026-10-11 22:51:45'),
(8, 'App\\Models\\User', 641, 'auth-token', 'ee6ae1398fa66dc3fb093340cbab865ac2b2ad03d053b46d365df4467aa69045', '[\"*\"]', '2026-10-11 19:09:11', NULL, '2026-10-11 19:08:57', '2026-10-11 19:09:11'),
(9, 'App\\Models\\User', 641, 'auth-token', '3603366817ae565cb93095257eaee5a7dd0561862f256236fa6fb1e0e99741e0', '[\"*\"]', '2026-10-11 22:26:05', NULL, '2026-10-11 19:28:47', '2026-10-11 22:26:05'),
(10, 'App\\Models\\User', 641, 'auth-token', '11e6230e8ffe514ee2c877ee5f24b149cd51c192caa46870ed18544c18825025', '[\"*\"]', NULL, NULL, '2026-10-11 19:55:32', '2026-10-11 19:55:32'),
(11, 'App\\Models\\User', 641, 'auth-token', '82304f3abc7cba1d99e9878b377446aa3b36b1d4adacb71caece2a326970b011', '[\"*\"]', '2026-10-11 20:04:51', NULL, '2026-10-11 19:55:59', '2026-10-11 20:04:51'),
(12, 'App\\Models\\User', 3, 'auth-token', '3c98de3832fb1df50f8fa3d29f5f154b19dd483a60c51533a082ae080c416fa8', '[\"*\"]', '2026-10-11 20:18:53', NULL, '2026-10-11 20:06:39', '2026-10-11 20:18:53'),
(13, 'App\\Models\\User', 641, 'auth-token', '463320bb613fc50b20b1e79f538cae4f0beef94277c427c9f91fb8a5abd0f696', '[\"*\"]', '2026-10-12 08:50:13', NULL, '2026-10-11 20:19:17', '2026-10-12 08:50:13'),
(14, 'App\\Models\\User', 641, 'auth-token', '458b44f39984e8644c0135f952f62d9bb5a8983050911dcbf1925c86cb93e8c7', '[\"*\"]', '2026-10-18 10:16:19', NULL, '2026-10-18 10:16:11', '2026-10-18 10:16:19'),
(15, 'App\\Models\\User', 641, 'auth-token', '5b079fd61346fa9381dc1625e2c0c87cb0e794e7805173204d76c1b85b9f2a93', '[\"*\"]', '2026-10-18 20:19:48', NULL, '2026-10-18 18:52:36', '2026-10-18 20:19:48'),
(16, 'App\\Models\\User', 641, 'auth-token', 'c48b922fba680f801f7a6980dfabd513bd7c972346af61d4d136ff0a2d6e3975', '[\"*\"]', '2026-10-25 18:19:28', NULL, '2026-10-25 18:15:50', '2026-10-25 18:19:28'),
(17, 'App\\Models\\User', 641, 'auth-token', 'dc81426f269848aeea28475158a9147be26414231f04bf0d6ba02aad6f361d1e', '[\"*\"]', '2026-10-25 18:21:16', NULL, '2026-10-25 18:21:11', '2026-10-25 18:21:16'),
(18, 'App\\Models\\User', 3, 'auth-token', 'f3f82e2515c583b10160b1e985b9d1d5661bfc0e4f6a4cfe316e158a7b9ec415', '[\"*\"]', '2026-10-25 18:23:39', NULL, '2026-10-25 18:21:51', '2026-10-25 18:23:39'),
(19, 'App\\Models\\User', 641, 'auth-token', 'f993915bc6637309dae5599c1ccf2339c6a7900ac72c8f6f56e6b00532148f3e', '[\"*\"]', '2026-10-25 18:31:54', NULL, '2026-10-25 18:22:58', '2026-10-25 18:31:54'),
(20, 'App\\Models\\User', 3, 'auth-token', '392ff44cb3fa1dfbccc78838e3da33526683baadd3d7aadb7cc3053bba4b0723', '[\"*\"]', '2026-10-25 18:29:25', NULL, '2026-10-25 18:24:17', '2026-10-25 18:29:25'),
(21, 'App\\Models\\User', 641, 'auth-token', '4cca16d7a1494bb6d27e3502721ab3871bedd9db17fbe23d4124fd41e4bc1625', '[\"*\"]', '2026-10-25 18:27:26', NULL, '2026-10-25 18:27:24', '2026-10-25 18:27:26'),
(22, 'App\\Models\\User', 641, 'auth-token', 'a3c2311b7b38abd8b7273bc152cb5b62963d79aed184e6987261df0b45b77c30', '[\"*\"]', '2026-10-28 05:04:31', NULL, '2026-10-28 05:04:28', '2026-10-28 05:04:31'),
(23, 'App\\Models\\User', 641, 'auth-token', '020c82c75fa349ef562281d68e0faa2599a8020fea185c9f2aaad739f3bdfd0f', '[\"*\"]', '2026-10-28 22:51:47', NULL, '2026-10-28 22:01:48', '2026-10-28 22:51:47'),
(24, 'App\\Models\\User', 641, 'auth-token', '5a6ec625b30c562e1b63172332f59384d06ad281e90e5367f547a23eaae61ee6', '[\"*\"]', '2026-10-28 22:39:34', NULL, '2026-10-28 22:39:21', '2026-10-28 22:39:34'),
(25, 'App\\Models\\User', 641, 'auth-token', '2449f2be05d731e04b3d4fee3ca822e858dffc035d11091c59a716e97629d983', '[\"*\"]', '2026-10-28 22:40:22', NULL, '2026-10-28 22:40:16', '2026-10-28 22:40:22'),
(26, 'App\\Models\\User', 3, 'auth-token', 'ecfe62ad50f38e3b68318866e79d3842989f277c2af54cb76b0287f1913f3070', '[\"*\"]', '2026-10-28 22:41:00', NULL, '2026-10-28 22:40:38', '2026-10-28 22:41:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `registrations`
--

CREATE TABLE `registrations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `registration_code` varchar(40) NOT NULL,
  `competition_id` bigint(20) UNSIGNED NOT NULL,
  `form_version_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `team_id` bigint(20) UNSIGNED DEFAULT NULL,
  `registration_type` enum('individual','team') NOT NULL DEFAULT 'individual',
  `registered_by` bigint(20) UNSIGNED NOT NULL,
  `status` enum('draft','pending_school_approval','approved_by_school','rejected_by_school','submitted','confirmed','cancelled') NOT NULL DEFAULT 'pending_school_approval',
  `result_status` enum('pending','participant','finalist','winner') NOT NULL DEFAULT 'pending',
  `rank_details` varchar(100) DEFAULT NULL,
  `certificate_file` varchar(255) DEFAULT NULL,
  `result_notes` text DEFAULT NULL,
  `result_recorded_at` datetime DEFAULT NULL,
  `school_approval_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `school_approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `school_approved_at` datetime DEFAULT NULL,
  `school_notes` text DEFAULT NULL,
  `assignment_letter_number` varchar(255) DEFAULT NULL,
  `assignment_letter_file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `registration_answers`
--

CREATE TABLE `registration_answers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `registration_id` bigint(20) UNSIGNED NOT NULL,
  `form_field_id` bigint(20) UNSIGNED NOT NULL,
  `field_key` varchar(100) NOT NULL,
  `field_label` varchar(255) NOT NULL,
  `answer_value` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `roles`
--

INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'super_admin', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(2, 'school_admin', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55'),
(3, 'student', 'web', '2026-10-11 05:06:55', '2026-10-11 05:06:55');

-- --------------------------------------------------------

--
-- Struktur dari tabel `role_has_permissions`
--

CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `role_has_permissions`
--

INSERT INTO `role_has_permissions` (`permission_id`, `role_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1),
(11, 1),
(12, 1),
(13, 1),
(14, 1),
(15, 1),
(16, 1),
(17, 1),
(18, 1),
(19, 1),
(20, 1),
(21, 1),
(22, 1),
(1, 2),
(3, 2),
(6, 2),
(7, 2),
(8, 2),
(9, 2),
(10, 2),
(11, 2),
(16, 2),
(18, 2),
(19, 2),
(21, 2),
(11, 3),
(16, 3),
(17, 3),
(19, 3),
(20, 3);

-- --------------------------------------------------------

--
-- Struktur dari tabel `schools`
--

CREATE TABLE `schools` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `npsn` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `educational_level` enum('sltp','slta','both') NOT NULL DEFAULT 'slta',
  `status` enum('pending','verified','rejected','suspended') NOT NULL DEFAULT 'pending',
  `province` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `district` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(25) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `dispensation_form_schema` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dispensation_form_schema`)),
  `letterhead_image_path` varchar(255) DEFAULT NULL,
  `letterhead_type` varchar(255) NOT NULL DEFAULT 'text',
  `letter_format_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`letter_format_config`)),
  `dispensation_docx_template_path` varchar(255) DEFAULT NULL,
  `permission_form_schema` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permission_form_schema`)),
  `permission_docx_template_path` varchar(255) DEFAULT NULL,
  `permission_letter_format_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permission_letter_format_config`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `schools`
--

INSERT INTO `schools` (`id`, `npsn`, `name`, `educational_level`, `status`, `province`, `city`, `district`, `address`, `postal_code`, `phone`, `email`, `website`, `verified_at`, `verified_by`, `verification_notes`, `dispensation_form_schema`, `letterhead_image_path`, `letterhead_type`, `letter_format_config`, `dispensation_docx_template_path`, `permission_form_schema`, `permission_docx_template_path`, `permission_letter_format_config`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, '20579998', 'MA Unggulan K.H. Abd. Wahab Hasbulloh', 'slta', 'verified', 'Jawa Timur', 'Jombang', 'Jombang', 'Tambakberas, Jombang', NULL, '0321-123456', 'info@mau-tb.sch.id', NULL, NULL, NULL, NULL, NULL, 'schools/1/letterhead/yNkjc2w2pGsApwFNgnCveY5dbb3680mf0aZXJ4TC.jpg', 'image', '{\"institution_level1\":\"PEMERINTAH DAERAH PROVINSI\",\"institution_level2\":\"DINAS PENDIDIKAN DAN KEBUDAYAAN\",\"document_title\":\"SURAT KETERANGAN DISPENSASI BELAJAR (KBM)\",\"reference_number_prefix\":\"421.3\\/DISP-KBM\",\"closing_text\":\"Demikian surat dispensasi ini dibuat agar Bapak\\/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa tetap berkewajiban menyelesaikan materi pelajaran serta tugas-tugas yang tertinggal.\",\"header_width_mode\":\"full\",\"header_max_height\":250,\"header_alignment\":\"center\",\"header_margin_bottom\":2}', NULL, NULL, NULL, NULL, '2026-10-11 05:15:45', '2026-10-25 18:31:54', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `school_registrations`
--

CREATE TABLE `school_registrations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `npsn` varchar(20) NOT NULL,
  `school_name` varchar(255) NOT NULL,
  `educational_level` enum('sltp','slta','both') NOT NULL DEFAULT 'slta',
  `province` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `district` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `pic_name` varchar(255) NOT NULL,
  `pic_email` varchar(255) NOT NULL,
  `pic_phone` varchar(25) NOT NULL,
  `pic_position` varchar(255) NOT NULL,
  `document_path` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `school_signers`
--

CREATE TABLE `school_signers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `nip` varchar(255) DEFAULT NULL,
  `position_title` varchar(255) NOT NULL,
  `role_type` varchar(255) NOT NULL DEFAULT 'other',
  `signature_token` varchar(64) NOT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `birth_place` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `address` text DEFAULT NULL,
  `education_history` text DEFAULT NULL,
  `biography` text DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `school_signers`
--

INSERT INTO `school_signers` (`id`, `school_id`, `name`, `nip`, `position_title`, `role_type`, `signature_token`, `photo_path`, `birth_place`, `birth_date`, `address`, `education_history`, `biography`, `phone`, `email`, `is_active`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Drs. H. Abd. Haris', NULL, 'Wakil Kepala Madrasah Urusan Kesiswaan', 'waka_kesiswaan', 'K8F5EHREc2eDASNsIvgPSZnsxllWDvHVqbvbcutv', 'signers/photos/tYbAbP0XThwLtdpOXgewTG2KGnZ0kDCd33dsIDhA.jpg', 'Sumenep', '1967-11-12', 'Jln. Abd. Rahman Saleh Gg. IV Jombang', 'S1 - Institut Of Islamic Cairo Mesir Tahun 1997', NULL, NULL, NULL, 1, '2026-10-11 20:21:43', '2026-10-11 20:21:43', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('4BE2fHoM12UG6SVUvJ8WISAJNwgksgWvbzlgb6Om', NULL, '114.5.221.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJrMXJXVWppME5BM0pRM0FjVlVUTEFBeEl4VDc5TjZlb3NyWnk0ZGU4IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9wcmVzdGFzaWt1Lm5haG51c3RkLmNvbVwvYmFja2VuZCIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1791765737),
('mxyMIhXyflX0z07aUNPQPKkEL72jHvcxY09THfv3', NULL, '114.5.221.219', 'curl/8.13.0', 'eyJfdG9rZW4iOiJFWFNWNEIyUVBTajhWOHJOeFJ4YU94UTBnTkZvNmpWTDVnNUNuRHYzIiwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1791765442);

-- --------------------------------------------------------

--
-- Struktur dari tabel `students`
--

CREATE TABLE `students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `nis` varchar(30) NOT NULL,
  `nisn` varchar(20) DEFAULT NULL,
  `full_name` varchar(255) NOT NULL,
  `grade_level` tinyint(4) NOT NULL,
  `class_name` varchar(50) NOT NULL,
  `gender` enum('L','P') NOT NULL,
  `birth_date` date NOT NULL,
  `birth_place` varchar(100) DEFAULT NULL,
  `phone_number` varchar(25) DEFAULT NULL,
  `public_id` varchar(40) NOT NULL,
  `public_profile_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','graduated','transferred','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `students`
--

INSERT INTO `students` (`id`, `user_id`, `school_id`, `nis`, `nisn`, `full_name`, `grade_level`, `class_name`, `gender`, `birth_date`, `birth_place`, `phone_number`, `public_id`, `public_profile_enabled`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 3, 1, '109876976', '109876976', 'ACHMAD AZAM MAULANA IBRAHIM', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_kztV4R9T2e65WbjuYIOdfKdz', 0, 'active', '2026-10-11 05:15:47', '2026-10-11 05:15:47', NULL),
(2, 4, 1, '3098832744', '3098832744', 'ACHMAD DWI PRAMUDIA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_GXCvLNaz2un85BZpKqIVoAGc', 0, 'active', '2026-10-11 05:15:48', '2026-10-11 05:15:48', NULL),
(3, 5, 1, '78953495', '78953495', 'ACHMAD KHOTIB ALMUZAQI', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_7UfZKLZnTNUZt7pQxjigb2UF', 0, 'active', '2026-10-11 05:15:48', '2026-10-11 05:15:48', NULL),
(4, 6, 1, '3111603066', '3111603066', 'ACHSANUL TUMUHULAWA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_uG3B1xDhXHs2PZF0RAslVG2t', 0, 'active', '2026-10-11 05:15:49', '2026-10-11 05:15:49', NULL),
(5, 7, 1, '108901736', '108901736', 'ADHYAKSA TOPAS PRIYANDARU', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_jkEfJUGyx4H6h2pV5HdxgDkk', 0, 'active', '2026-10-11 05:15:49', '2026-10-11 05:15:49', NULL),
(6, 8, 1, '3103912632', '3103912632', 'ADI SETIAWAN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_QGl4dvY6e4FvA4kNUNOSBKtA', 0, 'active', '2026-10-11 05:15:50', '2026-10-11 05:15:50', NULL),
(7, 9, 1, '3109496521', '3109496521', 'ADIKA PUTRA AFANIN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_EqDvC6E3JRmqk0daFkLcBAEN', 0, 'active', '2026-10-11 05:15:50', '2026-10-11 05:15:50', NULL),
(8, 10, 1, '117951786', '117951786', 'AGENG MAHARDIKA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_LZXrYn32rEUegBqwVdoaafDX', 0, 'active', '2026-10-11 05:15:51', '2026-10-11 05:15:51', NULL),
(9, 11, 1, '3117714534', '3117714534', 'AHMAD ABDURRAHMAN JAMALUDDIN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_Jvkib9yuWkQBNCEwLM4fFFx8', 0, 'active', '2026-10-11 05:15:51', '2026-10-11 05:15:51', NULL),
(10, 12, 1, '102613249', '102613249', 'AHMAD AUFAA MUTQINA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_kfz6ngN6ewoTNZ3SFaqa96nh', 0, 'active', '2026-10-11 05:15:51', '2026-10-11 05:15:51', NULL),
(11, 13, 1, '108579188', '108579188', 'AHMAD DANIEL VAHLEVY', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_MKJ0d4YqMcD3WXbdNSuKeeAo', 0, 'active', '2026-10-11 05:15:52', '2026-10-11 05:15:52', NULL),
(12, 14, 1, '3109288571', '3109288571', 'AHMAD HABIB FURQONI', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_XxibwsdQImmXvQyOhMhmSxJp', 0, 'active', '2026-10-11 05:15:52', '2026-10-11 05:15:52', NULL),
(13, 15, 1, '3097415133', '3097415133', 'AHMAD MUKAFFIN RIZQILLAH', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_yiUyfJZRek5DpMcD63KTARRo', 0, 'active', '2026-10-11 05:15:53', '2026-10-11 05:15:53', NULL),
(14, 16, 1, '111052463', '111052463', 'AHMAD MUTHI\' BIAMRILLAH AL-MUSTHOFA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_exCteQIpeOzJe28ij54gKGUQ', 0, 'active', '2026-10-11 05:15:54', '2026-10-11 05:15:54', NULL),
(15, 17, 1, '92672167', '92672167', 'AHMAD RASYA SYARIFUDIN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_OUuL7MC4PxNTHkLBwaP0Prah', 0, 'active', '2026-10-11 05:15:54', '2026-10-11 05:15:54', NULL),
(16, 18, 1, '3118928337', '3118928337', 'AHMAD SAMUEL AL BALHA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_SCUT84jBOXfRSmF4cBvNTDbU', 0, 'active', '2026-10-11 05:15:55', '2026-10-11 05:15:55', NULL),
(17, 19, 1, '3110370715', '3110370715', 'AHMAD VICKY JAELANI', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_8Sp4RAmzaMarrxjbPYBLmJkz', 0, 'active', '2026-10-11 05:15:55', '2026-10-11 05:15:55', NULL),
(18, 20, 1, '3107348745', '3107348745', 'ALDI SETIAWAN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_esLi62QLi7bIrzKyGc7vsaCU', 0, 'active', '2026-10-11 05:15:55', '2026-10-11 05:15:55', NULL),
(19, 21, 1, '118092541', '118092541', 'ALFITO AIDAN RAFIF', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_tu8YWt8wsanLZOZuu2F2wvUx', 0, 'active', '2026-10-11 05:15:56', '2026-10-11 05:15:56', NULL),
(20, 22, 1, '106288129', '106288129', 'ALFREZZI KHAUFINDA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_gFuRiuA9hhqvfHZRVHj00aui', 0, 'active', '2026-10-11 05:15:57', '2026-10-11 05:15:57', NULL),
(21, 23, 1, '113401710', '113401710', 'ANANDA RISKY RADHITYA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_63zhZLKrIWGXAsnOW2Y7Rap4', 0, 'active', '2026-10-11 05:15:57', '2026-10-11 05:15:57', NULL),
(22, 24, 1, '105973093', '105973093', 'AQIL CANDRA ROBANI', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_eupewoww3nK5O4xwHkJx8WQT', 0, 'active', '2026-10-11 05:15:58', '2026-10-11 05:15:58', NULL),
(23, 25, 1, '108459146', '108459146', 'ARDIAN RIKO SAPUTRA', 10, 'X-1', 'P', '2009-01-01', NULL, NULL, 'std_KNUUGvT6GwWbz0EKP5KIBgTS', 0, 'active', '2026-10-11 05:15:58', '2026-10-11 05:15:58', NULL),
(24, 26, 1, '3115950702', '3115950702', 'ATIF SYAHIN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_vOdIqP8io3SjxVCLtS3arEmB', 0, 'active', '2026-10-11 05:15:58', '2026-10-11 05:15:58', NULL),
(25, 27, 1, '119464561', '119464561', 'AZIZAN MARVIN JIYA HAZIQ', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_PSgYKMa9VTh2okXsptcANexU', 0, 'active', '2026-10-11 05:15:59', '2026-10-11 05:15:59', NULL),
(26, 28, 1, '112066727', '112066727', 'AZKA FARIS MUHAMMAD', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_uhjcKN86khlWCOi43Q6xc99Y', 0, 'active', '2026-10-11 05:15:59', '2026-10-11 05:15:59', NULL),
(27, 29, 1, '112275423', '112275423', 'BALYAN HABIL GHATAFAN', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_0DOEyrbqlgC5NKCM7i2I4DB3', 0, 'active', '2026-10-11 05:16:00', '2026-10-11 05:16:00', NULL),
(28, 30, 1, '119054313', '119054313', 'BIMA RAMADHAN PRATAMA', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_Y6D6cQ00WlNfLHFOUI1NULpo', 0, 'active', '2026-10-11 05:16:00', '2026-10-11 05:16:00', NULL),
(29, 31, 1, '3113225694', '3113225694', 'CHOIRUDIN ISMAIL', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_wv4bC1vO5Kt9HmZ334I3m5Yt', 0, 'active', '2026-10-11 05:16:01', '2026-10-11 05:16:01', NULL),
(30, 32, 1, '103777717', '103777717', 'EMILLUL FATAH', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_pMYtLkoB9DM1ZWFXIG5yiLFH', 0, 'active', '2026-10-11 05:16:02', '2026-10-11 05:16:02', NULL),
(31, 33, 1, '101229766', '101229766', 'FADHIL SAADI ZAHID', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_1ogHa7xk41bDwUi0iNZBt7Fd', 0, 'active', '2026-10-11 05:16:03', '2026-10-11 05:16:03', NULL),
(32, 34, 1, '116522335', '116522335', 'GILANG FAJAR RAHMATULLAH', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_kRCg46r4vbe7LnknK8C7HLTh', 0, 'active', '2026-10-11 05:16:03', '2026-10-11 05:16:03', NULL),
(33, 35, 1, '116838295', '116838295', 'AHMAD', 10, 'X-1', 'L', '2009-01-01', NULL, NULL, 'std_Gy37qZLD3Jc64pasZ7XRenip', 0, 'active', '2026-10-11 05:16:04', '2026-10-11 05:16:04', NULL),
(34, 36, 1, '113041483', '113041483', 'FARID DEMITRA PRAYOGA', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_a6xHD9u6BlDPuSLKBOFXsDyp', 0, 'active', '2026-10-11 05:16:05', '2026-10-11 05:16:05', NULL),
(35, 37, 1, '114511448', '114511448', 'FINO HAIDAR AZAM', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_2P2BWGpUIiXrkJwHCfMfkSC5', 0, 'active', '2026-10-11 05:16:06', '2026-10-11 05:16:06', NULL),
(36, 38, 1, '113995793', '113995793', 'HAFIZ AZIM ABDILLAH', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_qWboC8gQAG100HwKB8SmxKaX', 0, 'active', '2026-10-11 05:16:06', '2026-10-11 05:16:06', NULL),
(37, 39, 1, '105023493', '105023493', 'IKRAR LANGIT MERDEKA KURNIAWAN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_kOaII41dskW4iio4GwHB9hnL', 0, 'active', '2026-10-11 05:16:07', '2026-10-11 05:16:07', NULL),
(38, 40, 1, '117630810', '117630810', 'JAVIERI RAFIF SAKHI ALMAHABIH', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_CbCA2AxaObXRFLEXpFOkkQeN', 0, 'active', '2026-10-11 05:16:08', '2026-10-11 05:16:08', NULL),
(39, 41, 1, '119988882', '119988882', 'KAFFA MACHY ALMUSAFY', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_THCWA44FcQPFqTvM6JtL1yPC', 0, 'active', '2026-10-11 05:16:08', '2026-10-11 05:16:08', NULL),
(40, 42, 1, '97556803', '97556803', 'KESIT WAHYU ARYAWINDARU', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_cGqaI3CGEcBrwmVUrUWq0M6z', 0, 'active', '2026-10-11 05:16:08', '2026-10-11 05:16:08', NULL),
(41, 43, 1, '103272204', '103272204', 'KOEN AZKA ZACHARI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_zBTlUmPtAydcXvFAMGc107xp', 0, 'active', '2026-10-11 05:16:09', '2026-10-11 05:16:09', NULL),
(42, 44, 1, '103802334', '103802334', 'M KHUFAF ADZIKRILLAH RAMADHAN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_LCpKmfjjPG1DFdvh1aVkx3xj', 0, 'active', '2026-10-11 05:16:09', '2026-10-11 05:16:09', NULL),
(43, 45, 1, '112036109', '112036109', 'M. REFAN ADITYA RAMADHAN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_Yhv6kYzzvWAKlppyl2X9wlXq', 0, 'active', '2026-10-11 05:16:10', '2026-10-11 05:16:10', NULL),
(44, 46, 1, '3114906538', '3114906538', 'M.KAFIL KHOTHIBUL UMAM', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_u1DfXNxlpMeFZ5TkwWfNTloL', 0, 'active', '2026-10-11 05:16:10', '2026-10-11 05:16:10', NULL),
(45, 47, 1, '112595247', '112595247', 'M.SENDI STIAWAN PUTRA PRATAMA', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_m0Q5FqfljHiDf5Uw5rWFncfp', 0, 'active', '2026-10-11 05:16:11', '2026-10-11 05:16:11', NULL),
(46, 48, 1, '3107047232', '3107047232', 'MAULA ZIFRIEL ZUHAIRI NURSYAMS', 10, 'X-2', 'P', '2009-01-01', NULL, NULL, 'std_oYQuT62oBYLQfMwkmRxP017Y', 0, 'active', '2026-10-11 05:16:11', '2026-10-11 05:16:11', NULL),
(47, 49, 1, '119767184', '119767184', 'MAULANA BAHAUDIN FAUZAN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_1NXGSF4a6eiuAPWlltzgj4xX', 0, 'active', '2026-10-11 05:16:11', '2026-10-11 05:16:11', NULL),
(48, 50, 1, '129444631', '129444631', 'MISBAKHUS SHABRI RUSMANUDIN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_9kmZdhG9Ike2TfapF3W1R352', 0, 'active', '2026-10-11 05:16:12', '2026-10-11 05:16:12', NULL),
(49, 51, 1, '101496176', '101496176', 'MOCHAMAD AFGAN IBRAHIM', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_z3sdfnw4OfvB0xBMwZzUGpNh', 0, 'active', '2026-10-11 05:16:13', '2026-10-11 05:16:13', NULL),
(50, 52, 1, '3107780187', '3107780187', 'MOH ARIFIN ILHAM', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_9088jMcpR2XUD21vBVLZRU90', 0, 'active', '2026-10-11 05:16:13', '2026-10-11 05:16:13', NULL),
(51, 53, 1, '103629847', '103629847', 'MOH. IFTAHUR ROZIQIN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_vJVL3at7ldXlw9Ym9lDEqgPA', 0, 'active', '2026-10-11 05:16:13', '2026-10-11 05:16:13', NULL),
(52, 54, 1, '109782484', '109782484', 'MOH. ISHOMUDDIN AL HANNAN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_QDbHkVTle5JFU3qeeqdi3Xmb', 0, 'active', '2026-10-11 05:16:14', '2026-10-11 05:16:14', NULL),
(53, 55, 1, '115387792', '115387792', 'MOH.IRFAN IBRAHIM SYA\'BANI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_7038FOrwJo4DuPBuXnWBBSrI', 0, 'active', '2026-10-11 05:16:14', '2026-10-11 05:16:14', NULL),
(54, 56, 1, '3102346398', '3102346398', 'MOHAMMAD DAFFA HAFIDZ INIESTA', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_nV22BzvtlODe4Z2bmRS7wOjp', 0, 'active', '2026-10-11 05:16:14', '2026-10-11 05:16:14', NULL),
(55, 57, 1, '3114883341', '3114883341', 'MOHAMMAD HAFIDZ MUKMIN EL HUSNI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_NIGau9U04YpgBZDsXt1J5kGu', 0, 'active', '2026-10-11 05:16:15', '2026-10-11 05:16:15', NULL),
(56, 58, 1, '3106302415', '3106302415', 'MOHAMMAD HAZIQ ILMAN HIJAZI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_QEG2nvsGkI6F9RdlNvXSbvr3', 0, 'active', '2026-10-11 05:16:15', '2026-10-11 05:16:15', NULL),
(57, 59, 1, '93161340', '93161340', 'MOHAMMAD TSAQIF DZIKRILLAH', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_kgR7qHpR02ck5IA13mlVUHiq', 0, 'active', '2026-10-11 05:16:16', '2026-10-11 05:16:16', NULL),
(58, 60, 1, '3105566106', '3105566106', 'MUHAMMAD ABDILLAH MAHASURA AL-FARUQ', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_CZyiI7ALnMziOEChnoELU9xt', 0, 'active', '2026-10-11 05:16:16', '2026-10-11 05:16:16', NULL),
(59, 61, 1, '102304054', '102304054', 'MUHAMMAD ADLAN FAHMI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_y49Lyx8Z2vcmoF2Yoi4diZvK', 0, 'active', '2026-10-11 05:16:17', '2026-10-11 05:16:17', NULL),
(60, 62, 1, '3110507484', '3110507484', 'MUHAMMAD AHDA ASYSYAUQI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_g3eYOYWpY7HUCjRjkAKVlO76', 0, 'active', '2026-10-11 05:16:17', '2026-10-11 05:16:17', NULL),
(61, 63, 1, '3103068661', '3103068661', 'MUHAMMAD ALFIAN NAJA', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_f362mFyHyqA8zocpJ1HxTmNh', 0, 'active', '2026-10-11 05:16:18', '2026-10-11 05:16:18', NULL),
(62, 64, 1, '104937480', '104937480', 'MUHAMMAD ALFINO', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_4YAR23aalcWY4ueiiurlUvK2', 0, 'active', '2026-10-11 05:16:18', '2026-10-11 05:16:18', NULL),
(63, 65, 1, '107149297', '107149297', 'MUHAMMAD ALIF SYAFIQ NUR RISKY', 10, 'X-2', 'P', '2009-01-01', NULL, NULL, 'std_FghRQMTjHseMiMjoeUjCKfaW', 0, 'active', '2026-10-11 05:16:19', '2026-10-11 05:16:19', NULL),
(64, 66, 1, '3116328211', '3116328211', 'MUHAMMAD ARGATHA ROMADHONI', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_D1fgap5cT2s2gUJI5xmDw5yQ', 0, 'active', '2026-10-11 05:16:19', '2026-10-11 05:16:19', NULL),
(65, 67, 1, '118597649', '118597649', 'TOHA HUSEIN', 10, 'X-2', 'L', '2009-01-01', NULL, NULL, 'std_Eadl10WNkQlMJphiOxZrCJLN', 0, 'active', '2026-10-11 05:16:19', '2026-10-11 05:16:19', NULL),
(66, 68, 1, '104758724', '104758724', 'MOHAMMAD ABDUL AZIZ', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_S2fOjH5fQLbTN9yBSTYcRiGz', 0, 'active', '2026-10-11 05:16:20', '2026-10-11 05:16:20', NULL),
(67, 69, 1, '3106610085', '3106610085', 'MUHAMMAD ARSYIL AGUSTINO RAMADANI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_fhrELX8sHUzpdQPEHJkBgdKD', 0, 'active', '2026-10-11 05:16:20', '2026-10-11 05:16:20', NULL),
(68, 70, 1, '3106152592', '3106152592', 'MUHAMMAD AZIS CHOLILULLOH', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_w47Ic5Bxq81KbyVfokyZU2k7', 0, 'active', '2026-10-11 05:16:21', '2026-10-11 05:16:21', NULL),
(69, 71, 1, '114874564', '114874564', 'MUHAMMAD AZZAMIR JAUHAR GHOFUR', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_fWZfjE2TJiq8qcJxdXNc0FEa', 0, 'active', '2026-10-11 05:16:21', '2026-10-11 05:16:21', NULL),
(70, 72, 1, '103139222', '103139222', 'MUHAMMAD BAHI BARDAN', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_y92XAqqbg2BHkv0EknnoipRl', 0, 'active', '2026-10-11 05:16:22', '2026-10-11 05:16:22', NULL),
(71, 73, 1, '3108354613', '3108354613', 'MUHAMMAD FAQIH PUTRA WIRATAMA', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_Dv2RkXqBDptxkNFLLuuGVQst', 0, 'active', '2026-10-11 05:16:22', '2026-10-11 05:16:22', NULL),
(72, 74, 1, '3105237916', '3105237916', 'MUHAMMAD GHULAM SYAUQI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_YdBhLZMPXdNV1tyeng3uwdRN', 0, 'active', '2026-10-11 05:16:23', '2026-10-11 05:16:23', NULL),
(73, 75, 1, '3100860037', '3100860037', 'MUHAMMAD ILHAM SANTOSO', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_AvLb53rP9PbDf3BhklJbDsnD', 0, 'active', '2026-10-11 05:16:23', '2026-10-11 05:16:23', NULL),
(74, 76, 1, '108285584', '108285584', 'MUHAMMAD IZZAM AUFA ROSYID', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_U5QPHS1DZuzG53vVUhSZkGMF', 0, 'active', '2026-10-11 05:16:23', '2026-10-11 05:16:23', NULL),
(75, 77, 1, '117796561', '117796561', 'MUHAMMAD KAFFABIH', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_gsxREEwReDfwm3dWnF34IUDU', 0, 'active', '2026-10-11 05:16:24', '2026-10-11 05:16:24', NULL),
(76, 78, 1, '3105196421', '3105196421', 'MUHAMMAD NASHRULLOH', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_2qFzI0hXfWgguyJVh4Hh1xAN', 0, 'active', '2026-10-11 05:16:24', '2026-10-11 05:16:24', NULL),
(77, 79, 1, '3104256842', '3104256842', 'MUHAMMAD NAZRUL ALI AUFA', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_cbwl97ePwABYwBdDpQVx5nfV', 0, 'active', '2026-10-11 05:16:25', '2026-10-11 05:16:25', NULL),
(78, 80, 1, '111678344', '111678344', 'MUHAMMAD PRIYO MAHARDIKA JAUHAR', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_k0uaziTx5OecSWkj38nPBY7l', 0, 'active', '2026-10-11 05:16:25', '2026-10-11 05:16:25', NULL),
(79, 81, 1, '104877294', '104877294', 'MUHAMMAD REZA SYA\'BANI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_s5bnF7u9ypUtlM0ALZ7aPI9O', 0, 'active', '2026-10-11 05:16:26', '2026-10-11 05:16:26', NULL),
(80, 82, 1, '3118961302', '3118961302', 'MUHAMMAD RIZQI AMRULLOH', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_cLBLDMcLKm5Ndrk3ASFhSzhg', 0, 'active', '2026-10-11 05:16:27', '2026-10-11 05:16:27', NULL),
(81, 83, 1, '3100172496', '3100172496', 'MOHAMMAD ULIL ABSHOR', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_GKw3lxThQa0585V2Qy9HL6XN', 0, 'active', '2026-10-11 05:16:27', '2026-10-11 05:16:27', NULL),
(82, 84, 1, '119111692', '119111692', 'MUHAMMAD YAFI SHAUQI NAJMI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_dstsJvkvitQxy3VZ6WC9aJX7', 0, 'active', '2026-10-11 05:16:29', '2026-10-11 05:16:29', NULL),
(83, 85, 1, '3105434208', '3105434208', 'MUHAMMAD ZIDANE ELFOUST', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_cA7VBBHMRg6fwfYpMoorgaf2', 0, 'active', '2026-10-11 05:16:30', '2026-10-11 05:16:30', NULL),
(84, 86, 1, '3113457876', '3113457876', 'MUKH. HAIDAR IRSYAD AL FAROUK', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_wjSR84M0y8G9ptqFBthIyJal', 0, 'active', '2026-10-11 05:16:30', '2026-10-11 05:16:30', NULL),
(85, 87, 1, '119837205', '119837205', 'MUKHAMMAD HARIS ABDULLAH AZAM', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_1evd3Zk1kjMRUyu9wfRASmhu', 0, 'active', '2026-10-11 05:16:31', '2026-10-11 05:16:31', NULL),
(86, 88, 1, '117461658', '117461658', 'MUZANI FAWWAZ AHMAD NIYAZI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_H9BdVrdPCmb1aHGiI4Ilgjrh', 0, 'active', '2026-10-11 05:16:32', '2026-10-11 05:16:32', NULL),
(87, 89, 1, '119316296', '119316296', 'NANDA FAREL ARDIYANSYAH', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_t4OuzvoxXTsvJyUJDX1aGptN', 0, 'active', '2026-10-11 05:16:32', '2026-10-11 05:16:32', NULL),
(88, 90, 1, '115217354', '115217354', 'NEO ARISTYANTO', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_oQb0qOgLfKq2OcpkdaYHEBcC', 0, 'active', '2026-10-11 05:16:33', '2026-10-11 05:16:33', NULL),
(89, 91, 1, '95915224', '95915224', 'RAIHAN AKBAR MAULANA', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_G4ODTsMNHSIaDVSy6QuCvcas', 0, 'active', '2026-10-11 05:16:33', '2026-10-11 05:16:33', NULL),
(90, 92, 1, '103861530', '103861530', 'REZKI ADITYA PRATAMA', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_hs5t3xvnlvTBJg7FQbVrG8BE', 0, 'active', '2026-10-11 05:16:34', '2026-10-11 05:16:34', NULL),
(91, 93, 1, '112928724', '112928724', 'ROYYAN ADZIKRI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_OXysveAQkkk9eQTlfHbsHabk', 0, 'active', '2026-10-11 05:16:34', '2026-10-11 05:16:34', NULL),
(92, 94, 1, '104029138', '104029138', 'SALMAN AL FARISI', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_fVWqa56uN749Rl3cdSYpiN49', 0, 'active', '2026-10-11 05:16:35', '2026-10-11 05:16:35', NULL),
(93, 95, 1, '117934620', '117934620', 'SYAHRUL AHMAD AN NUR', 10, 'X-3', 'P', '2009-01-01', NULL, NULL, 'std_1lcTdQcdnozcY4bJElX9r9jf', 0, 'active', '2026-10-11 05:16:35', '2026-10-11 05:16:35', NULL),
(94, 96, 1, '116557257', '116557257', 'TEZZAR RACYEL YUVEBYAN', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_gWgw1iWdYYZH8q5goKfPXtIH', 0, 'active', '2026-10-11 05:16:36', '2026-10-11 05:16:36', NULL),
(95, 97, 1, '3115214625', '3115214625', 'WALID MIFTAHUSSURUR', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_HlcDGbnZjOomjyXuh2nRLA9V', 0, 'active', '2026-10-11 05:16:37', '2026-10-11 05:16:37', NULL),
(96, 98, 1, '3104967030', '3104967030', 'YAVIL MU\'MIN', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_SDjs48bTuTKUE3d4kVWtkCcX', 0, 'active', '2026-10-11 05:16:37', '2026-10-11 05:16:37', NULL),
(97, 99, 1, '106823979', '106823979', 'ARJEN LEONADA FATEHA', 10, 'X-3', 'L', '2009-01-01', NULL, NULL, 'std_yPqJdpmLinh4ZSDJO3rFzL1u', 0, 'active', '2026-10-11 05:16:38', '2026-10-11 05:16:38', NULL),
(98, 100, 1, '115111382', '115111382', 'ABELIA DWI PUTRI', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_lhRPKKHzhmo0y0bcoJzaaupT', 0, 'active', '2026-10-11 05:16:38', '2026-10-11 05:16:38', NULL),
(99, 101, 1, '92814357', '92814357', 'ADINDA FATIMATUS ZAHRA', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_HbowzrhbAgQNKUJbpDamju11', 0, 'active', '2026-10-11 05:16:39', '2026-10-11 05:16:39', NULL),
(100, 102, 1, '112826555', '112826555', 'ADIZZA AZZAHRA', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_997EGWNtRwBv8TRWsZcatNM0', 0, 'active', '2026-10-11 05:16:39', '2026-10-11 05:16:39', NULL),
(101, 103, 1, '114907623', '114907623', 'AFIFAH KHAIRUNNISA AZZAHRA', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_wC6XN7ca107AxxhkRaRCpU6b', 0, 'active', '2026-10-11 05:16:40', '2026-10-11 05:16:40', NULL),
(102, 104, 1, '109417495', '109417495', 'AISYAH AXELIA BASTIAN', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_iDIvQ2L5aMcZIWDU0Po0uiUd', 0, 'active', '2026-10-11 05:16:40', '2026-10-11 05:16:40', NULL),
(103, 105, 1, '112096547', '112096547', 'AISYAH FARICHATUL MUFIDAH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_V2Vs1zoAwKlhLZU1D9ReLtbe', 0, 'active', '2026-10-11 05:16:41', '2026-10-11 05:16:41', NULL),
(104, 106, 1, '3112790590', '3112790590', 'AISYAH WAFIYATUL HUSNA', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_obvUmzuxiZ5aPwJ7z3YJEHhv', 0, 'active', '2026-10-11 05:16:41', '2026-10-11 05:16:41', NULL),
(105, 107, 1, '3113322236', '3113322236', 'AKHLA MURIDATUL QUDRIYYAH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_6B7MFWcIiRBSU3INekjqoKFl', 0, 'active', '2026-10-11 05:16:41', '2026-10-11 05:16:41', NULL),
(106, 108, 1, '117913806', '117913806', 'ALISHA NAZURAH AZZALEA HARTONO', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_6y8e4ghWF3qYF8D30FTHoNoN', 0, 'active', '2026-10-11 05:16:42', '2026-10-11 05:16:42', NULL),
(107, 109, 1, '119138841', '119138841', 'ALLISA QOTRUN FILOSOFIAH PUTRI', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_dQtQjUylDiyOwA0O6x0n2R2J', 0, 'active', '2026-10-11 05:16:42', '2026-10-11 05:16:42', NULL),
(108, 110, 1, '3117403038', '3117403038', 'ALVINA GUSTI MALIKA', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_csBsh9r29Mcys0Im3qlsiAVE', 0, 'active', '2026-10-11 05:16:43', '2026-10-11 05:16:43', NULL),
(109, 111, 1, '3112748473', '3112748473', 'ANA AISYAH NUR RAMADHANI', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_1WidNyEpri6USZ5YncOVKB1m', 0, 'active', '2026-10-11 05:16:43', '2026-10-11 05:16:43', NULL),
(110, 112, 1, '121839069', '121839069', 'ANZHA ADININGTYAS', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_7YBvFrNrnfBjB3eKlhVd5542', 0, 'active', '2026-10-11 05:16:44', '2026-10-11 05:16:44', NULL),
(111, 113, 1, '108827596', '108827596', 'APRILIA LAILATUN NI\'MAH', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_lSd4sLmHLDFt1VjTupKasqfe', 0, 'active', '2026-10-11 05:16:44', '2026-10-11 05:16:44', NULL),
(112, 114, 1, '116812098', '116812098', 'AQILA FADIA HAYAK', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_dHSprLutgxTCH7paWzwL84VV', 0, 'active', '2026-10-11 05:16:45', '2026-10-11 05:16:45', NULL),
(113, 115, 1, '119229188', '119229188', 'AQILLA GUSMELTIANA SUPRASTYO', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_gqPVLtUedBbOUZQdv2NUhEUG', 0, 'active', '2026-10-11 05:16:45', '2026-10-11 05:16:45', NULL),
(114, 116, 1, '108653891', '108653891', 'ASSYIFA MAKARIMA AIZTANIA', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_qs8h8jXeiFNfWDz27MjD61NU', 0, 'active', '2026-10-11 05:16:46', '2026-10-11 05:16:46', NULL),
(115, 117, 1, '3116736315', '3116736315', 'ASSYIFA\' NASYWAH KAYYISAH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_UToE4rh3gunqTokU7jQaDDWP', 0, 'active', '2026-10-11 05:16:46', '2026-10-11 05:16:46', NULL),
(116, 118, 1, '107159094', '107159094', 'ASYIFA ISNANIA CHANDRA', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_ueHyUvjBCJM1ZyA7UsZNSF9r', 0, 'active', '2026-10-11 05:16:46', '2026-10-11 05:16:46', NULL),
(117, 119, 1, '3104190790', '3104190790', 'ASYIFA\' LAILATUL MUNAWAROH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_m4LA5tS5oczOUcMQPQiTeshO', 0, 'active', '2026-10-11 05:16:47', '2026-10-11 05:16:47', NULL),
(118, 120, 1, '103299469', '103299469', 'ATINA RAHMAH MAHMUDIAH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_0bCXsQeCMzevVTpS2814R97E', 0, 'active', '2026-10-11 05:16:47', '2026-10-11 05:16:47', NULL),
(119, 121, 1, '3117577422', '3117577422', 'ATIQOH ZALFA RATU BILQIS', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_AZJNAx30mAF8VrO7mPNPM9zd', 0, 'active', '2026-10-11 05:16:47', '2026-10-11 05:16:47', NULL),
(120, 122, 1, '3102531445', '3102531445', 'ATIRA ECHI JIHAN ZAHRIA', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_BtdLl9zbjwa81imR6jIEYXKd', 0, 'active', '2026-10-11 05:16:48', '2026-10-11 05:16:48', NULL),
(121, 123, 1, '109602103', '109602103', 'AURA CINTA AZZA ARROHMAH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_THUk1sEqrrgs9yG2O6ygbYO7', 0, 'active', '2026-10-11 05:16:48', '2026-10-11 05:16:48', NULL),
(122, 124, 1, '3119108464', '3119108464', 'AYA ALIZA', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_KApViNisxrqOi55UeSIs7rs3', 0, 'active', '2026-10-11 05:16:49', '2026-10-11 05:16:49', NULL),
(123, 125, 1, '105155903', '105155903', 'AYU NINDYA AL ASFIHANI RIFQI', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_56kS7UMqKFdkbHV4xasbaYPT', 0, 'active', '2026-10-11 05:16:49', '2026-10-11 05:16:49', NULL),
(124, 126, 1, '105265165', '105265165', 'AZALIA RAMADHANI', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_X9GhjbjmlW8J1iY1bfM10SBx', 0, 'active', '2026-10-11 05:16:49', '2026-10-11 05:16:49', NULL),
(125, 127, 1, '105549740', '105549740', 'AZIZAH ROUDHOTUL HASANAH', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_Q0mgQfiaNaqNY2wfPOMLNgK1', 0, 'active', '2026-10-11 05:16:50', '2026-10-11 05:16:50', NULL),
(126, 128, 1, '108795354', '108795354', 'BILQIS OKTAVIA PUTRI', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_hJ7ezrLhTDqjRBGsB8DEwSOe', 0, 'active', '2026-10-11 05:16:50', '2026-10-11 05:16:50', NULL),
(127, 129, 1, '108442508', '108442508', 'CAHAYA AAFIYAH HASNA', 10, 'X-4', 'L', '2009-01-01', NULL, NULL, 'std_KzbAbOmdbNAm500i5NkAvn1R', 0, 'active', '2026-10-11 05:16:51', '2026-10-11 05:16:51', NULL),
(128, 130, 1, '3117645797', '3117645797', 'ATA ZAHRA FIRDAUS', 10, 'X-4', 'P', '2009-01-01', NULL, NULL, 'std_XGlDidhaW88WolDScygslyea', 0, 'active', '2026-10-11 05:16:51', '2026-10-11 05:16:51', NULL),
(129, 131, 1, '103290495', '103290495', 'ALMAIDAH NUR IDLOFY', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_FlOZY1d2rlpPG9nHzyBZyXl5', 0, 'active', '2026-10-11 05:16:51', '2026-10-11 05:16:51', NULL),
(130, 132, 1, '107709031', '107709031', 'DEANITA OKTAFIYANI', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_kwp5GcR88MuLOrfoC4apUWlC', 0, 'active', '2026-10-11 05:16:52', '2026-10-11 05:16:52', NULL),
(131, 133, 1, '101498182', '101498182', 'DEBY SHAHLA HABIBI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_RXDfSqfrKoxUtwfwDkJ7jyVp', 0, 'active', '2026-10-11 05:16:52', '2026-10-11 05:16:52', NULL),
(132, 134, 1, '3103502880', '3103502880', 'DEWI TSALITSAH RAHMA DINI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_OXIQ378duZK6EfeTn2Jqi4qC', 0, 'active', '2026-10-11 05:16:53', '2026-10-11 05:16:53', NULL),
(133, 135, 1, '105976653', '105976653', 'DINDA ARIFA OCTAVIANI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_Ivq6szk9Ohntt3gk9zvLeM8s', 0, 'active', '2026-10-11 05:16:53', '2026-10-11 05:16:53', NULL),
(134, 136, 1, '114811329', '114811329', 'DINDA KHURIN RAHMAWATI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_aU8LUbdp7FiDczabl8rA1XLj', 0, 'active', '2026-10-11 05:16:54', '2026-10-11 05:16:54', NULL),
(135, 137, 1, '103776104', '103776104', 'DURROH WAAFIROH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_pObQAAZerCekhOcFIweVOCAh', 0, 'active', '2026-10-11 05:16:54', '2026-10-11 05:16:54', NULL),
(136, 138, 1, '3111509999', '3111509999', 'DURROTUL WAFIIYAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_bz7t4bJFeFoeoWQsjabMZ41R', 0, 'active', '2026-10-11 05:16:54', '2026-10-11 05:16:54', NULL),
(137, 139, 1, '117853652', '117853652', 'DYSNI NABILA AZZAHRA', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_AvBW9LXA7PUXjUasNtGzRrxQ', 0, 'active', '2026-10-11 05:16:55', '2026-10-11 05:16:55', NULL),
(138, 140, 1, '3113071531', '3113071531', 'FAIRUZIATIN NAFISAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_QO6nviCzOTCek19SJhqmM1oF', 0, 'active', '2026-10-11 05:16:55', '2026-10-11 05:16:55', NULL),
(139, 141, 1, '3102812388', '3102812388', 'FANNY ARTANTI SUROTO', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_feSlZKEN0fIO0IEWH7blw0MI', 0, 'active', '2026-10-11 05:16:56', '2026-10-11 05:16:56', NULL),
(140, 142, 1, '103977010', '103977010', 'FATHIN NAJMA FAISHOL', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_dyx8G9l6FCZjPUc9SUVfg1BA', 0, 'active', '2026-10-11 05:16:56', '2026-10-11 05:16:56', NULL),
(141, 143, 1, '3119164374', '3119164374', 'FATIMAH FA\'IZATUN NISA\'', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_9IkUrCvcz16uERMR0ETmEYdB', 0, 'active', '2026-10-11 05:16:57', '2026-10-11 05:16:57', NULL),
(142, 144, 1, '3118699074', '3118699074', 'FITA RIF\'ATUL MUJIBAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_bAbeTvxPi0v23QxjHVxE7mbA', 0, 'active', '2026-10-11 05:16:57', '2026-10-11 05:16:57', NULL),
(143, 145, 1, '119164236', '119164236', 'FUZNA BEMAZHEYA GHUFAYRA', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_7F3JrwFzhkATu8t0H0vgj72Q', 0, 'active', '2026-10-11 05:16:57', '2026-10-11 05:16:57', NULL),
(144, 146, 1, '3118637609', '3118637609', 'GITA CHINTYA REISMANDA', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_bDbcC0UA3OCeREwxsP1L5zgQ', 0, 'active', '2026-10-11 05:16:58', '2026-10-11 05:16:58', NULL),
(145, 147, 1, '114431026', '114431026', 'HABIBAH NUR FAUZIAH', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_BdLoJvN0jtGuDfxuPKRPgb27', 0, 'active', '2026-10-11 05:16:58', '2026-10-11 05:16:58', NULL),
(146, 148, 1, '3101478309', '3101478309', 'HABIBATTUL MUTMAINAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_HmXEHpMQpMTSJ5Y8JQ2Q8dKH', 0, 'active', '2026-10-11 05:16:59', '2026-10-11 05:16:59', NULL),
(147, 149, 1, '3101239098', '3101239098', 'HANAA AIDA ADHIYA', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_yNpANJhdZy234KhhxDV7g4Gl', 0, 'active', '2026-10-11 05:16:59', '2026-10-11 05:16:59', NULL),
(148, 150, 1, '108625514', '108625514', 'HANNA MABRUKAH QOTRUNADA', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_gVYLmF54D431BwUq4YAYKLTS', 0, 'active', '2026-10-11 05:17:00', '2026-10-11 05:17:00', NULL),
(149, 151, 1, '102985679', '102985679', 'HASNA\'UL QUDSIYAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_zyNeaa5oH1wWlXZ4kflnNV96', 0, 'active', '2026-10-11 05:17:00', '2026-10-11 05:17:00', NULL),
(150, 152, 1, '106444942', '106444942', 'HAZZAH TALITHA JINAN', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_OqiTigkHrI82Je1QklOLPA2z', 0, 'active', '2026-10-11 05:17:01', '2026-10-11 05:17:01', NULL),
(151, 153, 1, '111486463', '111486463', 'HESTIANA SARI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_Nc2T8SB4pPrddKvIo4SQAN7f', 0, 'active', '2026-10-11 05:17:01', '2026-10-11 05:17:01', NULL),
(152, 154, 1, '94930797', '94930797', 'IFTINAN QORIIROH AINI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_1ltxmCKk2PjcyU9TdKEZuDbT', 0, 'active', '2026-10-11 05:17:02', '2026-10-11 05:17:02', NULL),
(153, 155, 1, '3117936144', '3117936144', 'IFTITAH NABILA AWALIYAH', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_vNJf4r68MG4fcoQJ5jXFWhps', 0, 'active', '2026-10-11 05:17:03', '2026-10-11 05:17:03', NULL),
(154, 156, 1, '3119034346', '3119034346', 'INDAH DWI ROHMAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_6pUc5ai6yjGiko6jr27H9anV', 0, 'active', '2026-10-11 05:17:04', '2026-10-11 05:17:04', NULL),
(155, 157, 1, '109249727', '109249727', 'ISMI AZIZIA NUR RACHMA', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_E2lbPG2xrK5lxOSWnLtqcNjk', 0, 'active', '2026-10-11 05:17:04', '2026-10-11 05:17:04', NULL),
(156, 158, 1, '116627214', '116627214', 'JULIA NURUL AZIKA', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_v6bdy4sONt3JlR9eXHUDA5yA', 0, 'active', '2026-10-11 05:17:04', '2026-10-11 05:17:04', NULL),
(157, 159, 1, '3104802366', '3104802366', 'KAMILAH MUFLIKHATU AZKAL ADIBAH', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_gMsIj1G34Itxd8GK8AWtf94e', 0, 'active', '2026-10-11 05:17:05', '2026-10-11 05:17:05', NULL),
(158, 160, 1, '101994355', '101994355', 'KARINA ARBA\'AH MUNFAATI', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_TygM9g9vTuHSc2RTUPjrhz7a', 0, 'active', '2026-10-11 05:17:05', '2026-10-11 05:17:05', NULL),
(159, 161, 1, '116011481', '116011481', 'KAYLA AISYAH ASY-SYIFA\'', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_d1urMZVbIYks3bn0U5Kdu8s3', 0, 'active', '2026-10-11 05:17:06', '2026-10-11 05:17:06', NULL),
(160, 162, 1, '102124847', '102124847', 'KHANSA ROFINA RAMADHANI ANNUR', 10, 'X-5', 'P', '2009-01-01', NULL, NULL, 'std_yQliJKPdjuI1QsBV3rjCZpzU', 0, 'active', '2026-10-11 05:17:06', '2026-10-11 05:17:06', NULL),
(161, 163, 1, '114669042', '114669042', 'SANIYA CAHYA QOLBI', 10, 'X-5', 'L', '2009-01-01', NULL, NULL, 'std_lXfRqXexlFDb15Y9Pw2JiWrG', 0, 'active', '2026-10-11 05:17:06', '2026-10-11 05:17:06', NULL),
(162, 164, 1, '118357276', '118357276', 'KHANZA BULGHATURRIZQI ATHIRA SETIAWAN', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_ppJEQmrnzK6jbonwNVJKpXew', 0, 'active', '2026-10-11 05:17:07', '2026-10-11 05:17:07', NULL),
(163, 165, 1, '105802975', '105802975', 'LABIBAH KAMELIA RAMADHANI', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_5BNZdskaJwbYSLL68tCIDCou', 0, 'active', '2026-10-11 05:17:07', '2026-10-11 05:17:07', NULL),
(164, 166, 1, '104153455', '104153455', 'LAURINA ZAHROTUL FITRI', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_7qYfGzVVcjB9CsoydvLd7ouf', 0, 'active', '2026-10-11 05:17:08', '2026-10-11 05:17:08', NULL),
(165, 167, 1, '118856445', '118856445', 'LEILA AYU SALSABILA', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_8nYB8S56IN2iIRBfcIBVDJbw', 0, 'active', '2026-10-11 05:17:08', '2026-10-11 05:17:08', NULL),
(166, 168, 1, '114973880', '114973880', 'LINA RAFIFAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_angakFtRFXH249pcZdhXDZPy', 0, 'active', '2026-10-11 05:17:08', '2026-10-11 05:17:08', NULL),
(167, 169, 1, '111652434', '111652434', 'LULU NAFIATUL HUSNA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_BnNCOQ11d6cfCkZluROdk303', 0, 'active', '2026-10-11 05:17:09', '2026-10-11 05:17:09', NULL),
(168, 170, 1, '108069342', '108069342', 'LUTHFI NADYATUROHMAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_SMK5MUSxuRb6rdFAi75RFbe1', 0, 'active', '2026-10-11 05:17:09', '2026-10-11 05:17:09', NULL),
(169, 171, 1, '3117929746', '3117929746', 'MARETA ARNELIA ANGGRAINI', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_5KKjUnjREwYXP26diH2lx3A1', 0, 'active', '2026-10-11 05:17:09', '2026-10-11 05:17:09', NULL),
(170, 172, 1, '108684735', '108684735', 'MAULIDA HAFIZA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_RSjp8FFik0x0ahRPLO99SSj8', 0, 'active', '2026-10-11 05:17:10', '2026-10-11 05:17:10', NULL),
(171, 173, 1, '101002365', '101002365', 'MEYDINA AYU RACHMA', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_1FzZOhCPfXqPTXP4AmyH1Up6', 0, 'active', '2026-10-11 05:17:10', '2026-10-11 05:17:10', NULL),
(172, 174, 1, '105509336', '105509336', 'MIR ATURAHMA MUWASSI', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_zxsd7QSFdhLSy9jk6OB6uTK1', 0, 'active', '2026-10-11 05:17:11', '2026-10-11 05:17:11', NULL),
(173, 175, 1, '106231456', '106231456', 'MUTIYA SALSYABELA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_OHKOZ8ulLH4n3V0MpVvVAFex', 0, 'active', '2026-10-11 05:17:11', '2026-10-11 05:17:11', NULL),
(174, 176, 1, '108196087', '108196087', 'NABILA AHZA NAURA', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_4Owra0Vur2fHyc040BFSclB1', 0, 'active', '2026-10-11 05:17:11', '2026-10-11 05:17:11', NULL),
(175, 177, 1, '3103602022', '3103602022', 'NABILA RAHADATUL AISYI', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_OS9ngb6u7efkk9u3smTNqQIy', 0, 'active', '2026-10-11 05:17:12', '2026-10-11 05:17:12', NULL),
(176, 178, 1, '111832375', '111832375', 'NABILAH DENI LUTHFIYAH', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_XdnisIkgAzPzzynW9J9ifRqr', 0, 'active', '2026-10-11 05:17:12', '2026-10-11 05:17:12', NULL),
(177, 179, 1, '3109841868', '3109841868', 'NABILAH NUR FAIZAH', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_3E3sQ3qP1u2dSAlxzLFFXgx7', 0, 'active', '2026-10-11 05:17:13', '2026-10-11 05:17:13', NULL),
(178, 180, 1, '106416610', '106416610', 'NADIFATUL QURIYAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_PjOcPUHI765SzOFTFbdng01d', 0, 'active', '2026-10-11 05:17:13', '2026-10-11 05:17:13', NULL),
(179, 181, 1, '114821465', '114821465', 'NAIMA NOER NUHA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_UDujhMRHOvonefCW0tLWF6Wx', 0, 'active', '2026-10-11 05:17:13', '2026-10-11 05:17:13', NULL),
(180, 182, 1, '3113094336', '3113094336', 'NAJWA NAJAHA MUTTAQIN', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_emy7VagTjZBwvIKMWiMWPovq', 0, 'active', '2026-10-11 05:17:14', '2026-10-11 05:17:14', NULL),
(181, 183, 1, '3101347175', '3101347175', 'NALA DZAKIYYA NASHIROH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_YNkentnmvU3RWNVFcPCj9Qje', 0, 'active', '2026-10-11 05:17:14', '2026-10-11 05:17:14', NULL),
(182, 184, 1, '119096442', '119096442', 'NALA TASYAYA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_G0MZ6Bo0RVlOzzcQoN626Xed', 0, 'active', '2026-10-11 05:17:15', '2026-10-11 05:17:15', NULL),
(183, 185, 1, '102782744', '102782744', 'NASWA NUR ROCHMA', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_QNkER5vquJPy6ZghiU3e3Zxs', 0, 'active', '2026-10-11 05:17:15', '2026-10-11 05:17:15', NULL),
(184, 186, 1, '101338252', '101338252', 'NATASYA SYIFAURRAHMA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_uexLEt6fKM7xwjHcVCsFkI10', 0, 'active', '2026-10-11 05:17:16', '2026-10-11 05:17:16', NULL),
(185, 187, 1, '116385119', '116385119', 'NAURA FARADILA ARIZZAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_GS9m2mHuqy4391lIfAutCglo', 0, 'active', '2026-10-11 05:17:16', '2026-10-11 05:17:16', NULL),
(186, 188, 1, '115352674', '115352674', 'NAURAH MAULIDINA KHOIR', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_lt65gQOW0E5U5LaetaBr27Ux', 0, 'active', '2026-10-11 05:17:17', '2026-10-11 05:17:17', NULL),
(187, 189, 1, '3119904936', '3119904936', 'NAZIDAH EKA ALIYAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_TnWsai3ktPBxAA2xdzPCoQaX', 0, 'active', '2026-10-11 05:17:17', '2026-10-11 05:17:17', NULL),
(188, 190, 1, '109412871', '109412871', 'NAZILAH ZUMROTUL MAS\'UDAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_0ajYrot9TcZsVxksmBILrr45', 0, 'active', '2026-10-11 05:17:18', '2026-10-11 05:17:18', NULL),
(189, 191, 1, '115298819', '115298819', 'NAZWA NUR HIKMAH', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_aZv4oZT0QDkGpiVPwB1w8zLe', 0, 'active', '2026-10-11 05:17:19', '2026-10-11 05:17:19', NULL),
(190, 192, 1, '3104367334', '3104367334', 'NELLY RAMADHANI LANJARSARI', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_mi4N3gXJjB61o1ArsyGyHCZa', 0, 'active', '2026-10-11 05:17:20', '2026-10-11 05:17:20', NULL),
(191, 193, 1, '3117099533', '3117099533', 'NINDYA FAIZA SAFILA', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_j1iVOdgZeMRFCbQwvObZaRmc', 0, 'active', '2026-10-11 05:17:20', '2026-10-11 05:17:20', NULL),
(192, 194, 1, '116305714', '116305714', 'NINE ADDIN SYARIFAH', 10, 'X-6', 'L', '2009-01-01', NULL, NULL, 'std_iqGGMagcYiPI0Gxrjdc3wUme', 0, 'active', '2026-10-11 05:17:20', '2026-10-11 05:17:20', NULL),
(193, 195, 1, '107355950', '107355950', 'NURDIANA WAHIDAH', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_qtFRqI7e62orsVue8LBiXY8O', 0, 'active', '2026-10-11 05:17:21', '2026-10-11 05:17:21', NULL),
(194, 196, 1, '3100744334', '3100744334', 'NURUL AZKIYYAH', 10, 'X-6', 'P', '2009-01-01', NULL, NULL, 'std_t8VN5lDlGIG8nJavOTNLPxET', 0, 'active', '2026-10-11 05:17:21', '2026-10-11 05:17:21', NULL),
(195, 197, 1, '3115521941', '3115521941', 'PATRICIA RACHMA AL-KHOFIDI', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_gS6GnjGjoAEXZNDk1u7djtYa', 0, 'active', '2026-10-11 05:17:22', '2026-10-11 05:17:22', NULL),
(196, 198, 1, '107611706', '107611706', 'QONITA NADHIRA', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_zn2Lgf2RXRxwZqdzsZEcIkVd', 0, 'active', '2026-10-11 05:17:22', '2026-10-11 05:17:22', NULL),
(197, 199, 1, '111155623', '111155623', 'QONITA TRYAS NUR NASTITI', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_OE8pZ6YUkAsk8RkPocIZErUP', 0, 'active', '2026-10-11 05:17:23', '2026-10-11 05:17:23', NULL),
(198, 200, 1, '115293734', '115293734', 'QUEENSYA DEWI NAILA AISYATUSY SYARIFAH', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_HQrRZXqrFBn1Y7YPWWTeBS3C', 0, 'active', '2026-10-11 05:17:23', '2026-10-11 05:17:23', NULL),
(199, 201, 1, '3104868891', '3104868891', 'RAHMA WILUJENG', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_ReqCRRJ8L2EOnHVYkD2ersKv', 0, 'active', '2026-10-11 05:17:23', '2026-10-11 05:17:23', NULL),
(200, 202, 1, '117177552', '117177552', 'RATIH AULIA DEWI BUDIARTI', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_ZI0Q0JbdYbwHqdJ7bsU7vio1', 0, 'active', '2026-10-11 05:17:24', '2026-10-11 05:17:24', NULL),
(201, 203, 1, '107316109', '107316109', 'RENAYYA ZAHROTUL FITRIAH', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_UKX4r5GmNR6fbYcXt8xKp4m3', 0, 'active', '2026-10-11 05:17:24', '2026-10-11 05:17:24', NULL),
(202, 204, 1, '114262292', '114262292', 'REVA LUTFIA FAUZI', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_90QHhYKF3V2h6MT7ulyMqKOB', 0, 'active', '2026-10-11 05:17:25', '2026-10-11 05:17:25', NULL),
(203, 205, 1, '3115209711', '3115209711', 'REVALINA SALSABILA AZZAHRA', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_sgdwbb92VCOzE8z2FNtjKqaP', 0, 'active', '2026-10-11 05:17:25', '2026-10-11 05:17:25', NULL),
(204, 206, 1, '106669224', '106669224', 'ROSYIDAH AULIA SABIH DIYANTO', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_bqVQAAh6MVA7OxyEaTvcs9Bk', 0, 'active', '2026-10-11 05:17:25', '2026-10-11 05:17:25', NULL),
(205, 207, 1, '111150136', '111150136', 'SAFARA AZKA RAIHANATI', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_nYVyWzfDm0PigVgWXVgp0du8', 0, 'active', '2026-10-11 05:17:26', '2026-10-11 05:17:26', NULL),
(206, 208, 1, '3108779110', '3108779110', 'SAIDA AISYAH SAFADEWI', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_R0sFkvAWIkzcdANeXHkurU7O', 0, 'active', '2026-10-11 05:17:26', '2026-10-11 05:17:26', NULL),
(207, 209, 1, '3105103243', '3105103243', 'SALWA NUZULUL MUFIDA', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_JuW0iR8jPQqslP2mVpsFoJDc', 0, 'active', '2026-10-11 05:17:27', '2026-10-11 05:17:27', NULL),
(208, 210, 1, '105104872', '105104872', 'SASHIKIRANA CHANTIKA BRILLIANT YUDA PUTRI', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_8yX9ovBg2w4RqUHc9AjI8x9b', 0, 'active', '2026-10-11 05:17:27', '2026-10-11 05:17:27', NULL),
(209, 211, 1, '108543228', '108543228', 'SASYA KUSUMA ADELIA', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_T8LQTpyeTCfzuSCQTuP53Z1o', 0, 'active', '2026-10-11 05:17:28', '2026-10-11 05:17:28', NULL),
(210, 212, 1, '101208576', '101208576', 'SEPTIA RESTI AZIZAH', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_z0xJxlXYTw2EphpYanrwAbCH', 0, 'active', '2026-10-11 05:17:28', '2026-10-11 05:17:28', NULL),
(211, 213, 1, '3109145144', '3109145144', 'SHABRINA NURUL MA\'RUFAH', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_XfpB9zGzf9smoG3gI8iVvIj1', 0, 'active', '2026-10-11 05:17:29', '2026-10-11 05:17:29', NULL),
(212, 214, 1, '104453456', '104453456', 'SHAKILA KHAFITRAH HARTANTO PUTRI', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_8Jg1BW2orYQomI1uPaL3xZ63', 0, 'active', '2026-10-11 05:17:29', '2026-10-11 05:17:29', NULL),
(213, 215, 1, '3111935820', '3111935820', 'SITI NURIYAH', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_vL00nhcbItDH6kZI6AhQThEs', 0, 'active', '2026-10-11 05:17:30', '2026-10-11 05:17:30', NULL),
(214, 216, 1, '3113689620', '3113689620', 'SUKAINAH FAKHRA AHMADA', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_CKA1sMHpTEcWWThbVOsDEySm', 0, 'active', '2026-10-11 05:17:31', '2026-10-11 05:17:31', NULL),
(215, 217, 1, '105107522', '105107522', 'SWANDARI SAFRIDA FIQIH ZULKARNAEN', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_W2psd3K06Y1oqo0DPDWV8aZ2', 0, 'active', '2026-10-11 05:17:31', '2026-10-11 05:17:31', NULL),
(216, 218, 1, '104854574', '104854574', 'SYAHDILLA MINHAJUL QASIDA', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_Ct2vsOfFTaUizQgNkfiLG9rl', 0, 'active', '2026-10-11 05:17:32', '2026-10-11 05:17:32', NULL),
(217, 219, 1, '113323386', '113323386', 'SYAKIRA QATRUNNADA', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_3hLvK1Drj3zahF3jaFQtWVoR', 0, 'active', '2026-10-11 05:17:32', '2026-10-11 05:17:32', NULL),
(218, 220, 1, '3111329460', '3111329460', 'TALITA SYAKIRA', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_yv5henXWwOvcwqF9qPQnjfdY', 0, 'active', '2026-10-11 05:17:33', '2026-10-11 05:17:33', NULL),
(219, 221, 1, '119909807', '119909807', 'TANTIKA RIDHA JULIENY', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_rQ37Th98hrhn6dDTomDSIl5u', 0, 'active', '2026-10-11 05:17:33', '2026-10-11 05:17:33', NULL),
(220, 222, 1, '3116241693', '3116241693', 'THREE HANA NUR A\'IDAH', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_gqMStLYrtM7qnRPXI27A2kwn', 0, 'active', '2026-10-11 05:17:34', '2026-10-11 05:17:34', NULL),
(221, 223, 1, '3095836530', '3095836530', 'TIARA TUNGGADEWI SAFITRI', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_MaimJ1NnEtRNM50q4oM2JgOV', 0, 'active', '2026-10-11 05:17:34', '2026-10-11 05:17:34', NULL),
(222, 224, 1, '3113195224', '3113195224', 'TSURAYAA SALSABILA MALIHAH', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_HqYsniX88hO3OaKH6L6IbzoM', 0, 'active', '2026-10-11 05:17:34', '2026-10-11 05:17:34', NULL),
(223, 225, 1, '3104326605', '3104326605', 'UMI LATIFATUL JANNAH', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_bci9QoMxUOyKuoHsETr1srvL', 0, 'active', '2026-10-11 05:17:35', '2026-10-11 05:17:35', NULL),
(224, 226, 1, '3108347445', '3108347445', 'VELIA AL AMIRA TUNGGAL DEWI', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_A166xmuB6bRXJ6VfXC5lZfMN', 0, 'active', '2026-10-11 05:17:35', '2026-10-11 05:17:35', NULL),
(225, 227, 1, '3115780014', '3115780014', 'WARDATUL KHUMAIRO\'', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_kZtzYuux6xRwPzkMFDSTF0B8', 0, 'active', '2026-10-11 05:17:36', '2026-10-11 05:17:36', NULL),
(226, 228, 1, '106652650', '106652650', 'ZALFANA SYIFA\'UNNISA', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_o6wsIvuhDCoRKCBb4e4qpmA7', 0, 'active', '2026-10-11 05:17:36', '2026-10-11 05:17:36', NULL),
(227, 229, 1, '3105939605', '3105939605', 'ZIDA NIAMI', 10, 'X-7', 'L', '2009-01-01', NULL, NULL, 'std_eq5yPt8DuZ2zexsIgpux2vkT', 0, 'active', '2026-10-11 05:17:37', '2026-10-11 05:17:37', NULL),
(228, 230, 1, '102283507', '102283507', 'RISMA KHOIRUNNISA\'', 10, 'X-7', 'P', '2009-01-01', NULL, NULL, 'std_OzpvG57ZlT1TdJ8MobJOeYX4', 0, 'active', '2026-10-11 05:17:37', '2026-10-11 05:17:37', NULL),
(229, 231, 1, '97461918', '97461918', 'BAYU DERMAWAN SAPUTRA', 11, 'XI MIPA 1', 'P', '2008-01-01', NULL, NULL, 'std_p5huSmCWzfNF4VxiG6XVWEmJ', 0, 'active', '2026-10-11 05:17:38', '2026-10-11 05:17:38', NULL),
(230, 232, 1, '3097729037', '3097729037', 'DANY FAYYADHY SANJAYA', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_5Toff0G3wAXEtQn6vvSiaKB2', 0, 'active', '2026-10-11 05:17:38', '2026-10-11 05:17:38', NULL),
(231, 233, 1, '3113884289', '3113884289', 'MOCH. KAFA AL-MAHMUDI', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_3HtrkLPeCrTVJpqQBGrgjVqw', 0, 'active', '2026-10-11 05:17:38', '2026-10-11 05:17:38', NULL),
(232, 234, 1, '88534089', '88534089', 'MOCH. PRAJA KERTANEGARA', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_k79VvQTEJQgY8bFMKvL63kgK', 0, 'active', '2026-10-11 05:17:39', '2026-10-11 05:17:39', NULL),
(233, 235, 1, '99448229', '99448229', 'MOCHAMAD FAHRIEL ARHAM ARROSYID', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_LBOaNJqOV1lkVWlxuV8r8mKa', 0, 'active', '2026-10-11 05:17:39', '2026-10-11 05:17:39', NULL),
(234, 236, 1, '3095525692', '3095525692', 'MOCHAMMAD IRHAM SYAUQI FIRDAUS', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_Jlm2qUrs0loLsfHaMq1QotSD', 0, 'active', '2026-10-11 05:17:39', '2026-10-11 05:17:39', NULL),
(235, 237, 1, '99496087', '99496087', 'MUHAMMAD AKBAR RAFASSYA', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_MHcwxBbRAjz9JGYpKbdZ87b1', 0, 'active', '2026-10-11 05:17:40', '2026-10-11 05:17:40', NULL),
(236, 238, 1, '108752403', '108752403', 'MUHAMMAD DZIHNUL MUSHOFFA', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_31RkLGadijmnvIjrEb52A2xZ', 0, 'active', '2026-10-11 05:17:40', '2026-10-11 05:17:40', NULL),
(237, 239, 1, '3097990771', '3097990771', 'MUHAMMAD FAATHIR MUZAKI', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_GsuBppQTX87L233LjZY4yo7B', 0, 'active', '2026-10-11 05:17:41', '2026-10-11 05:17:41', NULL),
(238, 240, 1, '106595598', '106595598', 'MUHAMMAD FAQIH RIYADI', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_yQu0V8303RuqPVPiNLd7Qh2i', 0, 'active', '2026-10-11 05:17:41', '2026-10-11 05:17:41', NULL),
(239, 241, 1, '3101047682', '3101047682', 'MUHAMMAD IQBAL ILHAMY', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_ZFnNDgTziDPshdURzFBA8N3l', 0, 'active', '2026-10-11 05:17:41', '2026-10-11 05:17:41', NULL),
(240, 242, 1, '3104273487', '3104273487', 'MUHAMMAD IQBAL MAULANA', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_6QGuasE7eoTLOBBd1H6vvbEc', 0, 'active', '2026-10-11 05:17:42', '2026-10-11 05:17:42', NULL),
(241, 243, 1, '103639269', '103639269', 'MUHAMMAD KHOIRUL ANAM', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_4h4VxtnNo2lSg0y7vbKKHuNm', 0, 'active', '2026-10-11 05:17:42', '2026-10-11 05:17:42', NULL),
(242, 244, 1, '3109702781', '3109702781', 'MUHAMMAD MAULAL IBAD', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_q4dzhdnHgGmK3TDaXdigTld3', 0, 'active', '2026-10-11 05:17:42', '2026-10-11 05:17:42', NULL),
(243, 245, 1, '3094681066', '3094681066', 'MUHAMMAD RAFI MAHARDHIKA', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_mGuy4a49wddvctyDyJKSezG7', 0, 'active', '2026-10-11 05:17:43', '2026-10-11 05:17:43', NULL),
(244, 246, 1, '3087191616', '3087191616', 'MUHAMMAD ZACKY AFKHAR', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_vGgo8Dge9RxWyE3irGnBCRlj', 0, 'active', '2026-10-11 05:17:43', '2026-10-11 05:17:43', NULL);
INSERT INTO `students` (`id`, `user_id`, `school_id`, `nis`, `nisn`, `full_name`, `grade_level`, `class_name`, `gender`, `birth_date`, `birth_place`, `phone_number`, `public_id`, `public_profile_enabled`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(245, 247, 1, '103558442', '103558442', 'NASHIF KHOIRUL MUNIR', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_BJayPPvwrGuwRWgCOO7IWCB2', 0, 'active', '2026-10-11 05:17:44', '2026-10-11 05:17:44', NULL),
(246, 248, 1, '108444053', '108444053', 'NIZAR RAISSA SUSILO', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_XNHwXfjVBXW8rwG3j6PI9Nss', 0, 'active', '2026-10-11 05:17:44', '2026-10-11 05:17:44', NULL),
(247, 249, 1, '91081149', '91081149', 'RONALD LANGIT RAMADHAN', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_M4UVB13q9EczDcE9IC4Y98M5', 0, 'active', '2026-10-11 05:17:44', '2026-10-11 05:17:44', NULL),
(248, 250, 1, '107033220', '107033220', 'SANCAKA CESARIUS TRI HARSONO', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_SMVFvtdgEmRtyMOCTIuykMmB', 0, 'active', '2026-10-11 05:17:45', '2026-10-11 05:17:45', NULL),
(249, 251, 1, '109849676', '109849676', 'THARYQH AYDIL MUFAQQIH BUBU', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_Oblld5S8zPGJhlDD6PRsbJXS', 0, 'active', '2026-10-11 05:17:45', '2026-10-11 05:17:45', NULL),
(250, 252, 1, '3105749757', '3105749757', 'VINO ALFIANO', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_r2Mumkg4pFaNFigYy1t1sDcv', 0, 'active', '2026-10-11 05:17:45', '2026-10-11 05:17:45', NULL),
(251, 253, 1, '96916169', '96916169', 'RAIHAN NANDITYA SYAWALIYANTO', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_OgK4ULgft1PjFxtC4TRMMVZV', 0, 'active', '2026-10-11 05:17:46', '2026-10-11 05:17:46', NULL),
(252, 254, 1, '106553039', '106553039', 'NAUFAL AHMAD ZHAFIR GHATHFAN', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_cjRgEOoGv9iB8v87XFRz942A', 0, 'active', '2026-10-11 05:17:46', '2026-10-11 05:17:46', NULL),
(253, 255, 1, '99159987', '99159987', 'ARKAN ALGHAZI', 11, 'XI MIPA 1', 'L', '2008-01-01', NULL, NULL, 'std_qpTgiLrkOcXIAyLMLCIBrv8c', 0, 'active', '2026-10-11 05:17:47', '2026-10-11 05:17:47', NULL),
(254, 256, 1, '96461964', '96461964', 'ADELIA SAVA AZ ZYDA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_TZiWrFx5PoQ6iZj1JG9fRQuv', 0, 'active', '2026-10-11 05:17:47', '2026-10-11 05:17:47', NULL),
(255, 257, 1, '3114187095', '3114187095', 'AIDA AZKA AULIA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_CjlHqZ1mZT6rsZSVNv4kH2Ax', 0, 'active', '2026-10-11 05:17:47', '2026-10-11 05:17:47', NULL),
(256, 258, 1, '3082350779', '3082350779', 'AIDA IRMA FIKRIYAH', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_SdelkFo4UQyCiTO5A8i7Le4O', 0, 'active', '2026-10-11 05:17:48', '2026-10-11 05:17:48', NULL),
(257, 259, 1, '94078850', '94078850', 'ALFI MUSYAFA\'AH WIJAYATRI', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_8Hkgd2Ss33Qc0FVxG6iIWenp', 0, 'active', '2026-10-11 05:17:48', '2026-10-11 05:17:48', NULL),
(258, 260, 1, '99366176', '99366176', 'ANAYA JANEETA GUSEVA PUTRI', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_ZQBiYeU3jIAYeR34yN9TX0ZF', 0, 'active', '2026-10-11 05:17:48', '2026-10-11 05:17:48', NULL),
(259, 261, 1, '87221908', '87221908', 'ANDINI KURNIA PERTIWI', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_DRxUpV0o1aCU2c0mZSv4fNkU', 0, 'active', '2026-10-11 05:17:49', '2026-10-11 05:17:49', NULL),
(260, 262, 1, '95399733', '95399733', 'ANNISA KHOLIFATUR ROSYIDAH', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_ICFSvCN8WfcAz6azzEl20hwr', 0, 'active', '2026-10-11 05:17:49', '2026-10-11 05:17:49', NULL),
(261, 263, 1, '3101331783', '3101331783', 'ASA AYYAKUN DARIS SALAMAH', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_kUevLZVshMg3OailY0rjqBtO', 0, 'active', '2026-10-11 05:17:49', '2026-10-11 05:17:49', NULL),
(262, 264, 1, '97125518', '97125518', 'AURA MAR\'ATUS SHOLIKHA', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_CmHsTuPreAqmQktoSwilCMoQ', 0, 'active', '2026-10-11 05:17:50', '2026-10-11 05:17:50', NULL),
(263, 265, 1, '96138438', '96138438', 'AZIZAH WIJI LESTARI', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_DIDDPXyi1TCW0B9ms7GTL3We', 0, 'active', '2026-10-11 05:17:50', '2026-10-11 05:17:50', NULL),
(264, 266, 1, '95626616', '95626616', 'DEWI MAUIZATUL GHILVANA', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_1uLbxVZM225bNrZRcFQWGdmo', 0, 'active', '2026-10-11 05:17:50', '2026-10-11 05:17:50', NULL),
(265, 267, 1, '63236155', '63236155', 'DEWI TUNJUNG ARUM', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_pAdsYXJZum42mCFdBOkwP5x4', 0, 'active', '2026-10-11 05:17:51', '2026-10-11 05:17:51', NULL),
(266, 268, 1, '94078628', '94078628', 'FENTI AULIA RAHMAWATI', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_uITqbV77KNVA6fCzqt63rlTP', 0, 'active', '2026-10-11 05:17:51', '2026-10-11 05:17:51', NULL),
(267, 269, 1, '94858270', '94858270', 'FITRIA NURIL AZKYA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_LSGzHglr2NJBysM1ny7HMPJ7', 0, 'active', '2026-10-11 05:17:51', '2026-10-11 05:17:51', NULL),
(268, 270, 1, '3106233713', '3106233713', 'HAFIZHAH LAILATIS SA\'ADAH', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_lS3hyWAFNreJUnJPzRsPrdqv', 0, 'active', '2026-10-11 05:17:52', '2026-10-11 05:17:52', NULL),
(269, 271, 1, '3107453080', '3107453080', 'HAFSHAH AMIRAH ARFAH', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_fxa50plghNcdWWaFx3mfi2hA', 0, 'active', '2026-10-11 05:17:52', '2026-10-11 05:17:52', NULL),
(270, 272, 1, '3089582930', '3089582930', 'INDRA ARIFATUL ITSNAINI', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_7gHD9Yb7ilf6mdQO3Zr5FXpD', 0, 'active', '2026-10-11 05:17:52', '2026-10-11 05:17:52', NULL),
(271, 273, 1, '3093940680', '3093940680', 'INTAN ROFANIATUL HIDAYAH', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_DiH9mX11eGYO4BDhPVHY5NBZ', 0, 'active', '2026-10-11 05:17:53', '2026-10-11 05:17:53', NULL),
(272, 274, 1, '97688547', '97688547', 'LESTARI LATINA NURJANNAH', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_O5mRsV7fcBPVfn8S2U4OEq2n', 0, 'active', '2026-10-11 05:17:53', '2026-10-11 05:17:53', NULL),
(273, 275, 1, '3107143784', '3107143784', 'MEIDA ANINDA PUTRI', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_3tkjIwEAzFHrP0wQF83rDXfH', 0, 'active', '2026-10-11 05:17:54', '2026-10-11 05:17:54', NULL),
(274, 276, 1, '3098643225', '3098643225', 'NABILA PUTRI SAUNA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_mK2fppic03s64i87fSXuUK0q', 0, 'active', '2026-10-11 05:17:54', '2026-10-11 05:17:54', NULL),
(275, 277, 1, '102647954', '102647954', 'NABILAH HAIBATUR ROIHANAH', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_Au35zMAvuEfZgUvOL6ADsUu8', 0, 'active', '2026-10-11 05:17:54', '2026-10-11 05:17:54', NULL),
(276, 278, 1, '93314675', '93314675', 'NADIAH MUTIAH RAHMAH', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_Pn8vWyhhExzMi7psDnS46D3N', 0, 'active', '2026-10-11 05:17:55', '2026-10-11 05:17:55', NULL),
(277, 279, 1, '3113687279', '3113687279', 'NAMIRA AULIA ZAHROH', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_vtnl00Zl2lf5mKW8yvpmBNZY', 0, 'active', '2026-10-11 05:17:55', '2026-10-11 05:17:55', NULL),
(278, 280, 1, '92545202', '92545202', 'NANAKUM MALASARI', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_pnS4qT0RBVO2FLPoYMsYAtFb', 0, 'active', '2026-10-11 05:17:56', '2026-10-11 05:17:56', NULL),
(279, 281, 1, '82079245', '82079245', 'NIYAZ SALMA AULIA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_0D2d6H13Ws0bb8HlaQGEKziE', 0, 'active', '2026-10-11 05:17:56', '2026-10-11 05:17:56', NULL),
(280, 282, 1, '108250259', '108250259', 'NOURO YASMIN FIELEILAH ANNAFISA', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_Pm9VQ1yxMOmnHkjE3poB6RFw', 0, 'active', '2026-10-11 05:17:56', '2026-10-11 05:17:56', NULL),
(281, 283, 1, '3100805928', '3100805928', 'NUR FAIZA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_UqQcFEKV88jnx5mOSw5Of7M6', 0, 'active', '2026-10-11 05:17:57', '2026-10-11 05:17:57', NULL),
(282, 284, 1, '3107533741', '3107533741', 'NUR MAZIDATUN NI\'MAH', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_uVJ51eWZ4TwUOcyq3GFzktDz', 0, 'active', '2026-10-11 05:17:57', '2026-10-11 05:17:57', NULL),
(283, 285, 1, '3090634002', '3090634002', 'RIZCHA SEKAR MARCELLIA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_5F6Hs8UX4DwMxFXf2dvrJ9sB', 0, 'active', '2026-10-11 05:17:57', '2026-10-11 05:17:57', NULL),
(284, 286, 1, '101254800', '101254800', 'SALMAH AL ATTAS', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_6DzyFBK3Qiohvi3e16lmVK2o', 0, 'active', '2026-10-11 05:17:58', '2026-10-11 05:17:58', NULL),
(285, 287, 1, '108068156', '108068156', 'SHOVWANICA PUTRI PRASETYO', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_WeYfbuVjUvkP0iy7H8E6YC3I', 0, 'active', '2026-10-11 05:17:58', '2026-10-11 05:17:58', NULL),
(286, 288, 1, '95236806', '95236806', 'SITI KUMALA MILLATA ROSADA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_Uoyd9teIFx5rU5dxHcL7ZbsA', 0, 'active', '2026-10-11 05:17:58', '2026-10-11 05:17:58', NULL),
(287, 289, 1, '105804614', '105804614', 'TSAMARA UFAIRAH ADZKA', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_qLgWe6ssCNMh76BTT8i3BJdx', 0, 'active', '2026-10-11 05:17:59', '2026-10-11 05:17:59', NULL),
(288, 290, 1, '105884491', '105884491', 'WAFA ZAHROTUN KAMILAH', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_0pLPGbZKhty3EWXXUvhBAa3R', 0, 'active', '2026-10-11 05:17:59', '2026-10-11 05:17:59', NULL),
(289, 291, 1, '109104689', '109104689', 'YUDHITA ZULFANA', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_ImmYg3XjRiu21nhdGXBEiuTE', 0, 'active', '2026-10-11 05:17:59', '2026-10-11 05:17:59', NULL),
(290, 292, 1, '103443493', '103443493', 'ZAHWA AZZAH AMALIA', 11, 'XI MIPA 2', 'P', '2008-01-01', NULL, NULL, 'std_ruOjbSbzrCkwt2RQ5IqSHC50', 0, 'active', '2026-10-11 05:18:00', '2026-10-11 05:18:00', NULL),
(291, 293, 1, '91042510', '91042510', 'ELLIYANA ROSHIDAH TAUFIQ', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_KKz1XThQCzMZ74rzpgBixjsS', 0, 'active', '2026-10-11 05:18:00', '2026-10-11 05:18:00', NULL),
(292, 294, 1, '3092931898', '3092931898', 'STACY AURORA LATANZA', 11, 'XI MIPA 2', 'L', '2008-01-01', NULL, NULL, 'std_BXx5DtbmrjPQWDbGkdhjHT41', 0, 'active', '2026-10-11 05:18:01', '2026-10-11 05:18:01', NULL),
(293, 295, 1, '3104897692', '3104897692', 'ACHMAD FAYZ RAYAN AFRI CEZA.MD', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_Q2QyTPlQWlOzKn3Zr3glznBh', 0, 'active', '2026-10-11 05:18:01', '2026-10-11 05:18:01', NULL),
(294, 296, 1, '3106313215', '3106313215', 'ACHMAD YANUAR REZHA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_zLlhMe1uPKHzr8jRiTbXz7TB', 0, 'active', '2026-10-11 05:18:01', '2026-10-11 05:18:01', NULL),
(295, 297, 1, '3092050377', '3092050377', 'ADAM XAVIER NIBROOS AL-HUDA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_av6cnOV4Vap13ZMOZqnjCySW', 0, 'active', '2026-10-11 05:18:02', '2026-10-11 05:18:02', NULL),
(296, 298, 1, '91305902', '91305902', 'AHMAD MUTHOHAR SANUSI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_eDJQOUYkEhDCU0NUsFRDoaSy', 0, 'active', '2026-10-11 05:18:02', '2026-10-11 05:18:02', NULL),
(297, 299, 1, '97130420', '97130420', 'ALIF ZAIDAN MAULANA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_jmWrGpJiJSxrR32vjKl1HdQY', 0, 'active', '2026-10-11 05:18:03', '2026-10-11 05:18:03', NULL),
(298, 300, 1, '108878143', '108878143', 'ARIF MANUNGGAL PUTRA AL-KHOIRUL', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_OHmvdELmljRPQdo5HXbYSEjC', 0, 'active', '2026-10-11 05:18:03', '2026-10-11 05:18:03', NULL),
(299, 301, 1, '92490221', '92490221', 'DAFFA MIFZAL ROMADHAN', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_hXPsXIllGPMuMesmokk3Zra4', 0, 'active', '2026-10-11 05:18:04', '2026-10-11 05:18:04', NULL),
(300, 302, 1, '98339628', '98339628', 'DAFFA RHEYHAN MUSYAFFA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_JeDza3sFnWQl3yA5SMZQxVO4', 0, 'active', '2026-10-11 05:18:05', '2026-10-11 05:18:05', NULL),
(301, 303, 1, '3107340470', '3107340470', 'DZAKY SYARIF MUHAMMAD', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_6v7ly3L9VRpczW5tKJ68VRpr', 0, 'active', '2026-10-11 05:18:05', '2026-10-11 05:18:05', NULL),
(302, 304, 1, '3101758417', '3101758417', 'FADIL MUKTI JUNIAR', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_eQaWO3CqUX7GEGGGifLqtYiy', 0, 'active', '2026-10-11 05:18:05', '2026-10-11 05:18:05', NULL),
(303, 305, 1, '94176108', '94176108', 'FIKRAM BAIHAQI ZUKRILLAH', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_n3vTof3RtcOXsKiDlHe4cPTL', 0, 'active', '2026-10-11 05:18:06', '2026-10-11 05:18:06', NULL),
(304, 306, 1, '3103944475', '3103944475', 'GHIYAS SABIQ AL FATHIN', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_Sa7Np473W6HW7leZrST3cgYK', 0, 'active', '2026-10-11 05:18:06', '2026-10-11 05:18:06', NULL),
(305, 307, 1, '95311016', '95311016', 'HAMDAN ISMA\'IL', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_lQDtFSuEN3glwJ5hePDsg2c8', 0, 'active', '2026-10-11 05:18:06', '2026-10-11 05:18:06', NULL),
(306, 308, 1, '105391736', '105391736', 'IRSYADUL IBAD', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_iI2e1r3Ogc221V9jLYzjhVkM', 0, 'active', '2026-10-11 05:18:07', '2026-10-11 05:18:07', NULL),
(307, 309, 1, '94139149', '94139149', 'JOAN AFLAH MAHSUNI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_K1wv1AdS5rNNF07VDOlcauMb', 0, 'active', '2026-10-11 05:18:07', '2026-10-11 05:18:07', NULL),
(308, 310, 1, '3089745635', '3089745635', 'JUNDI DHIYAUL HAQ AL HAMDANI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_73TQSNozs7ZQyiHOnSdcbR7I', 0, 'active', '2026-10-11 05:18:08', '2026-10-11 05:18:08', NULL),
(309, 311, 1, '105676601', '105676601', 'M. ZUHRO SYIFA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_X2Zh1g62OQGVkP5wToQfMCLB', 0, 'active', '2026-10-11 05:18:08', '2026-10-11 05:18:08', NULL),
(310, 312, 1, '3096648345', '3096648345', 'MAULANA DZAKY AL-BUSTHOMI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_skweSg4vPhY2SSN6kQZwMrnf', 0, 'active', '2026-10-11 05:18:08', '2026-10-11 05:18:08', NULL),
(311, 313, 1, '89841280', '89841280', 'MOHAMMAD TORIQ', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_K7DxAhj2yPypATSgfFqKjWX7', 0, 'active', '2026-10-11 05:18:09', '2026-10-11 05:18:09', NULL),
(312, 314, 1, '103290823', '103290823', 'MUHAMAD ABBY AUSHAF AL GHIFARI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_t0qQi8VNitciUGSSainx8Q9c', 0, 'active', '2026-10-11 05:18:09', '2026-10-11 05:18:09', NULL),
(313, 315, 1, '3109788579', '3109788579', 'MUHAMMAD ABID ALFERO', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_018l3cJq929BWVu5JHlxairo', 0, 'active', '2026-10-11 05:18:10', '2026-10-11 05:18:10', NULL),
(314, 316, 1, '3096195102', '3096195102', 'MUHAMMAD AL-FAREZI UBAIDILLAH', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_Kyt3L6ncqTxqkoQcNsWN0PMC', 0, 'active', '2026-10-11 05:18:10', '2026-10-11 05:18:10', NULL),
(315, 317, 1, '107234496', '107234496', 'MUHAMMAD ALTHIF ABIR HYAA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_9wklzDDUGQXZDwwJeWkSBA2I', 0, 'active', '2026-10-11 05:18:10', '2026-10-11 05:18:10', NULL),
(316, 318, 1, '105014967', '105014967', 'MUHAMMAD AQIL FAHMI IRCHAM', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_240uZuicW5csD7BXyEOPTiaC', 0, 'active', '2026-10-11 05:18:11', '2026-10-11 05:18:11', NULL),
(317, 319, 1, '3092235034', '3092235034', 'MUHAMMAD AUFAR ATSIRUDDIN', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_GTwsuPWXhdhP1MgtNvUXNDaz', 0, 'active', '2026-10-11 05:18:11', '2026-10-11 05:18:11', NULL),
(318, 320, 1, '3091394103', '3091394103', 'MUHAMMAD DANIEL AL FIKRI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_2OkD5tTO138zF3NZlMfTnlqc', 0, 'active', '2026-10-11 05:18:11', '2026-10-11 05:18:11', NULL),
(319, 321, 1, '93364165', '93364165', 'MUHAMMAD FAHRI ROBBAANI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_wtnC4wA4qr3osOO93ixE0FUB', 0, 'active', '2026-10-11 05:18:12', '2026-10-11 05:18:12', NULL),
(320, 322, 1, '3098405606', '3098405606', 'MUHAMMAD MAULIDDANI MARVELLINO', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_sIlg79qTugYKXTDfpjQbNp5Z', 0, 'active', '2026-10-11 05:18:12', '2026-10-11 05:18:12', NULL),
(321, 323, 1, '3103340701', '3103340701', 'MUHAMMAD RAFI NAJATI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_M0HpMT7ZHI90hawyjTW9otvs', 0, 'active', '2026-10-11 05:18:13', '2026-10-11 05:18:13', NULL),
(322, 324, 1, '96502286', '96502286', 'MUHAMMAD RAFLI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_iBruxXLIODnxm0Cb5z0DCyka', 0, 'active', '2026-10-11 05:18:13', '2026-10-11 05:18:13', NULL),
(323, 325, 1, '3102356463', '3102356463', 'MUHAMMAD RAIHAN HARIST SANDI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_saDy3xEmI6WBwVfF0VoWcHZQ', 0, 'active', '2026-10-11 05:18:13', '2026-10-11 05:18:13', NULL),
(324, 326, 1, '91461882', '91461882', 'MUHAMMAD RIDHO BAYU SATRIA', 11, 'XI IPS 1', 'P', '2008-01-01', NULL, NULL, 'std_klA9X85jrjMwCRYaIkB8Cpfu', 0, 'active', '2026-10-11 05:18:14', '2026-10-11 05:18:14', NULL),
(325, 327, 1, '3107544384', '3107544384', 'QIWAMUL KHAFI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_yUgQ7cMSO7VtbrRgiGifIj3P', 0, 'active', '2026-10-11 05:18:14', '2026-10-11 05:18:14', NULL),
(326, 328, 1, '98194912', '98194912', 'RAFI PUTRA IBRAHIM', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_R4jddmui2yYhCxZow8vJ54Zp', 0, 'active', '2026-10-11 05:18:14', '2026-10-11 05:18:14', NULL),
(327, 329, 1, '98280835', '98280835', 'REZZA MAULANA NUR RIDWAN', 11, 'XI IPS 1', 'P', '2008-01-01', NULL, NULL, 'std_0u88yqlbzGajYPGqvfL5J1aJ', 0, 'active', '2026-10-11 05:18:15', '2026-10-11 05:18:15', NULL),
(328, 330, 1, '109955821', '109955821', 'ROYYAN ABDULLAH ZUHAIR', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_yHvF4lUHvATBUgGuQjh9lz8B', 0, 'active', '2026-10-11 05:18:16', '2026-10-11 05:18:16', NULL),
(329, 331, 1, '102477677', '102477677', 'SA\' DAN AQIIL', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_xIv0dMABVoSNtXOsl5w1VPAX', 0, 'active', '2026-10-11 05:18:16', '2026-10-11 05:18:16', NULL),
(330, 332, 1, '97613680', '97613680', 'MUHAMMAD HAMDAN BAHAUDDIN', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_x1VIvZKfbaOgkOuKy76KHa6v', 0, 'active', '2026-10-11 05:18:17', '2026-10-11 05:18:17', NULL),
(331, 333, 1, '107641506', '107641506', 'JAVIER AHMAD AR RAMDHANI', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_KvLULhIn1BMCJuo6I9wy5iRT', 0, 'active', '2026-10-11 05:18:18', '2026-10-11 05:18:18', NULL),
(332, 334, 1, '3092592729', '3092592729', 'YONKI AZHEEMA SUARNO PUTERA', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_xyXukDGuaBXZMLG8RyXeEQnZ', 0, 'active', '2026-10-11 05:18:18', '2026-10-11 05:18:18', NULL),
(333, 335, 1, '108255209', '108255209', 'MUCHAMMAD FAKHRI HAMZAH', 11, 'XI IPS 1', 'L', '2008-01-01', NULL, NULL, 'std_wb4nkTzVChr6ST9GRjiqccYH', 0, 'active', '2026-10-11 05:18:19', '2026-10-11 05:18:19', NULL),
(334, 336, 1, '106717034', '106717034', 'BINTANG PRAMUDHIA PURNOMO', 11, 'XI IPS 1', 'P', '2008-01-01', NULL, NULL, 'std_s2Ijn6QEhNIlXhksN0sztXzv', 0, 'active', '2026-10-11 05:18:19', '2026-10-11 05:18:19', NULL),
(335, 337, 1, '3099457560', '3099457560', 'A IMMATUL KHOIRIYAH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_aet6h1QRaas6jB6qqizBDvYe', 0, 'active', '2026-10-11 05:18:20', '2026-10-11 05:18:20', NULL),
(336, 338, 1, '3096202977', '3096202977', 'AGHISNI NADHRA HAKIM', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_q21TEwR8LJw7hH6vrz2Ha22H', 0, 'active', '2026-10-11 05:18:20', '2026-10-11 05:18:20', NULL),
(337, 339, 1, '3107795075', '3107795075', 'AINURROHMAH FARAH AULIA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_61DpjYlQwlWBAvkErRSzUJx1', 0, 'active', '2026-10-11 05:18:21', '2026-10-11 05:18:21', NULL),
(338, 340, 1, '3105173291', '3105173291', 'AISYY ALVI FAKHRANI', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_rXws7r58gwRGyP6DPt1tShjv', 0, 'active', '2026-10-11 05:18:21', '2026-10-11 05:18:21', NULL),
(339, 341, 1, '93085631', '93085631', 'ALISA KIRANI SAFITRI', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_EaPROOyoGGQg18RgkiNaEMEF', 0, 'active', '2026-10-11 05:18:22', '2026-10-11 05:18:22', NULL),
(340, 342, 1, '103500075', '103500075', 'ANINDYA NASHIFA PUTRI SOLIKHA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_UxYnMckWNPik9XhkpLYfnk0v', 0, 'active', '2026-10-11 05:18:22', '2026-10-11 05:18:22', NULL),
(341, 343, 1, '101088762', '101088762', 'AQILA LATHIFATUN NISA\'', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_7unfxk4BDkPeCXhswPg83rUT', 0, 'active', '2026-10-11 05:18:22', '2026-10-11 05:18:22', NULL),
(342, 344, 1, '98362634', '98362634', 'ARINA RAHMA TANAZILA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_UtxNsA5LybLy4PjJgNzZjKue', 0, 'active', '2026-10-11 05:18:23', '2026-10-11 05:18:23', NULL),
(343, 345, 1, '3102975407', '3102975407', 'BALQUES SELMA AL KHUMAIROH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_ICf1jhJKwN4jszEV34N169Xe', 0, 'active', '2026-10-11 05:18:24', '2026-10-11 05:18:24', NULL),
(344, 346, 1, '97395918', '97395918', 'BARBY ANGEL WIDI OKTA PRATAMA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_wF1Hkww5DM145pO8EXvvYkqG', 0, 'active', '2026-10-11 05:18:24', '2026-10-11 05:18:24', NULL),
(345, 347, 1, '91821117', '91821117', 'CAHAYA PUTRI TAHTA ZANZABILA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_z1TUgEhp32JOH3dqK4oAKgt9', 0, 'active', '2026-10-11 05:18:24', '2026-10-11 05:18:24', NULL),
(346, 348, 1, '93110905', '93110905', 'CAMILA NUR INAYAH', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_DOdwKMTDLVBdmSNH2de6zZIP', 0, 'active', '2026-10-11 05:18:25', '2026-10-11 05:18:25', NULL),
(347, 349, 1, '3100346273', '3100346273', 'CINDY ARIMBI SELLA RAMADHANI', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_Hfj8fOnroThoAQOIAbxUlQaF', 0, 'active', '2026-10-11 05:18:25', '2026-10-11 05:18:25', NULL),
(348, 350, 1, '102159682', '102159682', 'DANIA ATHIYA ZAHRA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_YepulLjF56rlcxxAAdK25xlT', 0, 'active', '2026-10-11 05:18:26', '2026-10-11 05:18:26', NULL),
(349, 351, 1, '3102886104', '3102886104', 'FAATIMATUZZAHROH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_s6YrNZW0QzhA6qR8TdmuZnAS', 0, 'active', '2026-10-11 05:18:27', '2026-10-11 05:18:27', NULL),
(350, 352, 1, '3092546066', '3092546066', 'FAIRUZ KHANZA WAHYUANA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_zqrfIhA7XdgNvfX0SkHlBhdw', 0, 'active', '2026-10-11 05:18:27', '2026-10-11 05:18:27', NULL),
(351, 353, 1, '3090854504', '3090854504', 'FARIHATUS SHOBAH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_HTyFZiHEnTebDVhVn1eLypdy', 0, 'active', '2026-10-11 05:18:27', '2026-10-11 05:18:27', NULL),
(352, 354, 1, '97133915', '97133915', 'FITHROTIN NUHA UMMU AUFA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_YhDOgeVH4sA47CdGMl30JDyZ', 0, 'active', '2026-10-11 05:18:28', '2026-10-11 05:18:28', NULL),
(353, 355, 1, '91234867', '91234867', 'FLORISTA ECHA KIRANA PUTRI', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_RyF1gTcPpOtkXDxVinrJa35y', 0, 'active', '2026-10-11 05:18:28', '2026-10-11 05:18:28', NULL),
(354, 356, 1, '101103560', '101103560', 'HANNY HALONA SELENA NADINE', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_R6vLTDcu7tve9EB6L8u524dF', 0, 'active', '2026-10-11 05:18:29', '2026-10-11 05:18:29', NULL),
(355, 357, 1, '3096880561', '3096880561', 'HILYATUN NAFISAH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_YTA7MWMHH7PKucbSf1fgKdsA', 0, 'active', '2026-10-11 05:18:29', '2026-10-11 05:18:29', NULL),
(356, 358, 1, '3102339218', '3102339218', 'JIHAN ZUHROTUS SYAHIROH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_VuOrYKvyqSQCUXYjOFjnHYtn', 0, 'active', '2026-10-11 05:18:29', '2026-10-11 05:18:29', NULL),
(357, 359, 1, '97418228', '97418228', 'JOVITA ELYSIA DAHAYU', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_vYW5oManjvgdjGtNrwnP7pZz', 0, 'active', '2026-10-11 05:18:30', '2026-10-11 05:18:30', NULL),
(358, 360, 1, '108126168', '108126168', 'JULFA NURBAITI', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_qPuS9V6yL0mdXTbPZzxW6TQ3', 0, 'active', '2026-10-11 05:18:30', '2026-10-11 05:18:30', NULL),
(359, 361, 1, '108180371', '108180371', 'KARIN ADZKA ISFAHANY', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_x2E3LkOeyIxlIpZ0vFUHTVXQ', 0, 'active', '2026-10-11 05:18:31', '2026-10-11 05:18:31', NULL),
(360, 362, 1, '3103148723', '3103148723', 'KHANSA HANIYAH NAJLA AL-NURI', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_86cRVW7gwZjSwxbqLGr086Zr', 0, 'active', '2026-10-11 05:18:31', '2026-10-11 05:18:31', NULL),
(361, 363, 1, '3096740342', '3096740342', 'KHOFIFAH NUR SALIM', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_H0y3TVtI7IYInFpe1QlKLGtH', 0, 'active', '2026-10-11 05:18:31', '2026-10-11 05:18:31', NULL),
(362, 364, 1, '3104037969', '3104037969', 'MAULAN MAHA RANI', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_LdDHPpZ20nGLVRiwO0w3v5JQ', 0, 'active', '2026-10-11 05:18:32', '2026-10-11 05:18:32', NULL),
(363, 365, 1, '106862928', '106862928', 'MEIFTAHUL VANIA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_tuHqoKNxCckn6cGVwywUIOTp', 0, 'active', '2026-10-11 05:18:32', '2026-10-11 05:18:32', NULL),
(364, 366, 1, '3107675590', '3107675590', 'NABILA SALSA RIHLATUS ZAHRO', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_NY2ZtQf4zUTykwgs8wEgsmM8', 0, 'active', '2026-10-11 05:18:33', '2026-10-11 05:18:33', NULL),
(365, 367, 1, '3092982220', '3092982220', 'NADHIFA AULIA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_rGtPbV6RtgDQOexkP74761Xa', 0, 'active', '2026-10-11 05:18:33', '2026-10-11 05:18:33', NULL),
(366, 368, 1, '3107860093', '3107860093', 'NAJWA LAILIA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_AtAQVJ8caUtv8x6sJQwlTglf', 0, 'active', '2026-10-11 05:18:34', '2026-10-11 05:18:34', NULL),
(367, 369, 1, '95641482', '95641482', 'NAJWA SALSABILA ARDIANTY', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_ZZUHfHbmVUZ9M4QjpMrWawh2', 0, 'active', '2026-10-11 05:18:34', '2026-10-11 05:18:34', NULL),
(368, 370, 1, '103189900', '103189900', 'NAURA PUTRI FIRDIANITA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_izdrw6kHCnS1XHJ4jijvvIrB', 0, 'active', '2026-10-11 05:18:35', '2026-10-11 05:18:35', NULL),
(369, 371, 1, '3093444121', '3093444121', 'NAZLA AZZAHROTUL AULIYA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_tLIyTG2j3LTRLjRlvcD8Tuzl', 0, 'active', '2026-10-11 05:18:36', '2026-10-11 05:18:36', NULL),
(370, 372, 1, '3098951442', '3098951442', 'RAHMA TRI RAHAYU', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_z1PjRvJVFbrsoRNt71OG0mxo', 0, 'active', '2026-10-11 05:18:36', '2026-10-11 05:18:36', NULL),
(371, 373, 1, '95799983', '95799983', 'RAISYA DWI FAJRIA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_eyWQr4WFfUwGJ2Q2jpsIk43M', 0, 'active', '2026-10-11 05:18:37', '2026-10-11 05:18:37', NULL),
(372, 374, 1, '3107050917', '3107050917', 'SALSABILA NOVITA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_WX03ifzoWy3aHysIwkI8jEjY', 0, 'active', '2026-10-11 05:18:37', '2026-10-11 05:18:37', NULL),
(373, 375, 1, '3101185370', '3101185370', 'SALWA KAMILAH SHOLEH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_Y2O8kIs2hWN3vSVojehwuDHI', 0, 'active', '2026-10-11 05:18:38', '2026-10-11 05:18:38', NULL),
(374, 376, 1, '96168167', '96168167', 'SINDY AULIYA ARIADI', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_M9o0ELSXfHnIuxRbUmcQuNBl', 0, 'active', '2026-10-11 05:18:38', '2026-10-11 05:18:38', NULL),
(375, 377, 1, '3094965806', '3094965806', 'SU\'UDIYAH AYU RIZQIA', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_9xv1Fs6sKlz0UPnV2JEQyIC2', 0, 'active', '2026-10-11 05:18:39', '2026-10-11 05:18:39', NULL),
(376, 378, 1, '3092016550', '3092016550', 'SYAVA ADI NUR', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_er65CGq4o8b3AR9VDpTuaXEK', 0, 'active', '2026-10-11 05:18:39', '2026-10-11 05:18:39', NULL),
(377, 379, 1, '96575392', '96575392', 'SYIFA PUTRI RAHMADANI', 11, 'XI IPS 2', 'P', '2008-01-01', NULL, NULL, 'std_rFlSZZZGzUxSfRw7OPCSOAJa', 0, 'active', '2026-10-11 05:18:40', '2026-10-11 05:18:40', NULL),
(378, 380, 1, '107231379', '107231379', 'THIFFANY ZUHROTUL AMALIYYAH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_8TIFOPs0anUh6YqDgl2JLKso', 0, 'active', '2026-10-11 05:18:40', '2026-10-11 05:18:40', NULL),
(379, 381, 1, '3091371351', '3091371351', 'YASMIN NADZIFAH MAULIDIYAH', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_zXL76AVW2TJI5v9SJLb43W7B', 0, 'active', '2026-10-11 05:18:41', '2026-10-11 05:18:41', NULL),
(380, 382, 1, '91240643', '91240643', 'ZAYYINA MAHYA BIFAZILATIL FITRIA', 11, 'XI IPS 2', 'L', '2008-01-01', NULL, NULL, 'std_9ZJnxIwQsTPezxZXfpD6R5xU', 0, 'active', '2026-10-11 05:18:41', '2026-10-11 05:18:41', NULL),
(381, 383, 1, '97694081', '97694081', 'ABDAN GHOYAYA', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_sp2ea4JmAdNLWbmVAKb7rVKh', 0, 'active', '2026-10-11 05:18:41', '2026-10-11 05:18:41', NULL),
(382, 384, 1, '3092605176', '3092605176', 'ALFIAN MUHAMMAD ALFATIH', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_2KmSDXdUo2HfqAETgDO3AYKi', 0, 'active', '2026-10-11 05:18:42', '2026-10-11 05:18:42', NULL),
(383, 385, 1, '107202405', '107202405', 'MUHAMMAD HAFIDZ JAMALUL MUSTHOFA', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_XR9318MIxNHLu6kmpFoANzEi', 0, 'active', '2026-10-11 05:18:42', '2026-10-11 05:18:42', NULL),
(384, 386, 1, '3097998063', '3097998063', 'M. IDHAM AL ADHAWI', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_Scd5XQuDaruCExj9TcoTwe5V', 0, 'active', '2026-10-11 05:18:43', '2026-10-11 05:18:43', NULL),
(385, 387, 1, '3095325490', '3095325490', 'MOCH. ARROYYAN FIKRI NAZARI', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_F3IfeLEGNyU8m54TD8NmNYIu', 0, 'active', '2026-10-11 05:18:43', '2026-10-11 05:18:43', NULL),
(386, 388, 1, '3084947869', '3084947869', 'MUHAMAD FAQIHAN TIRTADINALA', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_ZgkAe50fXMan0PYgUihNwFCf', 0, 'active', '2026-10-11 05:18:44', '2026-10-11 05:18:44', NULL),
(387, 389, 1, '102253963', '102253963', 'MUHAMMAD ADITYA NUGRAHA', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_dVwjCe4fC37fJhpMJa9Zk13D', 0, 'active', '2026-10-11 05:18:44', '2026-10-11 05:18:44', NULL),
(388, 390, 1, '92242208', '92242208', 'MUHAMMAD ATTARSYAH', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_8tRF1c4V9OSETfIvLpyCswIt', 0, 'active', '2026-10-11 05:18:44', '2026-10-11 05:18:44', NULL),
(389, 391, 1, '99491668', '99491668', 'MUHAMMAD DZULKARNAIN', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_t43htQx0hWSgQbqAALMOiRVU', 0, 'active', '2026-10-11 05:18:45', '2026-10-11 05:18:45', NULL),
(390, 392, 1, '102435070', '102435070', 'NAUFAL AWWALUL AZMI', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_vGSIsv7G6LXBs9C1RU5yvlmi', 0, 'active', '2026-10-11 05:18:45', '2026-10-11 05:18:45', NULL),
(391, 393, 1, '87398701', '87398701', 'FAHAD ABDUL JALIL SUPADI', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_RjPoLXJd8D9qlFZ5BjfgwVkA', 0, 'active', '2026-10-11 05:18:46', '2026-10-11 05:18:46', NULL),
(392, 394, 1, '3078740928', '3078740928', 'WAHYU IBTA ADITYA', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_lAgxLvZ5rhO9dePtw8Tqe11V', 0, 'active', '2026-10-11 05:18:46', '2026-10-11 05:18:46', NULL),
(393, 395, 1, '3078277898', '3078277898', 'AHMAD MUHAJIR AL-GHIFARI', 11, 'XI Bahasa 1', 'L', '2008-01-01', NULL, NULL, 'std_s4HqtVXnfuLZ0ZLi9YaSlSvi', 0, 'active', '2026-10-11 05:18:46', '2026-10-11 05:18:46', NULL),
(394, 396, 1, '3100141927', '3100141927', 'AMRINA ROSYADA RAHMANIA Z', 11, 'XI Bahasa 2', 'P', '2008-01-01', NULL, NULL, 'std_sdFeuFK5aAqwfBgHy4NO0qCB', 0, 'active', '2026-10-11 05:18:47', '2026-10-11 05:18:47', NULL),
(395, 397, 1, '3102971691', '3102971691', 'NAZILLAH RAHMANIA PUTRI', 11, 'XI Bahasa 2', 'P', '2008-01-01', NULL, NULL, 'std_YzrjtpK5XLra6gtzVHle5da1', 0, 'active', '2026-10-11 05:18:47', '2026-10-11 05:18:47', NULL),
(396, 398, 1, '106414600', '106414600', 'QUEENZA MUMAYYIZAH', 11, 'XI Bahasa 2', 'L', '2008-01-01', NULL, NULL, 'std_YWSTP4memVFlr9VEP7JAq9SB', 0, 'active', '2026-10-11 05:18:47', '2026-10-11 05:18:47', NULL),
(397, 399, 1, '3092642359', '3092642359', 'ZHULFA NABILLA ULYA', 11, 'XI Bahasa 2', 'L', '2008-01-01', NULL, NULL, 'std_1oFUGEZ5ndwdi9B69RRFIY22', 0, 'active', '2026-10-11 05:18:48', '2026-10-11 05:18:48', NULL),
(398, 400, 1, '97426729', '97426729', 'ZINNIA SHERENE AQUILA', 11, 'XI Bahasa 2', 'L', '2008-01-01', NULL, NULL, 'std_6VBtEToFpIQPgsSJm4EKDfGM', 0, 'active', '2026-10-11 05:18:48', '2026-10-11 05:18:48', NULL),
(399, 401, 1, '93418200', '93418200', 'YESITA NOVELIA RENITA PUTRI', 11, 'XI Bahasa 2', 'P', '2008-01-01', NULL, NULL, 'std_5CkG4b7rTkZ925v23GJdkNmC', 0, 'active', '2026-10-11 05:18:48', '2026-10-11 05:18:48', NULL),
(400, 402, 1, '82867496', '82867496', 'SARAH KHADIJAH AL KUBRO', 11, 'XI Bahasa 2', 'L', '2008-01-01', NULL, NULL, 'std_cSOcBeu4BrYRW8B6hcvQB58x', 0, 'active', '2026-10-11 05:18:49', '2026-10-11 05:18:49', NULL),
(401, 403, 1, '98693294', '98693294', 'ACHMAD RAFI AR -ROCHMAN', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_ysUx5rwtO0qFHPUXT14vdTCn', 0, 'active', '2026-10-11 05:18:49', '2026-10-11 05:18:49', NULL),
(402, 404, 1, '3089497619', '3089497619', 'AFGAN SALAFI\' MAULANA AL HUSNIN', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_EIpUCHpiyiMA0WwWzfYxWcBo', 0, 'active', '2026-10-11 05:18:49', '2026-10-11 05:18:49', NULL),
(403, 405, 1, '107838392', '107838392', 'AHMAD ASIF BUKHIYA', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_wrO1JAcjChB1spkNKHVtzB2V', 0, 'active', '2026-10-11 05:18:50', '2026-10-11 05:18:50', NULL),
(404, 406, 1, '109131930', '109131930', 'AHMAD DURMUJI ARIF', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_6FhadXtXRsPYKhXxsBfNQ9Y6', 0, 'active', '2026-10-11 05:18:50', '2026-10-11 05:18:50', NULL),
(405, 407, 1, '3094706387', '3094706387', 'AHMED ATHAR NUR YUDISTIRA', 11, 'XI AGAMA 1', 'P', '2008-01-01', NULL, NULL, 'std_85Pqks1KshvZ3zpD1coQRK6G', 0, 'active', '2026-10-11 05:18:51', '2026-10-11 05:18:51', NULL),
(406, 408, 1, '3096591166', '3096591166', 'AZKA ATHIAH PERDANA SUHARIYANTO', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_C6kycNjElytLZq3SDWyRJpzt', 0, 'active', '2026-10-11 05:18:51', '2026-10-11 05:18:51', NULL),
(407, 409, 1, '95696059', '95696059', 'M. FAQIH ASYHARI', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_OJy6Wm1fZVelcDH7S16oAA9E', 0, 'active', '2026-10-11 05:18:51', '2026-10-11 05:18:51', NULL),
(408, 410, 1, '107989474', '107989474', 'MOCH. KAAFI NAFIL ARZAQI', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_vV6NWP57eUB7j8cmhaXWWyVE', 0, 'active', '2026-10-11 05:18:52', '2026-10-11 05:18:52', NULL),
(409, 411, 1, '3103747218', '3103747218', 'MUHAMMAD AQIL RAHMAN', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_exfrGDpU90MaYeCakr1B6uz8', 0, 'active', '2026-10-11 05:18:52', '2026-10-11 05:18:52', NULL),
(410, 412, 1, '97275136', '97275136', 'MUHAMMAD HILAL SYA\'BAN MIFTAHUDDIN', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_ljAvJHWK8TDScIUSqZG17Z1D', 0, 'active', '2026-10-11 05:18:52', '2026-10-11 05:18:52', NULL),
(411, 413, 1, '3080305992', '3080305992', 'MUHAMMAD HUBBI SYAUQI', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_KVhkULT2QeWhWEhD4lPcuzkj', 0, 'active', '2026-10-11 05:18:53', '2026-10-11 05:18:53', NULL),
(412, 414, 1, '3108188513', '3108188513', 'MUHAMMAD ZIDA LUFTAN NAFIQ', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_Air99TOOm5Bi2JvE9HErNnWV', 0, 'active', '2026-10-11 05:18:53', '2026-10-11 05:18:53', NULL),
(413, 415, 1, '3095980925', '3095980925', 'MUHAMMAD ZIYAD AFKARUL HIKAM', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_I8y6kQHHxEZ2hKkdJookkg9F', 0, 'active', '2026-10-11 05:18:54', '2026-10-11 05:18:54', NULL),
(414, 416, 1, '3108613550', '3108613550', 'NEHRU MANDALA HAMKA', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_vIOp2ToCvVVy4PNGbkEh3edY', 0, 'active', '2026-10-11 05:18:54', '2026-10-11 05:18:54', NULL),
(415, 417, 1, '3107258712', '3107258712', 'RAFIE KENAN YONINDA PUTRA', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_vWBfj7UYGPPEeUgWgdZ2QxJg', 0, 'active', '2026-10-11 05:18:54', '2026-10-11 05:18:54', NULL),
(416, 418, 1, '3090104312', '3090104312', 'RAIHAN FUADY', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_uBQvkNc05lfMfVe9fBkhAjYu', 0, 'active', '2026-10-11 05:18:55', '2026-10-11 05:18:55', NULL),
(417, 419, 1, '103943759', '103943759', 'SOEKARNO HATTA', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_9jfHtgXmA5sxKy9jGrq4426b', 0, 'active', '2026-10-11 05:18:55', '2026-10-11 05:18:55', NULL),
(418, 420, 1, '105555535', '105555535', 'THORIK IMANSYAH', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_ISm2tag8ONRf13XdY7ggQyGE', 0, 'active', '2026-10-11 05:18:56', '2026-10-11 05:18:56', NULL),
(419, 421, 1, '3100859778', '3100859778', 'THUFAIL MUHAMMAD FURQON', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_EqCEBq2HSKWOn3yuA7hQCwqs', 0, 'active', '2026-10-11 05:18:56', '2026-10-11 05:18:56', NULL),
(420, 422, 1, '98355876', '98355876', 'REVANSYAH FAWWAS', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_I5XIpDJNVg6FPISbcM2EHZsY', 0, 'active', '2026-10-11 05:18:56', '2026-10-11 05:18:56', NULL),
(421, 423, 1, '1049233237', '1049233237', 'FAHRI AKMAL HANAFI', 11, 'XI AGAMA 1', 'L', '2008-01-01', NULL, NULL, 'std_6RzdmaIms0RgF5G2ngdJoD29', 0, 'active', '2026-10-11 05:18:57', '2026-10-11 05:18:57', NULL),
(422, 424, 1, '108789384', '108789384', 'ADILAH NUR ASYIFA', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_XNFqUBUasTXVgdNSgecISMwG', 0, 'active', '2026-10-11 05:18:57', '2026-10-11 05:18:57', NULL),
(423, 425, 1, '91527648', '91527648', 'ALFIESHA ANNUR', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_AW0IycvVQ0wvj44vUB8VXOpx', 0, 'active', '2026-10-11 05:18:57', '2026-10-11 05:18:57', NULL),
(424, 426, 1, '3093967691', '3093967691', 'ANINDITA RAHMATUL LAILI', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_NT7Up6PkAI7BDRGniiUiPYUQ', 0, 'active', '2026-10-11 05:18:58', '2026-10-11 05:18:58', NULL),
(425, 427, 1, '3097368480', '3097368480', 'ANISA NUR OKTAVIA', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_3dBRsFRTnDjmddrHZN6ukT3Y', 0, 'active', '2026-10-11 05:18:58', '2026-10-11 05:18:58', NULL),
(426, 428, 1, '83277735', '83277735', 'BARO\'ATUL AZFA AULIA', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_C0KIpqqfXpgZ3jv5BTqB5xLi', 0, 'active', '2026-10-11 05:18:58', '2026-10-11 05:18:58', NULL),
(427, 429, 1, '3096500481', '3096500481', 'BUNGA AZIZAH ZAZKYA BALQIS', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_YOQGsz4zm0xQCIis2ceaWQRR', 0, 'active', '2026-10-11 05:18:59', '2026-10-11 05:18:59', NULL),
(428, 430, 1, '108522867', '108522867', 'DIAN FATMA SALAMAH', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_xQXTIWzj7Jdi65udifWeNsEm', 0, 'active', '2026-10-11 05:18:59', '2026-10-11 05:18:59', NULL),
(429, 431, 1, '98576541', '98576541', 'HAGIA SOFIA', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_YlqOvw47Vg5Pd6SytAtuRaIB', 0, 'active', '2026-10-11 05:18:59', '2026-10-11 05:18:59', NULL),
(430, 432, 1, '93234893', '93234893', 'KINETHA AISYAH RACHMANIAH', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_t2geigf8zp4IR67TvEm5Bqsi', 0, 'active', '2026-10-11 05:19:00', '2026-10-11 05:19:00', NULL),
(431, 433, 1, '94977211', '94977211', 'MIRZA FAZA ILYA MUZDALIFA', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_zSR6FkVPaQbJqG2PUmsbu22c', 0, 'active', '2026-10-11 05:19:00', '2026-10-11 05:19:00', NULL),
(432, 434, 1, '3107104596', '3107104596', 'NAILUS SA\'ADAH', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_Jyc6iCOADs87iGKpPRdID9nL', 0, 'active', '2026-10-11 05:19:00', '2026-10-11 05:19:00', NULL),
(433, 435, 1, '98752243', '98752243', 'NAVISAH AFIFATUR ROHMAH', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_n3xufib4uEL5LBmTU49JQE9j', 0, 'active', '2026-10-11 05:19:01', '2026-10-11 05:19:01', NULL),
(434, 436, 1, '3091402855', '3091402855', 'NUR AIDA FAUZIYAH', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_Gn7RSoC44BppZc7jC9KkMWXy', 0, 'active', '2026-10-11 05:19:01', '2026-10-11 05:19:01', NULL),
(435, 437, 1, '94596905', '94596905', 'SINTA FAUZIYAH', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_cxeG05ACcnST3gw954Q6GOU6', 0, 'active', '2026-10-11 05:19:02', '2026-10-11 05:19:02', NULL),
(436, 438, 1, '94159416', '94159416', 'YUNIKA ABDAN SYAKURA', 11, 'XI AGAMA 2', 'L', '2008-01-01', NULL, NULL, 'std_Jmb2Rpf83JuxhjecyEcDZi7T', 0, 'active', '2026-10-11 05:19:02', '2026-10-11 05:19:02', NULL),
(437, 439, 1, '84306603', '84306603', 'DIAH AYU PUTRI RAMADHANI', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_LD2C3X79kcorizZi7fNv2icv', 0, 'active', '2026-10-11 05:19:03', '2026-10-11 05:19:03', NULL),
(438, 440, 1, '99444154', '99444154', 'NAJWA LAILA ARINA CHOSYATILLAH', 11, 'XI AGAMA 2', 'P', '2008-01-01', NULL, NULL, 'std_BTRoRnad8jrwS4p9iKExmJHQ', 0, 'active', '2026-10-11 05:19:03', '2026-10-11 05:19:03', NULL),
(439, 441, 1, '3083469693', '3083469693', 'ACHMAD HAQI HIDAYATULLOH ARROSYID', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_h7CnCpWhjghtPizoaWyIWNZc', 0, 'active', '2026-10-11 05:19:04', '2026-10-11 05:19:04', NULL),
(440, 442, 1, '99918538', '99918538', 'ACMED ARFAZ HARAMAIN', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_yfp0jsrQIjxz7r5jXkraUVi0', 0, 'active', '2026-10-11 05:19:04', '2026-10-11 05:19:04', NULL),
(441, 443, 1, '76837772', '76837772', 'ADAM RANGGA SISWA ATMAJA', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_K17hZgg9paHXSPFy4kB6Yefi', 0, 'active', '2026-10-11 05:19:04', '2026-10-11 05:19:04', NULL),
(442, 444, 1, '83182568', '83182568', 'AHMAD FADHLI ROBBI', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_UCPcx5wVY32wL8uwrevY0zws', 0, 'active', '2026-10-11 05:19:05', '2026-10-11 05:19:05', NULL),
(443, 445, 1, '91417661', '91417661', 'AHMAD NAJIH AL ANWAR', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_CXQeDpcKxh5JnFOjGy3eadDJ', 0, 'active', '2026-10-11 05:19:05', '2026-10-11 05:19:05', NULL),
(444, 446, 1, '3086590560', '3086590560', 'AHMAD SHOFHAL JAMIL AL KAFIE', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_zEP4dVTLMTZWDXIfanmfX0sA', 0, 'active', '2026-10-11 05:19:06', '2026-10-11 05:19:06', NULL),
(445, 447, 1, '82903568', '82903568', 'AHMAD SYAIFULLAH', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_zUEZ9jkLjC3aklZY406tnETj', 0, 'active', '2026-10-11 05:19:06', '2026-10-11 05:19:06', NULL),
(446, 448, 1, '83824918', '83824918', 'AQHMAT RIDWAN GUNAWAN', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_YoxBRxDTkRnaubL5zH1cLNT2', 0, 'active', '2026-10-11 05:19:06', '2026-10-11 05:19:06', NULL),
(447, 449, 1, '3095888277', '3095888277', 'AZUAN ELKA RAMA AL SYAHRUL', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_6BsQ9hHhDXPG9fC1Z2P0oLZx', 0, 'active', '2026-10-11 05:19:07', '2026-10-11 05:19:07', NULL),
(448, 450, 1, '94781041', '94781041', 'FALICHUL AMROINI', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_Mj5g6LWxxW5HinYt6VUcqHd7', 0, 'active', '2026-10-11 05:19:07', '2026-10-11 05:19:07', NULL),
(449, 451, 1, '75696924', '75696924', 'HAFIZH ZAHRAN NUGRAHA', 12, 'XII MIPA 1', 'P', '2007-01-01', NULL, NULL, 'std_DZCcBSShy1zKjCNRjVzwAvbj', 0, 'active', '2026-10-11 05:19:08', '2026-10-11 05:19:08', NULL),
(450, 452, 1, '91170364', '91170364', 'HAIDAR MAHYA SURYA SABILILLAH', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_EK9hl7i0KiEdgGzBXJ4xIkeX', 0, 'active', '2026-10-11 05:19:08', '2026-10-11 05:19:08', NULL),
(451, 453, 1, '3084495934', '3084495934', 'KENZA ATMAWEKA AHNAF', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_mxEh9YqDadZgHausFh0lNvFG', 0, 'active', '2026-10-11 05:19:08', '2026-10-11 05:19:08', NULL),
(452, 454, 1, '96447666', '96447666', 'MOCH. ALIF ARDIANSYAH', 12, 'XII MIPA 1', 'P', '2007-01-01', NULL, NULL, 'std_UWFuUN1SsdTzg4i3x4MpqYRK', 0, 'active', '2026-10-11 05:19:09', '2026-10-11 05:19:09', NULL),
(453, 455, 1, '3084930045', '3084930045', 'MOH RIKHY RAMADHANI AL FAQIH', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_zDlKkj7QgtvaFmbEjNaERtxl', 0, 'active', '2026-10-11 05:19:09', '2026-10-11 05:19:09', NULL),
(454, 456, 1, '93644571', '93644571', 'MOHAMMAD DAFFA\'UDIN NABHAN', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_P7n46mFWsp1i4VcEQI2HIPoA', 0, 'active', '2026-10-11 05:19:10', '2026-10-11 05:19:10', NULL),
(455, 457, 1, '3082174807', '3082174807', 'MUHAMMAD ADDIN HIDAYATULLOH', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_tqsd1x67FS0btVhAcLGfgH5s', 0, 'active', '2026-10-11 05:19:10', '2026-10-11 05:19:10', NULL),
(456, 458, 1, '3086134534', '3086134534', 'MUHAMMAD ADITYA PRATAMA', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_FZnMeyiZDp0WJo3Lmi83oCS9', 0, 'active', '2026-10-11 05:19:10', '2026-10-11 05:19:10', NULL),
(457, 459, 1, '3089064136', '3089064136', 'MUHAMMAD FERDY FIRMANSYAH', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_9XYRWjdFulXTNkBhZEyW0JvX', 0, 'active', '2026-10-11 05:19:11', '2026-10-11 05:19:11', NULL),
(458, 460, 1, '82904549', '82904549', 'MUHAMMAD IFDHOL HARIRI', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_NXcpBb7cKFa2V3q3bVC7IQqb', 0, 'active', '2026-10-11 05:19:11', '2026-10-11 05:19:11', NULL),
(459, 461, 1, '95881437', '95881437', 'MUHAMMAD MADHAN SUGIHARTONO', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_m6JKACEcywytCMEYeeyBzwzV', 0, 'active', '2026-10-11 05:19:12', '2026-10-11 05:19:12', NULL),
(460, 462, 1, '3081615719', '3081615719', 'MUHAMMAD RAFFY ADITYA', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_viB6EnVEuSLUFhQ9gQ15VMP4', 0, 'active', '2026-10-11 05:19:12', '2026-10-11 05:19:12', NULL),
(461, 463, 1, '85636017', '85636017', 'MUHAMMAD YUSUF PUTRA PRATAMA', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_XvBPjpnUxmQVM92uG3QUuist', 0, 'active', '2026-10-11 05:19:12', '2026-10-11 05:19:12', NULL),
(462, 464, 1, '84915328', '84915328', 'SAYYI ERIDANI HATAMI', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_6TqTZiEwxg0l4P4rlmpsKKoS', 0, 'active', '2026-10-11 05:19:13', '2026-10-11 05:19:13', NULL),
(463, 465, 1, '97428156', '97428156', 'TEGUH HARIYANTO', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_FPBglei83GdIPOA7amKD9QLE', 0, 'active', '2026-10-11 05:19:13', '2026-10-11 05:19:13', NULL),
(464, 466, 1, '95951816', '95951816', 'AHMAD FUAD Al-MUAYYAD', 12, 'XII MIPA 1', 'L', '2007-01-01', NULL, NULL, 'std_OVEbwkaH5UxheWo5N5EgjPYz', 0, 'active', '2026-10-11 05:19:14', '2026-10-11 05:19:14', NULL),
(465, 467, 1, '3089703581', '3089703581', 'AMELIA NANDA SAFITRI', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_Bet0akYCU4mVQERJTAYTThm5', 0, 'active', '2026-10-11 05:19:14', '2026-10-11 05:19:14', NULL),
(466, 468, 1, '3095116742', '3095116742', 'AYU ALMIRA', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_YDgXACW7YVJpi4o21LhULUH0', 0, 'active', '2026-10-11 05:19:14', '2026-10-11 05:19:14', NULL),
(467, 469, 1, '97789330', '97789330', 'AZALEA LAKHEISA PRADANA', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_qgX3DbOMQ9aNgfoRlHEabnIe', 0, 'active', '2026-10-11 05:19:15', '2026-10-11 05:19:15', NULL),
(468, 470, 1, '3083996685', '3083996685', 'BUNGA INDAH LESTRAI', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_ueNRFpmOnVzIPCGUnGZieyXX', 0, 'active', '2026-10-11 05:19:15', '2026-10-11 05:19:15', NULL),
(469, 471, 1, '3092073739', '3092073739', 'CALLYSTA SASIKIRANA', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_ubkQu4oYSu2UgR0nvA4OMtje', 0, 'active', '2026-10-11 05:19:16', '2026-10-11 05:19:16', NULL),
(470, 472, 1, '3086369277', '3086369277', 'CLAUDIA SINTA NURIYAH', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_cnA9SuTnh3MeEEb7DURGCRpv', 0, 'active', '2026-10-11 05:19:16', '2026-10-11 05:19:16', NULL),
(471, 473, 1, '91627584', '91627584', 'DINTA AULIA KULBA', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_1urXCkncrKOhd3CXngz21xum', 0, 'active', '2026-10-11 05:19:17', '2026-10-11 05:19:17', NULL),
(472, 474, 1, '3092664875', '3092664875', 'DWI FEBBI ZUMROTUN NISA\'', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_bEDO7sddC6eFB84yqDHTaYF5', 0, 'active', '2026-10-11 05:19:17', '2026-10-11 05:19:17', NULL),
(473, 475, 1, '92597365', '92597365', 'ELSA WITRIANINGSIH', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_JqrWo8SZN8raYiSUtqHCe70m', 0, 'active', '2026-10-11 05:19:18', '2026-10-11 05:19:18', NULL),
(474, 476, 1, '3094532238', '3094532238', 'ERICA ALVA RETTA', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_2qhAeUUjBd95kvzM9cZ8o7Sq', 0, 'active', '2026-10-11 05:19:18', '2026-10-11 05:19:18', NULL),
(475, 477, 1, '3097113789', '3097113789', 'FAIRUZA HIKMA AL ANSHORY', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_gfmF9i0b4GyRrkjaKox0F36a', 0, 'active', '2026-10-11 05:19:19', '2026-10-11 05:19:19', NULL),
(476, 478, 1, '51292710', '51292710', 'FAIZATUL WAHYUNING LESTARI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_nQSqFqTHmiMmuUgSU9L7l5nn', 0, 'active', '2026-10-11 05:19:19', '2026-10-11 05:19:19', NULL),
(477, 479, 1, '89185650', '89185650', 'FANI AFNAN JANNATI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_DNcYfEovk0kD2tP2iQa8csOI', 0, 'active', '2026-10-11 05:19:19', '2026-10-11 05:19:19', NULL),
(478, 480, 1, '97377905', '97377905', 'FARHATUS SALSABILA', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_38CaBnsKQCyw47JDBzjeHfRR', 0, 'active', '2026-10-11 05:19:20', '2026-10-11 05:19:20', NULL),
(479, 481, 1, '86879709', '86879709', 'FIANTIKA SELLYNA MUFTI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_0JljvSDtkdLAPQN3grQ7carK', 0, 'active', '2026-10-11 05:19:21', '2026-10-11 05:19:21', NULL),
(480, 482, 1, '83691515', '83691515', 'GENDIS NURSAFITRI', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_TiUNz775txJ2XFeX5CzFuoCi', 0, 'active', '2026-10-11 05:19:21', '2026-10-11 05:19:21', NULL),
(481, 483, 1, '3098043502', '3098043502', 'HELEN DHEVITA ULVI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_1yvCXkxnULR31ATtRJJEcSCI', 0, 'active', '2026-10-11 05:19:22', '2026-10-11 05:19:22', NULL);
INSERT INTO `students` (`id`, `user_id`, `school_id`, `nis`, `nisn`, `full_name`, `grade_level`, `class_name`, `gender`, `birth_date`, `birth_place`, `phone_number`, `public_id`, `public_profile_enabled`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(482, 484, 1, '87316170', '87316170', 'IFNATUS MUALIFAH', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_e9Rl1ABYWPOanDbqDJSWTiy7', 0, 'active', '2026-10-11 05:19:23', '2026-10-11 05:19:23', NULL),
(483, 485, 1, '94644990', '94644990', 'ILLA NUR BAGIATUS SHOLIHAT', 12, 'XII MIPA 2', 'P', '2007-01-01', NULL, NULL, 'std_knMF4XrRlIHEqWyS5Th66RXh', 0, 'active', '2026-10-11 05:19:24', '2026-10-11 05:19:24', NULL),
(484, 486, 1, '97812710', '97812710', 'INDAH AWWALUL KHULUQIYYAH', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_MRFWeguj6mak9KHIEa04Yw9T', 0, 'active', '2026-10-11 05:19:24', '2026-10-11 05:19:24', NULL),
(485, 487, 1, '3098585776', '3098585776', '\'ISYNA \'AUNA ELMAULA YUSRON', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_Zwr1LRpMTbti6FAoF45ugVRn', 0, 'active', '2026-10-11 05:19:25', '2026-10-11 05:19:25', NULL),
(486, 488, 1, '95275536', '95275536', 'IZZA ZAKIYATUL MAHFUDHOH FAJARI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_iAky0O7GIW3YirpPKLiuFxKZ', 0, 'active', '2026-10-11 05:19:25', '2026-10-11 05:19:25', NULL),
(487, 489, 1, '83746733', '83746733', 'KIRAN FARDA ATHIYA', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_WMNHtEMqXTL1ikQRAFy2cZkG', 0, 'active', '2026-10-11 05:19:25', '2026-10-11 05:19:25', NULL),
(488, 490, 1, '3088647504', '3088647504', 'LATIFATUL MAZEDA ILMAIDAH', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_GBXLg51kcuer4zBAEn3ji7TJ', 0, 'active', '2026-10-11 05:19:26', '2026-10-11 05:19:26', NULL),
(489, 491, 1, '84095714', '84095714', 'LIWAUL JANNAH', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_5aZolBUYWne0SABgyGDsKD5V', 0, 'active', '2026-10-11 05:19:26', '2026-10-11 05:19:26', NULL),
(490, 492, 1, '87680515', '87680515', 'MAORA WIDIA PRATIWI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_wpG8QOrvLkFXxuPAZudzErDe', 0, 'active', '2026-10-11 05:19:27', '2026-10-11 05:19:27', NULL),
(491, 493, 1, '74295462', '74295462', 'MAYYADA FIRDA THURAYYA', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_qmpUyAQCSV0jtyA5Ksreejmk', 0, 'active', '2026-10-11 05:19:27', '2026-10-11 05:19:27', NULL),
(492, 494, 1, '94403250', '94403250', 'ZALFA SURYANILLAH KUSUMAWARDANI', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_gBZ0G6K4xzKFIrboduki9O18', 0, 'active', '2026-10-11 05:19:27', '2026-10-11 05:19:27', NULL),
(493, 495, 1, '3080722862', '3080722862', 'AISYAH WISHMI VINORIKA', 12, 'XII MIPA 2', 'L', '2007-01-01', NULL, NULL, 'std_QNpIDWF48igbEBG2Amkz48FK', 0, 'active', '2026-10-11 05:19:28', '2026-10-11 05:19:28', NULL),
(494, 496, 1, '3090530062', '3090530062', 'KAYLA SYIFA RAYYA IZZAHRA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_1eSNItwQbHGIKW8NQs7TnMlt', 0, 'active', '2026-10-11 05:19:28', '2026-10-11 05:19:28', NULL),
(495, 497, 1, '92028208', '92028208', 'MUKHBITA EL RAFEYFA', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_OBoGZ9USTd3IESOO0vlR6n7f', 0, 'active', '2026-10-11 05:19:28', '2026-10-11 05:19:28', NULL),
(496, 498, 1, '85546052', '85546052', 'NABILAH EKA FATIHATUSHOFIYYAH', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_2VfEfKydXxCPHk6S3aWk9VDO', 0, 'active', '2026-10-11 05:19:29', '2026-10-11 05:19:29', NULL),
(497, 499, 1, '3080660620', '3080660620', 'NABILAH PUTRI AZZAHRA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_FtRmSRsRwS6IP9ArrOsUzO0y', 0, 'active', '2026-10-11 05:19:29', '2026-10-11 05:19:29', NULL),
(498, 500, 1, '85175324', '85175324', 'NABILLA AZZAHRA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_2NdnvJsrPgoVN1UP6D63PNcW', 0, 'active', '2026-10-11 05:19:29', '2026-10-11 05:19:29', NULL),
(499, 501, 1, '3099369420', '3099369420', 'NADIA CELSINTA', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_AxckchzPxrD6FfmROqgU2Ytm', 0, 'active', '2026-10-11 05:19:30', '2026-10-11 05:19:30', NULL),
(500, 502, 1, '3085329138', '3085329138', 'NAILAH AURORA', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_GIp22J84ilQZhmm20lZt0WRH', 0, 'active', '2026-10-11 05:19:30', '2026-10-11 05:19:30', NULL),
(501, 503, 1, '94321196', '94321196', 'NUHA SAFA AULIA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_7K93NXl8dOjgU6JOLFkktT1D', 0, 'active', '2026-10-11 05:19:30', '2026-10-11 05:19:30', NULL),
(502, 504, 1, '82784864', '82784864', 'PUTRI SABRINA SALSABILLAH', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_4ST5EOUFQThAytAjLpmfoWqf', 0, 'active', '2026-10-11 05:19:31', '2026-10-11 05:19:31', NULL),
(503, 505, 1, '92757701', '92757701', 'QORINA FATHMA ZAHARANI', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_CXJTqFVXu3FozpfBn7RXr0eB', 0, 'active', '2026-10-11 05:19:31', '2026-10-11 05:19:31', NULL),
(504, 506, 1, '3080381856', '3080381856', 'RAHMATUL ANFANA ZULIANA DEWI', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_wgAtlupQWIDBOaG0sSBuG3tj', 0, 'active', '2026-10-11 05:19:31', '2026-10-11 05:19:31', NULL),
(505, 507, 1, '78135431', '78135431', 'REVALINA FUJI SULAKSMI', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_yYQjDCogYrC5VpRVIK0BmWdC', 0, 'active', '2026-10-11 05:19:32', '2026-10-11 05:19:32', NULL),
(506, 508, 1, '3086456347', '3086456347', 'RIZKA AQMALIA MUTHI\'', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_QWh9ovjCx4i8MpTAosrD3rRV', 0, 'active', '2026-10-11 05:19:32', '2026-10-11 05:19:32', NULL),
(507, 509, 1, '86257908', '86257908', 'ROFIQOTUN NUR FAIZAH', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_fp1L4mKzjakFBvGrpsM92uns', 0, 'active', '2026-10-11 05:19:32', '2026-10-11 05:19:32', NULL),
(508, 510, 1, '86379579', '86379579', 'SALSABILA SINTANOLA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_2ILZu2xLHpna5U5s4n3EUnUP', 0, 'active', '2026-10-11 05:19:33', '2026-10-11 05:19:33', NULL),
(509, 511, 1, '89853432', '89853432', 'SASA DWI KAMILA', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_48eXPMoVejC9PdMhcoRPvQQR', 0, 'active', '2026-10-11 05:19:33', '2026-10-11 05:19:33', NULL),
(510, 512, 1, '87354862', '87354862', 'SAYYIDAH BILQIS NURUL JANNAH', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_oBfpG6DfBgkcqQHruKZuVXJ8', 0, 'active', '2026-10-11 05:19:33', '2026-10-11 05:19:33', NULL),
(511, 513, 1, '3098738977', '3098738977', 'SHOFI AMALIA ZAHRA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_v3n3NsqlvSYlfHfmXJyxI51k', 0, 'active', '2026-10-11 05:19:34', '2026-10-11 05:19:34', NULL),
(512, 514, 1, '91926144', '91926144', 'TALITA NAILAH SHOFWATILLAH', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_fdIX4knvuUT2xbNSIh8oxqjN', 0, 'active', '2026-10-11 05:19:34', '2026-10-11 05:19:34', NULL),
(513, 515, 1, '84552049', '84552049', 'UMMU MAYSYUROH AZZAHRA ZAMZAMIA', 12, 'XII MIPA 3', 'P', '2007-01-01', NULL, NULL, 'std_ukQT8oyMinJqmKd7jDKxYuSe', 0, 'active', '2026-10-11 05:19:34', '2026-10-11 05:19:34', NULL),
(514, 516, 1, '85944941', '85944941', 'VRISCA MARSHA ANGELLYA', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_EK5ADhKR4ciZUqNJ2Eu3Y3Sj', 0, 'active', '2026-10-11 05:19:35', '2026-10-11 05:19:35', NULL),
(515, 517, 1, '109037620', '109037620', 'WAFIYYATUL KARIMAH', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_4dfAVZ8wuylI6m6GuMDOYtix', 0, 'active', '2026-10-11 05:19:35', '2026-10-11 05:19:35', NULL),
(516, 518, 1, '86323627', '86323627', 'ZAKKIYATUL UMAMI', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_fzw0clXqry1CHACIrnYb5dZm', 0, 'active', '2026-10-11 05:19:36', '2026-10-11 05:19:36', NULL),
(517, 519, 1, '86171277', '86171277', 'LUTFIANA LATIFAH', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_GZqpWb1ybnBGHF4VQuKWX4WJ', 0, 'active', '2026-10-11 05:19:36', '2026-10-11 05:19:36', NULL),
(518, 520, 1, '3095413449', '3095413449', 'AURA IZZA NAELAL MUNA', 12, 'XII MIPA 3', 'L', '2007-01-01', NULL, NULL, 'std_BiteAHbG7YkM5hRa67IMkgIV', 0, 'active', '2026-10-11 05:19:36', '2026-10-11 05:19:36', NULL),
(519, 521, 1, '84018613', '84018613', 'ACHMAD ARAFA SHIDQI', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_nohNzBSUMNTFt45VU5y1ExzH', 0, 'active', '2026-10-11 05:19:37', '2026-10-11 05:19:37', NULL),
(520, 522, 1, '99190035', '99190035', 'AFIF SOLAHUDDIN ROHMATULLAH', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_3Ym5oRlGyad1r3hYCYmnkFig', 0, 'active', '2026-10-11 05:19:37', '2026-10-11 05:19:37', NULL),
(521, 523, 1, '95583296', '95583296', 'AFRI YOGA PRATAMA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_C6YI4mFfAXdQGgq5idGRyEMa', 0, 'active', '2026-10-11 05:19:37', '2026-10-11 05:19:37', NULL),
(522, 524, 1, '61708052', '61708052', 'AHMAD LABIB RAMDHAN AL GHIFFARY', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_lCmbQ8jSjP297kNRxF9IzanX', 0, 'active', '2026-10-11 05:19:38', '2026-10-11 05:19:38', NULL),
(523, 525, 1, '3085041374', '3085041374', 'AHMAD NUR FIKRI UBAIDILLAH', 12, 'XII IPS 1', 'P', '2007-01-01', NULL, NULL, 'std_YVh7kPlzyVysfPOgxCz0NA5Q', 0, 'active', '2026-10-11 05:19:38', '2026-10-11 05:19:38', NULL),
(524, 526, 1, '89540599', '89540599', 'AHMAD TRI MUSTAKIM', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_LHZTEDvxY6KdG8htzcgs560V', 0, 'active', '2026-10-11 05:19:39', '2026-10-11 05:19:39', NULL),
(525, 527, 1, '3070142205', '3070142205', 'ALFIAN JUFRI ABDILLAH', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_DCiT3bGiWeGdSzzge4ZR2fhw', 0, 'active', '2026-10-11 05:19:39', '2026-10-11 05:19:39', NULL),
(526, 528, 1, '81779516', '81779516', 'BAYU KRISNA WARDANA', 12, 'XII IPS 1', 'P', '2007-01-01', NULL, NULL, 'std_uNzDIf5LNRl8tJnouJWx7qob', 0, 'active', '2026-10-11 05:19:39', '2026-10-11 05:19:39', NULL),
(527, 529, 1, '93648907', '93648907', 'DAFFA RIZQI ATHAYA SETIAWAN', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_uGVa3svxsL99zL3F4S2AhmU3', 0, 'active', '2026-10-11 05:19:40', '2026-10-11 05:19:40', NULL),
(528, 530, 1, '3082448599', '3082448599', 'DIMAS AGENG NUR ISLAKHUDIN', 12, 'XII IPS 1', 'P', '2007-01-01', NULL, NULL, 'std_gDEmINmeqDxwWeT9Tf1GBxjo', 0, 'active', '2026-10-11 05:19:40', '2026-10-11 05:19:40', NULL),
(529, 531, 1, '3095537753', '3095537753', 'EZZAR GAISYAN NURAQIL', 12, 'XII IPS 1', 'P', '2007-01-01', NULL, NULL, 'std_CPzWDCVjbBmNYRKLbRPh8qYc', 0, 'active', '2026-10-11 05:19:40', '2026-10-11 05:19:40', NULL),
(530, 532, 1, '60093511', '60093511', 'FACHRI DZAKI RAMADHAN', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_ND1lqHmMRtMngLTnGnIlgZ8w', 0, 'active', '2026-10-11 05:19:41', '2026-10-11 05:19:41', NULL),
(531, 533, 1, '3080734003', '3080734003', 'GUSTI BINTANG PUTRA UNON PURWANTO', 12, 'XII IPS 1', 'P', '2007-01-01', NULL, NULL, 'std_clNYjgCE6hw7FbdtYvOIe8f7', 0, 'active', '2026-10-11 05:19:41', '2026-10-11 05:19:41', NULL),
(532, 534, 1, '3087903366', '3087903366', 'HAFIDZ MAULANA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_UzELQJZx9BnzCyUfXr6a9ep9', 0, 'active', '2026-10-11 05:19:41', '2026-10-11 05:19:41', NULL),
(533, 535, 1, '93913923', '93913923', 'HIJIR SURYA SUCIPTO', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_4bEw6o5wMJavqLEWdXelMWCX', 0, 'active', '2026-10-11 05:19:42', '2026-10-11 05:19:42', NULL),
(534, 536, 1, '98156542', '98156542', 'MARS MIKA\'IL', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_c9UugMSb9XyzyzI3HGLCZ95P', 0, 'active', '2026-10-11 05:19:42', '2026-10-11 05:19:42', NULL),
(535, 537, 1, '91839028', '91839028', 'MOCHAMMAD NOER ALFIAN AZKYA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_JCugl4avUJxjrXoN6pdOuTTE', 0, 'active', '2026-10-11 05:19:42', '2026-10-11 05:19:42', NULL),
(536, 538, 1, '83034281', '83034281', 'MOCHAMMAD AKMAL FIRDAUS AL- MUKARRAMY', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_mIq4SsFCjk5CClPE4Cca8rDr', 0, 'active', '2026-10-11 05:19:43', '2026-10-11 05:19:43', NULL),
(537, 539, 1, '3086070138', '3086070138', 'MOH. HASBY ABDILLAH', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_vXK9B22EtGgpy2Ol7GB1QvPs', 0, 'active', '2026-10-11 05:19:43', '2026-10-11 05:19:43', NULL),
(538, 540, 1, '3087135780', '3087135780', 'MOHAMMAD PANJI AKMALUZZUHAIR', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_3eaJRzFmrBy2aPbU4JZw2Jh9', 0, 'active', '2026-10-11 05:19:43', '2026-10-11 05:19:43', NULL),
(539, 541, 1, '3085904471', '3085904471', 'MOHAMMAD SYAHID MASHUDI', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_c9oeSbbUMp0nCe4noDwOVCbc', 0, 'active', '2026-10-11 05:19:44', '2026-10-11 05:19:44', NULL),
(540, 542, 1, '3095047702', '3095047702', 'MUHAMAD NIAM MUSAFFA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_KVfZbiGt6sCCBEUyYagultIA', 0, 'active', '2026-10-11 05:19:44', '2026-10-11 05:19:44', NULL),
(541, 543, 1, '3091589127', '3091589127', 'MUHAMMAD AD\'LIL AL GHOZALI', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_5X2mZ60FYpTBQZbu8ZHdnwGd', 0, 'active', '2026-10-11 05:19:45', '2026-10-11 05:19:45', NULL),
(542, 544, 1, '3087191997', '3087191997', 'MUHAMMAD ARIF PANJALU', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_PjuBQRAOg9MKa6jUhuAsuTn3', 0, 'active', '2026-10-11 05:19:45', '2026-10-11 05:19:45', NULL),
(543, 545, 1, '3080097010', '3080097010', 'MUHAMMAD ARSA OZORA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_9DbelU8xxc4cCxwiVUAgvHVV', 0, 'active', '2026-10-11 05:19:45', '2026-10-11 05:19:45', NULL),
(544, 546, 1, '97110798', '97110798', 'MUHAMMAD IQBAL MUSYAFFA\'', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_K14vE9NAyznlpNGpSG4jKnAj', 0, 'active', '2026-10-11 05:19:46', '2026-10-11 05:19:46', NULL),
(545, 547, 1, '3099176457', '3099176457', 'MUHAMMAD NABIL ASYHAR', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_yiSoiJnJBjxqUheSm388IPek', 0, 'active', '2026-10-11 05:19:46', '2026-10-11 05:19:46', NULL),
(546, 548, 1, '99611750', '99611750', 'MUHAMMAD SANJU ARISKA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_OAA7jacfPO2JMItVWLu4fLEh', 0, 'active', '2026-10-11 05:19:46', '2026-10-11 05:19:46', NULL),
(547, 549, 1, '86671162', '86671162', 'RAIHAN ADITYA MAULANA ISWAHYUDI', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_5k5rmodV16LO4pt3Z1R5ryKW', 0, 'active', '2026-10-11 05:19:47', '2026-10-11 05:19:47', NULL),
(548, 550, 1, '85850754', '85850754', 'REVAN RADITYAH PASHA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_57EYNfF64Y7Fe3zx7qVwJoqf', 0, 'active', '2026-10-11 05:19:47', '2026-10-11 05:19:47', NULL),
(549, 551, 1, '3092691163', '3092691163', 'REYHAN AR RAYAN FEBRIANTITO', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_slbyDP75T7r1BxY676q41H6o', 0, 'active', '2026-10-11 05:19:47', '2026-10-11 05:19:47', NULL),
(550, 552, 1, '3081782031', '3081782031', 'SAIF RAFA ALZINDANY', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_VlyqFrhDFqSJwzELZzYE16wl', 0, 'active', '2026-10-11 05:19:48', '2026-10-11 05:19:48', NULL),
(551, 553, 1, '3085725995', '3085725995', 'WILDAN ALBANNA', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_TAJigFctXxvGRqFntfc0mVwr', 0, 'active', '2026-10-11 05:19:48', '2026-10-11 05:19:48', NULL),
(552, 554, 1, '84402943', '84402943', 'WILIAM HAMID', 12, 'XII IPS 1', 'P', '2007-01-01', NULL, NULL, 'std_lRTia282ICvLrQPwWB3zzz6l', 0, 'active', '2026-10-11 05:19:48', '2026-10-11 05:19:48', NULL),
(553, 555, 1, '3086898748', '3086898748', 'ELDO RADITYA ASADULLAH', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_sRjEZMXdrQrrIblaXQmnoS1Y', 0, 'active', '2026-10-11 05:19:49', '2026-10-11 05:19:49', NULL),
(554, 556, 1, '3081597796', '3081597796', 'M. ALI SHOBIRIN', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_F94aa1FBWo5zweojmLgmTFlC', 0, 'active', '2026-10-11 05:19:49', '2026-10-11 05:19:49', NULL),
(555, 557, 1, '91440119', '91440119', 'M. PRAMUDITA MUSAIYAR RABBANI', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_WqZUFMZHWKI2QBLkzTj91qyg', 0, 'active', '2026-10-11 05:19:49', '2026-10-11 05:19:49', NULL),
(556, 558, 1, '96650343', '96650343', 'RIZQI DWI RAMADHAN', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_gToJCOVvRvkJwG32btkCpi8o', 0, 'active', '2026-10-11 05:19:50', '2026-10-11 05:19:50', NULL),
(557, 559, 1, '77313541', '77313541', 'MUHAMMAD KUNTADEWA EL \'AZIZY', 12, 'XII IPS 1', 'L', '2007-01-01', NULL, NULL, 'std_9x4XPgpCvHEwnFNxjx4j1EA0', 0, 'active', '2026-10-11 05:19:50', '2026-10-11 05:19:50', NULL),
(558, 560, 1, '98091961', '98091961', 'AINUN ZAZKIA AVRIL KIMBERLIN', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_O1zstWhyQgmwJFQy6o4cDCfQ', 0, 'active', '2026-10-11 05:19:50', '2026-10-11 05:19:50', NULL),
(559, 561, 1, '97832953', '97832953', 'ALISTA NAZWA PUTRI', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_b6PVrCt2xEZA3KaMRUTp8mSk', 0, 'active', '2026-10-11 05:19:51', '2026-10-11 05:19:51', NULL),
(560, 562, 1, '3092324620', '3092324620', 'ABIDAH AZMI AYU IMTIYAAZ', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_4dBNGYCufgQvHXNFbIeVtAvc', 0, 'active', '2026-10-11 05:19:51', '2026-10-11 05:19:51', NULL),
(561, 563, 1, '95443268', '95443268', 'ALFINAA ABIDATUL AZMIYYAH', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_LA7XiSG7BmjFuhPE3W0XZN3K', 0, 'active', '2026-10-11 05:19:52', '2026-10-11 05:19:52', NULL),
(562, 564, 1, '94142637', '94142637', 'ALMYRA VAEZA DEVIANTI', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_cK0gFYViKqaLbD9U46Xgnpv5', 0, 'active', '2026-10-11 05:19:52', '2026-10-11 05:19:52', NULL),
(563, 565, 1, '95751723', '95751723', 'ARNES SHINTA AZZAHRAH', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_Kt358rKpS1bqFoRl5CHatvB1', 0, 'active', '2026-10-11 05:19:52', '2026-10-11 05:19:52', NULL),
(564, 566, 1, '74874566', '74874566', 'AUFA AZKA RIZQIA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_IQ4RWEBRPCDyMP6bUQTRvLgH', 0, 'active', '2026-10-11 05:19:53', '2026-10-11 05:19:53', NULL),
(565, 567, 1, '88990463', '88990463', 'AULLIA AZ ZAHRA PUTRI', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_9Y2HHrQWf61Hn3tg7B7vq7fM', 0, 'active', '2026-10-11 05:19:53', '2026-10-11 05:19:53', NULL),
(566, 568, 1, '3096087437', '3096087437', 'AURA RIZKYTA MAULIDYA KIRANA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_YEsdMksDIjwnB06GrHARFPU1', 0, 'active', '2026-10-11 05:19:53', '2026-10-11 05:19:53', NULL),
(567, 569, 1, '3082688813', '3082688813', 'AZ ZAHRA NADIA SYIFA RAHMA', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_36Fh0tBLkDC55tLS6KKSYsqQ', 0, 'active', '2026-10-11 05:19:54', '2026-10-11 05:19:54', NULL),
(568, 570, 1, '3099665477', '3099665477', 'AZUN NAHAYATUN NAFIS', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_NY79rc2vlwvVe20kzpSq8aah', 0, 'active', '2026-10-11 05:19:54', '2026-10-11 05:19:54', NULL),
(569, 571, 1, '3099065677', '3099065677', 'BALQIS LUBNA HUMAIRO', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_0dy667eLfcbyfbyvMyip8cak', 0, 'active', '2026-10-11 05:19:54', '2026-10-11 05:19:54', NULL),
(570, 572, 1, '89565141', '89565141', 'CHUMAIROH FITRIA GALIS', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_d1PrSEdHR0yoq3gtqiGLTfcQ', 0, 'active', '2026-10-11 05:19:55', '2026-10-11 05:19:55', NULL),
(571, 573, 1, '95390608', '95390608', 'DAIVA AMIRA EILIYA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_HySXtIzckKNmlvhjadpCGxzp', 0, 'active', '2026-10-11 05:19:55', '2026-10-11 05:19:55', NULL),
(572, 574, 1, '83492993', '83492993', 'DEVITA KUSMIA DWIYANTI', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_47J6xdPIPuqigtCBr1l9NvfX', 0, 'active', '2026-10-11 05:19:55', '2026-10-11 05:19:55', NULL),
(573, 575, 1, '82415090', '82415090', 'DYAJENG AMANDA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_dkr1YTOjGAnWtKka3595Obo7', 0, 'active', '2026-10-11 05:19:56', '2026-10-11 05:19:56', NULL),
(574, 576, 1, '3099558421', '3099558421', 'FAZA SAKHIYATUN NAJWA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_99VJPkRjWSe8kqyPRu0Q4BEd', 0, 'active', '2026-10-11 05:19:56', '2026-10-11 05:19:56', NULL),
(575, 577, 1, '3097898135', '3097898135', 'FELISA HAURA NISRINA', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_z3sw5hb95YxW2BIVMLt4Lhhf', 0, 'active', '2026-10-11 05:19:56', '2026-10-11 05:19:56', NULL),
(576, 578, 1, '82314206', '82314206', 'FELLAH SYABANIA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_7pNL78UN97aQPFtFEvuNPygS', 0, 'active', '2026-10-11 05:19:57', '2026-10-11 05:19:57', NULL),
(577, 579, 1, '95691266', '95691266', 'FINA RAHMATUL AWWALIYAH', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_AInB3ja6iMfQsLQ3kB6ppy1o', 0, 'active', '2026-10-11 05:19:57', '2026-10-11 05:19:57', NULL),
(578, 580, 1, '3099071290', '3099071290', 'GHURROTUL HANA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_2VCE7gKei17u7wQAzBfenMQs', 0, 'active', '2026-10-11 05:19:57', '2026-10-11 05:19:57', NULL),
(579, 581, 1, '94334499', '94334499', 'IMELDA ZUHRO', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_ONb7nNMrjN9mmhcsgtI3aORL', 0, 'active', '2026-10-11 05:19:58', '2026-10-11 05:19:58', NULL),
(580, 582, 1, '98202495', '98202495', 'IZZA INAYATUL MAGHFIROH', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_rZsW2pxVMLTiHVhBOMrKp4lp', 0, 'active', '2026-10-11 05:19:58', '2026-10-11 05:19:58', NULL),
(581, 583, 1, '3097676773', '3097676773', 'KAYLA HAMANI MURTAZA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_gw8oFoO20645X9kUG3plqZF6', 0, 'active', '2026-10-11 05:19:58', '2026-10-11 05:19:58', NULL),
(582, 584, 1, '86885994', '86885994', 'KHANSA ZAHIRAH NAJLA AS-SHAINA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_vKzHufbQvisVxslFfaFKxYuP', 0, 'active', '2026-10-11 05:19:59', '2026-10-11 05:19:59', NULL),
(583, 585, 1, '89175951', '89175951', 'MALIKATU ZAHRA RAMADANI', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_VTOfz1wZE7XMBRb7fLtpMBBJ', 0, 'active', '2026-10-11 05:19:59', '2026-10-11 05:19:59', NULL),
(584, 586, 1, '96295204', '96295204', 'MAUDY MAULIDA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_wfAkTIhmuP4sheYpv7uFvbve', 0, 'active', '2026-10-11 05:19:59', '2026-10-11 05:19:59', NULL),
(585, 587, 1, '96223385', '96223385', 'NABILA AULIA ARIFIANTI', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_0Jq3NNhxx2U77w86SPKZxu6o', 0, 'active', '2026-10-11 05:20:00', '2026-10-11 05:20:00', NULL),
(586, 588, 1, '3081011746', '3081011746', 'NA\'IMATUZ ZAHRA', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_R7K9IT7J5IGP057HUsf2YS8H', 0, 'active', '2026-10-11 05:20:00', '2026-10-11 05:20:00', NULL),
(587, 589, 1, '3090619695', '3090619695', 'QOTRUNNADA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_7ul2p4dc8N0IK7zgidCJuMpH', 0, 'active', '2026-10-11 05:20:00', '2026-10-11 05:20:00', NULL),
(588, 590, 1, '3082932835', '3082932835', 'SAFIRA PUTRI ARIFIANA', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_DuQdIe4iFrPh1rO420NxOwbX', 0, 'active', '2026-10-11 05:20:01', '2026-10-11 05:20:01', NULL),
(589, 591, 1, '3097730333', '3097730333', 'SAVINATUN NAJAH FEBRIANI', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_mcWYwNBUZqe67guwXY6JH20Q', 0, 'active', '2026-10-11 05:20:01', '2026-10-11 05:20:01', NULL),
(590, 592, 1, '3095209361', '3095209361', 'SHEILA SALSABILA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_jIjZGARO2Eb0z0DUewBJOET3', 0, 'active', '2026-10-11 05:20:02', '2026-10-11 05:20:02', NULL),
(591, 593, 1, '87437156', '87437156', 'SHENA DWI ARISKA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_we8tBor55Pgu4sN8fhEFcDqY', 0, 'active', '2026-10-11 05:20:03', '2026-10-11 05:20:03', NULL),
(592, 594, 1, '99870680', '99870680', 'SHOFI MUFIIDAH', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_Cz1LcQB5lJ2CSNaDrEGnUYSj', 0, 'active', '2026-10-11 05:20:03', '2026-10-11 05:20:03', NULL),
(593, 595, 1, '92643066', '92643066', 'SITI KHOLIFAH NURLAYLI', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_OruUPk2htu1rhpvPcdxG0eVK', 0, 'active', '2026-10-11 05:20:04', '2026-10-11 05:20:04', NULL),
(594, 596, 1, '3083231072', '3083231072', 'VINA DAIMATURROHMAH', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_Drybz6Ehb0gqDI1ozsEfR00A', 0, 'active', '2026-10-11 05:20:04', '2026-10-11 05:20:04', NULL),
(595, 597, 1, '3084641260', '3084641260', 'WULAN SYASYA AQILA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_54azEsMCr2LIPeqAs23mpzTz', 0, 'active', '2026-10-11 05:20:05', '2026-10-11 05:20:05', NULL),
(596, 598, 1, '398328234', '398328234', 'RADITA NURFATHZAH', 12, 'XII IPS 2', 'P', '2007-01-01', NULL, NULL, 'std_ifjQ7SZhjwez0txsN0DhLAGs', 0, 'active', '2026-10-11 05:20:05', '2026-10-11 05:20:05', NULL),
(597, 599, 1, '78969128', '78969128', 'ZIDNI AGNIA ILMA', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_wrilueTSJ0ZQVC8QCGwfXZjg', 0, 'active', '2026-10-11 05:20:05', '2026-10-11 05:20:05', NULL),
(598, 600, 1, '3109127352', '3109127352', 'NAJMA TSANIA AL FAJRIYAH', 12, 'XII IPS 2', 'L', '2007-01-01', NULL, NULL, 'std_wPXZXkKrcoDdkHbolO2dDekn', 0, 'active', '2026-10-11 05:20:06', '2026-10-11 05:20:06', NULL),
(599, 601, 1, '3089941768', '3089941768', 'ABDILLAH FARDIN ALVARO', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_c9aZL6b061GQRVredI0NyAA7', 0, 'active', '2026-10-11 05:20:06', '2026-10-11 05:20:06', NULL),
(600, 602, 1, '3098427665', '3098427665', 'ADNIN MUHAMMAD AR RIFA\'I', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_OGexldVxCcE8sXEGuEdB3wRV', 0, 'active', '2026-10-11 05:20:07', '2026-10-11 05:20:07', NULL),
(601, 603, 1, '973226332', '973226332', 'AHMAD ADAM SULTAN PRATAMA HAQIQI', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_id5tHkAenCF2seYL6bU9HUPg', 0, 'active', '2026-10-11 05:20:07', '2026-10-11 05:20:07', NULL),
(602, 604, 1, '93604524', '93604524', 'AHMAD NIZAR MAULANA', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_HAeL2bKaqkYcnoGcWiBZoC1p', 0, 'active', '2026-10-11 05:20:07', '2026-10-11 05:20:07', NULL),
(603, 605, 1, '3083254442', '3083254442', 'AHMED GABRIEL WICAKSONO', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_7cz7zpKhQpFOV02ywF0ceYpr', 0, 'active', '2026-10-11 05:20:08', '2026-10-11 05:20:08', NULL),
(604, 606, 1, '94100712', '94100712', 'AHMMAD SOLEH ASRORI', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_39alJSHF5MuqvQrOG6Wz4wSa', 0, 'active', '2026-10-11 05:20:08', '2026-10-11 05:20:08', NULL),
(605, 607, 1, '97713040', '97713040', 'BAHAUDIN AKMAL', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_iNZimNNvjnfzcztjHIFfQ6kq', 0, 'active', '2026-10-11 05:20:08', '2026-10-11 05:20:08', NULL),
(606, 608, 1, '83401619', '83401619', 'LUVI MUSTAQIM', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_8pr1Eenco8pNHCJW5ZCFIlxg', 0, 'active', '2026-10-11 05:20:09', '2026-10-11 05:20:09', NULL),
(607, 609, 1, '3086645338', '3086645338', 'M. ASHABIL YAMIN', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_Niq5W35uthw514pmb9CHoeec', 0, 'active', '2026-10-11 05:20:09', '2026-10-11 05:20:09', NULL),
(608, 610, 1, '3090686371', '3090686371', 'M. FAHRI JAUHAR FUADI', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_rOIsrGBqctToXOjyB91w2nvh', 0, 'active', '2026-10-11 05:20:10', '2026-10-11 05:20:10', NULL),
(609, 611, 1, '3083789192', '3083789192', 'M. YUSUF AL GHUFRONY', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_Y26Vhl9g0e6mr2AyIhaxn37K', 0, 'active', '2026-10-11 05:20:10', '2026-10-11 05:20:10', NULL),
(610, 612, 1, '96221614', '96221614', 'MOCH. ALFIAN FAHMI', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_ph7evFmOQn5LvSsnL2AVoLO8', 0, 'active', '2026-10-11 05:20:10', '2026-10-11 05:20:10', NULL),
(611, 613, 1, '84156764', '84156764', 'MUCHAMMAD RISKI YULIANTO', 12, 'XII AGAMA 1', 'P', '2007-01-01', NULL, NULL, 'std_TrVtTTHIuyZtZBUQkFlwHuEc', 0, 'active', '2026-10-11 05:20:11', '2026-10-11 05:20:11', NULL),
(612, 614, 1, '3086604444', '3086604444', 'MUHAMMAD RAFLY ATTHALAH FEBRIANSYAH', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_B3UmG9UXCnHOKP2HwGvTWcps', 0, 'active', '2026-10-11 05:20:11', '2026-10-11 05:20:11', NULL),
(613, 615, 1, '93092498', '93092498', 'MUHAMMAD RIFAD ARFARI', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_X3u2WmkZJfBNVwPtD7QlBEII', 0, 'active', '2026-10-11 05:20:12', '2026-10-11 05:20:12', NULL),
(614, 616, 1, '3091725601', '3091725601', 'NATHAN ERZA QAFI YUWAN', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_pIsNZq2fQQldfldOD10N5wfN', 0, 'active', '2026-10-11 05:20:13', '2026-10-11 05:20:13', NULL),
(615, 617, 1, '96403216', '96403216', 'RAIHAN \'ADZIM AL MAULUDI', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_XnXBz15MkD3dxX9nR5auuoiE', 0, 'active', '2026-10-11 05:20:13', '2026-10-11 05:20:13', NULL),
(616, 618, 1, '85372602', '85372602', 'TEGAR ADI SAPUTRA', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_ZGw2WTLTQtg2WIpZeQ7e8IcX', 0, 'active', '2026-10-11 05:20:14', '2026-10-11 05:20:14', NULL),
(617, 619, 1, '3090822753', '3090822753', 'WAHYU WIBOWO WISNU SAPUTRO', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_CYywmfhRiKyOeRv6mTebXe1b', 0, 'active', '2026-10-11 05:20:15', '2026-10-11 05:20:15', NULL),
(618, 620, 1, '84338590', '84338590', 'MOCHAMMAD IMRON BAFADHOL', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_7TwUovydaGubGiSYdYjBTiKX', 0, 'active', '2026-10-11 05:20:16', '2026-10-11 05:20:16', NULL),
(619, 621, 1, '886798163', '886798163', 'MUHAMMAD WILDAN ZAIN', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_EdoFSkNfVwNv0Kcz2deaQmae', 0, 'active', '2026-10-11 05:20:22', '2026-10-11 05:20:22', NULL),
(620, 622, 1, '3089527599', '3089527599', 'MUHAMMAD DIMAS MAULANA', 12, 'XII AGAMA 1', 'L', '2007-01-01', NULL, NULL, 'std_ZdGo93BjjEQuCKOh8Me1d7jW', 0, 'active', '2026-10-11 05:20:24', '2026-10-11 05:20:24', NULL),
(621, 623, 1, '3088245680', '3088245680', 'ARJU NAILAL MUNA', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_mXtC8dzQP6ZVC6cfKXzrzJ1b', 0, 'active', '2026-10-11 05:20:25', '2026-10-11 05:20:25', NULL),
(622, 624, 1, '3099588305', '3099588305', 'BAYYIN KAFKA AL BALKAH', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_OZGTcArurTc2ZmHI5sW1Dnvd', 0, 'active', '2026-10-11 05:20:27', '2026-10-11 05:20:27', NULL),
(623, 625, 1, '3073646976', '3073646976', 'CERAH WULANDARI', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_z1QKlhjNvx1FlebR6BzROK1W', 0, 'active', '2026-10-11 05:20:29', '2026-10-11 05:20:29', NULL),
(624, 626, 1, '3088929541', '3088929541', 'ELOK SAYYIDAH HALIMAH', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_hZ37QIrdA9agPSzLBaZOG8sx', 0, 'active', '2026-10-11 05:20:33', '2026-10-11 05:20:33', NULL),
(625, 627, 1, '3085093748', '3085093748', 'FAZA AGHNIA RAMADHANI', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_pqBO4mlHDmiN8BVJiOQIQZBd', 0, 'active', '2026-10-11 05:20:34', '2026-10-11 05:20:34', NULL),
(626, 628, 1, '81715914', '81715914', 'GHARIYAH AN NUFUS', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_DWSTESxReieqEMxPR8sePATe', 0, 'active', '2026-10-11 05:20:36', '2026-10-11 05:20:36', NULL),
(627, 629, 1, '3084755282', '3084755282', 'IMRO\'ATUN NAFIAH', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_k9NQtAyunsX9gt6OOfHbdoe2', 0, 'active', '2026-10-11 05:20:37', '2026-10-11 05:20:37', NULL),
(628, 630, 1, '96045239', '96045239', 'MEISHYFA NUR HIDAYAH', 12, 'XII AGAMA 2', 'P', '2007-01-01', NULL, NULL, 'std_UTeEIZj0ZGehMZb2BgHXZO6k', 0, 'active', '2026-10-11 05:20:38', '2026-10-11 05:20:38', NULL),
(629, 631, 1, '83727364', '83727364', 'NUR FADHILAH AL FATWA', 12, 'XII AGAMA 2', 'P', '2007-01-01', NULL, NULL, 'std_ZtSaMy9KFIK3S8AAb4i5nMxN', 0, 'active', '2026-10-11 05:20:38', '2026-10-11 05:20:38', NULL),
(630, 632, 1, '3086166052', '3086166052', 'RIZKY BULAN AZZAHRA', 12, 'XII AGAMA 2', 'P', '2007-01-01', NULL, NULL, 'std_BcYWRmr8z24BLymhaBy1E5fM', 0, 'active', '2026-10-11 05:20:39', '2026-10-11 05:20:39', NULL),
(631, 633, 1, '3089765493', '3089765493', 'SHIRLY CHAFIYA BINTA AHMAD', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_LhYoZ9nhK1YFMIdtNtVHDJT2', 0, 'active', '2026-10-11 05:20:40', '2026-10-11 05:20:40', NULL),
(632, 634, 1, '96191205', '96191205', 'SIFA SAHARANY', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_cqXjCxOWbfLzWwizZQrQC0gL', 0, 'active', '2026-10-11 05:20:41', '2026-10-11 05:20:41', NULL),
(633, 635, 1, '81232328', '81232328', 'SITI ZULVA ROHMATIN', 12, 'XII AGAMA 2', 'P', '2007-01-01', NULL, NULL, 'std_vvKlLqcfwjXd3RrbkXvjEwbb', 0, 'active', '2026-10-11 05:20:41', '2026-10-11 05:20:41', NULL),
(634, 636, 1, '3099671112', '3099671112', 'YESSY ARTANITA AZZUFA', 12, 'XII AGAMA 2', 'P', '2007-01-01', NULL, NULL, 'std_Xa4I7A7FiltNtL1gt3wz5Vge', 0, 'active', '2026-10-11 05:20:42', '2026-10-11 05:20:42', NULL),
(635, 637, 1, '3094597521', '3094597521', 'ZAHROTUL HAYATUD DUNNYA', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_NOZrnlImyDjQGTmPIaJRF98Q', 0, 'active', '2026-10-11 05:20:42', '2026-10-11 05:20:42', NULL),
(636, 638, 1, '3081450431', '3081450431', 'ZIYADATUL CHOIRIYAH', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_FhMHN1VAkU2ww3rNTUzoIncX', 0, 'active', '2026-10-11 05:20:43', '2026-10-11 05:20:43', NULL),
(637, 639, 1, '91170581', '91170581', 'IZHARRO LAVINA ABIDAH', 12, 'XII AGAMA 2', 'L', '2007-01-01', NULL, NULL, 'std_iWaZ1Z8KsME8BBz5PH7NxTIK', 0, 'active', '2026-10-11 05:20:43', '2026-10-11 05:20:43', NULL),
(638, 640, 1, '44635179', '44635179', 'SITI NUR FAZILA', 12, 'XII AGAMA 2', 'P', '2007-01-01', NULL, NULL, 'std_XtBtTMfeTSPAWc2r9SL5YxOF', 0, 'active', '2026-10-11 05:20:44', '2026-10-11 05:20:44', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `teams`
--

CREATE TABLE `teams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `competition_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `team_name` varchar(255) NOT NULL,
  `leader_student_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `team_members`
--

CREATE TABLE `team_members` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `team_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `role_in_team` enum('leader','member') NOT NULL DEFAULT 'member',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `phone` varchar(25) DEFAULT NULL,
  `school_id` bigint(20) UNSIGNED DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL,
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `username`, `phone`, `school_id`, `email_verified_at`, `password`, `must_change_password`, `password_changed_at`, `last_login_at`, `last_login_ip`, `status`, `remember_token`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Super Administrator', 'sistemprestasiku@gmail.com', 'superadmin', '085755969705', NULL, NULL, '$2y$12$ufkIiBnk5gei1REiLXdG3uY0QWIlzPjL69GWn7rlVESUXkBgO3ygm', 0, '2026-10-11 18:26:57', '2026-10-11 18:25:53', '114.5.221.219', 'active', NULL, '2026-10-11 05:06:56', '2026-10-11 18:26:57', NULL),
(3, 'ACHMAD AZAM MAULANA IBRAHIM', '20579998_109876976@siswa.prestasiku.id', '20579998_109876976', NULL, 1, NULL, '$2y$12$fl9HI68i2A0PvLIkANHp0OtmjXOAw5AlX2cgP4iDyLE0efMg3LfDa', 0, '2026-10-11 18:13:15', '2026-10-28 22:40:38', '114.8.224.113', 'active', NULL, '2026-10-11 05:15:47', '2026-10-28 22:40:38', NULL),
(4, 'ACHMAD DWI PRAMUDIA', '20579998_3098832744@siswa.prestasiku.id', '20579998_3098832744', NULL, 1, NULL, '$2y$12$5oV8CvVoC9PgvCYV7cVwY.8qK0jVARfFj73VRhfYC8jyde3rWGrRS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:48', '2026-10-11 05:15:48', NULL),
(5, 'ACHMAD KHOTIB ALMUZAQI', '20579998_78953495@siswa.prestasiku.id', '20579998_78953495', NULL, 1, NULL, '$2y$12$RdQKlyVZsByRS9.YVr8s.ORSL.WK.NPAyLPpq.T.hFYlYIidO45xW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:48', '2026-10-11 05:15:48', NULL),
(6, 'ACHSANUL TUMUHULAWA', '20579998_3111603066@siswa.prestasiku.id', '20579998_3111603066', NULL, 1, NULL, '$2y$12$9qadZ0dy6N0wK6N05ceZ4ec1YfkYzFfuQUIg17/zwYCt0n2uOIjf2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:49', '2026-10-11 05:15:49', NULL),
(7, 'ADHYAKSA TOPAS PRIYANDARU', '20579998_108901736@siswa.prestasiku.id', '20579998_108901736', NULL, 1, NULL, '$2y$12$qL5zFU1XOftZ960jZQYvu.fjInWnhuEE0.kjldX07heZm7IHk8PIa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:49', '2026-10-11 05:15:49', NULL),
(8, 'ADI SETIAWAN', '20579998_3103912632@siswa.prestasiku.id', '20579998_3103912632', NULL, 1, NULL, '$2y$12$otLS0VM4cFbY5F.2Hk0QluJKnno/ciEp7IigwACwtl65yKtekU1Qu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:50', '2026-10-11 05:15:50', NULL),
(9, 'ADIKA PUTRA AFANIN', '20579998_3109496521@siswa.prestasiku.id', '20579998_3109496521', NULL, 1, NULL, '$2y$12$Z7JSrt2F4s4hZ5Y7IpLM9.xUBWh68a146UGp0MOfCPkhQymjI6XdW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:50', '2026-10-11 05:15:50', NULL),
(10, 'AGENG MAHARDIKA', '20579998_117951786@siswa.prestasiku.id', '20579998_117951786', NULL, 1, NULL, '$2y$12$XhOK8zOxZLSjiW2Xf7sNBecXr/uQl9U8gQqq.nHZl5Qzb0Xg0X5YC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:51', '2026-10-11 05:15:51', NULL),
(11, 'AHMAD ABDURRAHMAN JAMALUDDIN', '20579998_3117714534@siswa.prestasiku.id', '20579998_3117714534', NULL, 1, NULL, '$2y$12$u.Gl4IHIFcTN95fLryddA.BziGd6.HHQiejqfTDz1T1QA355/WIiG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:51', '2026-10-11 05:15:51', NULL),
(12, 'AHMAD AUFAA MUTQINA', '20579998_102613249@siswa.prestasiku.id', '20579998_102613249', NULL, 1, NULL, '$2y$12$SkgmNcCGBzyzXtwgCQ86xefxmr/TKo6AnhWEGOnP2A3hlwSSmn33.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:51', '2026-10-11 05:15:51', NULL),
(13, 'AHMAD DANIEL VAHLEVY', '20579998_108579188@siswa.prestasiku.id', '20579998_108579188', NULL, 1, NULL, '$2y$12$x6WE4YdkHAun7CB6RyVx8uv1KIdx3e92CJAwfF/PjHAaqrru9K7AG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:52', '2026-10-11 05:15:52', NULL),
(14, 'AHMAD HABIB FURQONI', '20579998_3109288571@siswa.prestasiku.id', '20579998_3109288571', NULL, 1, NULL, '$2y$12$a8DwPh/vmCZJtjc.zCXv2.T35B0B.0a.8VBuHRpIUvC8DsS2vFPwy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:52', '2026-10-11 05:15:52', NULL),
(15, 'AHMAD MUKAFFIN RIZQILLAH', '20579998_3097415133@siswa.prestasiku.id', '20579998_3097415133', NULL, 1, NULL, '$2y$12$STKRc4ZcVCzM1KSo3ysYcOBrp8.31V7ZqoWnysAdKhwgBNvBrKVEO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:53', '2026-10-11 05:15:53', NULL),
(16, 'AHMAD MUTHI\' BIAMRILLAH AL-MUSTHOFA', '20579998_111052463@siswa.prestasiku.id', '20579998_111052463', NULL, 1, NULL, '$2y$12$/dYQZjvfHE6GBWWyqTZFXONSd/zp7YnKet0I83Dz.gmTm1T4Kf3rm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:54', '2026-10-11 05:15:54', NULL),
(17, 'AHMAD RASYA SYARIFUDIN', '20579998_92672167@siswa.prestasiku.id', '20579998_92672167', NULL, 1, NULL, '$2y$12$ss/.mzPgJgrUJRktilIZEOWU4b/5s85BKtILhzMIdIRCx/OhvOp7C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:54', '2026-10-11 05:15:54', NULL),
(18, 'AHMAD SAMUEL AL BALHA', '20579998_3118928337@siswa.prestasiku.id', '20579998_3118928337', NULL, 1, NULL, '$2y$12$1pDPE0uXmm8FHSyxE9N2BezzjKKpa.3U1XDsfbDUotztXbtJ4nKPm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:54', '2026-10-11 05:15:54', NULL),
(19, 'AHMAD VICKY JAELANI', '20579998_3110370715@siswa.prestasiku.id', '20579998_3110370715', NULL, 1, NULL, '$2y$12$YgjRvrgI5LJgUy4n.YLhi.zN67PAQYKFsn55mLPoEC6B7s8eUaU2m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:55', '2026-10-11 05:15:55', NULL),
(20, 'ALDI SETIAWAN', '20579998_3107348745@siswa.prestasiku.id', '20579998_3107348745', NULL, 1, NULL, '$2y$12$LXTThQsZKNzpr7aFtYT1qeK86IKBg7CNnd7dpBBgY8fBRmaFRooqa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:55', '2026-10-11 05:15:55', NULL),
(21, 'ALFITO AIDAN RAFIF', '20579998_118092541@siswa.prestasiku.id', '20579998_118092541', NULL, 1, NULL, '$2y$12$J/GTsiya3m1t9YDJWhrtIO2zkk.9ywwMAHKA.LbHr.pXlXFg0fWNe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:56', '2026-10-11 05:15:56', NULL),
(22, 'ALFREZZI KHAUFINDA', '20579998_106288129@siswa.prestasiku.id', '20579998_106288129', NULL, 1, NULL, '$2y$12$7zp7c/EJgqBA85CERbguzukNW1ti/0sp3SMqnkSfXU6bePcOiBxFa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:57', '2026-10-11 05:15:57', NULL),
(23, 'ANANDA RISKY RADHITYA', '20579998_113401710@siswa.prestasiku.id', '20579998_113401710', NULL, 1, NULL, '$2y$12$k.WgpbuIuR9wenqr5k6IVOjKG.Og3VvJgmQc1T4noZm2J5IgiCri.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:57', '2026-10-11 05:15:57', NULL),
(24, 'AQIL CANDRA ROBANI', '20579998_105973093@siswa.prestasiku.id', '20579998_105973093', NULL, 1, NULL, '$2y$12$YK1luC/R1jYTu0qpZRgCLuNYncoW9I45l/pc1SBiH.9P/9R9utZEG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:58', '2026-10-11 05:15:58', NULL),
(25, 'ARDIAN RIKO SAPUTRA', '20579998_108459146@siswa.prestasiku.id', '20579998_108459146', NULL, 1, NULL, '$2y$12$KZpbgcCkJAgcwsPSwApxYOYUqc1QeZ21Pa1RE35PpF010vz65qEJO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:58', '2026-10-11 05:15:58', NULL),
(26, 'ATIF SYAHIN', '20579998_3115950702@siswa.prestasiku.id', '20579998_3115950702', NULL, 1, NULL, '$2y$12$KXJOt75B5hzKEXaJkMI9neRgpppJGBIKPQCapPbrVqGqoBg0iY.jm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:58', '2026-10-11 05:15:58', NULL),
(27, 'AZIZAN MARVIN JIYA HAZIQ', '20579998_119464561@siswa.prestasiku.id', '20579998_119464561', NULL, 1, NULL, '$2y$12$CVHAWNRAedWe/HWGOfHFTu9cDi2TLzGApe6LKcnDvllMpDU1JGdMe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:59', '2026-10-11 05:15:59', NULL),
(28, 'AZKA FARIS MUHAMMAD', '20579998_112066727@siswa.prestasiku.id', '20579998_112066727', NULL, 1, NULL, '$2y$12$4GG4u.OE7QddT0wJkt1GkeJixwxgbyntOKnRPn5abI.B/wQuTJBW6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:15:59', '2026-10-11 05:15:59', NULL),
(29, 'BALYAN HABIL GHATAFAN', '20579998_112275423@siswa.prestasiku.id', '20579998_112275423', NULL, 1, NULL, '$2y$12$pYfAO0j3cPQxlNF4aGsRzOrD/HWRum9.7cpzuA1Q2CF26DlnHySo2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:00', '2026-10-11 05:16:00', NULL),
(30, 'BIMA RAMADHAN PRATAMA', '20579998_119054313@siswa.prestasiku.id', '20579998_119054313', NULL, 1, NULL, '$2y$12$a2FOGbcATC6LXPQZ8AtzsO/q.qEkZ99/4/CbD5eg4WPWC5EjGUgXm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:00', '2026-10-11 05:16:00', NULL),
(31, 'CHOIRUDIN ISMAIL', '20579998_3113225694@siswa.prestasiku.id', '20579998_3113225694', NULL, 1, NULL, '$2y$12$XA/zCAWPjhPdmav7SxliHuvb1ASqbgMQhIGUKLYgCd14bw9oWuNCe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:01', '2026-10-11 05:16:01', NULL),
(32, 'EMILLUL FATAH', '20579998_103777717@siswa.prestasiku.id', '20579998_103777717', NULL, 1, NULL, '$2y$12$.UNUCOHvJ9SKN/Ju/iUqK.8eSb..lYFKFJR/b5goHHPwqzBfYqVxW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:01', '2026-10-11 05:16:01', NULL),
(33, 'FADHIL SAADI ZAHID', '20579998_101229766@siswa.prestasiku.id', '20579998_101229766', NULL, 1, NULL, '$2y$12$PTrlHWm01JsZbBrdgxl6puQcE1ZohOEm8C2h6AXgfOGU0pshVlb0e', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:02', '2026-10-11 05:16:02', NULL),
(34, 'GILANG FAJAR RAHMATULLAH', '20579998_116522335@siswa.prestasiku.id', '20579998_116522335', NULL, 1, NULL, '$2y$12$9GgFlyVNViJWrQYCbTInyOPOhXVALwxtvhUnMnvpFFC23kzWnem8e', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:03', '2026-10-11 05:16:03', NULL),
(35, 'AHMAD', '20579998_116838295@siswa.prestasiku.id', '20579998_116838295', NULL, 1, NULL, '$2y$12$crtRfU9vrzYN76Up3n0.b.hLGIqXjww5fCUe87D0ZevSewDLYJ6Qm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:04', '2026-10-11 05:16:04', NULL),
(36, 'FARID DEMITRA PRAYOGA', '20579998_113041483@siswa.prestasiku.id', '20579998_113041483', NULL, 1, NULL, '$2y$12$V//PzvlS82aHLZ1gS2JbiefJqcwBe4nW2kxE5otEhiEa0a1fsLjHS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:05', '2026-10-11 05:16:05', NULL),
(37, 'FINO HAIDAR AZAM', '20579998_114511448@siswa.prestasiku.id', '20579998_114511448', NULL, 1, NULL, '$2y$12$XPI1rSNUFP33H2mFLQKLkefV6QMiCjNypQzOw3HH.yZWx3Dec/IQ2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:06', '2026-10-11 05:16:06', NULL),
(38, 'HAFIZ AZIM ABDILLAH', '20579998_113995793@siswa.prestasiku.id', '20579998_113995793', NULL, 1, NULL, '$2y$12$ZFFb2RsJ2YZZX6t66KRC1eahNCBrkPJI7uDkCv1eyyIrxLAWNRFXa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:06', '2026-10-11 05:16:06', NULL),
(39, 'IKRAR LANGIT MERDEKA KURNIAWAN', '20579998_105023493@siswa.prestasiku.id', '20579998_105023493', NULL, 1, NULL, '$2y$12$jUtlts/WWyFY73Fdz/6XjOwpVhDMdLPdOA/fw3P5UqsRgCeL32wxK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:07', '2026-10-11 05:16:07', NULL),
(40, 'JAVIERI RAFIF SAKHI ALMAHABIH', '20579998_117630810@siswa.prestasiku.id', '20579998_117630810', NULL, 1, NULL, '$2y$12$TMspWOPYNVYI1MpmZbgWo.b34lJLEPQCtfe879ogLAjcUE.gX4ivC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:07', '2026-10-11 05:16:07', NULL),
(41, 'KAFFA MACHY ALMUSAFY', '20579998_119988882@siswa.prestasiku.id', '20579998_119988882', NULL, 1, NULL, '$2y$12$0MfhesFrm3BVdDbRmCSnOOE8QstY29s9GwrNwuNsnI9.aV.WN1HkG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:08', '2026-10-11 05:16:08', NULL),
(42, 'KESIT WAHYU ARYAWINDARU', '20579998_97556803@siswa.prestasiku.id', '20579998_97556803', NULL, 1, NULL, '$2y$12$WK0TP3nJUfY8sgBuOivOWuRXsWkod9c6LLkaMaxweRYCXxO1RWAxO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:08', '2026-10-11 05:16:08', NULL),
(43, 'KOEN AZKA ZACHARI', '20579998_103272204@siswa.prestasiku.id', '20579998_103272204', NULL, 1, NULL, '$2y$12$.KATT3NtFdhvb0Z119YNkelyaj.UcoI/JN5FwsGO8Iw2V9Lqu2VV.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:09', '2026-10-11 05:16:09', NULL),
(44, 'M KHUFAF ADZIKRILLAH RAMADHAN', '20579998_103802334@siswa.prestasiku.id', '20579998_103802334', NULL, 1, NULL, '$2y$12$QSqry1SNcb86xJGKLK0WZ.0EYzUmPj/BBKrDA8GqhjB/lWeJJkTyO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:09', '2026-10-11 05:16:09', NULL),
(45, 'M. REFAN ADITYA RAMADHAN', '20579998_112036109@siswa.prestasiku.id', '20579998_112036109', NULL, 1, NULL, '$2y$12$5lBZsu1IHHTag17gxC3nK.lA2U9vhWBQ28Hw8ICBidAU.ZdwjfMMu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:10', '2026-10-11 05:16:10', NULL),
(46, 'M.KAFIL KHOTHIBUL UMAM', '20579998_3114906538@siswa.prestasiku.id', '20579998_3114906538', NULL, 1, NULL, '$2y$12$5UU5iu9dtgoPlGET6bOA.OlzOdUpGiaN20z2T0OaU9YtUQl5OqwCW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:10', '2026-10-11 05:16:10', NULL),
(47, 'M.SENDI STIAWAN PUTRA PRATAMA', '20579998_112595247@siswa.prestasiku.id', '20579998_112595247', NULL, 1, NULL, '$2y$12$I5a2jVv7fnqOJEV5pcBE6uE0eaYtaj1H9WH2ACVfHeLvo.v9nSjKu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:11', '2026-10-11 05:16:11', NULL),
(48, 'MAULA ZIFRIEL ZUHAIRI NURSYAMS', '20579998_3107047232@siswa.prestasiku.id', '20579998_3107047232', NULL, 1, NULL, '$2y$12$qkhA4RDl4t46NCNMKyzsVOK7dLwIUrVYaR4Y3sKN2n8nupmzxZ4ZG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:11', '2026-10-11 05:16:11', NULL),
(49, 'MAULANA BAHAUDIN FAUZAN', '20579998_119767184@siswa.prestasiku.id', '20579998_119767184', NULL, 1, NULL, '$2y$12$hygYXKx/sB.v6S02WrAHYuUTV6rOxOx1bR3dyd28Lsn4vMTndTCRG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:11', '2026-10-11 05:16:11', NULL),
(50, 'MISBAKHUS SHABRI RUSMANUDIN', '20579998_129444631@siswa.prestasiku.id', '20579998_129444631', NULL, 1, NULL, '$2y$12$55.4xFKlAwD1uauNsfRUguzoLVFvbQh44pG2zOF0O0bb3MXeAkkJi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:12', '2026-10-11 05:16:12', NULL),
(51, 'MOCHAMAD AFGAN IBRAHIM', '20579998_101496176@siswa.prestasiku.id', '20579998_101496176', NULL, 1, NULL, '$2y$12$ABUn4H2fVxEtbYqDb.KVIeULEGHMms16zQsvQIwTwTY6VbcbR2/E6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:12', '2026-10-11 05:16:12', NULL),
(52, 'MOH ARIFIN ILHAM', '20579998_3107780187@siswa.prestasiku.id', '20579998_3107780187', NULL, 1, NULL, '$2y$12$8jy/mluT7JfTc9LzdaBReeGeGu7Y1cbXGWli7xqQZWn2pa4sW5eeW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:13', '2026-10-11 05:16:13', NULL),
(53, 'MOH. IFTAHUR ROZIQIN', '20579998_103629847@siswa.prestasiku.id', '20579998_103629847', NULL, 1, NULL, '$2y$12$H4rmUNlYFz4bcqqX3ahVeOwFiALdm7WFY9nH6qCY7e8jEzwPpUv4e', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:13', '2026-10-11 05:16:13', NULL),
(54, 'MOH. ISHOMUDDIN AL HANNAN', '20579998_109782484@siswa.prestasiku.id', '20579998_109782484', NULL, 1, NULL, '$2y$12$9MpAuqLwL0iHcen8G7uFkeGHh3nG35Yxn45U6EhC.20T0uerpR5t.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:14', '2026-10-11 05:16:14', NULL),
(55, 'MOH.IRFAN IBRAHIM SYA\'BANI', '20579998_115387792@siswa.prestasiku.id', '20579998_115387792', NULL, 1, NULL, '$2y$12$ODGcr0ZVr31VPmiuPAsMNu3.S05PuqfYDobXR6TWgADmvjCXDr52a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:14', '2026-10-11 05:16:14', NULL),
(56, 'MOHAMMAD DAFFA HAFIDZ INIESTA', '20579998_3102346398@siswa.prestasiku.id', '20579998_3102346398', NULL, 1, NULL, '$2y$12$3JkL7LfCbYM7ZLRB5ovRe.XY5bdN.4HM8mtdNq/HJyEOWB2.QTVWy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:14', '2026-10-11 05:16:14', NULL),
(57, 'MOHAMMAD HAFIDZ MUKMIN EL HUSNI', '20579998_3114883341@siswa.prestasiku.id', '20579998_3114883341', NULL, 1, NULL, '$2y$12$ONGPWSsIJ4rPwOmru1Y/seoJBmQUTkWjl4NWd7ZX2v2lDyT/W3sL2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:15', '2026-10-11 05:16:15', NULL),
(58, 'MOHAMMAD HAZIQ ILMAN HIJAZI', '20579998_3106302415@siswa.prestasiku.id', '20579998_3106302415', NULL, 1, NULL, '$2y$12$PEHnkSAgUbChkckxpYIw0uue7eailU9M2shoBOml4PbfF6lUofBge', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:15', '2026-10-11 05:16:15', NULL),
(59, 'MOHAMMAD TSAQIF DZIKRILLAH', '20579998_93161340@siswa.prestasiku.id', '20579998_93161340', NULL, 1, NULL, '$2y$12$LIfczyKHWDMxYwqorMSlKOin9oSnkmZOrUGki/YQCHt7KNf357Mfu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:16', '2026-10-11 05:16:16', NULL),
(60, 'MUHAMMAD ABDILLAH MAHASURA AL-FARUQ', '20579998_3105566106@siswa.prestasiku.id', '20579998_3105566106', NULL, 1, NULL, '$2y$12$VvdD3BG2AvWmexIe5kYVveJcBBWUL341ThCPQNZnJ8lATblIaHjcm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:16', '2026-10-11 05:16:16', NULL),
(61, 'MUHAMMAD ADLAN FAHMI', '20579998_102304054@siswa.prestasiku.id', '20579998_102304054', NULL, 1, NULL, '$2y$12$hgBJycNttaBpNtF.uZgTX.T6N25xjlULQkcwylQd2kXcjWeQae3su', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:17', '2026-10-11 05:16:17', NULL),
(62, 'MUHAMMAD AHDA ASYSYAUQI', '20579998_3110507484@siswa.prestasiku.id', '20579998_3110507484', NULL, 1, NULL, '$2y$12$R4bGgnA8zmwgM1o99t9bqOKC0b0Yd6EOU5VLDS2FsFM0FmL.kXpju', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:17', '2026-10-11 05:16:17', NULL),
(63, 'MUHAMMAD ALFIAN NAJA', '20579998_3103068661@siswa.prestasiku.id', '20579998_3103068661', NULL, 1, NULL, '$2y$12$GBGWXiX4xDXzlrR61zQBV.TLmn9Bw3vyJATYjNbJVuRmesbVNnNcW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:18', '2026-10-11 05:16:18', NULL),
(64, 'MUHAMMAD ALFINO', '20579998_104937480@siswa.prestasiku.id', '20579998_104937480', NULL, 1, NULL, '$2y$12$tOnbAnMsfU.qTgGnaVl04OxSFvnfRetas/SqPUbJ2wX.iECZ4bRXa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:18', '2026-10-11 05:16:18', NULL),
(65, 'MUHAMMAD ALIF SYAFIQ NUR RISKY', '20579998_107149297@siswa.prestasiku.id', '20579998_107149297', NULL, 1, NULL, '$2y$12$V7tsX8RP6ONEmIg8nIYEjeosvKb9whG2xscs7NzdPsERV9AdT/BuW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:19', '2026-10-11 05:16:19', NULL),
(66, 'MUHAMMAD ARGATHA ROMADHONI', '20579998_3116328211@siswa.prestasiku.id', '20579998_3116328211', NULL, 1, NULL, '$2y$12$jfaKCN.4JibebafAROZHpOZ.CoaGbaUhor0E4SM5AcRgKk9IP7cIu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:19', '2026-10-11 05:16:19', NULL),
(67, 'TOHA HUSEIN', '20579998_118597649@siswa.prestasiku.id', '20579998_118597649', NULL, 1, NULL, '$2y$12$fNoxq3w5EYDqtkwCpkGigul776664zzBkU/ApYxQW5QuyN7r28X.K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:19', '2026-10-11 05:16:19', NULL),
(68, 'MOHAMMAD ABDUL AZIZ', '20579998_104758724@siswa.prestasiku.id', '20579998_104758724', NULL, 1, NULL, '$2y$12$UJECoznLkOpj1twr1sEo9O624a1tktHDQTN2N9cRXEFLwpOVxAf/C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:20', '2026-10-11 05:16:20', NULL),
(69, 'MUHAMMAD ARSYIL AGUSTINO RAMADANI', '20579998_3106610085@siswa.prestasiku.id', '20579998_3106610085', NULL, 1, NULL, '$2y$12$WOnWoY3YoBydSLE5CQdoHuty5iUAnspb9Sj0wnjv0USMJT7qUa6ue', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:20', '2026-10-11 05:16:20', NULL),
(70, 'MUHAMMAD AZIS CHOLILULLOH', '20579998_3106152592@siswa.prestasiku.id', '20579998_3106152592', NULL, 1, NULL, '$2y$12$hYDOUY86cXIo5HxQcTNfnupnTI5qr8BN/vO2ja0URWmmzfGkNiLwi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:21', '2026-10-11 05:16:21', NULL),
(71, 'MUHAMMAD AZZAMIR JAUHAR GHOFUR', '20579998_114874564@siswa.prestasiku.id', '20579998_114874564', NULL, 1, NULL, '$2y$12$mie3XLjn66FrpDo/TPXQs.wgqukMprMQrBP/7mWZd2MV7PtFA.2Ny', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:21', '2026-10-11 05:16:21', NULL),
(72, 'MUHAMMAD BAHI BARDAN', '20579998_103139222@siswa.prestasiku.id', '20579998_103139222', NULL, 1, NULL, '$2y$12$O0qzGp0z2N6mmFKYlIsgqOEwhvjTSN76hTQE1tOc.clp71PtoOiIq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:22', '2026-10-11 05:16:22', NULL),
(73, 'MUHAMMAD FAQIH PUTRA WIRATAMA', '20579998_3108354613@siswa.prestasiku.id', '20579998_3108354613', NULL, 1, NULL, '$2y$12$SNAWc5dGbKwWgelClxkR6.d8CJoXwjsaPwxo.1YZOf9Y3lWlDjTwO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:22', '2026-10-11 05:16:22', NULL),
(74, 'MUHAMMAD GHULAM SYAUQI', '20579998_3105237916@siswa.prestasiku.id', '20579998_3105237916', NULL, 1, NULL, '$2y$12$IywuICaCGHUg6MIe8WHe5O9W0.UO26uL8ALCfWGruftELNc75Ytzi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:23', '2026-10-11 05:16:23', NULL),
(75, 'MUHAMMAD ILHAM SANTOSO', '20579998_3100860037@siswa.prestasiku.id', '20579998_3100860037', NULL, 1, NULL, '$2y$12$qzQzn9IiUFZ3RnCpd8o4/OY9FOeVUvXVqwXlDUfF5pE2dqOm45OeC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:23', '2026-10-11 05:16:23', NULL),
(76, 'MUHAMMAD IZZAM AUFA ROSYID', '20579998_108285584@siswa.prestasiku.id', '20579998_108285584', NULL, 1, NULL, '$2y$12$ORsYFef91yxDTZC48ONw3udkrOlFRCqw1GHE2Im8/XbHk.TUNrtQq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:23', '2026-10-11 05:16:23', NULL),
(77, 'MUHAMMAD KAFFABIH', '20579998_117796561@siswa.prestasiku.id', '20579998_117796561', NULL, 1, NULL, '$2y$12$uRQocXjeJWaMmDwfU/W7tuBxCc7Nch2bjwEcHp0pTzLD80hwZEZJG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:24', '2026-10-11 05:16:24', NULL),
(78, 'MUHAMMAD NASHRULLOH', '20579998_3105196421@siswa.prestasiku.id', '20579998_3105196421', NULL, 1, NULL, '$2y$12$z.Qa2ObByxwJFPr/9nsVQeFmMBEjeFdfLChrTLVI2ohUVa2jGKBsO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:24', '2026-10-11 05:16:24', NULL),
(79, 'MUHAMMAD NAZRUL ALI AUFA', '20579998_3104256842@siswa.prestasiku.id', '20579998_3104256842', NULL, 1, NULL, '$2y$12$4WiykICdBc7AKlyb/EWz2udyLQzkkwHfy23vz8w7CQSA7pbsZguk6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:25', '2026-10-11 05:16:25', NULL),
(80, 'MUHAMMAD PRIYO MAHARDIKA JAUHAR', '20579998_111678344@siswa.prestasiku.id', '20579998_111678344', NULL, 1, NULL, '$2y$12$88wTtAh8NCLAht9rV7erYOmFuHxFvTVFxF6vSmYqjMJttcAsR69RG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:25', '2026-10-11 05:16:25', NULL),
(81, 'MUHAMMAD REZA SYA\'BANI', '20579998_104877294@siswa.prestasiku.id', '20579998_104877294', NULL, 1, NULL, '$2y$12$O243pAwx8w.EH0W1Ku0KYuO.IWi4fErEM4JqNxBGm4vgnqJyoERqK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:26', '2026-10-11 05:16:26', NULL),
(82, 'MUHAMMAD RIZQI AMRULLOH', '20579998_3118961302@siswa.prestasiku.id', '20579998_3118961302', NULL, 1, NULL, '$2y$12$JiQeXA4sP4Q85vnWxfcDpeKUcc6UK.u6b9d6kIVZ6/CgHVkFeaLmu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:26', '2026-10-11 05:16:26', NULL),
(83, 'MOHAMMAD ULIL ABSHOR', '20579998_3100172496@siswa.prestasiku.id', '20579998_3100172496', NULL, 1, NULL, '$2y$12$eyEtAlQDDTAf0tnsoD4sqOvTdx0IEgSYuy5j4d0b6ul7Us.5VZAxy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:27', '2026-10-11 05:16:27', NULL),
(84, 'MUHAMMAD YAFI SHAUQI NAJMI', '20579998_119111692@siswa.prestasiku.id', '20579998_119111692', NULL, 1, NULL, '$2y$12$vW2wdV.RKnw5cBuxeHwL1uHyottkiQs.teOcnne/qpuGkL60UyDCW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:28', '2026-10-11 05:16:28', NULL),
(85, 'MUHAMMAD ZIDANE ELFOUST', '20579998_3105434208@siswa.prestasiku.id', '20579998_3105434208', NULL, 1, NULL, '$2y$12$YQp2Fkrq7aW5qgbAE3.Y9ubc9NKmfyoWZZ3uVgyYmQuVb0v4Rcz.q', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:29', '2026-10-11 05:16:29', NULL),
(86, 'MUKH. HAIDAR IRSYAD AL FAROUK', '20579998_3113457876@siswa.prestasiku.id', '20579998_3113457876', NULL, 1, NULL, '$2y$12$fMnoNps3PvKFIPAdYYS/nuonvslILBSzOi7A0TgDWlTpKzsrl5eyi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:30', '2026-10-11 05:16:30', NULL),
(87, 'MUKHAMMAD HARIS ABDULLAH AZAM', '20579998_119837205@siswa.prestasiku.id', '20579998_119837205', NULL, 1, NULL, '$2y$12$2k9AVrQOANxpuL/.SBbUB.5t1att0qLRrLFln07x5y0KaCsTDgQoK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:31', '2026-10-11 05:16:31', NULL),
(88, 'MUZANI FAWWAZ AHMAD NIYAZI', '20579998_117461658@siswa.prestasiku.id', '20579998_117461658', NULL, 1, NULL, '$2y$12$/V7vkpe2s57PU6913L9B8e4ahmagYDsqejsEL9vFOMuMiabHZuVoG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:32', '2026-10-11 05:16:32', NULL),
(89, 'NANDA FAREL ARDIYANSYAH', '20579998_119316296@siswa.prestasiku.id', '20579998_119316296', NULL, 1, NULL, '$2y$12$xHup4Q6vdLECxRCC3o2ZTu9aFK8RBaX.KkxQSVbqjfRv.fsMhgvSi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:32', '2026-10-11 05:16:32', NULL),
(90, 'NEO ARISTYANTO', '20579998_115217354@siswa.prestasiku.id', '20579998_115217354', NULL, 1, NULL, '$2y$12$SJkLYTNSqaN4x/fH8QzoxuqKc0q9TGY04jSbk/xTs0ZrvhaL0lZ8.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:33', '2026-10-11 05:16:33', NULL),
(91, 'RAIHAN AKBAR MAULANA', '20579998_95915224@siswa.prestasiku.id', '20579998_95915224', NULL, 1, NULL, '$2y$12$NXczd1o8bd0t1AUUZB8YV.BPGGUxw4uOLCIJC.WLuKXlv1eqOq12m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:33', '2026-10-11 05:16:33', NULL),
(92, 'REZKI ADITYA PRATAMA', '20579998_103861530@siswa.prestasiku.id', '20579998_103861530', NULL, 1, NULL, '$2y$12$uuSkX82HD3q/Le2Y9n/dg.9Org7w5n/6vg0N7cbUWNCyfvyZKDxcO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:34', '2026-10-11 05:16:34', NULL),
(93, 'ROYYAN ADZIKRI', '20579998_112928724@siswa.prestasiku.id', '20579998_112928724', NULL, 1, NULL, '$2y$12$pKFxPEfux2KUBvnkm.RPPeUJv3Jp6qib2Rrylo8SPdfYKhga1jGlG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:34', '2026-10-11 05:16:34', NULL),
(94, 'SALMAN AL FARISI', '20579998_104029138@siswa.prestasiku.id', '20579998_104029138', NULL, 1, NULL, '$2y$12$v5CpjeL4OIp9Sx2JOpnmluQMBxha5SH84cK188weQrgS.lqM4tH/a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:35', '2026-10-11 05:16:35', NULL),
(95, 'SYAHRUL AHMAD AN NUR', '20579998_117934620@siswa.prestasiku.id', '20579998_117934620', NULL, 1, NULL, '$2y$12$gIR9jxfczgQd9tZzGv0ViOzdmlXEZzwjc5wjcFdfoCuWlg.mBl6aK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:35', '2026-10-11 05:16:35', NULL),
(96, 'TEZZAR RACYEL YUVEBYAN', '20579998_116557257@siswa.prestasiku.id', '20579998_116557257', NULL, 1, NULL, '$2y$12$KzkMp6yMcl9MZfyKZvuYdeyVzCl9Y0mU9wgzQBDJnCzZ1I9DghGw2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:36', '2026-10-11 05:16:36', NULL),
(97, 'WALID MIFTAHUSSURUR', '20579998_3115214625@siswa.prestasiku.id', '20579998_3115214625', NULL, 1, NULL, '$2y$12$lidLddFcoqSiiZcQhgWovuyk.gNb3mbQP6v1ix6Aue.HSRhyXnD6K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:37', '2026-10-11 05:16:37', NULL),
(98, 'YAVIL MU\'MIN', '20579998_3104967030@siswa.prestasiku.id', '20579998_3104967030', NULL, 1, NULL, '$2y$12$zn/U45CXnrgTCvyT0scdYONlyinBlT40/HI3/5FSKTGF3VZFxCLMK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:37', '2026-10-11 05:16:37', NULL),
(99, 'ARJEN LEONADA FATEHA', '20579998_106823979@siswa.prestasiku.id', '20579998_106823979', NULL, 1, NULL, '$2y$12$1AWJ4qLqRAkKUqSWyMJ2WOpFwVfhE7JnIS7vw477j08JO.2fwB1Qy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:38', '2026-10-11 05:16:38', NULL),
(100, 'ABELIA DWI PUTRI', '20579998_115111382@siswa.prestasiku.id', '20579998_115111382', NULL, 1, NULL, '$2y$12$4CnkiagvhgxIGBPRG2SkZuUjCbvYXcGtICfGCUq/5z.GIbno2OvM.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:38', '2026-10-11 05:16:38', NULL),
(101, 'ADINDA FATIMATUS ZAHRA', '20579998_92814357@siswa.prestasiku.id', '20579998_92814357', NULL, 1, NULL, '$2y$12$A2dGN1sQX54JwdPQdB2j5eIBWxT/w8iIyPv82hB0dalHSjPF6Xdty', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:39', '2026-10-11 05:16:39', NULL),
(102, 'ADIZZA AZZAHRA', '20579998_112826555@siswa.prestasiku.id', '20579998_112826555', NULL, 1, NULL, '$2y$12$O9Sd1W4OK9OAEkaRj/Y86.6QwJEKpZfwE52Szcz5ODttG/xfgusu.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:39', '2026-10-11 05:16:39', NULL),
(103, 'AFIFAH KHAIRUNNISA AZZAHRA', '20579998_114907623@siswa.prestasiku.id', '20579998_114907623', NULL, 1, NULL, '$2y$12$Wyv2/ikUNmNhYWUTPZFw4uMF1IMdEX/9u5AsKYmQmWb/Ypgjt4Y7S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:40', '2026-10-11 05:16:40', NULL),
(104, 'AISYAH AXELIA BASTIAN', '20579998_109417495@siswa.prestasiku.id', '20579998_109417495', NULL, 1, NULL, '$2y$12$Lhy8YMEzxvHkxUBqUxXKv.mqUetqymfkXBH/s38baS3r3EzZ2DgHy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:40', '2026-10-11 05:16:40', NULL),
(105, 'AISYAH FARICHATUL MUFIDAH', '20579998_112096547@siswa.prestasiku.id', '20579998_112096547', NULL, 1, NULL, '$2y$12$vI0ZWeTIb2A0XfqzINNwg.PJKF9aeQF.bh8goKXQoCqxJzLb/wCE6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:41', '2026-10-11 05:16:41', NULL),
(106, 'AISYAH WAFIYATUL HUSNA', '20579998_3112790590@siswa.prestasiku.id', '20579998_3112790590', NULL, 1, NULL, '$2y$12$2TNvgHSfkyPxwQkz9XKXQ.YWgdsxfZ6N65eCrzP7aWbYsl/4H7hsq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:41', '2026-10-11 05:16:41', NULL),
(107, 'AKHLA MURIDATUL QUDRIYYAH', '20579998_3113322236@siswa.prestasiku.id', '20579998_3113322236', NULL, 1, NULL, '$2y$12$UyF5HLHHVEBthZNYxx.Jhe5NPQ5jmRnK7b/yXNi7243TV1a7IopRO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:41', '2026-10-11 05:16:41', NULL),
(108, 'ALISHA NAZURAH AZZALEA HARTONO', '20579998_117913806@siswa.prestasiku.id', '20579998_117913806', NULL, 1, NULL, '$2y$12$zMbBbBb/rRTmA0DNfOj9TuhxyXZVCYnYsblvzxP4ZMbC0SJnsw2.W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:42', '2026-10-11 05:16:42', NULL),
(109, 'ALLISA QOTRUN FILOSOFIAH PUTRI', '20579998_119138841@siswa.prestasiku.id', '20579998_119138841', NULL, 1, NULL, '$2y$12$oYST.4nEJJvZI1YaFYNl3.Z.P6Tn3Ba8OFLKQgchZ5vC8Yd7iCCcG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:42', '2026-10-11 05:16:42', NULL),
(110, 'ALVINA GUSTI MALIKA', '20579998_3117403038@siswa.prestasiku.id', '20579998_3117403038', NULL, 1, NULL, '$2y$12$AsTIvX/A44cMm7Ur.CCDMOYzurVzUausZ4.PxUCGE7vrLmzNDJ38.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:43', '2026-10-11 05:16:43', NULL),
(111, 'ANA AISYAH NUR RAMADHANI', '20579998_3112748473@siswa.prestasiku.id', '20579998_3112748473', NULL, 1, NULL, '$2y$12$xKK4LOw.cksOiirxInlVqOT3aaZUMKmZFSmr7mE47bZBrNGBmR7Ry', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:43', '2026-10-11 05:16:43', NULL),
(112, 'ANZHA ADININGTYAS', '20579998_121839069@siswa.prestasiku.id', '20579998_121839069', NULL, 1, NULL, '$2y$12$FWQNHYL20.FzX0Sr/goAA.L77iN/Pqi63dWH9TmpDgP9eTOfRb4pq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:43', '2026-10-11 05:16:43', NULL),
(113, 'APRILIA LAILATUN NI\'MAH', '20579998_108827596@siswa.prestasiku.id', '20579998_108827596', NULL, 1, NULL, '$2y$12$ypXf2JVdBiKh3.4WF3vq0.R6xZL5yLVxWaDiGElNYzrufqdtcVGvq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:44', '2026-10-11 05:16:44', NULL),
(114, 'AQILA FADIA HAYAK', '20579998_116812098@siswa.prestasiku.id', '20579998_116812098', NULL, 1, NULL, '$2y$12$n8xJulEJ42GXMW/YiJj7E.Sha1IhfeSCK3gC.WiSOpTT9XJZhqLMy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:45', '2026-10-11 05:16:45', NULL),
(115, 'AQILLA GUSMELTIANA SUPRASTYO', '20579998_119229188@siswa.prestasiku.id', '20579998_119229188', NULL, 1, NULL, '$2y$12$zB0bDPGJexvpn82D9fdQ1eCWAN0JEOhCjiw8U.BnbsckhojEDa422', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:45', '2026-10-11 05:16:45', NULL),
(116, 'ASSYIFA MAKARIMA AIZTANIA', '20579998_108653891@siswa.prestasiku.id', '20579998_108653891', NULL, 1, NULL, '$2y$12$RWcqgCNgn954z3GTWLeDBOjvxoS2uNBH867VYwON2s3Hwlgf3R2k.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:45', '2026-10-11 05:16:45', NULL),
(117, 'ASSYIFA\' NASYWAH KAYYISAH', '20579998_3116736315@siswa.prestasiku.id', '20579998_3116736315', NULL, 1, NULL, '$2y$12$K9k0U0I2L1lSVgrPKNlCEuoy1K7rmAvIWH3P6pXGmgQxNO5iFhq9.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:46', '2026-10-11 05:16:46', NULL),
(118, 'ASYIFA ISNANIA CHANDRA', '20579998_107159094@siswa.prestasiku.id', '20579998_107159094', NULL, 1, NULL, '$2y$12$V7DezgtHbWucO5bJl63Yi.p.4OoIseEJoHQkgbDxAFkvQkg9/UoI2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:46', '2026-10-11 05:16:46', NULL),
(119, 'ASYIFA\' LAILATUL MUNAWAROH', '20579998_3104190790@siswa.prestasiku.id', '20579998_3104190790', NULL, 1, NULL, '$2y$12$jGjmnlrUBDNGUWK4BqXuje.ldb1O9BCgAdQt3IazVPUllh1MPTpme', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:47', '2026-10-11 05:16:47', NULL),
(120, 'ATINA RAHMAH MAHMUDIAH', '20579998_103299469@siswa.prestasiku.id', '20579998_103299469', NULL, 1, NULL, '$2y$12$G7TEb.1YGjxw4QfUUNj/T.i/VSJ9/.7kaFg67u9pmTjB2k6twEkJe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:47', '2026-10-11 05:16:47', NULL),
(121, 'ATIQOH ZALFA RATU BILQIS', '20579998_3117577422@siswa.prestasiku.id', '20579998_3117577422', NULL, 1, NULL, '$2y$12$CRDcgETUdHLqF5Zrc9l3Uu4qfBZ0wbeS0F56kgEasnAIkXgxvvPtW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:47', '2026-10-11 05:16:47', NULL),
(122, 'ATIRA ECHI JIHAN ZAHRIA', '20579998_3102531445@siswa.prestasiku.id', '20579998_3102531445', NULL, 1, NULL, '$2y$12$YVyUaP1RInh0HPs2z69jo.cuCPf4woOIwOrpSOasH6ryWv6odBCJm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:48', '2026-10-11 05:16:48', NULL),
(123, 'AURA CINTA AZZA ARROHMAH', '20579998_109602103@siswa.prestasiku.id', '20579998_109602103', NULL, 1, NULL, '$2y$12$pp.WGK7857QX0Z3WHJJK/.6n85VdvkWNqML2ka8qXwUubarp3xTVK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:48', '2026-10-11 05:16:48', NULL),
(124, 'AYA ALIZA', '20579998_3119108464@siswa.prestasiku.id', '20579998_3119108464', NULL, 1, NULL, '$2y$12$j3cR.9dHUodPgqsTfl9X9u9rGneRJUBnYhGMWl3IN90c51CcI1H1i', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:49', '2026-10-11 05:16:49', NULL),
(125, 'AYU NINDYA AL ASFIHANI RIFQI', '20579998_105155903@siswa.prestasiku.id', '20579998_105155903', NULL, 1, NULL, '$2y$12$xpUZbJkwCaVFeiPQuX4K2uPPXuys6UyuYp.83lGfptM74l3LmaCvi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:49', '2026-10-11 05:16:49', NULL),
(126, 'AZALIA RAMADHANI', '20579998_105265165@siswa.prestasiku.id', '20579998_105265165', NULL, 1, NULL, '$2y$12$JOXnRoPnrb6NblAcuEZTPuBoHVLLkQ4Dm6Ii/mHU1xYDcPZNPHxbC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:49', '2026-10-11 05:16:49', NULL),
(127, 'AZIZAH ROUDHOTUL HASANAH', '20579998_105549740@siswa.prestasiku.id', '20579998_105549740', NULL, 1, NULL, '$2y$12$6bQDDgoZflFLePfzaZ46p.zkQMM3Ir9eJrSV5QdaTTAUTx6vY27wC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:50', '2026-10-11 05:16:50', NULL),
(128, 'BILQIS OKTAVIA PUTRI', '20579998_108795354@siswa.prestasiku.id', '20579998_108795354', NULL, 1, NULL, '$2y$12$11ou8LuS8bmsh1RteqglDeaNG8RmqHmRO5m5Ku7EVZyeNDnC9UjMW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:50', '2026-10-11 05:16:50', NULL),
(129, 'CAHAYA AAFIYAH HASNA', '20579998_108442508@siswa.prestasiku.id', '20579998_108442508', NULL, 1, NULL, '$2y$12$a4Qft85Jco5odSEzSWcthOunImVWydyNRjUE0wRTVNnX1UIiabWf2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:51', '2026-10-11 05:16:51', NULL),
(130, 'ATA ZAHRA FIRDAUS', '20579998_3117645797@siswa.prestasiku.id', '20579998_3117645797', NULL, 1, NULL, '$2y$12$R.HUu/ov2w9KoqiaBcRCNe6NgpvcxqxIetE9/Bp487paleORMe3XK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:51', '2026-10-11 05:16:51', NULL),
(131, 'ALMAIDAH NUR IDLOFY', '20579998_103290495@siswa.prestasiku.id', '20579998_103290495', NULL, 1, NULL, '$2y$12$OCSqNHxlnTiwHyxS6aiF5eHA5kfLkF1R79mzsANaGjMPU3zS.KHba', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:51', '2026-10-11 05:16:51', NULL),
(132, 'DEANITA OKTAFIYANI', '20579998_107709031@siswa.prestasiku.id', '20579998_107709031', NULL, 1, NULL, '$2y$12$BbPyr37DCfFJ6qdVD.zv4uOnnm6mBzJteymBr9K9oqu4fUaAxwyce', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:52', '2026-10-11 05:16:52', NULL),
(133, 'DEBY SHAHLA HABIBI', '20579998_101498182@siswa.prestasiku.id', '20579998_101498182', NULL, 1, NULL, '$2y$12$HAFCHtunCFogFcMjxYppGeAZUBAz9cHAnt/M0vjyPEk9WDtFbJYie', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:52', '2026-10-11 05:16:52', NULL),
(134, 'DEWI TSALITSAH RAHMA DINI', '20579998_3103502880@siswa.prestasiku.id', '20579998_3103502880', NULL, 1, NULL, '$2y$12$jjKFai6bfLJhkMt0emlTXucxZujGd/r7mL9e2202Kg8UnzWxOCnQm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:53', '2026-10-11 05:16:53', NULL),
(135, 'DINDA ARIFA OCTAVIANI', '20579998_105976653@siswa.prestasiku.id', '20579998_105976653', NULL, 1, NULL, '$2y$12$v0wN7PNZ9GEr3Dc8QGIfaupoloNzPFempgqunDq8EPN0Dfnj7jxym', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:53', '2026-10-11 05:16:53', NULL),
(136, 'DINDA KHURIN RAHMAWATI', '20579998_114811329@siswa.prestasiku.id', '20579998_114811329', NULL, 1, NULL, '$2y$12$e4x0poGpO/zLic18rjucxORYsC7Sk2CctHTdUuFXg5NJF4w7MMJka', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:54', '2026-10-11 05:16:54', NULL),
(137, 'DURROH WAAFIROH', '20579998_103776104@siswa.prestasiku.id', '20579998_103776104', NULL, 1, NULL, '$2y$12$iTdNwLOdGY/0qlRS/7qqV.l/nf9wy1rtjk4Q5xH9GmyEAdBh1ocYK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:54', '2026-10-11 05:16:54', NULL),
(138, 'DURROTUL WAFIIYAH', '20579998_3111509999@siswa.prestasiku.id', '20579998_3111509999', NULL, 1, NULL, '$2y$12$X2CYtXyHZ92aR5Yv7OxErei5/Jxdxe5iVEse2h41lY.eOVd7iqfDK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:54', '2026-10-11 05:16:54', NULL),
(139, 'DYSNI NABILA AZZAHRA', '20579998_117853652@siswa.prestasiku.id', '20579998_117853652', NULL, 1, NULL, '$2y$12$VzvVfL4BZTv.j.GuqAdjD.WG7XYAypTKugLifK/8gyI.mwKCs9uz6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:55', '2026-10-11 05:16:55', NULL),
(140, 'FAIRUZIATIN NAFISAH', '20579998_3113071531@siswa.prestasiku.id', '20579998_3113071531', NULL, 1, NULL, '$2y$12$ZOZT9r6qoTcqzrArqyfUWeT3xyfFjp2S/.3JmFQfEKCL7jurtJkSO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:55', '2026-10-11 05:16:55', NULL),
(141, 'FANNY ARTANTI SUROTO', '20579998_3102812388@siswa.prestasiku.id', '20579998_3102812388', NULL, 1, NULL, '$2y$12$w1bausqsSuEQBljT3peVZeW23KlbkcgPxcG4eWHnFAGArevqrSHNC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:55', '2026-10-11 05:16:55', NULL),
(142, 'FATHIN NAJMA FAISHOL', '20579998_103977010@siswa.prestasiku.id', '20579998_103977010', NULL, 1, NULL, '$2y$12$MrAdJNGDCzzWnonFzvSwJ.AsL7c/.KiNg/Uq/Mpt57gTKYgBkz2EW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:56', '2026-10-11 05:16:56', NULL),
(143, 'FATIMAH FA\'IZATUN NISA\'', '20579998_3119164374@siswa.prestasiku.id', '20579998_3119164374', NULL, 1, NULL, '$2y$12$PwrX.dwtOooZh9TQkjD0fuwVYoS82gqb2qLVtlGVzeJsBlGiru0q6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:57', '2026-10-11 05:16:57', NULL),
(144, 'FITA RIF\'ATUL MUJIBAH', '20579998_3118699074@siswa.prestasiku.id', '20579998_3118699074', NULL, 1, NULL, '$2y$12$jJB8Uxh8DQbPmxE8sOQ2sOEPL3eIFGkgLoxT3MtDbOBILvBE2LzCW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:57', '2026-10-11 05:16:57', NULL),
(145, 'FUZNA BEMAZHEYA GHUFAYRA', '20579998_119164236@siswa.prestasiku.id', '20579998_119164236', NULL, 1, NULL, '$2y$12$.oxzqVOY2KYPep7vwBe32uFWbKJnqOZuxWln0HM3f/i7Y0NkPgfL2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:57', '2026-10-11 05:16:57', NULL),
(146, 'GITA CHINTYA REISMANDA', '20579998_3118637609@siswa.prestasiku.id', '20579998_3118637609', NULL, 1, NULL, '$2y$12$FSImVC2gme8/I1uDm7zHXumXlcsb9Olhf6Zq0JjcotbprWStpGCxy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:58', '2026-10-11 05:16:58', NULL),
(147, 'HABIBAH NUR FAUZIAH', '20579998_114431026@siswa.prestasiku.id', '20579998_114431026', NULL, 1, NULL, '$2y$12$3djK/xMAhFDtL6xWqH4AFOZ68ZmGB8rwkZ9R7j6bmwpSn0xZaQeCe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:58', '2026-10-11 05:16:58', NULL),
(148, 'HABIBATTUL MUTMAINAH', '20579998_3101478309@siswa.prestasiku.id', '20579998_3101478309', NULL, 1, NULL, '$2y$12$8Ni3gCkO.WFnDQITvxILzOpX6Kyle6/DgqUI4SB7Sd0inH4mgGaOu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:59', '2026-10-11 05:16:59', NULL),
(149, 'HANAA AIDA ADHIYA', '20579998_3101239098@siswa.prestasiku.id', '20579998_3101239098', NULL, 1, NULL, '$2y$12$MjBSCMYnUT.6zy2Syg3UqOLtgThuYbo.heAJpTpE/mfE9f7n3uZli', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:16:59', '2026-10-11 05:16:59', NULL),
(150, 'HANNA MABRUKAH QOTRUNADA', '20579998_108625514@siswa.prestasiku.id', '20579998_108625514', NULL, 1, NULL, '$2y$12$QXXw94ZPofeP.0hrQtowyusa3ZtR0tyOjQX6E6Aqsfxvh33gJt0cq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:00', '2026-10-11 05:17:00', NULL),
(151, 'HASNA\'UL QUDSIYAH', '20579998_102985679@siswa.prestasiku.id', '20579998_102985679', NULL, 1, NULL, '$2y$12$cjNfBt06FtMat/7t2X3o8uPS3u70s2k/yA9l6.strfg/7Z4Wy9jie', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:00', '2026-10-11 05:17:00', NULL),
(152, 'HAZZAH TALITHA JINAN', '20579998_106444942@siswa.prestasiku.id', '20579998_106444942', NULL, 1, NULL, '$2y$12$3INA8nG96yrzQsFQXKt6h.ta0iVK8qAM/hEdP47t/bY7MgLb.aOlO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:01', '2026-10-11 05:17:01', NULL),
(153, 'HESTIANA SARI', '20579998_111486463@siswa.prestasiku.id', '20579998_111486463', NULL, 1, NULL, '$2y$12$MzEnzS6xuiCf0006urS4O.qAJrgOrlRGyK2GAyM28uoJR5WnJ23w.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:01', '2026-10-11 05:17:01', NULL),
(154, 'IFTINAN QORIIROH AINI', '20579998_94930797@siswa.prestasiku.id', '20579998_94930797', NULL, 1, NULL, '$2y$12$.enalJiLSF2eK78iGtcb9ueuMSUatwS0y6DZqJcSzuDAj.UnzuMtC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:02', '2026-10-11 05:17:02', NULL),
(155, 'IFTITAH NABILA AWALIYAH', '20579998_3117936144@siswa.prestasiku.id', '20579998_3117936144', NULL, 1, NULL, '$2y$12$zDXEnflmG15gZcyREDNIqunZ0JI/gRelT4DJPRiwOxD7y1KG1K9Ky', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:03', '2026-10-11 05:17:03', NULL),
(156, 'INDAH DWI ROHMAH', '20579998_3119034346@siswa.prestasiku.id', '20579998_3119034346', NULL, 1, NULL, '$2y$12$nNQ3muI6Do7UTTYW31gzzOTyPnT1tpyf3cAV7gkxFNtM5FLcHVowG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:03', '2026-10-11 05:17:03', NULL),
(157, 'ISMI AZIZIA NUR RACHMA', '20579998_109249727@siswa.prestasiku.id', '20579998_109249727', NULL, 1, NULL, '$2y$12$mRbhLRVCDiTvQaBg3Oeo5.mf78qy8qTF.w4sif8tisBBOLA7pGR6C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:04', '2026-10-11 05:17:04', NULL),
(158, 'JULIA NURUL AZIKA', '20579998_116627214@siswa.prestasiku.id', '20579998_116627214', NULL, 1, NULL, '$2y$12$ST6ojSosC9s.j/H1HskIheXZNwkkcw6yqA6DiXWSwhjGb8o8MBnae', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:04', '2026-10-11 05:17:04', NULL),
(159, 'KAMILAH MUFLIKHATU AZKAL ADIBAH', '20579998_3104802366@siswa.prestasiku.id', '20579998_3104802366', NULL, 1, NULL, '$2y$12$.fDiZ4pgqJz6yTb1I3z6gOMeeNvN.M39MWMT5ewFLeltBeOd5bz2C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:05', '2026-10-11 05:17:05', NULL),
(160, 'KARINA ARBA\'AH MUNFAATI', '20579998_101994355@siswa.prestasiku.id', '20579998_101994355', NULL, 1, NULL, '$2y$12$3mcnIpQm6bxY962d616W4OW.ECT6hZh2e1VbHnPaUVEWa2yevJQFq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:05', '2026-10-11 05:17:05', NULL),
(161, 'KAYLA AISYAH ASY-SYIFA\'', '20579998_116011481@siswa.prestasiku.id', '20579998_116011481', NULL, 1, NULL, '$2y$12$2.4A0bI5DUUv16nEpO9Ile1OFC5/WQ8u.8VvZvrrKBFN8UZ51veme', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:06', '2026-10-11 05:17:06', NULL),
(162, 'KHANSA ROFINA RAMADHANI ANNUR', '20579998_102124847@siswa.prestasiku.id', '20579998_102124847', NULL, 1, NULL, '$2y$12$2oNY8bs7fPGEs8hJ9PssHOAjh6PIZuEZHyfS8ACDP7dfd01WSIdDi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:06', '2026-10-11 05:17:06', NULL),
(163, 'SANIYA CAHYA QOLBI', '20579998_114669042@siswa.prestasiku.id', '20579998_114669042', NULL, 1, NULL, '$2y$12$PiWtrhXbahuYeqbEZs4Xp.4yLZo8/IWPbGxSyh64UdT/w7aFax56m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:06', '2026-10-11 05:17:06', NULL),
(164, 'KHANZA BULGHATURRIZQI ATHIRA SETIAWAN', '20579998_118357276@siswa.prestasiku.id', '20579998_118357276', NULL, 1, NULL, '$2y$12$SBXdHoPVP8GoyqVVGqTa8..MwIARhgi68LLRhqzFMy7/uxG25VEOy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:07', '2026-10-11 05:17:07', NULL),
(165, 'LABIBAH KAMELIA RAMADHANI', '20579998_105802975@siswa.prestasiku.id', '20579998_105802975', NULL, 1, NULL, '$2y$12$UitdBy3aCSH3o8hHlU838evWzKHcIXLCUGmSCcHVu0KqX9ZRH.c2K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:07', '2026-10-11 05:17:07', NULL),
(166, 'LAURINA ZAHROTUL FITRI', '20579998_104153455@siswa.prestasiku.id', '20579998_104153455', NULL, 1, NULL, '$2y$12$vul8C7tHOO0OBfyX5CHEPeblH6dobqf4LawO7LoMqc1.16lgIB5yW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:07', '2026-10-11 05:17:07', NULL),
(167, 'LEILA AYU SALSABILA', '20579998_118856445@siswa.prestasiku.id', '20579998_118856445', NULL, 1, NULL, '$2y$12$VNKzsyIyxkA8gY2dtPfH..wix6f0m.qN.NcRabbWmkLrIEJ0NYR/u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:08', '2026-10-11 05:17:08', NULL),
(168, 'LINA RAFIFAH', '20579998_114973880@siswa.prestasiku.id', '20579998_114973880', NULL, 1, NULL, '$2y$12$srcYTXkxt0JUrVmstlGTWujxSoS7C1utRhJm7rhT.eIwnmSz4OR2m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:08', '2026-10-11 05:17:08', NULL),
(169, 'LULU NAFIATUL HUSNA', '20579998_111652434@siswa.prestasiku.id', '20579998_111652434', NULL, 1, NULL, '$2y$12$bWLzhWsr.YcVEyAWzdmZCuxy3NzlBX18wHdLL1vYnPhY9RC04zV2C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:09', '2026-10-11 05:17:09', NULL),
(170, 'LUTHFI NADYATUROHMAH', '20579998_108069342@siswa.prestasiku.id', '20579998_108069342', NULL, 1, NULL, '$2y$12$e6.1KIPrQpoYruw3UVhcxOSZi/gjJPmtwyLH8ZoPx/Gs.md3ZVBW6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:09', '2026-10-11 05:17:09', NULL),
(171, 'MARETA ARNELIA ANGGRAINI', '20579998_3117929746@siswa.prestasiku.id', '20579998_3117929746', NULL, 1, NULL, '$2y$12$ZU/5kD08nxeenc/RT0OLdu21R7ksLQENNayZz//gQtJ6haaAdiC1e', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:09', '2026-10-11 05:17:09', NULL),
(172, 'MAULIDA HAFIZA', '20579998_108684735@siswa.prestasiku.id', '20579998_108684735', NULL, 1, NULL, '$2y$12$GBgH81YagynwxhKzByMja.EbVG.0d3AoemTuBjW33atKPhmynISti', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:10', '2026-10-11 05:17:10', NULL),
(173, 'MEYDINA AYU RACHMA', '20579998_101002365@siswa.prestasiku.id', '20579998_101002365', NULL, 1, NULL, '$2y$12$M.cxv9DTSbTXBbDBggjv4OG5OL3T9NxNTZ7DzCogcyT1Md5aT4s8.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:10', '2026-10-11 05:17:10', NULL),
(174, 'MIR ATURAHMA MUWASSI', '20579998_105509336@siswa.prestasiku.id', '20579998_105509336', NULL, 1, NULL, '$2y$12$j8E6msaFNmbS5z9vcFl0QuzT4WLkvSdyb/h/9PJqFgCMT50COdMEu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:11', '2026-10-11 05:17:11', NULL),
(175, 'MUTIYA SALSYABELA', '20579998_106231456@siswa.prestasiku.id', '20579998_106231456', NULL, 1, NULL, '$2y$12$s9yObS1rl345hsfAIAJEp.mtWPNHV96k7aonatxOjxIY5NkxjDYI6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:11', '2026-10-11 05:17:11', NULL),
(176, 'NABILA AHZA NAURA', '20579998_108196087@siswa.prestasiku.id', '20579998_108196087', NULL, 1, NULL, '$2y$12$aktz0PNbCz8Mwdn1.lv8e.aE1dvhzfyEh0jy6fppsarNk.vi0ho76', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:11', '2026-10-11 05:17:11', NULL),
(177, 'NABILA RAHADATUL AISYI', '20579998_3103602022@siswa.prestasiku.id', '20579998_3103602022', NULL, 1, NULL, '$2y$12$QuQ2SfW.CCjrwUFehF/7QOuz76PZLum3ghc5AIVtSO2GWm.fJbLuC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:12', '2026-10-11 05:17:12', NULL),
(178, 'NABILAH DENI LUTHFIYAH', '20579998_111832375@siswa.prestasiku.id', '20579998_111832375', NULL, 1, NULL, '$2y$12$o/Tv1TCHprrgdpIJClwJ3u1eCZi/o73RXTc9TXHNCnpbY0JZeYXQG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:12', '2026-10-11 05:17:12', NULL),
(179, 'NABILAH NUR FAIZAH', '20579998_3109841868@siswa.prestasiku.id', '20579998_3109841868', NULL, 1, NULL, '$2y$12$dICAZzMLk6Viv31KcmzbOuyxh7MOEzHz2VM2GGqR8Y6SF0nsGWkMS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:13', '2026-10-11 05:17:13', NULL),
(180, 'NADIFATUL QURIYAH', '20579998_106416610@siswa.prestasiku.id', '20579998_106416610', NULL, 1, NULL, '$2y$12$LYxEHOE1QhILemz66KCoxu.3pRSdqZvDUxlGnI0Zjp6zNsW7r1egm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:13', '2026-10-11 05:17:13', NULL),
(181, 'NAIMA NOER NUHA', '20579998_114821465@siswa.prestasiku.id', '20579998_114821465', NULL, 1, NULL, '$2y$12$pVQJXgBThVCRoXWo0IZmUuCVfz/xgdtZg1SHh6L7Mkh3lAT2IygjG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:13', '2026-10-11 05:17:13', NULL),
(182, 'NAJWA NAJAHA MUTTAQIN', '20579998_3113094336@siswa.prestasiku.id', '20579998_3113094336', NULL, 1, NULL, '$2y$12$WoCJF1hgvU3st00L3jRAw.XbBlR7oG.ICnl4yoX6TAyNSFYS47aGK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:14', '2026-10-11 05:17:14', NULL),
(183, 'NALA DZAKIYYA NASHIROH', '20579998_3101347175@siswa.prestasiku.id', '20579998_3101347175', NULL, 1, NULL, '$2y$12$Wpn4/fcecmA/vHJgpuB9ZOsSDBvD3P3bbuD3DpoI1QGsYWxK4fJV2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:14', '2026-10-11 05:17:14', NULL),
(184, 'NALA TASYAYA', '20579998_119096442@siswa.prestasiku.id', '20579998_119096442', NULL, 1, NULL, '$2y$12$dh2O8Y7IsZCIIOU1.jpwjOeZrBS8t.9uiet0UhztA7M6QUNlk.eFO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:15', '2026-10-11 05:17:15', NULL),
(185, 'NASWA NUR ROCHMA', '20579998_102782744@siswa.prestasiku.id', '20579998_102782744', NULL, 1, NULL, '$2y$12$fjgbhT7YDnN6pd8bhy8f6uGE/D93H7.ifSJtevU.bW3kFsE04vPwO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:15', '2026-10-11 05:17:15', NULL),
(186, 'NATASYA SYIFAURRAHMA', '20579998_101338252@siswa.prestasiku.id', '20579998_101338252', NULL, 1, NULL, '$2y$12$mer4pD3Jh6RGmMPVP9ES.OfvjOYIg6uE.yh43PLhhquMDkeXZ9Ov6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:16', '2026-10-11 05:17:16', NULL),
(187, 'NAURA FARADILA ARIZZAH', '20579998_116385119@siswa.prestasiku.id', '20579998_116385119', NULL, 1, NULL, '$2y$12$EWLheZGxcQwOYVFRFTTupONTPR9AKxRHNeDhOYAq1X5Ew4hgoLKa6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:16', '2026-10-11 05:17:16', NULL),
(188, 'NAURAH MAULIDINA KHOIR', '20579998_115352674@siswa.prestasiku.id', '20579998_115352674', NULL, 1, NULL, '$2y$12$mJPRMpwXt2duebnNAPNeseGKHq9EwxRoEkxVIJYLQXWR0bj0hOVp6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:17', '2026-10-11 05:17:17', NULL),
(189, 'NAZIDAH EKA ALIYAH', '20579998_3119904936@siswa.prestasiku.id', '20579998_3119904936', NULL, 1, NULL, '$2y$12$U0UK2Nbrhdj1PeOxmvI4H.fDDXE/C7mv7u5V76lVIA3Kei7JpAoyS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:17', '2026-10-11 05:17:17', NULL),
(190, 'NAZILAH ZUMROTUL MAS\'UDAH', '20579998_109412871@siswa.prestasiku.id', '20579998_109412871', NULL, 1, NULL, '$2y$12$BMruOs49QTtbDD5HgPp6pOl.VcGLsqfliMerHjAhaeca1khkWLRoi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:18', '2026-10-11 05:17:18', NULL);
INSERT INTO `users` (`id`, `name`, `email`, `username`, `phone`, `school_id`, `email_verified_at`, `password`, `must_change_password`, `password_changed_at`, `last_login_at`, `last_login_ip`, `status`, `remember_token`, `created_at`, `updated_at`, `deleted_at`) VALUES
(191, 'NAZWA NUR HIKMAH', '20579998_115298819@siswa.prestasiku.id', '20579998_115298819', NULL, 1, NULL, '$2y$12$76I6.SmP4YtLMcjLoHI/.OeZH/xdLNQZniINHyyprPW2D/RO/EwC.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:19', '2026-10-11 05:17:19', NULL),
(192, 'NELLY RAMADHANI LANJARSARI', '20579998_3104367334@siswa.prestasiku.id', '20579998_3104367334', NULL, 1, NULL, '$2y$12$LnhMRFDHlQSPxLtiPJ.wPeuLuyYzsuVMpKig62CBmGygouCvtNnLq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:19', '2026-10-11 05:17:19', NULL),
(193, 'NINDYA FAIZA SAFILA', '20579998_3117099533@siswa.prestasiku.id', '20579998_3117099533', NULL, 1, NULL, '$2y$12$dqnnCS4Bz4IDOi39RIfPHuPMDejSajUENTPcxEz5ixm7DHQMZahmS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:20', '2026-10-11 05:17:20', NULL),
(194, 'NINE ADDIN SYARIFAH', '20579998_116305714@siswa.prestasiku.id', '20579998_116305714', NULL, 1, NULL, '$2y$12$L1JXJmUdZNznbzExWFJaIuShbCxFEEqtLnmnZFuCI1WOB7HW2Ffhu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:20', '2026-10-11 05:17:20', NULL),
(195, 'NURDIANA WAHIDAH', '20579998_107355950@siswa.prestasiku.id', '20579998_107355950', NULL, 1, NULL, '$2y$12$hO1s9mH/.Ps2fKHp2gDecuvO3TuccHKaKCCUDJkZ192rwb0xK1bn.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:21', '2026-10-11 05:17:21', NULL),
(196, 'NURUL AZKIYYAH', '20579998_3100744334@siswa.prestasiku.id', '20579998_3100744334', NULL, 1, NULL, '$2y$12$MkWGKQgfvMV4mXVeHcc2gOi6nNdfXTFjgW2yjY1sNRWlAyGdwe8zq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:21', '2026-10-11 05:17:21', NULL),
(197, 'PATRICIA RACHMA AL-KHOFIDI', '20579998_3115521941@siswa.prestasiku.id', '20579998_3115521941', NULL, 1, NULL, '$2y$12$0vzSGs1nwgMo1aYlHuQjKOp/3z6Ir49aUPyAzASXXeBn71AjgxIaq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:22', '2026-10-11 05:17:22', NULL),
(198, 'QONITA NADHIRA', '20579998_107611706@siswa.prestasiku.id', '20579998_107611706', NULL, 1, NULL, '$2y$12$YaP24Ysie.982ZlIMrfAt.jOyKNkG3sCu1s9DC1hx4UssxPseHXxe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:22', '2026-10-11 05:17:22', NULL),
(199, 'QONITA TRYAS NUR NASTITI', '20579998_111155623@siswa.prestasiku.id', '20579998_111155623', NULL, 1, NULL, '$2y$12$UkxmKspN5PYUZ9uJ5hviD.LKjU3uITSZUMq0I1ZHihnHgcx6fwJda', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:23', '2026-10-11 05:17:23', NULL),
(200, 'QUEENSYA DEWI NAILA AISYATUSY SYARIFAH', '20579998_115293734@siswa.prestasiku.id', '20579998_115293734', NULL, 1, NULL, '$2y$12$VWP41TGlsQlq45x7U5BRruZIsYYcCc7BFXqBeYaNGfp0XmVuOtJ7y', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:23', '2026-10-11 05:17:23', NULL),
(201, 'RAHMA WILUJENG', '20579998_3104868891@siswa.prestasiku.id', '20579998_3104868891', NULL, 1, NULL, '$2y$12$.NBr460MyaUGWsbZKSNJke0RxOwbJi/1R6b7EaERAqCOnmzNNEly6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:23', '2026-10-11 05:17:23', NULL),
(202, 'RATIH AULIA DEWI BUDIARTI', '20579998_117177552@siswa.prestasiku.id', '20579998_117177552', NULL, 1, NULL, '$2y$12$wL2WMF7cTnE9VTKAjcrZY.zwyvkfYSlKMm7tLoeIVwBmD21g8nE2W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:24', '2026-10-11 05:17:24', NULL),
(203, 'RENAYYA ZAHROTUL FITRIAH', '20579998_107316109@siswa.prestasiku.id', '20579998_107316109', NULL, 1, NULL, '$2y$12$gsD4zvLuDAorzKafG.C0.O3HJ8v.W5oHNIzBGe7C23wXj5Yp5YvM.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:24', '2026-10-11 05:17:24', NULL),
(204, 'REVA LUTFIA FAUZI', '20579998_114262292@siswa.prestasiku.id', '20579998_114262292', NULL, 1, NULL, '$2y$12$Kn.EkuHf/HFVaSpwUC9vEuZZ91VQPfq6vCMe4YomKWF1Of9TNDGPS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:24', '2026-10-11 05:17:24', NULL),
(205, 'REVALINA SALSABILA AZZAHRA', '20579998_3115209711@siswa.prestasiku.id', '20579998_3115209711', NULL, 1, NULL, '$2y$12$YUnJLjeayjgcPsp5efiH7Oe/tQf8MfVjLucgQ5oioyfBCXkGECi6S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:25', '2026-10-11 05:17:25', NULL),
(206, 'ROSYIDAH AULIA SABIH DIYANTO', '20579998_106669224@siswa.prestasiku.id', '20579998_106669224', NULL, 1, NULL, '$2y$12$2HsJ/NFr2wGy6K6FFHMQc.Vsr1BEo6xHNBPFpLNK7d7jz/URbgi2S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:25', '2026-10-11 05:17:25', NULL),
(207, 'SAFARA AZKA RAIHANATI', '20579998_111150136@siswa.prestasiku.id', '20579998_111150136', NULL, 1, NULL, '$2y$12$QnhgTD0Q/D71OScymvdZluvMDXDJMs.KCjrgYtVMx7DIQjWcNlJjK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:26', '2026-10-11 05:17:26', NULL),
(208, 'SAIDA AISYAH SAFADEWI', '20579998_3108779110@siswa.prestasiku.id', '20579998_3108779110', NULL, 1, NULL, '$2y$12$.Cl9IwgVTcTov6ViqZDjD.sgby/WXXbn.uAmLDwO0.fiPwSJqaGYy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:26', '2026-10-11 05:17:26', NULL),
(209, 'SALWA NUZULUL MUFIDA', '20579998_3105103243@siswa.prestasiku.id', '20579998_3105103243', NULL, 1, NULL, '$2y$12$GkendnxZOF2WVf2CgPVHnO0yKyG00Iq7cNeZLpdoHATUvmEZqh1HG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:27', '2026-10-11 05:17:27', NULL),
(210, 'SASHIKIRANA CHANTIKA BRILLIANT YUDA PUTRI', '20579998_105104872@siswa.prestasiku.id', '20579998_105104872', NULL, 1, NULL, '$2y$12$tfExsU9zA3bshC00Vg24N.Qn7wSdu0sQeR.sA9C/N3qcjDUcpI.Hy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:27', '2026-10-11 05:17:27', NULL),
(211, 'SASYA KUSUMA ADELIA', '20579998_108543228@siswa.prestasiku.id', '20579998_108543228', NULL, 1, NULL, '$2y$12$HvWtNdgTWshBgKWNd4Msiefsyi0qA78U38h8HJZBWO2LwqhZFL6Iq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:28', '2026-10-11 05:17:28', NULL),
(212, 'SEPTIA RESTI AZIZAH', '20579998_101208576@siswa.prestasiku.id', '20579998_101208576', NULL, 1, NULL, '$2y$12$U.sTccjY3Xyrcet4Brw8Z.K8iCIxQcqlLompeOK8Is1yxbKoBwfNa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:28', '2026-10-11 05:17:28', NULL),
(213, 'SHABRINA NURUL MA\'RUFAH', '20579998_3109145144@siswa.prestasiku.id', '20579998_3109145144', NULL, 1, NULL, '$2y$12$iUPChUIulXZNHw/eEyLiheaJg8KJAMmrJpMpJkm5a6T/3p6Cnmn5K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:29', '2026-10-11 05:17:29', NULL),
(214, 'SHAKILA KHAFITRAH HARTANTO PUTRI', '20579998_104453456@siswa.prestasiku.id', '20579998_104453456', NULL, 1, NULL, '$2y$12$EWMSnrHmARoOUBz/I5afb.ZZcVu.2G0HeEq.McLNxFJ9W51z4X/Si', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:29', '2026-10-11 05:17:29', NULL),
(215, 'SITI NURIYAH', '20579998_3111935820@siswa.prestasiku.id', '20579998_3111935820', NULL, 1, NULL, '$2y$12$9PvU4Jw3.I/tZv9z5fquf.e.IZNIEIG86TS9ipY8WqfbqESH4Qb62', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:30', '2026-10-11 05:17:30', NULL),
(216, 'SUKAINAH FAKHRA AHMADA', '20579998_3113689620@siswa.prestasiku.id', '20579998_3113689620', NULL, 1, NULL, '$2y$12$yzrzMh7O2nbQolgPHjnx..8iVzSuhKPdIOHeocScBpXhB8U.5D/7u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:30', '2026-10-11 05:17:30', NULL),
(217, 'SWANDARI SAFRIDA FIQIH ZULKARNAEN', '20579998_105107522@siswa.prestasiku.id', '20579998_105107522', NULL, 1, NULL, '$2y$12$8MzXUiv2KRaZhaMRGv0dfeKAV79GMGaugVvPsTlh8vXIJC/33yz6m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:31', '2026-10-11 05:17:31', NULL),
(218, 'SYAHDILLA MINHAJUL QASIDA', '20579998_104854574@siswa.prestasiku.id', '20579998_104854574', NULL, 1, NULL, '$2y$12$qhIsfHu6EnuqxHV2c9q3lOTlQ3SJxDb2GA7j09bRn2TOqT/ZJt6X.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:32', '2026-10-11 05:17:32', NULL),
(219, 'SYAKIRA QATRUNNADA', '20579998_113323386@siswa.prestasiku.id', '20579998_113323386', NULL, 1, NULL, '$2y$12$t.SPGTZt4BOy0.3r5GgV2.z5CIusW2len7a/e.RqZgPceOf8hpI4C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:32', '2026-10-11 05:17:32', NULL),
(220, 'TALITA SYAKIRA', '20579998_3111329460@siswa.prestasiku.id', '20579998_3111329460', NULL, 1, NULL, '$2y$12$Fi4rHd4Qypf6oAOMXiCyPu/nVeIaievzYXomi7UUPSAKkQLHaMtey', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:33', '2026-10-11 05:17:33', NULL),
(221, 'TANTIKA RIDHA JULIENY', '20579998_119909807@siswa.prestasiku.id', '20579998_119909807', NULL, 1, NULL, '$2y$12$lUomslH3cjE/n0lAAswrauhwEURUlrQWxKDWBRq4xRaOJ5aOIZthW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:33', '2026-10-11 05:17:33', NULL),
(222, 'THREE HANA NUR A\'IDAH', '20579998_3116241693@siswa.prestasiku.id', '20579998_3116241693', NULL, 1, NULL, '$2y$12$LyhJiaPJdMSM80t1f8i4YePDQjdazbpWTjNN/QXbPVFC0IK84HhMK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:34', '2026-10-11 05:17:34', NULL),
(223, 'TIARA TUNGGADEWI SAFITRI', '20579998_3095836530@siswa.prestasiku.id', '20579998_3095836530', NULL, 1, NULL, '$2y$12$deiylQoWUENj5DkpZiZ4PubvVhmW5nXoi9DIM0qDxZ072.LXQwoCu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:34', '2026-10-11 05:17:34', NULL),
(224, 'TSURAYAA SALSABILA MALIHAH', '20579998_3113195224@siswa.prestasiku.id', '20579998_3113195224', NULL, 1, NULL, '$2y$12$hmnArd5U/DaRL/aCu/g9/.oDAerSNfY6mL8dhJX5NB9WXdVSgb3dm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:34', '2026-10-11 05:17:34', NULL),
(225, 'UMI LATIFATUL JANNAH', '20579998_3104326605@siswa.prestasiku.id', '20579998_3104326605', NULL, 1, NULL, '$2y$12$smEfAMwQMJbN8aYiwJ2HNu9N2OZaSGa.P3WZYDoEQS7QXkOrj76lW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:35', '2026-10-11 05:17:35', NULL),
(226, 'VELIA AL AMIRA TUNGGAL DEWI', '20579998_3108347445@siswa.prestasiku.id', '20579998_3108347445', NULL, 1, NULL, '$2y$12$9tLezJkx6FjzsWk64csTRud/8K57OEw3m4FyZx5yc.aF8g2NVMq1e', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:35', '2026-10-11 05:17:35', NULL),
(227, 'WARDATUL KHUMAIRO\'', '20579998_3115780014@siswa.prestasiku.id', '20579998_3115780014', NULL, 1, NULL, '$2y$12$PU.UyNtly.3CHF/sQNr5ouFozvTtfnJUwwaGDDscROTySbtE454va', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:36', '2026-10-11 05:17:36', NULL),
(228, 'ZALFANA SYIFA\'UNNISA', '20579998_106652650@siswa.prestasiku.id', '20579998_106652650', NULL, 1, NULL, '$2y$12$Jq2yxu4UhMuH3W/PVTJ/y.v50y72.pnraWBc6FC3YtxHGXWsrGxNS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:36', '2026-10-11 05:17:36', NULL),
(229, 'ZIDA NIAMI', '20579998_3105939605@siswa.prestasiku.id', '20579998_3105939605', NULL, 1, NULL, '$2y$12$5szNR9zqF9NDvzASSMJtoOr/qd7dKsGG7XEUPGR4dqoYp459tBvEW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:36', '2026-10-11 05:17:36', NULL),
(230, 'RISMA KHOIRUNNISA\'', '20579998_102283507@siswa.prestasiku.id', '20579998_102283507', NULL, 1, NULL, '$2y$12$e9BqXUjM3SL3uDNNInqVueOL5Y2s9Gan6yMHPGPpP.6G07uaq3ghu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:37', '2026-10-11 05:17:37', NULL),
(231, 'BAYU DERMAWAN SAPUTRA', '20579998_97461918@siswa.prestasiku.id', '20579998_97461918', NULL, 1, NULL, '$2y$12$Fz4.GKf32R7JXN90Pk7TbeGqC13m442LQ6LkWJSx0sDoDhkK4NGtS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:38', '2026-10-11 05:17:38', NULL),
(232, 'DANY FAYYADHY SANJAYA', '20579998_3097729037@siswa.prestasiku.id', '20579998_3097729037', NULL, 1, NULL, '$2y$12$VfKjnrS.l9slXN3RLtpMQuIHyI6DSANglemzZFDosw2XAsDiq2mue', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:38', '2026-10-11 05:17:38', NULL),
(233, 'MOCH. KAFA AL-MAHMUDI', '20579998_3113884289@siswa.prestasiku.id', '20579998_3113884289', NULL, 1, NULL, '$2y$12$jkZlgvXqP.vzWrtZFmxf4OSF5fqJRQ3c8eG2jZ9Fn.OC2hdnxUdNu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:38', '2026-10-11 05:17:38', NULL),
(234, 'MOCH. PRAJA KERTANEGARA', '20579998_88534089@siswa.prestasiku.id', '20579998_88534089', NULL, 1, NULL, '$2y$12$Ke9I75dwqGn7JsdHhcr7ruO/UTPmHa1XLx7DlFkGAy9rqbl9z6z6O', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:39', '2026-10-11 05:17:39', NULL),
(235, 'MOCHAMAD FAHRIEL ARHAM ARROSYID', '20579998_99448229@siswa.prestasiku.id', '20579998_99448229', NULL, 1, NULL, '$2y$12$oUckqc8r8mjNQEiDwWdrhOILZ4p9qih/fXM2ea48lnJO5g8h691zK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:39', '2026-10-11 05:17:39', NULL),
(236, 'MOCHAMMAD IRHAM SYAUQI FIRDAUS', '20579998_3095525692@siswa.prestasiku.id', '20579998_3095525692', NULL, 1, NULL, '$2y$12$XMDr/7PZYqzVVXDOawdJv.TGw.OL5/sN4/K1JUhnACdNYQh0ScIu.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:39', '2026-10-11 05:17:39', NULL),
(237, 'MUHAMMAD AKBAR RAFASSYA', '20579998_99496087@siswa.prestasiku.id', '20579998_99496087', NULL, 1, NULL, '$2y$12$jiCti4m9CkX2hpWfKN4VNOLQMpNp74Rxp4oit9R8pOvaKInvTVBQe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:40', '2026-10-11 05:17:40', NULL),
(238, 'MUHAMMAD DZIHNUL MUSHOFFA', '20579998_108752403@siswa.prestasiku.id', '20579998_108752403', NULL, 1, NULL, '$2y$12$7d9s6yYSjAVvocV6Boe/TuzdN21WCDSXfDMD99vhzkI.ESVAUaLhK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:40', '2026-10-11 05:17:40', NULL),
(239, 'MUHAMMAD FAATHIR MUZAKI', '20579998_3097990771@siswa.prestasiku.id', '20579998_3097990771', NULL, 1, NULL, '$2y$12$tFQtZMgm5dzkLSkwi6Y.u.SUOrXLC5Iyz6yVLSeuuKNOG60C9s7M.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:41', '2026-10-11 05:17:41', NULL),
(240, 'MUHAMMAD FAQIH RIYADI', '20579998_106595598@siswa.prestasiku.id', '20579998_106595598', NULL, 1, NULL, '$2y$12$Lgdtk/qwRmWmuC7Q92wR8.BCHh1DSD20bm70k67amsirj1smlqMim', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:41', '2026-10-11 05:17:41', NULL),
(241, 'MUHAMMAD IQBAL ILHAMY', '20579998_3101047682@siswa.prestasiku.id', '20579998_3101047682', NULL, 1, NULL, '$2y$12$8hqlgnbS22kurFc17ropsevpk85FnDREahaS8GeWOJI9Jb.8RXs/G', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:41', '2026-10-11 05:17:41', NULL),
(242, 'MUHAMMAD IQBAL MAULANA', '20579998_3104273487@siswa.prestasiku.id', '20579998_3104273487', NULL, 1, NULL, '$2y$12$PP4Y1E7wKztxYuFkJXoD.eKpU8.eFUR0QxFLCcSaosGnOqKqXp5Ji', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:42', '2026-10-11 05:17:42', NULL),
(243, 'MUHAMMAD KHOIRUL ANAM', '20579998_103639269@siswa.prestasiku.id', '20579998_103639269', NULL, 1, NULL, '$2y$12$bh8m7DTW7eK/un1B5MNCiutmPXzez/Rgo49PA0MQgV98qOtnuqS9m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:42', '2026-10-11 05:17:42', NULL),
(244, 'MUHAMMAD MAULAL IBAD', '20579998_3109702781@siswa.prestasiku.id', '20579998_3109702781', NULL, 1, NULL, '$2y$12$d4opsZLgps8Dga3FTh1eKue.4wrzMnFnt2xclR.MTx9gXUAqokAUa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:42', '2026-10-11 05:17:42', NULL),
(245, 'MUHAMMAD RAFI MAHARDHIKA', '20579998_3094681066@siswa.prestasiku.id', '20579998_3094681066', NULL, 1, NULL, '$2y$12$xizlMFFTYakdUa.lEtA26OnV.7k9trNzVPIMl59nSOYUnlkOB8aDO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:43', '2026-10-11 05:17:43', NULL),
(246, 'MUHAMMAD ZACKY AFKHAR', '20579998_3087191616@siswa.prestasiku.id', '20579998_3087191616', NULL, 1, NULL, '$2y$12$oubovicYik0C4ey4.dztneCbbFiQXemNK.suZcO/YfMdIWnDp0K/.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:43', '2026-10-11 05:17:43', NULL),
(247, 'NASHIF KHOIRUL MUNIR', '20579998_103558442@siswa.prestasiku.id', '20579998_103558442', NULL, 1, NULL, '$2y$12$dYp2GZ40YG.e1K.Id2jgy.ytfA8pCqd9mNJ8uqZZ.OE9mIGIQYb12', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:44', '2026-10-11 05:17:44', NULL),
(248, 'NIZAR RAISSA SUSILO', '20579998_108444053@siswa.prestasiku.id', '20579998_108444053', NULL, 1, NULL, '$2y$12$KC4M9i8jfVW0HJomQnqp0uXtQGoChgNbx7nheNUsAjR60BXkCP7ai', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:44', '2026-10-11 05:17:44', NULL),
(249, 'RONALD LANGIT RAMADHAN', '20579998_91081149@siswa.prestasiku.id', '20579998_91081149', NULL, 1, NULL, '$2y$12$EW7nasp0EUaTB4x9Z4WPc.JxszeGY0FIVLBc5Mqodw6jddytRMc/W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:44', '2026-10-11 05:17:44', NULL),
(250, 'SANCAKA CESARIUS TRI HARSONO', '20579998_107033220@siswa.prestasiku.id', '20579998_107033220', NULL, 1, NULL, '$2y$12$A2DV5D/J5naQt10xc4sELufaxMACzHfc/zD3sRKgBvgmByfhyYW9W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:45', '2026-10-11 05:17:45', NULL),
(251, 'THARYQH AYDIL MUFAQQIH BUBU', '20579998_109849676@siswa.prestasiku.id', '20579998_109849676', NULL, 1, NULL, '$2y$12$xnCSSGuQddDvIr8lcRZi/.Ll9tE32OqAeyVsjccJAPfPlERxp.LtO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:45', '2026-10-11 05:17:45', NULL),
(252, 'VINO ALFIANO', '20579998_3105749757@siswa.prestasiku.id', '20579998_3105749757', NULL, 1, NULL, '$2y$12$45PZS.So8JPT3ocX7qtMC.Ie.GJFUPa1JAENZ5X.7fiFst2vXXBxC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:45', '2026-10-11 05:17:45', NULL),
(253, 'RAIHAN NANDITYA SYAWALIYANTO', '20579998_96916169@siswa.prestasiku.id', '20579998_96916169', NULL, 1, NULL, '$2y$12$wf/82IVer6n.YdiYiiIkWeBJR4a2ublGSjGoGdWcRDU1fnTF4QulO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:46', '2026-10-11 05:17:46', NULL),
(254, 'NAUFAL AHMAD ZHAFIR GHATHFAN', '20579998_106553039@siswa.prestasiku.id', '20579998_106553039', NULL, 1, NULL, '$2y$12$ezA9x5ZAJ33yLfAgsavQf.ag.5J3APJjfKHShx2YkV5hkWlH7v51u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:46', '2026-10-11 05:17:46', NULL),
(255, 'ARKAN ALGHAZI', '20579998_99159987@siswa.prestasiku.id', '20579998_99159987', NULL, 1, NULL, '$2y$12$r0v2PUebwe8xmlLhoHvgTePXRmguskwRs959k.NFq4mv2tzpl3EJm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:46', '2026-10-11 05:17:46', NULL),
(256, 'ADELIA SAVA AZ ZYDA', '20579998_96461964@siswa.prestasiku.id', '20579998_96461964', NULL, 1, NULL, '$2y$12$m4Fl5kZLBYgBNgkGfTxChe1s1sBmtcluy3BalYgKUxUhcLOq3pcAa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:47', '2026-10-11 05:17:47', NULL),
(257, 'AIDA AZKA AULIA', '20579998_3114187095@siswa.prestasiku.id', '20579998_3114187095', NULL, 1, NULL, '$2y$12$W9JcmM6W609xhkU/C30Yuu92PkyNu5sGBtd9EEj3AjjytyuHeu/Yi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:47', '2026-10-11 05:17:47', NULL),
(258, 'AIDA IRMA FIKRIYAH', '20579998_3082350779@siswa.prestasiku.id', '20579998_3082350779', NULL, 1, NULL, '$2y$12$3tZREgMSnC/NqQlqM1USfe6qJnopvtXH5GzXkVNw7SGygUijdgOju', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:47', '2026-10-11 05:17:47', NULL),
(259, 'ALFI MUSYAFA\'AH WIJAYATRI', '20579998_94078850@siswa.prestasiku.id', '20579998_94078850', NULL, 1, NULL, '$2y$12$JJ/TE.WIK3OG154AQmU8DOpswFcq3WC0MPn61S0huGUU.EaQKe/.a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:48', '2026-10-11 05:17:48', NULL),
(260, 'ANAYA JANEETA GUSEVA PUTRI', '20579998_99366176@siswa.prestasiku.id', '20579998_99366176', NULL, 1, NULL, '$2y$12$wtl20xl4xe7HpBubxqaOjeQHWQhJ4typfaVotJRP1y29zgx/KdnIe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:48', '2026-10-11 05:17:48', NULL),
(261, 'ANDINI KURNIA PERTIWI', '20579998_87221908@siswa.prestasiku.id', '20579998_87221908', NULL, 1, NULL, '$2y$12$v7FtfDlfWjjo1/mcIVjnmuWsiBD3n8KJL44JrBLOus/aviE/GfgUC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:49', '2026-10-11 05:17:49', NULL),
(262, 'ANNISA KHOLIFATUR ROSYIDAH', '20579998_95399733@siswa.prestasiku.id', '20579998_95399733', NULL, 1, NULL, '$2y$12$CtrxkC0s6PuR86AXHICqAOzxMVIhHdJxaTkPABk9y12GDA/UyBzr2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:49', '2026-10-11 05:17:49', NULL),
(263, 'ASA AYYAKUN DARIS SALAMAH', '20579998_3101331783@siswa.prestasiku.id', '20579998_3101331783', NULL, 1, NULL, '$2y$12$4NOUEjwIN456qOcIYV7tvuVHki7E2kS6ZnU/GqzW7Tb7sMABF/oUe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:49', '2026-10-11 05:17:49', NULL),
(264, 'AURA MAR\'ATUS SHOLIKHA', '20579998_97125518@siswa.prestasiku.id', '20579998_97125518', NULL, 1, NULL, '$2y$12$CESkRE3UOKtFtoPFCfnSYe5.qtDf7HPwOivm2G.xWkVAElK8MrPQ6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:50', '2026-10-11 05:17:50', NULL),
(265, 'AZIZAH WIJI LESTARI', '20579998_96138438@siswa.prestasiku.id', '20579998_96138438', NULL, 1, NULL, '$2y$12$vCuJ./9Hi5zUCusbwpOExOdvSuSMxUdM3i5Ibve5HYK9w41tgn5x.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:50', '2026-10-11 05:17:50', NULL),
(266, 'DEWI MAUIZATUL GHILVANA', '20579998_95626616@siswa.prestasiku.id', '20579998_95626616', NULL, 1, NULL, '$2y$12$bI5W7Bmh5Ycyk/Qp73wKkuKKoDatP8oaK.URgBM.gx6UI4JEVD2/C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:50', '2026-10-11 05:17:50', NULL),
(267, 'DEWI TUNJUNG ARUM', '20579998_63236155@siswa.prestasiku.id', '20579998_63236155', NULL, 1, NULL, '$2y$12$gLINhHi5EfFPYKt7qhsRd.AWw5GYqobyAskF5hPpIEECU00boGSfG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:51', '2026-10-11 05:17:51', NULL),
(268, 'FENTI AULIA RAHMAWATI', '20579998_94078628@siswa.prestasiku.id', '20579998_94078628', NULL, 1, NULL, '$2y$12$7Mfpm6.i6Nxo6XKGvcTMZebfQPjNHAEoafbUc.VI1TVxqDfSgeNWK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:51', '2026-10-11 05:17:51', NULL),
(269, 'FITRIA NURIL AZKYA', '20579998_94858270@siswa.prestasiku.id', '20579998_94858270', NULL, 1, NULL, '$2y$12$dZrLhvf1WAxAF8UDD9uvwuyaDC2E5MELBa6ok3p7K7vdDYlVyAHqG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:51', '2026-10-11 05:17:51', NULL),
(270, 'HAFIZHAH LAILATIS SA\'ADAH', '20579998_3106233713@siswa.prestasiku.id', '20579998_3106233713', NULL, 1, NULL, '$2y$12$zRUrrdpIBzSSsMcEa17gFeOn7ySNw5tTa8JY2oY7COJni7g3JT4JK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:52', '2026-10-11 05:17:52', NULL),
(271, 'HAFSHAH AMIRAH ARFAH', '20579998_3107453080@siswa.prestasiku.id', '20579998_3107453080', NULL, 1, NULL, '$2y$12$VYDy0i3/Buks8tZuRACRze9p44Hau64SXytIJkaDAJNNSLQrF.j36', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:52', '2026-10-11 05:17:52', NULL),
(272, 'INDRA ARIFATUL ITSNAINI', '20579998_3089582930@siswa.prestasiku.id', '20579998_3089582930', NULL, 1, NULL, '$2y$12$NfVDkkCLf9hQay2c4ep.e.jr9cCsatlbDLcnNxNqaZ8PUnoV/tH9u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:52', '2026-10-11 05:17:52', NULL),
(273, 'INTAN ROFANIATUL HIDAYAH', '20579998_3093940680@siswa.prestasiku.id', '20579998_3093940680', NULL, 1, NULL, '$2y$12$4mRqkDDnqukPIrMDd4rrQOmCzKvAGpQc1OOaZS3f.m2jFgvl1ky4q', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:53', '2026-10-11 05:17:53', NULL),
(274, 'LESTARI LATINA NURJANNAH', '20579998_97688547@siswa.prestasiku.id', '20579998_97688547', NULL, 1, NULL, '$2y$12$XodIgh345Uzhm7eP4C049..43PVmkd4qIAvOBpHc/tkpuhBOLoyVO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:53', '2026-10-11 05:17:53', NULL),
(275, 'MEIDA ANINDA PUTRI', '20579998_3107143784@siswa.prestasiku.id', '20579998_3107143784', NULL, 1, NULL, '$2y$12$763dc8vlwRT8d7cAsXEwTu0x9OZ1bDfxwMVhPFLy2lGMfjs/7EIQS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:54', '2026-10-11 05:17:54', NULL),
(276, 'NABILA PUTRI SAUNA', '20579998_3098643225@siswa.prestasiku.id', '20579998_3098643225', NULL, 1, NULL, '$2y$12$ldVQf/cbmRVMGfc4ng8LA.rrzh92m76I9/5Z5ErE76woHv/5AJqb2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:54', '2026-10-11 05:17:54', NULL),
(277, 'NABILAH HAIBATUR ROIHANAH', '20579998_102647954@siswa.prestasiku.id', '20579998_102647954', NULL, 1, NULL, '$2y$12$ZH5mbRmMC4xZ.J40DSI1SeqhW/hPzlF3TWC.k7XbLnIERoDNYyfqy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:54', '2026-10-11 05:17:54', NULL),
(278, 'NADIAH MUTIAH RAHMAH', '20579998_93314675@siswa.prestasiku.id', '20579998_93314675', NULL, 1, NULL, '$2y$12$1fKEq/xR1s5RxtYheAg2QOpR6ckCAjpcKfQ5GAv0dmja8TGsJKZuy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:55', '2026-10-11 05:17:55', NULL),
(279, 'NAMIRA AULIA ZAHROH', '20579998_3113687279@siswa.prestasiku.id', '20579998_3113687279', NULL, 1, NULL, '$2y$12$mWvyDJN3CiTRfptBeRSZ3OVhvDU5Jtwc5cBI4iRn5f.uZ7iFHhpCi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:55', '2026-10-11 05:17:55', NULL),
(280, 'NANAKUM MALASARI', '20579998_92545202@siswa.prestasiku.id', '20579998_92545202', NULL, 1, NULL, '$2y$12$SyLylMXcOLZeJH2QhBvsye3kaFzmal.Ib8.xWRHK4g7ZUbsO8Fx.2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:56', '2026-10-11 05:17:56', NULL),
(281, 'NIYAZ SALMA AULIA', '20579998_82079245@siswa.prestasiku.id', '20579998_82079245', NULL, 1, NULL, '$2y$12$FkiiUwmbg4akup9Ph/C8hun4ihcsHc4Iyf.WjDT/lmjvNAV51ywV.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:56', '2026-10-11 05:17:56', NULL),
(282, 'NOURO YASMIN FIELEILAH ANNAFISA', '20579998_108250259@siswa.prestasiku.id', '20579998_108250259', NULL, 1, NULL, '$2y$12$EQzX01rluBWyZVgyRl7dnuu4VCXiFZhTedSppDanHbAiCVo26PYAq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:56', '2026-10-11 05:17:56', NULL),
(283, 'NUR FAIZA', '20579998_3100805928@siswa.prestasiku.id', '20579998_3100805928', NULL, 1, NULL, '$2y$12$ft7XLe6lPVOsTjvx3wSK4Oq41dUSzX5AHfZinOdYjwQCC0E7WPgEq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:57', '2026-10-11 05:17:57', NULL),
(284, 'NUR MAZIDATUN NI\'MAH', '20579998_3107533741@siswa.prestasiku.id', '20579998_3107533741', NULL, 1, NULL, '$2y$12$yHWLNXElLfw3HVQeNzSBAela7Z6gTfE7zhMRD.rxINuzK.8/Wr2gq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:57', '2026-10-11 05:17:57', NULL),
(285, 'RIZCHA SEKAR MARCELLIA', '20579998_3090634002@siswa.prestasiku.id', '20579998_3090634002', NULL, 1, NULL, '$2y$12$kcucP3kDOra6Ynjy8FPXCe7i.aiXWypw5sDdoWKyr.GBgHJDwBUvO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:57', '2026-10-11 05:17:57', NULL),
(286, 'SALMAH AL ATTAS', '20579998_101254800@siswa.prestasiku.id', '20579998_101254800', NULL, 1, NULL, '$2y$12$5vzrZGvXVIi1QkhanRiEvOOC.oN6BLD05tgxeK1JGiuGzSi4VcTRS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:58', '2026-10-11 05:17:58', NULL),
(287, 'SHOVWANICA PUTRI PRASETYO', '20579998_108068156@siswa.prestasiku.id', '20579998_108068156', NULL, 1, NULL, '$2y$12$D.pun7wNwggImM2oEgyW7uG.0GA7pn.DTU1YxKHY/69gX/REomtaa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:58', '2026-10-11 05:17:58', NULL),
(288, 'SITI KUMALA MILLATA ROSADA', '20579998_95236806@siswa.prestasiku.id', '20579998_95236806', NULL, 1, NULL, '$2y$12$qrpLEY9e7sUIz92uYt9h/e4fG7u1OPxMUXhuGKnC7DBvId8jxplWW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:58', '2026-10-11 05:17:58', NULL),
(289, 'TSAMARA UFAIRAH ADZKA', '20579998_105804614@siswa.prestasiku.id', '20579998_105804614', NULL, 1, NULL, '$2y$12$ms1sAnkLp3tXZdMCLhR1H.7R8b.RhaE3iZ4.bB4zJXy57Z8iZeJj6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:59', '2026-10-11 05:17:59', NULL),
(290, 'WAFA ZAHROTUN KAMILAH', '20579998_105884491@siswa.prestasiku.id', '20579998_105884491', NULL, 1, NULL, '$2y$12$BPoTjU38/.ZR6DX1X1bQr.TvczbDHoe6hbpX7nRocG5w.hJV.aDnm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:59', '2026-10-11 05:17:59', NULL),
(291, 'YUDHITA ZULFANA', '20579998_109104689@siswa.prestasiku.id', '20579998_109104689', NULL, 1, NULL, '$2y$12$4b/OE8k./4nypYLZg54i1.wPDVaWxo07i8S8UQDiLVGz1rOVt0DO2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:17:59', '2026-10-11 05:17:59', NULL),
(292, 'ZAHWA AZZAH AMALIA', '20579998_103443493@siswa.prestasiku.id', '20579998_103443493', NULL, 1, NULL, '$2y$12$/qtMSGtMP5HcnSWYhfnZkuWKpIdXCZcXQjvJspkgIuKXI/hlubjDu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:00', '2026-10-11 05:18:00', NULL),
(293, 'ELLIYANA ROSHIDAH TAUFIQ', '20579998_91042510@siswa.prestasiku.id', '20579998_91042510', NULL, 1, NULL, '$2y$12$vW242zXPHTZIOfPAzIGZveuQfvmKFvCOjGoS9Q8QmZtZB.KsmnKu2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:00', '2026-10-11 05:18:00', NULL),
(294, 'STACY AURORA LATANZA', '20579998_3092931898@siswa.prestasiku.id', '20579998_3092931898', NULL, 1, NULL, '$2y$12$zBd9UZ3UduGnjl4PPs9BWOcMxnMHvFNW3TKsIqtTOz1ZuSibKtRAi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:01', '2026-10-11 05:18:01', NULL),
(295, 'ACHMAD FAYZ RAYAN AFRI CEZA.MD', '20579998_3104897692@siswa.prestasiku.id', '20579998_3104897692', NULL, 1, NULL, '$2y$12$x5Mq9T5ulE0Z1j56F.dpQuCrB4rUjMpw.uXUdhu65iULyDoihfgau', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:01', '2026-10-11 05:18:01', NULL),
(296, 'ACHMAD YANUAR REZHA', '20579998_3106313215@siswa.prestasiku.id', '20579998_3106313215', NULL, 1, NULL, '$2y$12$ckzeYfDhqXMkkMDfgdTR1OP.j1dEWJiqyssVGPJ4HOT3R1NdLHsdm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:01', '2026-10-11 05:18:01', NULL),
(297, 'ADAM XAVIER NIBROOS AL-HUDA', '20579998_3092050377@siswa.prestasiku.id', '20579998_3092050377', NULL, 1, NULL, '$2y$12$VCRHE96IjOF6xnNAiEyHyOSTnOt6EymGWBlzOqDwNqw0BHtGcJpra', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:02', '2026-10-11 05:18:02', NULL),
(298, 'AHMAD MUTHOHAR SANUSI', '20579998_91305902@siswa.prestasiku.id', '20579998_91305902', NULL, 1, NULL, '$2y$12$HF83ZvVYerFfiQdMqAEwLuUUOv5ddf19frclm.YoTEUhh1JiUEd1i', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:02', '2026-10-11 05:18:02', NULL),
(299, 'ALIF ZAIDAN MAULANA', '20579998_97130420@siswa.prestasiku.id', '20579998_97130420', NULL, 1, NULL, '$2y$12$6QU2DtpKvfdcJBcitrLS.usNmFDHgLIcI/UAOudJkj5jZGNBt30z.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:03', '2026-10-11 05:18:03', NULL),
(300, 'ARIF MANUNGGAL PUTRA AL-KHOIRUL', '20579998_108878143@siswa.prestasiku.id', '20579998_108878143', NULL, 1, NULL, '$2y$12$YW0dKdH2XZHhZWYpmZeI9.KJpja1EWF4buu19Ls2W2zrasbZRboRC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:03', '2026-10-11 05:18:03', NULL),
(301, 'DAFFA MIFZAL ROMADHAN', '20579998_92490221@siswa.prestasiku.id', '20579998_92490221', NULL, 1, NULL, '$2y$12$idkIm.NKXvuC1jTm2NulFu/.C08HVqMz69f6dAmoJ6303Gzo6wA42', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:04', '2026-10-11 05:18:04', NULL),
(302, 'DAFFA RHEYHAN MUSYAFFA', '20579998_98339628@siswa.prestasiku.id', '20579998_98339628', NULL, 1, NULL, '$2y$12$yXGN9j667XL/tliGysf0nubPdOpr1b9nabBAXcj4cO.SeXi6F553K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:05', '2026-10-11 05:18:05', NULL),
(303, 'DZAKY SYARIF MUHAMMAD', '20579998_3107340470@siswa.prestasiku.id', '20579998_3107340470', NULL, 1, NULL, '$2y$12$3HBkqqHnrm8ZOCWgtnMbBeVkVdejJWsigDiMRwh2EPLCKIpnvm1L.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:05', '2026-10-11 05:18:05', NULL),
(304, 'FADIL MUKTI JUNIAR', '20579998_3101758417@siswa.prestasiku.id', '20579998_3101758417', NULL, 1, NULL, '$2y$12$.omxXM53FbpRaDWZZoagp.mcWN8Assv7Ymr.VJBd4x..U23niM2Cu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:05', '2026-10-11 05:18:05', NULL),
(305, 'FIKRAM BAIHAQI ZUKRILLAH', '20579998_94176108@siswa.prestasiku.id', '20579998_94176108', NULL, 1, NULL, '$2y$12$BP4DoxAtaRukuBA/N5Syae1RZ9qKug2gcrmoJ3atnIwb.LQRh/LJK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:06', '2026-10-11 05:18:06', NULL),
(306, 'GHIYAS SABIQ AL FATHIN', '20579998_3103944475@siswa.prestasiku.id', '20579998_3103944475', NULL, 1, NULL, '$2y$12$4nXpnfyzOFBwEKnMv0oS/.s//oG/6w2jeNnM89TU8lAYgBDclJE2q', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:06', '2026-10-11 05:18:06', NULL),
(307, 'HAMDAN ISMA\'IL', '20579998_95311016@siswa.prestasiku.id', '20579998_95311016', NULL, 1, NULL, '$2y$12$EK0o8SMkKeug1j4GO05uv.lad3Gxz3iVBL7KJni/abjR8llj.EKUK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:06', '2026-10-11 05:18:06', NULL),
(308, 'IRSYADUL IBAD', '20579998_105391736@siswa.prestasiku.id', '20579998_105391736', NULL, 1, NULL, '$2y$12$9LXj7lg22TIg8Bluijz8e.qZnq4Oja7PpxzDB1JInhiaDQwF5jyqG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:07', '2026-10-11 05:18:07', NULL),
(309, 'JOAN AFLAH MAHSUNI', '20579998_94139149@siswa.prestasiku.id', '20579998_94139149', NULL, 1, NULL, '$2y$12$geHMSIBONfjBzzwjjIAekOk1LWN6y0maaStXLre/cAO2gDwXWqfrC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:07', '2026-10-11 05:18:07', NULL),
(310, 'JUNDI DHIYAUL HAQ AL HAMDANI', '20579998_3089745635@siswa.prestasiku.id', '20579998_3089745635', NULL, 1, NULL, '$2y$12$WOcd3ywgpiaPooyQzPpoweI3tlUuT2cO1ZybEO0rLzMtmGdhBEQt6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:08', '2026-10-11 05:18:08', NULL),
(311, 'M. ZUHRO SYIFA', '20579998_105676601@siswa.prestasiku.id', '20579998_105676601', NULL, 1, NULL, '$2y$12$VKmTWMTKVzQm0.xutv04RuGkCbTBsGA7SalttgTQ2BgIVDB2HSyhO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:08', '2026-10-11 05:18:08', NULL),
(312, 'MAULANA DZAKY AL-BUSTHOMI', '20579998_3096648345@siswa.prestasiku.id', '20579998_3096648345', NULL, 1, NULL, '$2y$12$fassxgPUXi03/nr8CcJ0xOOKNmtWcy91Ex79xNfb5BspwZCWiaFyK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:08', '2026-10-11 05:18:08', NULL),
(313, 'MOHAMMAD TORIQ', '20579998_89841280@siswa.prestasiku.id', '20579998_89841280', NULL, 1, NULL, '$2y$12$oK7b1Q9uFnyTmJ7N6W5/Uu1FkrszeCpYXbrG0lXvaqMv9P5691MHO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:09', '2026-10-11 05:18:09', NULL),
(314, 'MUHAMAD ABBY AUSHAF AL GHIFARI', '20579998_103290823@siswa.prestasiku.id', '20579998_103290823', NULL, 1, NULL, '$2y$12$Lez9QdBRVQT8o8eerScAhuThmtlVzzsoye3b7./t65cTABQd/i0MG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:09', '2026-10-11 05:18:09', NULL),
(315, 'MUHAMMAD ABID ALFERO', '20579998_3109788579@siswa.prestasiku.id', '20579998_3109788579', NULL, 1, NULL, '$2y$12$jnMHRqLKWctYV4jFRvIuGO7Zqw5mBZHM2pUqBIhLKvxRTw.j1tmq6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:10', '2026-10-11 05:18:10', NULL),
(316, 'MUHAMMAD AL-FAREZI UBAIDILLAH', '20579998_3096195102@siswa.prestasiku.id', '20579998_3096195102', NULL, 1, NULL, '$2y$12$17WGE6ltN4qydHE8nESTF.lN2ipY5C3wRMOGtLFUSItkXS031DF3i', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:10', '2026-10-11 05:18:10', NULL),
(317, 'MUHAMMAD ALTHIF ABIR HYAA', '20579998_107234496@siswa.prestasiku.id', '20579998_107234496', NULL, 1, NULL, '$2y$12$CHTIldaBggHt3UylTmXNIelHwNYdT6Of6yXS6ukY31YBDV1VhJfx2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:10', '2026-10-11 05:18:10', NULL),
(318, 'MUHAMMAD AQIL FAHMI IRCHAM', '20579998_105014967@siswa.prestasiku.id', '20579998_105014967', NULL, 1, NULL, '$2y$12$Z12dTrfPAPJUXkTJnQRPoeGs15F6WBhSmh.xcA863Msclhpdq1AMu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:11', '2026-10-11 05:18:11', NULL),
(319, 'MUHAMMAD AUFAR ATSIRUDDIN', '20579998_3092235034@siswa.prestasiku.id', '20579998_3092235034', NULL, 1, NULL, '$2y$12$jvt028FtJSumLI/CfL1LhOfXTY55cnHyMlAgU9G4OyOigmHFMNdSS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:11', '2026-10-11 05:18:11', NULL),
(320, 'MUHAMMAD DANIEL AL FIKRI', '20579998_3091394103@siswa.prestasiku.id', '20579998_3091394103', NULL, 1, NULL, '$2y$12$/ibUURg8QGNYClOBlLFhEOWBmq2T2MVjXpvvZvuWVeDBz3lTPt0si', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:11', '2026-10-11 05:18:11', NULL),
(321, 'MUHAMMAD FAHRI ROBBAANI', '20579998_93364165@siswa.prestasiku.id', '20579998_93364165', NULL, 1, NULL, '$2y$12$A3y1eSLB5JRD89cpN94F9OtnYKlKZvWUAWL/LbZeZgEkquPV4Y8r2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:12', '2026-10-11 05:18:12', NULL),
(322, 'MUHAMMAD MAULIDDANI MARVELLINO', '20579998_3098405606@siswa.prestasiku.id', '20579998_3098405606', NULL, 1, NULL, '$2y$12$cS6nfzad.T6MQff40T0h8O6FcCvGvlQyScsvU2v/Sv004037cwyXe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:12', '2026-10-11 05:18:12', NULL),
(323, 'MUHAMMAD RAFI NAJATI', '20579998_3103340701@siswa.prestasiku.id', '20579998_3103340701', NULL, 1, NULL, '$2y$12$qUNgYftKia/DfMXpL8ua4Oh/OnwZCVHSFchG4bPdMd9PXnznwGGUa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:13', '2026-10-11 05:18:13', NULL),
(324, 'MUHAMMAD RAFLI', '20579998_96502286@siswa.prestasiku.id', '20579998_96502286', NULL, 1, NULL, '$2y$12$UCeAZWtE7lmoqNQc5gnWQuG9okXoy.nbnRptpddD7MQ2oPUkOzYVq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:13', '2026-10-11 05:18:13', NULL),
(325, 'MUHAMMAD RAIHAN HARIST SANDI', '20579998_3102356463@siswa.prestasiku.id', '20579998_3102356463', NULL, 1, NULL, '$2y$12$3COdqXZMC0PcYOb/mWNk/OQULKmauCUQrl.Sf4MXo3nAhSKlGhW.K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:13', '2026-10-11 05:18:13', NULL),
(326, 'MUHAMMAD RIDHO BAYU SATRIA', '20579998_91461882@siswa.prestasiku.id', '20579998_91461882', NULL, 1, NULL, '$2y$12$LWbwYlnLwvmW2Ms2vBoyNO7AN1u3gXYFv4M4IflUjRmn8QUrfBr4.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:14', '2026-10-11 05:18:14', NULL),
(327, 'QIWAMUL KHAFI', '20579998_3107544384@siswa.prestasiku.id', '20579998_3107544384', NULL, 1, NULL, '$2y$12$zMw2RWH5EwGo.lQ7uYbOOeJLn9ofAYK.7MJS.G.zxsjqx1xBFAhs2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:14', '2026-10-11 05:18:14', NULL),
(328, 'RAFI PUTRA IBRAHIM', '20579998_98194912@siswa.prestasiku.id', '20579998_98194912', NULL, 1, NULL, '$2y$12$0tzAn8BcL73oVmusqFnn8u6L0ape8g40f0.rK4vA9B3QR9P/jkIFK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:14', '2026-10-11 05:18:14', NULL),
(329, 'REZZA MAULANA NUR RIDWAN', '20579998_98280835@siswa.prestasiku.id', '20579998_98280835', NULL, 1, NULL, '$2y$12$0/YP6rzKbNa2Fh0nac6LyOsYIEWzMDaWthT.4G6mi4Ie5rsSsCnoy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:15', '2026-10-11 05:18:15', NULL),
(330, 'ROYYAN ABDULLAH ZUHAIR', '20579998_109955821@siswa.prestasiku.id', '20579998_109955821', NULL, 1, NULL, '$2y$12$SAIQqgYmu9jgn0Q2kvk42u0fVYIoP7M98QSEgJAh4v3pgR1EyOb.O', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:15', '2026-10-11 05:18:15', NULL),
(331, 'SA\' DAN AQIIL', '20579998_102477677@siswa.prestasiku.id', '20579998_102477677', NULL, 1, NULL, '$2y$12$R0jpgGMLPbVvascgUexLQe08Ocg4xlz4vX2AzYoljLXGAyYZJmXV.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:16', '2026-10-11 05:18:16', NULL),
(332, 'MUHAMMAD HAMDAN BAHAUDDIN', '20579998_97613680@siswa.prestasiku.id', '20579998_97613680', NULL, 1, NULL, '$2y$12$yPv7c4PEqHjqejPczt5FJuBwI5yr8p0YKlISsy6RJa8cyS09Me2l.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:17', '2026-10-11 05:18:17', NULL),
(333, 'JAVIER AHMAD AR RAMDHANI', '20579998_107641506@siswa.prestasiku.id', '20579998_107641506', NULL, 1, NULL, '$2y$12$j7j5FeU8y31GFCHwhsr3/uGwemO/QdWNYqmOMXZQrMbrIddcHJZbC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:18', '2026-10-11 05:18:18', NULL),
(334, 'YONKI AZHEEMA SUARNO PUTERA', '20579998_3092592729@siswa.prestasiku.id', '20579998_3092592729', NULL, 1, NULL, '$2y$12$E2PAUF/F.Y1bjIm1AL4XHu5WruG/CxmATW.xD8Gf3FZhuNmVdeAIe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:18', '2026-10-11 05:18:18', NULL),
(335, 'MUCHAMMAD FAKHRI HAMZAH', '20579998_108255209@siswa.prestasiku.id', '20579998_108255209', NULL, 1, NULL, '$2y$12$WCOGVK4ytBer8Zx9FbPYcO323zdjvtjv5myjYGS.HpzhSqzn7yetq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:19', '2026-10-11 05:18:19', NULL),
(336, 'BINTANG PRAMUDHIA PURNOMO', '20579998_106717034@siswa.prestasiku.id', '20579998_106717034', NULL, 1, NULL, '$2y$12$gtkJkuvkB87Beket/ytIzeALNrO7mFaB.YUkVt./NumJgXY/wrska', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:19', '2026-10-11 05:18:19', NULL),
(337, 'A IMMATUL KHOIRIYAH', '20579998_3099457560@siswa.prestasiku.id', '20579998_3099457560', NULL, 1, NULL, '$2y$12$syfqapZ76axRUycYMVvZ0.Jnreim1sRlM8As0Whtd9noT6UaDTudO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:20', '2026-10-11 05:18:20', NULL),
(338, 'AGHISNI NADHRA HAKIM', '20579998_3096202977@siswa.prestasiku.id', '20579998_3096202977', NULL, 1, NULL, '$2y$12$3YQv5qS5sFguwSMtmByRhuoRPLVcFRKwBOYKBeaNTEm9yrsxocmJy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:20', '2026-10-11 05:18:20', NULL),
(339, 'AINURROHMAH FARAH AULIA', '20579998_3107795075@siswa.prestasiku.id', '20579998_3107795075', NULL, 1, NULL, '$2y$12$NtlX0UibBTBbCXueN39A8ehglHYuv0X.W.xemL1AVvqrsQHENo.Vm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:21', '2026-10-11 05:18:21', NULL),
(340, 'AISYY ALVI FAKHRANI', '20579998_3105173291@siswa.prestasiku.id', '20579998_3105173291', NULL, 1, NULL, '$2y$12$kMUFrEoMIFs6.PBxk1m91uTMEfcgoS4RcS68mtiVm.6062dJSHeZC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:21', '2026-10-11 05:18:21', NULL),
(341, 'ALISA KIRANI SAFITRI', '20579998_93085631@siswa.prestasiku.id', '20579998_93085631', NULL, 1, NULL, '$2y$12$LKY2qZhkNYmwJVn4RoNVqeHBjBWDAwWtzMrJYtOsN1GbFhtzGwBIK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:21', '2026-10-11 05:18:21', NULL),
(342, 'ANINDYA NASHIFA PUTRI SOLIKHA', '20579998_103500075@siswa.prestasiku.id', '20579998_103500075', NULL, 1, NULL, '$2y$12$T8R6K/sqj6emW4Xx5jsunOSOSbDVbOH087GGaGgOtr1WAlwXZfGka', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:22', '2026-10-11 05:18:22', NULL),
(343, 'AQILA LATHIFATUN NISA\'', '20579998_101088762@siswa.prestasiku.id', '20579998_101088762', NULL, 1, NULL, '$2y$12$Vkof77owjW4kzvMyJlTLBeU5Bg8RI.x5ITmsiTGMENf7VvHX8OrnK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:22', '2026-10-11 05:18:22', NULL),
(344, 'ARINA RAHMA TANAZILA', '20579998_98362634@siswa.prestasiku.id', '20579998_98362634', NULL, 1, NULL, '$2y$12$7LFgx84RcD.INkGb./Or4up2wnaFroNYVs4N1W743C7ZayuJW8lR6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:23', '2026-10-11 05:18:23', NULL),
(345, 'BALQUES SELMA AL KHUMAIROH', '20579998_3102975407@siswa.prestasiku.id', '20579998_3102975407', NULL, 1, NULL, '$2y$12$ycf471hyj6erk1zZq2Xm0./WxlEfQQRBT5ISCOz/x4oO2mhq9BUCa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:24', '2026-10-11 05:18:24', NULL),
(346, 'BARBY ANGEL WIDI OKTA PRATAMA', '20579998_97395918@siswa.prestasiku.id', '20579998_97395918', NULL, 1, NULL, '$2y$12$VKVVwdBv073Ax/xojVmJse2FdYMwT2PEpydb3bP0ACJtsWBXCXa4a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:24', '2026-10-11 05:18:24', NULL),
(347, 'CAHAYA PUTRI TAHTA ZANZABILA', '20579998_91821117@siswa.prestasiku.id', '20579998_91821117', NULL, 1, NULL, '$2y$12$8wAJiGc.wPjgSMmanOt1Rez/UJZaYNyzLgc9bzoVrJwTct72dAAwm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:24', '2026-10-11 05:18:24', NULL),
(348, 'CAMILA NUR INAYAH', '20579998_93110905@siswa.prestasiku.id', '20579998_93110905', NULL, 1, NULL, '$2y$12$wYEj61Q7Itp3MmXYAndjyecXKI7gksRa6F0F7QgkrX3X0M2TCyi8S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:25', '2026-10-11 05:18:25', NULL),
(349, 'CINDY ARIMBI SELLA RAMADHANI', '20579998_3100346273@siswa.prestasiku.id', '20579998_3100346273', NULL, 1, NULL, '$2y$12$.Cc63FUVOpUcz9NOAxMUh.GU2kK05BVlIMifaeEodoG4O441DimEO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:25', '2026-10-11 05:18:25', NULL),
(350, 'DANIA ATHIYA ZAHRA', '20579998_102159682@siswa.prestasiku.id', '20579998_102159682', NULL, 1, NULL, '$2y$12$0gEjssG1983KtzWbdYA//epCI7ByqgwcoXweN/VwyDY/LdgS05lfS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:26', '2026-10-11 05:18:26', NULL),
(351, 'FAATIMATUZZAHROH', '20579998_3102886104@siswa.prestasiku.id', '20579998_3102886104', NULL, 1, NULL, '$2y$12$HguDs3UYcTcruhPtuuLk6.iWwP2qmWnUghwiRjcluyZM7pQoqi5Gu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:27', '2026-10-11 05:18:27', NULL),
(352, 'FAIRUZ KHANZA WAHYUANA', '20579998_3092546066@siswa.prestasiku.id', '20579998_3092546066', NULL, 1, NULL, '$2y$12$L6MH6HQMo/T6EVyYEoCMte2TpydeBiBMV0zktI47YAQTo2KAksLBq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:27', '2026-10-11 05:18:27', NULL),
(353, 'FARIHATUS SHOBAH', '20579998_3090854504@siswa.prestasiku.id', '20579998_3090854504', NULL, 1, NULL, '$2y$12$jlvi91DssOeceuuRvHCePO0elRVAtFeup9mMuAK5r6OZOGNkygmJS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:27', '2026-10-11 05:18:27', NULL),
(354, 'FITHROTIN NUHA UMMU AUFA', '20579998_97133915@siswa.prestasiku.id', '20579998_97133915', NULL, 1, NULL, '$2y$12$W.nOhY9vn.fPM5uKqQ5ml.Js0hKNbSN5yEoeC7NhUnKvDD08uXL/S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:28', '2026-10-11 05:18:28', NULL),
(355, 'FLORISTA ECHA KIRANA PUTRI', '20579998_91234867@siswa.prestasiku.id', '20579998_91234867', NULL, 1, NULL, '$2y$12$WS2cR7QyBpD.1yszZzzAT.uLztlNsvbKoGZh8GTrk2KfWuHScSZOy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:28', '2026-10-11 05:18:28', NULL),
(356, 'HANNY HALONA SELENA NADINE', '20579998_101103560@siswa.prestasiku.id', '20579998_101103560', NULL, 1, NULL, '$2y$12$XGCs24UlejRzQ9jRJyv6pujSUGbqAc/AGtWTTTOtTqfVnUZUO0qui', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:28', '2026-10-11 05:18:28', NULL),
(357, 'HILYATUN NAFISAH', '20579998_3096880561@siswa.prestasiku.id', '20579998_3096880561', NULL, 1, NULL, '$2y$12$3d8fRl76L3TUu8lcWUKN6e4QQFIL..ukWX.9NQq31cbX7CfzDpMve', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:29', '2026-10-11 05:18:29', NULL),
(358, 'JIHAN ZUHROTUS SYAHIROH', '20579998_3102339218@siswa.prestasiku.id', '20579998_3102339218', NULL, 1, NULL, '$2y$12$kLyJxVFjS66Dcd5uKK3fj.KcdWgsmmc.O8bPJyawWAgK9xImh9IgS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:29', '2026-10-11 05:18:29', NULL),
(359, 'JOVITA ELYSIA DAHAYU', '20579998_97418228@siswa.prestasiku.id', '20579998_97418228', NULL, 1, NULL, '$2y$12$HZ.ogS04BMJvGt0S6n5deed4lDUKqYCFCRw9eQcZhG9FRXDnuIY7a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:30', '2026-10-11 05:18:30', NULL),
(360, 'JULFA NURBAITI', '20579998_108126168@siswa.prestasiku.id', '20579998_108126168', NULL, 1, NULL, '$2y$12$JgJP2pOVMwY28ErBRmxTO.bRH9D87cA/zPf6BqYFRyV56x8IneBP2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:30', '2026-10-11 05:18:30', NULL),
(361, 'KARIN ADZKA ISFAHANY', '20579998_108180371@siswa.prestasiku.id', '20579998_108180371', NULL, 1, NULL, '$2y$12$4pGDSJnMhfiBe5CXvaaWaOs3.nseyB906epbKe6NBZOQOXpJuI6yq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:31', '2026-10-11 05:18:31', NULL),
(362, 'KHANSA HANIYAH NAJLA AL-NURI', '20579998_3103148723@siswa.prestasiku.id', '20579998_3103148723', NULL, 1, NULL, '$2y$12$fuTc2eU6eJbeGzQ/xIak2OnvxqyLlF0OVxOJHAsGc5vmzzSOyhL7W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:31', '2026-10-11 05:18:31', NULL),
(363, 'KHOFIFAH NUR SALIM', '20579998_3096740342@siswa.prestasiku.id', '20579998_3096740342', NULL, 1, NULL, '$2y$12$NMTqU1lXkdX/SrSCmzF5n.zFsagiXMT84.k1BZZDu8gs627BOHsGG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:31', '2026-10-11 05:18:31', NULL),
(364, 'MAULAN MAHA RANI', '20579998_3104037969@siswa.prestasiku.id', '20579998_3104037969', NULL, 1, NULL, '$2y$12$TSwR1TUCCYsWUbe5Z5CV2OJfUEdz9eAeInEr0qD1XD8DNhFAWb1eO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:32', '2026-10-11 05:18:32', NULL),
(365, 'MEIFTAHUL VANIA', '20579998_106862928@siswa.prestasiku.id', '20579998_106862928', NULL, 1, NULL, '$2y$12$Sjo90DVLAyUuwIT7tdOo6.pb2I.YV19tmCnuk9ZQGrmYQQUM.5RsK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:32', '2026-10-11 05:18:32', NULL),
(366, 'NABILA SALSA RIHLATUS ZAHRO', '20579998_3107675590@siswa.prestasiku.id', '20579998_3107675590', NULL, 1, NULL, '$2y$12$UZeIJSVEdo7etcsmd4W5n.i.hIwAXKjQZwaiXWWyj.3X5gLN.vm.m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:33', '2026-10-11 05:18:33', NULL),
(367, 'NADHIFA AULIA', '20579998_3092982220@siswa.prestasiku.id', '20579998_3092982220', NULL, 1, NULL, '$2y$12$YSsVoseCV.wTIvoXg5tUXe8RJXR3riC0gx9/zt6oXbraNJhLHTDRy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:33', '2026-10-11 05:18:33', NULL),
(368, 'NAJWA LAILIA', '20579998_3107860093@siswa.prestasiku.id', '20579998_3107860093', NULL, 1, NULL, '$2y$12$oWHtAFDHV4zbWiGdjyrohuk3/Ho59pKOR1iytag5Fa9GvD/6DoLxK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:34', '2026-10-11 05:18:34', NULL),
(369, 'NAJWA SALSABILA ARDIANTY', '20579998_95641482@siswa.prestasiku.id', '20579998_95641482', NULL, 1, NULL, '$2y$12$CIZWLUwNIgIWmhIOz2n6NeSfqcBnzgv5H2SqsMK6LMP/evpBEmCfm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:34', '2026-10-11 05:18:34', NULL),
(370, 'NAURA PUTRI FIRDIANITA', '20579998_103189900@siswa.prestasiku.id', '20579998_103189900', NULL, 1, NULL, '$2y$12$s/Yr2luHWL41pOfJaqbwZOqICRxbt82zewzauauf8lp27wvH.92NS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:35', '2026-10-11 05:18:35', NULL),
(371, 'NAZLA AZZAHROTUL AULIYA', '20579998_3093444121@siswa.prestasiku.id', '20579998_3093444121', NULL, 1, NULL, '$2y$12$.Ftz4.2wrczLCytBwNcnFOHCNUQiYDeKjypNY0rXkmmjxf9BrHU6G', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:35', '2026-10-11 05:18:35', NULL),
(372, 'RAHMA TRI RAHAYU', '20579998_3098951442@siswa.prestasiku.id', '20579998_3098951442', NULL, 1, NULL, '$2y$12$MnSCP7Fki4oceFnp3iMLT.KxBV0xUxIiRqrlyz/HWKtRnXVz1aWWm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:36', '2026-10-11 05:18:36', NULL),
(373, 'RAISYA DWI FAJRIA', '20579998_95799983@siswa.prestasiku.id', '20579998_95799983', NULL, 1, NULL, '$2y$12$wugxPs7RfJ4GZeCxiFUA7O69XzShAvihDpAlP0cRoiPx//cNjEInq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:37', '2026-10-11 05:18:37', NULL),
(374, 'SALSABILA NOVITA', '20579998_3107050917@siswa.prestasiku.id', '20579998_3107050917', NULL, 1, NULL, '$2y$12$cbdWl6DJ/7VavgxL/4e8FOaMdvjp2nKKKfBBcRp1HSmTjmAsjZGle', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:37', '2026-10-11 05:18:37', NULL),
(375, 'SALWA KAMILAH SHOLEH', '20579998_3101185370@siswa.prestasiku.id', '20579998_3101185370', NULL, 1, NULL, '$2y$12$h5lxm3kOcTmIqqrrwxCWHehXBegoYqKwk63vJVkD6otacB6KsWlQq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:38', '2026-10-11 05:18:38', NULL),
(376, 'SINDY AULIYA ARIADI', '20579998_96168167@siswa.prestasiku.id', '20579998_96168167', NULL, 1, NULL, '$2y$12$awJxmKmog3wzyOBR57ITdOPQ.AY9MNZDMPlBCBcnxsIBbYubOOgbi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:38', '2026-10-11 05:18:38', NULL),
(377, 'SU\'UDIYAH AYU RIZQIA', '20579998_3094965806@siswa.prestasiku.id', '20579998_3094965806', NULL, 1, NULL, '$2y$12$gzjQlLniqmkRyoc1UfVKau6iMzAsakyiQtFzzbkTbr7fnU8bj4Df2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:39', '2026-10-11 05:18:39', NULL),
(378, 'SYAVA ADI NUR', '20579998_3092016550@siswa.prestasiku.id', '20579998_3092016550', NULL, 1, NULL, '$2y$12$hkDCqe1H02kTieChx.8a.ePHB9C1/YysjTxXdR30TQEkX3ID3QIaK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:39', '2026-10-11 05:18:39', NULL),
(379, 'SYIFA PUTRI RAHMADANI', '20579998_96575392@siswa.prestasiku.id', '20579998_96575392', NULL, 1, NULL, '$2y$12$1nJddlDkUIoQX0hTBKGX9.yOSe0ZJTaMUw6JNTwtGXuYB.TE.BCJ.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:40', '2026-10-11 05:18:40', NULL);
INSERT INTO `users` (`id`, `name`, `email`, `username`, `phone`, `school_id`, `email_verified_at`, `password`, `must_change_password`, `password_changed_at`, `last_login_at`, `last_login_ip`, `status`, `remember_token`, `created_at`, `updated_at`, `deleted_at`) VALUES
(380, 'THIFFANY ZUHROTUL AMALIYYAH', '20579998_107231379@siswa.prestasiku.id', '20579998_107231379', NULL, 1, NULL, '$2y$12$uuJvLgl618s1X4DwVahPUe2vjUAEkhmHpJMGGH4hjroQHCzCNZv1.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:40', '2026-10-11 05:18:40', NULL),
(381, 'YASMIN NADZIFAH MAULIDIYAH', '20579998_3091371351@siswa.prestasiku.id', '20579998_3091371351', NULL, 1, NULL, '$2y$12$O1bgBbdyrkwoIDeCerOif.oW1Fv97Ksf1K67/OFd8VBBbjgHxf//K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:41', '2026-10-11 05:18:41', NULL),
(382, 'ZAYYINA MAHYA BIFAZILATIL FITRIA', '20579998_91240643@siswa.prestasiku.id', '20579998_91240643', NULL, 1, NULL, '$2y$12$rmMBKUTEs/fgDVTeUV/hQuOFrZ8os2KswpRws8p08Lnw.0HDJauCu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:41', '2026-10-11 05:18:41', NULL),
(383, 'ABDAN GHOYAYA', '20579998_97694081@siswa.prestasiku.id', '20579998_97694081', NULL, 1, NULL, '$2y$12$JGpf3lqs2o7NABDzp9QF2.8N9J2iscY/GpxwyccD6wF6cIz80/pNa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:41', '2026-10-11 05:18:41', NULL),
(384, 'ALFIAN MUHAMMAD ALFATIH', '20579998_3092605176@siswa.prestasiku.id', '20579998_3092605176', NULL, 1, NULL, '$2y$12$aDSwRGqo9Vqz8Yvoae/v1uL2aW1xyzDunqKuF2ul.f9NtgkPTUqtG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:42', '2026-10-11 05:18:42', NULL),
(385, 'MUHAMMAD HAFIDZ JAMALUL MUSTHOFA', '20579998_107202405@siswa.prestasiku.id', '20579998_107202405', NULL, 1, NULL, '$2y$12$5xpICjZ/5F5A8dTjouSzvO3QIIvJFIiCOmPCSUbBGBy/JcvRnWpjm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:42', '2026-10-11 05:18:42', NULL),
(386, 'M. IDHAM AL ADHAWI', '20579998_3097998063@siswa.prestasiku.id', '20579998_3097998063', NULL, 1, NULL, '$2y$12$6I9qWyEdYRVELDAZ2SO/quOdIFlhGyxblNLPCqI.v/I0p5mDqQ9we', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:43', '2026-10-11 05:18:43', NULL),
(387, 'MOCH. ARROYYAN FIKRI NAZARI', '20579998_3095325490@siswa.prestasiku.id', '20579998_3095325490', NULL, 1, NULL, '$2y$12$E/F2xrz2j5V4Qaqro/URxORNPBiXJ8K3f5/BPtu9cZM.p6aJAgQWS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:43', '2026-10-11 05:18:43', NULL),
(388, 'MUHAMAD FAQIHAN TIRTADINALA', '20579998_3084947869@siswa.prestasiku.id', '20579998_3084947869', NULL, 1, NULL, '$2y$12$tYRxpSA/ojeYOMFdEy3CO.DLCBk7I2lW/Rd4jd.a2ZCgbdb2NbGjm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:44', '2026-10-11 05:18:44', NULL),
(389, 'MUHAMMAD ADITYA NUGRAHA', '20579998_102253963@siswa.prestasiku.id', '20579998_102253963', NULL, 1, NULL, '$2y$12$ECFli3GvCrc3xOQqr0UCieF3O5lI3/BKbBmihWMJp/VE7aaScnHW.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:44', '2026-10-11 05:18:44', NULL),
(390, 'MUHAMMAD ATTARSYAH', '20579998_92242208@siswa.prestasiku.id', '20579998_92242208', NULL, 1, NULL, '$2y$12$RMyUzV3VLnJWfbrRgGLP6OeJh7qcLUN1QO18R.5Rmw6TuWYtZdDeC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:44', '2026-10-11 05:18:44', NULL),
(391, 'MUHAMMAD DZULKARNAIN', '20579998_99491668@siswa.prestasiku.id', '20579998_99491668', NULL, 1, NULL, '$2y$12$nij/2W4Q53T02CLuiZ8je.t62ZuUWDj8dUCxvi.goUVvth/gax5d6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:45', '2026-10-11 05:18:45', NULL),
(392, 'NAUFAL AWWALUL AZMI', '20579998_102435070@siswa.prestasiku.id', '20579998_102435070', NULL, 1, NULL, '$2y$12$uIRVqvPxoJgRTNwL8.PEneozvfBtqaaRmaDcfbvwgpLbuQY.CsfSu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:45', '2026-10-11 05:18:45', NULL),
(393, 'FAHAD ABDUL JALIL SUPADI', '20579998_87398701@siswa.prestasiku.id', '20579998_87398701', NULL, 1, NULL, '$2y$12$bT14OhYYPiAwdgoy8GxkOeOjX59RjG/pQgoDG6hFVUkH6czVgXpRW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:46', '2026-10-11 05:18:46', NULL),
(394, 'WAHYU IBTA ADITYA', '20579998_3078740928@siswa.prestasiku.id', '20579998_3078740928', NULL, 1, NULL, '$2y$12$Gt6fVh9pxEGGm6.L3ZFnbOh/5jNXa1ipizvvkwhL7YcIJycrVVoGG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:46', '2026-10-11 05:18:46', NULL),
(395, 'AHMAD MUHAJIR AL-GHIFARI', '20579998_3078277898@siswa.prestasiku.id', '20579998_3078277898', NULL, 1, NULL, '$2y$12$Wx21NqBrPg4QxQftRdrx9OHvm64rcH7syaW5DWLfmGDG3oFl5f3HO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:46', '2026-10-11 05:18:46', NULL),
(396, 'AMRINA ROSYADA RAHMANIA Z', '20579998_3100141927@siswa.prestasiku.id', '20579998_3100141927', NULL, 1, NULL, '$2y$12$nM4GRFuQdMh1/UyYxrpaoOIhGth/uPjynOfAgMpcUyimoq0ZiQQ0K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:47', '2026-10-11 05:18:47', NULL),
(397, 'NAZILLAH RAHMANIA PUTRI', '20579998_3102971691@siswa.prestasiku.id', '20579998_3102971691', NULL, 1, NULL, '$2y$12$LccNUjFw7GTiSJWBI3VAJOTyc3cPAAV5zFyGGPgmDNVf3oR6wgiCy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:47', '2026-10-11 05:18:47', NULL),
(398, 'QUEENZA MUMAYYIZAH', '20579998_106414600@siswa.prestasiku.id', '20579998_106414600', NULL, 1, NULL, '$2y$12$DMCL4eTVIBhRKBic9YsOsOnkI/zAfB/xlTDHayOfgsDMcGmPHtUX6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:47', '2026-10-11 05:18:47', NULL),
(399, 'ZHULFA NABILLA ULYA', '20579998_3092642359@siswa.prestasiku.id', '20579998_3092642359', NULL, 1, NULL, '$2y$12$n7oBs3fAZEpxftCS53LKP.yd6iLXygjuBf4C8sSpziPeUh2Qf/uUq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:48', '2026-10-11 05:18:48', NULL),
(400, 'ZINNIA SHERENE AQUILA', '20579998_97426729@siswa.prestasiku.id', '20579998_97426729', NULL, 1, NULL, '$2y$12$vWZ1BItqK/hI3TOl9jXpF.VaCsa6krA2ztICUNBmxUYS5mkIXOE3K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:48', '2026-10-11 05:18:48', NULL),
(401, 'YESITA NOVELIA RENITA PUTRI', '20579998_93418200@siswa.prestasiku.id', '20579998_93418200', NULL, 1, NULL, '$2y$12$fAFQopjJo/3fcz9Q9/.0Z.VoPEzMRQYFnnTRQLi9t0kYq.ADIGDHq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:48', '2026-10-11 05:18:48', NULL),
(402, 'SARAH KHADIJAH AL KUBRO', '20579998_82867496@siswa.prestasiku.id', '20579998_82867496', NULL, 1, NULL, '$2y$12$LRsA1HmojVHeBJPsEJ5dPegLORVIQY7RsdqYZpdzBXiZZo6iE1j7u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:49', '2026-10-11 05:18:49', NULL),
(403, 'ACHMAD RAFI AR -ROCHMAN', '20579998_98693294@siswa.prestasiku.id', '20579998_98693294', NULL, 1, NULL, '$2y$12$0WtJ3wzlfGN/QhuTq/UbIuGCwhE2OoVmUbp2WqJOd2lhEKH5v8H4y', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:49', '2026-10-11 05:18:49', NULL),
(404, 'AFGAN SALAFI\' MAULANA AL HUSNIN', '20579998_3089497619@siswa.prestasiku.id', '20579998_3089497619', NULL, 1, NULL, '$2y$12$WQaA41bIGDMyEpFqMFOpDegPfkpNf78hbUjFE4mcsywR69r6sek06', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:49', '2026-10-11 05:18:49', NULL),
(405, 'AHMAD ASIF BUKHIYA', '20579998_107838392@siswa.prestasiku.id', '20579998_107838392', NULL, 1, NULL, '$2y$12$mTHEAXztrbnmhnT/O9/UReyl8X5V44ZwjMBMXTOWDVhPNJHISM4cq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:50', '2026-10-11 05:18:50', NULL),
(406, 'AHMAD DURMUJI ARIF', '20579998_109131930@siswa.prestasiku.id', '20579998_109131930', NULL, 1, NULL, '$2y$12$VRsof5BJvtvdAyXHr0leOeVYjUseapJybzoKC.A/TQ5kV4H1F1m22', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:50', '2026-10-11 05:18:50', NULL),
(407, 'AHMED ATHAR NUR YUDISTIRA', '20579998_3094706387@siswa.prestasiku.id', '20579998_3094706387', NULL, 1, NULL, '$2y$12$ZSaH/KZikZdwY9idRGsnb.Ew.NI9iphAl.9sFNRFwDrq35BUlpHl.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:51', '2026-10-11 05:18:51', NULL),
(408, 'AZKA ATHIAH PERDANA SUHARIYANTO', '20579998_3096591166@siswa.prestasiku.id', '20579998_3096591166', NULL, 1, NULL, '$2y$12$TSkbBoJ6/ihNYWWNvxRyYeTnmUKA400/5QyOYCUXpUzv4EW1h6hOy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:51', '2026-10-11 05:18:51', NULL),
(409, 'M. FAQIH ASYHARI', '20579998_95696059@siswa.prestasiku.id', '20579998_95696059', NULL, 1, NULL, '$2y$12$AFBLRgXVIHBNeQgdh/rGqeqCQomiySKzThu/8W8EH4QFZLgXApJDK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:51', '2026-10-11 05:18:51', NULL),
(410, 'MOCH. KAAFI NAFIL ARZAQI', '20579998_107989474@siswa.prestasiku.id', '20579998_107989474', NULL, 1, NULL, '$2y$12$yG67QWxquPCl7/kzBfnQIOjM0YouTCyen7v7.590cPYQg929M3pJK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:52', '2026-10-11 05:18:52', NULL),
(411, 'MUHAMMAD AQIL RAHMAN', '20579998_3103747218@siswa.prestasiku.id', '20579998_3103747218', NULL, 1, NULL, '$2y$12$ExyioTf9ov7GaLX79qio5uYHc7Zl.DPKwoLEjr/DqJ12550q1tuzW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:52', '2026-10-11 05:18:52', NULL),
(412, 'MUHAMMAD HILAL SYA\'BAN MIFTAHUDDIN', '20579998_97275136@siswa.prestasiku.id', '20579998_97275136', NULL, 1, NULL, '$2y$12$BjWOL.FugVjlIa/NvLFFleemnca1ioKRjg4Dk04xH1Tes/5fdzMZK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:52', '2026-10-11 05:18:52', NULL),
(413, 'MUHAMMAD HUBBI SYAUQI', '20579998_3080305992@siswa.prestasiku.id', '20579998_3080305992', NULL, 1, NULL, '$2y$12$1Jxa9thr4YGzUpV1OAzNs.SXt/uyVtUraAklIfICdbJotZytxsLnK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:53', '2026-10-11 05:18:53', NULL),
(414, 'MUHAMMAD ZIDA LUFTAN NAFIQ', '20579998_3108188513@siswa.prestasiku.id', '20579998_3108188513', NULL, 1, NULL, '$2y$12$gQqTrezU3NLiZEU3mFQ5Hu7/0aKbP1vg3C7ZKT3LjddUP5v1QhvEK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:53', '2026-10-11 05:18:53', NULL),
(415, 'MUHAMMAD ZIYAD AFKARUL HIKAM', '20579998_3095980925@siswa.prestasiku.id', '20579998_3095980925', NULL, 1, NULL, '$2y$12$1hDKhZtHPv0gkfwhMLDld.WCHzWrEGKBDKlVY8TkI79zRKigqMgfO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:54', '2026-10-11 05:18:54', NULL),
(416, 'NEHRU MANDALA HAMKA', '20579998_3108613550@siswa.prestasiku.id', '20579998_3108613550', NULL, 1, NULL, '$2y$12$7L3PDE/ViyMBSk.BilZJre.wJ7IlQJeJqgZF3ELjFBPkvrZwlmPKm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:54', '2026-10-11 05:18:54', NULL),
(417, 'RAFIE KENAN YONINDA PUTRA', '20579998_3107258712@siswa.prestasiku.id', '20579998_3107258712', NULL, 1, NULL, '$2y$12$e3TBX2MRam9d5j1tvogWC.h86oFA84Mu5EVW13oH03Q83IyduEPxC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:54', '2026-10-11 05:18:54', NULL),
(418, 'RAIHAN FUADY', '20579998_3090104312@siswa.prestasiku.id', '20579998_3090104312', NULL, 1, NULL, '$2y$12$Og/oVxedBk79EfD8Zbs3lemfWRo.KoVyGBRsUGFDKX6kEcNP.HWcK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:55', '2026-10-11 05:18:55', NULL),
(419, 'SOEKARNO HATTA', '20579998_103943759@siswa.prestasiku.id', '20579998_103943759', NULL, 1, NULL, '$2y$12$3c4KTRlU.almWt4UkOr5Zu5/zvYc4BsYuGwVSCLHk1ONfwEUwOyse', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:55', '2026-10-11 05:18:55', NULL),
(420, 'THORIK IMANSYAH', '20579998_105555535@siswa.prestasiku.id', '20579998_105555535', NULL, 1, NULL, '$2y$12$RXvdUeE6gV.w03xgv3OBxu7IDjwTHJSp3opDOJkykaOdEacemaL5u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:55', '2026-10-11 05:18:55', NULL),
(421, 'THUFAIL MUHAMMAD FURQON', '20579998_3100859778@siswa.prestasiku.id', '20579998_3100859778', NULL, 1, NULL, '$2y$12$ISrc9B9WTUlL9h540ccjaOvLrKGeg.y0JW2cANJe3Lt.VGcYSmrz2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:56', '2026-10-11 05:18:56', NULL),
(422, 'REVANSYAH FAWWAS', '20579998_98355876@siswa.prestasiku.id', '20579998_98355876', NULL, 1, NULL, '$2y$12$qBPeXAqKGuJc6FJo5hyELOjJ3Ybr3Cpa8h1Miv6Uax5Y17HWE0LaK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:56', '2026-10-11 05:18:56', NULL),
(423, 'FAHRI AKMAL HANAFI', '20579998_1049233237@siswa.prestasiku.id', '20579998_1049233237', NULL, 1, NULL, '$2y$12$t0EOTxIpW4znSsm.YblcZOu6EvtztzRz0GAnraHsKV0IbxANaqzzS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:57', '2026-10-11 05:18:57', NULL),
(424, 'ADILAH NUR ASYIFA', '20579998_108789384@siswa.prestasiku.id', '20579998_108789384', NULL, 1, NULL, '$2y$12$y0wiGv4JNLkMFsbjJP8hN.Y7Kwe9EovbGAyEE9ejolLbyRO7Im0L2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:57', '2026-10-11 05:18:57', NULL),
(425, 'ALFIESHA ANNUR', '20579998_91527648@siswa.prestasiku.id', '20579998_91527648', NULL, 1, NULL, '$2y$12$aqkjv995etL4CGOOl7XEReOpytYOnDe4aM9Qsa4GY4b30DHMP7vP2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:57', '2026-10-11 05:18:57', NULL),
(426, 'ANINDITA RAHMATUL LAILI', '20579998_3093967691@siswa.prestasiku.id', '20579998_3093967691', NULL, 1, NULL, '$2y$12$RA2lCzNtZOZNap/BTIlBY.2GkVY67gS/Ay3VLyTn5SYmnFujOzlJu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:58', '2026-10-11 05:18:58', NULL),
(427, 'ANISA NUR OKTAVIA', '20579998_3097368480@siswa.prestasiku.id', '20579998_3097368480', NULL, 1, NULL, '$2y$12$lgHhcqokoWbiBqzlqBA.T.ePle9HIyd/EnNq/Kx4ZFsme.274aUL.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:58', '2026-10-11 05:18:58', NULL),
(428, 'BARO\'ATUL AZFA AULIA', '20579998_83277735@siswa.prestasiku.id', '20579998_83277735', NULL, 1, NULL, '$2y$12$EhnuTaupufxpOSYJlfHSa.oO.peobf6P0aSy1V26aW3Ck2Pte356S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:58', '2026-10-11 05:18:58', NULL),
(429, 'BUNGA AZIZAH ZAZKYA BALQIS', '20579998_3096500481@siswa.prestasiku.id', '20579998_3096500481', NULL, 1, NULL, '$2y$12$nOseo3dxvieqDhYMj2ASnOJxqsb3xqHLtgYJZin9NLXAFM7.QgN/q', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:59', '2026-10-11 05:18:59', NULL),
(430, 'DIAN FATMA SALAMAH', '20579998_108522867@siswa.prestasiku.id', '20579998_108522867', NULL, 1, NULL, '$2y$12$1CSIRfJemO8R3cljp3gLb.f49aprKJNMOfsjfFXvxLodM3Gm5.M92', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:59', '2026-10-11 05:18:59', NULL),
(431, 'HAGIA SOFIA', '20579998_98576541@siswa.prestasiku.id', '20579998_98576541', NULL, 1, NULL, '$2y$12$ribJP0wsDmbrGJ71Gbz0uOcULSo6wH7aqRmizqAsyPV/SUUOTtcY2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:18:59', '2026-10-11 05:18:59', NULL),
(432, 'KINETHA AISYAH RACHMANIAH', '20579998_93234893@siswa.prestasiku.id', '20579998_93234893', NULL, 1, NULL, '$2y$12$8O06C3tLIshOBrhBmUm/Iu88P/ZKIMw3I3ZGW/b/LbFC7xZC.lNwO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:00', '2026-10-11 05:19:00', NULL),
(433, 'MIRZA FAZA ILYA MUZDALIFA', '20579998_94977211@siswa.prestasiku.id', '20579998_94977211', NULL, 1, NULL, '$2y$12$A..QoqV3ERCnmXhRYupdMe1WO68ck3I2R7qhI0Uo2qWvu6AH06olK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:00', '2026-10-11 05:19:00', NULL),
(434, 'NAILUS SA\'ADAH', '20579998_3107104596@siswa.prestasiku.id', '20579998_3107104596', NULL, 1, NULL, '$2y$12$tbQPFZbksUHlj3pcOi0u.emK.3S/3USeHFCTGlNYNEIoaqrrKP.12', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:00', '2026-10-11 05:19:00', NULL),
(435, 'NAVISAH AFIFATUR ROHMAH', '20579998_98752243@siswa.prestasiku.id', '20579998_98752243', NULL, 1, NULL, '$2y$12$zlz9T14imM2NmTjIBr/pjO2GHBrxyGIU9qKkQN4sqlboTAGlg1Qbm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:01', '2026-10-11 05:19:01', NULL),
(436, 'NUR AIDA FAUZIYAH', '20579998_3091402855@siswa.prestasiku.id', '20579998_3091402855', NULL, 1, NULL, '$2y$12$baow3YuqFv1/o88wH9VOx.cvTxAPbYWQhsfXrzb19oB6mF.USRLQ6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:01', '2026-10-11 05:19:01', NULL),
(437, 'SINTA FAUZIYAH', '20579998_94596905@siswa.prestasiku.id', '20579998_94596905', NULL, 1, NULL, '$2y$12$UKxYqsBqj8f4pv9ZvfjXEuW6G/n3tAF2HjkodBBB71O14rdqqXQ7i', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:02', '2026-10-11 05:19:02', NULL),
(438, 'YUNIKA ABDAN SYAKURA', '20579998_94159416@siswa.prestasiku.id', '20579998_94159416', NULL, 1, NULL, '$2y$12$RvoLiKIECY6H1L0M.DSMzups7Le6EqRrpgWcVR.YVXPskze2TYFWK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:02', '2026-10-11 05:19:02', NULL),
(439, 'DIAH AYU PUTRI RAMADHANI', '20579998_84306603@siswa.prestasiku.id', '20579998_84306603', NULL, 1, NULL, '$2y$12$MuRGBRVlYXYtHe4n7F2sK.FvK3vS.D6c0jfndHoqKs79eNRzkdogi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:03', '2026-10-11 05:19:03', NULL),
(440, 'NAJWA LAILA ARINA CHOSYATILLAH', '20579998_99444154@siswa.prestasiku.id', '20579998_99444154', NULL, 1, NULL, '$2y$12$0Vq4pj9b.P1LuedrTjYgPuo/qww8fKOlhYaxEtYsYOq.9BoAm2T56', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:03', '2026-10-11 05:19:03', NULL),
(441, 'ACHMAD HAQI HIDAYATULLOH ARROSYID', '20579998_3083469693@siswa.prestasiku.id', '20579998_3083469693', NULL, 1, NULL, '$2y$12$Siwl2hvn.CPd4AmExmcR9O7YYOtcOMdO1lAWf/UG6Bd.r.jaFmLrS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:04', '2026-10-11 05:19:04', NULL),
(442, 'ACMED ARFAZ HARAMAIN', '20579998_99918538@siswa.prestasiku.id', '20579998_99918538', NULL, 1, NULL, '$2y$12$q8QkzKnwCEUKyokaQVg0m.ld3LMaknugyr4aAbXbTQz5Txi/K/INS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:04', '2026-10-11 05:19:04', NULL),
(443, 'ADAM RANGGA SISWA ATMAJA', '20579998_76837772@siswa.prestasiku.id', '20579998_76837772', NULL, 1, NULL, '$2y$12$WeI9cr515QnMN1J6B8jSVOUWeeLVqLfntTza7DAZKk5XpOtArP69S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:04', '2026-10-11 05:19:04', NULL),
(444, 'AHMAD FADHLI ROBBI', '20579998_83182568@siswa.prestasiku.id', '20579998_83182568', NULL, 1, NULL, '$2y$12$LHvym.7PziIZIDycLop97OD6QT1NUw7NHDLxAX8PUlR7WBdkEPQ.W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:05', '2026-10-11 05:19:05', NULL),
(445, 'AHMAD NAJIH AL ANWAR', '20579998_91417661@siswa.prestasiku.id', '20579998_91417661', NULL, 1, NULL, '$2y$12$6gz1oysiSy2oQ1BH29kufuofDx2flouLNt5i1DV1PDdHT0MWTLgWe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:05', '2026-10-11 05:19:05', NULL),
(446, 'AHMAD SHOFHAL JAMIL AL KAFIE', '20579998_3086590560@siswa.prestasiku.id', '20579998_3086590560', NULL, 1, NULL, '$2y$12$1QyOHFdXJU5dsXWOGT6naOiaAlnhFTSg86u7WxRdJy7uTKpCvEVsK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:06', '2026-10-11 05:19:06', NULL),
(447, 'AHMAD SYAIFULLAH', '20579998_82903568@siswa.prestasiku.id', '20579998_82903568', NULL, 1, NULL, '$2y$12$l6DAbL8rmPvE318B.bOzseQHE2hJxxq2jjVyclXQZERqDIG26Zx9i', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:06', '2026-10-11 05:19:06', NULL),
(448, 'AQHMAT RIDWAN GUNAWAN', '20579998_83824918@siswa.prestasiku.id', '20579998_83824918', NULL, 1, NULL, '$2y$12$5KmdLu1N1q7L4itYdzi8DuBHiL5Bl1wPigBxat2gnxwK0hJXy/BYS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:06', '2026-10-11 05:19:06', NULL),
(449, 'AZUAN ELKA RAMA AL SYAHRUL', '20579998_3095888277@siswa.prestasiku.id', '20579998_3095888277', NULL, 1, NULL, '$2y$12$vC85pwctdFOqs5N6/Ypk3OC1BVXSl5LS/4cPYZfM2FaOroMH7nmae', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:07', '2026-10-11 05:19:07', NULL),
(450, 'FALICHUL AMROINI', '20579998_94781041@siswa.prestasiku.id', '20579998_94781041', NULL, 1, NULL, '$2y$12$Xlh4TKVEQHez4suNGRjE6ub3JpeanHN4tt8k1BXPl1S9EV5vZP2aW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:07', '2026-10-11 05:19:07', NULL),
(451, 'HAFIZH ZAHRAN NUGRAHA', '20579998_75696924@siswa.prestasiku.id', '20579998_75696924', NULL, 1, NULL, '$2y$12$p3Ag0dmMtEADCKD83MUOFelQb07v6jwqb/neLnqAEIjhfg5EQ/vBW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:08', '2026-10-11 05:19:08', NULL),
(452, 'HAIDAR MAHYA SURYA SABILILLAH', '20579998_91170364@siswa.prestasiku.id', '20579998_91170364', NULL, 1, NULL, '$2y$12$DcyCYRlJQeVC5kUOPdJexuryg495GQjzTxcN1yDVeWf80HUJ4eaRG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:08', '2026-10-11 05:19:08', NULL),
(453, 'KENZA ATMAWEKA AHNAF', '20579998_3084495934@siswa.prestasiku.id', '20579998_3084495934', NULL, 1, NULL, '$2y$12$W8O95IuBl81TeIlg9Ws0R.PZD5T4V.axA3Gs5qM989ES8bJakDtRK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:08', '2026-10-11 05:19:08', NULL),
(454, 'MOCH. ALIF ARDIANSYAH', '20579998_96447666@siswa.prestasiku.id', '20579998_96447666', NULL, 1, NULL, '$2y$12$DJFkDCcRdAEblvLCj/cc5uuUfvWJJQMMX2F/aOGcZo33qeGyTyG12', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:09', '2026-10-11 05:19:09', NULL),
(455, 'MOH RIKHY RAMADHANI AL FAQIH', '20579998_3084930045@siswa.prestasiku.id', '20579998_3084930045', NULL, 1, NULL, '$2y$12$ysWzxaES.XpW9pombXtUu.2IqbixCzNIiB61uVi7aNd83WTu1VyN6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:09', '2026-10-11 05:19:09', NULL),
(456, 'MOHAMMAD DAFFA\'UDIN NABHAN', '20579998_93644571@siswa.prestasiku.id', '20579998_93644571', NULL, 1, NULL, '$2y$12$E0uwAFqaUGGEFXtIyVaNVuJe.Y.H6TZS7LtcaiPhkDCKTa2Lwh/5y', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:10', '2026-10-11 05:19:10', NULL),
(457, 'MUHAMMAD ADDIN HIDAYATULLOH', '20579998_3082174807@siswa.prestasiku.id', '20579998_3082174807', NULL, 1, NULL, '$2y$12$mac5zJdH1Olp/wifssOa5eEwJPlDjCTVcQEVr3XvyBAPVpQQsEkda', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:10', '2026-10-11 05:19:10', NULL),
(458, 'MUHAMMAD ADITYA PRATAMA', '20579998_3086134534@siswa.prestasiku.id', '20579998_3086134534', NULL, 1, NULL, '$2y$12$LiHjxpwOdgzlSm/T05rKpuawO2Ddz1fTy2hDW9HhuHmIRbPeQsnVu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:10', '2026-10-11 05:19:10', NULL),
(459, 'MUHAMMAD FERDY FIRMANSYAH', '20579998_3089064136@siswa.prestasiku.id', '20579998_3089064136', NULL, 1, NULL, '$2y$12$fzqDBanh1CACq7acx0rJqO4PTNAuBC.tYIZmkiM.PqJMYWh59sEXa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:11', '2026-10-11 05:19:11', NULL),
(460, 'MUHAMMAD IFDHOL HARIRI', '20579998_82904549@siswa.prestasiku.id', '20579998_82904549', NULL, 1, NULL, '$2y$12$S/tT3zw.unyOJOAoPCEet.iVPxs1e0kyNDnH2rQaSi/1dPCHwgf2.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:11', '2026-10-11 05:19:11', NULL),
(461, 'MUHAMMAD MADHAN SUGIHARTONO', '20579998_95881437@siswa.prestasiku.id', '20579998_95881437', NULL, 1, NULL, '$2y$12$JjaDD4SOUPj.47e3NWrWAebz3M5widKM3UCboKNWZ8J3ox4/iY18u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:12', '2026-10-11 05:19:12', NULL),
(462, 'MUHAMMAD RAFFY ADITYA', '20579998_3081615719@siswa.prestasiku.id', '20579998_3081615719', NULL, 1, NULL, '$2y$12$7ZFX0/ghpB5tB29y8tlFauMDsKaboRzwuL3XUe/dzy00cE5Jn2tVK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:12', '2026-10-11 05:19:12', NULL),
(463, 'MUHAMMAD YUSUF PUTRA PRATAMA', '20579998_85636017@siswa.prestasiku.id', '20579998_85636017', NULL, 1, NULL, '$2y$12$KKC.u2qijWQnAHFSYtUdP.J7qNM3LRfUgvwyDRZrrKLpmCaPIsOFq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:12', '2026-10-11 05:19:12', NULL),
(464, 'SAYYI ERIDANI HATAMI', '20579998_84915328@siswa.prestasiku.id', '20579998_84915328', NULL, 1, NULL, '$2y$12$rrAnIjyfmRUyT5NAAGiuP.ScyPkFrJG/7fFAt0gSezqSTdJepXYuq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:13', '2026-10-11 05:19:13', NULL),
(465, 'TEGUH HARIYANTO', '20579998_97428156@siswa.prestasiku.id', '20579998_97428156', NULL, 1, NULL, '$2y$12$jJ/9APqIBX/soKFnghtrIuo46Oue1o62GOfxTzhrE71.Lk1qsS2wa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:13', '2026-10-11 05:19:13', NULL),
(466, 'AHMAD FUAD Al-MUAYYAD', '20579998_95951816@siswa.prestasiku.id', '20579998_95951816', NULL, 1, NULL, '$2y$12$eW52QIGGlnn.cMrrbAVR7Oew9hcfgbZUPbyXLajXDuhEKrkxuolwK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:14', '2026-10-11 05:19:14', NULL),
(467, 'AMELIA NANDA SAFITRI', '20579998_3089703581@siswa.prestasiku.id', '20579998_3089703581', NULL, 1, NULL, '$2y$12$uLswxpEodbc5PzCrdjujxugMm3yjeGrwKfqJe/q2Z1Ds4pUsn1gIW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:14', '2026-10-11 05:19:14', NULL),
(468, 'AYU ALMIRA', '20579998_3095116742@siswa.prestasiku.id', '20579998_3095116742', NULL, 1, NULL, '$2y$12$sMWCPVnaBb4tTgxTVKOmPOfechYeEvMTEvi2xqLcfjFhR7UgS3Zk.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:14', '2026-10-11 05:19:14', NULL),
(469, 'AZALEA LAKHEISA PRADANA', '20579998_97789330@siswa.prestasiku.id', '20579998_97789330', NULL, 1, NULL, '$2y$12$quSbiLiZKge58y3H7Jp6eeJEEXI8XKfNUEt1tGjRSNv.9.2pVHnzO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:15', '2026-10-11 05:19:15', NULL),
(470, 'BUNGA INDAH LESTRAI', '20579998_3083996685@siswa.prestasiku.id', '20579998_3083996685', NULL, 1, NULL, '$2y$12$sp.Nabzz9M71LX3xklkit.Dkx4Dm4DdU8ToDY7OeekXfszEio4vaC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:15', '2026-10-11 05:19:15', NULL),
(471, 'CALLYSTA SASIKIRANA', '20579998_3092073739@siswa.prestasiku.id', '20579998_3092073739', NULL, 1, NULL, '$2y$12$hq8kIDlyA2LOx/9yDSa21.KtXsQ5wySWGZKG9IxZVEV6ZARbjmqPa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:16', '2026-10-11 05:19:16', NULL),
(472, 'CLAUDIA SINTA NURIYAH', '20579998_3086369277@siswa.prestasiku.id', '20579998_3086369277', NULL, 1, NULL, '$2y$12$Ehhx2A961PC6hNieazzDG.yiOuk.3YU3hiDpYpCmUKqrMYGRpJFd2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:16', '2026-10-11 05:19:16', NULL),
(473, 'DINTA AULIA KULBA', '20579998_91627584@siswa.prestasiku.id', '20579998_91627584', NULL, 1, NULL, '$2y$12$FLjl8i8squyc.nLd7O3KRe86kjzPzINnY1FWwn.kq8S3WIOjNebdO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:17', '2026-10-11 05:19:17', NULL),
(474, 'DWI FEBBI ZUMROTUN NISA\'', '20579998_3092664875@siswa.prestasiku.id', '20579998_3092664875', NULL, 1, NULL, '$2y$12$nyrO0geLciaEI.zWxnBf9ehOZTbvmm2a19jdO/KCpBqSWrEra1SWG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:17', '2026-10-11 05:19:17', NULL),
(475, 'ELSA WITRIANINGSIH', '20579998_92597365@siswa.prestasiku.id', '20579998_92597365', NULL, 1, NULL, '$2y$12$00PVzUGGZfCN/LPysISbD.gp3ZuAOA6azsieM6DP.IKJcmmmcPBBC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:18', '2026-10-11 05:19:18', NULL),
(476, 'ERICA ALVA RETTA', '20579998_3094532238@siswa.prestasiku.id', '20579998_3094532238', NULL, 1, NULL, '$2y$12$.ATo7gHDXMsZHfOppTESZOlPuORsDCJSptcvgswF6Yw0eX6cSCYza', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:18', '2026-10-11 05:19:18', NULL),
(477, 'FAIRUZA HIKMA AL ANSHORY', '20579998_3097113789@siswa.prestasiku.id', '20579998_3097113789', NULL, 1, NULL, '$2y$12$Gw0KVbvXwYRWqw4YVJp2IOQV2fnYGw5hTDRjmXkT/7EgfoRiwfvdi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:19', '2026-10-11 05:19:19', NULL),
(478, 'FAIZATUL WAHYUNING LESTARI', '20579998_51292710@siswa.prestasiku.id', '20579998_51292710', NULL, 1, NULL, '$2y$12$2gHxmqOKkEIi/JSQ9ArM.uSsVKNNZLuOZbv18zF0XGeQ9E4Q.Op/C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:19', '2026-10-11 05:19:19', NULL),
(479, 'FANI AFNAN JANNATI', '20579998_89185650@siswa.prestasiku.id', '20579998_89185650', NULL, 1, NULL, '$2y$12$HkqMFXobLOIZTz3MprfGCe.E1OlUZPzRMDmrpdKlUjA06eonDxaqm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:19', '2026-10-11 05:19:19', NULL),
(480, 'FARHATUS SALSABILA', '20579998_97377905@siswa.prestasiku.id', '20579998_97377905', NULL, 1, NULL, '$2y$12$nLJyI8zQgdcCrCDJrB09Y.Ji.6Yj.tXEHZOEur/dm9h0Hvxa8./k2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:20', '2026-10-11 05:19:20', NULL),
(481, 'FIANTIKA SELLYNA MUFTI', '20579998_86879709@siswa.prestasiku.id', '20579998_86879709', NULL, 1, NULL, '$2y$12$6ates9Or6TjMlOOydbF1sux2U8o7rU7S2WBseVX/LKUCkDpd92XU.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:21', '2026-10-11 05:19:21', NULL),
(482, 'GENDIS NURSAFITRI', '20579998_83691515@siswa.prestasiku.id', '20579998_83691515', NULL, 1, NULL, '$2y$12$c5FV03TduPvK4HYPhSwXdOgkJ6uICf..bcbjCObNjiB8wbuC73wNq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:21', '2026-10-11 05:19:21', NULL),
(483, 'HELEN DHEVITA ULVI', '20579998_3098043502@siswa.prestasiku.id', '20579998_3098043502', NULL, 1, NULL, '$2y$12$cWfuvFWfnIPHCxGAqEHovuqbxt2wiu7Po1i39FE12MrYiyYvmUwp.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:22', '2026-10-11 05:19:22', NULL),
(484, 'IFNATUS MUALIFAH', '20579998_87316170@siswa.prestasiku.id', '20579998_87316170', NULL, 1, NULL, '$2y$12$xQatdWmxHOLkVJdOVye29uOfxpxjFjJUNevHb8oeD3JINsxjcghKm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:23', '2026-10-11 05:19:23', NULL),
(485, 'ILLA NUR BAGIATUS SHOLIHAT', '20579998_94644990@siswa.prestasiku.id', '20579998_94644990', NULL, 1, NULL, '$2y$12$3sbuW2mmPDO0F7D4Q3fAAe3I4yS..0yZxwYdoNIPfrPS04s02w4AS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:24', '2026-10-11 05:19:24', NULL),
(486, 'INDAH AWWALUL KHULUQIYYAH', '20579998_97812710@siswa.prestasiku.id', '20579998_97812710', NULL, 1, NULL, '$2y$12$g/PogR0unfRLHCm3yGWTYuY4Xbzg37QL44hJHaZwi4agDNRroIzEm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:24', '2026-10-11 05:19:24', NULL),
(487, '\'ISYNA \'AUNA ELMAULA YUSRON', '20579998_3098585776@siswa.prestasiku.id', '20579998_3098585776', NULL, 1, NULL, '$2y$12$2xA2efxap6x/wdAbj7cLpuggWKdEUzAQynOHqtZNzfsIM5TR2OtoW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:24', '2026-10-11 05:19:24', NULL),
(488, 'IZZA ZAKIYATUL MAHFUDHOH FAJARI', '20579998_95275536@siswa.prestasiku.id', '20579998_95275536', NULL, 1, NULL, '$2y$12$JF/SjRHZxKWRvY7gCu9M3.m82arxJVeSytQFnLMWWOQXfO86vt/Z6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:25', '2026-10-11 05:19:25', NULL),
(489, 'KIRAN FARDA ATHIYA', '20579998_83746733@siswa.prestasiku.id', '20579998_83746733', NULL, 1, NULL, '$2y$12$8UXfq72FU6O2RSquKbWsh.nlQhY3j19hFp49JhSZjyWiY4GAC95r6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:25', '2026-10-11 05:19:25', NULL),
(490, 'LATIFATUL MAZEDA ILMAIDAH', '20579998_3088647504@siswa.prestasiku.id', '20579998_3088647504', NULL, 1, NULL, '$2y$12$g/PhhoAen.WB7C5fdz/xPuFwNqXeESXsa8ipVvSRopVRk8nBxPMne', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:26', '2026-10-11 05:19:26', NULL),
(491, 'LIWAUL JANNAH', '20579998_84095714@siswa.prestasiku.id', '20579998_84095714', NULL, 1, NULL, '$2y$12$HWRuqXv.gDhcJJ37GftctOhfjFK.rszo1EhBV46nA/d2N0To9OBYS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:26', '2026-10-11 05:19:26', NULL),
(492, 'MAORA WIDIA PRATIWI', '20579998_87680515@siswa.prestasiku.id', '20579998_87680515', NULL, 1, NULL, '$2y$12$/RD4VfaSBsrWiF5V5byRLekYFMrQwsK0I9/5ZBSKkNJujPEKnBkky', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:27', '2026-10-11 05:19:27', NULL),
(493, 'MAYYADA FIRDA THURAYYA', '20579998_74295462@siswa.prestasiku.id', '20579998_74295462', NULL, 1, NULL, '$2y$12$eP0ieIBuNd0TVqoSWcDODOM642hAB5faVp4PP0J2wJQyBCLC.H8WG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:27', '2026-10-11 05:19:27', NULL),
(494, 'ZALFA SURYANILLAH KUSUMAWARDANI', '20579998_94403250@siswa.prestasiku.id', '20579998_94403250', NULL, 1, NULL, '$2y$12$Qysv7zd015JCVjJUBNcZ1eCZei1NVIW.VqOzmdHApXEhQ8ovWTwRq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:27', '2026-10-11 05:19:27', NULL),
(495, 'AISYAH WISHMI VINORIKA', '20579998_3080722862@siswa.prestasiku.id', '20579998_3080722862', NULL, 1, NULL, '$2y$12$s1Ws3MxP5MAYjQAyGcTV7eCvtFSR9PongJ8Lw3l056ch2x.9jVQLm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:28', '2026-10-11 05:19:28', NULL),
(496, 'KAYLA SYIFA RAYYA IZZAHRA', '20579998_3090530062@siswa.prestasiku.id', '20579998_3090530062', NULL, 1, NULL, '$2y$12$8CsmZHeUDP9n.mMyOVs6U.VBm84XY8YRBAeMWsU1KcYCn5KdsjD1.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:28', '2026-10-11 05:19:28', NULL),
(497, 'MUKHBITA EL RAFEYFA', '20579998_92028208@siswa.prestasiku.id', '20579998_92028208', NULL, 1, NULL, '$2y$12$zBepAK6BHIFBfdtzTM/iP.w6Jks7vZegxwT8TjI6r2zqfTmMIuffa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:28', '2026-10-11 05:19:28', NULL),
(498, 'NABILAH EKA FATIHATUSHOFIYYAH', '20579998_85546052@siswa.prestasiku.id', '20579998_85546052', NULL, 1, NULL, '$2y$12$Cuz26fEdWXfPOzekvjleXuQMeOpvqBhOii.Vc0ezV8kvg6Rm4rsXi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:29', '2026-10-11 05:19:29', NULL),
(499, 'NABILAH PUTRI AZZAHRA', '20579998_3080660620@siswa.prestasiku.id', '20579998_3080660620', NULL, 1, NULL, '$2y$12$JLD4rTMF4xnNYy0C9scO1.B8rvAKw1/MY5mAhhi5/F0B0MMbJamNC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:29', '2026-10-11 05:19:29', NULL),
(500, 'NABILLA AZZAHRA', '20579998_85175324@siswa.prestasiku.id', '20579998_85175324', NULL, 1, NULL, '$2y$12$8LcTKClGCjWMfovqEv42YO1X1Wa1mWcWcsl.3FMZo1jDzr/gCqsvq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:29', '2026-10-11 05:19:29', NULL),
(501, 'NADIA CELSINTA', '20579998_3099369420@siswa.prestasiku.id', '20579998_3099369420', NULL, 1, NULL, '$2y$12$fBPQbXKoT69kql.C8tq19uQYs3OP8ZrO23dGMcPBYhVxdyHvOn6im', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:30', '2026-10-11 05:19:30', NULL),
(502, 'NAILAH AURORA', '20579998_3085329138@siswa.prestasiku.id', '20579998_3085329138', NULL, 1, NULL, '$2y$12$YwL9HVr6hBOTcwRX3p9J5.F78f3PoLo.FVqyO5H4RF1RaCuMfIUTW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:30', '2026-10-11 05:19:30', NULL),
(503, 'NUHA SAFA AULIA', '20579998_94321196@siswa.prestasiku.id', '20579998_94321196', NULL, 1, NULL, '$2y$12$oLJF1OVvXH5pAeDkFFWReOuvbqFdzn7ArX8V2Tg6ov4b6CYPZdIyq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:30', '2026-10-11 05:19:30', NULL),
(504, 'PUTRI SABRINA SALSABILLAH', '20579998_82784864@siswa.prestasiku.id', '20579998_82784864', NULL, 1, NULL, '$2y$12$rSGmpck7Jp1xbUtIh43ew.X.QDa4MUA6SbykHP1pSPA6dCPVPwize', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:31', '2026-10-11 05:19:31', NULL),
(505, 'QORINA FATHMA ZAHARANI', '20579998_92757701@siswa.prestasiku.id', '20579998_92757701', NULL, 1, NULL, '$2y$12$TXmqd2/ludEayzx.XKS0.eQ4eLSSREfjYspRF72TAHxcgt2Xc8mcu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:31', '2026-10-11 05:19:31', NULL),
(506, 'RAHMATUL ANFANA ZULIANA DEWI', '20579998_3080381856@siswa.prestasiku.id', '20579998_3080381856', NULL, 1, NULL, '$2y$12$SNnzxP0wftKbsbaPced2xu9v5gc2vHh/TiE2spIWIb7RUZKJZ95ZG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:31', '2026-10-11 05:19:31', NULL),
(507, 'REVALINA FUJI SULAKSMI', '20579998_78135431@siswa.prestasiku.id', '20579998_78135431', NULL, 1, NULL, '$2y$12$Tul4CnL/yc/CEsFlqlpEeOG/2gHK6V5UdDaSnuOF2LntYOXszOVMa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:32', '2026-10-11 05:19:32', NULL),
(508, 'RIZKA AQMALIA MUTHI\'', '20579998_3086456347@siswa.prestasiku.id', '20579998_3086456347', NULL, 1, NULL, '$2y$12$YZlC9KBEe3evCCVfVvXdIu2GkCvM.UURO3r5Vrt20ThZ/ESpUjGhW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:32', '2026-10-11 05:19:32', NULL),
(509, 'ROFIQOTUN NUR FAIZAH', '20579998_86257908@siswa.prestasiku.id', '20579998_86257908', NULL, 1, NULL, '$2y$12$AnGqKWLhUzS4b1ijmTJUSOPmzcLYCzaJulGyYE3yHRx4Xu2VEMjbO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:32', '2026-10-11 05:19:32', NULL),
(510, 'SALSABILA SINTANOLA', '20579998_86379579@siswa.prestasiku.id', '20579998_86379579', NULL, 1, NULL, '$2y$12$RL6zuJb4pX3AhfkbUkU7jOzmA02uf0dQlt8gHiTpY52D9KkFKpD0O', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:33', '2026-10-11 05:19:33', NULL),
(511, 'SASA DWI KAMILA', '20579998_89853432@siswa.prestasiku.id', '20579998_89853432', NULL, 1, NULL, '$2y$12$YssJpijJjzBROOxWorrBGOSfrOiaXH17bP5tEFiv1OruSqV.7Zwi2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:33', '2026-10-11 05:19:33', NULL),
(512, 'SAYYIDAH BILQIS NURUL JANNAH', '20579998_87354862@siswa.prestasiku.id', '20579998_87354862', NULL, 1, NULL, '$2y$12$OG1YD.7jTIQAt6DcdZIMGu2/JJrg5m/YT0sgHNeo/aCzge9pE2K1S', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:33', '2026-10-11 05:19:33', NULL),
(513, 'SHOFI AMALIA ZAHRA', '20579998_3098738977@siswa.prestasiku.id', '20579998_3098738977', NULL, 1, NULL, '$2y$12$XMPQ7RLW9eVr0GDW/UWgCuip0hVAs31s3Ay4rsOTzMK3qiwD82BG2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:34', '2026-10-11 05:19:34', NULL),
(514, 'TALITA NAILAH SHOFWATILLAH', '20579998_91926144@siswa.prestasiku.id', '20579998_91926144', NULL, 1, NULL, '$2y$12$WSF9JRRIKq4aGdbzvfn5E.Ftfp5WwSiabw12Akk6nB.QB81p.HFvy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:34', '2026-10-11 05:19:34', NULL),
(515, 'UMMU MAYSYUROH AZZAHRA ZAMZAMIA', '20579998_84552049@siswa.prestasiku.id', '20579998_84552049', NULL, 1, NULL, '$2y$12$.Z49PLrCgyQjNDvgU.jaTujDrI9oBHOUgFsVGq/CvydiEowk.F.V6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:34', '2026-10-11 05:19:34', NULL),
(516, 'VRISCA MARSHA ANGELLYA', '20579998_85944941@siswa.prestasiku.id', '20579998_85944941', NULL, 1, NULL, '$2y$12$AQkn7IKak2qOjOrxke8NN.9/h19GvSpdo3cJ6HUgoj99cOMgPFJG6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:35', '2026-10-11 05:19:35', NULL),
(517, 'WAFIYYATUL KARIMAH', '20579998_109037620@siswa.prestasiku.id', '20579998_109037620', NULL, 1, NULL, '$2y$12$x.nD1vOErA8N/2yoQPQjP.6i6ZGdbk0bReZ5r3p5jHLSW5SBNfxTm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:35', '2026-10-11 05:19:35', NULL),
(518, 'ZAKKIYATUL UMAMI', '20579998_86323627@siswa.prestasiku.id', '20579998_86323627', NULL, 1, NULL, '$2y$12$3kpTwUJHpNoULNIAOKqOB.weYP.7/rqD12dxSKeEhD6hsVdg.M2QO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:35', '2026-10-11 05:19:35', NULL),
(519, 'LUTFIANA LATIFAH', '20579998_86171277@siswa.prestasiku.id', '20579998_86171277', NULL, 1, NULL, '$2y$12$aEoZThIb2lWtHM98kS5LXe4.k10ZNluwuCjyb/FgsrnHyp.CWF9TS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:36', '2026-10-11 05:19:36', NULL),
(520, 'AURA IZZA NAELAL MUNA', '20579998_3095413449@siswa.prestasiku.id', '20579998_3095413449', NULL, 1, NULL, '$2y$12$vRtuTM0CNskzoSTNI4JgEuU9Pn4zyPHrswD52KJ2RwXVpeLvXu69y', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:36', '2026-10-11 05:19:36', NULL),
(521, 'ACHMAD ARAFA SHIDQI', '20579998_84018613@siswa.prestasiku.id', '20579998_84018613', NULL, 1, NULL, '$2y$12$lOWOB8Rk8SfI1gBkpc8oP./ACy0eXU2RqdLm0qmNcsjGWC3Pw5cWO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:37', '2026-10-11 05:19:37', NULL),
(522, 'AFIF SOLAHUDDIN ROHMATULLAH', '20579998_99190035@siswa.prestasiku.id', '20579998_99190035', NULL, 1, NULL, '$2y$12$qN05njObMWIrs6O2/kzxyerjPWwhCJRskd0C9PtsJIdFK534i9Gbi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:37', '2026-10-11 05:19:37', NULL),
(523, 'AFRI YOGA PRATAMA', '20579998_95583296@siswa.prestasiku.id', '20579998_95583296', NULL, 1, NULL, '$2y$12$/ZKgpC2HTOMS3HLaBac8se/CkaMW5PU/x9AYbnDosyi4eBgvnFdqe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:37', '2026-10-11 05:19:37', NULL),
(524, 'AHMAD LABIB RAMDHAN AL GHIFFARY', '20579998_61708052@siswa.prestasiku.id', '20579998_61708052', NULL, 1, NULL, '$2y$12$VQjzhfZwE.I5smoNrk1t9OOaFQS0Mj/593dredYPva9s0TAkexwnC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:38', '2026-10-11 05:19:38', NULL),
(525, 'AHMAD NUR FIKRI UBAIDILLAH', '20579998_3085041374@siswa.prestasiku.id', '20579998_3085041374', NULL, 1, NULL, '$2y$12$u9WFybeevySLUrGI9ZCNNOePISWsVTd9f7fCMiChUp3DRjhkMLv16', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:38', '2026-10-11 05:19:38', NULL),
(526, 'AHMAD TRI MUSTAKIM', '20579998_89540599@siswa.prestasiku.id', '20579998_89540599', NULL, 1, NULL, '$2y$12$Vzz0w.5esWF1yCoXS/jfReXzT3Io9OMIBeDlL0jGIC16O/sI7WFrm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:39', '2026-10-11 05:19:39', NULL),
(527, 'ALFIAN JUFRI ABDILLAH', '20579998_3070142205@siswa.prestasiku.id', '20579998_3070142205', NULL, 1, NULL, '$2y$12$JC0vju8HgUWaXBzDBomPreicQSFV9VFJIE2U3rsI8LSwEjRKMrZcO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:39', '2026-10-11 05:19:39', NULL),
(528, 'BAYU KRISNA WARDANA', '20579998_81779516@siswa.prestasiku.id', '20579998_81779516', NULL, 1, NULL, '$2y$12$rXJOJO78IAaQxC0JbyYBZeQPHYFkMd3ZprJ4IJK.NwnnS.FaRenHy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:39', '2026-10-11 05:19:39', NULL),
(529, 'DAFFA RIZQI ATHAYA SETIAWAN', '20579998_93648907@siswa.prestasiku.id', '20579998_93648907', NULL, 1, NULL, '$2y$12$kfIum.K9lxroFT1fB3hzq.Sqisez3aYExIhyKn3XDxzUKlqovZZny', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:40', '2026-10-11 05:19:40', NULL),
(530, 'DIMAS AGENG NUR ISLAKHUDIN', '20579998_3082448599@siswa.prestasiku.id', '20579998_3082448599', NULL, 1, NULL, '$2y$12$4b0RreFxKTFG8/hIY8yPRelGBz/ymKe/WTwnnhlAWTPkGu.ppYcQu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:40', '2026-10-11 05:19:40', NULL),
(531, 'EZZAR GAISYAN NURAQIL', '20579998_3095537753@siswa.prestasiku.id', '20579998_3095537753', NULL, 1, NULL, '$2y$12$S2f28Y.zUpbNoWpSwhb5O.0Hfsq2RLTZcDmDAAxUsBmquiMwtw3HC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:40', '2026-10-11 05:19:40', NULL),
(532, 'FACHRI DZAKI RAMADHAN', '20579998_60093511@siswa.prestasiku.id', '20579998_60093511', NULL, 1, NULL, '$2y$12$R/dtrXDuvwFUDHCp4kP85OOt90Cv7kFSGG.DDDo3KoVxzZmamisQ6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:41', '2026-10-11 05:19:41', NULL),
(533, 'GUSTI BINTANG PUTRA UNON PURWANTO', '20579998_3080734003@siswa.prestasiku.id', '20579998_3080734003', NULL, 1, NULL, '$2y$12$OJDCKzmeu2X98vfI5cUO9OH1A1LXqyGja.DXrrooMSsU2ceKzN51m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:41', '2026-10-11 05:19:41', NULL),
(534, 'HAFIDZ MAULANA', '20579998_3087903366@siswa.prestasiku.id', '20579998_3087903366', NULL, 1, NULL, '$2y$12$PJu1Uf4hD693kJQrVg0ZGOrXVDMJ.ZbzdzKc8Ke9jKnIErtymUSey', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:41', '2026-10-11 05:19:41', NULL),
(535, 'HIJIR SURYA SUCIPTO', '20579998_93913923@siswa.prestasiku.id', '20579998_93913923', NULL, 1, NULL, '$2y$12$i0Qvj5oayWzlQPC.TTiq3eNUeaH.JEfO9pgTqMMe/jXGuzbFXLCwS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:42', '2026-10-11 05:19:42', NULL),
(536, 'MARS MIKA\'IL', '20579998_98156542@siswa.prestasiku.id', '20579998_98156542', NULL, 1, NULL, '$2y$12$zvw9iEXFK3XzcttcsytB3.CkTjnb5oRJyXDVv/SuDKFCGln/PGl6K', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:42', '2026-10-11 05:19:42', NULL),
(537, 'MOCHAMMAD NOER ALFIAN AZKYA', '20579998_91839028@siswa.prestasiku.id', '20579998_91839028', NULL, 1, NULL, '$2y$12$Hnd1agOghjc1cwwruq6HZOO2hT1k1XfZ3K0BSkfJ7cILkQS2CyoUa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:42', '2026-10-11 05:19:42', NULL),
(538, 'MOCHAMMAD AKMAL FIRDAUS AL- MUKARRAMY', '20579998_83034281@siswa.prestasiku.id', '20579998_83034281', NULL, 1, NULL, '$2y$12$MG73uBB2rE/G7dd/sYs/1OVE4SltzizKqSlM/KYQQ5dV5d8//wtzu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:43', '2026-10-11 05:19:43', NULL),
(539, 'MOH. HASBY ABDILLAH', '20579998_3086070138@siswa.prestasiku.id', '20579998_3086070138', NULL, 1, NULL, '$2y$12$5JnUR.T3.G/nmsSWX1FzqOwrjU965IyFxhgk2xReCEAi3tl7sMFSy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:43', '2026-10-11 05:19:43', NULL),
(540, 'MOHAMMAD PANJI AKMALUZZUHAIR', '20579998_3087135780@siswa.prestasiku.id', '20579998_3087135780', NULL, 1, NULL, '$2y$12$w7y3gwntovqZc9maVHo9DeIEZ2jXHvhw4jleZzYK3TPoOzbjtyXnO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:43', '2026-10-11 05:19:43', NULL),
(541, 'MOHAMMAD SYAHID MASHUDI', '20579998_3085904471@siswa.prestasiku.id', '20579998_3085904471', NULL, 1, NULL, '$2y$12$HFRuJgTHVLnCEdLfqv3gZeOTPe/hqLF0IUdB1UIol13pO7rDUuHQO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:44', '2026-10-11 05:19:44', NULL),
(542, 'MUHAMAD NIAM MUSAFFA', '20579998_3095047702@siswa.prestasiku.id', '20579998_3095047702', NULL, 1, NULL, '$2y$12$c6wG/24G7Ug6fEyS6Rnsze040St4Nie.Q5NpXXWfwLkWLzdWYOkSu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:44', '2026-10-11 05:19:44', NULL),
(543, 'MUHAMMAD AD\'LIL AL GHOZALI', '20579998_3091589127@siswa.prestasiku.id', '20579998_3091589127', NULL, 1, NULL, '$2y$12$Wn6XAEF/xpLP.m9uYHwKZuymAXfrarLQR4LNzY5g1yvxvxdYznibW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:44', '2026-10-11 05:19:44', NULL),
(544, 'MUHAMMAD ARIF PANJALU', '20579998_3087191997@siswa.prestasiku.id', '20579998_3087191997', NULL, 1, NULL, '$2y$12$3NlXqL6.zaO31wp9d/hC1OWujNG.rLw7c7xTe4.eAaw/3vHIuUqu6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:45', '2026-10-11 05:19:45', NULL),
(545, 'MUHAMMAD ARSA OZORA', '20579998_3080097010@siswa.prestasiku.id', '20579998_3080097010', NULL, 1, NULL, '$2y$12$fLv.5HgX.YvfpJ0.7WVC2eZEI/dza0/twmA8cri.L20I0K277JEQm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:45', '2026-10-11 05:19:45', NULL),
(546, 'MUHAMMAD IQBAL MUSYAFFA\'', '20579998_97110798@siswa.prestasiku.id', '20579998_97110798', NULL, 1, NULL, '$2y$12$J1mJSpOKtx0Qx2b8ya9Ukuji6xvk9UPES0fFuDKLvUCzzawzzdQei', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:46', '2026-10-11 05:19:46', NULL),
(547, 'MUHAMMAD NABIL ASYHAR', '20579998_3099176457@siswa.prestasiku.id', '20579998_3099176457', NULL, 1, NULL, '$2y$12$8sFxmXntdu9mxfCTdP/ake0hSu1zk1RMZDeDNKaFjoxlV2n.06Gjq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:46', '2026-10-11 05:19:46', NULL),
(548, 'MUHAMMAD SANJU ARISKA', '20579998_99611750@siswa.prestasiku.id', '20579998_99611750', NULL, 1, NULL, '$2y$12$zXAtklLAZyMExcNYfMaS6ewnTAGhvQED9K.SUkaropfNEXOpn6Ghe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:46', '2026-10-11 05:19:46', NULL),
(549, 'RAIHAN ADITYA MAULANA ISWAHYUDI', '20579998_86671162@siswa.prestasiku.id', '20579998_86671162', NULL, 1, NULL, '$2y$12$A2DCvIGwha1OQelGvqZ52eqppGMz4JVw/dCiYZJixQZWURV.bq72m', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:47', '2026-10-11 05:19:47', NULL),
(550, 'REVAN RADITYAH PASHA', '20579998_85850754@siswa.prestasiku.id', '20579998_85850754', NULL, 1, NULL, '$2y$12$23deClIqNlH9loqXpZ0Y/uAYoNI681X5J61XZ6qA.PwGmJU.atgoa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:47', '2026-10-11 05:19:47', NULL),
(551, 'REYHAN AR RAYAN FEBRIANTITO', '20579998_3092691163@siswa.prestasiku.id', '20579998_3092691163', NULL, 1, NULL, '$2y$12$9sg9A5KqzjKHvbFWe9LRZ.jpgB8nLT0mqGYnnoQCn3l/4jUrDB.vu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:47', '2026-10-11 05:19:47', NULL),
(552, 'SAIF RAFA ALZINDANY', '20579998_3081782031@siswa.prestasiku.id', '20579998_3081782031', NULL, 1, NULL, '$2y$12$w3cfZaZ.BxSrfWxzOtl0seWJlpyjgbX9nutBA/EPR2T047gfeOE2.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:48', '2026-10-11 05:19:48', NULL),
(553, 'WILDAN ALBANNA', '20579998_3085725995@siswa.prestasiku.id', '20579998_3085725995', NULL, 1, NULL, '$2y$12$TFKHBxaQyaEfB.ToZVAim.v2Vk4AU1r9E825w0ztohIqc4iyQcCq6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:48', '2026-10-11 05:19:48', NULL),
(554, 'WILIAM HAMID', '20579998_84402943@siswa.prestasiku.id', '20579998_84402943', NULL, 1, NULL, '$2y$12$2V4VCoICpj1KLJW55wuUI.nUy33JLy/sBCkp.H0kdryxEnyZcny/.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:48', '2026-10-11 05:19:48', NULL),
(555, 'ELDO RADITYA ASADULLAH', '20579998_3086898748@siswa.prestasiku.id', '20579998_3086898748', NULL, 1, NULL, '$2y$12$6G/dy91iVRMjtPAjHbYaUuknyc6ZHjDrk5QgFW4LHlPiu9dTeHvMS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:49', '2026-10-11 05:19:49', NULL),
(556, 'M. ALI SHOBIRIN', '20579998_3081597796@siswa.prestasiku.id', '20579998_3081597796', NULL, 1, NULL, '$2y$12$11y3/F8WVj/MGnQs6671Ke1IQA1g4ktemndm8fPHiPShdUuFYfL.O', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:49', '2026-10-11 05:19:49', NULL),
(557, 'M. PRAMUDITA MUSAIYAR RABBANI', '20579998_91440119@siswa.prestasiku.id', '20579998_91440119', NULL, 1, NULL, '$2y$12$gFY4lsK9QCX1gaJPvf6Ceel5NbTikhVz3gJZZ4.UVRH56SRfm8Chu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:49', '2026-10-11 05:19:49', NULL),
(558, 'RIZQI DWI RAMADHAN', '20579998_96650343@siswa.prestasiku.id', '20579998_96650343', NULL, 1, NULL, '$2y$12$aPk/6OpVlNzUKXeRURod.uZd3XfOOFndA.CUzYYKjfcQB9pta9Puy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:50', '2026-10-11 05:19:50', NULL),
(559, 'MUHAMMAD KUNTADEWA EL \'AZIZY', '20579998_77313541@siswa.prestasiku.id', '20579998_77313541', NULL, 1, NULL, '$2y$12$DOJdciW1rByDyWz/QxjaVeNvt37DNS4jt7FfkSWrRPf6cZcNEQUB6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:50', '2026-10-11 05:19:50', NULL),
(560, 'AINUN ZAZKIA AVRIL KIMBERLIN', '20579998_98091961@siswa.prestasiku.id', '20579998_98091961', NULL, 1, NULL, '$2y$12$kcl1jmU7CTk2bMozNqdwIe5BVOFe/rVfp6SZ82hcsd0sBpFWG.Hl.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:50', '2026-10-11 05:19:50', NULL),
(561, 'ALISTA NAZWA PUTRI', '20579998_97832953@siswa.prestasiku.id', '20579998_97832953', NULL, 1, NULL, '$2y$12$e8L86BmWMnDtiw1F3R0k.eo.ZIcQ8Xi8LHUr7o0ZSnEK134d27MOi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:51', '2026-10-11 05:19:51', NULL),
(562, 'ABIDAH AZMI AYU IMTIYAAZ', '20579998_3092324620@siswa.prestasiku.id', '20579998_3092324620', NULL, 1, NULL, '$2y$12$cAH1kPncSC2CYJv1SlPrveGCB.FFV1bZDuvu1Lz2RIpNSl2GLjQoi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:51', '2026-10-11 05:19:51', NULL),
(563, 'ALFINAA ABIDATUL AZMIYYAH', '20579998_95443268@siswa.prestasiku.id', '20579998_95443268', NULL, 1, NULL, '$2y$12$QrcK.xgpxcK8fW98t974IOP0QxYlZPVLVCypY08bxdueU0TjOMTHi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:51', '2026-10-11 05:19:51', NULL),
(564, 'ALMYRA VAEZA DEVIANTI', '20579998_94142637@siswa.prestasiku.id', '20579998_94142637', NULL, 1, NULL, '$2y$12$FtiSsrat6Q0vU2RmeqvInefKHwQovoQNFkFeoqvC0sD3yBj9Sv/cu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:52', '2026-10-11 05:19:52', NULL),
(565, 'ARNES SHINTA AZZAHRAH', '20579998_95751723@siswa.prestasiku.id', '20579998_95751723', NULL, 1, NULL, '$2y$12$k.SE11N8ZC.5rma8BphjSekXOCyEZPtkMvWFo68HJ40l5wNR0shN6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:52', '2026-10-11 05:19:52', NULL),
(566, 'AUFA AZKA RIZQIA', '20579998_74874566@siswa.prestasiku.id', '20579998_74874566', NULL, 1, NULL, '$2y$12$XwS2zInAlzYngT8CuSMhL.Jkcehcp34jR/McrLA/1Hst3ESNk.0fq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:52', '2026-10-11 05:19:52', NULL),
(567, 'AULLIA AZ ZAHRA PUTRI', '20579998_88990463@siswa.prestasiku.id', '20579998_88990463', NULL, 1, NULL, '$2y$12$4Yuo.indYgkbtAGkucxNSutpbbk6CxRcBdGqdnWFdRbmtpWgqNHo2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:53', '2026-10-11 05:19:53', NULL),
(568, 'AURA RIZKYTA MAULIDYA KIRANA', '20579998_3096087437@siswa.prestasiku.id', '20579998_3096087437', NULL, 1, NULL, '$2y$12$51qGL66uzdD0oJEBnG4O2OJBlqlwRMKRO09kHXOS.FQpiJTXFW3iO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:53', '2026-10-11 05:19:53', NULL);
INSERT INTO `users` (`id`, `name`, `email`, `username`, `phone`, `school_id`, `email_verified_at`, `password`, `must_change_password`, `password_changed_at`, `last_login_at`, `last_login_ip`, `status`, `remember_token`, `created_at`, `updated_at`, `deleted_at`) VALUES
(569, 'AZ ZAHRA NADIA SYIFA RAHMA', '20579998_3082688813@siswa.prestasiku.id', '20579998_3082688813', NULL, 1, NULL, '$2y$12$aH1lluMPI3RQqBGG4MW2tugpuEaYfYM4EnHRPJxQ.66xKNxim.agG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:54', '2026-10-11 05:19:54', NULL),
(570, 'AZUN NAHAYATUN NAFIS', '20579998_3099665477@siswa.prestasiku.id', '20579998_3099665477', NULL, 1, NULL, '$2y$12$UOZzBgRLNannFIwoN8/u7.2.yvtjHUjJ5zwahn1sp1MgOVew.4TdW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:54', '2026-10-11 05:19:54', NULL),
(571, 'BALQIS LUBNA HUMAIRO', '20579998_3099065677@siswa.prestasiku.id', '20579998_3099065677', NULL, 1, NULL, '$2y$12$2rJilwpkn2Sp6w/CKsYvp.xJd7EnEE7K6EcUYYxgrWwVKIxTEiyau', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:54', '2026-10-11 05:19:54', NULL),
(572, 'CHUMAIROH FITRIA GALIS', '20579998_89565141@siswa.prestasiku.id', '20579998_89565141', NULL, 1, NULL, '$2y$12$hco/gbt9QP3An0O6WPEXZ.WjScHLxCybssCi4xaVqPVYab4xcsDYy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:55', '2026-10-11 05:19:55', NULL),
(573, 'DAIVA AMIRA EILIYA', '20579998_95390608@siswa.prestasiku.id', '20579998_95390608', NULL, 1, NULL, '$2y$12$/BaLsl/i0CqEVM5hX4.i7.1k7NhM8oIadA37.oeL8MoS59LRP.C4a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:55', '2026-10-11 05:19:55', NULL),
(574, 'DEVITA KUSMIA DWIYANTI', '20579998_83492993@siswa.prestasiku.id', '20579998_83492993', NULL, 1, NULL, '$2y$12$fpXmZJgE0zfJ0HcUQXt88exABEl6uV.dqQp3JbQE..L/8cBzrEZRe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:55', '2026-10-11 05:19:55', NULL),
(575, 'DYAJENG AMANDA', '20579998_82415090@siswa.prestasiku.id', '20579998_82415090', NULL, 1, NULL, '$2y$12$lURXwQFMHtPAygNRNq.yMeCQcsIuRyvztV9pECO/ipdDRSlBF3DE2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:56', '2026-10-11 05:19:56', NULL),
(576, 'FAZA SAKHIYATUN NAJWA', '20579998_3099558421@siswa.prestasiku.id', '20579998_3099558421', NULL, 1, NULL, '$2y$12$mzYT9aEmuCiTzlS3eQ7yEecM6pyzaz.IvQrI1kEEigBPX0XgGCMxK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:56', '2026-10-11 05:19:56', NULL),
(577, 'FELISA HAURA NISRINA', '20579998_3097898135@siswa.prestasiku.id', '20579998_3097898135', NULL, 1, NULL, '$2y$12$DtIn0u13V./Wpgb6dMR46OE/b5xJnxZxogyA.oMvPoxymrOmBW21i', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:56', '2026-10-11 05:19:56', NULL),
(578, 'FELLAH SYABANIA', '20579998_82314206@siswa.prestasiku.id', '20579998_82314206', NULL, 1, NULL, '$2y$12$Qjs4U2YUl4K2LuOVm47BdOm1vvk2NUUqWuRKLVI2TuxF18V2jvMcC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:57', '2026-10-11 05:19:57', NULL),
(579, 'FINA RAHMATUL AWWALIYAH', '20579998_95691266@siswa.prestasiku.id', '20579998_95691266', NULL, 1, NULL, '$2y$12$kcQ8yWYww6.uSwwf9HJvyefzDoZm.QZLYUY2CQ.Kipks4gJkdr0JO', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:57', '2026-10-11 05:19:57', NULL),
(580, 'GHURROTUL HANA', '20579998_3099071290@siswa.prestasiku.id', '20579998_3099071290', NULL, 1, NULL, '$2y$12$SqBM9wUtKtkDJL26Xhexz.7/E6yAueOAS/bVdiGcy3wTpW9IedvmK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:57', '2026-10-11 05:19:57', NULL),
(581, 'IMELDA ZUHRO', '20579998_94334499@siswa.prestasiku.id', '20579998_94334499', NULL, 1, NULL, '$2y$12$5DTpEpAmK8cZY3fiCFas6uABinc1Hmcb8BdR39IrlE7A03wAdefJq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:58', '2026-10-11 05:19:58', NULL),
(582, 'IZZA INAYATUL MAGHFIROH', '20579998_98202495@siswa.prestasiku.id', '20579998_98202495', NULL, 1, NULL, '$2y$12$SAk5r2K6E4kJHjfMvaWYouFJzQimAaEyZEmUn/klAXS1FlyhgHU/6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:58', '2026-10-11 05:19:58', NULL),
(583, 'KAYLA HAMANI MURTAZA', '20579998_3097676773@siswa.prestasiku.id', '20579998_3097676773', NULL, 1, NULL, '$2y$12$o1aBrCkSf7cHWTYNGUoB7.QTz.iA/4ghHUPjdnWutwkuqnfG7CqXG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:58', '2026-10-11 05:19:58', NULL),
(584, 'KHANSA ZAHIRAH NAJLA AS-SHAINA', '20579998_86885994@siswa.prestasiku.id', '20579998_86885994', NULL, 1, NULL, '$2y$12$wAcBs4eTW0KshQq0v7Qtg.sMxTHLvhj.iuVwc89ZP2JJnr9Z9RkrC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:59', '2026-10-11 05:19:59', NULL),
(585, 'MALIKATU ZAHRA RAMADANI', '20579998_89175951@siswa.prestasiku.id', '20579998_89175951', NULL, 1, NULL, '$2y$12$GQiEu8q44MjKl1wf9HsaWuGE3PNWhKFE3njpeDDhjUnptMkV9A/9W', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:59', '2026-10-11 05:19:59', NULL),
(586, 'MAUDY MAULIDA', '20579998_96295204@siswa.prestasiku.id', '20579998_96295204', NULL, 1, NULL, '$2y$12$U2WYbTNcx2dZapMbyWkNn.2zjGmw1SBJR9eBHI52rO/EQcGlbnvR2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:19:59', '2026-10-11 05:19:59', NULL),
(587, 'NABILA AULIA ARIFIANTI', '20579998_96223385@siswa.prestasiku.id', '20579998_96223385', NULL, 1, NULL, '$2y$12$1eszQbG2Kl76L55zJtAwHeP8oYoylPHuoR2ksC4q2ePbdlTGhNTFy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:00', '2026-10-11 05:20:00', NULL),
(588, 'NA\'IMATUZ ZAHRA', '20579998_3081011746@siswa.prestasiku.id', '20579998_3081011746', NULL, 1, NULL, '$2y$12$rQGlopq2RhyjGDT44qjrMuZV8YgMLE8ynArY3YdN97ikcYOvV7/gq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:00', '2026-10-11 05:20:00', NULL),
(589, 'QOTRUNNADA', '20579998_3090619695@siswa.prestasiku.id', '20579998_3090619695', NULL, 1, NULL, '$2y$12$FGX36SsqUjXBvdPC13v2E.sMfk9PZwx.NF2qTsMl8hHhZav5Mv0ym', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:00', '2026-10-11 05:20:00', NULL),
(590, 'SAFIRA PUTRI ARIFIANA', '20579998_3082932835@siswa.prestasiku.id', '20579998_3082932835', NULL, 1, NULL, '$2y$12$kdUDPFTx.X/HAWqyIGLXgeRrqGz9ObS2TUwRnqbpoBmRf.nEmBC3O', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:01', '2026-10-11 05:20:01', NULL),
(591, 'SAVINATUN NAJAH FEBRIANI', '20579998_3097730333@siswa.prestasiku.id', '20579998_3097730333', NULL, 1, NULL, '$2y$12$6KJHdzlyKqlY.NRIiSTfcOMDr31njCjyKM8/VT4nXIhNQu/TLC1O2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:01', '2026-10-11 05:20:01', NULL),
(592, 'SHEILA SALSABILA', '20579998_3095209361@siswa.prestasiku.id', '20579998_3095209361', NULL, 1, NULL, '$2y$12$1u4W.oncGOki.LTUvaYRYOS83d/Ud3J6IjtZCVfGkJqoCok9wNKBS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:02', '2026-10-11 05:20:02', NULL),
(593, 'SHENA DWI ARISKA', '20579998_87437156@siswa.prestasiku.id', '20579998_87437156', NULL, 1, NULL, '$2y$12$odmL2BYwxzp5SXLBsJhQm.S1Z6ozCdnX/h6oUf5G0SjB2S9Qrp7Dy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:03', '2026-10-11 05:20:03', NULL),
(594, 'SHOFI MUFIIDAH', '20579998_99870680@siswa.prestasiku.id', '20579998_99870680', NULL, 1, NULL, '$2y$12$3TPv/9fH5M36U0bS2ETmo.xk24EJwV6Wlb5z.m4AQvr18JnhIEHXi', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:03', '2026-10-11 05:20:03', NULL),
(595, 'SITI KHOLIFAH NURLAYLI', '20579998_92643066@siswa.prestasiku.id', '20579998_92643066', NULL, 1, NULL, '$2y$12$3QTc1VIAc1ZVmYVfTARXNec8x8D/d9XQ65l87tVPhgZMl244TsWVq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:04', '2026-10-11 05:20:04', NULL),
(596, 'VINA DAIMATURROHMAH', '20579998_3083231072@siswa.prestasiku.id', '20579998_3083231072', NULL, 1, NULL, '$2y$12$n781Sr7B0/IUNBNOJOM15OlASEGR8vSqwviy46qz3glZNmQqSFUEC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:04', '2026-10-11 05:20:04', NULL),
(597, 'WULAN SYASYA AQILA', '20579998_3084641260@siswa.prestasiku.id', '20579998_3084641260', NULL, 1, NULL, '$2y$12$wQcc4V65Me5fyycQyhAAcu3Eh7rDDSG0NdJAqe3g1DFBodT2rz9Ha', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:05', '2026-10-11 05:20:05', NULL),
(598, 'RADITA NURFATHZAH', '20579998_398328234@siswa.prestasiku.id', '20579998_398328234', NULL, 1, NULL, '$2y$12$pXHO8VOCYVpxKLX8rULCJOUCBTQxTIe1tlmhcZAfaeRL3gO5hAxA2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:05', '2026-10-11 05:20:05', NULL),
(599, 'ZIDNI AGNIA ILMA', '20579998_78969128@siswa.prestasiku.id', '20579998_78969128', NULL, 1, NULL, '$2y$12$X9ExCiA2.3w3.F2B1iVaxOxOKfcGIV5MiE8iBINCRqcMBzPlNlLey', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:05', '2026-10-11 05:20:05', NULL),
(600, 'NAJMA TSANIA AL FAJRIYAH', '20579998_3109127352@siswa.prestasiku.id', '20579998_3109127352', NULL, 1, NULL, '$2y$12$s7xk4T2Se5/6LJcGymliWu8G1rMfax/pz2owT458dYuAYDKpDvgo2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:06', '2026-10-11 05:20:06', NULL),
(601, 'ABDILLAH FARDIN ALVARO', '20579998_3089941768@siswa.prestasiku.id', '20579998_3089941768', NULL, 1, NULL, '$2y$12$b886n2mbFgSTZsTa0ZZo1u1y28VeUhfXMmL6Hb/YBSDnsmtDAeram', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:06', '2026-10-11 05:20:06', NULL),
(602, 'ADNIN MUHAMMAD AR RIFA\'I', '20579998_3098427665@siswa.prestasiku.id', '20579998_3098427665', NULL, 1, NULL, '$2y$12$YVhJx54xzyaRNcRcAG5DH.T8u/Q5SdEy9C/eaSoDoPunpZ8TvQoqu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:07', '2026-10-11 05:20:07', NULL),
(603, 'AHMAD ADAM SULTAN PRATAMA HAQIQI', '20579998_973226332@siswa.prestasiku.id', '20579998_973226332', NULL, 1, NULL, '$2y$12$kWJqLqNyHXV6zXoBnk1pcOLyv8IGbHYXlpMbzm94Xy3XDJtCrgq8C', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:07', '2026-10-11 05:20:07', NULL),
(604, 'AHMAD NIZAR MAULANA', '20579998_93604524@siswa.prestasiku.id', '20579998_93604524', NULL, 1, NULL, '$2y$12$MUKNyAVFessJPqv3ouS7cu0NOhcKSsbabTpF1rFEfF9NTljdaZeTW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:07', '2026-10-11 05:20:07', NULL),
(605, 'AHMED GABRIEL WICAKSONO', '20579998_3083254442@siswa.prestasiku.id', '20579998_3083254442', NULL, 1, NULL, '$2y$12$oNLvSPLgkiVfs41DlyqOxeyrafRQhD7ZosPB2Ajsy/cSzKu/iQZn6', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:08', '2026-10-11 05:20:08', NULL),
(606, 'AHMMAD SOLEH ASRORI', '20579998_94100712@siswa.prestasiku.id', '20579998_94100712', NULL, 1, NULL, '$2y$12$dheqCajxv3NeItJlYN4Ix.F0qvJQVRtCWuiTgxYu/v4xUVPJ5VrjC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:08', '2026-10-11 05:20:08', NULL),
(607, 'BAHAUDIN AKMAL', '20579998_97713040@siswa.prestasiku.id', '20579998_97713040', NULL, 1, NULL, '$2y$12$wk1405WQGdUvG5ngS0QJy.RGzQ2LqKz3N3/UZNtG0qxpd8Wdu5Ypu', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:08', '2026-10-11 05:20:08', NULL),
(608, 'LUVI MUSTAQIM', '20579998_83401619@siswa.prestasiku.id', '20579998_83401619', NULL, 1, NULL, '$2y$12$le3ET2ZSI1QJQwWYCv0hyuc88abid6DHuOrvM2UTfUJ0Ixv4y3Seq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:09', '2026-10-11 05:20:09', NULL),
(609, 'M. ASHABIL YAMIN', '20579998_3086645338@siswa.prestasiku.id', '20579998_3086645338', NULL, 1, NULL, '$2y$12$1pK4iK8PlUDrRryWFzRoz.ibyTkgrShvAZ6xd80ghqx8r.0mJHN1u', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:09', '2026-10-11 05:20:09', NULL),
(610, 'M. FAHRI JAUHAR FUADI', '20579998_3090686371@siswa.prestasiku.id', '20579998_3090686371', NULL, 1, NULL, '$2y$12$n1ThItFD1CleQbuodw/ct.oa0ddezrNwcfMvsTxrOl7R8PyVu0yGW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:10', '2026-10-11 05:20:10', NULL),
(611, 'M. YUSUF AL GHUFRONY', '20579998_3083789192@siswa.prestasiku.id', '20579998_3083789192', NULL, 1, NULL, '$2y$12$exX/2Fe2N1XH.YC24PLPi.qyyhB1Kj/jMj9X5CUOUcS6PlAOFkR46', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:10', '2026-10-11 05:20:10', NULL),
(612, 'MOCH. ALFIAN FAHMI', '20579998_96221614@siswa.prestasiku.id', '20579998_96221614', NULL, 1, NULL, '$2y$12$yqPG0wggqoBTg.cXjEJM6e4YferrWp9u.0TSi5nGMQOa4T.iOM6.q', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:10', '2026-10-11 05:20:10', NULL),
(613, 'MUCHAMMAD RISKI YULIANTO', '20579998_84156764@siswa.prestasiku.id', '20579998_84156764', NULL, 1, NULL, '$2y$12$5NqYuR1D04JVw3tjWRR4E.iO5z2jO7chdqrpjf0gxth1f2bLbS3..', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:11', '2026-10-11 05:20:11', NULL),
(614, 'MUHAMMAD RAFLY ATTHALAH FEBRIANSYAH', '20579998_3086604444@siswa.prestasiku.id', '20579998_3086604444', NULL, 1, NULL, '$2y$12$31twBaaOqjaEkv8EDW5vru6ZW3sd.5dw2Eieu8rK7n6oB3dfqzTeS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:11', '2026-10-11 05:20:11', NULL),
(615, 'MUHAMMAD RIFAD ARFARI', '20579998_93092498@siswa.prestasiku.id', '20579998_93092498', NULL, 1, NULL, '$2y$12$k/Kc9OpaaSS9CxQ8XuGP3O3NkU5JrB87/PkcPjWCYB362nPpWGEsq', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:12', '2026-10-11 05:20:12', NULL),
(616, 'NATHAN ERZA QAFI YUWAN', '20579998_3091725601@siswa.prestasiku.id', '20579998_3091725601', NULL, 1, NULL, '$2y$12$c6TlukbtPWz8hYfApxLg6uUWkL2UEXHT1OmGPskQSCV7jAn7WEkRy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:13', '2026-10-11 05:20:13', NULL),
(617, 'RAIHAN \'ADZIM AL MAULUDI', '20579998_96403216@siswa.prestasiku.id', '20579998_96403216', NULL, 1, NULL, '$2y$12$B29nCqQLlir3FWhSuUAsg.CxoC/d4QgKJGc5TNtUGMH2HqMKBBvjK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:13', '2026-10-11 05:20:13', NULL),
(618, 'TEGAR ADI SAPUTRA', '20579998_85372602@siswa.prestasiku.id', '20579998_85372602', NULL, 1, NULL, '$2y$12$yPKxomfuo5tEVhQ4623UNuJc3TnRcYbMVPQch1DE2SEzz5NncauJ.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:14', '2026-10-11 05:20:14', NULL),
(619, 'WAHYU WIBOWO WISNU SAPUTRO', '20579998_3090822753@siswa.prestasiku.id', '20579998_3090822753', NULL, 1, NULL, '$2y$12$lPV.pDzWuAgSxLLI2E2Aa.wrHsmBGxqHztylyK66MTTveTF/zsdRy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:15', '2026-10-11 05:20:15', NULL),
(620, 'MOCHAMMAD IMRON BAFADHOL', '20579998_84338590@siswa.prestasiku.id', '20579998_84338590', NULL, 1, NULL, '$2y$12$7ixb4.FfzVtCcfbUHTyzLuWPywBVCGJ2EgmWSKFrT0/KxJDJNict2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:15', '2026-10-11 05:20:15', NULL),
(621, 'MUHAMMAD WILDAN ZAIN', '20579998_886798163@siswa.prestasiku.id', '20579998_886798163', NULL, 1, NULL, '$2y$12$3g5jYKKTM7jJctxb/dnISuHKXibpz2E1ERrGy1AGayZ3wjMhDNapy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:16', '2026-10-11 05:20:16', NULL),
(622, 'MUHAMMAD DIMAS MAULANA', '20579998_3089527599@siswa.prestasiku.id', '20579998_3089527599', NULL, 1, NULL, '$2y$12$j8efzTnTLTFc8XnNVYNKCOA5U.LFleY9hcfsBp8RBYf3PlzGpj0EG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:23', '2026-10-11 05:20:23', NULL),
(623, 'ARJU NAILAL MUNA', '20579998_3088245680@siswa.prestasiku.id', '20579998_3088245680', NULL, 1, NULL, '$2y$12$Rkz7Lrq6KU83Gw7b2dQYluPQQIrN/SxLA3F2wvDMxP4thCw8nNh2a', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:24', '2026-10-11 05:20:24', NULL),
(624, 'BAYYIN KAFKA AL BALKAH', '20579998_3099588305@siswa.prestasiku.id', '20579998_3099588305', NULL, 1, NULL, '$2y$12$JV7d6qhfcviRzxP4Tpb9aOcWWaWXrYEL90Ia549H25Qh01J3qOKOa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:27', '2026-10-11 05:20:27', NULL),
(625, 'CERAH WULANDARI', '20579998_3073646976@siswa.prestasiku.id', '20579998_3073646976', NULL, 1, NULL, '$2y$12$b7WA58IFayaR6F7GldVVTucKLlFqyfNy5pzHm4.4QYA/Af6AB5Zwm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:28', '2026-10-11 05:20:28', NULL),
(626, 'ELOK SAYYIDAH HALIMAH', '20579998_3088929541@siswa.prestasiku.id', '20579998_3088929541', NULL, 1, NULL, '$2y$12$YOMSozd6VCCOGJXaozOTPOSmmzlWPr30Cmnh3ZFUin56Dya.JBVb.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:30', '2026-10-11 05:20:30', NULL),
(627, 'FAZA AGHNIA RAMADHANI', '20579998_3085093748@siswa.prestasiku.id', '20579998_3085093748', NULL, 1, NULL, '$2y$12$qTZDTnvUt/pWmjqdvnhdp.SzG10gSamktldnjoAwRpgKZn/1TdiVW', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:34', '2026-10-11 05:20:34', NULL),
(628, 'GHARIYAH AN NUFUS', '20579998_81715914@siswa.prestasiku.id', '20579998_81715914', NULL, 1, NULL, '$2y$12$2.pJetknagIyZAQ1p4oR4ejzLLxQCAtHRSpUh3elNPdeXX4IufMyC', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:35', '2026-10-11 05:20:35', NULL),
(629, 'IMRO\'ATUN NAFIAH', '20579998_3084755282@siswa.prestasiku.id', '20579998_3084755282', NULL, 1, NULL, '$2y$12$Rpxrj/ymW9KZV7P4UBo82OMJKRphPqAFGnTXkm/XM9MtQS4HmdBmm', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:36', '2026-10-11 05:20:36', NULL),
(630, 'MEISHYFA NUR HIDAYAH', '20579998_96045239@siswa.prestasiku.id', '20579998_96045239', NULL, 1, NULL, '$2y$12$ADmULFtCgEjDa0655xztCOG2ERVz1iMUc.G2ztgOk57eX4f52oPdy', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:37', '2026-10-11 05:20:37', NULL),
(631, 'NUR FADHILAH AL FATWA', '20579998_83727364@siswa.prestasiku.id', '20579998_83727364', NULL, 1, NULL, '$2y$12$uLoeSFXK7xXKDq50Rrwn7OVp/WY4OSxBrrC75wgGBspVAhvBgvDi2', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:38', '2026-10-11 05:20:38', NULL),
(632, 'RIZKY BULAN AZZAHRA', '20579998_3086166052@siswa.prestasiku.id', '20579998_3086166052', NULL, 1, NULL, '$2y$12$4EQ7xF3QzrH9AhUXaK/Qt.ry70geg6R05e34aqMVO3adyuWs/zPqe', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:39', '2026-10-11 05:20:39', NULL),
(633, 'SHIRLY CHAFIYA BINTA AHMAD', '20579998_3089765493@siswa.prestasiku.id', '20579998_3089765493', NULL, 1, NULL, '$2y$12$Jhh8xKPR3K.Jgqok.bWwOu88rRc8QavdtQOTnpETmT/kdmtkG3Yq.', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:40', '2026-10-11 05:20:40', NULL),
(634, 'SIFA SAHARANY', '20579998_96191205@siswa.prestasiku.id', '20579998_96191205', NULL, 1, NULL, '$2y$12$PDQRFhtcBMGefFy5yJDjled7TuDdvh8VIWU4f329eAUjofil6X3sG', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:41', '2026-10-11 05:20:41', NULL),
(635, 'SITI ZULVA ROHMATIN', '20579998_81232328@siswa.prestasiku.id', '20579998_81232328', NULL, 1, NULL, '$2y$12$lG0EdW8Gc0J00jVa9Cpjneh/hR9pj6UcyBBUfe6J4E7uM1a782QcK', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:41', '2026-10-11 05:20:41', NULL),
(636, 'YESSY ARTANITA AZZUFA', '20579998_3099671112@siswa.prestasiku.id', '20579998_3099671112', NULL, 1, NULL, '$2y$12$fH/bpnDuKWv4T15Pnso.fegM2czcoqQaJP69t543SfJz/gyyu/x06', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:42', '2026-10-11 05:20:42', NULL),
(637, 'ZAHROTUL HAYATUD DUNNYA', '20579998_3094597521@siswa.prestasiku.id', '20579998_3094597521', NULL, 1, NULL, '$2y$12$qYn5D2EMCEd5bCXrGETBeeM3XvExI9QjhmDplRxdYnsr35FCkP.Ty', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:42', '2026-10-11 05:20:42', NULL),
(638, 'ZIYADATUL CHOIRIYAH', '20579998_3081450431@siswa.prestasiku.id', '20579998_3081450431', NULL, 1, NULL, '$2y$12$tg0vWBEoMDGiyHScP5zWJO8M5vnKoRMh.lPN4.unXIZaN/XDJmzvS', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:43', '2026-10-11 05:20:43', NULL),
(639, 'IZHARRO LAVINA ABIDAH', '20579998_91170581@siswa.prestasiku.id', '20579998_91170581', NULL, 1, NULL, '$2y$12$bn0Qs1JjHPTQ4w/mRx4MFO9cUMf00VfnCTDyfzIZQ5729cfa1lFQa', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:43', '2026-10-11 05:20:43', NULL),
(640, 'SITI NUR FAZILA', '20579998_44635179@siswa.prestasiku.id', '20579998_44635179', NULL, 1, NULL, '$2y$12$ep1fFH8TUJEwcmoMhBvtYO6q16WJBHgOb1ryGrrgetb/rrQYXE4Ia', 1, NULL, NULL, NULL, 'active', NULL, '2026-10-11 05:20:44', '2026-10-11 05:20:44', NULL),
(641, 'Admin MAU', 'mauwh.official@gmail.com', 'adminmau', NULL, 1, NULL, '$2y$12$8rfgyTQ/IBtcduxVwAhGReF/TrjuG6yLJVh.Cm0gVb.Ov/vy22YE2', 0, NULL, '2026-10-28 22:40:16', '114.8.224.113', 'active', NULL, '2026-10-11 18:10:59', '2026-10-28 22:40:16', NULL);

--
-- Indeks untuk tabel yang dibuang
--

--
-- Indeks untuk tabel `achievements`
--
ALTER TABLE `achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `achievements_public_id_unique` (`public_id`),
  ADD KEY `achievements_competition_id_foreign` (`competition_id`),
  ADD KEY `achievements_registration_id_foreign` (`registration_id`),
  ADD KEY `achievements_verified_by_foreign` (`verified_by`),
  ADD KEY `achievements_public_id_status_index` (`public_id`,`status`),
  ADD KEY `achievements_school_id_status_index` (`school_id`,`status`),
  ADD KEY `achievements_student_id_status_index` (`student_id`,`status`);

--
-- Indeks untuk tabel `achievement_documents`
--
ALTER TABLE `achievement_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `achievement_documents_achievement_id_document_type_index` (`achievement_id`,`document_type`);

--
-- Indeks untuk tabel `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indeks untuk tabel `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indeks untuk tabel `competitions`
--
ALTER TABLE `competitions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `competitions_slug_unique` (`slug`),
  ADD KEY `competitions_organizer_id_foreign` (`organizer_id`),
  ADD KEY `competitions_category_id_foreign` (`category_id`),
  ADD KEY `competitions_verified_by_foreign` (`verified_by`),
  ADD KEY `competitions_verification_status_visibility_index` (`verification_status`,`visibility`),
  ADD KEY `competitions_level_target_level_index` (`level`,`target_level`),
  ADD KEY `competitions_registration_open_at_registration_deadline_index` (`registration_open_at`,`registration_deadline`),
  ADD KEY `competitions_event_start_at_event_end_at_index` (`event_start_at`,`event_end_at`),
  ADD KEY `competitions_curation_type_index` (`curation_type`);

--
-- Indeks untuk tabel `competition_categories`
--
ALTER TABLE `competition_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `competition_categories_slug_unique` (`slug`);

--
-- Indeks untuk tabel `competition_eligibilities`
--
ALTER TABLE `competition_eligibilities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `competition_eligibilities_competition_id_unique` (`competition_id`);

--
-- Indeks untuk tabel `competition_forms`
--
ALTER TABLE `competition_forms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `competition_forms_competition_id_version_unique` (`competition_id`,`version`);

--
-- Indeks untuk tabel `competition_permissions`
--
ALTER TABLE `competition_permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `competition_permissions_school_id_foreign` (`school_id`),
  ADD KEY `competition_permissions_student_id_foreign` (`student_id`),
  ADD KEY `competition_permissions_competition_id_foreign` (`competition_id`),
  ADD KEY `competition_permissions_requested_by_foreign` (`requested_by`),
  ADD KEY `competition_permissions_approved_by_foreign` (`approved_by`);

--
-- Indeks untuk tabel `competition_sources`
--
ALTER TABLE `competition_sources`
  ADD PRIMARY KEY (`id`),
  ADD KEY `competition_sources_competition_id_foreign` (`competition_id`),
  ADD KEY `competition_sources_verified_by_foreign` (`verified_by`);

--
-- Indeks untuk tabel `competition_supervisors`
--
ALTER TABLE `competition_supervisors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `competition_supervisors_public_token_unique` (`public_token`),
  ADD KEY `competition_supervisors_school_id_foreign` (`school_id`),
  ADD KEY `competition_supervisors_competition_id_foreign` (`competition_id`),
  ADD KEY `competition_supervisors_created_by_foreign` (`created_by`),
  ADD KEY `competition_supervisors_approved_by_foreign` (`approved_by`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  ADD KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`);

--
-- Indeks untuk tabel `form_fields`
--
ALTER TABLE `form_fields`
  ADD PRIMARY KEY (`id`),
  ADD KEY `form_fields_form_id_order_index` (`form_id`,`order`);

--
-- Indeks untuk tabel `hero_sliders`
--
ALTER TABLE `hero_sliders`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `imports`
--
ALTER TABLE `imports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `imports_user_id_foreign` (`user_id`),
  ADD KEY `imports_school_id_created_at_index` (`school_id`,`created_at`);

--
-- Indeks untuk tabel `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indeks untuk tabel `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `kbm_dispensations`
--
ALTER TABLE `kbm_dispensations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kbm_dispensations_verification_token_unique` (`verification_token`),
  ADD UNIQUE KEY `kbm_dispensations_reference_number_unique` (`reference_number`),
  ADD KEY `kbm_dispensations_competition_id_foreign` (`competition_id`),
  ADD KEY `kbm_dispensations_requested_by_foreign` (`requested_by`),
  ADD KEY `kbm_dispensations_approved_by_foreign` (`approved_by`),
  ADD KEY `kbm_dispensations_school_id_status_index` (`school_id`,`status`),
  ADD KEY `kbm_dispensations_start_date_end_date_index` (`start_date`,`end_date`),
  ADD KEY `kbm_dispensations_verification_token_index` (`verification_token`);

--
-- Indeks untuk tabel `kbm_dispensation_students`
--
ALTER TABLE `kbm_dispensation_students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kbm_dispensation_students_dispensation_id_student_id_unique` (`dispensation_id`,`student_id`),
  ADD KEY `kbm_dispensation_students_student_id_foreign` (`student_id`);

--
-- Indeks untuk tabel `login_events`
--
ALTER TABLE `login_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `login_events_identifier_created_at_index` (`identifier`,`created_at`),
  ADD KEY `login_events_user_id_created_at_index` (`user_id`,`created_at`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  ADD KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Indeks untuk tabel `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  ADD KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Indeks untuk tabel `organizers`
--
ALTER TABLE `organizers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `organizers_verified_by_foreign` (`verified_by`);

--
-- Indeks untuk tabel `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indeks untuk tabel `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`);

--
-- Indeks untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indeks untuk tabel `registrations`
--
ALTER TABLE `registrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registrations_registration_code_unique` (`registration_code`),
  ADD KEY `registrations_form_version_id_foreign` (`form_version_id`),
  ADD KEY `registrations_team_id_foreign` (`team_id`),
  ADD KEY `registrations_registered_by_foreign` (`registered_by`),
  ADD KEY `registrations_school_approved_by_foreign` (`school_approved_by`),
  ADD KEY `registrations_competition_id_status_index` (`competition_id`,`status`),
  ADD KEY `registrations_school_id_school_approval_status_index` (`school_id`,`school_approval_status`),
  ADD KEY `registrations_student_id_status_index` (`student_id`,`status`),
  ADD KEY `registrations_school_id_result_status_index` (`school_id`,`result_status`),
  ADD KEY `registrations_student_id_result_status_index` (`student_id`,`result_status`);

--
-- Indeks untuk tabel `registration_answers`
--
ALTER TABLE `registration_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `registration_answers_form_field_id_foreign` (`form_field_id`),
  ADD KEY `registration_answers_registration_id_field_key_index` (`registration_id`,`field_key`);

--
-- Indeks untuk tabel `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`);

--
-- Indeks untuk tabel `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`role_id`),
  ADD KEY `role_has_permissions_role_id_foreign` (`role_id`);

--
-- Indeks untuk tabel `schools`
--
ALTER TABLE `schools`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `schools_npsn_unique` (`npsn`),
  ADD KEY `schools_verified_by_foreign` (`verified_by`);

--
-- Indeks untuk tabel `school_registrations`
--
ALTER TABLE `school_registrations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `school_registrations_reviewed_by_foreign` (`reviewed_by`),
  ADD KEY `school_registrations_npsn_index` (`npsn`);

--
-- Indeks untuk tabel `school_signers`
--
ALTER TABLE `school_signers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `school_signers_signature_token_unique` (`signature_token`),
  ADD KEY `school_signers_school_id_foreign` (`school_id`);

--
-- Indeks untuk tabel `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indeks untuk tabel `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `students_school_id_nis_unique` (`school_id`,`nis`),
  ADD UNIQUE KEY `students_user_id_unique` (`user_id`),
  ADD UNIQUE KEY `students_public_id_unique` (`public_id`),
  ADD KEY `students_school_id_grade_level_index` (`school_id`,`grade_level`),
  ADD KEY `students_nisn_index` (`nisn`);

--
-- Indeks untuk tabel `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `teams_school_id_foreign` (`school_id`),
  ADD KEY `teams_leader_student_id_foreign` (`leader_student_id`),
  ADD KEY `teams_created_by_foreign` (`created_by`),
  ADD KEY `teams_competition_id_school_id_index` (`competition_id`,`school_id`);

--
-- Indeks untuk tabel `team_members`
--
ALTER TABLE `team_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `team_members_team_id_student_id_unique` (`team_id`,`student_id`),
  ADD KEY `team_members_student_id_foreign` (`student_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_username_unique` (`username`),
  ADD KEY `users_school_id_foreign` (`school_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `achievements`
--
ALTER TABLE `achievements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `achievement_documents`
--
ALTER TABLE `achievement_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `competitions`
--
ALTER TABLE `competitions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `competition_categories`
--
ALTER TABLE `competition_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `competition_eligibilities`
--
ALTER TABLE `competition_eligibilities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `competition_forms`
--
ALTER TABLE `competition_forms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `competition_permissions`
--
ALTER TABLE `competition_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `competition_sources`
--
ALTER TABLE `competition_sources`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- AUTO_INCREMENT untuk tabel `competition_supervisors`
--
ALTER TABLE `competition_supervisors`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `form_fields`
--
ALTER TABLE `form_fields`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `hero_sliders`
--
ALTER TABLE `hero_sliders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `imports`
--
ALTER TABLE `imports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kbm_dispensations`
--
ALTER TABLE `kbm_dispensations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `kbm_dispensation_students`
--
ALTER TABLE `kbm_dispensation_students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `login_events`
--
ALTER TABLE `login_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT untuk tabel `organizers`
--
ALTER TABLE `organizers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT untuk tabel `registrations`
--
ALTER TABLE `registrations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `registration_answers`
--
ALTER TABLE `registration_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `schools`
--
ALTER TABLE `schools`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `school_registrations`
--
ALTER TABLE `school_registrations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `school_signers`
--
ALTER TABLE `school_signers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `students`
--
ALTER TABLE `students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=639;

--
-- AUTO_INCREMENT untuk tabel `teams`
--
ALTER TABLE `teams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `team_members`
--
ALTER TABLE `team_members`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=642;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `achievements`
--
ALTER TABLE `achievements`
  ADD CONSTRAINT `achievements_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `achievements_registration_id_foreign` FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `achievements_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `achievements_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `achievements_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `achievement_documents`
--
ALTER TABLE `achievement_documents`
  ADD CONSTRAINT `achievement_documents_achievement_id_foreign` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `competitions`
--
ALTER TABLE `competitions`
  ADD CONSTRAINT `competitions_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `competition_categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `competitions_organizer_id_foreign` FOREIGN KEY (`organizer_id`) REFERENCES `organizers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `competitions_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `competition_eligibilities`
--
ALTER TABLE `competition_eligibilities`
  ADD CONSTRAINT `competition_eligibilities_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `competition_forms`
--
ALTER TABLE `competition_forms`
  ADD CONSTRAINT `competition_forms_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `competition_permissions`
--
ALTER TABLE `competition_permissions`
  ADD CONSTRAINT `competition_permissions_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `competition_permissions_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `competition_permissions_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `competition_permissions_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `competition_permissions_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `competition_sources`
--
ALTER TABLE `competition_sources`
  ADD CONSTRAINT `competition_sources_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `competition_sources_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `competition_supervisors`
--
ALTER TABLE `competition_supervisors`
  ADD CONSTRAINT `competition_supervisors_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `competition_supervisors_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `competition_supervisors_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `competition_supervisors_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `form_fields`
--
ALTER TABLE `form_fields`
  ADD CONSTRAINT `form_fields_form_id_foreign` FOREIGN KEY (`form_id`) REFERENCES `competition_forms` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `imports`
--
ALTER TABLE `imports`
  ADD CONSTRAINT `imports_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `imports_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `kbm_dispensations`
--
ALTER TABLE `kbm_dispensations`
  ADD CONSTRAINT `kbm_dispensations_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `kbm_dispensations_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `kbm_dispensations_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `kbm_dispensations_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `kbm_dispensation_students`
--
ALTER TABLE `kbm_dispensation_students`
  ADD CONSTRAINT `kbm_dispensation_students_dispensation_id_foreign` FOREIGN KEY (`dispensation_id`) REFERENCES `kbm_dispensations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `kbm_dispensation_students_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `login_events`
--
ALTER TABLE `login_events`
  ADD CONSTRAINT `login_events_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `organizers`
--
ALTER TABLE `organizers`
  ADD CONSTRAINT `organizers_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `registrations`
--
ALTER TABLE `registrations`
  ADD CONSTRAINT `registrations_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `registrations_form_version_id_foreign` FOREIGN KEY (`form_version_id`) REFERENCES `competition_forms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `registrations_registered_by_foreign` FOREIGN KEY (`registered_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `registrations_school_approved_by_foreign` FOREIGN KEY (`school_approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `registrations_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `registrations_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `registrations_team_id_foreign` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `registration_answers`
--
ALTER TABLE `registration_answers`
  ADD CONSTRAINT `registration_answers_form_field_id_foreign` FOREIGN KEY (`form_field_id`) REFERENCES `form_fields` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `registration_answers_registration_id_foreign` FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `schools`
--
ALTER TABLE `schools`
  ADD CONSTRAINT `schools_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `school_registrations`
--
ALTER TABLE `school_registrations`
  ADD CONSTRAINT `school_registrations_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `school_signers`
--
ALTER TABLE `school_signers`
  ADD CONSTRAINT `school_signers_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `students_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `teams`
--
ALTER TABLE `teams`
  ADD CONSTRAINT `teams_competition_id_foreign` FOREIGN KEY (`competition_id`) REFERENCES `competitions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `teams_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `teams_leader_student_id_foreign` FOREIGN KEY (`leader_student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `teams_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `team_members`
--
ALTER TABLE `team_members`
  ADD CONSTRAINT `team_members_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `team_members_team_id_foreign` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_school_id_foreign` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
