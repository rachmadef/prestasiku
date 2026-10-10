<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

interface EligibleCompetition {
  id: number
  title: string
  level: string
  curation_type: string
  sop_bisyaroh_recommendation: number
}

interface Supervisor {
  id: number
  supervisor_name: string
  supervisor_nip?: string
  supervisor_phone?: string
  role_title: string
  bisyaroh_amount: number
  sop_category?: string
  notes?: string
  status: 'pending' | 'approved' | 'disbursed'
  created_at: string
  competition?: {
    id: number
    title: string
    level: string
    curation_type: string
  }
}

const supervisors = ref<Supervisor[]>([])
const eligibleCompetitions = ref<EligibleCompetition[]>([])
const loading = ref(true)
const submitting = ref(false)
const filterStatus = ref<'all' | 'pending' | 'approved' | 'disbursed'>('all')
const searchQuery = ref('')
const errorMessage = ref('')

// Modal state
const isModalOpen = ref(false)
const selectedCompetition = ref<EligibleCompetition | null>(null)

const form = ref({
  competition_id: '',
  supervisor_name: '',
  supervisor_nip: '',
  supervisor_phone: '',
  role_title: 'Pembimbing Utama',
  bisyaroh_amount: 0,
  notes: '',
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

const fetchEligibleCompetitions = async () => {
  try {
    const response = await api.get('/school/supervisors/eligible-competitions')
    eligibleCompetitions.value = response.data.data || []
  } catch (err: any) {
    console.error('Error fetching eligible competitions:', err)
  }
}

const filteredSupervisors = computed(() => {
  return supervisors.value.filter((item) => {
    const matchStatus = filterStatus.value === 'all' || item.status === filterStatus.value
    const query = searchQuery.value.toLowerCase().trim()
    const matchSearch =
      !query ||
      item.supervisor_name.toLowerCase().includes(query) ||
      (item.supervisor_nip && item.supervisor_nip.toLowerCase().includes(query)) ||
      (item.competition && item.competition.title.toLowerCase().includes(query))

    return matchStatus && matchSearch
  })
})

const totalBisyaroh = computed(() => {
  return supervisors.value.reduce((sum, item) => sum + Number(item.bisyaroh_amount || 0), 0)
})

const handleCompetitionSelect = () => {
  const comp = eligibleCompetitions.value.find((c) => c.id === Number(form.value.competition_id))
  if (comp) {
    selectedCompetition.value = comp
    form.value.bisyaroh_amount = comp.sop_bisyaroh_recommendation
  } else {
    selectedCompetition.value = null
    form.value.bisyaroh_amount = 0
  }
}

const openModal = () => {
  form.value = {
    competition_id: '',
    supervisor_name: '',
    supervisor_nip: '',
    supervisor_phone: '',
    role_title: 'Pembimbing Utama',
    bisyaroh_amount: 0,
    notes: '',
  }
  selectedCompetition.value = null
  errorMessage.value = ''
  isModalOpen.value = true
}

const closeModal = () => {
  isModalOpen.value = false
}

const submitForm = async () => {
  if (!form.value.competition_id || !form.value.supervisor_name || !form.value.bisyaroh_amount) {
    errorMessage.value = 'Mohon lengkapi data lomba, nama pendamping, dan nominal bisyaroh.'
    return
  }

  submitting.value = true
  errorMessage.value = ''

  try {
    await api.post('/school/supervisors', form.value)
    toast.success('Form Pendamping & Pembagian Bisyaroh berhasil menerbitkan penetapan resmi.', 'Bisyaroh Diterbitkan')
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

const formatCurrency = (val: number) => {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}

const getCurationBadgeClass = (type?: string) => {
  if (type === 'resmi_negara') return 'bg-emerald-50 text-emerald-700 border-emerald-200'
  if (type === 'terkurasi_puspresnas') return 'bg-blue-50 text-blue-700 border-blue-200'
  return 'bg-amber-50 text-amber-700 border-amber-200'
}

const getCurationLabel = (type?: string) => {
  if (type === 'resmi_negara') return 'Resmi Negara'
  if (type === 'terkurasi_puspresnas') return 'Terkurasi Puspresnas'
  return 'Non-Kurasi'
}

import { exportToExcel } from '@/utils/exportExcel'

const exportSupervisorsExcel = () => {
  if (!supervisors.value || supervisors.value.length === 0) {
    toast.error('Tidak ada data pendamping & bisyaroh untuk di-export.', 'Export Gagal')
    return
  }

  const headers = [
    'No',
    'Nama Pendamping / Pembimbing',
    'NIP / NIK',
    'No HP / WhatsApp',
    'Peran / Jabatan',
    'Nama Kompetisi / Lomba',
    'Alokasi Bisyaroh (Rp)',
    'Status SOP / Pencairan',
    'Catatan / Keterangan',
  ]

  const rows = filteredSupervisors.value.map((item, idx) => [
    idx + 1,
    item.supervisor_name,
    item.supervisor_nip || '-',
    item.supervisor_phone || '-',
    item.role_title,
    item.competition?.title || '-',
    item.bisyaroh_amount || 0,
    item.status === 'disbursed' ? 'Sudah Dicairkan' : item.status === 'approved' ? 'Disetujui SOP' : 'Menunggu',
    item.notes || '-',
  ])

  exportToExcel('Rekap_Pendamping_Bisyaroh_MA_Unggulan', headers, rows)
  toast.success('File Rekapitulasi Excel Pendamping & Bisyaroh berhasil diunduh!', 'Export Berhasil')
}

onMounted(() => {
  fetchSupervisors()
  fetchEligibleCompetitions()
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
            Pelayanan Pendampingan & Insentif SOP Instansi
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Form Pendamping Lomba & Bisyaroh
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Penetapan pendamping perlombaan & alokasi insentif/bisyaroh sesuai SOP instansi (Khusus Lomba Resmi & Terkurasi).
          </p>
        </div>

        <div class="flex items-center gap-2.5 shrink-0 flex-wrap">
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

      <!-- Operational Alert Notice (Amber Clean Box) -->
      <div class="bg-amber-50/90 rounded-xl p-4 border border-amber-200/90 text-amber-900 text-xs sm:text-sm flex items-start gap-3 shadow-2xs">
        <i class="fa-solid fa-circle-info text-amber-600 text-base shrink-0 mt-0.5"></i>
        <div class="leading-relaxed">
          <strong class="font-bold">Ketentuan SOP Pembagian Bisyaroh Pendamping:</strong>
          Pemberian insentif/bisyaroh pendamping <u>hanya berlaku</u> untuk lomba yang telah terverifikasi sebagai <span class="font-semibold text-emerald-800">Resmi Negara</span> atau <span class="font-semibold text-blue-800">Terkurasi Puspresnas</span>. Lomba mandiri/non-kurasi tidak dapat dialokasikan bisyaroh pendamping.
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
          <p class="text-[11px] text-slate-400 mt-1">Sesuai plafon SOP instansi</p>
        </div>

        <!-- Tile 3: Eligible Competitions -->
        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Lomba Terkurasi Didampingi</span>
            <i class="fa-solid fa-award text-indigo-600 text-xs"></i>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-indigo-700 font-mono">{{ eligibleCompetitions.length }}</span>
            <span class="text-xs text-slate-500 font-medium">lomba resmi</span>
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Lomba Resmi Negara / Terkurasi</p>
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
            placeholder="Cari nama pendamping, lomba..."
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
            Klik tombol "Buat Form Pendamping" di atas untuk menerbitkan form penetapan pendamping lomba resmi.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs border-collapse">
            <thead class="bg-slate-50 text-slate-500 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[10px]">
              <tr>
                <th class="px-4 py-3">Pendamping</th>
                <th class="px-4 py-3">Lomba & Tingkat</th>
                <th class="px-4 py-3">Kurasi SOP</th>
                <th class="px-4 py-3">Nominal Bisyaroh</th>
                <th class="px-4 py-3 text-center">Status</th>
                <th class="px-4 py-3 text-right">Tindakan</th>
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
                </td>

                <!-- Lomba & Tingkat -->
                <td class="px-4 py-3.5 max-w-xs">
                  <p class="font-bold text-slate-800 text-xs leading-snug">
                    {{ item.competition?.title || '-' }}
                  </p>
                  <p class="text-[11px] text-slate-500 capitalize mt-0.5">
                    Tingkat {{ item.competition?.level || '-' }}
                  </p>
                </td>

                <!-- Kurasi SOP -->
                <td class="px-4 py-3.5">
                  <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium border" :class="getCurationBadgeClass(item.competition?.curation_type)">
                    <i class="fa-solid fa-shield-check text-[10px] mr-1"></i>
                    {{ getCurationLabel(item.competition?.curation_type) }}
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

                <!-- Actions -->
                <td class="px-4 py-3.5 text-right">
                  <button
                    type="button"
                    @click="deleteSupervisor(item.id)"
                    class="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-semibold text-rose-600 hover:bg-rose-50 hover:text-rose-700 transition-colors cursor-pointer"
                  >
                    <i class="fa-regular fa-trash-can text-xs"></i>
                    <span>Hapus</span>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Modal Create Form Pendamping & Bisyaroh -->
      <Modal v-model="isModalOpen" title="Form Pendamping & Alokasi Bisyaroh" subtitle="Penetapan pendamping & alokasi insentif menurut SOP instansi." size="lg">
        <template #title-icon>
          <i class="fa-solid fa-user-shield text-brand-navy"></i>
        </template>

        <form @submit.prevent="submitForm" class="space-y-4">
          <div v-if="errorMessage" class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
            <i class="fa-solid fa-circle-exclamation mr-1.5"></i>
            {{ errorMessage }}
          </div>

          <!-- Select Curated Competition -->
          <div>
            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
              Pilih Lomba Resmi & Terkurasi *
            </label>
            <select
              v-model="form.competition_id"
              @change="handleCompetitionSelect"
              required
              class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
            >
              <option value="" disabled>-- Pilih Lomba Terkurasi --</option>
              <option v-for="comp in eligibleCompetitions" :key="comp.id" :value="comp.id">
                [{{ getCurationLabel(comp.curation_type) }}] {{ comp.title }} (Tingkat {{ comp.level.toUpperCase() }})
              </option>
            </select>
          </div>

          <!-- Recommendation Alert -->
          <div v-if="selectedCompetition" class="p-3 rounded-xl bg-blue-50/80 border border-blue-200 text-xs text-brand-navy space-y-1">
            <div class="flex items-center justify-between">
              <span><strong>Tingkatan Lomba:</strong> {{ selectedCompetition.level.toUpperCase() }}</span>
              <span class="px-2 py-0.5 rounded-md bg-white border border-blue-200 font-bold text-brand-blue">{{ getCurationLabel(selectedCompetition.curation_type) }}</span>
            </div>
            <div><strong>Rekomendasi Bisyaroh SOP:</strong> <span class="font-bold text-emerald-700 font-mono">{{ formatCurrency(selectedCompetition.sop_bisyaroh_recommendation) }}</span></div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                Nama Pendamping *
              </label>
              <input
                v-model="form.supervisor_name"
                type="text"
                required
                placeholder="Contoh: Drs. Ahmad Dahlan"
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
              />
            </div>
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                NIP / NIK Pendamping
              </label>
              <input
                v-model="form.supervisor_nip"
                type="text"
                placeholder="Opsional (misal: 198501...)"
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
              />
            </div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                Peran Pendamping *
              </label>
              <input
                v-model="form.role_title"
                type="text"
                required
                placeholder="Pembimbing Utama / Pendamping Lapangan"
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
              />
            </div>
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                Nominal Bisyaroh (Rp) *
              </label>
              <input
                v-model.number="form.bisyaroh_amount"
                type="number"
                required
                min="0"
                step="50000"
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 font-mono font-bold focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
              />
            </div>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
              No. Telepon / WhatsApp Pendamping
            </label>
            <input
              v-model="form.supervisor_phone"
              type="text"
              placeholder="Opsional (misal: 08123456789)"
              class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
            />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
              Catatan Rincian Tugas / SOP
            </label>
            <textarea
              v-model="form.notes"
              rows="2"
              placeholder="Catatan rincian tugas pendamping..."
              class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy focus:outline-hidden transition-all"
            ></textarea>
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
            <span>{{ submitting ? 'Memproses...' : 'Simpan Form Bisyaroh' }}</span>
          </button>
        </template>
      </Modal>
    </div>
  </DashboardLayout>
</template>
