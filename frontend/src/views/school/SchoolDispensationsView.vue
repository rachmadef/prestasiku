<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import SearchableSelect from '@/components/common/SearchableSelect.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

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
})

// Print Letter Preview Modal
const showPrintModal = ref(false)
const printData = ref<any>(null)

const studentOptions = computed(() => {
  return students.value.map((s: any) => ({
    value: s.id,
    label: s.full_name,
    sublabel: `NIS: ${s.nis || '-'} • Kelas ${s.class_name || '-'}`,
    badge: s.grade_level ? `Tingkat ${s.grade_level}` : undefined,
  }))
})

async function fetchData() {
  loading.value = true
  try {
    const [dispRes, studRes] = await Promise.all([
      api.get('/school/dispensations'),
      api.get('/school/students').catch(() => ({ data: { data: [] } })),
    ])
    dispensations.value = extractList(dispRes.data.data)
    students.value = extractList(studRes.data.data)
  } catch (err) {
    console.error('Error fetching school dispensations:', err)
  } finally {
    loading.value = false
  }
}

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
    }
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menerbitkan dispensasi.', 'Gagal Menerbitkan')
  } finally {
    creating.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <div class="space-y-6">
      <!-- Header Banner -->
      <div class="bg-white rounded-2xl p-6 sm:p-8 shadow-xs border border-slate-200/80 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 relative overflow-hidden">
        <div class="space-y-2 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-navy/10 text-brand-navy text-xs font-bold">
            <i class="fa-solid fa-file-signature text-brand-gold"></i>
            Layanan Kesiswaan & Kurikulum
          </div>
          <h1 class="text-2xl sm:text-3xl font-black text-brand-navy tracking-tight">Manajemen Dispensasi KBM</h1>
          <p class="text-sm text-slate-600 leading-relaxed">
            Kelola persetujuan perizinan tidak mengikuti Kegiatan Belajar Mengajar (KBM) bagi siswa yang sedang latihan intensif atau bertanding lomba. Terbitkan Surat Dispensasi resmi lengkap dengan QR Code verifikasi guru.
          </p>
        </div>
        <div class="flex items-center gap-3">
          <button
            @click="showCreateModal = true"
            class="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-md hover:bg-blue-900 transition-all cursor-pointer"
          >
            <i class="fa-solid fa-plus text-brand-gold"></i>
            <span>Terbitkan Dispensasi Langsung</span>
          </button>
        </div>
      </div>

      <!-- Filters & Search Bar -->
      <div class="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs flex flex-col md:flex-row items-center justify-between gap-4">
        <!-- Status Tabs -->
        <div class="flex items-center gap-1.5 overflow-x-auto w-full md:w-auto pb-1 md:pb-0">
          <button
            @click="statusFilter = 'all'"
            :class="[
              'px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap',
              statusFilter === 'all'
                ? 'bg-brand-navy text-white shadow-xs'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            ]"
          >
            Semua ({{ dispensations.length }})
          </button>
          <button
            @click="statusFilter = 'pending'"
            :class="[
              'px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap',
              statusFilter === 'pending'
                ? 'bg-amber-600 text-white shadow-xs'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            ]"
          >
            Menunggu Review ({{ dispensations.filter((d: any) => d.status === 'pending').length }})
          </button>
          <button
            @click="statusFilter = 'approved'"
            :class="[
              'px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap',
              statusFilter === 'approved'
                ? 'bg-emerald-600 text-white shadow-xs'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            ]"
          >
            Disetujui ({{ dispensations.filter((d: any) => d.status === 'approved').length }})
          </button>
          <button
            @click="statusFilter = 'rejected'"
            :class="[
              'px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap',
              statusFilter === 'rejected'
                ? 'bg-red-600 text-white shadow-xs'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            ]"
          >
            Ditolak ({{ dispensations.filter((d: any) => d.status === 'rejected').length }})
          </button>
        </div>

        <!-- Search Input -->
        <div class="relative w-full md:w-72">
          <i class="fa-solid fa-search absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Cari siswa, kegiatan, no surat..."
            class="w-full text-xs rounded-xl border border-slate-300 pl-9 pr-3.5 py-2 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          />
        </div>
      </div>

      <!-- Dispensations Table -->
      <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div v-if="loading" class="p-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-3xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2">Memuat daftar dispensasi...</p>
        </div>

        <div v-else-if="filteredDispensations.length === 0" class="p-16 text-center">
          <div class="w-16 h-16 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-2xl mb-4">
            <i class="fa-solid fa-file-circle-question"></i>
          </div>
          <h3 class="text-base font-bold text-slate-800">Tidak Ditemukan Data Dispensasi</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
            Belum ada permohonan dispensasi KBM yang sesuai dengan filter atau pencarian Anda.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50 border-b border-slate-200/80 text-[11px] uppercase tracking-wider text-slate-500 font-bold">
              <tr>
                <th class="px-5 py-3.5">Nomor & Kegiatan</th>
                <th class="px-5 py-3.5">Siswa Terlibat</th>
                <th class="px-5 py-3.5">Periode & Waktu</th>
                <th class="px-5 py-3.5">Jenis & Pembimbing</th>
                <th class="px-5 py-3.5">Status</th>
                <th class="px-5 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr
                v-for="item in filteredDispensations"
                :key="item.id"
                class="hover:bg-slate-50/60 transition-colors"
              >
                <!-- Nomor & Kegiatan -->
                <td class="px-5 py-4 max-w-xs">
                  <p class="font-bold text-brand-navy text-sm">{{ item.competition_name }}</p>
                  <p class="font-mono text-[11px] text-slate-400 mt-0.5">{{ item.reference_number || 'Belum terbit nomor' }}</p>
                  <p class="text-[11px] text-slate-500 truncate mt-1 italic">"{{ item.purpose }}"</p>
                </td>

                <!-- Siswa Terlibat -->
                <td class="px-5 py-4">
                  <div class="space-y-1">
                    <div
                      v-for="s in (item.students || []).slice(0, 3)"
                      :key="s.id"
                      class="flex items-center gap-1.5 text-slate-800 font-medium"
                    >
                      <i class="fa-solid fa-user-graduate text-[10px] text-brand-navy"></i>
                      <span>{{ s.full_name }}</span>
                      <span class="text-[10px] text-slate-400">({{ s.class_name }})</span>
                    </div>
                    <p v-if="(item.students || []).length > 3" class="text-[10px] text-blue-600 font-bold">
                      +{{ item.students.length - 3 }} siswa lainnya
                    </p>
                  </div>
                </td>

                <!-- Periode & Waktu -->
                <td class="px-5 py-4 whitespace-nowrap">
                  <p class="font-bold text-slate-700">{{ item.start_date }} s.d. {{ item.end_date }}</p>
                  <p class="text-[11px] text-slate-500 mt-0.5">
                    {{ item.is_all_day ? 'Seharian Penuh' : `${item.start_time || '-'} - ${item.end_time || '-'}` }}
                  </p>
                </td>

                <!-- Jenis & Pembimbing -->
                <td class="px-5 py-4">
                  <span class="inline-block px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wider bg-blue-50 text-blue-800 border border-blue-200">
                    {{ item.dispensation_type === 'persiapan_latihan' ? 'Persiapan / Latihan' : 'Hari Lomba' }}
                  </span>
                  <p v-if="item.supervisor_name" class="text-[11px] text-slate-600 mt-1">
                    <i class="fa-solid fa-chalkboard-user mr-1 text-slate-400"></i>
                    {{ item.supervisor_name }}
                  </p>
                </td>

                <!-- Status -->
                <td class="px-5 py-4 whitespace-nowrap">
                  <span
                    v-if="item.status === 'approved'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300"
                  >
                    <i class="fa-solid fa-check"></i>
                    Disetujui
                  </span>
                  <span
                    v-else-if="item.status === 'rejected'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-red-100 text-red-800 border border-red-300"
                  >
                    <i class="fa-solid fa-xmark"></i>
                    Ditolak
                  </span>
                  <span
                    v-else
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-800 border border-amber-300"
                  >
                    <i class="fa-solid fa-clock"></i>
                    Pending Review
                  </span>
                </td>

                <!-- Aksi -->
                <td class="px-5 py-4 text-right whitespace-nowrap">
                  <div class="inline-flex items-center gap-1.5">
                    <button
                      v-if="item.status === 'pending'"
                      @click="openReviewModal(item)"
                      class="px-3 py-1.5 rounded-lg bg-brand-navy text-white text-xs font-bold hover:bg-blue-900 shadow-xs cursor-pointer"
                    >
                      Review
                    </button>

                    <button
                      v-if="item.status === 'approved'"
                      @click="openPrintPreview(item.id)"
                      class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200 text-xs font-bold cursor-pointer"
                      title="Cetak Surat Dispensasi Resmi"
                    >
                      <i class="fa-solid fa-print"></i>
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
    <Modal v-model="showReviewModal" title="Tinjau Permohonan Dispensasi KBM" @close="showReviewModal = false">
      <div v-if="selectedDisp" class="space-y-4">
        <div class="p-3 bg-slate-50 border border-slate-200 rounded-xl space-y-2 text-xs">
          <div>
            <span class="text-slate-400 block text-[10px] uppercase font-bold">Kegiatan Lomba</span>
            <span class="font-bold text-slate-800 text-sm">{{ selectedDisp.competition_name }}</span>
          </div>
          <div class="grid grid-cols-2 gap-2">
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold">Periode Dispensasi</span>
              <span class="font-semibold text-slate-700">{{ selectedDisp.start_date }} s.d. {{ selectedDisp.end_date }}</span>
            </div>
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold">Guru Pembimbing</span>
              <span class="font-semibold text-slate-700">{{ selectedDisp.supervisor_name || 'Tidak dicantumkan' }}</span>
            </div>
          </div>
          <div>
            <span class="text-slate-400 block text-[10px] uppercase font-bold">Uraian / Alasan</span>
            <p class="text-slate-700">{{ selectedDisp.purpose }}</p>
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Keputusan Persetujuan *</label>
          <div class="grid grid-cols-2 gap-3">
            <label
              :class="[
                'p-3 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 cursor-pointer transition-all',
                reviewAction === 'approve'
                  ? 'bg-emerald-50 border-emerald-500 text-emerald-800'
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
                  ? 'bg-red-50 border-red-500 text-red-800'
                  : 'border-slate-200 text-slate-600 hover:bg-slate-50'
              ]"
            >
              <input type="radio" v-model="reviewAction" value="reject" class="sr-only" />
              <i class="fa-solid fa-circle-xmark text-red-600"></i>
              <span>Tolak Dispensasi</span>
            </label>
          </div>
        </div>

        <div v-if="reviewAction === 'approve'">
          <label class="block text-xs font-bold text-slate-700 mb-1">Nomor Surat Dispensasi Resmi (Opsional)</label>
          <input
            v-model="referenceNumberInput"
            type="text"
            placeholder="Kosongkan untuk nomor surat otomatis sistem"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          />
          <p class="text-[10px] text-slate-400 mt-1">Sistem akan mengenerate format resmi sekolah jika dikosongkan.</p>
        </div>

        <div v-if="reviewAction === 'reject'">
          <label class="block text-xs font-bold text-slate-700 mb-1">Alasan Penolakan *</label>
          <textarea
            v-model="rejectionReasonInput"
            rows="2"
            required
            placeholder="Jelaskan alasan dispensasi tidak dapat diberikan..."
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-red-500 focus:border-red-500"
          ></textarea>
        </div>

        <div class="pt-4 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showReviewModal = false"
            class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100"
          >
            Batal
          </button>
          <button
            type="button"
            @click="submitReview"
            :disabled="reviewing"
            class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-navy text-white hover:bg-blue-900 disabled:opacity-50 transition-all flex items-center gap-2"
          >
            <i v-if="reviewing" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ reviewing ? 'Memproses...' : 'Simpan Keputusan' }}</span>
          </button>
        </div>
      </div>
    </Modal>

    <!-- Create Direct Dispensation Modal -->
    <Modal v-model="showCreateModal" title="Terbitkan Surat Dispensasi KBM Langsung" @close="showCreateModal = false">
      <form @submit.prevent="handleCreateDirect" class="space-y-4">
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Nama Lomba / Kegiatan *</label>
          <input
            v-model="createForm.competition_name"
            type="text"
            required
            placeholder="Contoh: Lomba Debat Bahasa Inggris Tingkat Provinsi 2026"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          />
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Jenis Dispensasi *</label>
            <select
              v-model="createForm.dispensation_type"
              required
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            >
              <option value="persiapan_latihan">Persiapan & Latihan Intensif</option>
              <option value="pelaksanaan_lomba">Hari-H Pelaksanaan Lomba</option>
              <option value="lainnya">Kegiatan Lainnya</option>
            </select>
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Guru Pendamping / Pembimbing</label>
            <input
              v-model="createForm.supervisor_name"
              type="text"
              placeholder="Contoh: Dra. Sri Wahyuni, M.Pd."
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            />
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Pilih Siswa yang Diberi Dispensasi *</label>
          <div class="space-y-2">
            <select
              multiple
              v-model="createForm.student_ids"
              required
              class="w-full h-28 text-xs rounded-xl border border-slate-300 p-2 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            >
              <option v-for="s in students" :key="s.id" :value="s.id">
                {{ s.full_name }} ({{ s.class_name }} - NIS: {{ s.nis }})
              </option>
            </select>
            <p class="text-[10px] text-slate-400">Tekan tombol Ctrl (Windows) atau Cmd (Mac) untuk memilih beberapa siswa sekaligus.</p>
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Alasan / Uraian Dispensasi *</label>
          <textarea
            v-model="createForm.purpose"
            rows="2"
            required
            placeholder="Contoh: Mengikuti sesi gladi bersih dan perlombaan tingkat provinsi."
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Mulai *</label>
            <input
              v-model="createForm.start_date"
              type="date"
              required
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            />
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Selesai *</label>
            <input
              v-model="createForm.end_date"
              type="date"
              required
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            />
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Nomor Surat Resmi (Opsional)</label>
          <input
            v-model="createForm.reference_number"
            type="text"
            placeholder="Contoh: 421.3/DISP/2026/045"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          />
        </div>

        <div class="pt-4 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showCreateModal = false"
            class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="creating"
            class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-navy text-white hover:bg-blue-900 disabled:opacity-50 transition-all flex items-center gap-2"
          >
            <i v-if="creating" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ creating ? 'Menerbitkan...' : 'Terbitkan Surat Dispensasi' }}</span>
          </button>
        </div>
      </form>
    </Modal>

    <!-- Official Printable Dispensation Letter Preview Modal -->
    <Modal v-model="showPrintModal" title="Cetak Surat Dispensasi Resmi Sekolah" @close="showPrintModal = false">
      <div v-if="printData" class="space-y-6">
        <!-- Printable Paper Container -->
        <div id="printable-dispensation-letter" class="bg-white p-6 sm:p-8 rounded-xl border-2 border-slate-300 shadow-sm text-black font-serif space-y-4">
          <!-- Kop Surat Sekolah -->
          <div class="text-center border-b-2 border-black pb-3 space-y-1">
            <h2 class="text-lg font-black uppercase tracking-wider">{{ printData.school?.name || 'SEKOLAH MENENGAH ATAS' }}</h2>
            <p class="text-[11px] font-sans text-slate-700">
              {{ printData.school?.address || 'Jalan Pendidikan No. 1' }} • NPSN: {{ printData.school?.npsn || '-' }}
            </p>
            <p class="text-[11px] font-sans text-slate-700">
              Telp: {{ printData.school?.phone || '-' }} • Email: {{ printData.school?.email || '-' }}
            </p>
          </div>

          <!-- Judul Surat -->
          <div class="text-center pt-2">
            <h3 class="text-sm font-bold uppercase underline">SURAT KETERANGAN DISPENSASI BELAJAR (KBM)</h3>
            <p class="text-xs font-sans font-semibold mt-0.5">Nomor: {{ printData.dispensation?.reference_number }}</p>
          </div>

          <!-- Isi Surat -->
          <div class="text-xs font-sans text-slate-800 leading-relaxed space-y-3">
            <p>
              Yang bertanda tangan di bawah ini, Kepala Sekolah / Bagian Kesiswaan menerangkan bahwa siswa-siswi tersebut di bawah ini:
            </p>

            <table class="w-full text-xs border border-slate-400 border-collapse">
              <thead class="bg-slate-100 font-bold">
                <tr>
                  <th class="border border-slate-400 px-2 py-1 text-center w-8">No</th>
                  <th class="border border-slate-400 px-2 py-1">Nama Siswa</th>
                  <th class="border border-slate-400 px-2 py-1">NIS</th>
                  <th class="border border-slate-400 px-2 py-1">Kelas</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(std, idx) in printData.students" :key="std.id">
                  <td class="border border-slate-400 px-2 py-1 text-center">{{ Number(idx) + 1 }}</td>
                  <td class="border border-slate-400 px-2 py-1 font-semibold">{{ std.full_name }}</td>
                  <td class="border border-slate-400 px-2 py-1">{{ std.nis || '-' }}</td>
                  <td class="border border-slate-400 px-2 py-1">{{ std.class_name || '-' }}</td>
                </tr>
              </tbody>
            </table>

            <p>
              Diberikan izin dispensasi untuk tidak mengikuti Kegiatan Belajar Mengajar (KBM) di kelas sehubungan dengan:
            </p>

            <div class="bg-slate-50 p-3 rounded-lg border border-slate-200 text-xs space-y-1">
              <p><span class="font-bold">Kegiatan:</span> {{ printData.dispensation?.competition_name }}</p>
              <p><span class="font-bold">Keperluan:</span> {{ printData.dispensation?.purpose }}</p>
              <p><span class="font-bold">Waktu Pelaksanaan:</span> {{ printData.dispensation?.start_date }} s.d. {{ printData.dispensation?.end_date }}</p>
              <p v-if="printData.dispensation?.supervisor_name"><span class="font-bold">Guru Pembimbing:</span> {{ printData.dispensation?.supervisor_name }}</p>
            </div>

            <p>
              Demikian surat dispensasi ini dibuat agar Bapak/Ibu Guru Mata Pelajaran dan Guru Piket dapat memakluminya. Siswa tetap berkewajiban menyelesaikan tugas-tugas KBM yang tertinggal.
            </p>
          </div>

          <!-- Tanda Tangan & QR Verifikasi -->
          <div class="pt-4 flex items-end justify-between text-xs font-sans">
            <!-- QR Code Box -->
            <div class="text-center p-2 border border-slate-300 rounded-lg">
              <img
                v-if="printData.qr_code_data_uri"
                :src="printData.qr_code_data_uri"
                alt="QR Verifikasi Guru"
                class="w-24 h-24 mx-auto"
              />
              <p class="text-[9px] text-slate-500 font-mono mt-1">Scan QR untuk Verifikasi Guru</p>
            </div>

            <!-- Signature Box -->
            <div class="text-center space-y-12">
              <p>Diterbitkan pada: {{ printData.printed_at }}<br /><span class="font-bold">Kepala Sekolah / Bidang Kesiswaan</span></p>
              <p class="font-bold underline">{{ printData.dispensation?.approved_by?.name || 'Admin Sekolah' }}</p>
            </div>
          </div>
        </div>

        <div class="flex justify-end gap-2 pt-2">
          <button
            type="button"
            @click="showPrintModal = false"
            class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100"
          >
            Tutup
          </button>
          <button
            type="button"
            @click="handlePrintAction"
            class="px-5 py-2 rounded-xl text-xs font-bold bg-emerald-600 text-white hover:bg-emerald-700 flex items-center gap-2 shadow-xs cursor-pointer"
          >
            <i class="fa-solid fa-print"></i>
            <span>Cetak / Simpan PDF</span>
          </button>
        </div>
      </div>
    </Modal>
  </DashboardLayout>
</template>
