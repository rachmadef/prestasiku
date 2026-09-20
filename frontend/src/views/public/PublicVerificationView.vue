<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import Badge from '@/components/common/Badge.vue'
import api from '@/services/api'

const route = useRoute()
const router = useRouter()

const inputPublicId = ref((route.params.public_id as string) || (route.query.id as string) || '')
const verificationData = ref<any>(null)
const loading = ref(false)
const error = ref<string | null>(null)
const qrUrl = ref<string | null>(null)

async function verifyAchievement(publicId: string) {
  if (!publicId.trim()) return
  loading.value = true
  error.value = null
  verificationData.value = null
  qrUrl.value = null

  try {
    const cleanId = publicId.trim().toUpperCase()
    const response = await api.get(`/verify/${cleanId}`)
    verificationData.value = response.data.data
    qrUrl.value = `/api/v1/verify/${cleanId}/qr`
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Prestasi tidak ditemukan atau kode verifikasi tidak valid.'
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  if (inputPublicId.value.trim()) {
    router.push(`/verify/${inputPublicId.value.trim().toUpperCase()}`)
    verifyAchievement(inputPublicId.value.trim())
  }
}

function formatDate(dateStr: string) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
}

onMounted(() => {
  if (inputPublicId.value) {
    verifyAchievement(inputPublicId.value)
  }
})

watch(() => route.params.public_id, (newVal) => {
  if (newVal) {
    inputPublicId.value = newVal as string
    verifyAchievement(newVal as string)
  }
})
</script>

