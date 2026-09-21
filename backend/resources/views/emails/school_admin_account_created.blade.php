<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Persetujuan Pendaftaran Sekolah & Detail Akun Admin</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f8fafc;
            margin: 0;
            padding: 0;
            color: #1e293b;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 30px auto;
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }
        .header {
            background-color: #001D60;
            padding: 32px 24px;
            text-align: center;
            color: #ffffff;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }
        .header p {
            margin: 6px 0 0 0;
            font-size: 12px;
            color: #93c5fd;
        }
        .badge-verified {
            display: inline-block;
            background-color: rgba(251, 191, 36, 0.2);
            color: #f59e0b;
            border: 1px solid rgba(251, 191, 36, 0.4);
            padding: 4px 12px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 700;
            margin-bottom: 12px;
            text-transform: uppercase;
        }
        .content {
            padding: 32px 24px;
        }
        .salutation {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 12px;
        }
        .credential-box {
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 12px;
            padding: 20px;
            margin: 24px 0;
        }
        .credential-title {
            font-size: 13px;
            font-weight: 800;
            color: #001D60;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 0;
            margin-bottom: 14px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 8px;
        }
        .credential-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 13px;
        }
        .credential-label {
            color: #64748b;
        }
        .credential-val {
            font-weight: 700;
            color: #0f172a;
            font-family: monospace;
        }
        .password-highlight {
            background-color: #fef3c7;
            border: 1px solid #fde68a;
            padding: 12px;
            border-radius: 8px;
            margin-top: 12px;
            text-align: center;
        }
        .password-highlight span {
            display: block;
            font-size: 11px;
            color: #92400e;
            font-weight: 600;
            text-transform: uppercase;
        }
        .password-highlight code {
            font-size: 18px;
            font-weight: 800;
            color: #78350f;
            letter-spacing: 1px;
        }
        .btn-login {
            display: block;
            width: 220px;
            margin: 24px auto;
            text-align: center;
            background-color: #001D60;
            color: #ffffff !important;
            padding: 12px 20px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            box-shadow: 0 2px 4px rgba(0, 29, 96, 0.2);
        }
        .info-card {
            background-color: #eff6ff;
            border-left: 4px solid #3b82f6;
            padding: 14px 16px;
            border-radius: 0 8px 8px 0;
            margin: 20px 0;
            font-size: 12px;
            color: #1e3a8a;
        }
        .footer {
            background-color: #f1f5f9;
            padding: 20px 24px;
            text-align: center;
            font-size: 11px;
            color: #64748b;
            border-top: 1px solid #e2e8f0;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <span class="badge-verified">Instansi Terverifikasi</span>
            <h1>PrestasiKu</h1>
            <p>Sistem Pengelolaan Prestasi Talenta & Perizinan Dispensasi Sekolah</p>
        </div>

        <!-- Content -->
        <div class="content">
            <p class="salutation">Yth. Bapak/Ibu {{ $registration->pic_name }},</p>
            
            <p style="font-size: 13px; color: #334155; margin-bottom: 16px;">
                Selamat! Pengajuan pendaftaran instansi <strong>{{ $school->name }}</strong> (NPSN: <strong>{{ $school->npsn }}</strong>) telah resmi <strong>DIVERIFIKASI dan DISETUJUI</strong> oleh Tim Super Administrator PrestasiKu.
            </p>

            <p style="font-size: 13px; color: #334155;">
                Akun Admin Sekolah resmi Anda telah diaktifkan dengan rincian kredensial akses sebagai berikut:
            </p>

            <!-- Credential Box -->
            <div class="credential-box">
                <div class="credential-title">Rincian Akun Admin Sekolah</div>
                
                <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                    <tr>
                        <td style="padding: 6px 0; color: #64748b; width: 40%;">Nama Sekolah:</td>
                        <td style="padding: 6px 0; font-weight: 700; color: #0f172a;">{{ $school->name }}</td>
                    </tr>
                    <tr>
                        <td style="padding: 6px 0; color: #64748b;">NPSN:</td>
                        <td style="padding: 6px 0; font-weight: 700; font-family: monospace; color: #0f172a;">{{ $school->npsn }}</td>
                    </tr>
                    <tr>
                        <td style="padding: 6px 0; color: #64748b;">Username Login:</td>
                        <td style="padding: 6px 0; font-weight: 700; font-family: monospace; color: #2563eb;">{{ $adminUser->username }}</td>
                    </tr>
                    <tr>
                        <td style="padding: 6px 0; color: #64748b;">Email Terdaftar:</td>
                        <td style="padding: 6px 0; font-weight: 700; color: #0f172a;">{{ $adminUser->email }}</td>
                    </tr>
                </table>

                <div class="password-highlight">
                    <span>Password Sementara (Bawaan Sistem):</span>
                    <code>{{ $temporaryPassword }}</code>
                </div>
            </div>

            <!-- Action Button -->
            <a href="{{ $loginUrl }}" class="btn-login" target="_blank">
                Masuk ke Portal Sekolah &rarr;
            </a>

            <!-- Info & Security Notice -->
            <div class="info-card">
                <strong>Pemberitahuan Keamanan:</strong><br>
                Demi keamanan data kesiswaan sekolah Anda, kami sangat menyarankan Anda untuk segera masuk ke portal dan <strong>mengubah password sementara</strong> ini melalui menu <em>Profil & Ganti Password</em> setelah berhasil login pertama kali.
            </div>

            <p style="font-size: 12px; color: #475569; margin-top: 20px;">
                <strong>Layanan yang kini dapat Anda akses di Dashboard Sekolah:</strong>
            </p>
            <ul style="font-size: 12px; color: #475569; padding-left: 20px; line-height: 1.8;">
                <li>Pendaftaran dan delegasi siswa ke kompetisi resmi Kemendikdasmen / Puspresnas & BPTI.</li>
                <li>Penerbitan Surat Dispensasi KBM resmi ber-QR Code untuk siswa delegasi lomba.</li>
                <li>Pencatatan dan arsip portofolio piagam prestasi juara siswa.</li>
            </ul>

            <p style="font-size: 12px; color: #64748b; margin-top: 24px;">
                Jika Anda memiliki kendala teknis atau pertanyaan, silakan hubungi tim dukungan kami melalui email <a href="mailto:support@prestasiku.id" style="color: #2563eb;">support@prestasiku.id</a>.
            </p>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p style="margin: 0;">&copy; {{ date('Y') }} PrestasiKu Portal. Hak Cipta Dilindungi.</p>
            <p style="margin: 4px 0 0 0;">Email ini dikirimkan secara otomatis dari sistem pendaftaran mandiri sekolah PrestasiKu.</p>
        </div>
    </div>
</body>
</html>
