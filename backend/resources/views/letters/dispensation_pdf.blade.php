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
        .page-break {
            page-break-before: always;
        }
        .kop-container {
            text-align: {{ $letterConfig['header_alignment'] ?? 'center' }};
            margin-bottom: {{ $letterConfig['header_margin_bottom'] ?? 10 }}px;
        }
        .kop-image {
            display: block;
            margin: {{ ($letterConfig['header_alignment'] ?? 'center') === 'center' ? '0 auto' : (($letterConfig['header_alignment'] ?? 'center') === 'left' ? '0 auto 0 0' : '0 0 0 auto') }};
            @if(($letterConfig['header_width_mode'] ?? 'contained') === 'full')
                width: 100%;
                height: auto;
                max-height: none;
                object-fit: fill;
            @else
                width: auto;
                max-width: 100%;
                max-height: {{ $letterConfig['header_max_height'] ?? 130 }}px;
                object-fit: contain;
            @endif
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
        .recipient-box {
            margin-bottom: 14px;
            font-size: 11pt;
        }
        .doc-body {
            text-align: justify;
            margin-bottom: 12px;
        }
        .info-table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
            font-size: 10.5pt;
        }
        .info-table td {
            padding: 3px 4px;
            vertical-align: top;
        }
        .info-table td.label {
            width: 140px;
            font-weight: bold;
        }
        .student-table {
            width: 100%;
            border-collapse: collapse;
            margin: 12px 0;
            font-size: 10.5pt;
            font-family: 'Times New Roman', Times, serif;
        }
        .student-table th, .student-table td {
            border: 1px solid #000;
            padding: 6px 10px;
        }
        .student-table th {
            background-color: #f3f4f6;
            font-weight: bold;
            text-align: center;
            text-transform: uppercase;
            font-size: 10pt;
        }
        .closing-text {
            text-align: justify;
            margin-top: 12px;
            margin-bottom: 20px;
            font-size: 11pt;
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
            width: 65px;
            height: 65px;
            vertical-align: middle;
        }
        .qr-text {
            display: inline-block;
            vertical-align: middle;
            margin-left: 8px;
            font-size: 8pt;
            color: #4b5563;
            max-width: 200px;
        }
    </style>
