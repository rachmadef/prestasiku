<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'
import { formatDateIndo, formatDateRange } from '@/utils/date'

const { toast } = useNotify()

const dispensations = ref<any[]>([])
const students = ref<any[]>([])
const loading = ref(true)
const statusFilter = ref<'all' | 'pending' | 'approved' | 'rejected'>('all')
const searchQuery = ref('')

// Review Modal
const showReviewModal = ref(false)
const selectedDisp = ref<any>(null)
const reviewAction = ref<'approve' | 'reject'>('approve')
const referenceNumberInput = ref('')
const rejectionReasonInput = ref('')
const reviewing = ref(false)

// Direct Create Dispensation Modal
const showCreateModal = ref(false)
const creating = ref(false)
const formSchema = ref<any[]>([])
const createForm = ref({
  competition_name: '',
  dispensation_type: 'persiapan_latihan',
  purpose: '',
  start_date: '',
  end_date: '',
  is_all_day: true,
  start_time: '',
  end_time: '',
  supervisor_name: '',
  student_ids: [] as number[],
  reference_number: '',
  notes: '',
  custom_fields_data: {} as Record<string, any>,
})

// Print Letter Preview Modal
const showPrintModal = ref(false)
const printData = ref<any>(null)

async function fetchData() {
  loading.value = true
  try {
    const [dispRes, studRes, schemaRes] = await Promise.all([
      api.get('/school/dispensations'),
      api.get('/school/students?all=1').catch(() => ({ data: { data: [] } })),
      api.get('/school/dispensations/form-schema').catch(() => ({ data: { data: { schema: [] } } })),
    ])
    dispensations.value = extractList(dispRes.data.data)
    students.value = extractList(studRes.data.data)
    formSchema.value = schemaRes.data?.data?.schema || []
  } catch (err) {
    console.error('Error fetching school dispensations:', err)
  } finally {
    loading.value = false
  }
}

// Operational counts
const pendingCount = computed(() => dispensations.value.filter((d: any) => d.status === 'pending').length)
const approvedCount = computed(() => dispensations.value.filter((d: any) => d.status === 'approved').length)
const rejectedCount = computed(() => dispensations.value.filter((d: any) => d.status === 'rejected').length)

