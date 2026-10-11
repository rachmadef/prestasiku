<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const loadingOptions = ref(true)
const submitting = ref(false)
const submitSuccess = ref(false)
const submittedData = ref<any>(null)
const errorMessage = ref('')

// Form Options from backend
const curatedCompetitions = ref<any[]>([])
const participatedCompetitions = ref<any[]>([])
const studentsList = ref<any[]>([])
const selectedParticipatedIdx = ref<string>('')

// Form State matching FORM PENDAMPING PERLOMBAAN.docx
const form = ref({
  competition_id: null as number | null,
  competition_name: '',
  organizer_name: '',
  competition_branch: '',
  student_names: '',
  student_ids: [] as number[],
  competition_category: 'SMA / MA',
  competition_place: '',
  competition_level: 'kabupaten',
  event_date: '',
  supervisor_name: '',
  supervisor_nip: '',
  supervisor_phone: '',
  supervisor_category: 'Guru',
  supervisor_gender: 'Laki-laki',
  role_title: 'Guru Pembimbing',
  duty_zone: 'dalam_kota',
  bisyaroh_amount: 0,
  notes: '',
  statement_agreed: true,
})

// Student picker search
const studentSearchQuery = ref('')
const showStudentDropdown = ref(false)

const filteredStudents = computed(() => {
  if (!studentSearchQuery.value) return studentsList.value.slice(0, 15)
  const q = studentSearchQuery.value.toLowerCase().trim()
  return studentsList.value.filter((s) => {
    const matchName = s.full_name && s.full_name.toLowerCase().includes(q)
    const matchClass = s.class_name && s.class_name.toLowerCase().includes(q)
    const matchNisn = s.nisn && s.nisn.toLowerCase().includes(q)
    return matchName || matchClass || matchNisn
  }).slice(0, 20)
})

function closeStudentDropdown() {
  setTimeout(() => {
    showStudentDropdown.value = false
  }, 250)
}

async function fetchOptions() {
  loadingOptions.value = true
  try {
    const res = await api.get('/public/supervisor-form/options')
    if (res.data?.data) {
      curatedCompetitions.value = res.data.data.curated_competitions || []
      participatedCompetitions.value = res.data.data.participated_competitions || []
      studentsList.value = res.data.data.students || []
    }
  } catch (err) {
    console.error('Error fetching options:', err)
  } finally {
    loadingOptions.value = false
  }
}

// Quick Autofill from Student Competition History
function handleParticipatedSelect() {
  if (selectedParticipatedIdx.value === '' || selectedParticipatedIdx.value === 'manual') {
    return
  }
  const idx = Number(selectedParticipatedIdx.value)
  const item = participatedCompetitions.value[idx]
  if (item) {
    form.value.competition_id = item.competition_id || null
    form.value.competition_name = item.competition_name || ''
    form.value.competition_branch = item.competition_branch || ''
    form.value.student_names = item.student_names || ''
    form.value.competition_level = item.competition_level || 'kabupaten'
    form.value.competition_place = item.competition_place || ''
    form.value.event_date = item.event_date || ''
    if (item.students && item.students.length > 0) {
      form.value.student_ids = item.students.map((s: any) => s.id)
    }
  }
}

function addStudentFromPicker(student: any) {
  if (!form.value.student_ids.includes(student.id)) {
    form.value.student_ids.push(student.id)
  }
  const currentNames = form.value.student_names
    ? form.value.student_names.split(',').map((s) => s.trim()).filter(Boolean)
    : []
  if (!currentNames.includes(student.full_name)) {
    currentNames.push(student.full_name)
    form.value.student_names = currentNames.join(', ')
  }
  studentSearchQuery.value = ''
  showStudentDropdown.value = false
}

function removeStudentName(nameToRemove: string) {
  const names = form.value.student_names
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s && s !== nameToRemove)
  form.value.student_names = names.join(', ')
}

const parsedStudentNames = computed(() => {
  if (!form.value.student_names) return []
  return form.value.student_names.split(',').map((s) => s.trim()).filter(Boolean)
})

