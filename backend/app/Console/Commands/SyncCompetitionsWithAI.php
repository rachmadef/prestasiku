<?php

namespace App\Console\Commands;

use App\Models\Competition;
use App\Services\GeminiCompetitionVerifierService;
use Illuminate\Console\Command;

class SyncCompetitionsWithAI extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'competitions:sync-ai {--id= : ID spesifik kompetisi yang ingin di-sync}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Melakukan pencarian dan audit data lomba secara otomatis menggunakan Gemini AI Grounding';

    /**
     * Execute the console command.
     */
    public function handle(GeminiCompetitionVerifierService $verifier): int
    {
        $comp = $this->option('id');

        if ($comp) {
            $competitions = Competition::where('id', $comp)->get();
        } else {
            $competitions = Competition::all();
        }

        $this->info("Memulai verifikasi dan sinkronisasi AI untuk " . $competitions->count() . " data kompetisi...");

        $successCount = 0;

        foreach ($competitions as $c) {
            $this->output->write("Meng-audit [ID {$c->id}] {$c->title}... ");
            $res = $verifier->verifyAndUpdate($c);

            if ($res['success']) {
                $this->info("✔ SELSEAI (" . ($res['ai_summary'] ?? 'OK') . ")");
                $successCount++;
            } else {
                $this->error("✖ GAGAL: " . ($res['message'] ?? 'Error'));
            }
        }

        $this->info("Proses selesai! {$successCount} dari " . $competitions->count() . " kompetisi berhasil diverifikasi & diperbarui.");

        return Command::SUCCESS;
    }
}
