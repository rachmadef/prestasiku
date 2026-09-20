<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const loading = ref(true)
const portfolioData = ref<any>(null)
const activeTab = ref<'all' | 'winner' | 'finalist' | 'participant' | 'pending'>('all')

// Upload Certificate Modal
const showUploadModal = ref(false)
const selectedRecord = ref<any>(null)
const uploadForm = ref({
  result_status: 'participant',
  rank_details: '',
  certificate_file: null as File | null,
})
const uploading = ref(false)

async function fetchPortfolio() {
  loading.value = true
  try {
    const res = await api.get('/student/portfolio')
    portfolioData.value = res.data.data
  } catch (err) {
    console.error('Error fetching student portfolio:', err)
  } finally {
    loading.value = false
  }
}

const filteredRecords = computed(() => {
  if (!portfolioData.value?.records) return []
  if (activeTab.value === 'all') return portfolioData.value.records
  return portfolioData.value.records.filter((r: any) => r.result_status === activeTab.value)
})

function openUploadModal(record: any) {
  selectedRecord.value = record
  uploadForm.value = {
    result_status: record.result_status && record.result_status !== 'pending' ? record.result_status : 'participant',
    rank_details: record.rank_details || '',
    certificate_file: null,
  }
  showUploadModal.value = true
}

function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    uploadForm.value.certificate_file = target.files[0]
  }
}