const filteredDispensations = computed(() => {
  return dispensations.value.filter((d: any) => {
    const matchStatus = statusFilter.value === 'all' || d.status === statusFilter.value
    const matchSearch =
      !searchQuery.value ||
      (d.competition_name && d.competition_name.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (d.reference_number && d.reference_number.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (d.supervisor_name && d.supervisor_name.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (d.students && d.students.some((s: any) => s.full_name.toLowerCase().includes(searchQuery.value.toLowerCase())))

    return matchStatus && matchSearch
  })
})

function openReviewModal(disp: any) {
  selectedDisp.value = disp
  reviewAction.value = 'approve'
  referenceNumberInput.value = disp.reference_number || ''
  rejectionReasonInput.value = ''
  showReviewModal.value = true
}

async function submitReview() {
  reviewing.value = true
  try {
    await api.post(`/school/dispensations/${selectedDisp.value.id}/review`, {
      action: reviewAction.value,
      reference_number: referenceNumberInput.value,
      rejection_reason: rejectionReasonInput.value,
    })

    toast.success(
      reviewAction.value === 'approve'
        ? 'Dispensasi KBM berhasil disetujui & nomor surat diterbitkan!'
        : 'Permohonan dispensasi KBM ditolak.',
      'Tinjauan Selesai'
    )
    showReviewModal.value = false
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memproses review dispensasi.', 'Gagal Review')
  } finally {
    reviewing.value = false
  }
}

async function openPrintPreview(dispId: number) {
  try {
    const res = await api.get(`/school/dispensations/${dispId}/print-letter`)
    printData.value = res.data.data
    showPrintModal.value = true
  } catch (err) {
    toast.error('Gagal menyiapkan format cetak surat dispensasi.', 'Gagal')
  }
}

const downloadingDocx = ref(false)
const downloadingPdf = ref(false)

async function downloadDocx(dispId: number, refNumber: string) {
  downloadingDocx.value = true
  try {
    const res = await api.get(`/school/dispensations/${dispId}/download-docx`, {
      responseType: 'blob',
    })
    const blob = new Blob([res.data], {
      type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const safeName = (refNumber || 'KBM').replace(/[^a-zA-Z0-9_-]/g, '_')
    a.download = `Surat_Dispensasi_${safeName}.docx`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Dokumen Word (.docx) berhasil diunduh.', 'Unduh Berhasil')
  } catch (err: any) {
    toast.error('Gagal mengunduh berkas DOCX.', 'Gagal Unduh')
  } finally {
    downloadingDocx.value = false
  }
}

async function downloadPdf(dispId: number, refNumber: string) {
  downloadingPdf.value = true
  try {
    const res = await api.get(`/school/dispensations/${dispId}/download-pdf`, {
      responseType: 'blob',
    })
    const blob = new Blob([res.data], {
      type: 'application/pdf',
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const safeName = (refNumber || 'KBM').replace(/[^a-zA-Z0-9_-]/g, '_')
    a.download = `Surat_Dispensasi_${safeName}.pdf`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Dokumen PDF berhasil diunduh.', 'Unduh Berhasil')
  } catch (err: any) {
    toast.error('Gagal mengunduh berkas PDF.', 'Gagal Unduh')
  } finally {
    downloadingPdf.value = false
  }
}

function handlePrintAction() {
  window.print()
}

async function handleCreateDirect() {
  if (
    !createForm.value.competition_name ||
    !createForm.value.purpose ||
    !createForm.value.start_date ||
    !createForm.value.end_date ||
    createForm.value.student_ids.length === 0
  ) {
    toast.error('Mohon lengkapi data kegiatan, periode, dan minimal 1 siswa.', 'Validasi Form')
    return
  }

  creating.value = true
  try {
    await api.post('/school/dispensations', createForm.value)
    toast.success('Surat perizinan dispensasi KBM berhasil diterbitkan secara resmi.', 'Dispensasi Diterbitkan')
    showCreateModal.value = false
    createForm.value = {
      competition_name: '',
      dispensation_type: 'persiapan_latihan',
      purpose: '',
      start_date: '',
      end_date: '',
      is_all_day: true,
      start_time: '',
      end_time: '',
      supervisor_name: '',
      student_ids: [],
      reference_number: '',
      notes: '',
      custom_fields_data: {},
    }
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menerbitkan dispensasi.', 'Gagal Menerbitkan')
  } finally {
    creating.value = false
  }
}

import { exportToExcel } from '@/utils/exportExcel'

function exportDispensationsExcel() {
  if (!dispensations.value || dispensations.value.length === 0) {
    toast.error('Tidak ada data perizinan dispensasi untuk di-export.', 'Export Gagal')
    return
  }

  const headers = [
    'No',
    'Nomor Surat / Ref',
    'Nama Lomba / Kegiatan',
    'Jenis / Alasan Dispensasi',
    'Siswa Penerima Izin',
    'Jumlah Siswa',
    'Tanggal Mulai',
    'Tanggal Selesai',
    'Durasi / Waktu',
    'Guru Pembimbing / Pendamping',
    'Status Persetujuan',
  ]

  const rows = filteredDispensations.value.map((d: any, idx: number) => {
    const studentNames = d.students && d.students.length > 0
      ? d.students.map((s: any) => `${s.full_name} (${s.class_name || '-'})`).join('; ')
      : (d.student?.full_name || '-')

    const timeStr = d.is_all_day ? 'Seharian Penuh' : `${d.start_time || ''} - ${d.end_time || ''}`

    return [
      idx + 1,
      d.reference_number || '-',
      d.competition_name || d.title || '-',
      (d.dispensation_type || 'persiapan_latihan').replace(/_/g, ' ').toUpperCase(),
      studentNames,
      d.students?.length || 1,
      d.start_date ? String(d.start_date).split('T')[0] : '-',
      d.end_date ? String(d.end_date).split('T')[0] : '-',
      timeStr,
      d.supervisor_name || '-',
      (d.status || 'pending').toUpperCase(),
    ]
  })

  exportToExcel('Rekap_Dispensasi_KBM_MA_Unggulan', headers, rows)
  toast.success('File Rekapitulasi Excel Dispensasi KBM berhasil diunduh!', 'Export Berhasil')
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Perizinan Dispensasi Belajar (KBM)</template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Humanized Administrative Top Section -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200/90 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-1.5 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-slate-100 text-slate-700 text-xs font-semibold">
            <i class="fa-solid fa-file-signature text-brand-navy"></i>
            Pelayanan Administrasi Kesiswaan & Kurikulum
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Manajemen Surat Izin Dispensasi KBM
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Kelola persetujuan izin bagi siswa yang menjalani persiapan, bimbingan intensif, maupun keberangkatan lomba agar tetap tercatat resmi dan tidak dianggap alpa oleh guru kelas.
          </p>
        </div>

        <div class="flex items-center gap-2.5 shrink-0 flex-wrap">
          <button
            type="button"
            @click="exportDispensationsExcel"
            class="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold border border-emerald-700 shadow-2xs transition-all cursor-pointer"
            title="Unduh Rekapitulasi Data Dispensasi Format Excel"
          >
            <i class="fa-solid fa-file-excel"></i>
            <span>Export Excel</span>
          </button>

          <router-link
            to="/school/dispensations/form-settings"
            class="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold border border-slate-300 shadow-2xs transition-all cursor-pointer"
            title="Kustomisasi Format Surat, Kop Sekolah, dan Kolom Formulir Siswa"
          >
            <i class="fa-solid fa-stamp text-brand-navy"></i>
            <span>Format Surat & Kop</span>
          </router-link>

          <button
            type="button"
            @click="showCreateModal = true"
            class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-[#00164a] transition-all cursor-pointer"
          >
            <i class="fa-solid fa-circle-plus text-brand-gold"></i>
            <span>Terbitkan Surat Dispensasi</span>
          </button>
        </div>
      </div>

      <!-- Operational Status Ledger (Clean, practical tiles) -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <!-- Tile 1: Pending Review -->
        <div
          :class="[
            'bg-white rounded-xl p-4 border transition-all cursor-pointer',
            statusFilter === 'pending' ? 'border-amber-400 ring-2 ring-amber-100' : 'border-slate-200/80 hover:border-slate-300'
          ]"
          @click="statusFilter = statusFilter === 'pending' ? 'all' : 'pending'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Perlu Tindakan / Menunggu Persetujuan</span>
            <span class="w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse"></span>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-amber-600 font-mono">{{ pendingCount }}</span>
            <span class="text-xs text-slate-500 font-medium">permohonan diajukan</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Siswa menunggu surat pengesahan kesiswaan</p>
        </div>

        <!-- Tile 2: Approved Active -->
        <div
          :class="[
            'bg-white rounded-xl p-4 border transition-all cursor-pointer',
            statusFilter === 'approved' ? 'border-emerald-400 ring-2 ring-emerald-100' : 'border-slate-200/80 hover:border-slate-300'
          ]"
          @click="statusFilter = statusFilter === 'approved' ? 'all' : 'approved'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Surat Disetujui & Resmi Terbit</span>
            <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-emerald-700 font-mono">{{ approvedCount }}</span>
            <span class="text-xs text-slate-500 font-medium">surat sah</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Dapat dicetak atau dicek via QR guru</p>
        </div>

        <!-- Tile 3: Total Archive -->
        <div
          :class="[
            'bg-white rounded-xl p-4 border transition-all cursor-pointer',
            statusFilter === 'all' ? 'border-blue-400 ring-2 ring-blue-100' : 'border-slate-200/80 hover:border-slate-300'
          ]"
          @click="statusFilter = 'all'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Total Arsip Dispensasi Belajar</span>
            <i class="fa-solid fa-folder-closed text-slate-400 text-xs"></i>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-brand-navy font-mono">{{ dispensations.length }}</span>
            <span class="text-xs text-slate-500 font-medium">dokumen tercatat</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">{{ rejectedCount }} permohonan ditolak</p>
        </div>
      </div>

      <!-- Filter Controls & Search -->
      <div class="bg-white rounded-xl p-3 sm:p-4 border border-slate-200/80 shadow-xs flex flex-col md:flex-row items-center justify-between gap-3">
        <!-- Filter Tabs -->
        <div class="flex items-center gap-1.5 overflow-x-auto w-full md:w-auto">
          <button
            type="button"
            @click="statusFilter = 'all'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              statusFilter === 'all'
                ? 'bg-brand-navy text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Semua ({{ dispensations.length }})
          </button>
          <button
            type="button"
            @click="statusFilter = 'pending'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap flex items-center gap-1.5',
              statusFilter === 'pending'
                ? 'bg-amber-600 text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            <span>Menunggu Tindakan</span>
            <span v-if="pendingCount > 0" class="px-1.5 py-0.2 rounded-full text-[10px] bg-amber-200 text-amber-900 font-bold">
              {{ pendingCount }}
            </span>
          </button>
          <button
            type="button"
            @click="statusFilter = 'approved'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              statusFilter === 'approved'
                ? 'bg-emerald-700 text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Disetujui ({{ approvedCount }})
          </button>
          <button
            type="button"
            @click="statusFilter = 'rejected'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              statusFilter === 'rejected'
                ? 'bg-red-700 text-white shadow-xs'
                : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Ditolak ({{ rejectedCount }})
          </button>
        </div>

        <!-- Search Input -->
        <div class="relative w-full md:w-80">
          <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Cari siswa, nama kegiatan, no surat..."
            class="w-full text-xs rounded-lg border border-slate-200 bg-slate-50 pl-8 pr-3 py-2 text-slate-700 placeholder-slate-400 focus:outline-hidden focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy transition-all"
          />
        </div>
      </div>

      <!-- Main Data Table Container -->
      <div class="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div v-if="loading" class="py-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2 font-medium">Memuat data perizinan dispensasi...</p>
        </div>

        <div v-else-if="filteredDispensations.length === 0" class="py-16 text-center">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
            <i class="fa-regular fa-folder-open"></i>
          </div>
          <h3 class="text-sm font-bold text-slate-800">Tidak Ditemukan Data Dispensasi</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
            Belum ada permohonan atau surat dispensasi yang sesuai dengan kriteria filter saat ini.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs border-collapse">
            <thead class="bg-slate-50 text-slate-500 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[10px]">
              <tr>
                <th class="px-4 py-3">Nomor & Kegiatan</th>
                <th class="px-4 py-3">Siswa Penerima Izin</th>
                <th class="px-4 py-3">Jadwal Pelaksanaan</th>
                <th class="px-4 py-3">Jenis & Pembimbing</th>
                <th class="px-4 py-3">Status Izin</th>
                <th class="px-4 py-3 text-right">Tindakan</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 text-slate-700">
              <tr
                v-for="item in filteredDispensations"
                :key="item.id"
                class="hover:bg-slate-50/80 transition-colors"
              >
                <!-- Nomor & Kegiatan -->
                <td class="px-4 py-3.5 max-w-xs">
                  <p class="font-bold text-slate-900 text-xs leading-snug">
                    {{ item.competition_name }}
                  </p>
                  <p class="font-mono text-[11px] text-slate-500 mt-0.5">
                    {{ item.reference_number || 'Nomor surat belum diterbitkan' }}
                  </p>
                  <p class="text-[11px] text-slate-500 truncate mt-1 italic">
                    "{{ item.purpose }}"
                  </p>
                </td>

                <!-- Siswa Penerima Izin -->
                <td class="px-4 py-3.5">
                  <div class="space-y-1">
                    <div
                      v-for="s in (item.students || []).slice(0, 2)"
                      :key="s.id"
                      class="flex items-center gap-1.5 font-medium text-slate-800"
                    >
                      <i class="fa-solid fa-user-graduate text-[10px] text-brand-blue"></i>
                      <span>{{ s.full_name }}</span>
                      <span class="text-[10px] text-slate-400 font-normal">({{ s.class_name }})</span>
                    </div>
                    <p v-if="(item.students || []).length > 2" class="text-[10px] font-bold text-brand-blue">
                      +{{ item.students.length - 2 }} siswa lainnya
                    </p>
                  </div>
                </td>

                <!-- Jadwal Pelaksanaan -->
                <td class="px-4 py-3.5 whitespace-nowrap">
                  <p class="font-semibold text-slate-800">
                    {{ formatDateRange(item.start_date, item.end_date) }}
                  </p>
                  <p class="text-[11px] text-slate-500 mt-0.5">
                    {{ item.is_all_day ? 'Seharian Penuh' : `${item.start_time || '-'} s.d. ${item.end_time || '-'}` }}
                  </p>
                </td>

                <!-- Jenis & Pembimbing -->
                <td class="px-4 py-3.5">
                  <span class="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                    {{ item.dispensation_type === 'persiapan_latihan' ? 'Latihan / Persiapan' : 'Hari Pelaksanaan' }}
                  </span>
                  <p v-if="item.supervisor_name" class="text-[11px] text-slate-600 mt-1">
                    <i class="fa-solid fa-chalkboard-user mr-1 text-slate-400"></i>
                    {{ item.supervisor_name }}
                  </p>
                </td>

                <!-- Status Izin -->
                <td class="px-4 py-3.5 whitespace-nowrap">
                  <span
                    v-if="item.status === 'approved'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200"
                  >
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                    Disetujui
                  </span>
                  <span
                    v-else-if="item.status === 'rejected'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold bg-rose-50 text-rose-800 border border-rose-200"
                  >
                    <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                    Ditolak
                  </span>
                  <span
                    v-else
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold bg-amber-50 text-amber-800 border border-amber-200"
                  >
                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
                    Menunggu Review
                  </span>
                </td>

                <!-- Tindakan -->
                <td class="px-4 py-3.5 text-right whitespace-nowrap">
                  <div class="inline-flex items-center gap-2">
                    <button
                      v-if="item.status === 'pending'"
                      type="button"
                      @click="openReviewModal(item)"
                      class="px-3 py-1.5 rounded-lg bg-brand-navy text-white text-xs font-bold hover:bg-[#00164a] transition-all cursor-pointer"
                    >
                      Tinjau
                    </button>

                    <button
                      v-if="item.status === 'approved'"
                      type="button"
                      @click="openPrintPreview(item.id)"
                      class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold transition-all cursor-pointer border border-slate-200"
                      title="Cetak Surat Dispensasi Resmi"
                    >
                      <i class="fa-solid fa-print text-slate-500"></i>
                      <span>Cetak Surat</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Review Modal -->
    <Modal v-model="showReviewModal" title="Tinjauan Surat Dispensasi Belajar" @close="showReviewModal = false">
      <div v-if="selectedDisp" class="space-y-4 text-xs">
        <div class="p-4 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-[10px] uppercase font-bold text-slate-400">Kegiatan Lomba</p>
              <p class="text-sm font-bold text-brand-navy mt-0.5">{{ selectedDisp.competition_name }}</p>
            </div>
            <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-200 text-slate-700">
              {{ selectedDisp.dispensation_type === 'persiapan_latihan' ? 'Latihan / Persiapan' : 'Hari Pelaksanaan' }}
            </span>
          </div>

          <div class="grid grid-cols-2 gap-3 pt-2 border-t border-slate-200/80">
            <div>
              <p class="text-[10px] uppercase font-bold text-slate-400">Periode Izin</p>
              <p class="font-semibold text-slate-800">{{ formatDateRange(selectedDisp.start_date, selectedDisp.end_date) }}</p>
            </div>
            <div>
              <p class="text-[10px] uppercase font-bold text-slate-400">Guru Pendamping</p>
              <p class="font-semibold text-slate-800">{{ selectedDisp.supervisor_name || 'Tidak dicantumkan' }}</p>
            </div>
          </div>

          <div>
            <p class="text-[10px] uppercase font-bold text-slate-400">Keperluan / Keterangan</p>
            <p class="text-slate-700 mt-0.5">{{ selectedDisp.purpose }}</p>
          </div>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-2">Keputusan Kesiswaan *</label>
          <div class="grid grid-cols-2 gap-3">
            <label
              :class="[
                'p-3 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 cursor-pointer transition-all',
                reviewAction === 'approve'
                  ? 'bg-emerald-50 border-emerald-600 text-emerald-900 ring-1 ring-emerald-600'
                  : 'border-slate-200 text-slate-600 hover:bg-slate-50'
              ]"
            >
              <input type="radio" v-model="reviewAction" value="approve" class="sr-only" />
              <i class="fa-solid fa-circle-check text-emerald-600"></i>
              <span>Setujui Dispensasi</span>
            </label>

            <label
              :class="[
                'p-3 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 cursor-pointer transition-all',
                reviewAction === 'reject'
                  ? 'bg-rose-50 border-rose-600 text-rose-900 ring-1 ring-rose-600'
                  : 'border-slate-200 text-slate-600 hover:bg-slate-50'
              ]"
            >
              <input type="radio" v-model="reviewAction" value="reject" class="sr-only" />
              <i class="fa-solid fa-circle-xmark text-rose-600"></i>
              <span>Tolak Permohonan</span>
            </label>
          </div>
        </div>

        <div v-if="reviewAction === 'approve'">
          <label class="block font-bold text-slate-700 mb-1">Nomor Surat Dinas (Opsional)</label>
          <input
            v-model="referenceNumberInput"
            type="text"
            placeholder="Kosongkan untuk penomoran otomatis sistem (421.3/...)"
            class="w-full text-xs rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
          <p class="text-[10px] text-slate-400 mt-1">Format penomoran standar sekolah akan diterapkan jika dikosongkan.</p>
        </div>

        <div v-if="reviewAction === 'reject'">
          <label class="block font-bold text-slate-700 mb-1">Alasan Penolakan Izin *</label>
          <textarea
            v-model="rejectionReasonInput"
            rows="2"
            required
            placeholder="Jelaskan alasan penolakan untuk siswa pemohon..."
            class="w-full text-xs rounded-lg border border-slate-300 p-2.5 focus:border-rose-500 focus:outline-hidden"
          ></textarea>
        </div>

        <div class="pt-3 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showReviewModal = false"
            class="px-4 py-2 rounded-lg font-semibold text-slate-600 hover:bg-slate-100 cursor-pointer"
          >
            Batal
          </button>
          <button
            type="button"
            @click="submitReview"
            :disabled="reviewing"
            class="px-5 py-2 rounded-lg font-bold bg-brand-navy text-white hover:bg-[#00164a] disabled:opacity-50 transition-all flex items-center gap-2 cursor-pointer"
          >
            <i v-if="reviewing" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ reviewing ? 'Menyimpan...' : 'Simpan Keputusan' }}</span>
          </button>
        </div>
      </div>
    </Modal>

    <!-- Create Direct Dispensation Modal -->
    <Modal v-model="showCreateModal" title="Penerbitan Surat Dispensasi Belajar Langsung" @close="showCreateModal = false">
      <form @submit.prevent="handleCreateDirect" class="space-y-4 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Nama Lomba / Kegiatan *</label>
          <input
            v-model="createForm.competition_name"
            type="text"
            required
            placeholder="Contoh: Lomba Cerdas Cermat Fisika UNY 2026"
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block font-bold text-slate-700 mb-1">Jenis Izin *</label>
            <select
              v-model="createForm.dispensation_type"
              required
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            >
              <option value="persiapan_latihan">Persiapan & Latihan Intensif</option>
              <option value="pelaksanaan_lomba">Hari-H Pelaksanaan Lomba</option>
              <option value="lainnya">Kegiatan Lainnya</option>
            </select>
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Guru Pendamping / Pembina</label>
            <input
              v-model="createForm.supervisor_name"
              type="text"
              placeholder="Contoh: Dra. Hj. Siti Aminah, M.Pd."
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Pilih Siswa yang Diberi Dispensasi *</label>
          <select
            multiple
            v-model="createForm.student_ids"
            required
            class="w-full h-32 rounded-lg border border-slate-300 p-2 focus:border-brand-navy focus:outline-hidden font-sans"
          >
            <option v-for="s in students" :key="s.id" :value="s.id" class="py-1">
              {{ s.full_name }} — Kelas {{ s.class_name }} (NIS: {{ s.nis }})
            </option>
          </select>
          <p class="text-[10px] text-slate-400 mt-1">Gunakan tombol Ctrl / Cmd untuk memilih lebih dari 1 siswa sekaligus.</p>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Uraian / Tujuan Dispensasi *</label>
          <textarea
            v-model="createForm.purpose"
            rows="2"
            required
            placeholder="Contoh: Mengikuti karantina materi dan simulasi babak final di laboratorium sekolah."
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block font-bold text-slate-700 mb-1">Tanggal Mulai Izin *</label>
            <input
              v-model="createForm.start_date"
              type="date"
              required
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Tanggal Selesai Izin *</label>
            <input
              v-model="createForm.end_date"
              type="date"
              required
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Nomor Surat Dinas (Opsional)</label>
          <input
            v-model="createForm.reference_number"
            type="text"
            placeholder="Contoh: 421.3/045/SMAN1/DISP/2026"
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
        </div>

        <!-- Dynamic Custom Fields from School Schema -->
        <div v-if="formSchema && formSchema.length > 0" class="pt-4 border-t border-slate-200 space-y-3">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-1.5 text-brand-navy font-black text-xs">
              <i class="fa-solid fa-sparkles text-brand-gold"></i>
              <span>Kolom Khusus Sekolah</span>
            </div>
            <router-link
              to="/school/dispensations/form-settings"
              class="text-[10px] text-brand-navy hover:underline font-bold"
              target="_blank"
            >
              Atur Kolom &rarr;
            </router-link>
          </div>

          <div v-for="field in formSchema" :key="field.id" class="space-y-1">
            <label class="block font-bold text-slate-700">
              {{ field.label }}
              <span v-if="field.is_required" class="text-rose-500">*</span>
              <span v-else class="text-[10px] text-slate-400 font-normal"> (Opsional)</span>
            </label>

            <!-- Text Input -->
            <input
              v-if="field.type === 'text'"
              v-model="createForm.custom_fields_data[field.name]"
              type="text"
              :placeholder="field.placeholder || ''"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />

            <!-- Textarea -->
            <textarea
              v-else-if="field.type === 'textarea'"
              v-model="createForm.custom_fields_data[field.name]"
              rows="2"
              :placeholder="field.placeholder || ''"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            ></textarea>

            <!-- Select Dropdown -->
            <select
              v-else-if="field.type === 'select'"
              v-model="createForm.custom_fields_data[field.name]"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            >
              <option value="">-- Pilih {{ field.label }} --</option>
              <option v-for="(opt, oIdx) in (field.options || [])" :key="oIdx" :value="opt">
                {{ opt }}
              </option>
            </select>

            <!-- Number -->
            <input
              v-else-if="field.type === 'number'"
              v-model.number="createForm.custom_fields_data[field.name]"
              type="number"
              :placeholder="field.placeholder || '0'"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />

            <!-- Date -->
            <input
              v-else-if="field.type === 'date'"
              v-model="createForm.custom_fields_data[field.name]"
              type="date"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />

            <!-- Checkbox -->
            <label v-else-if="field.type === 'checkbox'" class="flex items-start gap-2 pt-1 cursor-pointer">
              <input
                type="checkbox"
                v-model="createForm.custom_fields_data[field.name]"
                :required="field.is_required"
                class="mt-0.5 rounded border-slate-300 text-brand-navy focus:ring-brand-navy"
              />
              <span class="text-slate-700 leading-snug">{{ field.label }}</span>
            </label>

            <p v-if="field.description" class="text-[10px] text-slate-400 italic">
              {{ field.description }}
            </p>
          </div>
        </div>

        <div class="pt-3 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showCreateModal = false"
            class="px-4 py-2 rounded-lg font-semibold text-slate-600 hover:bg-slate-100 cursor-pointer"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="creating"
            class="px-5 py-2 rounded-lg font-bold bg-brand-navy text-white hover:bg-[#00164a] disabled:opacity-50 transition-all flex items-center gap-2 cursor-pointer"
          >
            <i v-if="creating" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ creating ? 'Menerbitkan...' : 'Terbitkan Surat' }}</span>
          </button>
        </div>
      </form>
    </Modal>

    <!-- Authentic Official Indonesian School Dispensation Letter (Print Preview Modal) -->
    <Modal v-model="showPrintModal" title="Pratinjau Cetak Surat Resmi Sekolah" @close="showPrintModal = false">
      <div v-if="printData" class="space-y-4 text-slate-800">
        <!-- The Printable Paper Document (A4 Styling) -->
        <div
          id="printable-dispensation-letter"
          class="bg-white p-8 sm:p-12 rounded-xl border border-slate-300 shadow-sm text-black font-serif space-y-4 max-w-2xl mx-auto"
        >
          <!-- Official Kop Surat Sekolah (Dukungan Gambar Kop / Teks Garis Ganda) -->
          <div class="text-center pb-2">
            <div v-if="printData.letterhead_type === 'image' && printData.letterhead_image_url" class="mb-2">
              <img
                :src="printData.letterhead_image_url"
                alt="Kop Surat Sekolah"
                class="max-h-28 object-contain w-auto mx-auto"
              />
            </div>
            <div v-else>
              <h2 class="text-base sm:text-lg font-black uppercase tracking-wider leading-tight">
                {{ printData.letter_format_config?.institution_level1 || 'PEMERINTAH DAERAH PROVINSI' }}
              </h2>
              <p class="text-xs font-black uppercase tracking-wide text-slate-800 mt-0.5">
                {{ printData.letter_format_config?.institution_level2 || 'DINAS PENDIDIKAN DAN KEBUDAYAAN' }}
              </p>
              <h3 class="text-sm sm:text-base font-black uppercase tracking-wide text-slate-900 mt-0.5">
                {{ printData.school?.name || 'SMA NEGERI CONTOH' }}
              </h3>
              <p class="text-xs font-sans text-slate-700 mt-1 leading-normal">
                {{ printData.school?.address || 'Jalan Pendidikan No. 1' }} • NPSN: {{ printData.school?.npsn || '-' }}
              </p>
              <p class="text-[11px] font-sans text-slate-600">
                Telp: {{ printData.school?.phone || '-' }} • Email: {{ printData.school?.email || '-' }}
              </p>

              <!-- Dual Border Hairlines standard in Indonesian government documents -->
              <div class="mt-3 border-t-2 border-black"></div>
              <div class="mt-0.5 border-t border-black"></div>
            </div>
          </div>

          <!-- Document Title & Reference Number -->
          <div class="text-center pt-2 space-y-0.5">
            <h3 class="text-sm sm:text-base font-black uppercase underline tracking-wide">
              {{ printData.letter_format_config?.document_title || 'SURAT KETERANGAN DISPENSASI BELAJAR (KBM)' }}
            </h3>
            <p class="text-xs font-sans font-semibold text-slate-700">
              Nomor: {{ printData.dispensation?.reference_number }}
            </p>
          </div>

          <!-- Document Body -->
          <div class="text-xs font-sans text-slate-900 leading-relaxed space-y-3 pt-2">
            <p>
              Yang bertanda tangan di bawah ini, Kepala Sekolah / Bidang Kesiswaan {{ printData.school?.name }}, menerangkan bahwa siswa-siswi tersebut di bawah ini:
            </p>

            <!-- Student Table -->
            <table class="w-full text-xs border border-slate-400 border-collapse my-2">
              <thead class="bg-slate-100 font-bold text-slate-800">
                <tr>
                  <th class="border border-slate-400 px-2.5 py-1.5 text-center w-8">No</th>
                  <th class="border border-slate-400 px-3 py-1.5 text-left">Nama Siswa</th>
                  <th class="border border-slate-400 px-3 py-1.5 text-center">NIS</th>
                  <th class="border border-slate-400 px-3 py-1.5 text-center">Kelas</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(std, idx) in printData.students" :key="std.id">
                  <td class="border border-slate-400 px-2.5 py-1.5 text-center">{{ Number(idx) + 1 }}</td>
                  <td class="border border-slate-400 px-3 py-1.5 font-bold">{{ std.full_name }}</td>
                  <td class="border border-slate-400 px-3 py-1.5 text-center font-mono">{{ std.nis || '-' }}</td>
                  <td class="border border-slate-400 px-3 py-1.5 text-center">{{ std.class_name || '-' }}</td>
                </tr>
              </tbody>
            </table>

            <p>
              Diberikan izin dispensasi untuk tidak mengikuti Kegiatan Belajar Mengajar (KBM) di kelas sehubungan dengan keikutsertaan pada kegiatan:
            </p>

            <div class="bg-slate-50 p-3 rounded-lg border border-slate-300 text-xs space-y-1 my-2">
              <p><span class="font-bold">Nama Kegiatan:</span> {{ printData.dispensation?.competition_name }}</p>
              <p><span class="font-bold">Keperluan:</span> {{ printData.dispensation?.purpose }}</p>
              <p><span class="font-bold">Waktu Pelaksanaan:</span> {{ formatDateRange(printData.dispensation?.start_date, printData.dispensation?.end_date) }}</p>
              <p><span class="font-bold">Guru Pembina:</span> {{ printData.dispensation?.supervisor_name || 'Pembina Lomba Sekolah' }}</p>

              <!-- Dynamic custom fields on printable letter -->
              <template v-if="printData.form_schema && printData.form_schema.length > 0">
                <template v-for="cf in printData.form_schema" :key="cf.id">
                  <p v-if="printData.custom_fields_data && printData.custom_fields_data[cf.name] !== undefined && printData.custom_fields_data[cf.name] !== ''">
                    <span class="font-bold">{{ cf.label }}:</span>
                    {{ typeof printData.custom_fields_data[cf.name] === 'boolean' ? (printData.custom_fields_data[cf.name] ? 'Ya / Terpenuhi' : 'Tidak') : printData.custom_fields_data[cf.name] }}
                  </p>
                </template>
              </template>
            </div>

            <p class="italic text-slate-700">
              {{ printData.letter_format_config?.closing_text || 'Demikian surat dispensasi ini dibuat agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa tetap berkewajiban menyelesaikan materi pelajaran serta tugas-tugas yang tertinggal.' }}
            </p>
          </div>

          <!-- Bottom: QR Code Verification Box & Dual Signatures Block -->
          <div class="pt-6 grid grid-cols-12 gap-4 items-end text-xs font-sans">
            <!-- Left: Official QR Verification (3 Cols) -->
            <div class="col-span-3 text-center p-2.5 border border-slate-300 rounded-lg bg-slate-50/50">
              <img
                v-if="printData.qr_code_data_uri"
                :src="printData.qr_code_data_uri"
                alt="QR Code Verifikasi"
                class="w-20 h-20 mx-auto"
              />
              <p class="text-[8.5px] text-slate-600 font-medium leading-tight mt-1">
                Pindai QR untuk verifikasi keabsahan izin
              </p>
            </div>

            <!-- Right: 2 Signatures Columns (9 Cols) -->
            <div class="col-span-9 grid grid-cols-2 gap-4 text-center">
              <!-- Tanda Tangan 1: Guru Pembina Lomba (Terisi Otomatis) -->
              <div class="space-y-12">
                <div class="text-[11px] text-slate-700 leading-tight">
                  Ditetapkan di: {{ printData.school?.city || 'Sekolah' }}<br />
                  Pada tanggal: {{ printData.printed_at }}<br />
                  <span class="font-bold text-slate-900 mt-1 block">Mengetahui,<br>Guru Pembina Lomba</span>
                </div>
                <div>
                  <p class="font-bold underline text-xs text-brand-navy">
                    {{ printData.dispensation?.supervisor_name || 'Guru Pembina Lomba' }}
                  </p>
                  <p class="text-[10px] text-slate-500">NIP. - / Pembina Prestasi</p>
                </div>
              </div>

              <!-- Tanda Tangan 2: Guru Mata Pelajaran / Guru Piket (Dikosongkan) -->
              <div class="space-y-12">
                <div class="text-[11px] text-slate-700 leading-tight">
                  <br /><br />
                  <span class="font-bold text-slate-900 mt-1 block">Menyetujui / Memaklumi,<br>Guru Mata Pelajaran / Piket</span>
                </div>
                <div>
                  <p class="font-bold text-xs text-slate-600">
                    ( .................................................. )
                  </p>
                  <p class="text-[9.5px] text-slate-400 italic mt-0.5">*Ditandatangani saat jam KBM di kelas</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Action Buttons: Unduh DOCX, Unduh PDF, dan Cetak Langsung -->
        <div class="flex flex-wrap items-center justify-between gap-3 pt-3 border-t border-slate-200">
          <div class="text-xs text-slate-500 flex items-center gap-1.5">
            <i class="fa-solid fa-circle-check text-emerald-600"></i>
            <span>Dokumen resmi siap dicetak atau diunduh</span>
          </div>

          <div class="flex flex-wrap items-center gap-2">
            <button
              type="button"
              @click="showPrintModal = false"
              class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100 cursor-pointer"
            >
              Tutup
            </button>

            <!-- Unduh DOCX -->
            <button
              type="button"
              @click="downloadDocx(printData.dispensation?.id, printData.dispensation?.reference_number)"
              :disabled="downloadingDocx"
              class="px-4 py-2 rounded-xl text-xs font-bold bg-blue-700 hover:bg-blue-800 text-white flex items-center gap-2 shadow-xs cursor-pointer disabled:opacity-60"
            >
              <i v-if="downloadingDocx" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-file-word"></i>
              <span>Unduh DOCX (.docx)</span>
            </button>

            <!-- Unduh PDF -->
            <button
              type="button"
              @click="downloadPdf(printData.dispensation?.id, printData.dispensation?.reference_number)"
              :disabled="downloadingPdf"
              class="px-4 py-2 rounded-xl text-xs font-bold bg-rose-700 hover:bg-rose-800 text-white flex items-center gap-2 shadow-xs cursor-pointer disabled:opacity-60"
            >
              <i v-if="downloadingPdf" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-file-pdf"></i>
              <span>Unduh PDF (.pdf)</span>
            </button>

            <!-- Cetak Window -->
            <button
              type="button"
              @click="handlePrintAction"
              class="px-4 py-2 rounded-xl text-xs font-bold bg-brand-navy hover:bg-[#00164a] text-white flex items-center gap-2 shadow-xs cursor-pointer"
            >
              <i class="fa-solid fa-print text-brand-gold"></i>
              <span>Cetak Pratinjau</span>
            </button>
          </div>
        </div>
      </div>
    </Modal>
  </DashboardLayout>
</template>
