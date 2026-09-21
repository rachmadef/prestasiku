<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const dispensations = ref<any[]>([])
const loading = ref(true)
const formSchema = ref<any[]>([])
const customFieldsData = ref<Record<string, any>>({})

// Request Modal
const showRequestModal = ref(false)
const requesting = ref(false)
const requestForm = ref({
  competition_name: '',
  dispensation_type: 'persiapan_latihan',
  purpose: '',
  start_date: '',
  end_date: '',
  is_all_day: true,
  start_time: '',
  end_time: '',
  supervisor_name: '',
  notes: '',
  attachment_file: null as File | null,
})

// QR / Digital Pass Modal
const showQrModal = ref(false)
const selectedDisp = ref<any>(null)

async function fetchDispensations() {
  loading.value = true
  try {
    const [dispRes, schemaRes] = await Promise.all([
      api.get('/student/dispensations'),
      api.get('/student/dispensations/form-schema').catch(() => ({ data: { data: { schema: [] } } })),
    ])
    dispensations.value = extractList(dispRes.data.data)
    formSchema.value = schemaRes.data?.data?.schema || []
  } catch (err) {
    console.error('Error fetching student dispensations:', err)
  } finally {
    loading.value = false
  }
}

function handleAttachmentChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    requestForm.value.attachment_file = target.files[0]
  }
}

