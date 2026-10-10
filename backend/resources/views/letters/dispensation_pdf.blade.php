@php \Carbon\Carbon::setLocale('id'); @endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Surat Dispensasi Belajar - {{ $dispensation->reference_number }}</title>
    <style>
        @page {
            size: A4 portrait;
            margin: 0.6cm 1.4cm 1.0cm 1.4cm;
        }
        body {
            font-family: 'Times New Roman', Times, serif;
            color: #111827;
            font-size: 12pt;
            line-height: 1.3;
            margin: 0;
            padding: 0;
        }
        .page-break {
            page-break-before: always;
        }
        .kop-container {
            text-align: {{ $letterConfig['header_alignment'] ?? 'center' }};
            margin-bottom: {{ $letterConfig['header_margin_bottom'] ?? 8 }}px;
        }
        .kop-container-full {
            margin-top: -0.6cm;
            margin-left: -1.4cm;
            margin-right: -1.4cm;
            margin-bottom: {{ $letterConfig['header_margin_bottom'] ?? 8 }}px;
        }
        .kop-image {
            display: block;
            margin: 0 auto;
            width: 100%;
            height: auto;
            max-height: {{ $letterConfig['header_max_height'] ?? 150 }}px;
            object-fit: fill;
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
            margin-top: 6px;
        }
        .kop-line-thin {
            border-top: 1px solid #000;
            margin-top: 1.5px;
            margin-bottom: 10px;
        }
        .doc-title-container {
            text-align: center;
            margin-bottom: 10px;
        }
        .doc-title {
            font-size: 14pt;
            font-weight: bold;
            text-decoration: underline;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }
        .doc-ref-number {
            font-size: 11pt;
            font-family: Arial, sans-serif;
            margin-top: 2px;
        }
        .recipient-box {
            margin-bottom: 10px;
            font-size: 12pt;
            line-height: 1.3;
        }
        .doc-body {
            text-align: justify;
            margin-bottom: 8px;
            font-size: 12pt;
        }
        .info-table {
            width: 100%;
            border-collapse: collapse;
            margin: 6px 0;
            font-size: 11.5pt;
        }
        .info-table td {
            padding: 2px 4px;
            vertical-align: top;
        }
        .info-table td.label {
            width: 140px;
            font-weight: bold;
        }
        .student-table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
            font-size: 11pt;
            font-family: 'Times New Roman', Times, serif;
        }
        .student-table th, .student-table td {
            border: 1px solid #000;
            padding: 5px 8px;
        }
        .student-table th {
            background-color: #f3f4f6;
            font-weight: bold;
            text-align: center;
            text-transform: uppercase;
            font-size: 10.5pt;
        }
        .closing-text {
            text-align: justify;
            margin-top: 8px;
            margin-bottom: 10px;
            font-size: 12pt;
            line-height: 1.3;
        }
        .signatures-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 8px;
            page-break-inside: avoid;
        }
        .signatures-table td {
            width: 50%;
            vertical-align: top;
            text-align: center;
            font-size: 10.5pt;
            padding: 0 8px;
        }
        .signature-title {
            font-weight: bold;
            margin-bottom: 2px;
        }
        .signature-name {
            font-weight: bold;
            text-decoration: underline;
            margin-top: 45px;
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
            margin-top: 2px;
        }
        .qr-section {
            margin-top: 6px;
            text-align: left;
            font-family: Arial, sans-serif;
        }
        .qr-section img {
            width: 52px;
            height: 52px;
            vertical-align: middle;
        }
        .qr-text {
            display: inline-block;
            vertical-align: middle;
            margin-left: 6px;
            font-size: 8pt;
            color: #4b5563;
            max-width: 220px;
        }
    </style>
