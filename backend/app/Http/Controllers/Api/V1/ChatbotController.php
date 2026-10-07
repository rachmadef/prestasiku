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
            'history.*.role' => 'required|in:user,model,assistant',
            'history.*.parts' => 'nullable|array',
        ]);

        $groqApiKey = config('services.groq.api_key');
        $geminiApiKey = config('services.gemini.api_key');

        if (empty($groqApiKey) && empty($geminiApiKey)) {
            return response()->json([
                'success' => false,
                'message' => 'API Key AI (Groq / Gemini) belum dikonfigurasi di server.',
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
   - Pengajuan, persetujuan, dan pencetakan Surat Dispensasi KBM & Perizinan Lomba beserta verifikasi QR Code.
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

        // 1. Try Groq API first if key available
        if (!empty($groqApiKey)) {
            $groqReply = $this->callGroqApi($groqApiKey, $systemInstructionText, $history, $userMessage);
            if ($groqReply !== null) {
                return response()->json([
                    'success' => true,
                    'reply' => $groqReply,
                ]);
            }
            Log::warning('Groq API failed or returned empty response. Falling back to Gemini...');
        }

        // 2. Fallback to Gemini API if Groq fails or unavailable
        if (!empty($geminiApiKey)) {
            $geminiReply = $this->callGeminiApi($geminiApiKey, $systemInstructionText, $history, $userMessage);
            if ($geminiReply !== null) {
                return response()->json([
                    'success' => true,
                    'reply' => $geminiReply,
                ]);
            }
        }

        return response()->json([
            'success' => false,
            'message' => 'Gagal mendapatkan tanggapan dari AI Chatbot saat ini. Silakan coba beberapa saat lagi.',
        ], 502);
    }

    /**
     * Call Groq Cloud OpenAI-Compatible API using system cURL / Laravel Http
     */
    private function callGroqApi(string $apiKey, string $systemPrompt, array $rawHistory, string $userMessage): ?string
    {
        $messages = [
            ['role' => 'system', 'content' => $systemPrompt]
        ];

        foreach ($rawHistory as $chatItem) {
            $role = ($chatItem['role'] ?? 'user') === 'model' ? 'assistant' : 'user';
            $text = '';
            if (isset($chatItem['parts'][0]['text'])) {
                $text = $chatItem['parts'][0]['text'];
            } elseif (isset($chatItem['content'])) {
                $text = $chatItem['content'];
            }

            if (!empty($text) && !str_contains($text, 'Gagal mendapatkan tanggapan') && !str_contains($text, '⚠️')) {
                $messages[] = [
                    'role' => $role,
                    'content' => $text,
                ];
            }
        }

        $messages[] = [
            'role' => 'user',
            'content' => $userMessage,
        ];

        // Available models on this Groq key
        $models = [
            'openai/gpt-oss-120b',
            'qwen/qwen3.8-27b',
            'openai/gpt-oss-20b',
        ];

        foreach ($models as $model) {
            $payload = [
                'model' => $model,
                'messages' => $messages,
                'temperature' => 0.5,
                'max_tokens' => 500,
            ];

            // Primary: System curl.exe
            try {
                $tempFile = sys_get_temp_dir() . '/groq_req_' . uniqid() . '.json';
                file_put_contents($tempFile, json_encode($payload));

                $cmd = 'curl.exe -s -k -X POST -H "Authorization: Bearer ' . $apiKey . '" -H "Content-Type: application/json" --data-binary "@' . str_replace('\\', '/', $tempFile) . '" "https://api.groq.com/openai/v1/chat/completions"';
                $output = shell_exec($cmd);
                @unlink($tempFile);

                if (!empty($output)) {
                    $json = json_decode($output, true);
                    if (isset($json['choices'][0]['message']['content'])) {
                        return trim($json['choices'][0]['message']['content']);
                    }
                }
            } catch (\Throwable $e) {
                Log::error("Groq cURL error for {$model}: " . $e->getMessage());
            }

            // Secondary: Laravel Http client
            try {
                $response = Http::withOptions(['verify' => false, 'timeout' => 10])
                    ->withHeaders([
                        'Authorization' => 'Bearer ' . $apiKey,
                        'Content-Type' => 'application/json',
                    ])
                    ->post('https://api.groq.com/openai/v1/chat/completions', $payload);

                if ($response->successful()) {
                    $json = $response->json();
                    if (isset($json['choices'][0]['message']['content'])) {
                        return trim($json['choices'][0]['message']['content']);
                    }
                }
            } catch (\Throwable $t) {
                Log::error("Groq Http error for {$model}: " . $t->getMessage());
            }
        }

        return null;
    }

    /**
     * Fallback Gemini API call
     */
    private function callGeminiApi(string $apiKey, string $systemPrompt, array $rawHistory, string $userMessage): ?string
    {
        $cleanHistory = [];
        foreach ($rawHistory as $chatItem) {
            $text = $chatItem['parts'][0]['text'] ?? '';
            $role = ($chatItem['role'] ?? 'user') === 'model' ? 'model' : 'user';

            if (!empty($text) && !str_contains($text, 'Gagal mendapatkan tanggapan') && !str_contains($text, '⚠️')) {
                $cleanHistory[] = [
                    'role' => $role,
                    'parts' => [['text' => $text]]
                ];
            }
        }

        $contents = array_merge($cleanHistory, [
            ['role' => 'user', 'parts' => [['text' => $userMessage]]]
        ]);

        $models = [
            'gemini-3.1-flash-lite',
            'gemini-3.6-flash',
            'gemini-flash-latest',
        ];

        $payload = [
            'systemInstruction' => ['parts' => [['text' => $systemPrompt]]],
            'contents' => $contents,
            'generationConfig' => [
                'temperature' => 0.5,
                'maxOutputTokens' => 450,
            ],
        ];

        foreach ($models as $modelName) {
            $url = "https://generativelanguage.googleapis.com/v1beta/models/{$modelName}:generateContent?key={$apiKey}";
            try {
                $tempFile = sys_get_temp_dir() . '/gemini_req_' . uniqid() . '.json';
                file_put_contents($tempFile, json_encode($payload));

                $cmd = 'curl.exe -s -k -X POST -H "Content-Type: application/json" --data-binary "@' . str_replace('\\', '/', $tempFile) . '" "' . $url . '"';
                $output = shell_exec($cmd);
                @unlink($tempFile);

                if (!empty($output)) {
                    $json = json_decode($output, true);
                    if (isset($json['candidates'][0]['content']['parts'][0]['text'])) {
                        return trim($json['candidates'][0]['content']['parts'][0]['text']);
                    }
                }
            } catch (\Throwable $t) {
                Log::error("Gemini fallback error for {$modelName}: " . $t->getMessage());
            }
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
