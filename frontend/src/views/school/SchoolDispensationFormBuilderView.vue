<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import api from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const router = useRouter()
const { toast } = useNotify()

interface CustomField {
  id: string
  name: string
  label: string
  type: 'text' | 'textarea' | 'select' | 'number' | 'checkbox' | 'date'
  placeholder?: string
  description?: string
  options?: string[]
  is_required: boolean
}

const loading = ref(true)
const saving = ref(false)
const schoolName = ref('')
const schema = ref<CustomField[]>([])

// Field editing / new option buffer
const optionInputs = ref<Record<string, string>>({})

// Interactive preview testing state
const previewValues = ref<Record<string, any>>({})

async function fetchSchema() {
  loading.value = true
  try {
    const res = await api.get('/school/dispensations/form-schema')
    schoolName.value = res.data.data.school_name || 'Sekolah'
    schema.value = res.data.data.schema || []
    initPreviewValues()
  } catch (err: any) {
    toast.error('Gagal memuat pengaturan formulir sekolah.', 'Error')
  } finally {
    loading.value = false
  }
}

function initPreviewValues() {
  const vals: Record<string, any> = {}
  schema.value.forEach(f => {
    vals[f.name] = f.type === 'checkbox' ? false : ''
  })
  previewValues.value = vals
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '_')
    .replace(/^-+|-+$/g, '')
}

function addField(type: CustomField['type'] = 'text') {
  const count = schema.value.length + 1
  const defaultLabels: Record<CustomField['type'], string> = {
    text: `Kolom Teks ${count}`,
    textarea: `Catatan Tambahan ${count}`,
    select: `Pilihan Kategori ${count}`,
    number: `Jumlah / Nilai ${count}`,
    checkbox: `Persetujuan Khusus ${count}`,
    date: `Tanggal Khusus ${count}`,
  }

  const label = defaultLabels[type]
  const id = `field_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`
  const name = slugify(label) || `field_${count}`

  const newField: CustomField = {
    id,
    name,
    label,
    type,
    placeholder: type === 'select' ? undefined : 'Masukkan isian...',
    description: '',
    options: type === 'select' ? ['Pilihan A', 'Pilihan B'] : [],
    is_required: false,
  }

  schema.value.push(newField)
  previewValues.value[name] = type === 'checkbox' ? false : ''
}

function removeField(index: number) {
  schema.value.splice(index, 1)
}

function moveField(index: number, direction: 'up' | 'down') {
  if (direction === 'up' && index > 0) {
    const temp = schema.value[index]
    schema.value[index] = schema.value[index - 1]
    schema.value[index - 1] = temp
  } else if (direction === 'down' && index < schema.value.length - 1) {
    const temp = schema.value[index]
    schema.value[index] = schema.value[index + 1]
    schema.value[index + 1] = temp
  }
}

function onLabelChange(field: CustomField) {
  if (!field.name || field.name.startsWith('field_')) {
    field.name = slugify(field.label) || field.id
  }
}

function addOption(field: CustomField) {
  const optVal = (optionInputs.value[field.id] || '').trim()
  if (!optVal) return
  if (!field.options) field.options = []
  if (!field.options.includes(optVal)) {
    field.options.push(optVal)
  }
  optionInputs.value[field.id] = ''
}

function removeOption(field: CustomField, optIdx: number) {
  if (field.options) {
    field.options.splice(optIdx, 1)
  }
}

// Presets
function applyPreset(presetType: 'sma' | 'smk' | 'ma') {
  if (schema.value.length > 0) {
    if (!confirm('Menerapkan preset akan menggantikan daftar kolom formulir saat ini. Lanjutkan?')) {
      return
    }
  }

  if (presetType === 'sma') {
    schema.value = [
      {
        id: `field_${Date.now()}_1`,
        name: 'lokasi_karantina',
        label: 'Ruang / Lokasi Karantina Lomba',
        type: 'text',
        placeholder: 'Contoh: Lab Komputer 1 / Perpustakaan Lt. 2',
        description: 'Lokasi persiapan atau karantina materi di sekolah',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_2`,
        name: 'sumber_dana',
        label: 'Sumber Pembiayaan Kegiatan',
        type: 'select',
        placeholder: '',
        description: 'Alokasi anggaran pendaftaran dan akomodasi',
        options: ['Dana BOS Sekolah', 'Komite Sekolah', 'Mandiri Peserta', 'Sponsor / CSR'],
        is_required: false,
      },
      {
        id: `field_${Date.now()}_3`,
        name: 'komitmen_tugas',
        label: 'Siswa Berkomitmen Mengerjakan Tugas Susulan KBM',
        type: 'checkbox',
        placeholder: '',
        description: 'Siswa wajib berkoordinasi dengan guru mata pelajaran yang ditinggalkan',
        options: [],
        is_required: true,
      },
    ]
  } else if (presetType === 'smk') {
    schema.value = [
      {
        id: `field_${Date.now()}_1`,
        name: 'bengkel_lab_kejuruan',
        label: 'Bengkel / Laboratorium Kejuruan',
        type: 'text',
        placeholder: 'Contoh: Bengkel Otomotif 2 / Lab RPL 1',
        description: 'Fasilitas praktik kejuruan yang digunakan untuk persiapan',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_2`,
        name: 'mitra_industri_dudi',
        label: 'Instansi / Mitra DUDI Terkait',
        type: 'text',
        placeholder: 'Contoh: PT. Astra Honda Motor / Axioo Class Program',
        description: 'Mitra industri pendukung kompetisi kejuruan (opsional)',
        options: [],
        is_required: false,
      },
      {
        id: `field_${Date.now()}_3`,
        name: 'jam_praktik_ditinggalkan',
        label: 'Estimasi Jam Pelajaran Praktik yang Ditinggalkan',
        type: 'number',
        placeholder: 'Contoh: 12',
        description: 'Jumlah jam KBM praktik yang harus dijadwalkan susulan',
        options: [],
        is_required: false,
      },
    ]
  } else if (presetType === 'ma') {
    schema.value = [
      {
        id: `field_${Date.now()}_1`,
        name: 'status_tempat_tinggal',
        label: 'Status Tempat Tinggal Siswa',
        type: 'select',
        placeholder: '',
        description: 'Status siswa apakah mukim di asrama atau pulang-pergi',
        options: ['Santri Mukim Asrama / Pondok', 'Non-Mukim (Laju / Pulang-Pergi)'],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_2`,
        name: 'izin_pengasuh_asrama',
        label: 'Telah Memperoleh Rekomendasi Pengasuh Asrama / Pondok',
        type: 'checkbox',
        placeholder: '',
        description: 'Khusus santri mukim, wajib mengantongi izin dari pengasuhan',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_3`,
        name: 'target_setoran_hafalan',
        label: 'Komitmen Setoran Hafalan / Kitab Disesuaikan',
        type: 'checkbox',
        placeholder: '',
        description: 'Setoran tahfidz atau kajian madrasah akan diganti setelah lomba',
        options: [],
        is_required: false,
      },
    ]
  }

  initPreviewValues()
  toast.info(`Preset ${presetType.toUpperCase()} berhasil diterapkan. Silakan periksa atau sesuaikan kembali.`)
}