async function handleRequestDispensation() {
  if (!requestForm.value.competition_name || !requestForm.value.purpose || !requestForm.value.start_date || !requestForm.value.end_date) {
    toast.error('Mohon lengkapi semua bidang yang bertanda bintang.', 'Validasi Form')
    return
  }

  requesting.value = true
  try {
    const formData = new FormData()
    formData.append('competition_name', requestForm.value.competition_name)
    formData.append('dispensation_type', requestForm.value.dispensation_type)
    formData.append('purpose', requestForm.value.purpose)
    formData.append('start_date', requestForm.value.start_date)
    formData.append('end_date', requestForm.value.end_date)
    formData.append('is_all_day', requestForm.value.is_all_day ? '1' : '0')
    if (requestForm.value.start_time) formData.append('start_time', requestForm.value.start_time)
    if (requestForm.value.end_time) formData.append('end_time', requestForm.value.end_time)
    if (requestForm.value.supervisor_name) formData.append('supervisor_name', requestForm.value.supervisor_name)
    if (requestForm.value.notes) formData.append('notes', requestForm.value.notes)
    if (requestForm.value.attachment_file) {
      formData.append('attachment_file', requestForm.value.attachment_file)
    }

    if (Object.keys(customFieldsData.value).length > 0) {
      formData.append('custom_fields_data', JSON.stringify(customFieldsData.value))
    }

    await api.post('/student/dispensations', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Permohonan izin dispensasi KBM berhasil dikirim ke pihak sekolah.', 'Pengajuan Berhasil')
    showRequestModal.value = false
    customFieldsData.value = {}
    requestForm.value = {
      competition_name: '',
      dispensation_type: 'persiapan_latihan',
      purpose: '',
      start_date: '',
      end_date: '',
      is_all_day: true,
      start_time: '',
      end_time: '',
      supervisor_name: '',
      notes: '',
      attachment_file: null,
    }
    fetchDispensations()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengajukan dispensasi KBM.', 'Gagal Pengajuan')
  } finally {
    requesting.value = false
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
    a.download = `Surat_Dispensasi_${safeName}.docx`
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
    a.download = `Surat_Dispensasi_${safeName}.pdf`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    toast.success('Berkas PDF berhasil diunduh.', 'Unduh Berhasil')
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
    <template #header-title>Izin Dispensasi Belajar (KBM)</template>

    <div class="space-y-6 max-w-5xl mx-auto">
      <!-- Humanized Student Guidance Banner -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200/90 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-1.5 max-w-xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-blue-50 text-brand-navy text-xs font-semibold">
            <i class="fa-solid fa-graduation-cap text-brand-blue"></i>
            Pelayanan Izin Siswa
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Izin Dispensasi Mengikuti Lomba
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Perlu izin meninggalkan kelas untuk persiapan materi, latihan intensif bersama pembimbing, atau hari-H lomba? Ajukan dispensasi di sini agar ketidakhadiranmu di kelas resmi tercatat dan tidak dianggap alpa oleh guru piket.
          </p>
        </div>

        <button
          type="button"
          @click="showRequestModal = true"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-[#00164a] transition-all cursor-pointer shrink-0"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Ajukan Izin Baru</span>
        </button>
      </div>

      <!-- Quick Informative Tip Card -->
      <div class="bg-amber-50/70 border border-amber-200/80 rounded-xl p-4 flex items-start gap-3 text-xs text-amber-900">
        <i class="fa-solid fa-circle-info text-amber-600 text-sm mt-0.5 shrink-0"></i>
        <div class="space-y-1 leading-relaxed">
          <p class="font-bold">Tips Pengajuan Dispensasi:</p>
          <p class="text-amber-800/90">
            Pastikan kamu sudah berkoordinasi dengan guru pembina lomba sebelum mengajukan. Setelah disetujui pihak kesiswaan, kamu dapat langsung membuka tombol <strong>"Lihat Pass Izin Digital"</strong> dari ponselmu untuk ditunjukkan kepada guru kelas atau guru piket.
          </p>
        </div>
      </div>

      <!-- Dispensations History Container -->
      <div class="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 class="text-sm font-bold text-slate-800">Riwayat Pengajuan Dispensasi KBM</h3>
            <p class="text-xs text-slate-500">Status persetujuan resmi dari pihak sekolah</p>
          </div>
          <span class="text-xs font-semibold text-slate-500 font-mono">{{ dispensations.length }} pengajuan</span>
        </div>

        <div v-if="loading" class="py-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2">Memeriksa data dispensasi...</p>
        </div>

        <div v-else-if="dispensations.length === 0" class="py-16 text-center">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
            <i class="fa-solid fa-file-circle-check"></i>
          </div>
          <h4 class="text-sm font-bold text-slate-800">Belum Ada Pengajuan Dispensasi</h4>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
            Jika kamu membutuhkan waktu latihan intensif atau hari keberangkatan lomba, silakan klik tombol "Ajukan Izin Baru" di atas.
          </p>
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
                  Disetujui Sekolah
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
                  Menunggu Persetujuan
                </span>

                <span class="text-[11px] font-medium px-2 py-0.5 rounded bg-slate-100 text-slate-600 border border-slate-200">
                  {{ item.dispensation_type === 'persiapan_latihan' ? 'Latihan / Persiapan' : 'Hari Pelaksanaan' }}
                </span>

                <span v-if="item.reference_number" class="text-xs font-mono text-slate-500">
                  No: {{ item.reference_number }}
                </span>
              </div>

              <div>
                <h4 class="text-sm font-bold text-slate-900">{{ item.competition_name }}</h4>
                <p class="text-xs text-slate-600 mt-0.5">
                  <span class="font-semibold text-slate-700">Keperluan:</span> {{ item.purpose }}
                </p>
              </div>

              <div class="flex items-center gap-4 text-xs text-slate-500 flex-wrap pt-0.5">
                <span>
                  <i class="fa-regular fa-calendar mr-1 text-slate-400"></i>
                  {{ item.start_date }} s.d. {{ item.end_date }}
                </span>
                <span>
                  <i class="fa-regular fa-clock mr-1 text-slate-400"></i>
                  {{ item.is_all_day ? 'Seharian Penuh' : `${item.start_time} - ${item.end_time}` }}
                </span>
                <span v-if="item.supervisor_name">
                  <i class="fa-solid fa-chalkboard-user mr-1 text-slate-400"></i>
                  Pembimbing: {{ item.supervisor_name }}
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
                  title="Buka QR Pass Verifikasi Guru"
                >
                  <i class="fa-solid fa-qrcode"></i>
                  <span>Pass Digital</span>
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

                <!-- Unduh PDF Button -->
                <button
                  type="button"
                  @click="downloadPdf(item.id, item.reference_number)"
                  :disabled="downloadingPdfId === item.id"
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-rose-700 hover:bg-rose-800 text-white text-xs font-bold transition-all shadow-xs cursor-pointer disabled:opacity-60"
                  title="Unduh Berkas PDF .pdf"
                >
                  <i v-if="downloadingPdfId === item.id" class="fa-solid fa-spinner fa-spin"></i>
                  <i v-else class="fa-solid fa-file-pdf"></i>
                  <span>PDF</span>
                </button>
              </template>
              <span v-else class="text-xs text-slate-400 italic">
                Izin terbit setelah disahkan kesiswaan
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Request Dispensation Modal -->
    <Modal v-model="showRequestModal" title="Formulir Pengajuan Izin Dispensasi KBM" @close="showRequestModal = false">
      <form @submit.prevent="handleRequestDispensation" class="space-y-4 text-xs">
        <div>
          <label class="block font-bold text-slate-700 mb-1">Nama Lomba / Kegiatan *</label>
          <input
            v-model="requestForm.competition_name"
            type="text"
            required
            placeholder="Contoh: Olimpiade Sains Nasional (OSN) Bidang Matematika 2026"
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="block font-bold text-slate-700 mb-1">Jenis Izin *</label>
            <select
              v-model="requestForm.dispensation_type"
              required
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            >
              <option value="persiapan_latihan">Persiapan & Latihan Intensif</option>
              <option value="pelaksanaan_lomba">Hari-H Pelaksanaan Lomba</option>
              <option value="lainnya">Kegiatan Prestasi Lainnya</option>
            </select>
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1">
              Guru Pembina Lomba <span class="text-rose-500">*</span>
            </label>
            <input
              v-model="requestForm.supervisor_name"
              type="text"
              required
              placeholder="Contoh: Dra. Sri Wahyuni, M.Pd."
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
            <p class="text-[10px] text-slate-500 mt-1">
              Nama guru pembina ini akan tercantum resmi pada kolom tanda tangan surat perizinan.
            </p>
          </div>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Uraian / Alasan Izin *</label>
          <textarea
            v-model="requestForm.purpose"
            rows="2"
            required
            placeholder="Contoh: Mengikuti bimbingan intensif dan bedah soal babak semifinal bersama pembina di lab komputer."
            class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block font-bold text-slate-700 mb-1">Tanggal Mulai Izin *</label>
            <input
              v-model="requestForm.start_date"
              type="date"
              required
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
          <div>
            <label class="block font-bold text-slate-700 mb-1">Tanggal Selesai Izin *</label>
            <input
              v-model="requestForm.end_date"
              type="date"
              required
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
        </div>

        <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg space-y-2">
          <label class="flex items-center gap-2 cursor-pointer font-bold text-slate-700">
            <input
              v-model="requestForm.is_all_day"
              type="checkbox"
              class="rounded border-slate-300 text-brand-navy focus:ring-brand-navy"
            />
            <span>Izin Seharian Penuh (Seluruh Jam Pelajaran)</span>
          </label>

          <div v-if="!requestForm.is_all_day" class="grid grid-cols-2 gap-3 pt-2">
            <div>
              <label class="block text-[11px] font-semibold text-slate-600 mb-1">Jam Mulai</label>
              <input
                v-model="requestForm.start_time"
                type="time"
                class="w-full rounded-lg border border-slate-300 p-2"
              />
            </div>
            <div>
              <label class="block text-[11px] font-semibold text-slate-600 mb-1">Jam Selesai</label>
              <input
                v-model="requestForm.end_time"
                type="time"
                class="w-full rounded-lg border border-slate-300 p-2"
              />
            </div>
          </div>
        </div>

        <div>
          <label class="block font-bold text-slate-700 mb-1">Dokumen Pendukung (Surat Undangan / Poster Lomba)</label>
          <input
            type="file"
            accept=".pdf,.jpg,.jpeg,.png"
            @change="handleAttachmentChange"
            class="w-full text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-[#00164a] cursor-pointer"
          />
        </div>

        <!-- Dynamic Custom Fields from School Schema -->
        <div v-if="formSchema && formSchema.length > 0" class="pt-4 border-t border-slate-200 space-y-3">
          <div class="flex items-center gap-1.5 text-brand-navy font-bold text-xs">
            <i class="fa-solid fa-sparkles text-brand-gold"></i>
            <span>Persyaratan Tambahan Sekolah</span>
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
              v-model="customFieldsData[field.name]"
              type="text"
              :placeholder="field.placeholder || ''"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />

            <!-- Textarea -->
            <textarea
              v-else-if="field.type === 'textarea'"
              v-model="customFieldsData[field.name]"
              rows="2"
              :placeholder="field.placeholder || ''"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            ></textarea>

            <!-- Select Dropdown -->
            <select
              v-else-if="field.type === 'select'"
              v-model="customFieldsData[field.name]"
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
              v-model.number="customFieldsData[field.name]"
              type="number"
              :placeholder="field.placeholder || '0'"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />

            <!-- Date -->
            <input
              v-else-if="field.type === 'date'"
              v-model="customFieldsData[field.name]"
              type="date"
              :required="field.is_required"
              class="w-full rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />

            <!-- Checkbox -->
            <label v-else-if="field.type === 'checkbox'" class="flex items-start gap-2 pt-1 cursor-pointer">
              <input
                type="checkbox"
                v-model="customFieldsData[field.name]"
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
            @click="showRequestModal = false"
            class="px-4 py-2 rounded-lg font-semibold text-slate-600 hover:bg-slate-100 cursor-pointer"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="requesting"
            class="px-5 py-2 rounded-lg font-bold bg-brand-navy text-white hover:bg-[#00164a] disabled:opacity-50 transition-all flex items-center gap-2 cursor-pointer"
          >
            <i v-if="requesting" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ requesting ? 'Mengirimkan...' : 'Kirim Pengajuan' }}</span>
          </button>
        </div>
      </form>
    </Modal>

    <!-- Authentic Digital School Pass Modal -->
    <Modal v-model="showQrModal" title="Pass Izin Digital Siswa" @close="showQrModal = false">
      <div v-if="selectedDisp" class="space-y-4 text-slate-800">
        <!-- Digital Pass Card (Modern Indonesian Student ID Look) -->
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
                  <span class="font-semibold text-slate-700">{{ selectedDisp.start_date }} s.d. {{ selectedDisp.end_date }}</span>
                </div>
                <div>
                  <span class="text-slate-400 block text-[10px] uppercase font-bold">Waktu</span>
                  <span class="font-semibold text-slate-700">{{ selectedDisp.is_all_day ? 'Seharian Penuh' : `${selectedDisp.start_time} - ${selectedDisp.end_time}` }}</span>
                </div>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Pengesahan Kesiswaan</span>
                <span class="font-semibold text-emerald-800">{{ selectedDisp.approved_by?.name || 'Admin Sekolah' }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="pt-3 flex flex-wrap items-center justify-center gap-2 border-t border-slate-100">
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
            @click="downloadPdf(selectedDisp.id, selectedDisp.reference_number)"
            :disabled="downloadingPdfId === selectedDisp.id"
            class="px-4 py-2 rounded-xl text-xs font-bold bg-rose-700 hover:bg-rose-800 text-white flex items-center gap-1.5 shadow-xs cursor-pointer disabled:opacity-60"
          >
            <i v-if="downloadingPdfId === selectedDisp.id" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-file-pdf"></i>
            <span>Unduh PDF</span>
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
