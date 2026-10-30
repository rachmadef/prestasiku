<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import QrScannerModal from '@/components/common/QrScannerModal.vue'
import api from '@/services/api'
import { formatDateIndo, formatDateRange } from '@/utils/date'

const route = useRoute()
const router = useRouter()

const token = ref((route.params.token as string) || (route.query.token as string) || '')
const inputToken = ref(token.value)
const loading = ref(false)
const verificationResult = ref<any>(null)
const errorMsg = ref('')
const showScannerModal = ref(false)

async function verifyToken(t: string) {
  if (!t.trim()) return
  loading.value = true
  errorMsg.value = ''
  verificationResult.value = null

  const cleanToken = t.trim()
  inputToken.value = cleanToken

  try {
    const res = await api.get(`/dispensations/verify/${encodeURIComponent(cleanToken)}`)
    verificationResult.value = res.data.data
  } catch (err: any) {
    errorMsg.value = err.response?.data?.message || 'Kode verifikasi QR tidak valid atau surat dispensasi tidak ditemukan di database sekolah.'
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  if (inputToken.value.trim()) {
    const cleanToken = inputToken.value.trim()
    router.push(`/dispensasi/verifikasi/${encodeURIComponent(cleanToken)}`)
    verifyToken(cleanToken)
  }
}

function handleQrScanned(result: { code: string; raw: string; isUrl: boolean }) {
  const code = result.code
  const raw = result.raw.toLowerCase()

  // If scanned code is an achievement ID, redirect to achievement verification
  if (code.startsWith('PKU-ACH-') || raw.includes('/verify/pku-ach-') || raw.includes('/verify/pku_ach_')) {
    router.push(`/verify/${encodeURIComponent(code)}`)
    return
  }

  // Handle as dispensation token
  inputToken.value = code
  router.push(`/dispensasi/verifikasi/${encodeURIComponent(code)}`)
  verifyToken(code)
}

onMounted(() => {
  if (token.value) {
    verifyToken(token.value)
  }
})

watch(() => route.params.token, (newVal) => {
  if (newVal) {
    token.value = newVal as string
    inputToken.value = newVal as string
    verifyToken(newVal as string)
  }
})
</script>

<template>
  <PublicLayout>
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <!-- Mode Switcher Tabs (Prestasi vs Dispensasi) -->
      <div class="flex items-center justify-center gap-2 mb-8">
        <router-link
          to="/verify"
          class="px-4 py-2 rounded-xl text-xs font-bold bg-white text-slate-600 hover:text-brand-navy hover:bg-slate-100 border border-slate-200 transition-all flex items-center gap-2"
        >
          <i class="fa-solid fa-trophy text-amber-500"></i>
          <span>Cek QR Prestasi</span>
        </router-link>
        <router-link
          to="/dispensasi/verifikasi"
          class="px-4 py-2 rounded-xl text-xs font-bold bg-brand-navy text-white shadow-xs flex items-center gap-2"
        >
          <i class="fa-solid fa-file-signature text-emerald-400"></i>
          <span>Cek Validasi Dispensasi</span>
        </router-link>
      </div>

      <!-- Page Header -->
      <div class="text-center max-w-xl mx-auto mb-8 space-y-2">
        <div class="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-emerald-50 text-emerald-800 text-xs font-semibold border border-emerald-200">
          <i class="fa-solid fa-shield-check text-emerald-600"></i>
          <span>Verifikasi Surat Dispensasi Belajar (KBM)</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">Cek Keabsahan Dispensasi</h1>
        <p class="text-xs sm:text-sm text-slate-600">
          Pindai QR Code dari surat dispensasi atau masukkan kode token verifikasi / nomor surat untuk memvalidasi izin resmi KBM siswa.
        </p>
      </div>

      <!-- Search Input Box & Cam Scanner Button -->
      <div class="bg-white rounded-2xl p-3 sm:p-4 border border-slate-200/80 shadow-md mb-8 max-w-2xl mx-auto">
        <form @submit.prevent="handleSearch" class="flex items-center gap-2 flex-wrap sm:flex-nowrap">
          <div class="pl-2 text-slate-400">
            <i class="fa-solid fa-file-lines text-lg"></i>
          </div>
          <input
            v-model="inputToken"
            type="text"
            placeholder="Kode token QR atau Nomor Surat dispensasi..."
            class="flex-1 bg-transparent border-none text-xs sm:text-sm font-semibold tracking-wide text-slate-800 placeholder-slate-400 focus:outline-hidden py-2 min-w-[200px]"
          />
          <div class="flex items-center gap-2 w-full sm:w-auto justify-end">
            <!-- Cam Scanner Button -->
            <button
              type="button"
              @click="showScannerModal = true"
              class="px-3.5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-1.5 cursor-pointer shrink-0"
              title="Buka Kamera untuk Scan QR Surat"
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
              <span>Validasi</span>
            </button>
          </div>
        </form>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="bg-white rounded-2xl p-10 text-center shadow-xs border border-slate-200 max-w-xl mx-auto space-y-3">
        <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
        <p class="text-xs text-slate-500 font-medium">Memverifikasi keabsahan dokumen di basis data sekolah...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="errorMsg" class="bg-white rounded-2xl p-8 text-center shadow-xs border border-rose-200 space-y-3 max-w-xl mx-auto">
        <div class="w-12 h-12 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center mx-auto text-xl">
          <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="text-base font-bold text-rose-900">Verifikasi Tidak Ditemukan</h3>
        <p class="text-xs text-slate-600 max-w-sm mx-auto leading-relaxed">{{ errorMsg }}</p>
      </div>

      <!-- Official Verified Certificate Result -->
      <div v-else-if="verificationResult" class="bg-white rounded-2xl shadow-lg border border-slate-200 overflow-hidden max-w-2xl mx-auto">
        <!-- Verification Banner Header -->
        <div
          :class="[
            'p-6 text-center text-white space-y-2',
            verificationResult.is_active_today
              ? 'bg-[#001D60]'
              : (verificationResult.status === 'approved' ? 'bg-slate-700' : 'bg-rose-700')
          ]"
        >
          <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-[11px] font-bold backdrop-blur-xs">
            <i class="fa-solid fa-shield-check text-brand-gold"></i>
            <span>DOKUMEN RESMI TERDATA</span>
          </div>

          <h2 class="text-lg sm:text-xl font-black tracking-tight uppercase">
            {{ verificationResult.school_name }}
          </h2>
          <p class="text-xs text-blue-100/90 font-mono">
            {{ verificationResult.reference_number }}
          </p>

          <div class="pt-2">
            <span
              v-if="verificationResult.is_active_today"
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-black bg-emerald-500 text-white shadow-xs"
            >
              <i class="fa-solid fa-circle-check"></i>
              SAH & BERLAKU AKTIF HARI INI
            </span>
            <span
              v-else-if="verificationResult.period_status === 'completed'"
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-semibold bg-white/20 text-white"
            >
              Masa Berlaku Izin Telah Berakhir
            </span>
            <span
              v-else
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-semibold bg-white/20 text-white"
            >
              Izin Mulai Berlaku: {{ formatDateIndo(verificationResult.start_date) }}
            </span>
          </div>
        </div>

        <!-- Verification Detail Body -->
        <div class="p-6 space-y-5 text-xs">
          <!-- Information Card -->
          <div class="bg-slate-50 rounded-xl p-4 border border-slate-200/80 space-y-2.5">
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold tracking-wider">Nama Kegiatan / Lomba</span>
              <span class="text-sm font-bold text-brand-navy">{{ verificationResult.competition_name }}</span>
            </div>
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold tracking-wider">Tujuan Dispensasi</span>
              <p class="text-slate-700 font-medium leading-relaxed">{{ verificationResult.purpose }}</p>
            </div>
            <div class="grid grid-cols-2 gap-2 pt-2 border-t border-slate-200">
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Periode Tanggal</span>
                <span class="font-bold text-slate-800">{{ formatDateRange(verificationResult.start_date, verificationResult.end_date) }}</span>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Waktu</span>
                <span class="font-bold text-slate-800">{{ verificationResult.is_all_day ? 'Seharian Penuh' : `${verificationResult.start_time} - ${verificationResult.end_time}` }}</span>
              </div>
            </div>
          </div>

          <!-- Custom School Specific Fields (if any) -->
          <div
            v-if="verificationResult.form_schema && verificationResult.form_schema.length > 0 && verificationResult.custom_fields_data && Object.keys(verificationResult.custom_fields_data).length > 0"
            class="bg-blue-50/60 rounded-xl p-4 border border-blue-200/70 space-y-2"
          >
            <span class="text-brand-navy block text-[10px] uppercase font-bold tracking-wider flex items-center gap-1.5">
              <i class="fa-solid fa-sparkles text-brand-gold"></i>
              <span>Rincian Tambahan Khusus {{ verificationResult.school_name }}</span>
            </span>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
              <template v-for="cf in verificationResult.form_schema" :key="cf.id">
                <div v-if="verificationResult.custom_fields_data[cf.name] !== undefined && verificationResult.custom_fields_data[cf.name] !== ''" class="bg-white p-2.5 rounded-lg border border-blue-100">
                  <span class="text-slate-400 block text-[10px] uppercase font-bold">{{ cf.label }}</span>
                  <span class="font-bold text-slate-800">
                    {{ typeof verificationResult.custom_fields_data[cf.name] === 'boolean' ? (verificationResult.custom_fields_data[cf.name] ? 'Ya / Terpenuhi' : 'Tidak') : verificationResult.custom_fields_data[cf.name] }}
                  </span>
                </div>
              </template>
            </div>
          </div>

          <!-- Students List Table -->
          <div>
            <h3 class="text-xs uppercase tracking-wider font-bold text-slate-500 mb-2">
              Siswa Penerima Dispensasi ({{ verificationResult.students?.length ?? 0 }} Orang)
            </h3>
            <div class="border border-slate-200 rounded-lg overflow-hidden">
              <table class="w-full text-left text-xs border-collapse">
                <thead class="bg-slate-100 text-slate-600 font-bold border-b border-slate-200 text-[11px]">
                  <tr>
                    <th class="px-3 py-2 text-center w-8">No</th>
                    <th class="px-3 py-2">Nama Lengkap</th>
                    <th class="px-3 py-2 text-center">Kelas</th>
                    <th class="px-3 py-2 text-center">NIS</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  <tr v-for="(student, idx) in verificationResult.students" :key="student.nis" class="hover:bg-slate-50">
                    <td class="px-3 py-2 text-center text-slate-400">{{ Number(idx) + 1 }}</td>
                    <td class="px-3 py-2 font-bold text-slate-900">{{ student.full_name }}</td>
                    <td class="px-3 py-2 text-center font-medium text-slate-700">{{ student.class_name }}</td>
                    <td class="px-3 py-2 text-center text-slate-500 font-mono">{{ student.nis }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Approval Details Footer -->
          <div class="flex items-center justify-between text-[11px] text-slate-500 pt-3 border-t border-slate-100">
            <div>
              <p>Guru Pembina: <span class="font-semibold text-slate-700">{{ verificationResult.supervisor_name || '-' }}</span></p>
            </div>
            <div class="text-right">
              <p>Disetujui: <span class="font-semibold text-emerald-800">{{ verificationResult.approved_by }}</span></p>
              <p class="text-[10px]">{{ verificationResult.approved_at }}</p>
            </div>
          </div>
        </div>

        <div class="bg-slate-50 px-6 py-3 border-t border-slate-200 text-center">
          <p class="text-[11px] text-slate-500">
            Diverifikasi Resmi oleh <span class="font-bold text-brand-navy">PrestasiKu</span> • Terhubung dengan Basis Data Sekolah
          </p>
        </div>
      </div>

      <!-- QR Camera Scanner Modal -->
      <QrScannerModal
        v-model="showScannerModal"
        title="Scan QR Code Surat Dispensasi"
        subtitle="Arahkan kamera ke kode QR yang tertera pada lembar surat dispensasi"
        @scanned="handleQrScanned"
      />
    </div>
  </PublicLayout>
</template>