async function saveSchema() {
  saving.value = true
  try {
    // Basic sanitization
    const payload = schema.value.map(f => ({
      id: f.id,
      name: slugify(f.name) || f.id,
      label: f.label.trim(),
      type: f.type,
      placeholder: f.placeholder || null,
      description: f.description || null,
      options: f.type === 'select' ? (f.options || []) : [],
      is_required: Boolean(f.is_required),
    }))

    await api.put('/school/dispensations/form-schema', {
      schema: payload,
    })

    toast.success('Pengaturan kolom formulir dispensasi berhasil disimpan!', 'Berhasil Disimpan')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menyimpan pengaturan formulir.', 'Gagal')
  } finally {
    saving.value = false
  }
}

// -------------------------------------------------------------
// Letterhead & Official Document Template State & Methods
// -------------------------------------------------------------
const activeTab = ref<'schema' | 'template'>('schema')
const templateLoading = ref(false)
const templateSaving = ref(false)

const letterheadType = ref<'image' | 'text'>('text')
const letterheadImageUrl = ref<string | null>(null)
const letterheadImagePreview = ref<string | null>(null)
const letterheadFile = ref<File | null>(null)
const removeLetterheadImage = ref(false)

const docxTemplateFile = ref<File | null>(null)
const hasCustomDocx = ref(false)
const docxTemplateName = ref<string | null>(null)
const removeDocxTemplate = ref(false)

const letterConfig = ref({
  institution_level1: 'PEMERINTAH DAERAH PROVINSI',
  institution_level2: 'DINAS PENDIDIKAN DAN KEBUDAYAAN',
  document_title: 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)',
  reference_number_prefix: '421.3/DISP-KBM',
  closing_text: 'Demikian surat dispensasi ini dibuat agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa tetap berkewajiban menyelesaikan materi pelajaran serta tugas-tugas yang tertinggal.',
})

async function fetchLetterTemplate() {
  templateLoading.value = true
  try {
    const res = await api.get('/school/dispensations/letter-template')
    const d = res.data.data
    letterheadType.value = d.letterhead_type || 'text'
    letterheadImageUrl.value = d.letterhead_image_url
    letterheadImagePreview.value = d.letterhead_image_url
    hasCustomDocx.value = d.has_custom_docx || false
    docxTemplateName.value = d.docx_template_name
    if (d.letter_format_config) {
      letterConfig.value = { ...letterConfig.value, ...d.letter_format_config }
    }
  } catch (err) {
    toast.error('Gagal memuat template surat dan kop sekolah.')
  } finally {
    templateLoading.value = false
  }
}

function handleLetterheadChange(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    letterheadFile.value = file
    removeLetterheadImage.value = false
    letterheadType.value = 'image'
    const reader = new FileReader()
    reader.onload = () => {
      letterheadImagePreview.value = reader.result as string
    }
    reader.readAsDataURL(file)
  }
}

function handleRemoveLetterhead() {
  letterheadFile.value = null
  letterheadImagePreview.value = null
  removeLetterheadImage.value = true
  letterheadType.value = 'text'
}

function handleDocxChange(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    docxTemplateFile.value = target.files[0]
    removeDocxTemplate.value = false
  }
}

function handleRemoveDocx() {
  docxTemplateFile.value = null
  removeDocxTemplate.value = true
  hasCustomDocx.value = false
  docxTemplateName.value = null
}

