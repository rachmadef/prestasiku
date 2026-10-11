<?php
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$sup = \App\Models\CompetitionSupervisor::latest()->first();
if ($sup) {
    $service = app(\App\Services\SupervisorDocumentService::class);
    $pdf = $service->generatePdf($sup);
    $outputPath = storage_path('app/test_sup_updated.pdf');
    file_put_contents($outputPath, $pdf->output());
    $content = file_get_contents($outputPath);
    preg_match_all('/\/Type\s*\/Page[^s]/', $content, $matches);
    echo "SUCCESS: " . filesize($outputPath) . " bytes\n";
    echo "Page count: " . count($matches[0]) . "\n";
} else {
    echo "No supervisor found\n";
}
