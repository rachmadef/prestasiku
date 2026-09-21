<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
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
    <template #header-title>Buku Rekam Jejak Lomba</template>

    <div class="space-y-6 max-w-6xl mx-auto">
      <!-- Humanized Student Portfolio Banner -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200/90 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-1.5 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-amber-50 text-amber-900 text-xs font-semibold">
            <i class="fa-solid fa-award text-amber-600"></i>
            Portofolio Rekam Jejak Pelajar
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Arsip Keikutsertaan & Prestasi Lomba
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Setiap ikhtiar, sesi latihan, dan keberanianmu berlomba adalah bagian dari proses belajarmu. Baik meraih juara maupun berstatus sebagai peserta/finalis, seluruh riwayat keikutsertaan dan sertifikatmu diarsipkan di sini sebagai portofolio resmi.
          </p>
        </div>

        <router-link
          to="/student/dispensations"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-[#00164a] transition-all cursor-pointer shrink-0"
        >
          <i class="fa-solid fa-file-signature text-brand-gold"></i>
          <span>Izin Dispensasi Latihan</span>
        </router-link>
      </div>

      <!-- Humanized Clean Metric Bar (Summary of Records) -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <p class="text-[11px] font-semibold text-slate-500">Total Lomba Diikuti</p>
          <div class="mt-1 flex items-baseline gap-2">
            <span class="text-2xl font-black text-brand-navy font-mono">{{ portfolioData?.stats?.total_participations ?? 0 }}</span>
            <span class="text-[11px] text-slate-400">kali bertanding</span>
          </div>
        </div>

        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <p class="text-[11px] font-semibold text-slate-500">Pencapaian Juara</p>
          <div class="mt-1 flex items-baseline gap-2">
            <span class="text-2xl font-black text-amber-600 font-mono">{{ portfolioData?.stats?.total_wins ?? 0 }}</span>
            <span class="text-[11px] text-amber-700/80">medali / piala</span>
          </div>
        </div>

        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <p class="text-[11px] font-semibold text-slate-500">Peserta & Pengalaman</p>
          <div class="mt-1 flex items-baseline gap-2">
            <span class="text-2xl font-black text-emerald-700 font-mono">{{ portfolioData?.stats?.total_participants ?? 0 }}</span>
            <span class="text-[11px] text-emerald-800/80">terdokumentasi</span>
          </div>
        </div>

        <div class="bg-white rounded-xl p-4 border border-slate-200/80 shadow-xs">
          <p class="text-[11px] font-semibold text-slate-500">Finalis & Harapan</p>
          <div class="mt-1 flex items-baseline gap-2">
            <span class="text-2xl font-black text-purple-700 font-mono">{{ portfolioData?.stats?.total_finalists ?? 0 }}</span>
            <span class="text-[11px] text-purple-800/80">babak akhir</span>
          </div>
        </div>
      </div>

      <!-- Filter Tabs (Simple, Clean, Human-Friendly) -->
      <div class="flex items-center gap-1.5 overflow-x-auto pb-1 border-b border-slate-200">
        <button
          type="button"
          @click="activeTab = 'all'"
          :class="[
            'px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
            activeTab === 'all'
              ? 'bg-brand-navy text-white shadow-xs'
              : 'text-slate-600 hover:bg-slate-200/60'
          ]"
        >
          Semua Catatan ({{ portfolioData?.stats?.total_participations ?? 0 }})
        </button>

        <button
          type="button"
          @click="activeTab = 'winner'"
          :class="[
            'px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap flex items-center gap-1.5',
            activeTab === 'winner'
              ? 'bg-amber-600 text-white shadow-xs'
              : 'text-slate-600 hover:bg-slate-200/60'
          ]"
        >
          <i class="fa-solid fa-trophy text-[10px]"></i>
          <span>Juara / Menang ({{ portfolioData?.stats?.total_wins ?? 0 }})</span>
        </button>

        <button
          type="button"
          @click="activeTab = 'participant'"
          :class="[
            'px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap flex items-center gap-1.5',
            activeTab === 'participant'
              ? 'bg-emerald-700 text-white shadow-xs'
              : 'text-slate-600 hover:bg-slate-200/60'
          ]"
        >
          <i class="fa-solid fa-id-badge text-[10px]"></i>
          <span>Peserta Terdata ({{ portfolioData?.stats?.total_participants ?? 0 }})</span>
        </button>

        <button
          type="button"
          @click="activeTab = 'finalist'"
          :class="[
            'px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap flex items-center gap-1.5',
            activeTab === 'finalist'
              ? 'bg-purple-700 text-white shadow-xs'
              : 'text-slate-600 hover:bg-slate-200/60'
          ]"
        >
          <i class="fa-solid fa-star text-[10px]"></i>
          <span>Finalis ({{ portfolioData?.stats?.total_finalists ?? 0 }})</span>
        </button>

        <button
          type="button"
          @click="activeTab = 'pending'"
          :class="[
            'px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap flex items-center gap-1.5',
            activeTab === 'pending'
              ? 'bg-slate-700 text-white shadow-xs'
              : 'text-slate-600 hover:bg-slate-200/60'
          ]"
        >
          <i class="fa-regular fa-clock text-[10px]"></i>
          <span>Menunggu Hasil ({{ portfolioData?.stats?.pending_results ?? 0 }})</span>
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="py-16 text-center">
        <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
        <p class="text-xs text-slate-500 mt-2 font-medium">Membuka lembar portofolio...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredRecords.length === 0" class="bg-white rounded-xl p-12 text-center border border-slate-200/80 shadow-xs">
        <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
          <i class="fa-regular fa-folder-open"></i>
        </div>
        <h4 class="text-sm font-bold text-slate-800">Belum Ada Rekam Jejak pada Kategori Ini</h4>
        <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
          Seluruh lomba yang kamu ikuti akan tercatat otomatis di halaman ini setelah proses pendaftaran atau seleksi sekolah.
        </p>
      </div>

      <!-- Portfolio Ledger Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div
          v-for="record in filteredRecords"
          :key="record.id"
          class="bg-white rounded-xl p-5 border border-slate-200/80 shadow-xs hover:border-slate-300 transition-all flex flex-col justify-between"
        >
          <div class="space-y-3">
            <!-- Header Tag & Level -->
            <div class="flex items-center justify-between gap-2">
              <span
                v-if="record.result_status === 'winner'"
                class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded text-[11px] font-bold bg-amber-50 text-amber-800 border border-amber-300"
              >
                <i class="fa-solid fa-trophy text-amber-600"></i>
                {{ record.rank_details || 'Juara' }}
              </span>
              <span
                v-else-if="record.result_status === 'participant'"
                class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded text-[11px] font-semibold bg-emerald-50 text-emerald-800 border border-emerald-300"
              >
                <i class="fa-solid fa-id-badge text-emerald-600"></i>
                {{ record.rank_details || 'Peserta Terdaftar' }}
              </span>
              <span
                v-else-if="record.result_status === 'finalist'"
                class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded text-[11px] font-semibold bg-purple-50 text-purple-800 border border-purple-300"
              >
                <i class="fa-solid fa-star text-purple-600"></i>
                Finalis
              </span>
              <span
                v-else
                class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded text-[11px] font-medium bg-slate-100 text-slate-600 border border-slate-200"
              >
                <i class="fa-regular fa-clock"></i>
                Menunggu Pengumuman
              </span>

              <span class="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded bg-slate-100 text-slate-600">
                Tingkat {{ record.competition?.level ?? 'Nasional' }}
              </span>
            </div>

            <!-- Competition Title -->
            <div>
              <h4 class="text-sm font-bold text-slate-900 leading-snug">
                {{ record.competition?.title ?? 'Lomba' }}
              </h4>
              <p class="text-xs text-slate-500 mt-1">
                <i class="fa-solid fa-building-columns mr-1 text-slate-400"></i>
                {{ record.competition?.organizer?.name ?? 'Penyelenggara Resmi' }}
              </p>
            </div>

            <!-- Metadata Box -->
            <div class="bg-slate-50 rounded-lg p-3 text-xs text-slate-600 space-y-1.5 border border-slate-100 font-sans">
              <div class="flex justify-between items-center">
                <span class="text-slate-400">Nomor Registrasi:</span>
                <span class="font-mono font-semibold text-slate-700">{{ record.registration_code }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-slate-400">Kategori Peserta:</span>
                <span class="font-medium text-slate-700">
                  {{ record.registration_type === 'team' ? `Tim (${record.team?.team_name ?? 'Kelompok'})` : 'Individu / Perorangan' }}
                </span>
              </div>
              <div v-if="record.result_notes" class="pt-1.5 border-t border-slate-200 text-[11px] text-slate-600 italic">
                "{{ record.result_notes }}"
              </div>
            </div>
          </div>

          <!-- Bottom Card Action Controls -->
          <div class="pt-3 mt-3 border-t border-slate-100 flex items-center justify-between gap-2">
            <button
              type="button"
              @click="openUploadModal(record)"
              class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-navy hover:text-blue-700 transition-colors cursor-pointer"
            >
              <i class="fa-solid fa-arrow-up-from-bracket text-brand-blue"></i>
              <span>{{ record.certificate_file ? 'Perbarui Berkas' : 'Unggah Sertifikat' }}</span>
            </button>

            <button
              v-if="record.certificate_file"
              type="button"
              @click="downloadCertificate(record.id)"
              class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-800 hover:bg-emerald-100 border border-emerald-200 text-xs font-bold transition-all cursor-pointer"
            >
              <i class="fa-solid fa-file-arrow-down"></i>
              <span>Unduh Sertifikat</span>
            </button>
            <span v-else class="text-[11px] text-slate-400 italic">
              Belum ada berkas sertifikat
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Upload / Update Certificate Modal -->
    <Modal v-model="showUploadModal" title="Pengarsipan Sertifikat Lomba" @close="showUploadModal = false">
      <form @submit.prevent="handleUploadCertificate" class="space-y-4 text-xs">
        <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-slate-700">
          <p class="font-bold text-brand-navy mb-0.5">{{ selectedRecord?.competition?.title }}</p>
          <p class="text-[11px] text-slate-500">Unggah sertifikat kepesertaan atau piagam kejuaraan untuk melengkapi arsip portofolio belajarmu.</p>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Status Keikutsertaan / Hasil *</label>
          <select
            v-model="uploadForm.result_status"
            required
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          >
            <option value="participant">Peserta / Partisipan (Dokumentasi Pengalaman)</option>
            <option value="winner">Juara / Pemenang (Juara 1, 2, 3, Harapan, Emas/Perak/Perunggu)</option>
            <option value="finalist">Finalis / Semifinalis</option>
          </select>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Keterangan Predikat / Peringkat *</label>
          <input
            v-model="uploadForm.rank_details"
            type="text"
            required
            placeholder="Contoh: Peserta Babak Penyisihan, Juara 1 Tingkat Nasional"
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Berkas Sertifikat (PDF / JPG / PNG, maks 5MB) *</label>
          <input
            type="file"
            accept=".pdf,.jpg,.jpeg,.png"
            required
            @change="handleFileChange"
            class="w-full text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-[#00164a] cursor-pointer"
          />
        </div>

        <div class="pt-3 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showUploadModal = false"
            class="px-4 py-2 rounded-lg font-semibold text-slate-600 hover:bg-slate-100 cursor-pointer"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="uploading"
            class="px-5 py-2 rounded-lg font-bold bg-brand-navy text-white hover:bg-[#00164a] disabled:opacity-50 transition-all flex items-center gap-2 cursor-pointer"
          >
            <i v-if="uploading" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ uploading ? 'Menyimpan...' : 'Simpan ke Portofolio' }}</span>
          </button>
        </div>
      </form>
    </Modal>
  </DashboardLayout>
</template>
