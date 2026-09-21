<?php

namespace Tests\Feature;

use App\Models\Competition;
use App\Models\CompetitionForm;
use App\Models\KbmDispensation;
use App\Models\Registration;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class KbmDispensationAndArchiveTest extends TestCase
{
    use RefreshDatabase;

    protected School $school;
    protected User $schoolAdminUser;
    protected User $studentUser;
    protected Student $student;
    protected Competition $competition;
    protected CompetitionForm $form;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $this->school = School::create([
            'npsn' => '10203040',
            'name' => 'SMA Negeri 1 Prestasi',
            'educational_level' => 'slta',
            'status' => 'verified',
            'province' => 'DKI Jakarta',
            'city' => 'Jakarta Selatan',
            'district' => 'Setiabudi',
            'address' => 'Jl. Pendidikan No. 10',
            'phone' => '021-5551234',
            'email' => 'info@sman1prestasi.sch.id',
        ]);

        $this->schoolAdminUser = User::create([
            'name' => 'Admin Sekolah',
            'email' => 'admin@sman1prestasi.sch.id',
            'username' => 'adminsma1',
            'password' => bcrypt('password'),
            'status' => 'active',
            'school_id' => $this->school->id,
            'must_change_password' => false,
        ]);
        $this->schoolAdminUser->assignRole('school_admin');

        $this->studentUser = User::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@siswa.sman1prestasi.sch.id',
            'username' => 'budi10293',
            'password' => bcrypt('password'),
            'status' => 'active',
            'school_id' => $this->school->id,
            'must_change_password' => false,
        ]);
        $this->studentUser->assignRole('student');

        $this->student = Student::create([
            'user_id' => $this->studentUser->id,
            'school_id' => $this->school->id,
            'nis' => '10293',
            'nisn' => '0051234567',
            'full_name' => 'Budi Santoso',
            'grade_level' => 11,
            'class_name' => 'XI MIPA 1',
            'gender' => 'L',
            'birth_date' => '2008-05-10',
            'birth_place' => 'Jakarta',
            'status' => 'active',
        ]);

        $organizer = \App\Models\Organizer::create([
            'name' => 'Pusat Prestasi Nasional',
            'type' => 'kementerian',
            'verification_status' => 'official',
        ]);

        $category = \App\Models\CompetitionCategory::create([
            'name' => 'Sains & Teknologi',
            'slug' => 'sains-dan-teknologi',
        ]);

        $this->competition = Competition::create([
            'organizer_id' => $organizer->id,
            'category_id' => $category->id,
            'title' => 'Olimpiade Sains Nasional 2026',
            'slug' => 'olimpiade-sains-nasional-2026',
            'level' => 'nasional',
            'target_level' => 'slta',
            'description' => 'Kompetisi sains bergengsi tingkat nasional untuk pelajar SLTA.',
            'participation_type' => 'individual',
            'verification_status' => 'published',
            'registration_open_at' => now()->subDays(5),
            'registration_deadline' => now()->addDays(20),
            'event_start_at' => now()->addDays(25),
            'event_end_at' => now()->addDays(27),
            'published_at' => now()->subDays(5),
        ]);

        $this->form = CompetitionForm::create([
            'competition_id' => $this->competition->id,
            'version' => 1,
            'title' => 'Formulir OSN 2026',
            'is_active' => true,
        ]);
    }

    public function test_student_can_request_kbm_dispensation(): void
    {
        $response = $this->actingAs($this->studentUser, 'sanctum')->postJson('/api/v1/student/dispensations', [
            'competition_name' => 'Olimpiade Sains Nasional 2026',
            'dispensation_type' => 'persiapan_latihan',
            'purpose' => 'Bimbingan intensif persiapan semifinal di lab sekolah',
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDays(2)->toDateString(),
            'is_all_day' => true,
            'supervisor_name' => 'Drs. Supardi',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'pending',
                    'competition_name' => 'Olimpiade Sains Nasional 2026',
                ],
            ]);

        $this->assertDatabaseHas('kbm_dispensations', [
            'school_id' => $this->school->id,
            'requested_by' => $this->studentUser->id,
            'status' => 'pending',
        ]);
    }

    public function test_school_admin_can_approve_dispensation_and_get_print_letter(): void
    {
        $dispensation = KbmDispensation::create([
            'school_id' => $this->school->id,
            'competition_name' => 'Lomba Debat Bahasa Inggris',
            'dispensation_type' => 'pelaksanaan_lomba',
            'purpose' => 'Mengikuti babak penyisihan tingkat provinsi',
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDay()->toDateString(),
            'is_all_day' => true,
            'requested_by' => $this->studentUser->id,
            'status' => 'pending',
        ]);

        $dispensation->students()->sync([$this->student->id]);

        // School Admin reviews and approves
        $reviewRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->postJson("/api/v1/school/dispensations/{$dispensation->id}/review", [
                'action' => 'approve',
                'reference_number' => '421.3/DISP/SMAN1/2026/001',
            ]);

        $reviewRes->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'approved',
                    'reference_number' => '421.3/DISP/SMAN1/2026/001',
                ],
            ]);

        // Get print letter
        $printRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->getJson("/api/v1/school/dispensations/{$dispensation->id}/print-letter");

        $printRes->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'dispensation',
                    'school',
                    'students',
                    'qr_code_data_uri',
                    'verification_url',
                ],
            ]);
    }

    public function test_public_qr_verification_endpoint_for_teachers(): void
    {
        $dispensation = KbmDispensation::create([
            'school_id' => $this->school->id,
            'reference_number' => '421.3/DISP-KBM/2026/088',
            'competition_name' => 'Lomba Robotika Nasional',
            'dispensation_type' => 'persiapan_latihan',
            'purpose' => 'Perakitan modul sensor di ruang robotika',
            'start_date' => now()->toDateString(),
            'end_date' => now()->toDateString(),
            'is_all_day' => true,
            'status' => 'approved',
            'requested_by' => $this->schoolAdminUser->id,
            'approved_by' => $this->schoolAdminUser->id,
            'approved_at' => now(),
        ]);
        $dispensation->students()->sync([$this->student->id]);

        $verifyRes = $this->getJson("/api/v1/dispensations/verify/{$dispensation->verification_token}");

        $verifyRes->assertStatus(200)
            ->assertJson([
                'success' => true,
                'is_valid' => true,
                'data' => [
                    'school_name' => $this->school->name,
                    'reference_number' => '421.3/DISP-KBM/2026/088',
                    'competition_name' => 'Lomba Robotika Nasional',
                    'is_active_today' => true,
                ],
            ]);
    }

    public function test_recording_participant_outcome_and_checking_student_portfolio(): void
    {
        $registration = Registration::create([
            'competition_id' => $this->competition->id,
            'form_version_id' => $this->form->id,
            'school_id' => $this->school->id,
            'student_id' => $this->student->id,
            'registered_by' => $this->studentUser->id,
            'status' => 'approved_by_school',
            'school_approval_status' => 'approved',
        ]);

        // Record participant outcome (kalah/partisipan biasa tapi tetap terdokumentasi)
        $resultRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->postJson("/api/v1/school/registrations/{$registration->id}/result", [
                'result_status' => 'participant',
                'rank_details' => 'Peserta Babak Penyisihan',
                'result_notes' => 'Telah mewakili sekolah dengan sangat baik hingga babak penyisihan provinsi.',
            ]);

        $resultRes->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        // Student checks their comprehensive portfolio
        $portfolioRes = $this->actingAs($this->studentUser, 'sanctum')
            ->getJson('/api/v1/student/portfolio');

        $portfolioRes->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'stats' => [
                        'total_participations' => 1,
                        'total_participants' => 1,
                        'total_wins' => 0,
                    ],
                ],
            ]);
    }

    public function test_school_admin_can_manage_dispensation_form_schema_and_create_with_custom_fields(): void
    {
        $schema = [
            [
                'id' => 'field_1',
                'name' => 'lokasi_karantina',
                'label' => 'Lokasi Karantina / Pelatihan',
                'type' => 'text',
                'placeholder' => 'Contoh: Lab Komputer 1',
                'description' => 'Ruang tempat siswa berlatih',
                'options' => [],
                'is_required' => true,
            ],
            [
                'id' => 'field_2',
                'name' => 'sumber_dana',
                'label' => 'Sumber Pembiayaan',
                'type' => 'select',
                'placeholder' => null,
                'description' => 'Alokasi anggaran',
                'options' => ['Dana BOS', 'Komite', 'Mandiri'],
                'is_required' => false,
            ],
        ];

        // 1. School Admin updates form schema
        $updateRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->putJson('/api/v1/school/dispensations/form-schema', [
                'schema' => $schema,
            ]);

        $updateRes->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'school_id' => $this->school->id,
                ],
            ]);

        // 2. School Admin retrieves form schema
        $getRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->getJson('/api/v1/school/dispensations/form-schema');

        $getRes->assertStatus(200)
            ->assertJsonCount(2, 'data.schema')
            ->assertJsonPath('data.schema.0.name', 'lokasi_karantina');

        // 3. Student can also retrieve school's form schema
        $studentGetRes = $this->actingAs($this->studentUser, 'sanctum')
            ->getJson('/api/v1/student/dispensations/form-schema');

        $studentGetRes->assertStatus(200)
            ->assertJsonPath('data.schema.0.name', 'lokasi_karantina');

        // 4. School Admin creates dispensation with custom_fields_data
        $createRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->postJson('/api/v1/school/dispensations', [
                'competition_name' => 'Olimpiade Sains Terapan 2026',
                'dispensation_type' => 'persiapan_latihan',
                'purpose' => 'Persiapan intensif materi olimpiade',
                'start_date' => now()->addDays(1)->format('Y-m-d'),
                'end_date' => now()->addDays(3)->format('Y-m-d'),
                'is_all_day' => true,
                'supervisor_name' => 'Dra. Hj. Siti Aminah, M.Pd.',
                'student_ids' => [$this->student->id],
                'custom_fields_data' => [
                    'lokasi_karantina' => 'Laboratorium Multimedia Lantai 2',
                    'sumber_dana' => 'Dana BOS',
                ],
            ]);

        $createRes->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'custom_fields_data' => [
                        'lokasi_karantina' => 'Laboratorium Multimedia Lantai 2',
                        'sumber_dana' => 'Dana BOS',
                    ],
                ],
            ]);

        $dispId = $createRes->json('data.id');

        // 5. Printable letter includes form schema and custom fields
        $printRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->getJson("/api/v1/school/dispensations/{$dispId}/print-letter");

        $printRes->assertStatus(200)
            ->assertJsonPath('data.custom_fields_data.lokasi_karantina', 'Laboratorium Multimedia Lantai 2')
            ->assertJsonPath('data.form_schema.0.name', 'lokasi_karantina');
    }

    public function test_school_can_manage_letterhead_and_export_docx_and_pdf_with_dual_signatures(): void
    {
        \Illuminate\Support\Facades\Storage::fake('public');

        // 1. Get initial letter template config
        $getRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->getJson('/api/v1/school/dispensations/letter-template');

        $getRes->assertStatus(200)
            ->assertJsonPath('data.letterhead_type', 'text');

        // 2. Upload letterhead image & configure custom letter details
        $fakeImage = \Illuminate\Http\UploadedFile::fake()->image('kop_surat_sman1.png', 800, 200);

        $updateRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->postJson('/api/v1/school/dispensations/letter-template', [
                'letterhead_type' => 'image',
                'letterhead_image' => $fakeImage,
                'institution_level1' => 'PEMERINTAH PROVINSI JAWA BARAT',
                'institution_level2' => 'DINAS PENDIDIKAN WILAYAH III',
                'document_title' => 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)',
            ]);

        $updateRes->assertStatus(200)
            ->assertJsonPath('data.letterhead_type', 'image')
            ->assertJsonPath('data.letter_format_config.institution_level1', 'PEMERINTAH PROVINSI JAWA BARAT');

        $this->school->refresh();
        $this->assertNotNull($this->school->letterhead_image_path);
        \Illuminate\Support\Facades\Storage::disk('public')->assertExists($this->school->letterhead_image_path);

        // 3. Create approved dispensation with supervisor name
        $disp = KbmDispensation::create([
            'school_id' => $this->school->id,
            'competition_name' => 'Lomba Karya Ilmiah Pelajar 2026',
            'dispensation_type' => 'persiapan_latihan',
            'purpose' => 'Uji coba instrumen penelitian',
            'start_date' => now()->format('Y-m-d'),
            'end_date' => now()->addDays(2)->format('Y-m-d'),
            'is_all_day' => true,
            'supervisor_name' => 'Dr. H. Mulyadi, S.Si., M.Pd.',
            'status' => 'approved',
            'reference_number' => '421.3/001/DISP/2026',
            'requested_by' => $this->schoolAdminUser->id,
            'approved_by' => $this->schoolAdminUser->id,
            'approved_at' => now(),
        ]);
        $disp->students()->attach($this->student->id);

        // 4. Verify printLetter contains the 2 signatures structure:
        // Signature 1: Guru Pembina Lomba (filled with supervisor_name)
        // Signature 2: Guru Mapel / Guru Piket (blank for wet signature in class)
        $printRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->getJson("/api/v1/school/dispensations/{$disp->id}/print-letter");

        $printRes->assertStatus(200)
            ->assertJsonPath('data.signatures.pembina.name', 'Dr. H. Mulyadi, S.Si., M.Pd.')
            ->assertJsonPath('data.signatures.mapel.name', '( .................................................. )')
            ->assertJsonPath('data.letterhead_type', 'image');

        // 5. Test School Admin downloading DOCX
        $docxRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->get("/api/v1/school/dispensations/{$disp->id}/download-docx");

        $docxRes->assertStatus(200);
        $this->assertStringContainsString('wordprocessingml.document', $docxRes->headers->get('content-type'));

        // 6. Test School Admin downloading PDF
        $pdfRes = $this->actingAs($this->schoolAdminUser, 'sanctum')
            ->get("/api/v1/school/dispensations/{$disp->id}/download-pdf");

        $pdfRes->assertStatus(200);
        $this->assertStringContainsString('application/pdf', $pdfRes->headers->get('content-type'));

        // 7. Test Student downloading approved DOCX & PDF
        $stdDocxRes = $this->actingAs($this->studentUser, 'sanctum')
            ->get("/api/v1/student/dispensations/{$disp->id}/download-docx");
        $stdDocxRes->assertStatus(200);

        $stdPdfRes = $this->actingAs($this->studentUser, 'sanctum')
            ->get("/api/v1/student/dispensations/{$disp->id}/download-pdf");
        $stdPdfRes->assertStatus(200);
    }
}

