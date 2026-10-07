<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'
import { formatDateRange } from '@/utils/date'

const { toast } = useNotify()

const dispensations = ref<any[]>([])
const loading = ref(true)

// QR / Digital Pass Modal
const showQrModal = ref(false)
const selectedDisp = ref<any>(null)

async function fetchDispensations() {
  loading.value = true
  try {
    const dispRes = await api.get('/student/dispensations')
    dispensations.value = extractList(dispRes.data.data)
  } catch (err) {
    console.error('Error fetching student dispensations:', err)
  } finally {
    loading.value = false
  }
}

async function openQrModal(dispId: number) {
  try {
    const res = await api.get(`/student/dispensations/${dispId}`)
    selectedDisp.value = res.data.data
    showQrModal.value = true
  } catch (err) {
    toast.error('Gagal memuat detail surat dispensasi.', 'Gagal')
  }
}

const downloadingDocxId = ref<number | null>(null)
const downloadingPdfId = ref<number | null>(null)

async function downloadDocx(dispId: number, refNumber?: string) {
  downloadingDocxId.value = dispId
  try {
    const res = await api.get(`/student/dispensations/${dispId}/download-docx`, {
      responseType: 'blob',
    })
    const blob = new Blob([res.data], {
      type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const safeName = (refNumber || 'KBM').replace(/[^a-zA-Z0-9_-]/g, '_')
    a.download = `Surat_Perizinan_Dispensasi_${safeName}.docx`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Berkas Word (.docx) berhasil diunduh.', 'Unduh Berhasil')
  } catch (err: any) {
    toast.error('Gagal mengunduh file DOCX.', 'Gagal')
  } finally {
    downloadingDocxId.value = null
  }
}

async function downloadPdf(dispId: number, refNumber?: string) {
  downloadingPdfId.value = dispId
  try {
    const res = await api.get(`/student/dispensations/${dispId}/download-pdf`, {
      responseType: 'blob',
    })
    const blob = new Blob([res.data], {
      type: 'application/pdf',
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const safeName = (refNumber || 'KBM').replace(/[^a-zA-Z0-9_-]/g, '_')
    a.download = `Surat_Perizinan_Dispensasi_${safeName}.pdf`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Surat perizinan & dispensasi PDF berhasil diunduh. Silakan cetak untuk ditunjukkan ke guru mengajar di kelas.', 'Unduh Berhasil')
  } catch (err: any) {
    toast.error('Gagal mengunduh file PDF.', 'Gagal')
  } finally {
    downloadingPdfId.value = null
  }
}

onMounted(() => {
  fetchDispensations()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Form Perizinan & Dispensasi KBM</template>

    <div class="space-y-6 max-w-5xl mx-auto">
      <!-- Humanized Student Guidance Banner -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200/90 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-1.5 max-w-xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-blue-50 text-brand-navy text-xs font-semibold">
            <i class="fa-solid fa-graduation-cap text-brand-blue"></i>
            Formulir Terpadu Perizinan Siswa
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Perizinan Lomba & Dispensasi Belajar (KBM)
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Cukup isi 1 formulir untuk mengajukan izin mengikuti lomba sekaligus pengajuan dispensasi KBM. Setelah disetujui pihak sekolah/kesiswaan, surat resmi dapat dicetak untuk ditunjukkan kepada guru mata pelajaran di kelas.
          </p>
        </div>

        <router-link
          to="/student/dispensations/create"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-[#00164a] transition-all cursor-pointer shrink-0"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Isi Form Perizinan Baru</span>
        </router-link>
      </div>

      <!-- Quick Informative Tip Card -->
      <div class="bg-amber-50/70 border border-amber-200/80 rounded-xl p-4 flex items-start gap-3 text-xs text-amber-900">
        <i class="fa-solid fa-circle-info text-amber-600 text-sm mt-0.5 shrink-0"></i>
        <div class="space-y-1 leading-relaxed">
          <p class="font-bold">Alur Pengajuan & Pengesahan Surat:</p>
          <p class="text-amber-800/90">
            1. Siswa mengisi formulir perizinan pada halaman baru.<br>
            2. Menunggu validasi & persetujuan dari Guru Pembina / Waka Kesiswaan.<br>
            3. Setelah disetujui, klik <strong>Cetak Surat (PDF/DOCX)</strong> untuk diprint dan ditunjukkan ke Guru Mata Pelajaran / Wali Kelas saat KBM di kelas.
          </p>
        </div>
      </div>

      <!-- Dispensations History Container -->
      <div class="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 class="text-sm font-bold text-slate-800">Riwayat Pengajuan Perizinan & Dispensasi</h3>
            <p class="text-xs text-slate-500">Status validasi dan tombol cetak surat resmi</p>
          </div>
          <span class="text-xs font-semibold text-slate-500 font-mono">{{ dispensations.length }} pengajuan</span>
        </div>

        <div v-if="loading" class="py-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2">Memeriksa data pengajuan...</p>
        </div>

        <div v-else-if="dispensations.length === 0" class="py-16 text-center">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
            <i class="fa-solid fa-file-circle-check"></i>
          </div>
          <h4 class="text-sm font-bold text-slate-800">Belum Ada Pengajuan Perizinan</h4>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1 mb-4">
            Jika kamu hendak mengikuti perlombaan atau butuh dispensasi kelas, silakan klik tombol di bawah untuk mengisi formulir perizinan baru.
          </p>
          <router-link
            to="/student/dispensations/create"
            class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-brand-navy text-white text-xs font-bold hover:bg-[#00164a] transition-all shadow-xs"
          >
            <i class="fa-solid fa-plus text-brand-gold"></i>
            <span>Isi Form Perizinan Baru</span>
          </router-link>
        </div>

        <div v-else class="divide-y divide-slate-100">
          <div
            v-for="item in dispensations"
            :key="item.id"
            class="p-5 hover:bg-slate-50/70 transition-colors flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
          >
            <div class="space-y-2 flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <!-- Status Badge -->
                <span
                  v-if="item.status === 'approved'"
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-md text-xs font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200"
                >
                  <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                  Disetujui Sekolah (Siap Cetak)
                </span>
                <span
                  v-else-if="item.status === 'rejected'"
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-md text-xs font-semibold bg-rose-50 text-rose-800 border border-rose-200"
                >
                  <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                  Ditolak
                </span>
                <span
                  v-else
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-md text-xs font-semibold bg-amber-50 text-amber-800 border border-amber-200"
                >
                  <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
                  Menunggu Validasi Sekolah
                </span>

                <span v-if="item.competition_level" class="text-[11px] font-bold uppercase px-2 py-0.5 rounded bg-slate-100 text-slate-700 border border-slate-200">
                  Tingkat {{ item.competition_level }}
                </span>

                <span v-if="item.reference_number" class="text-xs font-mono text-slate-500">
                  No: {{ item.reference_number }}
                </span>
              </div>

              <div>
                <h4 class="text-sm font-bold text-slate-900">{{ item.competition_name }}</h4>
                <p class="text-xs text-slate-600 mt-0.5">
                  <span class="font-semibold text-slate-700">Keperluan / Agenda:</span> {{ item.purpose }}
                </p>
              </div>

              <div class="flex items-center gap-4 text-xs text-slate-500 flex-wrap pt-0.5">
                <span>
                  <i class="fa-regular fa-calendar mr-1 text-slate-400"></i>
                  {{ formatDateRange(item.start_date, item.end_date) }}
                </span>
                <span>
                  <i class="fa-regular fa-clock mr-1 text-slate-400"></i>
                  {{ item.is_all_day ? 'Seharian Penuh' : `${item.start_time} - ${item.end_time}` }}
                </span>
                <span v-if="item.supervisor_name">
                  <i class="fa-solid fa-chalkboard-user mr-1 text-slate-400"></i>
                  Pembina: {{ item.supervisor_name }}
                </span>
                <span v-if="item.homeroom_teacher">
                  <i class="fa-solid fa-user-tie mr-1 text-slate-400"></i>
                  Wali Kelas: {{ item.homeroom_teacher }}
                </span>
              </div>

              <div v-if="item.status === 'rejected' && item.rejection_reason" class="p-2.5 bg-rose-50 border border-rose-200 rounded-lg text-xs text-rose-800">
                <span class="font-bold">Alasan Penolakan:</span> {{ item.rejection_reason }}
              </div>
            </div>

            <!-- Action Buttons for Approved Dispensation -->
            <div class="shrink-0 w-full sm:w-auto flex flex-wrap items-center justify-end gap-2">
              <template v-if="item.status === 'approved'">
                <!-- Pass QR Button -->
                <button
                  type="button"
                  @click="openQrModal(item.id)"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold transition-all shadow-xs cursor-pointer"
                  title="Buka Pass Izin Digital"
                >
                  <i class="fa-solid fa-qrcode"></i>
                  <span>Pass Digital</span>
                </button>

                <!-- Unduh PDF Button (Recommended for printing) -->
                <button
                  type="button"
                  @click="downloadPdf(item.id, item.reference_number)"
                  :disabled="downloadingPdfId === item.id"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-rose-700 hover:bg-rose-800 text-white text-xs font-bold transition-all shadow-xs cursor-pointer disabled:opacity-60"
                  title="Unduh & Cetak Surat PDF"
                >
                  <i v-if="downloadingPdfId === item.id" class="fa-solid fa-spinner fa-spin"></i>
                  <i v-else class="fa-solid fa-print"></i>
                  <span>Cetak Surat PDF</span>
                </button>

                <!-- Unduh DOCX Button -->
                <button
                  type="button"
                  @click="downloadDocx(item.id, item.reference_number)"
                  :disabled="downloadingDocxId === item.id"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-700 hover:bg-blue-800 text-white text-xs font-bold transition-all shadow-xs cursor-pointer disabled:opacity-60"
                  title="Unduh Berkas Word .docx"
                >
                  <i v-if="downloadingDocxId === item.id" class="fa-solid fa-spinner fa-spin"></i>
                  <i v-else class="fa-solid fa-file-word"></i>
                  <span>DOCX</span>
                </button>
              </template>
              <span v-else class="text-xs text-slate-400 italic">
                Surat dapat dicetak setelah disetujui
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Authentic Digital School Pass Modal -->
    <Modal v-model="showQrModal" title="Pass Izin Digital Siswa" @close="showQrModal = false">
      <div v-if="selectedDisp" class="space-y-4 text-slate-800">
        <!-- Digital Pass Card -->
        <div class="bg-white rounded-2xl border-2 border-slate-300 shadow-md overflow-hidden max-w-sm mx-auto">
          <!-- Top Card Header (Navy) -->
          <div class="bg-brand-navy text-white p-4 text-center space-y-1">
            <p class="text-[10px] uppercase font-bold tracking-widest text-brand-gold">
              SURAT DISPENSASI BELAJAR (KBM)
            </p>
            <h4 class="text-sm font-black tracking-tight leading-tight">
              {{ selectedDisp.school?.name }}
            </h4>
            <p class="text-[11px] font-mono text-blue-200/80">
              {{ selectedDisp.reference_number }}
            </p>
          </div>

          <!-- Card Content Body -->
          <div class="p-5 text-center space-y-4">
            <!-- Active Status Badge -->
            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300">
              <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
              SAH & TERVERIFIKASI SEKOLAH
            </div>

            <!-- Scannable QR Code -->
            <div class="p-3 bg-slate-50 border border-slate-200 rounded-xl inline-block shadow-2xs">
              <img
                v-if="selectedDisp.qr_code_data_uri"
                :src="selectedDisp.qr_code_data_uri"
                alt="QR Verifikasi Guru"
                class="w-40 h-40 mx-auto"
              />
              <p class="text-[9px] text-slate-400 font-mono mt-1">Pindai kamera guru untuk cek keabsahan</p>
            </div>

            <!-- Details Block -->
            <div class="text-xs text-left bg-slate-50 p-3.5 rounded-xl border border-slate-200 space-y-2">
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Kegiatan Lomba</span>
                <span class="font-bold text-brand-navy">{{ selectedDisp.competition_name }}</span>
              </div>
              <div class="grid grid-cols-2 gap-2">
                <div>
                  <span class="text-slate-400 block text-[10px] uppercase font-bold">Periode Izin</span>
                  <span class="font-semibold text-slate-700">{{ formatDateRange(selectedDisp.start_date, selectedDisp.end_date) }}</span>
                </div>
                <div>
                  <span class="text-slate-400 block text-[10px] uppercase font-bold">Waktu</span>
                  <span class="font-semibold text-slate-700">{{ selectedDisp.is_all_day ? 'Seharian Penuh' : `${selectedDisp.start_time} - ${selectedDisp.end_time}` }}</span>
                </div>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Pengesahan Kesiswaan</span>
                <span class="font-semibold text-emerald-800">{{ selectedDisp.approved_by?.name || 'Waka Kesiswaan' }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="pt-3 flex flex-wrap items-center justify-center gap-2 border-t border-slate-100">
          <button
            type="button"
            @click="downloadPdf(selectedDisp.id, selectedDisp.reference_number)"
            :disabled="downloadingPdfId === selectedDisp.id"
            class="px-4 py-2 rounded-xl text-xs font-bold bg-rose-700 hover:bg-rose-800 text-white flex items-center gap-1.5 shadow-xs cursor-pointer disabled:opacity-60"
          >
            <i v-if="downloadingPdfId === selectedDisp.id" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-print"></i>
            <span>Cetak Surat PDF</span>
          </button>

          <button
            type="button"
            @click="downloadDocx(selectedDisp.id, selectedDisp.reference_number)"
            :disabled="downloadingDocxId === selectedDisp.id"
            class="px-4 py-2 rounded-xl text-xs font-bold bg-blue-700 hover:bg-blue-800 text-white flex items-center gap-1.5 shadow-xs cursor-pointer disabled:opacity-60"
          >
            <i v-if="downloadingDocxId === selectedDisp.id" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-file-word"></i>
            <span>Unduh DOCX</span>
          </button>

          <button
            type="button"
            @click="showQrModal = false"
            class="px-4 py-2 rounded-xl text-xs font-bold bg-slate-200 hover:bg-slate-300 text-slate-700 cursor-pointer"
          >
            Tutup
          </button>
        </div>
      </div>
    </Modal>
  </DashboardLayout>
</template>