</head>
<body>

    <!-- ========================================================= -->
    <!-- LEMBAR 1: SURAT DISPENSASI UTAMA                          -->
    <!-- ========================================================= -->

    <!-- Kop Surat Sekolah -->
    <div class="kop-container {{ !empty($letterheadImageBase64) ? 'kop-container-full' : '' }}">
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
            <p style="margin: 0 0 6px 0;">
                Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {{ $school->name }}, memberikan izin dan dispensasi KBM kepada peserta didik berikut:
                <strong style="text-decoration: underline;">(nama-nama terlampir)</strong>
            </p>
        @else
            @php $singleStudent = $students->first(); @endphp
            <p style="margin: 0 0 6px 0;">
                Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {{ $school->name }}, memberikan izin dan dispensasi KBM kepada peserta didik berikut:
            </p>

            <!-- Details Single Student Langsung di Halaman Utama -->
            <table class="info-table" style="margin: 4px 0 8px 0; background-color: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px;">
                <tr>
                    <td class="label" style="width: 140px; padding: 3px 8px;">Nama Peserta Didik</td>
                    <td style="width: 10px; padding: 3px 0;">:</td>
                    <td style="font-weight: bold; text-transform: uppercase; padding: 3px 8px;">{{ $singleStudent->full_name ?? '-' }}</td>
                </tr>
                <tr>
                    <td class="label" style="padding: 3px 8px;">Kelas</td>
                    <td style="padding: 3px 0;">:</td>
                    <td style="font-weight: bold; padding: 3px 8px;">{{ $singleStudent->class_name ?? '-' }}</td>
                </tr>
                <tr>
                    <td class="label" style="padding: 3px 8px;">NIS / NISN</td>
                    <td style="padding: 3px 0;">:</td>
                    <td style="padding: 3px 8px; font-family: Arial, sans-serif;">{{ $singleStudent->nis ?? '-' }} / {{ $singleStudent->nisn ?? '-' }}</td>
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
                    {{ \Carbon\Carbon::parse($dispensation->start_date)->locale('id')->translatedFormat('l, d F Y') }}
                    @if($dispensation->start_date != $dispensation->end_date)
                        s.d. {{ \Carbon\Carbon::parse($dispensation->end_date)->locale('id')->translatedFormat('l, d F Y') }}
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

    <!-- Tanda Tangan Resmi Sesuai Ketentuan (Guru Pembina/PJ Lomba & Wali Kelas di atas, Waka Kesiswaan di bawah) -->
    <!-- Baris 1: Guru PJ Lomba (Kiri) & Wali Kelas / Guru Mapel (Kanan) -->
    <table class="signatures-table" style="margin-top: 15px;">
        <tr>
            <!-- Tanda Tangan 1: Guru PJ Lomba / Pembina -->
            <td style="width: 50%; vertical-align: top; text-align: center;">
                <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                    {{ $school->city ?? 'Jombang' }}, {{ \Carbon\Carbon::parse($dispensation->approved_at ?? now())->locale('id')->translatedFormat('d F Y') }}
                </div>
                <div class="signature-title">
                    {{ $pjSigner->position_title ?? 'Guru PJ Lomba / Pembina' }}
                </div>

                @if(!empty($pjQrDataUri))
                    <div style="margin: 4px 0;">
                        <img src="{{ $pjQrDataUri }}" style="width: 58px; height: 58px;" alt="TTD QR PJ Lomba" />
                        <div style="font-size: 7.5pt; color: #4b5563; font-style: italic;">(TTD Digital QR Code)</div>
                    </div>
                @else
                    <div style="height: 45px;"></div>
                @endif

                <div class="signature-name" style="{{ !empty($pjQrDataUri) ? 'margin-top: 2px;' : 'margin-top: 10px;' }}">
                    {{ !empty($pjSigner->name) ? $pjSigner->name : ($dispensation->supervisor_name ?: 'Pembina Lomba Prestasi') }}
                </div>
                @if(!empty($pjSigner->nip))
                    <div class="signature-nip">
                        NIP. {{ $pjSigner->nip }}
                    </div>
                @endif
            </td>

            <!-- Tanda Tangan 2: Wali Kelas / Guru Mata Pelajaran -->
            <td style="width: 50%; vertical-align: top; text-align: center;">
                <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                    Menyetujui / Memaklumi,
                </div>
                <div class="signature-title">
                    Wali Kelas / Guru Mata Pelajaran
                </div>

                <div style="margin-top: 35px; margin-bottom: 6px;">
                    <span style="font-weight: bold; font-size: 9.5pt;">( .................................................... )</span>
                </div>
                <div class="signature-note">
                    *(Ditandatangani saat jam KBM di kelas)*
                </div>
            </td>
        </tr>
    </table>

    <!-- Baris 2: Waka Kesiswaan (Di Bawah, Tengah) -->
    <table class="signatures-table" style="margin-top: 15px;">
        <tr>
            <td style="width: 100%; text-align: center;">
                <div style="font-size: 9.5pt; color: #374151; margin-bottom: 2px;">
                    Mengetahui / Menyetujui,
                </div>
                <div class="signature-title">
                    {{ !empty($wakaSigner->position_title) ? $wakaSigner->position_title : 'Waka Kesiswaan' }}
                </div>

                @if(!empty($wakaQrDataUri))
                    <div style="margin: 4px 0;">
                        <img src="{{ $wakaQrDataUri }}" style="width: 58px; height: 58px;" alt="TTD QR Waka Kesiswaan" />
                        <div style="font-size: 7.5pt; color: #4b5563; font-style: italic;">(TTD Digital QR Code)</div>
                    </div>
                @else
                    <div style="height: 45px;"></div>
                @endif

                <div class="signature-name" style="{{ !empty($wakaQrDataUri) ? 'margin-top: 2px;' : 'margin-top: 10px;' }}">
                    {{ !empty($wakaSigner->name) ? $wakaSigner->name : ($letterConfig['waka_kesiswaan_name'] ?? ($dispensation->approvedBy->name ?? 'Drs. H. Abdul Haris')) }}
                </div>
                @if(!empty($wakaSigner->nip))
                    <div class="signature-nip">
                        NIP. {{ $wakaSigner->nip }}
                    </div>
                @elseif(!empty($letterConfig['waka_kesiswaan_nip']))
                    <div class="signature-nip">
                        NIP. {{ $letterConfig['waka_kesiswaan_nip'] }}
                    </div>
                @endif
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
