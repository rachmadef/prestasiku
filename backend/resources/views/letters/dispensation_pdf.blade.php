<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Surat Dispensasi Belajar - {{ $dispensation->reference_number }}</title>
    <style>
        @page {
            size: A4 portrait;
            margin: 1.5cm 2cm 2cm 2cm;
        }
        body {
            font-family: 'Times New Roman', Times, serif;
            color: #111827;
            font-size: 11pt;
            line-height: 1.4;
            margin: 0;
            padding: 0;
        }
        .kop-container {
            text-align: center;
            margin-bottom: 12px;
        }
        .kop-image {
            width: 100%;
            max-height: 130px;
            object-fit: contain;
            display: block;
            margin: 0 auto;
        }
        .kop-text-gov {
            font-size: 11pt;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }
        .kop-text-agency {
            font-size: 12pt;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 2px 0 0 0;
        }
        .kop-text-school {
            font-size: 14pt;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin: 2px 0 0 0;
        }
        .kop-text-meta {
            font-size: 9pt;
            font-family: Arial, sans-serif;
            color: #374151;
            margin: 4px 0 0 0;
        }
        .kop-line-thick {
            border-top: 2.5px solid #000;
            margin-top: 8px;
        }
        .kop-line-thin {
            border-top: 1px solid #000;
            margin-top: 1.5px;
            margin-bottom: 14px;
        }
        .doc-title-container {
            text-align: center;
            margin-bottom: 16px;
        }
        .doc-title {
            font-size: 13pt;
            font-weight: bold;
            text-decoration: underline;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }
        .doc-ref-number {
            font-size: 10.5pt;
            font-family: Arial, sans-serif;
            margin-top: 3px;
        }
        .doc-body {
            text-align: justify;
            margin-bottom: 12px;
        }
        .student-table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0 14px 0;
            font-size: 10pt;
            font-family: Arial, sans-serif;
        }
        .student-table th, .student-table td {
            border: 1px solid #4b5563;
            padding: 5px 8px;
        }
        .student-table th {
            background-color: #f3f4f6;
            font-weight: bold;
            text-align: center;
        }
        .info-box {
            background-color: #f9fafb;
            border: 1px solid #d1d5db;
            border-radius: 4px;
            padding: 8px 12px;
            margin: 10px 0;
            font-size: 10pt;
            font-family: Arial, sans-serif;
        }
        .info-box table {
            width: 100%;
            border-collapse: collapse;
        }
        .info-box td {
            padding: 2px 4px;
            vertical-align: top;
        }
        .info-box td.label {
            width: 140px;
            font-weight: bold;
            color: #1f2937;
        }
        .closing-text {
            font-style: italic;
            margin-top: 10px;
            margin-bottom: 20px;
            font-size: 10pt;
        }
        .signatures-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            page-break-inside: avoid;
        }
        .signatures-table td {
            width: 50%;
            vertical-align: top;
            text-align: center;
            font-size: 10pt;
            padding: 0 10px;
        }
        .signature-title {
            font-weight: bold;
            margin-bottom: 4px;
        }
        .signature-name {
            font-weight: bold;
            text-decoration: underline;
            margin-top: 55px;
        }
        .signature-nip {
            font-size: 9pt;
            color: #4b5563;
            font-family: Arial, sans-serif;
        }
        .signature-note {
            font-size: 8.5pt;
            color: #6b7280;
            font-style: italic;
            margin-top: 4px;
        }
        .qr-section {
            margin-top: 12px;
            text-align: left;
            font-family: Arial, sans-serif;
        }
        .qr-section img {
            width: 70px;
            height: 70px;
            vertical-align: middle;
        }
        .qr-text {
            display: inline-block;
            vertical-align: middle;
            margin-left: 8px;
            font-size: 8pt;
            color: #4b5563;
            max-width: 180px;
        }
    </style>