async function submitForm() {
  errorMessage.value = ''
  if (!form.value.competition_name || !form.value.supervisor_name || !form.value.supervisor_phone) {
    errorMessage.value = 'Mohon lengkapi Nama Lomba, Nama Pendamping, dan Nomor WhatsApp Anda.'
    return
  }
  if (!form.value.statement_agreed) {
    errorMessage.value = 'Anda harus menyetujui pernyataan dan persetujuan pendampingan lomba.'
    return
  }

  submitting.value = true
  try {
    const res = await api.post('/public/supervisor-form/submit', form.value)
    if (res.data?.success) {
      submitSuccess.value = true
      submittedData.value = res.data.data
    }
  } catch (err: any) {
    errorMessage.value = err.response?.data?.message || 'Gagal mengirim formulir. Mohon periksa kembali isian Anda.'
  } finally {
    submitting.value = false
  }
}

function downloadDocx() {
  if (!submittedData.value?.public_token) return
  window.open(`/api/v1/public/supervisor-form/${submittedData.value.public_token}/download-docx`, '_blank')
}

function downloadPdf() {
  if (!submittedData.value?.public_token) return
  window.open(`/api/v1/public/supervisor-form/${submittedData.value.public_token}/download-pdf`, '_blank')
}

function printLetter() {
  window.print()
}

function resetForm() {
  form.value = {
    competition_id: null,
    competition_name: '',
    organizer_name: '',
    competition_branch: '',
    student_names: '',
    student_ids: [],
    competition_category: 'SMA / MA',
    competition_place: '',
    competition_level: 'kabupaten',
    event_date: '',
    supervisor_name: '',
    supervisor_nip: '',
    supervisor_phone: '',
    supervisor_category: 'Guru',
    supervisor_gender: 'Laki-laki',
    role_title: 'Guru Pembimbing',
    duty_zone: 'dalam_kota',
    bisyaroh_amount: 0,
    notes: '',
    statement_agreed: true,
  }
  selectedParticipatedIdx.value = ''
  submitSuccess.value = false
  submittedData.value = null
  errorMessage.value = ''
}

function formatCurrency(val: number) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}

onMounted(() => {
  fetchOptions()
})
</script>

