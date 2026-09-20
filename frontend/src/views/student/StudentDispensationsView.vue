<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const dispensations = ref<any[]>([])
const loading = ref(true)

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

// QR / Pass Modal
const showQrModal = ref(false)
const selectedDisp = ref<any>(null)

async function fetchDispensations() {
  loading.value = true
  try {
    const res = await api.get('/student/dispensations')
    dispensations.value = extractList(res.data.data)
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

    await api.post('/student/dispensations', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Permohonan izin dispensasi KBM berhasil diajukan ke pihak sekolah.', 'Pengajuan Berhasil')
    showRequestModal.value = false
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

onMounted(() => {
  fetchDispensations()
})
</script>

<template>
  <DashboardLayout>
    <div class="space-y-6">
      <!-- Header Banner -->
      <div class="bg-white rounded-2xl p-6 sm:p-8 shadow-xs border border-slate-200/80 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 relative overflow-hidden">
        <div class="absolute -right-10 -bottom-10 w-48 h-48 bg-gradient-to-br from-brand-navy/5 to-emerald-500/10 rounded-full blur-2xl pointer-events-none"></div>
        <div class="space-y-2 z-10 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-bold">
            <i class="fa-solid fa-file-signature text-emerald-600"></i>
            Pelayanan Perizinan Sekolah
          </div>
          <h1 class="text-2xl sm:text-3xl font-black text-brand-navy tracking-tight">Izin Dispensasi KBM</h1>
          <p class="text-sm text-slate-600 leading-relaxed">
            Ajukan perizinan tidak mengikuti Kegiatan Belajar Mengajar (KBM) untuk persiapan latihan intensif atau hari keberangkatan lomba. Surat dispensasi ber-QR Code resmi dapat diperlihatkan langsung ke guru piket atau guru kelas.
          </p>
        </div>
        <div class="z-10">
          <button
            @click="showRequestModal = true"
            class="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-md hover:bg-blue-900 transition-all cursor-pointer"
          >
            <i class="fa-solid fa-plus text-brand-gold"></i>
            <span>Ajukan Dispensasi Baru</span>
          </button>
        </div>
      </div>

      <!-- Dispensations List -->
      <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div class="p-5 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h2 class="text-base font-bold text-slate-800">Daftar Pengajuan Dispensasi KBM</h2>
            <p class="text-xs text-slate-500">Pantau status persetujuan dari kesiswaan/kurikulum sekolah</p>
          </div>
        </div>

        <div v-if="loading" class="p-12 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-3xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2">Memuat data dispensasi...</p>
        </div>

        <div v-else-if="dispensations.length === 0" class="p-12 text-center">
          <div class="w-16 h-16 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-2xl mb-4">
            <i class="fa-solid fa-file-circle-check"></i>
          </div>
          <h3 class="text-base font-bold text-slate-800">Belum Ada Pengajuan Dispensasi</h3>
          <p class="text-xs text-slate-500 max-w-md mx-auto mt-1">
            Jika kamu perlu persiapan, latihan bersama pembimbing, atau berangkat lomba, klik tombol "Ajukan Dispensasi Baru" di atas.
          </p>
        </div>

        <div v-else class="divide-y divide-slate-100">
          <div
            v-for="item in dispensations"
            :key="item.id"
            class="p-5 hover:bg-slate-50/70 transition-colors flex flex-col md:flex-row items-start md:items-center justify-between gap-4"
          >
            <div class="space-y-2 flex-1">
              <div class="flex items-center gap-2 flex-wrap">
                <span
                  v-if="item.status === 'approved'"
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300"
                >
                  <i class="fa-solid fa-circle-check text-emerald-600"></i>
                  Disetujui Sekolah
                </span>
                <span
                  v-else-if="item.status === 'rejected'"
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-bold bg-red-100 text-red-800 border border-red-300"
                >
                  <i class="fa-solid fa-circle-xmark text-red-600"></i>
                  Ditolak
                </span>
                <span
                  v-else
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-bold bg-amber-100 text-amber-800 border border-amber-300"
                >
                  <i class="fa-solid fa-clock text-amber-600"></i>
                  Menunggu Persetujuan
                </span>

                <span class="text-xs font-semibold px-2 py-0.5 rounded-md bg-blue-50 text-blue-800 border border-blue-200">
                  {{ item.dispensation_type === 'persiapan_latihan' ? 'Persiapan & Latihan' : (item.dispensation_type === 'pelaksanaan_lomba' ? 'Hari Lomba' : 'Kegiatan Lain') }}
                </span>

                <span v-if="item.reference_number" class="text-xs font-mono text-slate-500 font-semibold">
                  No: {{ item.reference_number }}
                </span>
              </div>

              <div>
                <h3 class="text-base font-bold text-brand-navy">{{ item.competition_name }}</h3>
                <p class="text-xs text-slate-600 mt-0.5">
                  <span class="font-semibold text-slate-700">Tujuan:</span> {{ item.purpose }}
                </p>
              </div>

              <div class="flex items-center gap-4 text-xs text-slate-500 flex-wrap">
                <span>
                  <i class="fa-solid fa-calendar-day mr-1 text-slate-400"></i>
                  {{ item.start_date }} s.d. {{ item.end_date }}
                </span>
                <span v-if="!item.is_all_day && item.start_time">
                  <i class="fa-solid fa-clock mr-1 text-slate-400"></i>
                  {{ item.start_time }} - {{ item.end_time }}
                </span>
                <span v-else>
                  <i class="fa-solid fa-sun mr-1 text-amber-500"></i>
                  Seharian Penuh
                </span>
                <span v-if="item.supervisor_name">
                  <i class="fa-solid fa-chalkboard-user mr-1 text-slate-400"></i>
                  Pembimbing: {{ item.supervisor_name }}
                </span>
              </div>

              <div v-if="item.status === 'rejected' && item.rejection_reason" class="p-2.5 bg-red-50 border border-red-200 rounded-xl text-xs text-red-800">
                <span class="font-bold">Alasan Penolakan:</span> {{ item.rejection_reason }}
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center gap-2 shrink-0 w-full md:w-auto">
              <button
                v-if="item.status === 'approved'"
                @click="openQrModal(item.id)"
                class="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-emerald-600 text-white hover:bg-emerald-700 text-xs font-bold shadow-xs transition-all w-full md:w-auto cursor-pointer"
              >
                <i class="fa-solid fa-qrcode text-base"></i>
                <span>Tampilkan QR Guru</span>
              </button>
              <span v-else class="text-xs text-slate-400 italic">
                QR terbit setelah disetujui
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Request Dispensation Modal -->
    <Modal v-model="showRequestModal" title="Pengajuan Izin Dispensasi KBM Baru" @close="showRequestModal = false">
      <form @submit.prevent="handleRequestDispensation" class="space-y-4">
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Nama Lomba / Kegiatan *</label>
          <input
            v-model="requestForm.competition_name"
            type="text"
            required
            placeholder="Contoh: Olimpiade Sains Nasional Bidang Matematika 2026"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Jenis Dispensasi *</label>
            <select
              v-model="requestForm.dispensation_type"
              required
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            >
              <option value="persiapan_latihan">Persiapan & Latihan Intensif</option>
              <option value="pelaksanaan_lomba">Hari-H Pelaksanaan Lomba</option>
              <option value="lainnya">Kegiatan Prestasi Lainnya</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Guru Pembimbing / Pendamping</label>
            <input
              v-model="requestForm.supervisor_name"
              type="text"
              placeholder="Contoh: Bpk. Bambang, S.Pd."
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            />
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Alasan / Uraian Kegiatan *</label>
          <textarea
            v-model="requestForm.purpose"
            rows="2"
            required
            placeholder="Contoh: Mengikuti sesi bimbingan dan simulasi ujian babak semifinal di laboratorium komputer sekolah."
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Mulai Izin *</label>
            <input
              v-model="requestForm.start_date"
              type="date"
              required
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            />
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Selesai Izin *</label>
            <input
              v-model="requestForm.end_date"
              type="date"
              required
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:outline-hidden focus:ring-2 focus:ring-brand-gold focus:border-brand-gold"
            />
          </div>
        </div>

        <div class="p-3 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
          <label class="flex items-center gap-2 cursor-pointer text-xs font-bold text-slate-700">
            <input
              v-model="requestForm.is_all_day"
              type="checkbox"
              class="rounded-sm border-slate-300 text-brand-navy focus:ring-brand-gold"
            />
            <span>Izin Seharian Penuh (Seluruh Jam Pelajaran)</span>
          </label>

          <div v-if="!requestForm.is_all_day" class="grid grid-cols-2 gap-3 pt-2">
            <div>
              <label class="block text-[11px] font-semibold text-slate-600 mb-1">Jam Mulai</label>
              <input
                v-model="requestForm.start_time"
                type="time"
                class="w-full text-xs rounded-lg border border-slate-300 p-2"
              />
            </div>
            <div>
              <label class="block text-[11px] font-semibold text-slate-600 mb-1">Jam Selesai</label>
              <input
                v-model="requestForm.end_time"
                type="time"
                class="w-full text-xs rounded-lg border border-slate-300 p-2"
              />
            </div>
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Lampiran Dokumen (Surat Undangan / Poster Lomba)</label>
          <input
            type="file"
            accept=".pdf,.jpg,.jpeg,.png"
            @change="handleAttachmentChange"
            class="w-full text-xs text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-blue-900 cursor-pointer"
          />
        </div>

        <div class="pt-4 border-t border-slate-200 flex justify-end gap-2">
          <button
            type="button"
            @click="showRequestModal = false"
            class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="requesting"
            class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-navy text-white hover:bg-blue-900 disabled:opacity-50 transition-all flex items-center gap-2 cursor-pointer"
          >
            <i v-if="requesting" class="fa-solid fa-circle-notch fa-spin"></i>
            <span>{{ requesting ? 'Mengirim Pengajuan...' : 'Kirim Pengajuan' }}</span>
          </button>
        </div>
      </form>
    </Modal>

    <!-- QR Code Digital Pass Modal -->
    <Modal v-model="showQrModal" title="Pass Digital Dispensasi KBM Siswa" @close="showQrModal = false">
      <div v-if="selectedDisp" class="text-center space-y-4">
        <!-- Verification Badge -->
        <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-emerald-100 text-emerald-800 text-xs font-black border border-emerald-300">
          <i class="fa-solid fa-shield-check text-emerald-600"></i>
          DISPENSASI RESMI TERVERIFIKASI
        </div>

        <!-- School info -->
        <div>
          <h3 class="text-base font-black text-brand-navy">{{ selectedDisp.school?.name }}</h3>
          <p class="text-xs text-slate-500 font-mono">{{ selectedDisp.reference_number }}</p>
        </div>

        <!-- QR Code Container -->
        <div class="inline-block p-4 bg-white rounded-2xl border-2 border-emerald-400 shadow-md">
          <img
            v-if="selectedDisp.qr_code_data_uri"
            :src="selectedDisp.qr_code_data_uri"
            alt="QR Code Dispensasi"
            class="w-48 h-48 mx-auto"
          />
          <p class="text-[10px] text-slate-400 mt-2 font-mono">Pindai dengan kamera untuk verifikasi guru</p>
        </div>

        <!-- Card summary -->
        <div class="bg-slate-50 rounded-xl p-4 text-xs text-left space-y-2 border border-slate-200">
          <div>
            <span class="text-slate-400 block text-[10px] uppercase font-bold">Kegiatan / Lomba</span>
            <span class="font-bold text-slate-800">{{ selectedDisp.competition_name }}</span>
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
            <span class="text-slate-400 block text-[10px] uppercase font-bold">Disetujui Oleh</span>
            <span class="font-semibold text-emerald-700">{{ selectedDisp.approved_by?.name ?? 'Admin Kesiswaan' }}</span>
          </div>
        </div>

        <div class="pt-3 border-t border-slate-100 flex justify-center">
          <button
            type="button"
            @click="showQrModal = false"
            class="px-6 py-2 rounded-xl text-xs font-bold bg-slate-800 text-white hover:bg-slate-900"
          >
            Tutup
          </button>
        </div>
      </div>
    </Modal>
  </DashboardLayout>
</template>
