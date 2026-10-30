<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import QrScannerModal from '@/components/common/QrScannerModal.vue'
import api, { API_BASE_URL } from '@/services/api'
import { formatDateIndo, formatDateRange } from '@/utils/date'

const route = useRoute()
const router = useRouter()

const inputCode = ref((route.params.public_id as string) || (route.params.token as string) || (route.query.id as string) || (route.query.token as string) || '')
const loading = ref(false)
const error = ref<string | null>(null)
const errorStatus = ref<string | null>(null)
const pendingAchievementTitle = ref<string | null>(null)
const showScannerModal = ref(false)

// Result state
const resultType = ref<'achievement' | 'dispensation' | null>(null)
const achievementData = ref<any>(null)
const dispensationData = ref<any>(null)
const qrUrl = ref<string | null>(null)

function normalizeCode(raw: string): string {
  let val = raw.trim()
  // If user pasted a full URL, extract the last segment or query param
  if (/^https?:\/\//i.test(val)) {
    try {
      const url = new URL(val)
      const segments = url.pathname.split('/').filter(Boolean)
      const verifyIdx = segments.indexOf('verify')
      if (verifyIdx !== -1 && segments[verifyIdx + 1]) {
        val = segments[verifyIdx + 1]
      } else {
        const verifikasiIdx = segments.indexOf('verifikasi')
        if (verifikasiIdx !== -1 && segments[verifikasiIdx + 1]) {
          val = segments[verifikasiIdx + 1]
        } else if (segments.length > 0) {
          val = segments[segments.length - 1]
        }
      }
    } catch {
      // fallback
    }
  }

  // Replace spaces or underscores with hyphens if it looks like an achievement public id
  if (/pku/i.test(val) || /ach/i.test(val)) {
    return val.replace(/[\s_]+/g, '-').toUpperCase()
  }
  return val
}

async function verifyCode(query: string) {
  if (!query || !query.trim()) return
  loading.value = true
  error.value = null
  errorStatus.value = null
  pendingAchievementTitle.value = null
  resultType.value = null
  achievementData.value = null
  dispensationData.value = null
  qrUrl.value = null

  const clean = normalizeCode(query)
  inputCode.value = clean

  // 1. If explicitly looks like an achievement (PKU-ACH-...)
  if (/^PKU-ACH-/i.test(clean)) {
    try {
      const res = await api.get(`/verify/${encodeURIComponent(clean)}`)
      resultType.value = 'achievement'
      achievementData.value = res.data.data
      qrUrl.value = `${API_BASE_URL}/verify/${encodeURIComponent(clean)}/qr`
      return
    } catch (err: any) {
      handleAchievementError(err)
      return
    } finally {
      loading.value = false
    }
  }

  // 2. If explicitly looks like dispensation (contains DISP, KBM, or /)
  if (/DISP|KBM|\//i.test(clean)) {
    try {
      const res = await api.get(`/dispensations/verify/${encodeURIComponent(clean)}`)
      resultType.value = 'dispensation'
      dispensationData.value = res.data.data
      return
    } catch {
      // Try achievement as fallback before giving up
    }
  }

  // 3. General verification: try achievement first
  try {
    const res = await api.get(`/verify/${encodeURIComponent(clean)}`)
    resultType.value = 'achievement'
    achievementData.value = res.data.data
    qrUrl.value = `${API_BASE_URL}/verify/${encodeURIComponent(clean)}/qr`
    loading.value = false
    return
  } catch (err: any) {
    if (err.response?.status === 422 && err.response?.data?.status === 'pending_verification') {
      handleAchievementError(err)
      loading.value = false
      return
    }

    // If achievement 404, try dispensation verification
    try {
      const dispRes = await api.get(`/dispensations/verify/${encodeURIComponent(clean)}`)
      resultType.value = 'dispensation'
      dispensationData.value = dispRes.data.data
      loading.value = false
      return
    } catch {
      error.value = 'Dokumen tidak ditemukan atau kode verifikasi QR tidak valid di pangkalan data sekolah.'
    }
  } finally {
    loading.value = false
  }
}

