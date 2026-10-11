@php \Carbon\Carbon::setLocale('id'); @endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Form Pendamping & Tanda Terima Honorarium - {{ $supervisor->supervisor_name }}</title>
    <style>
        @page {
            size: A4 portrait;
            margin: 0.6cm 1.4cm 1.0cm 1.4cm;
        }
        body {
            font-family: 'Times New Roman', Times, serif;
            color: #111827;
            font-size: 11pt;
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
            margin-bottom: 12px;
        }
        .doc-title {
            font-size: 13pt;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }
        .doc-subtitle {
            font-size: 11pt;
            font-weight: bold;
            text-transform: uppercase;
            margin: 2px 0 0 0;
        }
        .doc-ref {
            font-size: 9.5pt;
            font-family: Arial, sans-serif;
            margin-top: 3px;
            color: #4b5563;
        }
        .section-header {
            font-size: 11pt;
            font-weight: bold;
            margin-top: 10px;
            margin-bottom: 4px;
            text-transform: uppercase;
            background-color: #f3f4f6;
            padding: 2px 6px;
            border-left: 4px solid #1e3a8a;
        }
        .form-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 8px;
            font-size: 10.5pt;
        }
        .form-table td {
            padding: 3px 4px;
            vertical-align: top;
        }
        .form-table td.label {
            width: 200px;
            font-weight: 500;
        }
        .form-table td.colon {
            width: 15px;
            text-align: center;
        }
        .form-table td.value {
            font-weight: 600;
        }
        .grid-table {
            width: 100%;
            border-collapse: collapse;
            margin: 6px 0 10px 0;
            font-size: 10pt;
        }
        .grid-table th, .grid-table td {
            border: 1px solid #374151;
            padding: 4px 8px;
        }
        .grid-table th {
            background-color: #f3f4f6;
            font-weight: bold;
            text-align: left;
        }
        .check-box {
            display: inline-block;
            font-family: Arial, sans-serif;
            margin-right: 10px;
            font-size: 10pt;
        }
        .check-box-checked {
            font-weight: bold;
            color: #1e3a8a;
        }
        .check-mark {
            font-family: 'DejaVu Sans', sans-serif;
            font-weight: bold;
            color: #1e3a8a;
        }
        .statement-box {
            border: 1px solid #cbd5e1;
            background-color: #f8fafc;
            padding: 8px 12px;
            margin: 8px 0;
            font-size: 10pt;
            border-radius: 4px;
            text-align: justify;
        }
        .statement-box ol {
            margin: 4px 0 0 18px;
            padding: 0;
        }
        .statement-box li {
            margin-bottom: 2px;
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
            font-size: 10.5pt;
        }
        .sig-name {
            font-weight: bold;
            text-decoration: underline;
        }
        .sig-nip {
            font-size: 9.5pt;
            margin-top: 2px;
        }
        .honorarium-card {
            border: 1.5px solid #1e3a8a;
            border-radius: 6px;
            padding: 12px 16px;
            margin: 12px 0;
            background-color: #f8fafc;
        }
        .honorarium-option {
            padding: 4px 0;
            font-size: 10.5pt;
        }
        .honorarium-highlight {
            font-weight: bold;
            color: #065f46;
        }
    </style>
