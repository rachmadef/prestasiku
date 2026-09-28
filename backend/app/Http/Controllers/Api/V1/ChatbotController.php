<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\CompetitionCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    /**
     * Handle incoming chat requests for Prestasiku AI Chatbot.
     */
    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:1000',
            'history' => 'nullable|array',
            'history.*.role' => 'required|in:user,model',
            'history.*.parts' => 'required|array',
        ]);

        $apiKey = config('services.gemini.api_key');

        if (empty($apiKey)) {
            return response()->json([
                'success' => false,
                'message' => 'API Key Gemini belum dikonfigurasi di server.',
            ], 500);
        }

        $userMessage = trim($request->input('message'));
        $history = $request->input('history', []);

        // Realtime context summary from Prestasiku database
        $contextData = $this->getWebsiteContextData();

        $systemInstructionText = <<<EOT
Kamu adalah "Prestasiku Assistant", asisten AI ramah dan cerdas untuk platform website Prestasiku.

[TENTANG WEBSITE PRESTASIKU]:
Prestasiku adalah platform digital manajemen prestasi siswa, katalog dan kurasi kompetisi/lomba terpadu, pengajuan & verifikasi Surat Dispensasi Kegiatan Belajar Mengajar (KBM) berbasis QR Code, serta portofolio digital keikutsertaan lomba untuk sekolah modern.

[PANDUAN MENJAWAB PERTANYAAN]:
1. Bantu pengguna dengan ramah, komunikatif, solutif, dan jelas mengenai:
   - Pengenalan website Prestasiku, fungsi, dan manfaatnya.
   - Katalog kompetisi, kategori lomba, kurasi resmi negara/bergengsi, eligibilitas, serta filter status pendaftaran (Pendaftaran Sudah Dibuka, Pendaftaran Belum Dibuka, dan Lomba Sudah Terlaksana).
   - Alur pendaftaran perlombaan (perorangan maupun tim).
   - Pengajuan, persetujuan, dan pencetakan Surat Dispensasi KBM beserta verifikasi QR Code.
   - Pengunggahan sertifikat, pembentukan portofolio prestasi siswa, dan verifikasi sekolah.
   - Pendaftaran sekolah baru, manajemen akun siswa, serta fitur-fitur website.
   - Pertanyaan umum seputar perlombaan, persiapan lomba, pendidikan, dan pengembangan talenta siswa.

2. CATATAN PENTING KETERCAPAULAN (FLEXIBILITY):
   - Saran pertanyaan populer pada UI hanyalah contoh bantuan cepat untuk pengguna, BUKAN batasan topik.
   - Jawablah pertanyaan apa pun yang diajukan pengguna terkait aplikasi ini, fungsinya, fiturnya, atau perlombaan secara terbuka dan informatif.
   - Jika pengguna bertanya hal yang benar-benar tidak berhubungan sama sekali (misal resep masakan atau politik internasional), ingatkan dengan sopan bahwa fokus kamu adalah membantu seputar Prestasiku dan dunia kompetisi/prestasi siswa.

3. GAYA & KECEPATAN RESPONS:
   Gunakan Bahasa Indonesia yang sopan, jelas, ringkas, dan langsung menjawab ke inti pertanyaan.

[BERITA & UPDATE RESMI PUSPRESNAS KEMENDIKDASMEN 2026]:
- Olimpiade Sains Nasional (OSN 2026 SD/SMP/SMA): Telah resmi ditutup dan selesai dilaksanakan per 21 September 2026. Para pemenang medali telah diumumkan dan lanjut ke pembinaan Pelatnas menuju ajang internasional. Pendaftaran OSN 2026 di sistem telah diperbarui ke status "Lomba Sudah Terlaksana".