<template>
  <div class="min-h-screen bg-slate-100/70 text-slate-800 font-sans py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-3xl mx-auto">
      
      <!-- Top Branding Header -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-200/90 overflow-hidden mb-6">
        <div class="bg-gradient-to-r from-[#001f5b] via-[#002f87] to-[#0a4bb3] p-6 sm:p-8 text-white relative">
          <div class="flex flex-col sm:flex-row items-center sm:items-start gap-4">
            <div class="w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-md border border-white/20 flex items-center justify-center shrink-0 shadow-inner">
              <i class="fa-solid fa-graduation-cap text-3xl text-amber-300"></i>
            </div>
            <div class="text-center sm:text-left space-y-1">
              <div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-amber-400/20 text-amber-300 text-[11px] font-bold tracking-wide uppercase">
                <i class="fa-solid fa-file-signature"></i>
                Portal Pelayanan Resmi
              </div>
              <h1 class="text-xl sm:text-2xl font-black tracking-tight text-white">
                FORM PENDAMPING PERLOMBAAN
              </h1>
              <p class="text-xs sm:text-sm text-blue-100 font-medium">
                MA Unggulan K.H. Abd. Wahab Hasbulloh Tambakberas Jombang
              </p>
            </div>
          </div>
        </div>

        <div class="px-6 py-4 bg-slate-50 border-t border-slate-200/80 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-600">
          <div class="flex items-center gap-2">
            <i class="fa-solid fa-shield-halved text-emerald-600 text-sm"></i>
            <span>Formulir Penetapan Guru Pendamping Lomba Siswa Terintegrasi</span>
          </div>
          <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md bg-slate-200/80 text-slate-700 font-mono text-[11px] font-semibold">
            Tahun Ajaran 2026/2027
          </span>
        </div>
      </div>

      <!-- SUCCESS STATE BANNER -->
      <div v-if="submitSuccess" class="bg-white rounded-2xl shadow-md border border-emerald-200 p-6 sm:p-8 text-center space-y-5 animate-fade-in">
        <div class="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto text-2xl shadow-inner">
          <i class="fa-solid fa-check-double"></i>
        </div>
        <div class="space-y-1">
          <h2 class="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
            Formulir Pendamping Berhasil Dikirim!
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 max-w-lg mx-auto">
            Terima kasih Bapak/Ibu <strong>{{ submittedData?.supervisor_name }}</strong>. Data pendampingan untuk ajang <strong>{{ submittedData?.competition_name }}</strong> telah tersimpan dalam database instansi.
          </p>
          <div class="pt-2">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-slate-100 border border-slate-200 font-mono text-xs font-bold text-brand-navy">
              <i class="fa-solid fa-hashtag text-slate-400"></i> No. Register: {{ submittedData?.reference_number }}
            </span>
          </div>
        </div>

        <!-- Download & Print Action Buttons -->
        <div class="p-4 rounded-xl bg-slate-50 border border-slate-200/80 max-w-md mx-auto space-y-3">
          <p class="text-xs font-bold text-slate-700 uppercase tracking-wider">
            Dokumen & Bukti Formulir Surat:
          </p>
          <div class="flex flex-col sm:flex-row items-center justify-center gap-2.5">
            <button
              type="button"
              @click="downloadDocx"
              class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-blue-700 hover:bg-blue-800 text-white text-xs font-bold shadow-xs transition-all cursor-pointer"
            >
              <i class="fa-solid fa-file-word text-sm"></i>
              <span>Unduh Word (.docx)</span>
            </button>
            <button
              type="button"
              @click="downloadPdf"
              class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-rose-700 hover:bg-rose-800 text-white text-xs font-bold shadow-xs transition-all cursor-pointer"
            >
              <i class="fa-solid fa-file-pdf text-sm"></i>
              <span>Unduh PDF</span>
            </button>
            <button
              type="button"
              @click="printLetter"
              class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-900 text-white text-xs font-bold shadow-xs transition-all cursor-pointer"
            >
              <i class="fa-solid fa-print text-sm"></i>
              <span>Cetak Surat</span>
            </button>
          </div>
        </div>

        <div class="pt-2">
          <button
            type="button"
            @click="resetForm"
            class="text-xs text-brand-navy font-bold hover:underline cursor-pointer"
          >
            <i class="fa-solid fa-rotate-left mr-1"></i> Isi Formulir Pendamping Baru
          </button>
        </div>
      </div>

      <!-- FORM SUBMISSION SECTION -->
      <form v-else @submit.prevent="submitForm" class="space-y-6">
        
        <!-- Error Alert -->
        <div v-if="errorMessage" class="p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs sm:text-sm font-semibold flex items-center gap-2.5">
          <i class="fa-solid fa-circle-exclamation text-rose-600 text-base shrink-0"></i>
          <span>{{ errorMessage }}</span>
        </div>

        <!-- QUICK SELECTOR: Selaras dengan data lomba siswa yang sudah pernah diikuti -->
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-blue-200/90 shadow-xs space-y-4">
          <div class="flex items-start gap-3">
            <div class="w-9 h-9 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center shrink-0 text-base">
              <i class="fa-solid fa-wand-magic-sparkles"></i>
            </div>
            <div>
              <h3 class="text-sm font-bold text-slate-900">
                Pilih Cepat dari Riwayat Lomba Peserta Didik
              </h3>
              <p class="text-xs text-slate-500 mt-0.5 leading-relaxed">
                Pilih lomba yang telah diajukan dispensasi/diikuti oleh siswa madrasah agar data terisi secara otomatis dan selaras.
              </p>
            </div>
          </div>

          <div>
            <select
              v-model="selectedParticipatedIdx"
              @change="handleParticipatedSelect"
              class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-800 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
            >
              <option value="">-- Pilih dari Riwayat Lomba Siswa (Opsional) --</option>
              <option
                v-for="(comp, idx) in participatedCompetitions"
                :key="idx"
                :value="idx"
              >
                🏆 {{ comp.competition_name }} ({{ comp.competition_level.toUpperCase() }}) — Peserta: {{ comp.student_names || 'Siswa' }}
              </option>
              <option value="manual">✏️ Lomba Baru / Input Manual Sendiri</option>
            </select>
          </div>
        </div>

        <!-- BAGIAN A: DATA PERLOMBAAN -->
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-slate-200/90 shadow-xs space-y-4">
          <div class="flex items-center gap-2.5 pb-2 border-b border-slate-100">
            <span class="w-6 h-6 rounded-lg bg-[#001f5b] text-white text-xs font-black flex items-center justify-center">A</span>
            <h2 class="text-sm font-black text-slate-900 uppercase tracking-wide">
              Data Perlombaan
            </h2>
          </div>

          <div class="space-y-4">
            <!-- Nama Penyelenggara/nama perlombaan -->
            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">
                Nama Penyelenggara / Nama Perlombaan <span class="text-rose-500">*</span>
              </label>
              <input
                v-model="form.competition_name"
                type="text"
                required
                placeholder="Contoh: Olimpiade Sains Nasional (OSN) 2026 / Lomba Kaligrafi"
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
              />
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <!-- Cabang Lomba yang Diikuti -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Cabang Lomba yang Diikuti
                </label>
                <input
                  v-model="form.competition_branch"
                  type="text"
                  placeholder="Contoh: Matematika, Fisika, Kaligrafi, Riset OPSI"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
                />
              </div>

              <!-- Kategori Lomba -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Kategori Lomba
                </label>
                <select
                  v-model="form.competition_category"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
                >
                  <option value="SMA / MA">SMA / MA</option>
                  <option value="SMP / MTs">SMP / MTs</option>
                  <option value="SD / MI">SD / MI</option>
                  <option value="Umum / Mahasiswa">Umum / Mahasiswa</option>
                </select>
              </div>
            </div>

            <!-- Nama Peserta / Tim yang Didampingi -->
            <div class="space-y-1.5">
              <label class="block text-xs font-bold text-slate-700">
                Nama Peserta / Tim yang Didampingi
              </label>
              
              <!-- Quick search picker from student database -->
              <div class="relative">
                <div class="relative">
                  <input
                    v-model="studentSearchQuery"
                    @focus="showStudentDropdown = true"
                    @input="showStudentDropdown = true"
                    @blur="closeStudentDropdown"
                    type="text"
                    placeholder="🔍 Cari nama siswa terdaftar untuk ditambahkan..."
                    class="w-full text-xs rounded-xl border border-slate-300 bg-blue-50/50 px-3.5 py-2.5 pr-8 text-slate-800 placeholder-slate-400 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all font-medium"
                  />
                  <button
                    v-if="studentSearchQuery"
                    type="button"
                    @mousedown.prevent="studentSearchQuery = ''; showStudentDropdown = true"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs cursor-pointer"
                  >
                    <i class="fa-solid fa-circle-xmark"></i>
                  </button>
                </div>
                
                <div
                  v-if="showStudentDropdown && filteredStudents.length > 0"
                  class="absolute z-30 top-full left-0 right-0 mt-1 max-h-56 overflow-y-auto bg-white rounded-xl shadow-xl border border-slate-200 py-1.5 text-xs divide-y divide-slate-100"
                >
                  <div
                    v-for="s in filteredStudents"
                    :key="s.id"
                    @mousedown.prevent="addStudentFromPicker(s)"
                    class="px-3.5 py-2 hover:bg-blue-50/80 cursor-pointer flex items-center justify-between transition-colors"
                  >
                    <div>
                      <div class="font-bold text-slate-800 flex items-center gap-1.5">
                        <i class="fa-solid fa-user-graduate text-blue-600 text-[10px]"></i>
                        <span>{{ s.full_name }}</span>
                      </div>
                      <div class="text-[10px] text-slate-400 font-mono mt-0.5" v-if="s.nisn">
                        NISN: {{ s.nisn }}
                      </div>
                    </div>
                    <span class="text-[11px] font-semibold text-blue-700 bg-blue-50 border border-blue-200 px-2 py-0.5 rounded-md font-mono shrink-0">
                      {{ s.class_name || s.class_room || '-' }}
                    </span>
                  </div>
                </div>

                <div
                  v-else-if="showStudentDropdown && studentSearchQuery && filteredStudents.length === 0"
                  class="absolute z-30 top-full left-0 right-0 mt-1 p-3 bg-white rounded-xl shadow-xl border border-slate-200 text-center text-xs text-slate-500"
                >
                  Tidak ditemukan siswa dengan nama "<strong class="text-slate-700">{{ studentSearchQuery }}</strong>". Anda dapat mengetik langsung pada kotak isian di bawah.
                </div>
              </div>

              <!-- Badges of selected students -->
              <div v-if="parsedStudentNames.length > 0" class="flex flex-wrap gap-1.5 pt-1">
                <span
                  v-for="(name, nIdx) in parsedStudentNames"
                  :key="nIdx"
                  class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-blue-100 text-blue-900 text-xs font-semibold"
                >
                  <i class="fa-solid fa-user-graduate text-[10px]"></i>
                  {{ name }}
                  <button
                    type="button"
                    @click="removeStudentName(name)"
                    class="text-blue-600 hover:text-rose-600 ml-0.5 cursor-pointer"
                  >
                    &times;
                  </button>
                </span>
              </div>

              <textarea
                v-model="form.student_names"
                rows="2"
                placeholder="Atau ketik langsung nama siswa/tim yang didampingi..."
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
              ></textarea>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <!-- Tempat Perlombaan -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Tempat Perlombaan
                </label>
                <input
                  v-model="form.competition_place"
                  type="text"
                  placeholder="Contoh: Lab Biologi Gedung B / Universitas Airlangga Surabaya"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
                />
              </div>

              <!-- Tingkat Perlombaan -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Tingkat Perlombaan
                </label>
                <select
                  v-model="form.competition_level"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all capitalize"
                >
                  <option value="kabupaten">Kabupaten/Kota</option>
                  <option value="provinsi">Provinsi</option>
                  <option value="nasional">Nasional</option>
                  <option value="internasional">Internasional</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <!-- BAGIAN B: DATA DIRI PENDAMPING -->
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-slate-200/90 shadow-xs space-y-4">
          <div class="flex items-center gap-2.5 pb-2 border-b border-slate-100">
            <span class="w-6 h-6 rounded-lg bg-[#001f5b] text-white text-xs font-black flex items-center justify-center">B</span>
            <h2 class="text-sm font-black text-slate-900 uppercase tracking-wide">
              Data Diri Pendamping
            </h2>
          </div>

          <div class="space-y-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <!-- Nama Lengkap dan Gelar -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  1. Nama Lengkap dan Gelar <span class="text-rose-500">*</span>
                </label>
                <input
                  v-model="form.supervisor_name"
                  type="text"
                  required
                  placeholder="Contoh: Drs. H. Ahmad Dahlan, M.Pd."
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all font-semibold"
                />
              </div>

              <!-- Kategori Pendamping -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  2. Kategori Pendamping <span class="text-rose-500">*</span>
                </label>
                <select
                  v-model="form.supervisor_category"
                  required
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
                >
                  <option value="Guru">Guru</option>
                  <option value="Pelatih">Pelatih</option>
                  <option value="Tenaga Kependidikan (Admin / Staf / Magang)">Tenaga Kependidikan (Admin / Staf / Magang)</option>
                  <option value="Pembimbing (Eksternal / Akademik / Pembina)">Pembimbing (Eksternal / Akademik / Pembina)</option>
                  <option value="Koordinator Prestasi">Koordinator Prestasi</option>
                </select>
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <!-- Jabatan / Mata Pelajaran / Unit Kerja -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  3. Jabatan / Mata Pelajaran / Unit Kerja <span class="text-rose-500">*</span>
                </label>
                <input
                  v-model="form.role_title"
                  type="text"
                  required
                  placeholder="Contoh: Guru Fisika / Pembina KIR"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
                />
              </div>

              <!-- Jenis Kelamin -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  4. Jenis Kelamin <span class="text-rose-500">*</span>
                </label>
                <div class="flex items-center gap-6 pt-2">
                  <label class="inline-flex items-center gap-2 text-xs sm:text-sm cursor-pointer">
                    <input
                      v-model="form.supervisor_gender"
                      type="radio"
                      value="Laki-laki"
                      class="text-blue-600 focus:ring-blue-500"
                    />
                    <span>Laki-laki</span>
                  </label>
                  <label class="inline-flex items-center gap-2 text-xs sm:text-sm cursor-pointer">
                    <input
                      v-model="form.supervisor_gender"
                      type="radio"
                      value="Perempuan"
                      class="text-blue-600 focus:ring-blue-500"
                    />
                    <span>Perempuan</span>
                  </label>
                </div>
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <!-- Nomor WhatsApp / HP -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  5. Nomor WhatsApp / HP (Aktif) <span class="text-rose-500">*</span>
                </label>
                <input
                  v-model="form.supervisor_phone"
                  type="text"
                  required
                  placeholder="Contoh: 081234567890"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all font-mono"
                />
              </div>

              <!-- NIP / NIK -->
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  NIP / NIK Pendamping
                </label>
                <input
                  v-model="form.supervisor_nip"
                  type="text"
                  placeholder="Opsional (misal: 198501...)"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all font-mono"
                />
              </div>
            </div>

            <!-- Catatan / Rincian Tugas (Opsional) -->
            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">
                Catatan Rincian Tugas / SOP (Opsional)
              </label>
              <textarea
                v-model="form.notes"
                rows="2"
                placeholder="Tambahkan catatan khusus teknis tugas pendampingan bila ada..."
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50 px-3.5 py-2.5 text-slate-900 focus:bg-white focus:border-blue-600 focus:ring-2 focus:ring-blue-100 focus:outline-hidden transition-all"
              ></textarea>
            </div>
          </div>
        </div>

        <!-- BAGIAN C: PERNYATAAN DAN PERSETUJUAN -->
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-slate-200/90 shadow-xs space-y-4">
          <div class="flex items-center gap-2.5 pb-2 border-b border-slate-100">
            <span class="w-6 h-6 rounded-lg bg-amber-600 text-white text-xs font-black flex items-center justify-center">C</span>
            <h2 class="text-sm font-black text-slate-900 uppercase tracking-wide">
              Pernyataan dan Persetujuan
            </h2>
          </div>

          <div class="p-4 rounded-xl bg-amber-50/70 border border-amber-200/80 text-xs sm:text-sm text-slate-700 space-y-2.5 leading-relaxed">
            <strong class="font-bold text-amber-950 block">Dengan mengisi formulir ini, saya menyatakan bahwa:</strong>
            <ol class="list-decimal pl-5 space-y-1">
              <li>Data yang saya isikan di atas adalah benar dan dapat dipertanggungjawabkan.</li>
              <li>Saya ditugaskan secara resmi oleh sekolah/instansi/lembaga sebagai pendamping peserta perlombaan.</li>
              <li>Saya bersedia mendampingi peserta, serta mematuhi seluruh tata tertib dan regulasi perlombaan yang ditetapkan panitia.</li>
            </ol>
          </div>

          <label class="flex items-start gap-3 cursor-pointer pt-1">
            <input
              v-model="form.statement_agreed"
              type="checkbox"
              required
              class="w-4 h-4 rounded-md text-blue-600 focus:ring-blue-500 mt-0.5"
            />
            <span class="text-xs font-bold text-slate-800 leading-snug">
              Saya telah membaca, memahami, dan menyetujui seluruh ketentuan pernyataan pendamping perlombaan di atas.
            </span>
          </label>
        </div>

        <!-- SUBMIT BUTTON -->
        <div class="pt-2">
          <button
            type="submit"
            :disabled="submitting"
            class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-[#001f5b] to-[#0038a8] hover:from-[#001642] hover:to-[#002f8c] text-white text-sm sm:text-base font-black shadow-md hover:shadow-lg transition-all cursor-pointer flex items-center justify-center gap-3 disabled:opacity-60"
          >
            <i v-if="submitting" class="fa-solid fa-circle-notch fa-spin text-base"></i>
            <i v-else class="fa-solid fa-paper-plane text-amber-300"></i>
            <span>{{ submitting ? 'Memproses Formulir...' : 'Kirim Formulir Pendamping Perlombaan' }}</span>
          </button>
        </div>
      </form>

      <!-- Institutional Footer -->
      <div class="mt-8 text-center text-xs text-slate-500 space-y-1">
        <p class="font-semibold text-slate-600">MA Unggulan K.H. Abd. Wahab Hasbulloh Tambakberas Jombang</p>
        <p class="text-[11px] text-slate-400">Pondok Pesantren Bahrul Ulum &bull; Sistem Pengelolaan Prestasi & Insentif Guru</p>
      </div>

    </div>
  </div>
</template>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fade-in {
  animation: fadeIn 0.3s ease-out forwards;
}

@media print {
  body {
    background: white !important;
  }
}
</style>
