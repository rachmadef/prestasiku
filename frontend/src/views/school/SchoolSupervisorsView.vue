<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api from '@/services/api'
import { useNotify } from '@/composables/useNotify'
import { exportToExcel } from '@/utils/exportExcel'

const { toast } = useNotify()

interface Supervisor {
  id: number
  reference_number?: string
  supervisor_name: string
  supervisor_nip?: string
  supervisor_phone?: string
  supervisor_category?: string
  supervisor_gender?: string
  role_title: string
  competition_id?: number
  competition_name?: string
  competition_branch?: string
  student_names?: string
  student_ids?: number[]
  competition_category?: string
  competition_place?: string
  competition_level?: string
  duty_zone?: string
  bisyaroh_amount: number
  sop_category?: string
  notes?: string
  status: 'pending' | 'approved' | 'disbursed'
  public_token?: string
  created_at: string
  competition?: {
    id: number
    title: string
    level: string
    curation_type: string
  }
}

const supervisors = ref<Supervisor[]>([])
const curatedCompetitions = ref<any[]>([])
const participatedCompetitions = ref<any[]>([])
const studentsList = ref<any[]>([])
const loading = ref(true)
const submitting = ref(false)
const filterStatus = ref<'all' | 'pending' | 'approved' | 'disbursed'>('all')
const searchQuery = ref('')
const errorMessage = ref('')

// Modal state
const isModalOpen = ref(false)
const selectedParticipatedIdx = ref<string>('')

// Form state matching FORM PENDAMPING PERLOMBAAN.docx
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
  bisyaroh_amount: 50000,
  notes: '',
  statement_agreed: true,
})

const dutyRates: Record<string, number> = {
  dalam_kota: 50000,
  luar_kota: 100000,
  luar_provinsi: 150000,
  luar_negeri: 200000,
}

// Print Preview Modal state
const isPrintModalOpen = ref(false)
const printData = ref<Supervisor | null>(null)

// Student Picker in Modal
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

const publicLink = computed(() => {
  return window.location.origin + '/form-pendamping'
})

const fetchSupervisors = async () => {
  loading.value = true
  try {
    const response = await api.get('/school/supervisors', {
      params: {
        status: filterStatus.value !== 'all' ? filterStatus.value : undefined,
        search: searchQuery.value || undefined,
      }
    })
    supervisors.value = response.data.data.data || response.data.data || []
  } catch (err: any) {
    console.error('Error fetching supervisors:', err)
  } finally {
    loading.value = false
  }
}

const fetchOptions = async () => {
  try {
    const response = await api.get('/school/supervisors/eligible-competitions')
    const d = response.data.data
    curatedCompetitions.value = d.curated_competitions || []
    participatedCompetitions.value = d.participated_competitions || []
    studentsList.value = d.students || []
  } catch (err: any) {
    console.error('Error fetching supervisor options:', err)
  }
}

const filteredSupervisors = computed(() => {
  return supervisors.value.filter((item) => {
    const matchStatus = filterStatus.value === 'all' || item.status === filterStatus.value
    const query = searchQuery.value.toLowerCase().trim()
    const compTitle = item.competition_name || item.competition?.title || ''
    const matchSearch =
      !query ||
      item.supervisor_name.toLowerCase().includes(query) ||
      (item.supervisor_nip && item.supervisor_nip.toLowerCase().includes(query)) ||
      (item.student_names && item.student_names.toLowerCase().includes(query)) ||
      compTitle.toLowerCase().includes(query)

    return matchStatus && matchSearch
  })
})

const totalBisyaroh = computed(() => {
  return supervisors.value.reduce((sum, item) => sum + Number(item.bisyaroh_amount || 0), 0)
})