[DATA STATISTIK KONTEKS WEBSITE SAAT INI]:
{$contextData}
EOT;

        // Clean up history to ensure invalid or error messages are excluded
        $cleanHistory = [];
        foreach ($history as $chatItem) {
            $parts = $chatItem['parts'] ?? [];
            $text = $parts[0]['text'] ?? '';
            $role = $chatItem['role'] ?? 'user';

            // Filter out system error messages if present in history
            if (!empty($text) && !str_contains($text, 'Gagal mendapatkan tanggapan') && !str_contains($text, '⚠️')) {
                $cleanHistory[] = [
                    'role' => $role === 'model' ? 'model' : 'user',
                    'parts' => [
                        ['text' => $text]
                    ]
                ];
            }
        }

        $contents = array_merge($cleanHistory, [
            [
                'role' => 'user',
                'parts' => [
                    ['text' => $userMessage]
                ]
            ]
        ]);

        // Prioritize ultra-fast and reliable Gemini models
        $models = [
            'gemini-3.1-flash-lite',
            'gemini-3.6-flash',
            'gemini-flash-latest',
            'gemini-flash-lite-latest',
            'gemini-3.5-flash-lite',
            'gemini-3.8-flash',
        ];

        $payload = [
            'systemInstruction' => [
                'parts' => [
                    ['text' => $systemInstructionText]
                ]
            ],
            'contents' => $contents,
            'generationConfig' => [
                'temperature' => 0.5,
                'maxOutputTokens' => 450,
            ],
        ];

        $successfulResponse = null;
        $lastError = '';

        foreach ($models as $modelName) {
            $url = "https://generativelanguage.googleapis.com/v1beta/models/{$modelName}:generateContent?key={$apiKey}";

            // 1. Try Laravel Http Client first
            try {
                $response = Http::withOptions([
                    'verify' => false,
                    'timeout' => 10,
                ])->withHeaders([
                    'Content-Type' => 'application/json',
                ])->post($url, $payload);

                if ($response->successful()) {
                    $json = $response->json();
                    if (isset($json['candidates'][0]['content']['parts'][0]['text'])) {
                        $successfulResponse = $json;
                        break;
                    }
                }
            } catch (\Throwable $e) {
                Log::info("Gemini Http exception for {$modelName}: " . $e->getMessage());
            }

            // 2. Always try cURL fallback if Http client fails or is unsupported
            $curlResponse = $this->callGeminiViaCurl($url, $payload);
            if ($curlResponse && isset($curlResponse['candidates'][0]['content']['parts'][0]['text'])) {
                $successfulResponse = $curlResponse;
                break;
            }

            if (isset($curlResponse['error']['message'])) {
                $lastError = $curlResponse['error']['message'];
            }
        }

        if (!$successfulResponse) {
            Log::error('All Gemini API models failed. Last error: ' . $lastError);
            return response()->json([
                'success' => false,
                'message' => 'Gagal mendapatkan tanggapan dari Gemini AI.',
            ], 502);
        }

        $replyText = $successfulResponse['candidates'][0]['content']['parts'][0]['text'] ?? 'Maaf, tidak ada tanggapan yang dihasilkan.';

        return response()->json([
            'success' => true,
            'reply' => $replyText,
        ]);
    }

    /**
     * Fallback method using system curl.exe for maximum performance and compatibility.
     */
    private function callGeminiViaCurl(string $url, array $payload): ?array
    {
        try {
            $tempFile = sys_get_temp_dir() . '/gemini_payload_' . uniqid() . '.json';
            file_put_contents($tempFile, json_encode($payload));

            $cmd = 'curl.exe -s -k -X POST -H "Content-Type: application/json" --data-binary "@' . str_replace('\\', '/', $tempFile) . '" "' . $url . '"';
            $output = shell_exec($cmd);

            @unlink($tempFile);

            if (!empty($output)) {
                $json = json_decode($output, true);
                if (json_last_error() === JSON_ERROR_NONE) {
                    return $json;
                }
            }
        } catch (\Throwable $t) {
            Log::error('cURL fallback execution failed: ' . $t->getMessage());
        }

        return null;
    }

    /**
     * Dapatkan ringkasan konteks data publik dari database Prestasiku.
     */
    private function getWebsiteContextData(): string
    {
        try {
            $categoriesCount = CompetitionCategory::count();
            $competitionsCount = Competition::count();
            $recentCompetitions = Competition::select('title', 'level', 'registration_close')
                ->where('registration_close', '>=', now())
                ->latest()
                ->take(5)
                ->get();

            $competitionsListStr = '';
            if ($recentCompetitions->isNotEmpty()) {
                $competitionsListStr = "Beberapa kompetisi aktif yang sedang membuka pendaftaran:\n";
                foreach ($recentCompetitions as $comp) {
                    $deadline = $comp->registration_close ? $comp->registration_close->format('d M Y') : 'TBA';
                    $competitionsListStr .= "- {$comp->title} (Tingkat: {$comp->level}, Deadline: {$deadline})\n";
                }
            } else {
                $competitionsListStr = "Saat ini terdapat {$competitionsCount} kompetisi terdaftar di sistem.\n";
            }

            return "Jumlah Kategori Kompetisi: {$categoriesCount}\n" . $competitionsListStr;
        } catch (\Throwable $th) {
            return "Informasi umum platform Prestasiku.";
        }
    }
}
