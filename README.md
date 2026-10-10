# 🏆 PrestasiKu - Portal Prestasi & Dispensasi Belajar (KBM)

**PrestasiKu** adalah platform manajemen prestasi siswa dan penerbitan Surat Izin Dispensasi Kegiatan Belajar Mengajar (KBM) sekolah secara digital. Sistem ini dilengkapi dengan verifikasi TTD Digital berbasis QR Code, integrasi AI untuk verifikasi perlombaan, serta halaman publik untuk pengecekan keabsahan dokumen dan data penandatangan resmi sekolah.

---

## 🚀 Fitur Utama

### 1. 🛡️ Multi-Role Dashboard & Access Control
- **Super Admin / Platform Management:**
  - Pengelolaan sekolah, instansi, dan katalog perlombaan nasional/internasional.
  - Pengaturan kategori lomba, penyelenggara, dan banner landing page.
  - Integrasi AI (Google Gemini & Groq) untuk verifikasi otomatis kelayakan & syarat lomba.
- **Admin Sekolah & Kesiswaan:**
  - **Manajemen Peserta Didik:** Import data siswa via CSV/Excel, pengelolaan NIS/NISN, serta manajemen akun siswa.
  - **Guru Penandatangan Tetap (Signers Management):** Pengelolaan Waka Kesiswaan & Guru PJ Lomba / Olimpiade beserta fitur TTD Digital QR Code dan profil publik guru (TTL, alamat, riwayat pendidikan, foto).
  - **Dispensasi KBM & Persetujuan:** Pengajuan dan verifikasi surat izin dispensasi KBM untuk siswa secara individu maupun kelompok (kolektif).
  - **Custom Builder Surat:** Pengaturan Kop Surat (Upload gambar / teks dinamis), penyesuaian skala kop (A4/F4), penomoran surat, dan margin otomatis.
  - **Cetak PDF Rapi 1 Lembar:** Output Surat Dispensasi Belajar yang otomatis tersusun rapi dalam 1 halaman kertas (A4/F4) lengkap dengan 3 blok TTD (Guru PJ Lomba, Wali Kelas/Guru Mapel, & Waka Kesiswaan).
  - **Rekam Prestasi & Portofolio:** Penginputan raihan juara siswa dan rekapitulasi capaian prestasi sekolah.
- **Siswa / Peserta Didik:**
  - Katalog informasi perlombaan dan olimpiade.
  - Pengajuan izin dispensasi KBM mandiri untuk mengikuti kompetisi.
  - Portofolio digital pencapaian prestasi dan riwayat sertifikat.

### 2. 🔍 Verifikasi Publik Berbasis QR Code
- **Stempel Verifikasi Keabsahan Surat:** Pengunjung atau pihak sekolah/guru piket dapat memindai QR Code pada surat dispensasi untuk memverifikasi keabsahan dokumen secara publik.
- **Verifikasi TTD Digital Guru (QR Code Signer):** Memindai QR Code TTD Waka Kesiswaan / Guru PJ Lomba untuk menuju ke halaman verifikasi resmi profil & biodata guru penandatangan.

---

## 🛠️ Spesifikasi & Teknologi

### **Backend**
- **Framework:** Laravel 11 (PHP 8.3 / 8.4)
- **Autentikasi:** Laravel Sanctum
- **Role & Permission:** Spatie Laravel-Permission
- **PDF Generator:** Barryvdh Laravel DomPDF
- **QR Code Engine:** SimpleSoftwareIO Simple QRCode
- **Excel & Document:** Maatwebsite Excel & PHPWord
- **AI Integrations:** Google Gemini API & Groq API

### **Frontend**
- **Framework:** Vue 3 (Composition API & `<script setup>`)
- **Build Tool:** Vite 8 + TypeScript (`vue-tsc`)
- **State Management:** Pinia
- **Routing:** Vue Router
- **Styling & UI:** TailwindCSS 4 + Custom Utility CSS & FontAwesome Icons

---

## 💻 Panduan Instalasi & Pengoperasian

### 📋 Prasyarat System
- PHP `>= 8.3` (Extension: `pdo`, `mbstring`, `openssl`, `gd`, `zip`, `sqlite3` atau `mysqli`)
- Composer `>= 2.x`
- Node.js `>= 18.x` & npm

---

### 1. ⚙️ Setup Backend (Laravel API)

```bash
# Masuk ke direktori backend
cd backend

# Install dependensi PHP
composer install

# Salin berkas lingkungan .env
copy .env.example .env

# Generate Application Key
php artisan key:generate

# Jalankan migrasi database & seeder
php artisan migrate --seed

# Jalankan server lokal Laravel
php artisan serve
```
> Server backend akan berjalan di `http://127.0.0.1:8000`.

---

### 2. 🎨 Setup Frontend (Vue 3 + Vite)

```bash
# Masuk ke direktori frontend
cd frontend

# Install dependensi Node.js
npm install

# Jalankan server pengembangan Vite
npm run dev
```
> Server frontend akan berjalan di `http://localhost:5173`.

---

## 🧪 Pengujian (Unit & Feature Tests)

Untuk memastikan seluruh modul backend (seperti penerbitan PDF dispensasi, verifikasi QR Code, dan manajemen penandatangan sekolah) berjalan dengan baik:

```bash
cd backend

# Jalankan seluruh test suite
php artisan test

# Pengujian spesifik fitur dispensasi & PDF
php artisan test --filter=KbmDispensationAndArchiveTest

# Pengujian spesifik fitur penandatangan sekolah & QR TTD
php artisan test --filter=SchoolSignerTest
```

---

## 📁 Struktur Direktori Utama

```
prestasiku/
├── backend/                  # Application API Laravel 11
│   ├── app/
│   │   ├── Http/Controllers/ # Controller API Admin, School, Student & Public
│   │   ├── Models/           # Eloquent Models (KbmDispensation, SchoolSigner, etc.)
│   │   └── Services/         # QrCodeService, DispensationDocumentService, Gemini AI
│   ├── database/             # Migrations & Seeders
│   ├── resources/views/       # Blade templates untuk PDF (dispensation_pdf.blade.php)
│   └── routes/               # Routes (api.php & web.php)
│
├── frontend/                 # Application Frontend Vue 3 + Vite
│   ├── src/
│   │   ├── components/       # Reusable UI Components (Modal, Navbar, Sidebar)
│   │   ├── layouts/          # DashboardLayout & PublicLayout
│   │   ├── router/           # Vue Router definitions
│   │   ├── stores/           # Pinia Stores (Auth, School, Dispensations)
│   │   └── views/            # Admin, School Admin, Student & Public Verification Views
│   └── package.json
└── README.md
```

---

## 📜 Lisensi & Pengembang

Dikembangkan untuk mendukung digitalisasi manajemen prestasi dan otomatisasi administrasi perizinan sekolah yang efisien, transparan, dan tervalidasi secara resmi.

**PrestasiKu © 2026** — *Empowering Student Achievements with Modern Digital Solutions.*