</head>
<body>

    <!-- Kop Surat Sekolah -->
    <div class="kop-container">
        @if (!empty($letterheadImageBase64))
            <img src="{{ $letterheadImageBase64 }}" alt="Kop Surat" class="kop-image" />
        @else
            <p class="kop-text-gov">{{ $letterConfig['institution_level1'] ?? 'PEMERINTAH PROVINSI' }}</p>
            <p class="kop-text-agency">{{ $letterConfig['institution_level2'] ?? 'DINAS PENDIDIKAN DAN KEBUDAYAAN' }}</p>
            <p class="kop-text-school">{{ $school->name }}</p>
            <p class="kop-text-meta">
                {{ $school->address }} • NPSN: {{ $school->npsn }}
                @if($school->phone) • Telp: {{ $school->phone }} @endif
                @if($school->email) • Email: {{ $school->email }} @endif
            </p>
            <div class="kop-line-thick"></div>
            <div class="kop-line-thin"></div>
        @endif
    </div>

    <!-- Judul Dokumen & Nomor Registrasi -->
    <div class="doc-title-container">
        <h1 class="doc-title">{{ $letterConfig['document_title'] ?? 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)' }}</h1>
        <div class="doc-ref-number">Nomor: {{ $dispensation->reference_number }}</div>
    </div>

    <!-- Pembuka Surat -->
    <div class="doc-body">
        <p style="margin: 0 0 8px 0;">
            Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {{ $school->name }}, dengan ini menerangkan dan memberikan izin dispensasi kepada siswa-siswi tersebut di bawah ini:
        </p>

        <!-- Tabel Delegasi Siswa -->
        <table class="student-table">
            <thead>
                <tr>
                    <th style="width: 30px;">No</th>
                    <th>Nama Siswa</th>
                    <th style="width: 100px;">NIS / NISN</th>
                    <th style="width: 90px;">Kelas</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($dispensation->students as $index => $student)
                    <tr>
                        <td style="text-align: center;">{{ $index + 1 }}</td>
                        <td style="font-weight: bold;">{{ $student->full_name }}</td>
                        <td style="text-align: center;">{{ $student->nis ?? '-' }} / {{ $student->nisn ?? '-' }}</td>
                        <td style="text-align: center;">{{ $student->class_name ?? '-' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        <p style="margin: 8px 0 6px 0;">
            Diberikan izin untuk tidak mengikuti Kegiatan Belajar Mengajar (KBM) di kelas sehubungan dengan keikutsertaan pada agenda kompetisi / pembinaan prestasi:
        </p>

        <!-- Kotak Rincian Kegiatan -->
        <div class="info-box">
            <table>
                <tr>
                    <td class="label">Nama Kegiatan</td>
                    <td style="width: 10px;">:</td>
                    <td style="font-weight: bold;">{{ $dispensation->competition_name }}</td>
                </tr>
                <tr>
                    <td class="label">Jenis Izin</td>
                    <td>:</td>
                    <td>
                        @if($dispensation->dispensation_type === 'persiapan_latihan')
                            Pembinaan & Latihan Intensif
                        @elseif($dispensation->dispensation_type === 'pelaksanaan_lomba')
                            Pelaksanaan Hari-H Lomba
                        @else
                            Kegiatan Prestasi Sekolah
                        @endif
                    </td>
                </tr>
                <tr>
                    <td class="label">Keperluan Izin</td>
                    <td>:</td>
                    <td>{{ $dispensation->purpose }}</td>
                </tr>
                <tr>
                    <td class="label">Waktu Pelaksanaan</td>
                    <td>:</td>
                    <td>
                        {{ \Carbon\Carbon::parse($dispensation->start_date)->translatedFormat('d F Y') }}
                        s.d.
                        {{ \Carbon\Carbon::parse($dispensation->end_date)->translatedFormat('d F Y') }}
                        @if(!$dispensation->is_all_day && $dispensation->start_time)
                            ({{ $dispensation->start_time }} - {{ $dispensation->end_time }} WIB)
                        @else
                            (Seharian Penuh)
                        @endif
                    </td>
                </tr>
                <tr>
                    <td class="label">Guru Pembina Lomba</td>
                    <td>:</td>
                    <td style="font-weight: bold;">{{ $dispensation->supervisor_name ?? 'Pembina Lomba Sekolah' }}</td>
                </tr>
            </table>
        </div>

        <!-- Kalimat Penutup -->
        <p class="closing-text">
            Demikian surat dispensasi ini diterbitkan agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa yang bersangkutan tetap berkewajiban menyelesaikan materi serta tugas-tugas pelajaran yang tertinggal.
        </p>
    </div>

    <!-- 2 Kolom Tanda Tangan Resmi Sesuai Kebutuhan di Lapangan -->
    <table class="signatures-table">
        <tr>
            <!-- Tanda Tangan 1: Guru Pembina Lomba (Terisi Otomatis) -->
            <td>
                <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                    Ditetapkan di: {{ $school->city ?? 'Tempat' }}<br>
                    Pada tanggal: {{ \Carbon\Carbon::parse($dispensation->approved_at ?? now())->translatedFormat('d F Y') }}
                </div>
                <div class="signature-title">
                    Mengetahui,<br>
                    Guru Pembina Lomba
                </div>
                <div class="signature-name">
                    {{ $dispensation->supervisor_name ?: 'Pembina Lomba Prestasi' }}
                </div>
                <div class="signature-nip">
                    NIP. - / Pembina Prestasi Sekolah
                </div>
            </td>

            <!-- Tanda Tangan 2: Guru Mata Pelajaran / Guru Piket (Dikosongkan Karena Jam Mengajar Fleksibel) -->
            <td>
                <div style="font-size: 9.5pt; color: transparent; margin-bottom: 2px;">
                    .<br>.
                </div>
                <div class="signature-title">
                    Menyetujui / Memaklumi,<br>
                    Guru Mata Pelajaran / Guru Piket
                </div>
                <div class="signature-name" style="text-decoration: none;">
                    ( .................................................... )
                </div>
                <div class="signature-nip">
                    NIP. ..............................................
                </div>
                <div class="signature-note">
                    * Ditandatangani saat jam KBM berlangsung di kelas
                </div>
            </td>
        </tr>
    </table>

    <!-- Stempel Validasi QR Code Digital PrestasiKu -->
    @if(!empty($qrCodeDataUri))
        <div class="qr-section">
            <table style="width: auto; border-collapse: collapse;">
                <tr>
                    <td style="padding: 0; vertical-align: middle;">
                        <img src="{{ $qrCodeDataUri }}" alt="QR Verifikasi" />
                    </td>
                    <td style="padding-left: 8px; vertical-align: middle; font-size: 8pt; color: #4b5563;">
                        <strong>Sistem Validasi PrestasiKu</strong><br>
                        Pindai QR ini untuk memeriksa keabsahan surat secara publik tanpa perlu login.
                    </td>
                </tr>
            </table>
        </div>
    @endif

</body>
</html>