</head>
<body>

    <!-- ========================================================= -->
    <!-- LEMBAR 1: SURAT DISPENSASI UTAMA                          -->
    <!-- ========================================================= -->

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

    <!-- Judul Dokumen & Nomor -->
    <div class="doc-title-container">
        <h1 class="doc-title">{{ $letterConfig['document_title'] ?? 'SURAT DISPENSASI' }}</h1>
        <div class="doc-ref-number">Nomor: {{ $dispensation->reference_number }}</div>
    </div>

    <!-- Kepada Yth -->
    <div class="recipient-box">
        Yang Terhormat,<br>
        <strong>Bapak/Ibu Guru Mata Pelajaran / Guru Piket</strong><br>
        Di Kelas
    </div>

    <!-- Pembuka Surat -->
    <div class="doc-body">
        @if(count($students) > 1)
            <p style="margin: 0 0 10px 0;">
                Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {{ $school->name }}, memberikan izin dan dispensasi KBM kepada peserta didik berikut:
                <strong style="text-decoration: underline;">(nama-nama terlampir)</strong>
            </p>
        @else
            @php $singleStudent = $students->first(); @endphp
            <p style="margin: 0 0 10px 0;">
                Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {{ $school->name }}, memberikan izin dan dispensasi KBM kepada peserta didik berikut:
            </p>

            <!-- Details Single Student Langsung di Halaman Utama -->
            <table class="info-table" style="margin: 6px 0 12px 0; background-color: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px;">
                <tr>
                    <td class="label" style="width: 140px; padding: 4px 8px;">Nama Peserta Didik</td>
                    <td style="width: 10px; padding: 4px 0;">:</td>
                    <td style="font-weight: bold; text-transform: uppercase; padding: 4px 8px;">{{ $singleStudent->full_name ?? '-' }}</td>
                </tr>
                <tr>
                    <td class="label" style="padding: 4px 8px;">Kelas</td>
                    <td style="padding: 4px 0;">:</td>
                    <td style="font-weight: bold; padding: 4px 8px;">{{ $singleStudent->class_name ?? '-' }}</td>
                </tr>
                <tr>
                    <td class="label" style="padding: 4px 8px;">NIS / NISN</td>
                    <td style="padding: 4px 0;">:</td>
                    <td style="padding: 4px 8px; font-family: Arial, sans-serif;">{{ $singleStudent->nis ?? '-' }} / {{ $singleStudent->nisn ?? '-' }}</td>
                </tr>
            </table>
        @endif

        <!-- Rincian Keperluan & Pelaksanaan -->
        <table class="info-table">
            <tr>
                <td class="label">Nama Kegiatan</td>
                <td style="width: 10px;">:</td>
                <td style="font-weight: bold;">{{ $dispensation->competition_name }}</td>
            </tr>
            @if(!empty($dispensation->competition_field))
            <tr>
                <td class="label">Bidang Lomba</td>
                <td>:</td>
                <td>{{ $dispensation->competition_field }}</td>
            </tr>
            @endif
            @if(!empty($dispensation->competition_level))
            <tr>
                <td class="label">Tingkat Lomba</td>
                <td>:</td>
                <td style="text-transform: capitalize;">{{ $dispensation->competition_level }}</td>
            </tr>
            @endif
            @if(!empty($dispensation->organizer))
            <tr>
                <td class="label">Penyelenggara</td>
                <td>:</td>
                <td>{{ $dispensation->organizer }}</td>
            </tr>
            @endif
            <tr>
                <td class="label">Keperluan / Agenda</td>
                <td>:</td>
                <td>{{ $dispensation->purpose }}</td>
            </tr>
            <tr>
                <td class="label">Hari & Tanggal</td>
                <td>:</td>
                <td>
                    {{ \Carbon\Carbon::parse($dispensation->start_date)->translatedFormat('l, d F Y') }}
                    @if($dispensation->start_date != $dispensation->end_date)
                        s.d. {{ \Carbon\Carbon::parse($dispensation->end_date)->translatedFormat('l, d F Y') }}
                    @endif
                </td>
            </tr>
            <tr>
                <td class="label">Waktu Pelaksanaan</td>
                <td>:</td>
                <td>
                    @if(!$dispensation->is_all_day && $dispensation->start_time)
                        {{ $dispensation->start_time }} - {{ $dispensation->end_time }} WIB
                    @else
                        Seharian Penuh (Jam KBM)
                    @endif
                </td>
            </tr>
            @if(!empty($dispensation->location))
            <tr>
                <td class="label">Tempat / Lokasi</td>
                <td>:</td>
                <td>{{ $dispensation->location }}</td>
            </tr>
            @endif
            <tr>
                <td class="label">Guru Pembina / Pendamping</td>
                <td>:</td>
                <td style="font-weight: bold;">{{ $dispensation->supervisor_name ?? 'Pembina Lomba Sekolah' }}</td>
            </tr>
            @if(!empty($dispensation->homeroom_teacher))
            <tr>
                <td class="label">Wali Kelas</td>
                <td>:</td>
                <td>{{ $dispensation->homeroom_teacher }}</td>
            </tr>
            @endif
        </table>

        <!-- Penutup Surat -->
        <p class="closing-text">
            @if(count($students) > 1)
                Mohon dengan hormat Bapak/Ibu guru memberikan izin kepada nama-nama peserta didik terlampir untuk tidak mengikuti pembelajaran sesuai waktu yang telah ditentukan. Siswa yang bersangkutan tetap berkewajiban menyelesaikan materi pelajaran serta tugas-tugas yang tertinggal.
            @else
                Mohon dengan hormat Bapak/Ibu guru memberikan izin kepada peserta didik di atas untuk tidak mengikuti pembelajaran sesuai waktu yang telah ditentukan. Siswa yang bersangkutan tetap berkewajiban menyelesaikan materi pelajaran serta tugas-tugas yang tertinggal.
            @endif
        </p>
    </div>

    <!-- Tanda Tangan Resmi Sesuai Ketentuan (Guru Pembina, Waka Kesiswaan & Kosongan Wali Kelas) -->
    <table class="signatures-table" style="margin-top: 15px;">
        <tr>
            <!-- Tanda Tangan 1: Guru Pembina / Pendamping -->
            <td style="width: 50%; vertical-align: top; text-align: center;">
                <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                    {{ $school->city ?? 'Jombang' }}, {{ \Carbon\Carbon::parse($dispensation->approved_at ?? now())->translatedFormat('d F Y') }}
                </div>
                <div class="signature-title">
                    Guru Pembina / Pendamping
                </div>
                <div class="signature-name">
                    {{ $dispensation->supervisor_name ?: 'Pembina Lomba Prestasi' }}
                </div>
                <div class="signature-nip">
                    NIP. - / Pembina Prestasi Sekolah
                </div>
            </td>

            <!-- Tanda Tangan 2: Waka Kesiswaan -->
            <td style="width: 50%; vertical-align: top; text-align: center;">
                <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                    Mengetahui / Menyetujui,
                </div>
                <div class="signature-title">
                    Waka Kesiswaan
                </div>
                <div class="signature-name">
                    {{ $letterConfig['waka_kesiswaan_name'] ?? ($dispensation->approvedBy->name ?? 'Drs. H. Abdul Haris') }}
                </div>
                <div class="signature-nip">
                    {{ $letterConfig['waka_kesiswaan_nip'] ?? 'NIP. Sekolah / Pengesahan Resmi' }}
                </div>
            </td>
        </tr>
    </table>

    <!-- Tanda Tangan 3: Kosongan untuk Wali Kelas / Guru Mapel di Kelas -->
    <table class="signatures-table" style="margin-top: 20px;">
        <tr>
            <td style="width: 100%; text-align: center;">
                <div class="signature-title">
                    Menyetujui / Memaklumi,<br>
                    Wali Kelas / Guru Mata Pelajaran
                </div>
                <div class="signature-name" style="margin-top: 45px;">
                    ( .................................................... )
                </div>
                <div class="signature-nip">
                    NIP. ..............................................
                </div>
                <div class="signature-note">
                    *(Ditandatangani saat jam KBM di kelas)*
                </div>
            </td>
        </tr>
    </table>

    <!-- Stempel Validasi QR Code Digital -->
    @if(!empty($qrCodeDataUri))
        <div class="qr-section">
            <table style="width: auto; border-collapse: collapse;">
                <tr>
                    <td style="padding: 0; vertical-align: middle;">
                        <img src="{{ $qrCodeDataUri }}" alt="QR Verifikasi" />
                    </td>
                    <td style="padding-left: 8px; vertical-align: middle; font-size: 8pt; color: #4b5563;">
                        <strong>Sistem Validasi Resmi PrestasiKu</strong><br>
                        Pindai QR ini untuk mengecek keabsahan surat & lampiran siswa secara publik.
                    </td>
                </tr>
            </table>
        </div>
    @endif


    @if(count($students) > 1)
        <!-- ========================================================= -->
        <!-- LEMBAR 2: LAMPIRAN DAFTAR PESERTA DIDIK (PAGE BREAK)      -->
        <!-- ========================================================= -->

        <div class="page-break"></div>

        <!-- Kop Surat Sekolah Lembar 2 -->
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

        <!-- Judul Lampiran -->
        <div class="doc-title-container">
            <h2 style="font-size: 11.5pt; font-weight: bold; text-decoration: underline; text-transform: uppercase; margin: 0;">
                LAMPIRAN DAFTAR PESERTA DIDIK PENERIMA DISPENSASI KBM
            </h2>
            <div class="doc-ref-number">
                Surat Nomor: <strong>{{ $dispensation->reference_number }}</strong> • Agenda: {{ $dispensation->competition_name }}
            </div>
        </div>

        <!-- Tabel Daftar Peserta Didik (Lembar 2) -->
        <table class="student-table">
            <thead>
                <tr>
                    <th style="width: 40px;">NO</th>
                    <th>NAMA PESERTA DIDIK</th>
                    <th style="width: 120px;">NIS / NISN</th>
                    <th style="width: 110px;">KELAS</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($dispensation->students as $index => $student)
                    <tr>
                        <td style="text-align: center; font-weight: bold;">{{ $index + 1 }}</td>
                        <td style="font-weight: bold; text-transform: uppercase;">{{ $student->full_name }}</td>
                        <td style="text-align: center; font-family: Arial, sans-serif;">{{ $student->nis ?? '-' }} / {{ $student->nisn ?? '-' }}</td>
                        <td style="text-align: center; font-weight: bold;">{{ $student->class_name ?? '-' }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" style="text-align: center; font-style: italic;">Tidak ada data siswa terlampir.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        <!-- Tanda Tangan Pengesahan Lampiran -->
        <table class="signatures-table" style="margin-top: 30px;">
            <tr>
                <td style="width: 50%;"></td>
                <td style="width: 50%;">
                    <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                        {{ $school->city ?? 'Jombang' }}, {{ \Carbon\Carbon::parse($dispensation->approved_at ?? now())->translatedFormat('d F Y') }}
                    </div>
                    <div class="signature-title">
                        Guru Pembina / Pendamping
                    </div>
                    <div class="signature-name">
                        {{ $dispensation->supervisor_name ?: 'Pembina Lomba Prestasi' }}
                    </div>
                    <div class="signature-nip">
                        NIP. - / Pembina Prestasi Sekolah
                    </div>
                </td>
            </tr>
        </table>
    @endif

</body>
</html>