</head>
<body>

    <!-- ============================================================= -->
    <!-- DOKUMEN 1: FORM PENDAMPING PERLOMBAAN -->
    <!-- ============================================================= -->
    <div class="kop-container {{ !empty($letterheadImageBase64) ? 'kop-container-full' : '' }}">
        @if (!empty($letterheadImageBase64))
            <img src="{{ $letterheadImageBase64 }}" alt="Kop Surat" class="kop-image" />
        @else
            <p class="kop-text-gov">{{ $letterConfig['institution_level1'] ?? 'PEMERINTAH PROVINSI' }}</p>
            <p class="kop-text-agency">{{ $letterConfig['institution_level2'] ?? 'DINAS PENDIDIKAN DAN KEBUDAYAAN' }}</p>
            <p class="kop-text-school">{{ $school->name ?? 'MA UNGGULAN K.H. ABD. WAHAB HASBULLOH' }}</p>
            <p class="kop-text-meta">
                {{ $school->address ?? 'Tambakberas Jombang' }} &bull; NPSN: {{ $school->npsn ?? '20579998' }}
                @if(!empty($school->phone)) &bull; Telp: {{ $school->phone }} @endif
                @if(!empty($school->email)) &bull; Email: {{ $school->email }} @endif
            </p>
            <div class="kop-line-thick"></div>
            <div class="kop-line-thin"></div>
        @endif
    </div>

    <div class="doc-title-container">
        <div class="doc-title">FORM PENDAMPING PERLOMBAAN</div>
        <div class="doc-ref">No. Register: {{ $supervisor->reference_number }}</div>
    </div>

    <!-- A. DATA PERLOMBAAN -->
    <div class="section-header">A. DATA PERLOMBAAN</div>
    <table class="form-table">
        <tr>
            <td class="label">Nama Penyelenggara / Lomba</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->competition_name ?: ($supervisor->competition->title ?? '-') }}</td>
        </tr>
        <tr>
            <td class="label">Cabang Lomba yang Diikuti</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->competition_branch ?: '-' }}</td>
        </tr>
        <tr>
            <td class="label">Nama Peserta / Tim Didampingi</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->student_names ?: '-' }}</td>
        </tr>
        <tr>
            <td class="label">Kategori Lomba</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->competition_category ?: 'SMA / MA' }}</td>
        </tr>
        <tr>
            <td class="label">Tempat Perlombaan</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->competition_place ?: '-' }}</td>
        </tr>
        <tr>
            <td class="label">Tingkat Perlombaan</td>
            <td class="colon">:</td>
            <td class="value">
                @php $lvl = strtolower($supervisor->competition_level ?: ($supervisor->competition->level ?? '')); @endphp
                <span class="check-box {{ $lvl === 'kabupaten' ? 'check-box-checked' : '' }}">
                    [{!! $lvl === 'kabupaten' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Kabupaten/Kota
                </span>
                <span class="check-box {{ $lvl === 'provinsi' ? 'check-box-checked' : '' }}">
                    [{!! $lvl === 'provinsi' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Provinsi
                </span>
                <span class="check-box {{ $lvl === 'nasional' ? 'check-box-checked' : '' }}">
                    [{!! $lvl === 'nasional' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Nasional
                </span>
                <span class="check-box {{ $lvl === 'internasional' ? 'check-box-checked' : '' }}">
                    [{!! $lvl === 'internasional' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Internasional
                </span>
            </td>
        </tr>
    </table>

    <!-- B. DATA DIRI PENDAMPING -->
    <div class="section-header">B. DATA DIRI PENDAMPING</div>
    <table class="grid-table">
        <thead>
            <tr>
                <th style="width: 30px; text-align: center;">No</th>
                <th style="width: 190px;">Informasi</th>
                <th>Isian Data</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="text-align: center; font-weight: bold;">1</td>
                <td>Nama Lengkap dan Gelar</td>
                <td style="font-weight: bold;">{{ $supervisor->supervisor_name }}</td>
            </tr>
            <tr>
                <td style="text-align: center; font-weight: bold;">2</td>
                <td>Kategori Pendamping</td>
                <td>
                    @php $cat = strtolower($supervisor->supervisor_category ?? 'guru'); @endphp
                    <span class="check-box {{ str_contains($cat, 'guru') ? 'check-box-checked' : '' }}">
                        [{!! str_contains($cat, 'guru') ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Guru
                    </span>
                    <span class="check-box {{ str_contains($cat, 'pelatih') ? 'check-box-checked' : '' }}">
                        [{!! str_contains($cat, 'pelatih') ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Pelatih
                    </span>
                    <span class="check-box {{ str_contains($cat, 'tenaga') || str_contains($cat, 'admin') ? 'check-box-checked' : '' }}">
                        [{!! str_contains($cat, 'tenaga') || str_contains($cat, 'admin') ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Tenaga Kependidikan
                    </span>
                    <br/>
                    <span class="check-box {{ str_contains($cat, 'pembimbing') ? 'check-box-checked' : '' }}">
                        [{!! str_contains($cat, 'pembimbing') ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Pembimbing Eksternal
                    </span>
                    <span class="check-box {{ str_contains($cat, 'koordinator') ? 'check-box-checked' : '' }}">
                        [{!! str_contains($cat, 'koordinator') ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Koordinator Prestasi
                    </span>
                </td>
            </tr>
            <tr>
                <td style="text-align: center; font-weight: bold;">3</td>
                <td>Jabatan / Mata Pelajaran / Unit</td>
                <td>{{ $supervisor->role_title }}</td>
            </tr>
            <tr>
                <td style="text-align: center; font-weight: bold;">4</td>
                <td>Jenis Kelamin</td>
                <td>
                    @php $gen = strtolower($supervisor->supervisor_gender ?? ''); @endphp
                    <span class="check-box {{ $gen === 'laki-laki' || $gen === 'l' ? 'check-box-checked' : '' }}">
                        [{!! $gen === 'laki-laki' || $gen === 'l' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Laki-laki
                    </span>
                    <span class="check-box {{ $gen === 'perempuan' || $gen === 'p' ? 'check-box-checked' : '' }}">
                        [{!! $gen === 'perempuan' || $gen === 'p' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] Perempuan
                    </span>
                </td>
            </tr>
            <tr>
                <td style="text-align: center; font-weight: bold;">5</td>
                <td>Nomor WhatsApp / HP (Aktif)</td>
                <td>{{ $supervisor->supervisor_phone ?: '-' }}</td>
            </tr>
            @if($supervisor->supervisor_nip)
            <tr>
                <td style="text-align: center; font-weight: bold;">6</td>
                <td>NIP / NIK</td>
                <td>{{ $supervisor->supervisor_nip }}</td>
            </tr>
            @endif
        </tbody>
    </table>

    <!-- C. PERNYATAAN DAN PERSETUJUAN -->
    <div class="section-header">C. PERNYATAAN DAN PERSETUJUAN</div>
    <div class="statement-box">
        <strong>Dengan mengisi formulir ini, saya menyatakan bahwa:</strong>
        <ol>
            <li>Data yang saya isikan di atas adalah benar dan dapat dipertanggungjawabkan.</li>
            <li>Saya ditugaskan secara resmi oleh sekolah/instansi/lembaga sebagai pendamping peserta perlombaan.</li>
            <li>Saya bersedia mendampingi peserta, serta mematuhi seluruh tata tertib dan regulasi perlombaan yang ditetapkan panitia.</li>
        </ol>
    </div>

    <!-- Tanda Tangan Formulir -->
    <table class="signatures-table">
        <tr>
            <td style="width: 50%;"></td>
            <td style="width: 50%;">
                Jombang, {{ \Carbon\Carbon::parse($supervisor->created_at)->translatedFormat('d F Y') }}<br/>
                Pendamping Perlombaan,<br/>
                <br/><br/><br/>
                <div class="sig-name">{{ $supervisor->supervisor_name }}</div>
                @if($supervisor->supervisor_nip)
                    <div class="sig-nip">NIP: {{ $supervisor->supervisor_nip }}</div>
                @endif
            </td>
        </tr>
    </table>


    <!-- ============================================================= -->
    <!-- DOKUMEN 2: TANDA TERIMA HONORARIUM PENDAMPING PERLOMBAAN -->
    <!-- ============================================================= -->
    <div class="page-break"></div>

    <div class="kop-container {{ !empty($letterheadImageBase64) ? 'kop-container-full' : '' }}">
        @if (!empty($letterheadImageBase64))
            <img src="{{ $letterheadImageBase64 }}" alt="Kop Surat" class="kop-image" />
        @else
            <p class="kop-text-gov">{{ $letterConfig['institution_level1'] ?? 'PEMERINTAH PROVINSI' }}</p>
            <p class="kop-text-agency">{{ $letterConfig['institution_level2'] ?? 'DINAS PENDIDIKAN DAN KEBUDAYAAN' }}</p>
            <p class="kop-text-school">{{ $school->name ?? 'MA UNGGULAN K.H. ABD. WAHAB HASBULLOH' }}</p>
            <p class="kop-text-meta">
                {{ $school->address ?? 'Tambakberas Jombang' }} &bull; NPSN: {{ $school->npsn ?? '20579998' }}
                @if(!empty($school->phone)) &bull; Telp: {{ $school->phone }} @endif
                @if(!empty($school->email)) &bull; Email: {{ $school->email }} @endif
            </p>
            <div class="kop-line-thick"></div>
            <div class="kop-line-thin"></div>
        @endif
    </div>

    <div class="doc-title-container">
        <div class="doc-title">FORM TANDA TERIMA HONORARIUM PENDAMPING PERLOMBAAN</div>
        <div class="doc-ref">No. Register: {{ $supervisor->reference_number }}</div>
    </div>

    <table class="form-table" style="margin-top: 15px;">
        <tr>
            <td class="label" style="width: 220px;">Nama Pendamping Perlombaan</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->supervisor_name }}</td>
        </tr>
        <tr>
            <td class="label">Nama Penyelenggara / Lomba</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->competition_name ?: ($supervisor->competition->title ?? '-') }}</td>
        </tr>
        <tr>
            <td class="label">Cabang & Tingkat Lomba</td>
            <td class="colon">:</td>
            <td class="value">{{ $supervisor->competition_branch ?: '-' }} &bull; Tingkat {{ ucfirst($supervisor->competition_level ?: ($supervisor->competition->level ?? '-')) }}</td>
        </tr>
    </table>

    <div class="section-header" style="margin-top: 15px;">KATEGORI WILAYAH TUGAS & STANDAR HONORARIUM</div>
    <div class="honorarium-card">
        @php $zone = strtolower($supervisor->duty_zone ?? 'dalam_kota'); @endphp
        <div class="honorarium-option {{ $zone === 'dalam_kota' ? 'honorarium-highlight' : '' }}">
            <span class="check-box {{ $zone === 'dalam_kota' ? 'check-box-checked' : '' }}">
                [{!! $zone === 'dalam_kota' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] <strong>Dalam Kota</strong> : Rp 50.000
            </span>
        </div>
        <div class="honorarium-option {{ $zone === 'luar_kota' ? 'honorarium-highlight' : '' }}">
            <span class="check-box {{ $zone === 'luar_kota' ? 'check-box-checked' : '' }}">
                [{!! $zone === 'luar_kota' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] <strong>Luar Kota</strong> : Rp 100.000
            </span>
        </div>
        <div class="honorarium-option {{ $zone === 'luar_provinsi' ? 'honorarium-highlight' : '' }}">
            <span class="check-box {{ $zone === 'luar_provinsi' ? 'check-box-checked' : '' }}">
                [{!! $zone === 'luar_provinsi' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] <strong>Luar Provinsi</strong> : Rp 150.000
            </span>
        </div>
        <div class="honorarium-option {{ $zone === 'luar_negeri' ? 'honorarium-highlight' : '' }}">
            <span class="check-box {{ $zone === 'luar_negeri' ? 'check-box-checked' : '' }}">
                [{!! $zone === 'luar_negeri' ? '<span class="check-mark">&#10003;</span>' : '&nbsp;&nbsp;' !!}] <strong>Luar Negeri</strong> : Rp 200.000
            </span>
        </div>

        <div style="margin-top: 10px; padding-top: 8px; border-top: 1px dashed #94a3b8; font-size: 11pt;">
            Nominal Bisyaroh Disetujui: <strong style="color: #065f46; font-size: 12pt;">Rp {{ number_format($supervisor->bisyaroh_amount, 0, ',', '.') }}</strong>
            @if($supervisor->sop_category)
                <span style="color: #64748b; font-size: 9.5pt;">({{ $supervisor->sop_category }})</span>
            @endif
        </div>
        @if($supervisor->notes)
        <div style="margin-top: 4px; font-size: 9.5pt; color: #475569;">
            Catatan: {{ $supervisor->notes }}
        </div>
        @endif
    </div>

    <!-- Tanda Tangan Tanda Terima Honorarium -->
    <table class="signatures-table" style="margin-top: 30px;">
        <tr>
            <td style="width: 50%;">
                Yang Menerima,<br/>
                Pendamping Perlombaan<br/>
                <br/><br/><br/>
                <div class="sig-name">{{ $supervisor->supervisor_name }}</div>
                @if($supervisor->supervisor_nip)
                    <div class="sig-nip">NIP: {{ $supervisor->supervisor_nip }}</div>
                @endif
            </td>
            <td style="width: 50%;">
                Jombang, {{ \Carbon\Carbon::parse($supervisor->created_at)->translatedFormat('d F Y') }}<br/>
                Mengetahui,<br/>
                Koordinator Prestasi<br/>
                <br/><br/><br/>
                <div class="sig-name">Sariyanti, S.Pd.</div>
                <div class="sig-nip">NIP: -</div>
            </td>
        </tr>
    </table>

</body>
</html>