async function handleUploadCertificate() {
  if (!uploadForm.value.certificate_file) {
    toast.error('Silakan pilih berkas sertifikat terlebih dahulu.', 'Pilih Berkas')
    return
  }

  uploading.value = true
  try {
    const formData = new FormData()
    formData.append('certificate_file', uploadForm.value.certificate_file)
    formData.append('result_status', uploadForm.value.result_status)
    formData.append('rank_details', uploadForm.value.rank_details || 'Peserta Terdaftar')

    await api.post(`/student/registrations/${selectedRecord.value.id}/upload-certificate`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Sertifikat keikutsertaan lomba berhasil diunggah dan diarsipkan!', 'Berhasil')
    showUploadModal.value = false
    fetchPortfolio()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengunggah sertifikat.', 'Gagal Unggah')
  } finally {
    uploading.value = false
  }
}

async function downloadCertificate(recordId: number) {
  try {
    const res = await api.get(`/student/registrations/${recordId}/certificate`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(new Blob([res.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `Sertifikat-Lomba-${recordId}.pdf`)
    document.body.appendChild(link)
    link.click()
    link.remove()
    toast.success('Sertifikat berhasil diunduh.', 'Unduh Berhasil')
  } catch (err) {
    toast.error('Gagal mengunduh berkas sertifikat.', 'Unduh Gagal')
  }
}

onMounted(() => {
  fetchPortfolio()
})
</script>

<template>
  <DashboardLayout>
    <div class="space-y-6">
      <!-- Header Banner -->
      <div class="bg-white rounded-2xl p-6 sm:p-8 shadow-xs border border-slate-200/80 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 relative overflow-hidden">
        <div class="absolute -right-10 -bottom-10 w-48 h-48 bg-gradient-to-br from-brand-navy/5 to-brand-gold/10 rounded-full blur-2xl pointer-events-none"></div>
        <div class="space-y-2 z-10 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-gold/15 text-brand-navy text-xs font-bold">
            <i class="fa-solid fa-award text-brand-gold"></i>
            Rekam Jejak & Portofolio Siswa
          </div>
          <h1 class="text-2xl sm:text-3xl font-black text-brand-navy tracking-tight">Arsip Keikutsertaan Lomba</h1>
          <p class="text-sm text-slate-600 leading-relaxed">
            Seluruh rekam jejak lomba yang pernah kamu ikuti didokumentasikan di sini. Menang maupun kalah, setiap perjuangan dan pengalaman berharga tetap diarsipkan sebagai portofolio prestasimu!
          </p>
        </div>
        <div class="flex flex-col sm:flex-row gap-3 w-full md:w-auto z-10">
          <router-link
            to="/student/dispensations"
            class="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-blue-900 transition-all"
          >
            <i class="fa-solid fa-file-signature text-brand-gold"></i>
            Ajukan Izin Dispensasi KBM
          </router-link>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="bg-white rounded-xl p-5 border border-slate-200/80 shadow-xs flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-blue-50 text-brand-navy flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-layer-group"></i>
          </div>
          <div>
            <p class="text-xs font-medium text-slate-500">Total Diikuti</p>
            <p class="text-2xl font-black text-brand-navy">{{ portfolioData?.stats?.total_participations ?? 0 }}</p>
          </div>
        </div>

        <div class="bg-white rounded-xl p-5 border border-slate-200/80 shadow-xs flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-trophy text-amber-500"></i>
          </div>
          <div>
            <p class="text-xs font-medium text-slate-500">Prestasi Juara</p>
            <p class="text-2xl font-black text-amber-600">{{ portfolioData?.stats?.total_wins ?? 0 }}</p>
          </div>
        </div>

        <div class="bg-white rounded-xl p-5 border border-slate-200/80 shadow-xs flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-id-badge"></i>
          </div>
          <div>
            <p class="text-xs font-medium text-slate-500">Peserta / Pengalaman</p>
            <p class="text-2xl font-black text-emerald-600">{{ portfolioData?.stats?.total_participants ?? 0 }}</p>
          </div>
        </div>

        <div class="bg-white rounded-xl p-5 border border-slate-200/80 shadow-xs flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-star"></i>
          </div>
          <div>
            <p class="text-xs font-medium text-slate-500">Finalis & Harapan</p>
            <p class="text-2xl font-black text-purple-600">{{ portfolioData?.stats?.total_finalists ?? 0 }}</p>
          </div>
        </div>
      </div>

      <!-- Filter Tabs -->
      <div class="flex items-center gap-2 overflow-x-auto pb-1 border-b border-slate-200">
        <button
          @click="activeTab = 'all'"
          :class="[
            'px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center gap-2',
            activeTab === 'all'
              ? 'bg-brand-navy text-white shadow-xs'
              : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
          ]"
        >
          <i class="fa-solid fa-list-ul"></i>
          Semua Riwayat ({{ portfolioData?.stats?.total_participations ?? 0 }})
        </button>
        <button
          @click="activeTab = 'winner'"
          :class="[
            'px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center gap-2',
            activeTab === 'winner'
              ? 'bg-amber-600 text-white shadow-xs'
              : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
          ]"
        >
          <i class="fa-solid fa-trophy text-amber-400"></i>
          Juara / Menang ({{ portfolioData?.stats?.total_wins ?? 0 }})
        </button>
        <button
          @click="activeTab = 'participant'"
          :class="[
            'px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center gap-2',
            activeTab === 'participant'
              ? 'bg-emerald-600 text-white shadow-xs'
              : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
          ]"
        >
          <i class="fa-solid fa-id-badge text-emerald-300"></i>
          Peserta & Pengalaman ({{ portfolioData?.stats?.total_participants ?? 0 }})
        </button>
        <button
          @click="activeTab = 'finalist'"
          :class="[
            'px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center gap-2',
            activeTab === 'finalist'
              ? 'bg-purple-600 text-white shadow-xs'
              : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
          ]"
        >
          <i class="fa-solid fa-star text-purple-300"></i>
          Finalis ({{ portfolioData?.stats?.total_finalists ?? 0 }})
        </button>
        <button
          @click="activeTab = 'pending'"
          :class="[
            'px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center gap-2',
            activeTab === 'pending'
              ? 'bg-slate-700 text-white shadow-xs'
              : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
          ]"
        >
          <i class="fa-solid fa-clock text-slate-300"></i>
          Menunggu Hasil ({{ portfolioData?.stats?.pending_results ?? 0 }})
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="py-16 text-center">
        <i class="fa-solid fa-circle-notch fa-spin text-3xl text-brand-navy"></i>
        <p class="text-xs text-slate-500 mt-2">Memuat arsip riwayat lomba...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredRecords.length === 0" class="bg-white rounded-2xl p-12 text-center border border-slate-200/80 shadow-xs">
        <div class="w-16 h-16 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-2xl mb-4">
          <i class="fa-solid fa-folder-open"></i>
        </div>
        <h3 class="text-base font-bold text-slate-800">Belum Ada Data Lomba</h3>
        <p class="text-xs text-slate-500 max-w-md mx-auto mt-1">
          Kamu belum memiliki arsip keikutsertaan lomba pada kategori ini.
        </p>
      </div>

      <!-- Records List -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div
          v-for="record in filteredRecords"
          :key="record.id"
          class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-xs hover:shadow-md transition-all flex flex-col justify-between"
        >
          <div class="space-y-3">
            <div class="flex items-start justify-between gap-3">
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 flex-wrap mb-1">
                  <span
                    v-if="record.result_status === 'winner'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-black bg-amber-100 text-amber-800 border border-amber-300"
                  >
                    <i class="fa-solid fa-trophy text-amber-600"></i>
                    {{ record.rank_details || 'Juara' }}
                  </span>
                  <span
                    v-else-if="record.result_status === 'participant'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-300"
                  >
                    <i class="fa-solid fa-id-badge text-emerald-600"></i>
                    {{ record.rank_details || 'Peserta Terdaftar' }}
                  </span>
                  <span
                    v-else-if="record.result_status === 'finalist'"
                    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-purple-100 text-purple-800 border border-purple-300"
                  >
                    <i class="fa-solid fa-star text-purple-600"></i>
                    Finalis
                  </span>
                  <span
                    v-else
                    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-medium bg-slate-100 text-slate-600 border border-slate-200"
                  >
                    <i class="fa-solid fa-clock"></i>
                    Menunggu Hasil
                  </span>

                  <span class="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-md bg-slate-100 text-slate-600">
                    {{ record.competition?.level ?? 'Nasional' }}
                  </span>
                </div>

                <h3 class="text-base font-bold text-brand-navy leading-snug truncate">
                  {{ record.competition?.title ?? 'Lomba' }}
                </h3>
                <p class="text-xs text-slate-500 truncate mt-0.5">
                  <i class="fa-solid fa-building-columns mr-1 text-slate-400"></i>
                  {{ record.competition?.organizer?.name ?? 'Penyelenggara' }}
                </p>
              </div>
            </div>

            <!-- Meta details -->
            <div class="bg-slate-50 rounded-xl p-3 text-xs text-slate-600 space-y-1.5 border border-slate-100">
              <div class="flex justify-between items-center">
                <span class="text-slate-400">Kode Registrasi:</span>
                <span class="font-mono font-bold text-slate-700">{{ record.registration_code }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-slate-400">Tipe Keikutsertaan:</span>
                <span class="font-medium text-slate-700">
                  {{ record.registration_type === 'team' ? `Tim (${record.team?.team_name ?? 'Kelompok'})` : 'Individu' }}
                </span>
              </div>
              <div v-if="record.result_notes" class="pt-1 border-t border-slate-200/60 text-[11px] text-slate-600 italic">
                "{{ record.result_notes }}"
              </div>
            </div>
          </div>

          <!-- Card Actions -->
          <div class="pt-4 mt-3 border-t border-slate-100 flex items-center justify-between gap-2">
            <button
              @click="openUploadModal(record)"
              class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-navy hover:text-blue-700 transition-colors"
            >
              <i class="fa-solid fa-upload text-brand-gold"></i>
              <span>{{ record.certificate_file ? 'Perbarui Sertifikat' : 'Unggah Sertifikat' }}</span>
            </button>

            <button
              v-if="record.certificate_file"
              @click="downloadCertificate(record.id)"
              class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200 text-xs font-bold transition-all shadow-xs"
            >
              <i class="fa-solid fa-file-arrow-down"></i>
              Unduh Sertifikat
            </button>
            <span v-else class="text-[11px] text-slate-400 italic">
              Belum ada berkas sertifikat
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Upload / Update Certificate Modal -->
    <Modal v-model="showUploadModal" title="Unggah Arsip Sertifikat Lomba" @close="showUploadModal = false">
      <form @submit.prevent="handleUploadCertificate" class="space-y-4">
        <div class="p-3 bg-blue-50/70 border border-blue-200 rounded-xl text-xs text-blue-900 leading-relaxed">
          <p class="font-bold mb-1">
            <i class="fa-solid fa-circle-info mr-1 text-blue-600"></i>
            {{ selectedRecord?.competition?.title }}
          </p>
          Unggah sertifikat kepesertaan maupun piagam kejuaraan untuk mendokumentasikan keikutsertaanmu di sistem.
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Status Keikutsertaan / Hasil *</label>
          <select
            v-model="uploadForm.result_status"
            required
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          >
            <option value="participant">Peserta / Partisipan (Pengalaman Berlomba)</option>
            <option value="winner">Juara / Pemenang (Juara 1, 2, 3, Harapan, Emas/Perak/Perunggu)</option>
            <option value="finalist">Finalis / Semifinalis</option>
          </select>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Keterangan Peringkat / Predikat *</label>
          <input
            v-model="uploadForm.rank_details"
            type="text"
            required
            placeholder="Contoh: Peserta Babak Penyisihan, Juara 2 Tingkat Provinsi"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          />
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Berkas Sertifikat (PDF / JPG / PNG, maks 5MB) *</label>
          <input
            type="file"
            accept=".pdf,.jpg,.jpeg,.png"
            required
            @change="handleFileChange"
            class="w-full text-xs text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-blue-900 cursor-pointer"
          />
        </div>

        <div class="pt-4 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showUploadModal = false"
            class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="uploading"
            class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-navy text-white hover:bg-blue-900 disabled:opacity-50 transition-all flex items-center gap-2"
          >
            <i v-if="uploading" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ uploading ? 'Mengunggah...' : 'Simpan & Arsipkan' }}</span>
          </button>
        </div>
      </form>
    </Modal>
  </DashboardLayout>
</template>