async function saveLetterTemplate() {
  templateSaving.value = true
  try {
    const formData = new FormData()
    formData.append('letterhead_type', letterheadType.value)
    if (letterheadFile.value) {
      formData.append('letterhead_image', letterheadFile.value)
    }
    if (removeLetterheadImage.value) {
      formData.append('remove_letterhead_image', '1')
    }
    if (docxTemplateFile.value) {
      formData.append('docx_template', docxTemplateFile.value)
    }
    if (removeDocxTemplate.value) {
      formData.append('remove_docx_template', '1')
    }
    formData.append('institution_level1', letterConfig.value.institution_level1)
    formData.append('institution_level2', letterConfig.value.institution_level2)
    formData.append('document_title', letterConfig.value.document_title)
    formData.append('reference_number_prefix', letterConfig.value.reference_number_prefix)
    formData.append('closing_text', letterConfig.value.closing_text)

    await api.post('/school/dispensations/letter-template', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Format surat dan kop sekolah berhasil disimpan secara resmi.', 'Tersimpan')
    letterheadFile.value = null
    docxTemplateFile.value = null
    removeLetterheadImage.value = false
    removeDocxTemplate.value = false
    fetchLetterTemplate()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menyimpan format surat.')
  } finally {
    templateSaving.value = false
  }
}

onMounted(() => {
  fetchSchema()
  fetchLetterTemplate()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>
      Pengaturan Formulir Dispensasi KBM
    </template>

    <div class="max-w-7xl mx-auto space-y-6 pb-12">
      <!-- Breadcrumb & Top Action Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-white p-6 rounded-2xl border border-slate-200/80 shadow-xs">
        <div>
          <div class="flex items-center gap-2 text-xs font-semibold text-slate-500 mb-1">
            <router-link to="/school/dispensations" class="hover:text-brand-navy flex items-center gap-1">
              <i class="fa-solid fa-arrow-left"></i>
              <span>Kembali ke Dispensasi</span>
            </router-link>
            <span>/</span>
            <span class="text-brand-navy">Form Builder Dinamis</span>
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
            Kustomisasi Formulir Surat Dispensasi KBM
          </h2>
          <p class="text-xs sm:text-sm text-slate-500 mt-1 max-w-2xl">
            Sesuaikan kolom formulir perizinan siswa di <strong>{{ schoolName }}</strong>. Kolom yang Anda tentukan di sini akan otomatis tampil saat Admin maupun Siswa membuat surat dispensasi, serta dicetak resmi pada dokumen surat.
          </p>
        </div>

        <div class="flex items-center gap-2.5 shrink-0">
          <button
            v-if="activeTab === 'schema'"
            type="button"
            @click="saveSchema"
            :disabled="saving || loading"
            class="px-5 py-2.5 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
          >
            <i v-if="saving" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-floppy-disk text-brand-gold"></i>
            <span>Simpan Formulir</span>
          </button>

          <button
            v-else
            type="button"
            @click="saveLetterTemplate"
            :disabled="templateSaving || templateLoading"
            class="px-5 py-2.5 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
          >
            <i v-if="templateSaving" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-floppy-disk text-brand-gold"></i>
            <span>Simpan Format & Kop Surat</span>
          </button>
        </div>
      </div>

      <!-- Navigation Tabs: Form Schema vs Letterhead & Document Format -->
      <div class="flex items-center gap-3 border-b border-slate-200">
        <button
          type="button"
          @click="activeTab = 'schema'"
          :class="[
            'px-5 py-3 text-xs sm:text-sm font-bold border-b-2 transition-all flex items-center gap-2 cursor-pointer',
            activeTab === 'schema'
              ? 'border-brand-navy text-brand-navy'
              : 'border-transparent text-slate-500 hover:text-slate-800'
          ]"
        >
          <i class="fa-solid fa-list-check"></i>
          <span>1. Kolom Formulir Pengajuan Siswa</span>
        </button>

        <button
          type="button"
          @click="activeTab = 'template'"
          :class="[
            'px-5 py-3 text-xs sm:text-sm font-bold border-b-2 transition-all flex items-center gap-2 cursor-pointer',
            activeTab === 'template'
              ? 'border-brand-navy text-brand-navy'
              : 'border-transparent text-slate-500 hover:text-slate-800'
          ]"
        >
          <i class="fa-solid fa-file-signature text-brand-gold"></i>
          <span>2. Format Surat & Kop Sekolah (DOCX / PDF)</span>
          <span class="ml-1.5 px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">2 Tanda Tangan</span>
        </button>
      </div>

      <!-- TAB 1: FORM SCHEMA BUILDER -->
      <div v-if="activeTab === 'schema'" class="space-y-6">
        <!-- Quick Preset Template Banner -->
        <div class="bg-linear-to-r from-blue-900 to-indigo-950 text-white rounded-2xl p-5 sm:p-6 shadow-md border border-blue-800/40 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div class="space-y-1 max-w-xl">
          <div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-white/10 text-brand-gold text-[10px] font-bold uppercase tracking-wider">
            <i class="fa-solid fa-wand-magic-sparkles"></i>
            <span>Template Cepat Instansi</span>
          </div>
          <h3 class="text-sm sm:text-base font-bold text-white">Gunakan Template Rekomendasi Sesuai Jenjang</h3>
          <p class="text-xs text-blue-200/80 leading-relaxed">
            Ingin setup instan? Terapkan skema kolom baku yang sering digunakan untuk jenjang SMA Umum, SMK Vokasi, atau Madrasah Aliyah.
          </p>
        </div>

        <div class="flex flex-wrap items-center gap-2">
          <button
            type="button"
            @click="applyPreset('sma')"
            class="px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-xs font-semibold text-white border border-white/15 transition-all cursor-pointer flex items-center gap-1.5"
          >
            <i class="fa-solid fa-graduation-cap text-sky-400"></i>
            <span>Preset SMA (Umum)</span>
          </button>
          <button
            type="button"
            @click="applyPreset('smk')"
            class="px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-xs font-semibold text-white border border-white/15 transition-all cursor-pointer flex items-center gap-1.5"
          >
            <i class="fa-solid fa-wrench text-amber-400"></i>
            <span>Preset SMK (Kejuruan)</span>
          </button>
          <button
            type="button"
            @click="applyPreset('ma')"
            class="px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-xs font-semibold text-white border border-white/15 transition-all cursor-pointer flex items-center gap-1.5"
          >
            <i class="fa-solid fa-mosque text-emerald-400"></i>
            <span>Preset MA (Madrasah)</span>
          </button>
        </div>
      </div>

      <!-- Main Dual-Column Workspace: Left Form Editor, Right Live Preview -->
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        <!-- LEFT: Field Configuration List (7 cols) -->
        <div class="lg:col-span-7 space-y-4">
          <!-- Permanent Core Fields Card (Read-only reference) -->
          <div class="bg-slate-50 rounded-2xl p-4 border border-slate-200/80 text-xs">
            <div class="flex items-center justify-between mb-2">
              <span class="font-bold text-slate-700 flex items-center gap-1.5">
                <i class="fa-solid fa-lock text-slate-400"></i>
                <span>Kolom Wajib Baku (Standar Semua Sekolah)</span>
              </span>
              <span class="text-[10px] text-slate-400">Permanen</span>
            </div>
            <div class="flex flex-wrap gap-1.5">
              <span class="px-2.5 py-1 rounded-md bg-white border border-slate-200 text-[11px] text-slate-600 font-medium">1. Nama Lomba / Kegiatan</span>
              <span class="px-2.5 py-1 rounded-md bg-white border border-slate-200 text-[11px] text-slate-600 font-medium">2. Jenis Izin (Persiapan / Pelaksanaan)</span>
              <span class="px-2.5 py-1 rounded-md bg-white border border-slate-200 text-[11px] text-slate-600 font-medium">3. Siswa yang Diberi Izin</span>
              <span class="px-2.5 py-1 rounded-md bg-white border border-slate-200 text-[11px] text-slate-600 font-medium">4. Rentang Tanggal Izin</span>
              <span class="px-2.5 py-1 rounded-md bg-white border border-slate-200 text-[11px] text-slate-600 font-medium">5. Uraian / Tujuan</span>
              <span class="px-2.5 py-1 rounded-md bg-white border border-slate-200 text-[11px] text-slate-600 font-medium">6. Guru Pendamping</span>
            </div>
          </div>

          <!-- Add Field Action Buttons Bar -->
          <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <h4 class="text-xs font-extrabold uppercase tracking-wider text-brand-navy">Kolom Kustom Sekolah</h4>
              <p class="text-[11px] text-slate-500">Pilih tipe input untuk menambah kolom baru:</p>
            </div>
            <div class="flex flex-wrap items-center gap-1.5">
              <button
                type="button"
                @click="addField('text')"
                class="px-2.5 py-1.5 bg-slate-50 hover:bg-blue-50 text-brand-navy rounded-lg border border-slate-200 text-xs font-semibold transition-colors cursor-pointer"
                title="Teks Singkat"
              >
                <i class="fa-solid fa-font text-blue-600 mr-1"></i> Teks
              </button>
              <button
                type="button"
                @click="addField('select')"
                class="px-2.5 py-1.5 bg-slate-50 hover:bg-emerald-50 text-emerald-900 rounded-lg border border-slate-200 text-xs font-semibold transition-colors cursor-pointer"
                title="Pilihan Dropdown"
              >
                <i class="fa-solid fa-list text-emerald-600 mr-1"></i> Pilihan
              </button>
              <button
                type="button"
                @click="addField('checkbox')"
                class="px-2.5 py-1.5 bg-slate-50 hover:bg-purple-50 text-purple-900 rounded-lg border border-slate-200 text-xs font-semibold transition-colors cursor-pointer"
                title="Kotak Centang"
              >
                <i class="fa-solid fa-square-check text-purple-600 mr-1"></i> Centang
              </button>
              <button
                type="button"
                @click="addField('number')"
                class="px-2.5 py-1.5 bg-slate-50 hover:bg-amber-50 text-amber-900 rounded-lg border border-slate-200 text-xs font-semibold transition-colors cursor-pointer"
                title="Angka"
              >
                <i class="fa-solid fa-hashtag text-amber-600 mr-1"></i> Angka
              </button>
              <button
                type="button"
                @click="addField('textarea')"
                class="px-2.5 py-1.5 bg-slate-50 hover:bg-indigo-50 text-indigo-900 rounded-lg border border-slate-200 text-xs font-semibold transition-colors cursor-pointer"
                title="Paragraf"
              >
                <i class="fa-solid fa-paragraph text-indigo-600 mr-1"></i> Paragraf
              </button>
            </div>
          </div>

          <!-- Dynamic Field Cards List -->
          <div v-if="loading" class="p-8 text-center bg-white rounded-2xl border border-slate-200">
            <i class="fa-solid fa-spinner fa-spin text-2xl text-brand-navy"></i>
            <p class="text-xs text-slate-500 mt-2">Memuat konfigurasi formulir sekolah...</p>
          </div>

          <div v-else-if="schema.length === 0" class="p-8 text-center bg-white rounded-2xl border border-dashed border-slate-300 space-y-3">
            <div class="w-12 h-12 rounded-full bg-blue-50 text-brand-blue flex items-center justify-center text-xl mx-auto">
              <i class="fa-solid fa-sliders"></i>
            </div>
            <h4 class="text-sm font-bold text-slate-800">Belum Ada Kolom Tambahan Khusus</h4>
            <p class="text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
              Sekolah Anda saat ini hanya menggunakan kolom baku standar. Klik tombol tipe kolom di atas atau terapkan preset untuk menambah kolom formulir.
            </p>
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="(field, fIdx) in schema"
              :key="field.id"
              class="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs space-y-4 transition-all"
            >
              <!-- Field Card Header -->
              <div class="flex items-center justify-between gap-3 border-b border-slate-100 pb-3">
                <div class="flex items-center gap-2 min-w-0">
                  <span class="w-6 h-6 rounded-full bg-slate-100 text-slate-700 text-xs font-extrabold flex items-center justify-center shrink-0">
                    {{ fIdx + 1 }}
                  </span>
                  <span class="text-xs font-bold text-slate-900 truncate">
                    {{ field.label || 'Kolom Baru' }}
                  </span>
                  <span class="px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-[10px] font-semibold uppercase">
                    {{ field.type }}
                  </span>
                  <span v-if="field.is_required" class="px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 text-[10px] font-bold">
                    Wajib
                  </span>
                </div>

                <!-- Move & Delete Controls -->
                <div class="flex items-center gap-1 shrink-0">
                  <button
                    type="button"
                    @click="moveField(fIdx, 'up')"
                    :disabled="fIdx === 0"
                    class="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md disabled:opacity-30 cursor-pointer"
                    title="Pindahkan Ke Atas"
                  >
                    <i class="fa-solid fa-arrow-up text-xs"></i>
                  </button>
                  <button
                    type="button"
                    @click="moveField(fIdx, 'down')"
                    :disabled="fIdx === schema.length - 1"
                    class="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md disabled:opacity-30 cursor-pointer"
                    title="Pindahkan Ke Bawah"
                  >
                    <i class="fa-solid fa-arrow-down text-xs"></i>
                  </button>
                  <button
                    type="button"
                    @click="removeField(fIdx)"
                    class="p-1.5 text-rose-500 hover:text-rose-700 hover:bg-rose-50 rounded-md cursor-pointer ml-1"
                    title="Hapus Kolom"
                  >
                    <i class="fa-solid fa-trash-can text-xs"></i>
                  </button>
                </div>
              </div>

              <!-- Field Settings Form -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                <!-- Label -->
                <div class="space-y-1">
                  <label class="font-bold text-slate-700">Label Kolom (Judul di Form) *</label>
                  <input
                    type="text"
                    v-model="field.label"
                    @input="onLabelChange(field)"
                    placeholder="Contoh: Lokasi Karantina"
                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-navy focus:bg-white"
                  />
                </div>

                <!-- Input Type -->
                <div class="space-y-1">
                  <label class="font-bold text-slate-700">Tipe Masukan Data *</label>
                  <select
                    v-model="field.type"
                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-navy focus:bg-white"
                  >
                    <option value="text">Teks Singkat (Text)</option>
                    <option value="textarea">Paragraf Panjang (Textarea)</option>
                    <option value="select">Pilihan Dropdown (Select)</option>
                    <option value="number">Angka / Jam (Number)</option>
                    <option value="checkbox">Kotak Centang Persetujuan (Checkbox)</option>
                    <option value="date">Tanggal Tambahan (Date)</option>
                  </select>
                </div>

                <!-- Placeholder (if applicable) -->
                <div v-if="field.type !== 'checkbox' && field.type !== 'date'" class="space-y-1">
                  <label class="font-medium text-slate-600">Placeholder (Petunjuk Isi)</label>
                  <input
                    type="text"
                    v-model="field.placeholder"
                    placeholder="Contoh: Tuliskan nama ruangan..."
                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-navy focus:bg-white"
                  />
                </div>

                <!-- Variable Key / Name (slug) -->
                <div class="space-y-1">
                  <label class="font-medium text-slate-600">Kode Kunci Sistem</label>
                  <input
                    type="text"
                    v-model="field.name"
                    placeholder="contoh_kunci"
                    class="w-full px-3 py-2 bg-slate-100 font-mono text-[11px] text-slate-600 border border-slate-200 rounded-xl focus:outline-hidden"
                  />
                </div>

                <!-- Description / Helper -->
                <div class="sm:col-span-2 space-y-1">
                  <label class="font-medium text-slate-600">Keterangan Tambahan untuk Pemohon (Opsional)</label>
                  <input
                    type="text"
                    v-model="field.description"
                    placeholder="Contoh: Pastikan berkoordinasi dengan pengelola ruangan..."
                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-navy focus:bg-white"
                  />
                </div>

                <!-- Options Editor (for select dropdown type) -->
                <div v-if="field.type === 'select'" class="sm:col-span-2 p-3 bg-blue-50/50 rounded-xl border border-blue-100 space-y-2">
                  <label class="font-bold text-brand-navy block">Daftar Pilihan Dropdown:</label>
                  <div class="flex flex-wrap gap-1.5 mb-2">
                    <span
                      v-for="(opt, oIdx) in (field.options || [])"
                      :key="oIdx"
                      class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-white border border-blue-200 rounded-lg text-xs font-semibold text-slate-700"
                    >
                      <span>{{ opt }}</span>
                      <button
                        type="button"
                        @click="removeOption(field, oIdx)"
                        class="text-slate-400 hover:text-rose-600 cursor-pointer"
                      >
                        <i class="fa-solid fa-xmark text-xs"></i>
                      </button>
                    </span>
                  </div>

                  <div class="flex gap-2">
                    <input
                      type="text"
                      v-model="optionInputs[field.id]"
                      @keydown.enter.prevent="addOption(field)"
                      placeholder="Ketik opsi pilihan lalu klik Tambah..."
                      class="flex-1 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs focus:outline-hidden focus:border-brand-navy"
                    />
                    <button
                      type="button"
                      @click="addOption(field)"
                      class="px-3 py-1.5 bg-brand-navy text-white text-xs font-bold rounded-lg hover:bg-[#001442] cursor-pointer"
                    >
                      Tambah Opsi
                    </button>
                  </div>
                </div>

                <!-- Required Toggle Switch -->
                <div class="sm:col-span-2 pt-2 flex items-center justify-between border-t border-slate-100">
                  <div>
                    <p class="font-bold text-slate-800">Apakah Kolom Ini Wajib Diisi?</p>
                    <p class="text-[11px] text-slate-400">Jika wajib, pemohon tidak bisa menyimpan formulir jika belum mengisi kolom ini.</p>
                  </div>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" v-model="field.is_required" class="sr-only peer" />
                    <div class="w-11 h-6 bg-slate-200 peer-focus:outline-hidden rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-600"></div>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- RIGHT: Live Interactive Preview (5 cols) -->
        <div class="lg:col-span-5 sticky top-6 space-y-4">
          <div class="bg-white rounded-3xl p-6 border border-slate-200 shadow-lg space-y-5">
            <div class="flex items-center justify-between border-b border-slate-100 pb-3">
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 rounded-full bg-emerald-500 animate-pulse"></div>
                <h3 class="text-xs font-extrabold uppercase tracking-wider text-brand-navy">Pratinjau Langsung Formulir</h3>
              </div>
              <span class="text-[10px] text-slate-400 font-mono">Tampilan Pengguna</span>
            </div>

            <p class="text-[11px] text-slate-500 leading-relaxed">
              Berikut simulasi bagaimana kolom kustom di atas akan terlihat saat Admin menerbitkan dispensasi atau Siswa mengajukan izin:
            </p>

            <!-- Mock Form -->
            <div class="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-4 text-xs">
              <!-- Mock Permanent Core Field -->
              <div class="space-y-1 opacity-70">
                <label class="font-bold text-slate-600">Nama Lomba / Kegiatan *</label>
                <input
                  type="text"
                  disabled
                  value="Olimpiade Sains Nasional (OSN) 2026"
                  class="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed"
                />
              </div>

              <!-- Dynamic Custom Fields Preview -->
              <div v-if="schema.length > 0" class="pt-3 border-t border-blue-200/60 space-y-3.5">
                <div class="flex items-center gap-1.5 text-brand-navy font-black text-xs">
                  <i class="fa-solid fa-sparkles text-brand-gold"></i>
                  <span>Kolom Khusus {{ schoolName }}</span>
                </div>

                <div v-for="field in schema" :key="field.id" class="space-y-1">
                  <label class="font-bold text-slate-800 flex items-center justify-between">
                    <span>
                      {{ field.label }}
                      <span v-if="field.is_required" class="text-rose-500">*</span>
                    </span>
                    <span v-if="!field.is_required" class="text-[10px] text-slate-400 font-normal">(Opsional)</span>
                  </label>

                  <!-- Text Input -->
                  <input
                    v-if="field.type === 'text'"
                    type="text"
                    v-model="previewValues[field.name]"
                    :placeholder="field.placeholder || 'Isikan teks...'"
                    class="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl focus:outline-hidden focus:border-brand-navy"
                  />

                  <!-- Textarea -->
                  <textarea
                    v-else-if="field.type === 'textarea'"
                    rows="2"
                    v-model="previewValues[field.name]"
                    :placeholder="field.placeholder || 'Tuliskan rincian...'"
                    class="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl focus:outline-hidden focus:border-brand-navy"
                  ></textarea>

                  <!-- Select Dropdown -->
                  <select
                    v-else-if="field.type === 'select'"
                    v-model="previewValues[field.name]"
                    class="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl focus:outline-hidden focus:border-brand-navy"
                  >
                    <option value="">-- Pilih {{ field.label }} --</option>
                    <option v-for="(opt, oIdx) in (field.options || [])" :key="oIdx" :value="opt">
                      {{ opt }}
                    </option>
                  </select>

                  <!-- Number -->
                  <input
                    v-else-if="field.type === 'number'"
                    type="number"
                    v-model.number="previewValues[field.name]"
                    :placeholder="field.placeholder || '0'"
                    class="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl focus:outline-hidden focus:border-brand-navy"
                  />

                  <!-- Date -->
                  <input
                    v-else-if="field.type === 'date'"
                    type="date"
                    v-model="previewValues[field.name]"
                    class="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl focus:outline-hidden focus:border-brand-navy"
                  />

                  <!-- Checkbox -->
                  <label v-else-if="field.type === 'checkbox'" class="flex items-start gap-2 pt-1 cursor-pointer">
                    <input
                      type="checkbox"
                      v-model="previewValues[field.name]"
                      class="mt-0.5 rounded border-slate-300 text-brand-navy focus:ring-brand-navy"
                    />
                    <span class="text-slate-700 leading-snug">{{ field.label }}</span>
                  </label>

                  <p v-if="field.description" class="text-[10px] text-slate-400 italic">
                    {{ field.description }}
                  </p>
                </div>
              </div>

              <div v-else class="text-center py-4 text-slate-400 text-xs italic">
                (Belum ada kolom kustom yang ditambahkan)
              </div>
            </div>

            <!-- Footer status in preview card -->
            <div class="pt-2 flex justify-between items-center text-[11px] text-slate-400">
              <span>Total: <strong>{{ schema.length }}</strong> kolom kustom</span>
              <button
                type="button"
                @click="saveSchema"
                :disabled="saving"
                class="text-brand-navy hover:underline font-bold cursor-pointer"
              >
                Simpan Konfigurasi &rarr;
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

      <!-- TAB 2: LETTERHEAD & OFFICIAL DOCUMENT TEMPLATE (KOP, DOCX & PDF) -->
      <div v-else-if="activeTab === 'template'" class="space-y-6">
        <!-- Banner Penjelasan Fitur -->
        <div class="bg-linear-to-r from-emerald-900 to-teal-950 text-white rounded-2xl p-6 shadow-md border border-emerald-800/40 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div class="space-y-1.5 max-w-2xl">
            <div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-white/10 text-emerald-300 text-[10px] font-bold uppercase tracking-wider">
              <i class="fa-solid fa-stamp"></i>
              <span>Standar Dokumen Resmi Sekolah</span>
            </div>
            <h3 class="text-base sm:text-lg font-bold text-white">Format Surat & Kop Instansi untuk Cetak PDF & DOCX</h3>
            <p class="text-xs text-emerald-200/90 leading-relaxed">
              Unggah gambar kop surat sekolah asli Anda atau gunakan kop dinas standar. Setiap surat dispensasi yang disahkan sekolah otomatis memuat <strong>2 kolom tanda tangan</strong>: Guru Pembina Lomba (terisi) dan Guru Mapel/Piket (kosong untuk tanda tangan basah di kelas).
            </p>
          </div>

          <button
            type="button"
            @click="saveLetterTemplate"
            :disabled="templateSaving || templateLoading"
            class="px-5 py-2.5 bg-brand-gold hover:bg-amber-400 text-brand-navy font-black text-xs rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60 shrink-0"
          >
            <i v-if="templateSaving" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-floppy-disk"></i>
            <span>Simpan Format & Kop</span>
          </button>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          <!-- Left Column: Form Settings (7 Cols) -->
          <div class="lg:col-span-7 space-y-6">
            <!-- 1. Pilihan Mode Kop Surat -->
            <div class="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs space-y-4">
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <i class="fa-solid fa-heading text-brand-blue"></i>
                    <span>Kop Surat Resmi Sekolah</span>
                  </h3>
                  <p class="text-xs text-slate-500 mt-0.5">
                    Pilih bagaimana kop surat sekolah ditampilkan pada surat dispensasi.
                  </p>
                </div>
              </div>

              <!-- Radio Cards -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <label
                  :class="[
                    'p-4 rounded-xl border-2 transition-all cursor-pointer flex flex-col justify-between space-y-2',
                    letterheadType === 'image'
                      ? 'border-brand-navy bg-blue-50/40 text-brand-navy shadow-xs'
                      : 'border-slate-200 hover:border-slate-300 text-slate-700 bg-white'
                  ]"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex items-center gap-2 font-bold text-xs">
                      <i class="fa-solid fa-image text-brand-blue"></i>
                      <span>Unggah Gambar Kop Resmi</span>
                    </div>
                    <input
                      type="radio"
                      name="letterhead_type"
                      value="image"
                      v-model="letterheadType"
                      class="text-brand-navy focus:ring-brand-navy mt-0.5"
                    />
                  </div>
                  <p class="text-[11px] text-slate-500 leading-normal">
                    Menggunakan gambar kop surat berlogo resmi dinas & sekolah yang diunggah.
                  </p>
                </label>

                <label
                  :class="[
                    'p-4 rounded-xl border-2 transition-all cursor-pointer flex flex-col justify-between space-y-2',
                    letterheadType === 'text'
                      ? 'border-brand-navy bg-blue-50/40 text-brand-navy shadow-xs'
                      : 'border-slate-200 hover:border-slate-300 text-slate-700 bg-white'
                  ]"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex items-center gap-2 font-bold text-xs">
                      <i class="fa-solid fa-font text-emerald-600"></i>
                      <span>Kop Teks Kedinasan Standar</span>
                    </div>
                    <input
                      type="radio"
                      name="letterhead_type"
                      value="text"
                      v-model="letterheadType"
                      class="text-brand-navy focus:ring-brand-navy mt-0.5"
                    />
                  </div>
                  <p class="text-[11px] text-slate-500 leading-normal">
                    Disusun otomatis dengan teks nama dinas, nama sekolah, NPSN, dan garis ganda dinas.
                  </p>
                </label>
              </div>

              <!-- Upload Gambar Kop Box -->
              <div v-if="letterheadType === 'image'" class="pt-3 border-t border-slate-100 space-y-3">
                <div v-if="letterheadImagePreview" class="p-3 bg-slate-50 rounded-xl border border-slate-200 space-y-2">
                  <div class="flex items-center justify-between text-xs font-semibold text-slate-700">
                    <span class="flex items-center gap-1.5 text-emerald-700">
                      <i class="fa-solid fa-circle-check"></i>
                      <span>Gambar Kop Surat Terpasang</span>
                    </span>
                    <button
                      type="button"
                      @click="handleRemoveLetterhead"
                      class="text-rose-600 hover:text-rose-800 text-[11px] font-bold cursor-pointer flex items-center gap-1"
                    >
                      <i class="fa-solid fa-trash-can"></i>
                      <span>Hapus Gambar</span>
                    </button>
                  </div>
                  <div class="p-2 bg-white rounded-lg border border-slate-200 flex items-center justify-center max-h-36 overflow-hidden">
                    <img :src="letterheadImagePreview" alt="Preview Kop Surat" class="max-h-28 object-contain w-auto mx-auto" />
                  </div>
                </div>

                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">
                    {{ letterheadImagePreview ? 'Ganti File Gambar Kop Surat' : 'Pilih Berkas Gambar Kop Surat (PNG/JPG)' }}
                  </label>
                  <input
                    type="file"
                    accept="image/png,image/jpeg,image/webp"
                    @change="handleLetterheadChange"
                    class="w-full text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-[#00164a] cursor-pointer text-xs"
                  />
                  <p class="text-[11px] text-slate-400 mt-1">
                    Format: PNG, JPG, atau WebP (Maks. 5 MB). Disarankan menggunakan gambar berlatar transparan atau putih dengan resolusi tajam (lebar ideal 1000 - 1400 px).
                  </p>
                </div>
              </div>

              <!-- Teks Kop Tambahan -->
              <div class="pt-3 border-t border-slate-100 space-y-3">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Tingkat Pemerintah / Wilayah</label>
                    <input
                      v-model="letterConfig.institution_level1"
                      type="text"
                      placeholder="Contoh: PEMERINTAH DAERAH PROVINSI JAWA TIMUR"
                      class="w-full rounded-xl border border-slate-300 p-2 text-xs focus:border-brand-navy focus:outline-hidden"
                    />
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Nama Dinas / Instansi Induk</label>
                    <input
                      v-model="letterConfig.institution_level2"
                      type="text"
                      placeholder="Contoh: DINAS PENDIDIKAN WILAYAH KOTA MALANG"
                      class="w-full rounded-xl border border-slate-300 p-2 text-xs focus:border-brand-navy focus:outline-hidden"
                    />
                  </div>
                </div>
              </div>
            </div>

            <!-- 2. Pengaturan Konten Surat & Nomor -->
            <div class="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs space-y-4">
              <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-file-lines text-indigo-600"></i>
                <span>Format Redaksi & Penomoran Surat</span>
              </h3>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Judul Dokumen Resmi</label>
                  <input
                    v-model="letterConfig.document_title"
                    type="text"
                    placeholder="SURAT KETERANGAN DISPENSASI BELAJAR (KBM)"
                    class="w-full rounded-xl border border-slate-300 p-2 text-xs focus:border-brand-navy focus:outline-hidden font-bold"
                  />
                </div>
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Kode / Awalan Nomor Surat</label>
                  <input
                    v-model="letterConfig.reference_number_prefix"
                    type="text"
                    placeholder="421.3/DISP-KBM"
                    class="w-full rounded-xl border border-slate-300 p-2 text-xs focus:border-brand-navy focus:outline-hidden font-mono"
                  />
                </div>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Kalimat Penutup Surat</label>
                <textarea
                  v-model="letterConfig.closing_text"
                  rows="3"
                  class="w-full rounded-xl border border-slate-300 p-2.5 text-xs focus:border-brand-navy focus:outline-hidden leading-relaxed"
                ></textarea>
              </div>
            </div>

            <!-- 3. Struktur 2 Tanda Tangan Resmi (Penjelasan Sistem) -->
            <div class="bg-blue-50/70 rounded-2xl p-6 border border-blue-200/80 shadow-xs space-y-3">
              <div class="flex items-center gap-2 text-brand-navy font-bold text-xs uppercase tracking-wider">
                <i class="fa-solid fa-signature text-brand-gold"></i>
                <span>Struktur 2 Tanda Tangan Resmi di Lapangan</span>
              </div>
              <p class="text-xs text-slate-700 leading-relaxed">
                Sesuai kebutuhan operasional sekolah, sistem menghasilkan 2 kolom tanda tangan berdampingan:
              </p>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
                <!-- Tanda Tangan 1 -->
                <div class="bg-white p-3.5 rounded-xl border border-blue-200/90 shadow-2xs space-y-1.5">
                  <div class="flex items-center justify-between">
                    <span class="text-xs font-bold text-brand-navy">1. Guru Pembina Lomba</span>
                    <span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">Terisi Otomatis</span>
                  </div>
                  <p class="text-[11px] text-slate-600 leading-normal">
                    Nama terisi otomatis dari kolom <strong>Guru Pembimbing / Pembina</strong> yang diisi siswa saat mengajukan dispensasi.
                  </p>
                </div>

                <!-- Tanda Tangan 2 -->
                <div class="bg-white p-3.5 rounded-xl border border-blue-200/90 shadow-2xs space-y-1.5">
                  <div class="flex items-center justify-between">
                    <span class="text-xs font-bold text-slate-900">2. Guru Mapel / Piket</span>
                    <span class="px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 text-[10px] font-bold">Dikosongkan</span>
                  </div>
                  <p class="text-[11px] text-slate-600 leading-normal">
                    Dikosongkan dengan garis tanda tangan karena guru yang mengajar di kelas dapat berubah-ubah sesuai jadwal pelajaran jam tersebut.
                  </p>
                </div>
              </div>
            </div>

            <!-- 4. Template DOCX Kustom (Opsional) -->
            <div class="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs space-y-4">
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <i class="fa-solid fa-file-word text-blue-600"></i>
                    <span>Template Microsoft Word (.docx) Kustom (Opsional)</span>
                  </h3>
                  <p class="text-xs text-slate-500 mt-0.5">
                    Unggah berkas Word (.docx) khusus jika sekolah Anda memiliki format tata naskah dinas mandiri.
                  </p>
                </div>
                <span
                  :class="[
                    'px-2.5 py-1 rounded-full text-[11px] font-bold',
                    hasCustomDocx ? 'bg-blue-100 text-blue-800' : 'bg-slate-100 text-slate-600'
                  ]"
                >
                  {{ hasCustomDocx ? 'Template Kustom Aktif' : 'Template Standar Sistem' }}
                </span>
              </div>

              <div v-if="hasCustomDocx" class="p-3 bg-blue-50/60 rounded-xl border border-blue-200 flex items-center justify-between text-xs">
                <div class="flex items-center gap-2 text-brand-navy font-semibold">
                  <i class="fa-solid fa-file-word text-blue-600 text-base"></i>
                  <span>{{ docxTemplateName || 'Template_Dispensasi_Sekolah.docx' }}</span>
                </div>
                <button
                  type="button"
                  @click="handleRemoveDocx"
                  class="text-rose-600 hover:text-rose-800 font-bold cursor-pointer flex items-center gap-1"
                >
                  <i class="fa-solid fa-rotate-left"></i>
                  <span>Kembali ke Standar</span>
                </button>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  {{ hasCustomDocx ? 'Ganti File Template DOCX' : 'Unggah File Template DOCX Kustom' }}
                </label>
                <input
                  type="file"
                  accept=".docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                  @change="handleDocxChange"
                  class="w-full text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-blue-700 file:text-white hover:file:bg-blue-800 cursor-pointer text-xs"
                />
              </div>

              <!-- Accordion Tag Guide -->
              <details class="text-xs bg-slate-50 rounded-xl p-3 border border-slate-200">
                <summary class="font-bold text-slate-700 cursor-pointer flex items-center gap-2">
                  <i class="fa-solid fa-code text-brand-blue"></i>
                  <span>Daftar Variabel Placeholder yang Didukung di File Word</span>
                </summary>
                <div class="mt-2.5 pt-2 border-t border-slate-200 space-y-1.5 font-mono text-[11px] text-slate-600">
                  <p><code>${NOMOR_SURAT}</code> : Nomor surat perizinan resmi</p>
                  <p><code>${NAMA_KEGIATAN}</code> : Nama kompetisi / agenda lomba</p>
                  <p><code>${KEPERLUAN}</code> : Alasan & keperluan izin dispensasi</p>
                  <p><code>${TANGGAL_MULAI}</code> : Tanggal mulai izin</p>
                  <p><code>${TANGGAL_SELESAI}</code> : Tanggal selesai izin</p>
                  <p><code>${GURU_PEMBINA}</code> : Nama guru pembina / pendamping</p>
                  <p><code>${SEKOLAH_NAMA}</code> : Nama instansi sekolah</p>
                  <p><code>${SEKOLAH_ALAMAT}</code> : Alamat lengkap sekolah</p>
                  <p><code>${student_no}</code> : Penanda baris tabel untuk daftar siswa delegasi</p>
                </div>
              </details>
            </div>
          </div>

          <!-- Right Column: Live Paper Preview A4 (5 Cols) -->
          <div class="lg:col-span-5 sticky top-6 space-y-4">
            <div class="bg-white rounded-2xl p-4 sm:p-5 border border-slate-200/80 shadow-xs space-y-3">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                  <i class="fa-solid fa-eye text-brand-blue"></i>
                  <span>Simulasi Tampilan Kertas (A4)</span>
                </span>
                <span class="text-[10px] font-mono text-slate-400">Pratinjau Nyata</span>
              </div>

              <!-- Mini A4 Paper Container -->
              <div class="bg-white p-5 rounded-lg border border-slate-300 shadow-sm text-black font-serif text-[10px] space-y-2.5">
                <!-- Kop Mini -->
                <div v-if="letterheadType === 'image' && letterheadImagePreview" class="text-center pb-1 border-b border-slate-200">
                  <img :src="letterheadImagePreview" alt="Kop Gambar" class="max-h-14 object-contain w-auto mx-auto" />
                </div>
                <div v-else class="text-center pb-1">
                  <p class="font-bold uppercase tracking-wider text-[9px]">{{ letterConfig.institution_level1 }}</p>
                  <p class="font-bold uppercase text-[9.5px]">{{ letterConfig.institution_level2 }}</p>
                  <p class="font-black uppercase text-[11px] leading-tight">{{ schoolName }}</p>
                  <p class="text-[8px] font-sans text-slate-500">Jl. Pendidikan No. 1 • NPSN: 10203040 • Telp: 021-5551234</p>
                  <div class="mt-1.5 border-t-2 border-black"></div>
                  <div class="mt-0.5 border-t border-black"></div>
                </div>

                <!-- Judul Mini -->
                <div class="text-center pt-1 space-y-0.5">
                  <p class="font-bold underline uppercase text-[10px]">{{ letterConfig.document_title }}</p>
                  <p class="font-sans text-[8.5px] text-slate-600">Nomor: {{ letterConfig.reference_number_prefix }}/2026/001</p>
                </div>

                <!-- Body Mini -->
                <p class="font-sans text-[9px] leading-relaxed text-slate-800">
                  Yang bertanda tangan di bawah ini menerangkan bahwa delegasi siswa di bawah ini diberikan izin dispensasi KBM:
                </p>

                <!-- Mini Student Table -->
                <table class="w-full font-sans text-[8.5px] border border-slate-400 border-collapse">
                  <thead class="bg-slate-100 font-bold">
                    <tr>
                      <th class="border border-slate-400 px-1 py-0.5 text-center w-5">No</th>
                      <th class="border border-slate-400 px-1 py-0.5 text-left">Nama Siswa</th>
                      <th class="border border-slate-400 px-1 py-0.5 text-center">Kelas</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td class="border border-slate-400 px-1 py-0.5 text-center">1</td>
                      <td class="border border-slate-400 px-1 py-0.5 font-bold">Ahmad Bintang Pratama</td>
                      <td class="border border-slate-400 px-1 py-0.5 text-center">XII MIPA 1</td>
                    </tr>
                  </tbody>
                </table>

                <div class="bg-slate-50 p-1.5 rounded border border-slate-200 font-sans text-[8.5px] space-y-0.5">
                  <p><strong>Kegiatan:</strong> Olimpiade Sains Nasional (OSN) 2026</p>
                  <p><strong>Guru Pembina:</strong> Dra. Sri Wahyuni, M.Pd.</p>
                </div>

                <!-- 2 Kolom Tanda Tangan Mini -->
                <div class="pt-3 grid grid-cols-2 gap-2 text-center font-sans text-[8px]">
                  <!-- Kolom 1 -->
                  <div class="p-1 rounded border border-blue-200/80 bg-blue-50/30">
                    <p class="font-semibold text-slate-700">Mengetahui,<br><strong>Guru Pembina Lomba</strong></p>
                    <div class="h-6"></div>
                    <p class="font-bold underline text-brand-navy">Dra. Sri Wahyuni, M.Pd.</p>
                    <p class="text-[7px] text-slate-500">NIP. - / Pembina Prestasi</p>
                  </div>

                  <!-- Kolom 2 -->
                  <div class="p-1 rounded border border-slate-300 bg-slate-50/50">
                    <p class="font-semibold text-slate-700">Menyetujui,<br><strong>Guru Mapel / Piket</strong></p>
                    <div class="h-6"></div>
                    <p class="font-mono text-slate-500">( ................................. )</p>
                    <p class="text-[7px] text-slate-400 italic">*Tanda tangan basah di kelas</p>
                  </div>
                </div>
              </div>

              <!-- Quick Save Button -->
              <button
                type="button"
                @click="saveLetterTemplate"
                :disabled="templateSaving || templateLoading"
                class="w-full py-2.5 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-60"
              >
                <i v-if="templateSaving" class="fa-solid fa-spinner fa-spin"></i>
                <i v-else class="fa-solid fa-check text-brand-gold"></i>
                <span>Terapkan & Simpan Pengaturan</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
