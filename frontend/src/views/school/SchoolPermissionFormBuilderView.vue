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

// Interactive preview testing state & mode toggle
const viewMode = ref<'editor' | 'preview'>('editor')
const previewValues = ref<Record<string, any>>({})

async function fetchSchema() {
  loading.value = true
  try {
    const res = await api.get('/school/permissions/form-schema')
    schoolName.value = res.data.data.school_name || 'Sekolah'
    const rawSchema = res.data.data.schema || []
    schema.value = rawSchema.map((f: any, idx: number) => ({
      id: f.id || `field_${Date.now()}_${idx}`,
      name: f.name || `field_${idx + 1}`,
      label: f.label || `Pertanyaan ${idx + 1}`,
      type: f.type || 'text',
      placeholder: f.placeholder || '',
      description: f.description || '',
      options: Array.isArray(f.options) ? [...f.options] : [],
      is_required: Boolean(f.is_required),
    }))
    initPreviewValues()
  } catch (err: any) {
    toast.error('Gagal memuat pengaturan formulir perizinan lomba.', 'Error')
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
    checkbox: `Persetujuan Orang Tua ${count}`,
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

function duplicateField(index: number) {
  const source = schema.value[index]
  const newId = `field_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`
  const cloned: CustomField = {
    ...JSON.parse(JSON.stringify(source)),
    id: newId,
    label: `${source.label} (Salinan)`,
    name: `${source.name}_copy`,
  }
  schema.value.splice(index + 1, 0, cloned)
  previewValues.value[cloned.name] = cloned.type === 'checkbox' ? false : ''
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

function updateOptionValue(field: CustomField, optIdx: number, val: string) {
  if (!field.options) field.options = []
  field.options[optIdx] = val
}

// Presets for Perizinan Lomba
function applyPreset(presetType: 'sma' | 'smk' | 'ma') {
  if (schema.value.length > 0) {
    if (!confirm('Menerapkan preset akan menggantikan daftar kolom formulir perizinan saat ini. Lanjutkan?')) {
      return
    }
  }

  if (presetType === 'sma') {
    schema.value = [
      {
        id: `field_${Date.now()}_1`,
        name: 'nama_orang_tua_wali',
        label: 'Nama Orang Tua / Wali Siswa',
        type: 'text',
        placeholder: 'Contoh: Bapak H. Bambang Harjo',
        description: 'Nama wali resmi yang memberikan persetujuan izin lomba',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_2`,
        name: 'sumber_pembiayaan',
        label: 'Sumber Pembiayaan Pendaftaran Lomba',
        type: 'select',
        placeholder: '',
        description: 'Alokasi anggaran pendaftaran dan akomodasi lomba',
        options: ['Mandiri Siswa', 'Subsidi Instansi / Sekolah', 'Sponsor / Beasiswa'],
        is_required: false,
      },
      {
        id: `field_${Date.now()}_3`,
        name: 'persetujuan_orang_tua',
        label: 'Orang Tua / Wali Menyetujui Keikutsertaan Lomba',
        type: 'checkbox',
        placeholder: '',
        description: 'Siswa telah mengantongi izin tertulis dari orang tua/wali',
        options: [],
        is_required: true,
      },
    ]
  } else if (presetType === 'smk') {
    schema.value = [
      {
        id: `field_${Date.now()}_1`,
        name: 'nama_orang_tua_wali',
        label: 'Nama Orang Tua / Wali Siswa',
        type: 'text',
        placeholder: 'Contoh: Ibu Hj. Siti Rohmah',
        description: 'Nama wali resmi yang memberikan persetujuan',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_2`,
        name: 'kategori_kejuruan',
        label: 'Kategori Keahlian / Bidang Lomba Kejuruan',
        type: 'text',
        placeholder: 'Contoh: LKS Web Technologies / CNC Machining',
        description: 'Bidang kompetensi kejuruan yang diikuti',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_3`,
        name: 'rekomendasi_kaprog',
        label: 'Telah Mendapat Rekomendasi Kepala Program Keahlian',
        type: 'checkbox',
        placeholder: '',
        description: 'Telah dikoordinasikan dengan Kaprog kejuruan',
        options: [],
        is_required: true,
      },
    ]
  } else if (presetType === 'ma') {
    schema.value = [
      {
        id: `field_${Date.now()}_1`,
        name: 'nama_orang_tua_wali',
        label: 'Nama Orang Tua / Wali Siswa',
        type: 'text',
        placeholder: 'Contoh: KH. Abdullah Faqih',
        description: 'Nama wali resmi santri/siswa',
        options: [],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_2`,
        name: 'status_santri',
        label: 'Status Keanggotaan Santri',
        type: 'select',
        placeholder: '',
        description: 'Status santri mukim atau laju',
        options: ['Santri Mukim Asrama / Pesantren', 'Non-Mukim (Laju)'],
        is_required: true,
      },
      {
        id: `field_${Date.now()}_3`,
        name: 'izin_pengasuh_pondok',
        label: 'Izin dan Restu Pengasuh Pondok Pesantren',
        type: 'checkbox',
        placeholder: '',
        description: 'Khusus santri mukim wajib mengantongi restu pengasuh',
        options: [],
        is_required: true,
      },
    ]
  }

  initPreviewValues()
  toast.info(`Preset ${presetType.toUpperCase()} berhasil diterapkan. Silakan periksa atau sesuaikan kembali.`)
}

async function saveSchema() {
  saving.value = true
  try {
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

    await api.put('/school/permissions/form-schema', {
      schema: payload,
    })

    toast.success('Pengaturan kolom formulir perizinan lomba berhasil disimpan!', 'Berhasil Disimpan')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menyimpan pengaturan formulir.', 'Gagal')
  } finally {
    saving.value = false
  }
}

// -------------------------------------------------------------
// Letterhead & DOCX Template State & Methods
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
const parsingDocx = ref(false)

const letterConfig = ref({
  institution_level1: 'PEMERINTAH DAERAH PROVINSI',
  institution_level2: 'DINAS PENDIDIKAN DAN KEBUDAYAAN',
  document_title: 'SURAT REKOMENDASI & PERIZINAN MENGIKUTI LOMBA',
  reference_number_prefix: '421.3/IZIN-LOMBA',
  closing_text: 'Demikian surat perizinan mengikuti lomba ini diterbitkan untuk dipergunakan sebagaimana mestinya.',
  header_width_mode: 'contained',
  header_max_height: 130,
  header_alignment: 'center',
  header_margin_bottom: 10,
})

async function fetchLetterTemplate() {
  templateLoading.value = true
  try {
    const res = await api.get('/school/permissions/letter-template')
    const d = res.data.data
    letterheadType.value = d.letterhead_type || 'text'
    letterheadImageUrl.value = d.letterhead_image_url
    letterheadImagePreview.value = d.letterhead_image_url
    hasCustomDocx.value = d.has_custom_docx || false
    docxTemplateName.value = d.docx_template_name
    if (d.permission_letter_format_config) {
      letterConfig.value = { ...letterConfig.value, ...d.permission_letter_format_config }
    }
  } catch (err) {
    toast.error('Gagal memuat template surat perizinan lomba.')
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

async function autoGenerateFromDocx() {
  if (!docxTemplateFile.value) {
    toast.error('Mohon pilih file template .docx terlebih dahulu.', 'Pilih File')
    return
  }

  parsingDocx.value = true
  try {
    const formData = new FormData()
    formData.append('docx_file', docxTemplateFile.value)

    const res = await api.post('/school/permissions/parse-docx-schema', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    const extracted = res.data.data.extracted_schema || []
    if (extracted.length === 0) {
      toast.info('Tidak ditemukan variabel baru pada file DOCX.', 'Informasi')
      return
    }

    schema.value = extracted
    initPreviewValues()
    activeTab.value = 'schema'
    toast.success(`Berhasil memindai file. ${extracted.length} kolom formulir dinamis dibuat secara otomatis!`, 'Form Terbuat Otomatis')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memindai file template DOCX.')
  } finally {
    parsingDocx.value = false
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
    formData.append('header_width_mode', letterConfig.value.header_width_mode || 'contained')
    formData.append('header_max_height', String(letterConfig.value.header_max_height || 130))
    formData.append('header_alignment', letterConfig.value.header_alignment || 'center')
    formData.append('header_margin_bottom', String(letterConfig.value.header_margin_bottom || 10))

    await api.post('/school/permissions/letter-template', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Format surat perizinan lomba berhasil disimpan secara resmi.', 'Tersimpan')
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
      Pengaturan Formulir Perizinan Lomba
    </template>

    <div class="max-w-7xl mx-auto space-y-6 pb-12">
      <!-- Breadcrumb & Top Action Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-white p-6 rounded-2xl border border-slate-200/80 shadow-xs">
        <div>
          <div class="flex items-center gap-2 text-xs font-semibold text-slate-500 mb-1">
            <router-link to="/school/permissions" class="hover:text-brand-navy flex items-center gap-1">
              <i class="fa-solid fa-arrow-left"></i>
              <span>Kembali ke Perizinan Lomba</span>
            </router-link>
            <span>/</span>
            <span class="text-brand-navy">Form Builder Dinamis</span>
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
            Kustomisasi Formulir Surat Perizinan Mengikuti Lomba
          </h2>
          <p class="text-xs sm:text-sm text-slate-500 mt-1 max-w-2xl">
            Sesuaikan kolom formulir perizinan siswa di <strong>{{ schoolName }}</strong>. Kolom yang Anda tentukan di sini akan otomatis tampil saat Admin maupun Siswa membuat surat perizinan lomba.
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

      <!-- Navigation Tabs -->
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

      <!-- TAB 1: FORM SCHEMA BUILDER (GOOGLE FORMS AESTHETIC) -->
      <div v-if="activeTab === 'schema'" class="max-w-4xl mx-auto space-y-5">
        <!-- Google Forms Top Header Card -->
        <div class="bg-white rounded-2xl border border-slate-200/90 shadow-xs overflow-hidden">
          <div class="h-2.5 bg-linear-to-r from-brand-navy via-blue-800 to-indigo-900"></div>
          <div class="p-6 space-y-4">
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div>
                <h2 class="text-xl font-extrabold text-slate-900 tracking-tight">Formulir Perizinan Lomba - {{ schoolName }}</h2>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                  Susun pertanyaan dan kolom dinamis yang wajib diisi oleh siswa saat membuat pengajuan perizinan lomba.
                </p>
              </div>

              <!-- Top Action & View Switcher -->
              <div class="flex items-center gap-2 shrink-0">
                <button
                  type="button"
                  @click="viewMode = viewMode === 'editor' ? 'preview' : 'editor'"
                  :class="[
                    'px-3.5 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 cursor-pointer border',
                    viewMode === 'preview'
                      ? 'bg-emerald-50 text-emerald-800 border-emerald-300 shadow-2xs'
                      : 'bg-slate-100 hover:bg-slate-200 text-slate-700 border-slate-200'
                  ]"
                >
                  <i :class="viewMode === 'preview' ? 'fa-solid fa-pen-to-square text-emerald-600' : 'fa-solid fa-eye text-brand-blue'"></i>
                  <span>{{ viewMode === 'preview' ? 'Kembali ke Editor' : 'Pratinjau Form Siswa' }}</span>
                </button>

                <button
                  type="button"
                  @click="saveSchema"
                  :disabled="saving"
                  class="px-5 py-2.5 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
                >
                  <i v-if="saving" class="fa-solid fa-spinner fa-spin"></i>
                  <i v-else class="fa-solid fa-floppy-disk text-brand-gold"></i>
                  <span>Simpan Formulir</span>
                </button>
              </div>
            </div>

            <!-- Editor vs Preview View Mode Tabs & Preset Bar -->
            <div class="pt-3 border-t border-slate-100 flex flex-wrap items-center justify-between gap-3 text-xs">
              <div class="flex items-center gap-1 bg-slate-100 p-1 rounded-xl">
                <button
                  type="button"
                  @click="viewMode = 'editor'"
                  :class="[
                    'px-3 py-1.5 rounded-lg font-bold text-xs transition-all cursor-pointer flex items-center gap-1.5',
                    viewMode === 'editor' ? 'bg-white text-brand-navy shadow-2xs' : 'text-slate-600 hover:text-slate-900'
                  ]"
                >
                  <i class="fa-solid fa-sliders text-brand-blue"></i>
                  <span>1. Desain Pertanyaan (Editor)</span>
                </button>
                <button
                  type="button"
                  @click="viewMode = 'preview'"
                  :class="[
                    'px-3 py-1.5 rounded-lg font-bold text-xs transition-all cursor-pointer flex items-center gap-1.5',
                    viewMode === 'preview' ? 'bg-white text-brand-navy shadow-2xs' : 'text-slate-600 hover:text-slate-900'
                  ]"
                >
                  <i class="fa-solid fa-eye text-emerald-600"></i>
                  <span>2. Pratinjau Tampilan Siswa</span>
                </button>
              </div>

              <!-- Presets Buttons -->
              <div v-if="viewMode === 'editor'" class="flex items-center gap-1.5">
                <span class="font-bold text-slate-500 text-[11px]">Preset Instan:</span>
                <button
                  type="button"
                  @click="applyPreset('sma')"
                  class="px-2.5 py-1 rounded-lg bg-blue-50 hover:bg-blue-100 text-brand-navy font-semibold text-[11px] transition-colors cursor-pointer flex items-center gap-1"
                >
                  <i class="fa-solid fa-graduation-cap text-blue-600"></i>
                  <span>SMA</span>
                </button>
                <button
                  type="button"
                  @click="applyPreset('smk')"
                  class="px-2.5 py-1 rounded-lg bg-amber-50 hover:bg-amber-100 text-amber-900 font-semibold text-[11px] transition-colors cursor-pointer flex items-center gap-1"
                >
                  <i class="fa-solid fa-gear text-amber-600"></i>
                  <span>SMK</span>
                </button>
                <button
                  type="button"
                  @click="applyPreset('ma')"
                  class="px-2.5 py-1 rounded-lg bg-emerald-50 hover:bg-emerald-100 text-emerald-900 font-semibold text-[11px] transition-colors cursor-pointer flex items-center gap-1"
                >
                  <i class="fa-solid fa-mosque text-emerald-600"></i>
                  <span>MA</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- MODE 1: EDITOR PERTANYAAN -->
        <div v-if="viewMode === 'editor'" class="space-y-4">
          <!-- Floating Action Bar (+ Tambah Pertanyaan Tipe Baru) -->
          <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap items-center justify-between gap-3 sticky top-4 z-10">
            <div class="flex items-center gap-2 font-extrabold text-xs text-brand-navy">
              <i class="fa-solid fa-circle-plus text-base text-brand-blue"></i>
              <span>Tambah Pertanyaan</span>
            </div>
            <div class="flex flex-wrap items-center gap-1.5">
              <button
                type="button"
                @click="addField('text')"
                class="px-3 py-1.5 bg-slate-100 hover:bg-blue-50 text-slate-700 hover:text-brand-navy rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5"
              >
                <i class="fa-solid fa-font text-blue-600"></i> Teks Singkat
              </button>
              <button
                type="button"
                @click="addField('select')"
                class="px-3 py-1.5 bg-slate-100 hover:bg-emerald-50 text-slate-700 hover:text-emerald-900 rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5"
              >
                <i class="fa-regular fa-circle-dot text-emerald-600"></i> Pilihan Ganda
              </button>
              <button
                type="button"
                @click="addField('checkbox')"
                class="px-3 py-1.5 bg-slate-100 hover:bg-purple-50 text-slate-700 hover:text-purple-900 rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5"
              >
                <i class="fa-regular fa-square-check text-purple-600"></i> Centang
              </button>
              <button
                type="button"
                @click="addField('number')"
                class="px-3 py-1.5 bg-slate-100 hover:bg-amber-50 text-slate-700 hover:text-amber-900 rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5"
              >
                <i class="fa-solid fa-hashtag text-amber-600"></i> Angka
              </button>
              <button
                type="button"
                @click="addField('textarea')"
                class="px-3 py-1.5 bg-slate-100 hover:bg-indigo-50 text-slate-700 hover:text-indigo-900 rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5"
              >
                <i class="fa-solid fa-paragraph text-indigo-600"></i> Paragraf
              </button>
            </div>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="p-8 text-center bg-white rounded-2xl border border-slate-200">
            <i class="fa-solid fa-spinner fa-spin text-2xl text-brand-navy"></i>
            <p class="text-xs text-slate-500 mt-2">Memuat formulir sekolah...</p>
          </div>

          <!-- Empty State -->
          <div v-else-if="schema.length === 0" class="p-8 text-center bg-white rounded-2xl border border-dashed border-slate-300 space-y-3">
            <div class="w-12 h-12 rounded-full bg-blue-50 text-brand-blue flex items-center justify-center text-xl mx-auto">
              <i class="fa-solid fa-file-circle-plus"></i>
            </div>
            <h4 class="text-sm font-bold text-slate-800">Formulir Masih Kosong</h4>
            <p class="text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
              Klik tombol tipe pertanyaan di atas untuk menambah pertanyaan baru pada formulir perizinan lomba.
            </p>
          </div>

          <!-- Google Forms Question Cards Stack -->
          <div v-else class="space-y-4">
            <div
              v-for="(field, fIdx) in schema"
              :key="field.id"
              class="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs border-l-4 border-l-brand-navy transition-all space-y-4 hover:shadow-md"
            >
              <!-- Drag Grip & Card Index Header -->
              <div class="flex items-center justify-between text-slate-400">
                <div class="flex items-center gap-2">
                  <i class="fa-solid fa-grip-lines text-slate-300 text-xs cursor-grab"></i>
                  <span class="text-[11px] font-bold uppercase tracking-wider text-slate-500">
                    PERTANYAAN {{ fIdx + 1 }}
                  </span>
                </div>
                <span class="text-[10px] font-mono text-slate-400">ID: {{ field.name }}</span>
              </div>

              <!-- Title Input & Type Dropdown -->
              <div class="flex flex-col sm:flex-row items-start sm:items-center gap-3">
                <input
                  type="text"
                  v-model="field.label"
                  @input="onLabelChange(field)"
                  placeholder="Judul Pertanyaan / Kolom"
                  class="flex-1 w-full text-base font-bold text-slate-900 bg-slate-50/80 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-brand-navy focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
                />

                <select
                  v-model="field.type"
                  class="w-full sm:w-52 px-3.5 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:border-brand-navy focus:bg-white cursor-pointer"
                >
                  <option value="text">Teks Singkat</option>
                  <option value="textarea">Paragraf Panjang</option>
                  <option value="select">Pilihan Ganda</option>
                  <option value="number">Angka / Nilai</option>
                  <option value="checkbox">Kotak Centang</option>
                  <option value="date">Tanggal</option>
                </select>
              </div>

              <!-- Description / Helper Text -->
              <div>
                <input
                  type="text"
                  v-model="field.description"
                  placeholder="Deskripsi atau petunjuk pertanyaan (opsional)..."
                  class="w-full text-xs text-slate-600 bg-slate-50/50 border border-slate-200/70 rounded-xl px-3.5 py-2 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                />
              </div>

              <!-- Options Editor for Pilihan Ganda -->
              <div v-if="field.type === 'select'" class="space-y-2.5 pt-2">
                <p class="text-[11px] font-bold text-slate-600 uppercase tracking-wider">Opsi Pilihan Ganda:</p>

                <div
                  v-for="(opt, oIdx) in (field.options || [])"
                  :key="oIdx"
                  class="flex items-center gap-3"
                >
                  <i class="fa-regular fa-circle text-slate-400 text-sm"></i>
                  <input
                    type="text"
                    :value="opt"
                    @input="e => updateOptionValue(field, oIdx, (e.target as HTMLInputElement).value)"
                    placeholder="Nama Opsi"
                    class="flex-1 text-xs px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:border-brand-navy focus:outline-hidden"
                  />
                  <button
                    type="button"
                    @click="removeOption(field, oIdx)"
                    class="text-slate-400 hover:text-rose-600 p-1.5 cursor-pointer"
                    title="Hapus Opsi"
                  >
                    <i class="fa-solid fa-xmark text-sm"></i>
                  </button>
                </div>

                <div class="flex items-center gap-3 pt-1">
                  <i class="fa-regular fa-circle text-slate-300 text-sm"></i>
                  <input
                    type="text"
                    v-model="optionInputs[field.id]"
                    @keydown.enter.prevent="addOption(field)"
                    placeholder="Ketik opsi baru lalu tekan Enter..."
                    class="flex-1 text-xs px-3.5 py-2 bg-white border border-slate-300 rounded-xl focus:border-brand-navy focus:outline-hidden"
                  />
                  <button
                    type="button"
                    @click="addOption(field)"
                    class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white text-xs font-bold rounded-xl transition-colors cursor-pointer"
                  >
                    + Tambah
                  </button>
                </div>
              </div>

              <!-- Bottom Action Bar -->
              <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-3 text-slate-500">
                <button
                  type="button"
                  @click="duplicateField(fIdx)"
                  class="p-2 text-slate-600 hover:text-brand-navy hover:bg-slate-100 rounded-xl transition-colors cursor-pointer flex items-center gap-1.5 text-xs font-semibold"
                  title="Duplikat Pertanyaan Ini"
                >
                  <i class="fa-solid fa-clone"></i>
                  <span>Duplikat</span>
                </button>

                <button
                  type="button"
                  @click="removeField(fIdx)"
                  class="p-2 text-slate-600 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-colors cursor-pointer flex items-center gap-1.5 text-xs font-semibold"
                  title="Hapus Pertanyaan Ini"
                >
                  <i class="fa-regular fa-trash-can"></i>
                  <span>Hapus</span>
                </button>

                <div class="flex items-center gap-1">
                  <button
                    type="button"
                    @click="moveField(fIdx, 'up')"
                    :disabled="fIdx === 0"
                    class="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg disabled:opacity-30 cursor-pointer"
                    title="Geser Ke Atas"
                  >
                    <i class="fa-solid fa-arrow-up text-xs"></i>
                  </button>
                  <button
                    type="button"
                    @click="moveField(fIdx, 'down')"
                    :disabled="fIdx === schema.length - 1"
                    class="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg disabled:opacity-30 cursor-pointer"
                    title="Geser Ke Bawah"
                  >
                    <i class="fa-solid fa-arrow-down text-xs"></i>
                  </button>
                </div>

                <div class="w-px h-5 bg-slate-200 mx-1"></div>

                <label class="relative inline-flex items-center gap-2 cursor-pointer select-none shrink-0">
                  <span class="text-xs font-bold text-slate-700">Wajib diisi</span>
                  <div class="relative inline-block w-9 h-5 align-middle">
                    <input type="checkbox" v-model="field.is_required" class="sr-only peer" />
                    <div class="w-9 h-5 bg-slate-200 rounded-full peer-checked:bg-brand-navy transition-colors"></div>
                    <div class="absolute top-[2px] left-[2px] bg-white border border-slate-300 rounded-full h-4 w-4 transition-transform peer-checked:translate-x-4 peer-checked:border-white pointer-events-none"></div>
                  </div>
                </label>
              </div>

              <!-- Advanced Settings Details -->
              <details class="text-[11px] text-slate-500 pt-1">
                <summary class="cursor-pointer hover:text-brand-navy font-semibold flex items-center gap-1">
                  <i class="fa-solid fa-gear text-slate-400"></i>
                  <span>Pengaturan Lanjutan (Placeholder & Kode Sistem)</span>
                </summary>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
                  <div>
                    <label class="block text-[10px] font-bold uppercase text-slate-500 mb-0.5">Placeholder</label>
                    <input
                      type="text"
                      v-model="field.placeholder"
                      placeholder="Petunjuk isian..."
                      class="w-full px-2.5 py-1.5 bg-slate-50 border border-slate-200 rounded-lg text-xs"
                    />
                  </div>
                  <div>
                    <label class="block text-[10px] font-bold uppercase text-slate-500 mb-0.5">Kode Kunci Variable (Word/DB)</label>
                    <input
                      type="text"
                      v-model="field.name"
                      placeholder="kode_variabel"
                      class="w-full px-2.5 py-1.5 bg-slate-100 font-mono text-[11px] text-slate-700 border border-slate-200 rounded-lg"
                    />
                  </div>
                </div>
              </details>
            </div>
          </div>
        </div>

        <!-- MODE 2: PRATINJAU TAMPILAN SISWA -->
        <div v-else class="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200 shadow-md space-y-6">
          <div class="flex items-center justify-between border-b border-slate-100 pb-4">
            <div class="flex items-center gap-2.5">
              <div class="w-3.5 h-3.5 rounded-full bg-emerald-500 animate-pulse"></div>
              <div>
                <h3 class="text-sm font-extrabold uppercase tracking-wider text-brand-navy">Pratinjau Formulir Pengajuan Perizinan</h3>
                <p class="text-xs text-slate-500 mt-0.5">Simulasi tampilan sebenarnya di mata siswa saat mengisi formulir</p>
              </div>
            </div>
            <span class="px-3 py-1 rounded-full bg-slate-100 text-slate-600 font-mono text-xs font-bold">Tampilan Siswa</span>
          </div>

          <!-- Empty State in Preview -->
          <div v-if="schema.length === 0" class="py-12 text-center bg-slate-50 rounded-2xl border border-dashed border-slate-300 space-y-2">
            <i class="fa-solid fa-file-circle-question text-slate-400 text-2xl"></i>
            <h4 class="text-xs font-bold text-slate-700">Formulir Masih Kosong</h4>
            <p class="text-[11px] text-slate-500">Tambahkan pertanyaan pada editor untuk melihat simulasi tampilan formulir siswa.</p>
          </div>

          <div v-else class="space-y-4 text-sm">
            <!-- Custom Dynamic Fields Preview (100% Configurable) -->
            <div v-for="(f, idx) in schema" :key="f.id" class="space-y-1.5 p-4 bg-slate-50/60 rounded-xl border border-slate-200/80">
              <label class="block font-bold text-slate-800">
                <span>{{ idx + 1 }}. {{ f.label }}</span>
                <span v-if="f.is_required" class="text-rose-500 ml-1">*</span>
                <span v-else class="text-[10px] text-slate-400 font-normal ml-1.5">(Opsional)</span>
              </label>
              <p v-if="f.description" class="text-xs text-slate-500 mb-1 leading-relaxed">{{ f.description }}</p>

              <input
                v-if="f.type === 'text'"
                type="text"
                v-model="previewValues[f.name]"
                :placeholder="f.placeholder || 'Isikan teks...'"
                class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-brand-navy focus:outline-hidden"
              />

              <textarea
                v-else-if="f.type === 'textarea'"
                v-model="previewValues[f.name]"
                rows="3"
                :placeholder="f.placeholder || 'Isikan uraian...'"
                class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-brand-navy focus:outline-hidden"
              ></textarea>

              <select
                v-else-if="f.type === 'select'"
                v-model="previewValues[f.name]"
                class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-brand-navy focus:outline-hidden"
              >
                <option value="">-- Pilih {{ f.label }} --</option>
                <option v-for="opt in (f.options || [])" :key="opt" :value="opt">{{ opt }}</option>
              </select>

              <input
                v-else-if="f.type === 'number'"
                type="number"
                v-model="previewValues[f.name]"
                :placeholder="f.placeholder || '0'"
                class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-xs font-mono focus:ring-2 focus:ring-brand-navy focus:outline-hidden"
              />

              <input
                v-else-if="f.type === 'date'"
                type="date"
                v-model="previewValues[f.name]"
                class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-brand-navy focus:outline-hidden"
              />

              <label v-else-if="f.type === 'checkbox'" class="flex items-center gap-2 cursor-pointer pt-1">
                <input type="checkbox" v-model="previewValues[f.name]" class="w-4 h-4 rounded text-brand-navy" />
                <span class="text-xs text-slate-700 font-semibold">{{ f.label }}</span>
              </label>
            </div>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500 font-medium">
            <span>Total: <strong>{{ schema.length }}</strong> kolom kustom aktif</span>
            <button
              type="button"
              @click="saveSchema"
              :disabled="saving"
              class="px-5 py-2.5 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
            >
              <i v-if="saving" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-floppy-disk text-brand-gold"></i>
              <span>Simpan Konfigurasi Ini</span>
            </button>
          </div>
        </div>
      </div>

      <!-- TAB 2: TEMPLATE & FORMAT DOCX -->
      <div v-else class="space-y-6">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          <!-- LEFT: Template & Kop Controls (7 cols) -->
          <div class="lg:col-span-7 space-y-6">
            <!-- 1. Kop Surat Setting -->
            <div class="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs space-y-4">
              <div class="flex items-center justify-between border-b border-slate-100 pb-3">
                <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <i class="fa-solid fa-heading text-brand-blue"></i>
                  <span>Tipe Kop Surat Kedinasan</span>
                </h3>
              </div>

              <div class="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  @click="letterheadType = 'text'"
                  :class="[
                    'p-3.5 rounded-xl border text-left transition-all cursor-pointer space-y-1',
                    letterheadType === 'text' ? 'border-brand-navy bg-blue-50/50 ring-2 ring-blue-100' : 'border-slate-200 hover:bg-slate-50'
                  ]"
                >
                  <p class="font-bold text-xs text-brand-navy">Teks Standar Kedinasan</p>
                  <p class="text-[11px] text-slate-500">Kop teks resmi dengan garis ganda kedinasan.</p>
                </button>

                <button
                  type="button"
                  @click="letterheadType = 'image'"
                  :class="[
                    'p-3.5 rounded-xl border text-left transition-all cursor-pointer space-y-1',
                    letterheadType === 'image' ? 'border-brand-navy bg-blue-50/50 ring-2 ring-blue-100' : 'border-slate-200 hover:bg-slate-50'
                  ]"
                >
                  <p class="font-bold text-xs text-brand-navy">Gambar Kop Sekolah (.PNG / .JPG)</p>
                  <p class="text-[11px] text-slate-500">Unggah berkas banner kop resmi sekolah.</p>
                </button>
              </div>

              <div v-if="letterheadType === 'image'" class="p-4 bg-slate-50 rounded-xl border border-slate-200 space-y-3">
                <div v-if="letterheadImagePreview" class="relative group max-w-md mx-auto bg-white p-2 border rounded-lg">
                  <img :src="letterheadImagePreview" alt="Kop Gambar" class="max-h-24 object-contain mx-auto" />
                  <button
                    type="button"
                    @click="handleRemoveLetterhead"
                    class="absolute top-2 right-2 bg-rose-600 text-white p-1 rounded-full text-xs hover:bg-rose-700"
                  >
                    <i class="fa-solid fa-xmark"></i>
                  </button>
                </div>
                <input
                  type="file"
                  accept="image/*"
                  @change="handleLetterheadChange"
                  class="w-full text-xs text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:bg-brand-navy file:text-white"
                />

                <!-- Penyesuaian Presisi & Ukuran Kop (Kop Adjustment) -->
                <div class="p-4 bg-blue-50/60 rounded-xl border border-blue-200/90 space-y-4 text-left">
                  <div class="flex items-center justify-between">
                    <h4 class="text-xs font-bold text-brand-navy flex items-center gap-1.5">
                      <i class="fa-solid fa-sliders text-brand-blue"></i>
                      <span>Penyesuaian Ukuran & Presisi Kop (Kop Adjustment)</span>
                    </h4>
                    <span class="text-[10px] font-semibold text-blue-800 bg-blue-100 px-2 py-0.5 rounded-full">Fit Kertas A4</span>
                  </div>

                  <!-- 1. Mode Fit Lebar -->
                  <div>
                    <label class="block text-[11px] font-bold text-slate-700 mb-1.5">Model Skala Lebar Kop Surat</label>
                    <div class="grid grid-cols-2 gap-2">
                      <button
                        type="button"
                        @click="letterConfig.header_width_mode = 'contained'"
                        :class="[
                          'p-2.5 rounded-xl border text-left text-xs font-medium transition-all cursor-pointer flex items-center gap-2',
                          letterConfig.header_width_mode === 'contained' || !letterConfig.header_width_mode
                            ? 'border-brand-navy bg-white text-brand-navy font-bold shadow-2xs'
                            : 'border-slate-200 bg-slate-50 text-slate-600 hover:bg-white'
                        ]"
                      >
                        <i class="fa-solid fa-expand text-brand-blue"></i>
                        <div>
                          <p class="leading-tight">Proporsional (Auto Fit)</p>
                          <p class="text-[9.5px] text-slate-400 font-normal">Sesuai rasio asli gambar</p>
                        </div>
                      </button>

                      <button
                        type="button"
                        @click="letterConfig.header_width_mode = 'full'"
                        :class="[
                          'p-2.5 rounded-xl border text-left text-xs font-medium transition-all cursor-pointer flex items-center gap-2',
                          letterConfig.header_width_mode === 'full'
                            ? 'border-brand-navy bg-white text-brand-navy font-bold shadow-2xs'
                            : 'border-slate-200 bg-slate-50 text-slate-600 hover:bg-white'
                        ]"
                      >
                        <i class="fa-solid fa-arrows-left-right text-emerald-600"></i>
                        <div>
                          <p class="leading-tight">Pas Lebar Kertas (100%)</p>
                          <p class="text-[9.5px] text-slate-400 font-normal">Mentok batas margin A4</p>
                        </div>
                      </button>
                    </div>
                  </div>

                  <!-- 2. Batas Tinggi Maksimal & Alignment & Margin Bottom -->
                  <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div v-if="letterConfig.header_width_mode !== 'full'">
                      <label class="block text-[11px] font-bold text-slate-700 mb-1">
                        Tinggi Maksimal: <span class="text-brand-navy font-mono">{{ letterConfig.header_max_height || 130 }}px</span>
                      </label>
                      <input
                        type="range"
                        min="50"
                        max="250"
                        step="5"
                        v-model.number="letterConfig.header_max_height"
                        class="w-full accent-brand-navy cursor-pointer"
                      />
                    </div>

                    <div>
                      <label class="block text-[11px] font-bold text-slate-700 mb-1">Posisi / Alignment</label>
                      <select
                        v-model="letterConfig.header_alignment"
                        class="w-full rounded-lg border border-slate-300 p-1.5 text-xs bg-white text-slate-800 font-medium focus:border-brand-navy focus:outline-hidden"
                      >
                        <option value="center">Tengah (Center)</option>
                        <option value="left">Kiri (Left)</option>
                        <option value="right">Kanan (Right)</option>
                      </select>
                    </div>

                    <div>
                      <label class="block text-[11px] font-bold text-slate-700 mb-1">
                        Margin Bawah: <span class="text-brand-navy font-mono">{{ letterConfig.header_margin_bottom || 10 }}px</span>
                      </label>
                      <input
                        type="range"
                        min="0"
                        max="40"
                        step="2"
                        v-model.number="letterConfig.header_margin_bottom"
                        class="w-full accent-brand-navy cursor-pointer"
                      />
                    </div>
                  </div>
                </div>
              </div>

              <div v-else class="space-y-3 pt-2">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Baris 1 (Instansi Induk / Pemda)</label>
                    <input v-model="letterConfig.institution_level1" type="text" class="w-full rounded-xl border border-slate-300 p-2 text-xs focus:border-brand-navy" />
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Baris 2 (Dinas / Yayasan)</label>
                    <input v-model="letterConfig.institution_level2" type="text" class="w-full rounded-xl border border-slate-300 p-2 text-xs focus:border-brand-navy" />
                  </div>
                </div>
              </div>
            </div>

            <!-- 2. Template DOCX Kustom with Auto Generate -->
            <div class="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs space-y-4">
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <i class="fa-solid fa-file-word text-blue-600"></i>
                    <span>Template Microsoft Word (.docx) Kustom</span>
                  </h3>
                  <p class="text-xs text-slate-500 mt-0.5">
                    Unggah berkas Word (.docx) khusus jika sekolah Anda memiliki format naskah perizinan lomba mandiri.
                  </p>
                </div>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  {{ hasCustomDocx ? 'Ganti File Template DOCX' : 'Unggah File Template DOCX Kustom' }}
                </label>
                <div class="flex flex-col sm:flex-row gap-2">
                  <input
                    type="file"
                    accept=".docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    @change="handleDocxChange"
                    class="w-full text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-blue-700 file:text-white hover:file:bg-blue-800 cursor-pointer text-xs"
                  />
                  <button
                    v-if="docxTemplateFile"
                    type="button"
                    @click="autoGenerateFromDocx"
                    :disabled="parsingDocx"
                    class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center justify-center gap-1.5 shrink-0 cursor-pointer disabled:opacity-50"
                  >
                    <i v-if="parsingDocx" class="fa-solid fa-spinner fa-spin text-xs"></i>
                    <i v-else class="fa-solid fa-wand-magic-sparkles text-amber-300"></i>
                    <span>Generate Form Dinamis</span>
                  </button>
                </div>
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
                  <p><code>${TINGKATAN_LOMBA}</code> : Tingkat lomba (Kabupaten/Provinsi/Nasional/Internasional)</p>
                  <p><code>${TANGGAL_MULAI}</code> : Tanggal mulai pelaksanaan</p>
                  <p><code>${TANGGAL_SELESAI}</code> : Tanggal selesai pelaksanaan</p>
                  <p><code>${SEKOLAH_NAMA}</code> : Nama instansi sekolah</p>
                </div>
              </details>
            </div>
          </div>

          <!-- RIGHT: Live Paper Preview A4 (5 Cols) -->
          <div class="lg:col-span-5 sticky top-6 space-y-4">
            <div class="bg-white rounded-2xl p-4 sm:p-5 border border-slate-200/80 shadow-xs space-y-3">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                  <i class="fa-solid fa-eye text-brand-blue"></i>
                  <span>Simulasi Tampilan Kertas (A4)</span>
                </span>
                <span class="text-[10px] font-mono text-slate-400">Pratinjau Nyata</span>
              </div>

              <div class="bg-white p-5 rounded-lg border border-slate-300 shadow-sm text-black font-serif text-[10px] space-y-2.5">
                <div
                  v-if="letterheadType === 'image' && letterheadImagePreview"
                  class="w-full text-center pb-1 border-b border-slate-200 transition-all"
                  :style="{
                    marginBottom: (letterConfig.header_margin_bottom || 10) + 'px',
                    textAlign: (letterConfig.header_alignment || 'center') as any
                  }"
                >
                  <img
                    :src="letterheadImagePreview"
                    alt="Kop Gambar"
                    :style="{
                      width: letterConfig.header_width_mode === 'full' ? '100%' : 'auto',
                      maxWidth: '100%',
                      maxHeight: letterConfig.header_width_mode === 'full' ? 'none' : ((letterConfig.header_max_height || 130) * 0.45) + 'px',
                      objectFit: (letterConfig.header_width_mode === 'full' ? 'fill' : 'contain') as any,
                      display: 'block',
                      margin: letterConfig.header_alignment === 'left' ? '0 auto 0 0' : letterConfig.header_alignment === 'right' ? '0 0 0 auto' : '0 auto'
                    }"
                  />
                </div>
                <div v-else class="text-center pb-1">
                  <p class="font-bold uppercase tracking-wider text-[9px]">{{ letterConfig.institution_level1 }}</p>
                  <p class="font-bold uppercase text-[9.5px]">{{ letterConfig.institution_level2 }}</p>
                  <p class="font-black uppercase text-[11px] leading-tight">{{ schoolName }}</p>
                  <div class="mt-1.5 border-t-2 border-black"></div>
                  <div class="mt-0.5 border-t border-black"></div>
                </div>

                <div class="text-center pt-1 space-y-0.5">
                  <p class="font-bold underline uppercase text-[10px]">{{ letterConfig.document_title }}</p>
                  <p class="font-sans text-[8.5px] text-slate-600">Nomor: {{ letterConfig.reference_number_prefix }}/2026/001</p>
                </div>

                <p class="font-sans text-[9px] leading-relaxed text-slate-800">
                  Yang bertanda tangan di bawah ini menerangkan bahwa siswa di bawah ini diberikan rekomendasi & izin mengikuti ajang kompetisi:
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