function handleAchievementError(err: any) {
  const data = err.response?.data
  errorStatus.value = data?.status || null
  pendingAchievementTitle.value = data?.achievement_title || null
  error.value = data?.message || 'Prestasi tidak ditemukan atau kode verifikasi tidak valid.'
}

function handleSearch() {
  if (inputCode.value.trim()) {
    const clean = normalizeCode(inputCode.value)
    router.push(`/verify/${encodeURIComponent(clean)}`)
    verifyCode(clean)
  }
}

function handleQrScanned(result: { code: string; raw: string; isUrl: boolean }) {
  const clean = normalizeCode(result.code || result.raw)
  inputCode.value = clean
  router.push(`/verify/${encodeURIComponent(clean)}`)
  verifyCode(clean)
}

onMounted(() => {
  if (inputCode.value) {
    verifyCode(inputCode.value)
  }
})

watch(() => route.params.public_id, (newVal) => {
  if (newVal) {
    inputCode.value = newVal as string
    verifyCode(newVal as string)
  }
})
watch(() => route.params.token, (newVal) => {
  if (newVal) {
    inputCode.value = newVal as string
    verifyCode(newVal as string)
  }
})
</script>

<template>
  <PublicLayout>
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <!-- Page Header -->
      <div class="text-center max-w-xl mx-auto mb-8 space-y-2">
        <div class="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-blue-50 text-brand-blue text-xs font-semibold border border-blue-200">
          <i class="fa-solid fa-qrcode text-brand-gold"></i>
          <span>Portal Verifikasi Dokumen & QR</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">Verifikasi Keaslian Dokumen</h1>
        <p class="text-xs sm:text-sm text-slate-600">
          Pindai QR Code menggunakan kamera atau masukkan kode sertifikat prestasi / surat dispensasi untuk memeriksa keabsahan dokumen resmi sekolah.
        </p>
      </div>

      <!-- Single Unified Search & Cam Scanner Input Box -->
      <div class="bg-white rounded-2xl p-3 sm:p-4 border border-slate-200/80 shadow-md mb-8">
        <form @submit.prevent="handleSearch" class="flex items-center gap-2 flex-wrap sm:flex-nowrap">
          <div class="pl-2 text-slate-400">
            <i class="fa-solid fa-barcode text-lg"></i>
          </div>
          <input
            v-model="inputCode"
            type="text"
            placeholder="Ketik Public ID (PKU-ACH-...), token QR, atau nomor surat..."
            class="flex-1 bg-transparent border-none text-xs sm:text-sm font-bold tracking-wider text-slate-800 placeholder-slate-400 focus:outline-hidden py-2 min-w-[200px]"
          />
          <div class="flex items-center gap-2 w-full sm:w-auto justify-end">
            <!-- Cam Scanner Button -->
            <button
              type="button"
              @click="showScannerModal = true"
              class="px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-1.5 cursor-pointer shrink-0"
              title="Buka Kamera untuk Pindai QR"
            >
              <i class="fa-solid fa-camera"></i>
              <span>Scan Kamera</span>
            </button>

            <!-- Submit Button -->
            <button
              type="submit"
              :disabled="loading"
              class="px-5 py-2.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-1.5 cursor-pointer shrink-0 disabled:opacity-50"
            >
              <i v-if="loading" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-magnifying-glass"></i>
              <span>Verifikasi</span>
            </button>
          </div>
        </form>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="bg-white rounded-3xl p-8 border border-slate-200 text-center animate-pulse space-y-4">
        <div class="w-16 h-16 rounded-full bg-slate-200 mx-auto"></div>
        <div class="h-5 bg-slate-200 rounded-md w-1/3 mx-auto"></div>
        <div class="h-4 bg-slate-100 rounded-md w-1/2 mx-auto"></div>
      </div>

      <!-- Pending Verification Warning -->
      <div
        v-else-if="errorStatus === 'pending_verification'"
        class="bg-amber-50 rounded-3xl p-6 sm:p-8 border-2 border-amber-300 text-center space-y-4 shadow-sm"
      >
        <div class="w-14 h-14 rounded-full bg-amber-100 text-amber-600 flex items-center justify-center text-2xl mx-auto shadow-xs">
          <i class="fa-solid fa-clock-rotate-left"></i>
        </div>
        <div>
          <span class="inline-block px-3 py-1 rounded-full text-[11px] font-bold bg-amber-200/80 text-amber-900 uppercase tracking-wider mb-2">
            Status: Menunggu Verifikasi Sekolah
          </span>
          <h3 class="text-base sm:text-lg font-bold text-slate-900">
            Prestasi Terdaftar, Namun Belum Diterbitkan Resmi
          </h3>
          <p v-if="pendingAchievementTitle" class="text-xs font-semibold text-amber-800 mt-1">
            "{{ pendingAchievementTitle }}"
          </p>
        </div>
        <p class="text-xs text-slate-600 max-w-md mx-auto leading-relaxed">
          Catatan prestasi dengan kode <strong>{{ inputCode }}</strong> ini telah masuk ke dalam pangkalan data sekolah, namun saat ini masih berstatus <em>pending_verification</em>. Sertifikat QR publik hanya dapat diakses setelah pihak sekolah (Kesiswaan/Admin) menekan tombol <strong>"Terbitkan QR"</strong> pada daftar prestasi sekolah.
        </p>
      </div>

      <!-- Error State: Not Found -->
      <div v-else-if="error" class="bg-white rounded-3xl p-8 border border-rose-100 shadow-sm text-center space-y-3">
        <div class="w-14 h-14 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center text-2xl mx-auto">
          <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="text-base font-bold text-slate-800">Dokumen Tidak Ditemukan</h3>
        <p class="text-xs text-slate-500 max-w-md mx-auto">{{ error }}</p>
      </div>

      <!-- RESULT 1: PRESTASI CERTIFICATE -->
      <div
        v-else-if="resultType === 'achievement' && achievementData"
        class="bg-white rounded-3xl border-2 border-emerald-500/30 shadow-xl overflow-hidden relative"
      >
        <!-- Top Verified Banner -->
        <div class="bg-gradient-to-r from-emerald-600 to-teal-700 text-white px-6 py-4 flex items-center justify-between flex-wrap gap-2">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center text-xl">
              <i class="fa-solid fa-circle-check"></i>
            </div>
            <div>
              <p class="text-[10px] uppercase font-bold tracking-widest text-emerald-200">Dokumen Sah Terverifikasi</p>
              <h3 class="text-base font-extrabold tracking-tight">Sertifikat Prestasi Siswa Terdaftar</h3>
            </div>
          </div>
          <span class="px-3 py-1 bg-white/15 rounded-full text-xs font-mono font-bold tracking-wider">
            {{ achievementData.public_id }}
          </span>
        </div>

        <!-- Certificate Body -->
        <div class="p-6 sm:p-8 space-y-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-8 items-center">
            <!-- Left Details -->
            <div class="md:col-span-2 space-y-4">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Nama Penerima / Siswa</p>
                <h2 class="text-2xl font-black text-slate-900 mt-0.5 flex items-center gap-2">
                  <span>{{ achievementData.student_name }}</span>
                  <span v-if="achievementData.is_name_masked" class="text-[10px] font-semibold text-slate-400 bg-slate-100 px-2 py-0.5 rounded-md" title="Nama disamarkan untuk privasi">
                    <i class="fa-solid fa-user-shield text-slate-400"></i> Disamarkan
                  </span>
                </h2>
                <p class="text-xs text-slate-500 mt-1 font-semibold flex items-center gap-1.5">
                  <i class="fa-solid fa-school text-brand-blue"></i>
                  <span>{{ achievementData.school?.name || 'MA Unggulan K.H. Abd. Wahab Hasbulloh' }}</span>
                </p>
              </div>

              <div class="p-4 rounded-2xl bg-amber-50/70 border border-amber-200/80 space-y-2">
                <div class="flex items-center justify-between">
                  <span class="text-[10px] font-bold uppercase tracking-wider text-amber-800">Capaian Prestasi</span>
                  <span class="text-[10px] font-bold px-2 py-0.5 bg-amber-200/70 text-amber-900 rounded-md">
                    {{ String(achievementData.achievement?.level || 'nasional').replace('_', ' ').toUpperCase() }}
                  </span>
                </div>
                <div class="text-xl font-black text-amber-900 flex items-center gap-2">
                  <i class="fa-solid fa-trophy text-brand-gold"></i>
                  <span>{{ achievementData.achievement?.rank || 'Juara' }}</span>
                </div>
                <p class="text-xs font-semibold text-slate-700">
                  {{ achievementData.achievement?.title || achievementData.achievement?.event_name }}
                </p>
              </div>

              <!-- Metadata Grid -->
              <div class="grid grid-cols-2 gap-3 text-xs">
                <div class="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <p class="text-[10px] font-bold uppercase text-slate-400">Penyelenggara</p>
                  <p class="font-semibold text-slate-800 mt-0.5">{{ achievementData.achievement?.organizer_name || '-' }}</p>
                </div>
                <div class="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <p class="text-[10px] font-bold uppercase text-slate-400">Tanggal Kejuaraan</p>
                  <p class="font-semibold text-slate-800 mt-0.5">{{ formatDateIndo(achievementData.achievement?.event_date) }}</p>
                </div>
              </div>
            </div>

            <!-- Right QR Code Display -->
            <div class="flex flex-col items-center justify-center p-6 bg-slate-50 rounded-2xl border border-slate-200/80 text-center space-y-3">
              <div class="w-40 h-40 bg-white p-2 rounded-xl shadow-xs border border-slate-200 flex items-center justify-center overflow-hidden">
                <img
                  v-if="qrUrl"
                  :src="qrUrl"
                  alt="QR Code Verifikasi"
                  class="w-full h-full object-contain"
                />
              </div>
              <div>
                <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">QR Code Resmi</p>
                <p class="text-[11px] font-mono font-bold text-brand-navy">{{ achievementData.public_id }}</p>
              </div>
              <p class="text-[10px] text-slate-400">Disahkan secara digital oleh {{ achievementData.school?.name }}</p>
            </div>
          </div>
        </div>

        <div class="bg-slate-50 px-6 py-3 border-t border-slate-100 text-center text-[11px] text-slate-400">
          Sistem Verifikasi QR Ber-ID Publik • Terkoneksi dengan Data Pokok PrestasiKu
        </div>
      </div>

      <!-- RESULT 2: DISPENSASI SURAT RESMI -->
      <div
        v-else-if="resultType === 'dispensation' && dispensationData"
        class="bg-white rounded-3xl shadow-xl border-2 border-brand-navy/20 overflow-hidden"
      >
        <!-- Header Banner -->
        <div
          :class="[
            'p-6 text-center text-white space-y-2',
            dispensationData.is_active_today
              ? 'bg-[#001D60]'
              : (dispensationData.status === 'approved' ? 'bg-slate-700' : 'bg-rose-700')
          ]"
        >
          <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-[11px] font-bold backdrop-blur-xs">
            <i class="fa-solid fa-shield-check text-brand-gold"></i>
            <span>SURAT DISPENSASI RESMI TERDATA</span>
          </div>

          <h2 class="text-lg sm:text-xl font-black tracking-tight uppercase">
            {{ dispensationData.school_name }}
          </h2>
          <p class="text-xs text-blue-100/90 font-mono font-bold">
            Nomor: {{ dispensationData.reference_number }}
          </p>

          <div class="pt-2">
            <span
              v-if="dispensationData.is_active_today"
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-black bg-emerald-500 text-white shadow-xs"
            >
              <i class="fa-solid fa-circle-check"></i>
              SAH & BERLAKU AKTIF HARI INI
            </span>
            <span
              v-else-if="dispensationData.period_status === 'completed'"
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-semibold bg-white/20 text-white"
            >
              Masa Berlaku Izin Telah Berakhir
            </span>
            <span
              v-else
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-semibold bg-white/20 text-white"
            >
              Izin Mulai Berlaku: {{ formatDateIndo(dispensationData.start_date) }}
            </span>
          </div>
        </div>

        <!-- Detail Body -->
        <div class="p-6 sm:p-8 space-y-6 text-xs">
          <!-- Information Card -->
          <div class="bg-slate-50 rounded-2xl p-5 border border-slate-200/80 space-y-3">
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold tracking-wider">Nama Kegiatan / Lomba</span>
              <span class="text-base font-bold text-brand-navy">{{ dispensationData.competition_name }}</span>
            </div>
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold tracking-wider">Tujuan Dispensasi</span>
              <p class="text-slate-700 font-medium leading-relaxed">{{ dispensationData.purpose }}</p>
            </div>
            <div class="grid grid-cols-2 gap-3 pt-3 border-t border-slate-200">
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Periode Tanggal</span>
                <span class="font-bold text-slate-800">{{ formatDateRange(dispensationData.start_date, dispensationData.end_date) }}</span>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Waktu</span>
                <span class="font-bold text-slate-800">{{ dispensationData.is_all_day ? 'Seharian Penuh' : `${dispensationData.start_time} - ${dispensationData.end_time}` }}</span>
              </div>
            </div>
          </div>

          <!-- Students List Table -->
          <div>
            <h3 class="text-xs uppercase tracking-wider font-bold text-slate-600 mb-2.5 flex items-center justify-between">
              <span>Siswa Penerima Dispensasi</span>
              <span class="px-2 py-0.5 bg-slate-100 rounded-md text-[11px] font-bold text-slate-700">{{ dispensationData.students?.length ?? 0 }} Orang</span>
            </h3>
            <div class="border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
              <table class="w-full text-left text-xs border-collapse">
                <thead class="bg-slate-100 text-slate-600 font-bold border-b border-slate-200 text-[11px]">
                  <tr>
                    <th class="px-4 py-2.5 text-center w-10">No</th>
                    <th class="px-4 py-2.5">Nama Lengkap</th>
                    <th class="px-4 py-2.5 text-center">Kelas</th>
                    <th class="px-4 py-2.5 text-center">NIS</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  <tr v-for="(student, idx) in dispensationData.students" :key="student.nis" class="hover:bg-slate-50/70">
                    <td class="px-4 py-2.5 text-center text-slate-400">{{ Number(idx) + 1 }}</td>
                    <td class="px-4 py-2.5 font-bold text-slate-900">{{ student.full_name }}</td>
                    <td class="px-4 py-2.5 text-center font-medium text-slate-700">{{ student.class_name }}</td>
                    <td class="px-4 py-2.5 text-center text-slate-500 font-mono">{{ student.nis }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Approval Details Footer -->
          <div class="flex items-center justify-between text-[11px] text-slate-500 pt-4 border-t border-slate-100 flex-wrap gap-2">
            <div>
              <p>Guru Pembina / PJ: <span class="font-bold text-slate-800">{{ dispensationData.supervisor_name || 'Pembina Lomba' }}</span></p>
            </div>
            <div class="text-right">
              <p>Disetujui Oleh: <span class="font-bold text-emerald-800">{{ dispensationData.approved_by }}</span></p>
              <p class="text-[10px] text-slate-400">{{ dispensationData.approved_at }}</p>
            </div>
          </div>
        </div>

        <div class="bg-slate-50 px-6 py-3 border-t border-slate-100 text-center text-[11px] text-slate-400">
          Diverifikasi Resmi oleh <span class="font-bold text-brand-navy">PrestasiKu</span> • Terhubung dengan Basis Data Sekolah
        </div>
      </div>

      <!-- Universal QR Camera Scanner Modal -->
      <QrScannerModal
        v-model="showScannerModal"
        title="Scan QR Code Kamera"
        subtitle="Arahkan kamera ke QR Code sertifikat prestasi atau surat dispensasi"
        @scanned="handleQrScanned"
      />
    </div>
  </PublicLayout>
</template>