const handleParticipatedSelect = () => {
  if (selectedParticipatedIdx.value === '' || selectedParticipatedIdx.value === 'manual') return
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

const handleDutyZoneChange = () => {
  const rate = dutyRates[form.value.duty_zone]
  if (rate) {
    form.value.bisyaroh_amount = rate
  }
}

const addStudentFromPicker = (student: any) => {
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

const removeStudentName = (nameToRemove: string) => {
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

const copyPublicLink = async () => {
  try {
    await navigator.clipboard.writeText(publicLink.value)
    toast.success('Link public form pendamping berhasil disalin ke clipboard!', 'Tautan Disalin')
  } catch (err) {
    toast.info(`Salin link berikut: ${publicLink.value}`)
  }
}

const openModal = () => {
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
    bisyaroh_amount: 50000,
    notes: '',
    statement_agreed: true,
  }
  selectedParticipatedIdx.value = ''
  errorMessage.value = ''
  isModalOpen.value = true
}

const closeModal = () => {
  isModalOpen.value = false
}

const submitForm = async () => {
  if (!form.value.competition_name || !form.value.supervisor_name || !form.value.bisyaroh_amount) {
    errorMessage.value = 'Mohon lengkapi nama lomba, nama pendamping, dan nominal bisyaroh.'
    return
  }

  submitting.value = true
  errorMessage.value = ''

  try {
    await api.post('/school/supervisors', form.value)
    toast.success('Form Pendamping Perlombaan & Alokasi Bisyaroh berhasil diterbitkan.', 'Penetapan Diterbitkan')
    closeModal()
    fetchSupervisors()
  } catch (err: any) {
    errorMessage.value = err.response?.data?.message || 'Gagal menyimpan form pendamping.'
    toast.error(errorMessage.value, 'Gagal Menyimpan')
  } finally {
    submitting.value = false
  }
}

const deleteSupervisor = async (id: number) => {
  if (!confirm('Apakah Anda yakin ingin menghapus penetapan pendamping ini?')) return
  try {
    await api.delete(`/school/supervisors/${id}`)
    toast.success('Form pendamping telah dihapus dari sistem.', 'Hapus Berhasil')
    fetchSupervisors()
  } catch (err: any) {
    toast.error('Gagal menghapus data pendamping.', 'Gagal Hapus')
  }
}

const openPrintPreview = (item: Supervisor) => {
  printData.value = item
  isPrintModalOpen.value = true
}

const downloadDocx = async (id: number, name: string) => {
  try {
    const res = await api.get(`/school/supervisors/${id}/download-docx`, { responseType: 'blob' })
    const blob = new Blob([res.data], {
      type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const safeName = (name || 'Pendamping').replace(/[^a-zA-Z0-9_-]/g, '_')
    a.download = `Form_Pendamping_${safeName}.docx`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Dokumen Word Form Pendamping berhasil diunduh.', 'Unduh Berhasil')
  } catch (err) {
    toast.error('Gagal mengunduh dokumen Word form pendamping.')
  }
}

const downloadPdf = async (id: number, name: string) => {
  try {
    const res = await api.get(`/school/supervisors/${id}/download-pdf`, { responseType: 'blob' })
    const blob = new Blob([res.data], { type: 'application/pdf' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const safeName = (name || 'Pendamping').replace(/[^a-zA-Z0-9_-]/g, '_')
    a.download = `Form_Pendamping_${safeName}.pdf`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Dokumen PDF Form Pendamping berhasil diunduh.', 'Unduh Berhasil')
  } catch (err) {
    toast.error('Gagal mengunduh dokumen PDF.')
  }
}

const formatCurrency = (val: number) => {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}

const exportSupervisorsExcel = () => {
  if (!supervisors.value || supervisors.value.length === 0) {
    toast.error('Tidak ada data pendamping & bisyaroh untuk di-export.', 'Export Gagal')
    return
  }

  const headers = [
    'No',
    'No Register',
    'Nama Pendamping',
    'NIP / NIK',
    'No HP / WA',
    'Kategori Pendamping',
    'Jabatan / Peran',
    'Nama Lomba / Penyelenggara',
    'Cabang Lomba',
    'Siswa Didampingi',
    'Tingkat Lomba',
    'Wilayah Tugas',
    'Alokasi Bisyaroh (Rp)',
    'Status',
  ]

  const rows = filteredSupervisors.value.map((item, idx) => [
    idx + 1,
    item.reference_number || '-',
    item.supervisor_name,
    item.supervisor_nip || '-',
    item.supervisor_phone || '-',
    item.supervisor_category || 'Guru',
    item.role_title,
    item.competition_name || item.competition?.title || '-',
    item.competition_branch || '-',
    item.student_names || '-',
    item.competition_level || item.competition?.level || '-',
    item.duty_zone || 'dalam_kota',
    item.bisyaroh_amount || 0,
    item.status === 'disbursed' ? 'Sudah Dicairkan' : item.status === 'approved' ? 'Disetujui SOP' : 'Menunggu',
  ])

  exportToExcel('Rekap_Pendamping_Bisyaroh_MA_Unggulan', headers, rows)
  toast.success('File Rekapitulasi Excel Pendamping & Bisyaroh berhasil diunduh!', 'Export Berhasil')
}

onMounted(() => {
  fetchSupervisors()
  fetchOptions()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Form Pendamping & Bisyaroh</template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Humanized Administrative Top Section -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200/90 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-1.5 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-slate-100 text-slate-700 text-xs font-semibold">
            <i class="fa-solid fa-user-gear text-brand-navy"></i>
            Pelayanan Pendampingan Perlombaan & Insentif SOP Instansi
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Form Pendamping Lomba & Bisyaroh
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Kelola formulir pendampingan lomba siswa, tanda terima honorarium wilayah tugas, dan terbitkan surat tugas resmi.
          </p>
        </div>

        <div class="flex items-center gap-2.5 shrink-0 flex-wrap">
          <!-- Tombol Salin Link Form Publik -->
          <button
            type="button"
            @click="copyPublicLink"
            class="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-blue-50 hover:bg-blue-100 text-blue-800 text-xs font-bold border border-blue-200 shadow-2xs transition-all cursor-pointer"
            title="Salin tautan form publik untuk dibagikan ke WhatsApp guru pendamping (tanpa login)"
          >
            <i class="fa-solid fa-share-nodes text-blue-700"></i>
            <span>Salin Link Form Guru</span>
          </button>

          <button
            type="button"
            @click="exportSupervisorsExcel"
            class="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold border border-emerald-700 shadow-2xs transition-all cursor-pointer"
            title="Unduh Rekapitulasi Data Pendamping & Bisyaroh Format Excel"
          >
            <i class="fa-solid fa-file-excel"></i>
            <span>Export Excel</span>
          </button>

          <button
            type="button"
            @click="openModal"
            class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-[#00164a] transition-all cursor-pointer"
          >
            <i class="fa-solid fa-circle-plus text-brand-gold"></i>
            <span>Buat Form Pendamping</span>
          </button>
        </div>
      </div>

      <!-- Public Link Direct Box Notification -->
      <div class="bg-gradient-to-r from-blue-50/90 via-indigo-50/80 to-blue-50/90 rounded-2xl p-4 sm:p-5 border border-blue-200/90 shadow-2xs flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div class="flex items-start gap-3">
          <div class="w-10 h-10 rounded-xl bg-blue-600 text-white flex items-center justify-center shrink-0 text-base shadow-xs">
            <i class="fa-solid fa-link"></i>
          </div>
          <div>
            <div class="flex items-center gap-2">
              <span class="text-xs font-black text-brand-navy uppercase tracking-wider">Link Formulir Publik Guru Pendamping</span>
              <span class="px-2 py-0.5 rounded-full bg-blue-100 text-blue-800 text-[10px] font-bold">Tanpa Login</span>
            </div>
            <p class="text-xs text-slate-600 mt-0.5">
              Guru pendamping dapat mengisi form ini secara mandiri melalui HP/browser tanpa login:
              <span class="font-mono text-blue-800 font-semibold underline select-all ml-1">{{ publicLink }}</span>
            </p>
          </div>
        </div>

        <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
          <button
            type="button"
            @click="copyPublicLink"
            class="flex-1 sm:flex-none inline-flex items-center justify-center gap-1.5 px-3 py-2 rounded-xl bg-white hover:bg-slate-50 text-slate-800 text-xs font-bold border border-slate-300 shadow-2xs transition-all cursor-pointer"
          >
            <i class="fa-solid fa-copy text-brand-navy"></i>
            <span>Salin Link</span>
          </button>
          <a
            :href="publicLink"
            target="_blank"
            class="inline-flex items-center justify-center gap-1.5 px-3 py-2 rounded-xl bg-blue-700 hover:bg-blue-800 text-white text-xs font-bold shadow-xs transition-all"
          >
            <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
            <span>Buka Form</span>
          </a>
        </div>
      </div>

      <!-- Operational Status Ledger (Clean white tiles) -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <!-- Tile 1: Total Pendamping -->
        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Total Personil Pendamping</span>
            <i class="fa-solid fa-user-tie text-brand-navy text-xs"></i>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-brand-navy font-mono">{{ supervisors.length }}</span>
            <span class="text-xs text-slate-500 font-medium">personil terdaftar</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Pembimbing & pendamping lapangan</p>
        </div>

        <!-- Tile 2: Total Bisyaroh -->
        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Total Bisyaroh Dialokasikan</span>
            <i class="fa-solid fa-money-bill-wave text-emerald-600 text-xs"></i>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-emerald-700 font-mono">{{ formatCurrency(totalBisyaroh) }}</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Sesuai plafon wilayah tugas SOP</p>
        </div>

        <!-- Tile 3: Riwayat Lomba Siswa -->
        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Lomba Siswa Terdata</span>
            <i class="fa-solid fa-award text-indigo-600 text-xs"></i>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-indigo-700 font-mono">{{ participatedCompetitions.length }}</span>
            <span class="text-xs text-slate-500 font-medium">ajang kompetisi</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Sinkron data dispensasi & pendaftaran</p>
        </div>
      </div>

      <!-- Filter Controls & Search -->
      <div class="bg-white rounded-xl p-3 sm:p-4 border border-slate-200/80 shadow-xs flex flex-col md:flex-row items-center justify-between gap-3">
        <!-- Filter Tabs -->
        <div class="flex items-center gap-1.5 overflow-x-auto w-full md:w-auto">
          <button
            type="button"
            @click="filterStatus = 'all'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              filterStatus === 'all'
                ? 'bg-brand-navy text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Semua ({{ supervisors.length }})
          </button>
          <button
            type="button"
            @click="filterStatus = 'approved'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              filterStatus === 'approved'
                ? 'bg-emerald-700 text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Disetujui SOP
          </button>
          <button
            type="button"
            @click="filterStatus = 'disbursed'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              filterStatus === 'disbursed'
                ? 'bg-blue-700 text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Sudah Dicairkan
          </button>
        </div>

        <!-- Search Input -->
        <div class="relative w-full md:w-80">
          <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Cari nama pendamping, lomba, siswa..."
            class="w-full text-xs rounded-lg border border-slate-200 bg-slate-50 pl-8 pr-3 py-2 text-slate-700 placeholder-slate-400 focus:outline-hidden focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy transition-all"
          />
        </div>
      </div>

      <!-- Main Data Table Container -->
      <div class="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div v-if="loading" class="py-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2 font-medium">Memuat data pendamping & bisyaroh...</p>
        </div>

        <div v-else-if="filteredSupervisors.length === 0" class="py-16 text-center">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
            <i class="fa-regular fa-folder-open"></i>
          </div>
          <h3 class="text-sm font-bold text-slate-800">Belum Ada Form Pendamping & Bisyaroh</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
            Klik tombol "Buat Form Pendamping" di atas atau bagikan link form publik ke bapak/ibu guru pendamping.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs border-collapse">
            <thead class="bg-slate-50 text-slate-500 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[10px]">
              <tr>
                <th class="px-4 py-3">Pendamping</th>
                <th class="px-4 py-3">Lomba & Siswa</th>
                <th class="px-4 py-3">Wilayah Tugas</th>
                <th class="px-4 py-3">Nominal Bisyaroh</th>
                <th class="px-4 py-3 text-center">Status</th>
                <th class="px-4 py-3 text-right">Surat & Tindakan</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 text-slate-700">
              <tr
                v-for="item in filteredSupervisors"
                :key="item.id"
                class="hover:bg-slate-50/80 transition-colors"
              >
                <!-- Pendamping -->
                <td class="px-4 py-3.5">
                  <p class="font-bold text-slate-900 text-xs leading-snug">
                    {{ item.supervisor_name }}
                  </p>
                  <p class="text-[11px] text-slate-500 mt-0.5">
                    {{ item.role_title }}
                    <span v-if="item.supervisor_nip" class="font-mono ml-1">• NIP: {{ item.supervisor_nip }}</span>
                  </p>
                  <p v-if="item.supervisor_phone" class="text-[11px] text-slate-400 mt-0.5">
                    <i class="fa-solid fa-phone text-[9px] mr-1"></i>{{ item.supervisor_phone }}
                  </p>
                  <span v-if="item.reference_number" class="inline-block mt-1 font-mono text-[10px] text-blue-700 bg-blue-50 px-1.5 py-0.5 rounded-sm">
                    {{ item.reference_number }}
                  </span>
                </td>

                <!-- Lomba & Siswa -->
                <td class="px-4 py-3.5 max-w-xs">
                  <p class="font-bold text-slate-800 text-xs leading-snug">
                    {{ item.competition_name || item.competition?.title || '-' }}
                  </p>
                  <p v-if="item.competition_branch" class="text-[11px] text-indigo-700 font-semibold mt-0.5">
                    Cabang: {{ item.competition_branch }}
                  </p>
                  <p v-if="item.student_names" class="text-[11px] text-slate-600 mt-0.5 line-clamp-2">
                    <i class="fa-solid fa-user-graduate text-[9px] mr-1 text-slate-400"></i>
                    {{ item.student_names }}
                  </p>
                  <p class="text-[10px] text-slate-400 capitalize mt-0.5">
                    Tingkat {{ item.competition_level || item.competition?.level || '-' }}
                  </p>
                </td>

                <!-- Wilayah Tugas -->
                <td class="px-4 py-3.5">
                  <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-semibold bg-slate-100 text-slate-800 border border-slate-200 capitalize">
                    {{ (item.duty_zone || 'dalam_kota').replace('_', ' ') }}
                  </span>
                </td>

                <!-- Nominal Bisyaroh -->
                <td class="px-4 py-3.5">
                  <p class="font-black text-emerald-700 text-xs font-mono">
                    {{ formatCurrency(item.bisyaroh_amount) }}
                  </p>
                  <p class="text-[10px] text-slate-400 mt-0.5">
                    {{ item.sop_category || 'SOP Instansi' }}
                  </p>
                </td>

                <!-- Status -->
                <td class="px-4 py-3.5 text-center">
                  <span
                    :class="[
                      'inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold border',
                      item.status === 'disbursed'
                        ? 'bg-blue-50 text-blue-800 border-blue-200'
                        : 'bg-emerald-50 text-emerald-800 border-emerald-200'
                    ]"
                  >
                    <i :class="item.status === 'disbursed' ? 'fa-solid fa-circle-check text-[9px] mr-1' : 'fa-solid fa-clock text-[9px] mr-1'"></i>
                    {{ item.status === 'disbursed' ? 'Sudah Dicairkan' : 'Disetujui SOP' }}
                  </span>
                </td>

                <!-- Actions: Cetak Surat, Unduh DOCX, Unduh PDF, Hapus -->
                <td class="px-4 py-3.5 text-right">
                  <div class="flex items-center justify-end gap-1.5">
                    <button
                      type="button"
                      @click="openPrintPreview(item)"
                      class="inline-flex items-center gap-1 px-2.5 py-1 rounded-md text-[11px] font-bold bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300 transition-colors cursor-pointer"
                      title="Cetak Surat Formulir & Tanda Terima"
                    >
                      <i class="fa-solid fa-print text-brand-navy"></i>
                      <span>Cetak</span>
                    </button>

                    <button
                      type="button"
                      @click="downloadDocx(item.id, item.supervisor_name)"
                      class="inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-bold bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-200 transition-colors cursor-pointer"
                      title="Unduh Dokumen Word (.docx)"
                    >
                      <i class="fa-solid fa-file-word"></i>
                      <span>DOCX</span>
                    </button>

                    <button
                      type="button"
                      @click="downloadPdf(item.id, item.supervisor_name)"
                      class="inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-bold bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 transition-colors cursor-pointer"
                      title="Unduh Dokumen PDF"
                    >
                      <i class="fa-solid fa-file-pdf"></i>
                      <span>PDF</span>
                    </button>

                    <button
                      type="button"
                      @click="deleteSupervisor(item.id)"
                      class="inline-flex items-center p-1.5 rounded-md text-xs font-semibold text-rose-600 hover:bg-rose-50 hover:text-rose-700 transition-colors cursor-pointer"
                      title="Hapus Penetapan"
                    >
                      <i class="fa-regular fa-trash-can"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- MODAL BUAT FORM PENDAMPING & BISYAROH (Aligned with Word document) -->
      <Modal v-model="isModalOpen" title="Form Pendamping & Alokasi Bisyaroh" subtitle="Penetapan pendamping perlombaan & alokasi insentif menurut SOP instansi." size="lg">
        <template #title-icon>
          <i class="fa-solid fa-file-signature text-brand-navy"></i>
        </template>

        <form @submit.prevent="submitForm" class="space-y-4 max-h-[75vh] overflow-y-auto px-1">
          <div v-if="errorMessage" class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
            <i class="fa-solid fa-circle-exclamation mr-1.5"></i>
            {{ errorMessage }}
          </div>

          <!-- Quick Selector: Riwayat Lomba Siswa yang Diikuti -->
          <div class="p-3.5 rounded-xl bg-blue-50/70 border border-blue-200 space-y-1.5">
            <label class="block text-xs font-bold text-brand-navy">
              <i class="fa-solid fa-wand-magic-sparkles mr-1 text-blue-600"></i>
              Pilih dari Riwayat Lomba Siswa (Autofill Selaras)
            </label>
            <select
              v-model="selectedParticipatedIdx"
              @change="handleParticipatedSelect"
              class="w-full text-xs rounded-xl border border-blue-200 bg-white px-3 py-2 text-slate-800 focus:outline-hidden focus:border-brand-navy"
            >
              <option value="">-- Pilih dari Lomba yang Pernah Diikuti Peserta Didik --</option>
              <option
                v-for="(comp, idx) in participatedCompetitions"
                :key="idx"
                :value="idx"
              >
                🏆 {{ comp.competition_name }} ({{ comp.competition_level.toUpperCase() }}) — {{ comp.student_names || 'Siswa' }}
              </option>
              <option value="manual">✏️ Lomba Baru / Input Manual</option>
            </select>
          </div>

          <!-- A. DATA PERLOMBAAN -->
          <div class="space-y-3 pt-1">
            <div class="text-xs font-black text-slate-800 uppercase tracking-wider pb-1 border-b border-slate-200">
              A. Data Perlombaan
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">
                Nama Penyelenggara / Nama Perlombaan *
              </label>
              <input
                v-model="form.competition_name"
                type="text"
                required
                placeholder="Contoh: OSN 2026 / OPSI / Lomba Kaligrafi"
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
              />
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Cabang Lomba yang Diikuti
                </label>
                <input
                  v-model="form.competition_branch"
                  type="text"
                  placeholder="Matematika, Riset, Seni, dll."
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                />
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Kategori Lomba
                </label>
                <select
                  v-model="form.competition_category"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                >
                  <option value="SMA / MA">SMA / MA</option>
                  <option value="SMP / MTs">SMP / MTs</option>
                  <option value="SD / MI">SD / MI</option>
                  <option value="Umum">Umum</option>
                </select>
              </div>
            </div>

            <!-- Nama Peserta / Tim dengan Student Picker -->
            <div class="space-y-1">
              <label class="block text-xs font-bold text-slate-700 mb-1">
                Nama Peserta / Tim yang Didampingi
              </label>

              <!-- Quick Student Search Picker -->
              <div class="relative">
                <div class="relative">
                  <input
                    v-model="studentSearchQuery"
                    @focus="showStudentDropdown = true"
                    @input="showStudentDropdown = true"
                    @blur="closeStudentDropdown"
                    type="text"
                    placeholder="🔍 Cari nama siswa terdaftar..."
                    class="w-full text-xs rounded-xl border border-slate-300 bg-blue-50/50 px-3 py-2 pr-8 text-slate-800 placeholder-slate-400 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                  />
                  <button
                    v-if="studentSearchQuery"
                    type="button"
                    @mousedown.prevent="studentSearchQuery = ''; showStudentDropdown = true"
                    class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs cursor-pointer"
                  >
                    <i class="fa-solid fa-circle-xmark"></i>
                  </button>
                </div>
                
                <div
                  v-if="showStudentDropdown && filteredStudents.length > 0"
                  class="absolute z-30 top-full left-0 right-0 mt-1 max-h-48 overflow-y-auto bg-white rounded-xl shadow-xl border border-slate-200 py-1 text-xs divide-y divide-slate-100"
                >
                  <div
                    v-for="s in filteredStudents"
                    :key="s.id"
                    @mousedown.prevent="addStudentFromPicker(s)"
                    class="px-3 py-1.5 hover:bg-blue-50 cursor-pointer flex items-center justify-between"
                  >
                    <div>
                      <span class="font-bold text-slate-800">{{ s.full_name }}</span>
                      <span class="text-[10px] text-slate-400 font-mono ml-2" v-if="s.nisn">NISN: {{ s.nisn }}</span>
                    </div>
                    <span class="text-[10px] text-blue-700 font-bold bg-blue-50 border border-blue-200 px-1.5 py-0.5 rounded-md font-mono shrink-0">
                      {{ s.class_name || s.class_room || '-' }}
                    </span>
                  </div>
                </div>

                <div
                  v-else-if="showStudentDropdown && studentSearchQuery && filteredStudents.length === 0"
                  class="absolute z-30 top-full left-0 right-0 mt-1 p-2.5 bg-white rounded-xl shadow-xl border border-slate-200 text-center text-xs text-slate-500"
                >
                  Tidak ditemukan siswa dengan nama "{{ studentSearchQuery }}"
                </div>
              </div>

              <div v-if="parsedStudentNames.length > 0" class="flex flex-wrap gap-1 pt-1">
                <span
                  v-for="(name, nIdx) in parsedStudentNames"
                  :key="nIdx"
                  class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-blue-100 text-blue-900 text-[11px] font-semibold"
                >
                  {{ name }}
                  <button type="button" @click="removeStudentName(name)" class="text-blue-600 hover:text-rose-600 ml-0.5">&times;</button>
                </span>
              </div>

              <textarea
                v-model="form.student_names"
                rows="2"
                placeholder="Nama-nama peserta didik yang didampingi..."
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
              ></textarea>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Tempat Perlombaan
                </label>
                <input
                  v-model="form.competition_place"
                  type="text"
                  placeholder="Tempat/Lokasi perlombaan"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                />
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Tingkat Perlombaan
                </label>
                <select
                  v-model="form.competition_level"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden capitalize"
                >
                  <option value="kabupaten">Kabupaten/Kota</option>
                  <option value="provinsi">Provinsi</option>
                  <option value="nasional">Nasional</option>
                  <option value="internasional">Internasional</option>
                </select>
              </div>
            </div>
          </div>

          <!-- B. DATA DIRI PENDAMPING -->
          <div class="space-y-3 pt-2">
            <div class="text-xs font-black text-slate-800 uppercase tracking-wider pb-1 border-b border-slate-200">
              B. Data Diri Pendamping
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Nama Lengkap dan Gelar *
                </label>
                <input
                  v-model="form.supervisor_name"
                  type="text"
                  required
                  placeholder="Contoh: Drs. H. Ahmad Dahlan, M.Pd."
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden font-semibold"
                />
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Kategori Pendamping *
                </label>
                <select
                  v-model="form.supervisor_category"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                >
                  <option value="Guru">Guru</option>
                  <option value="Pelatih">Pelatih</option>
                  <option value="Tenaga Kependidikan (Admin / Staf / Magang)">Tenaga Kependidikan</option>
                  <option value="Pembimbing (Eksternal / Akademik / Pembina)">Pembimbing</option>
                  <option value="Koordinator Prestasi">Koordinator Prestasi</option>
                </select>
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Jabatan / Mapel / Unit Kerja *
                </label>
                <input
                  v-model="form.role_title"
                  type="text"
                  required
                  placeholder="Guru Fisika / Pembina KIR"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                />
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Jenis Kelamin *
                </label>
                <div class="flex items-center gap-4 pt-2">
                  <label class="inline-flex items-center gap-1.5 text-xs">
                    <input v-model="form.supervisor_gender" type="radio" value="Laki-laki" />
                    <span>Laki-laki</span>
                  </label>
                  <label class="inline-flex items-center gap-1.5 text-xs">
                    <input v-model="form.supervisor_gender" type="radio" value="Perempuan" />
                    <span>Perempuan</span>
                  </label>
                </div>
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  No. WhatsApp / HP
                </label>
                <input
                  v-model="form.supervisor_phone"
                  type="text"
                  placeholder="08123456789"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden font-mono"
                />
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  NIP / NIK Pendamping
                </label>
                <input
                  v-model="form.supervisor_nip"
                  type="text"
                  placeholder="Opsional (misal: 198501...)"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden font-mono"
                />
              </div>
            </div>
          </div>

          <!-- C. KATEGORI WILAYAH TUGAS & TANDA TERIMA HONORARIUM -->
          <div class="space-y-3 pt-2">
            <div class="text-xs font-black text-slate-800 uppercase tracking-wider pb-1 border-b border-slate-200">
              C. Kategori Wilayah Tugas & Bisyaroh
            </div>

            <div class="grid grid-cols-2 gap-2">
              <label
                :class="[
                  'p-2.5 rounded-xl border text-xs cursor-pointer flex items-center justify-between',
                  form.duty_zone === 'dalam_kota' ? 'border-emerald-600 bg-emerald-50 text-emerald-900 font-bold' : 'border-slate-200'
                ]"
              >
                <div class="flex items-center gap-1.5">
                  <input v-model="form.duty_zone" type="radio" value="dalam_kota" @change="handleDutyZoneChange" />
                  <span>Dalam Kota</span>
                </div>
                <span class="font-mono text-emerald-700">Rp 50.000</span>
              </label>

              <label
                :class="[
                  'p-2.5 rounded-xl border text-xs cursor-pointer flex items-center justify-between',
                  form.duty_zone === 'luar_kota' ? 'border-emerald-600 bg-emerald-50 text-emerald-900 font-bold' : 'border-slate-200'
                ]"
              >
                <div class="flex items-center gap-1.5">
                  <input v-model="form.duty_zone" type="radio" value="luar_kota" @change="handleDutyZoneChange" />
                  <span>Luar Kota</span>
                </div>
                <span class="font-mono text-emerald-700">Rp 100.000</span>
              </label>

              <label
                :class="[
                  'p-2.5 rounded-xl border text-xs cursor-pointer flex items-center justify-between',
                  form.duty_zone === 'luar_provinsi' ? 'border-emerald-600 bg-emerald-50 text-emerald-900 font-bold' : 'border-slate-200'
                ]"
              >
                <div class="flex items-center gap-1.5">
                  <input v-model="form.duty_zone" type="radio" value="luar_provinsi" @change="handleDutyZoneChange" />
                  <span>Luar Provinsi</span>
                </div>
                <span class="font-mono text-emerald-700">Rp 150.000</span>
              </label>

              <label
                :class="[
                  'p-2.5 rounded-xl border text-xs cursor-pointer flex items-center justify-between',
                  form.duty_zone === 'luar_negeri' ? 'border-emerald-600 bg-emerald-50 text-emerald-900 font-bold' : 'border-slate-200'
                ]"
              >
                <div class="flex items-center gap-1.5">
                  <input v-model="form.duty_zone" type="radio" value="luar_negeri" @change="handleDutyZoneChange" />
                  <span>Luar Negeri</span>
                </div>
                <span class="font-mono text-emerald-700">Rp 200.000</span>
              </label>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Nominal Bisyaroh Disetujui (Rp) *
                </label>
                <input
                  v-model.number="form.bisyaroh_amount"
                  type="number"
                  required
                  min="0"
                  step="25000"
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-slate-800 font-mono font-bold focus:bg-white focus:border-brand-navy focus:outline-hidden"
                />
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">
                  Catatan Rincian Tugas / SOP
                </label>
                <input
                  v-model="form.notes"
                  type="text"
                  placeholder="Catatan tugas..."
                  class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-slate-800 focus:bg-white focus:border-brand-navy focus:outline-hidden"
                />
              </div>
            </div>
          </div>
        </form>

        <template #footer>
          <button
            type="button"
            @click="closeModal"
            class="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            Batal
          </button>
          <button
            type="button"
            @click="submitForm"
            :disabled="submitting"
            class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-navy hover:bg-[#00164a] text-white shadow-xs disabled:opacity-50 transition-all cursor-pointer inline-flex items-center gap-2"
          >
            <i v-if="submitting" class="fa-solid fa-circle-notch fa-spin text-xs"></i>
            <span>{{ submitting ? 'Memproses...' : 'Simpan Form Pendamping' }}</span>
          </button>
        </template>
      </Modal>

      <!-- PRINT PREVIEW MODAL FOR LETTER -->
      <Modal v-model="isPrintModalOpen" title="Cetak Surat Formulir & Tanda Terima" subtitle="Pratinjau dokumen resmi Form Pendamping Perlombaan & Honorarium." size="xl">
        <template #title-icon>
          <i class="fa-solid fa-print text-brand-navy"></i>
        </template>

        <div v-if="printData" class="space-y-6 max-h-[75vh] overflow-y-auto px-2 py-1 text-slate-800 text-xs">
          <!-- Document 1 Preview: Form Pendamping Perlombaan -->
          <div class="bg-white p-6 rounded-xl border border-slate-300 shadow-sm space-y-4">
            <!-- Kop -->
            <div class="text-center pb-2 border-b-2 border-slate-900 space-y-0.5">
              <h4 class="font-serif font-black text-sm uppercase">MA UNGGULAN K.H. ABD. WAHAB HASBULLOH</h4>
              <p class="font-serif text-xs font-bold uppercase">TAMBAKBERAS JOMBANG JAWA TIMUR</p>
              <p class="text-[10px] text-slate-600">Pondok Pesantren Bahrul Ulum &bull; NPSN: 20579998</p>
            </div>

            <div class="text-center space-y-0.5">
              <h3 class="font-bold text-xs uppercase underline">FORM PENDAMPING PERLOMBAAN</h3>
              <p class="font-mono text-[10px] text-slate-500">Nomor: {{ printData.reference_number || '-' }}</p>
            </div>

            <!-- Bagian A -->
            <div class="space-y-1.5">
              <div class="font-bold uppercase text-[11px] bg-slate-100 p-1 border-l-2 border-brand-navy">A. DATA PERLOMBAAN</div>
              <div class="grid grid-cols-3 gap-2 pl-2">
                <span class="text-slate-500">Nama Penyelenggara/Lomba:</span>
                <span class="col-span-2 font-bold">{{ printData.competition_name || printData.competition?.title || '-' }}</span>
                <span class="text-slate-500">Cabang Lomba yang Diikuti:</span>
                <span class="col-span-2 font-semibold">{{ printData.competition_branch || '-' }}</span>
                <span class="text-slate-500">Nama Peserta / Tim:</span>
                <span class="col-span-2 font-semibold">{{ printData.student_names || '-' }}</span>
                <span class="text-slate-500">Kategori Lomba:</span>
                <span class="col-span-2">{{ printData.competition_category || 'SMA / MA' }}</span>
                <span class="text-slate-500">Tempat Perlombaan:</span>
                <span class="col-span-2">{{ printData.competition_place || '-' }}</span>
                <span class="text-slate-500">Tingkat Perlombaan:</span>
                <span class="col-span-2 capitalize font-bold text-blue-900">{{ printData.competition_level || printData.competition?.level || '-' }}</span>
              </div>
            </div>

            <!-- Bagian B -->
            <div class="space-y-1.5">
              <div class="font-bold uppercase text-[11px] bg-slate-100 p-1 border-l-2 border-brand-navy">B. DATA DIRI PENDAMPING</div>
              <div class="grid grid-cols-3 gap-2 pl-2">
                <span class="text-slate-500">Nama Lengkap dan Gelar:</span>
                <span class="col-span-2 font-bold">{{ printData.supervisor_name }}</span>
                <span class="text-slate-500">Kategori Pendamping:</span>
                <span class="col-span-2 font-semibold">{{ printData.supervisor_category || 'Guru' }}</span>
                <span class="text-slate-500">Jabatan / Mapel / Unit:</span>
                <span class="col-span-2 font-semibold">{{ printData.role_title }}</span>
                <span class="text-slate-500">Jenis Kelamin:</span>
                <span class="col-span-2">{{ printData.supervisor_gender || 'Laki-laki' }}</span>
                <span class="text-slate-500">Nomor WhatsApp / HP:</span>
                <span class="col-span-2 font-mono">{{ printData.supervisor_phone || '-' }}</span>
              </div>
            </div>

            <!-- Tanda Tangan Pendamping -->
            <div class="pt-4 flex justify-end text-center">
              <div class="w-48 space-y-12">
                <p>Pendamping Perlombaan,</p>
                <div>
                  <p class="font-bold underline">{{ printData.supervisor_name }}</p>
                  <p v-if="printData.supervisor_nip" class="text-[10px] text-slate-500">NIP: {{ printData.supervisor_nip }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Document 2 Preview: Form Tanda Terima Honorarium -->
          <div class="bg-white p-6 rounded-xl border border-slate-300 shadow-sm space-y-4">
            <div class="text-center pb-2 border-b-2 border-slate-900 space-y-0.5">
              <h4 class="font-serif font-black text-sm uppercase">MA UNGGULAN K.H. ABD. WAHAB HASBULLOH</h4>
              <p class="font-serif text-xs font-bold uppercase">TAMBAKBERAS JOMBANG JAWA TIMUR</p>
            </div>

            <div class="text-center space-y-0.5">
              <h3 class="font-bold text-xs uppercase underline">FORM TANDA TERIMA HONORARIUM PENDAMPING PERLOMBAAN</h3>
              <p class="font-mono text-[10px] text-slate-500">Nomor: {{ printData.reference_number || '-' }}</p>
            </div>

            <div class="space-y-2 pl-2">
              <p><strong>Nama Pendamping:</strong> {{ printData.supervisor_name }}</p>
              <p><strong>Nama Penyelenggara/Lomba:</strong> {{ printData.competition_name || printData.competition?.title || '-' }}</p>
              <div>
                <strong>Kategori Wilayah Tugas:</strong>
                <p class="mt-1 font-semibold text-emerald-800">
                  [{{ (printData.duty_zone || 'dalam_kota').toUpperCase().replace('_', ' ') }}] &bull; Insentif/Bisyaroh: {{ formatCurrency(printData.bisyaroh_amount) }}
                </p>
              </div>
            </div>

            <!-- Tanda Tangan Ganda -->
            <div class="pt-6 grid grid-cols-2 text-center">
              <div class="space-y-12">
                <p>Yang Menerima,<br/>Pendamping Perlombaan</p>
                <p class="font-bold underline">{{ printData.supervisor_name }}</p>
              </div>
              <div class="space-y-12">
                <p>Mengetahui,<br/>Koordinator Prestasi</p>
                <p class="font-bold underline">Sariyanti, S.Pd.</p>
              </div>
            </div>
          </div>
        </div>

        <template #footer>
          <button
            type="button"
            @click="isPrintModalOpen = false"
            class="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            Tutup
          </button>
          <div class="flex items-center gap-2">
            <button
              v-if="printData"
              type="button"
              @click="downloadDocx(printData.id, printData.supervisor_name)"
              class="px-3.5 py-2 rounded-xl text-xs font-bold bg-blue-700 hover:bg-blue-800 text-white shadow-xs transition-all cursor-pointer inline-flex items-center gap-1.5"
            >
              <i class="fa-solid fa-file-word"></i>
              <span>Unduh Word</span>
            </button>
            <button
              v-if="printData"
              type="button"
              @click="downloadPdf(printData.id, printData.supervisor_name)"
              class="px-3.5 py-2 rounded-xl text-xs font-bold bg-rose-700 hover:bg-rose-800 text-white shadow-xs transition-all cursor-pointer inline-flex items-center gap-1.5"
            >
              <i class="fa-solid fa-file-pdf"></i>
              <span>Unduh PDF</span>
            </button>
            <button
              type="button"
              onclick="window.print()"
              class="px-4 py-2 rounded-xl text-xs font-bold bg-slate-900 hover:bg-black text-white shadow-xs transition-all cursor-pointer inline-flex items-center gap-1.5"
            >
              <i class="fa-solid fa-print"></i>
              <span>Cetak Sekarang</span>
            </button>
          </div>
        </template>
      </Modal>

    </div>
  </DashboardLayout>
</template>