<template>
  <PublicLayout>
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Page Header -->
      <div class="text-center max-w-xl mx-auto mb-10 space-y-2">
        <div class="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-blue-50 text-brand-blue text-xs font-semibold border border-blue-200">
          <i class="fa-solid fa-qrcode text-brand-gold"></i>
          <span>Portal Verifikasi Publik</span>
        </div>
        <h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">Verifikasi Keaslian Prestasi</h1>
        <p class="text-xs sm:text-sm text-slate-600">
          Masukkan kode ID Publik sertifikat (format: PKU-2026-XXXXXX) untuk memeriksa keabsahan dan keaslian data penghargaan pelajar.
        </p>
      </div>

      <!-- Search Input Box -->
      <div class="bg-white rounded-2xl p-3 sm:p-4 border border-slate-200/80 shadow-md mb-10">
        <form @submit.prevent="handleSearch" class="flex items-center gap-2">
          <div class="pl-3 text-slate-400">
            <i class="fa-solid fa-barcode text-lg"></i>
          </div>
          <input
            v-model="inputPublicId"
            type="text"
            placeholder="Contoh: PKU-2026-000001"
            class="flex-1 uppercase bg-transparent border-none text-sm font-semibold tracking-wider text-slate-800 placeholder-slate-400 focus:outline-hidden py-2"
          />
          <button
            type="submit"
            :disabled="loading"
            class="px-6 py-2.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 shrink-0"
          >
            <i v-if="loading" class="fa-solid fa-spinner fa-spin"></i>
            <i v-else class="fa-solid fa-magnifying-glass"></i>
            <span>Verifikasi</span>
          </button>
        </form>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="bg-white rounded-3xl p-8 border border-slate-200 text-center animate-pulse space-y-4">
        <div class="w-16 h-16 rounded-full bg-slate-200 mx-auto"></div>
        <div class="h-5 bg-slate-200 rounded-md w-1/3 mx-auto"></div>
        <div class="h-4 bg-slate-100 rounded-md w-1/2 mx-auto"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-white rounded-3xl p-8 border border-rose-100 shadow-sm text-center space-y-3">
        <div class="w-14 h-14 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center text-2xl mx-auto">
          <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="text-base font-bold text-slate-800">Prestasi Tidak Ditemukan</h3>
        <p class="text-xs text-slate-500 max-w-md mx-auto">{{ error }}</p>
      </div>

      <!-- Verified Certificate Presentation Card -->
      <div
        v-else-if="verificationData"
        class="bg-white rounded-3xl border-2 border-emerald-500/30 shadow-xl overflow-hidden relative"
      >
        <!-- Top Verified Banner -->
        <div class="bg-gradient-to-r from-emerald-600 to-teal-700 text-white px-6 py-4 flex items-center justify-between">
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
            {{ verificationData.public_id }}
          </span>
        </div>

        <!-- Certificate Body -->
        <div class="p-6 sm:p-8 space-y-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-8 items-center">
            <!-- Left 2 Cols: Details -->
            <div class="md:col-span-2 space-y-4">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Nama Penerima / Siswa</p>
                <h2 class="text-2xl font-black text-slate-900 mt-0.5 flex items-center gap-2">
                  <span>{{ verificationData.student_name }}</span>
                  <span v-if="verificationData.is_profile_private" class="text-[10px] font-semibold text-slate-400 bg-slate-100 px-2 py-0.5 rounded-md" title="Nama disamarkan untuk perlindungan privasi">
                    <i class="fa-solid fa-user-shield text-slate-400"></i> Disamarkan
                  </span>
                </h2>
              </div>

              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Asal Instansi Sekolah</p>
                <p class="text-base font-bold text-slate-800 flex items-center gap-1.5 mt-0.5">
                  <i class="fa-solid fa-school text-brand-navy"></i>
                  {{ verificationData.school_name }}
                </p>
              </div>

              <div class="grid grid-cols-2 gap-4 pt-2">
                <div>
                  <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Nama Kompetisi</p>
                  <p class="text-xs font-bold text-slate-800 mt-0.5">{{ verificationData.competition_name }}</p>
                </div>
                <div>
                  <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Peringkat / Capaian</p>
                  <p class="text-xs font-extrabold text-amber-600 flex items-center gap-1 mt-0.5">
                    <i class="fa-solid fa-trophy text-brand-gold"></i>
                    {{ verificationData.rank || 'Juara' }}
                  </p>
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4 pt-2 border-t border-slate-100">
                <div>
                  <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tanggal Terverifikasi</p>
                  <p class="text-xs font-medium text-slate-700 mt-0.5">{{ formatDate(verificationData.verified_at) }}</p>
                </div>
                <div>
                  <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tingkat Wilayah</p>
                  <p class="text-xs font-medium text-slate-700 capitalize mt-0.5">{{ verificationData.scope || 'Nasional' }}</p>
                </div>
              </div>
            </div>

            <!-- Right Col: QR Code Display -->
            <div class="text-center flex flex-col items-center justify-center p-5 bg-slate-50 rounded-2xl border border-slate-200/80">
              <div class="w-36 h-36 bg-white p-2 rounded-xl shadow-xs border border-slate-200 flex items-center justify-center">
                <img
                  v-if="qrUrl"
                  :src="qrUrl"
                  alt="QR Verification"
                  class="w-full h-full object-contain"
                  @error="(e: any) => e.target.style.display = 'none'"
                />
                <i v-else class="fa-solid fa-qrcode text-6xl text-slate-700"></i>
              </div>
              <p class="text-[10px] font-mono font-bold text-slate-600 mt-2">{{ verificationData.public_id }}</p>
              <p class="text-[9px] text-slate-400 mt-0.5">Pindai untuk memvalidasi secara instan</p>
            </div>
          </div>

          <!-- Privacy notice footer inside card -->
          <div class="p-4 rounded-xl bg-blue-50/70 border border-blue-100 flex items-start gap-2.5 text-xs text-brand-blue">
            <i class="fa-solid fa-shield-halved text-base mt-0.5"></i>
            <div>
              <span class="font-bold">Standar Perlindungan Privasi PrestasiKu:</span>
              <span class="text-slate-600 ml-1">
                Data NIS/NISN, nomor kontak, serta dokumen identitas diri siswa dienkripsi dan tidak dipublikasikan ke publik sesuai prinsip Privacy-by-Default.
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Instruction info if empty search -->
      <div v-else class="text-center py-8 text-slate-400 text-xs">
        <p>Silakan masukkan kode ID Publik yang tertera pada sertifikat/piagam penghargaan untuk memulai pemeriksaan.</p>
      </div>
    </div>
  </PublicLayout>
</template>
