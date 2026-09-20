<?php

namespace Database\Seeders;

use App\Models\CompetitionCategory;
use Illuminate\Database\Seeder;

class CompetitionCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Sains & Matematika',
                'slug' => 'sains-dan-matematika',
                'description' => 'Kompetisi bidang sains, fisika, kimia, biologi, astronomi, dan matematika.',
                'icon' => 'atom',
            ],
            [
                'name' => 'Riset & Karya Ilmiah',
                'slug' => 'riset-dan-karya-ilmiah',
                'description' => 'Lomba karya tulis ilmiah, inovasi teknologi terapan, dan penelitian pelajar.',
                'icon' => 'microscope',
            ],
            [
                'name' => 'Teknologi & Robotika',
                'slug' => 'teknologi-dan-robotika',
                'description' => 'Kompetisi pemrograman, AI, robotika, web development, dan cyber security.',
                'icon' => 'cpu',
            ],
            [
                'name' => 'Seni & Budaya',
                'slug' => 'seni-dan-budaya',
                'description' => 'Festival lomba seni vokal, tari tradisional, musik, lukis, kriya, dan sinematografi.',
                'icon' => 'palette',
            ],
            [
                'name' => 'Olahraga & Kebugaran',
                'slug' => 'olahraga-dan-kebugaran',
                'description' => 'Olimpiade olahraga siswa nasional seperti atletik, renang, catur, dan pencak silat.',
                'icon' => 'trophy',
            ],
            [
                'name' => 'Bahasa & Literasi',
                'slug' => 'bahasa-dan-literasi',
                'description' => 'Debat bahasa Inggris/Indonesia, pidato, cipta puisi, dan penulisan kreatif.',
                'icon' => 'book-open',
            ],
        ];

        foreach ($categories as $cat) {
            CompetitionCategory::firstOrCreate(['slug' => $cat['slug']], $cat);
        }
    }
}
