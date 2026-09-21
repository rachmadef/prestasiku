<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import api, { extractList } from '@/services/api'

const router = useRouter()
const competitions = ref<any[]>([])
const loading = ref(true)
const verifyTokenInput = ref('')

async function fetchFeaturedCompetitions() {
  loading.value = true
  try {
    const response = await api.get('/competitions', {
      params: { per_page: 3, status: 'published' },
    })
    competitions.value = extractList(response.data.data)
  } catch (error) {
    console.error('Error fetching competitions:', error)
  } finally {
    loading.value = false
  }
}

function handleVerifySubmit() {
  if (verifyTokenInput.value.trim()) {
    router.push(`/verify-dispensation/${verifyTokenInput.value.trim()}`)
  }
}

function formatDateIndo(dateStr?: string) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

onMounted(() => {
  fetchFeaturedCompetitions()
})
</script>

<template>
  <PublicLayout>
    <!-- Dignified Academic Hero Section (Clean, Iconic, Humanized) -->
    <section class="bg-white border-b border-slate-200 pt-12 pb-16 lg:pt-16 lg:pb-24">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          <!-- Left Column: Purpose & Introduction -->
          <div class="lg:col-span-7 space-y-6 text-left">
            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-200 text-brand-navy text-xs font-bold">
              <span class="w-2 h-2 rounded-full bg-brand-gold"></span>
              <span>Buku Induk Prestasi & Izin Belajar</span>
            </div>

            <h1 class="text-3xl sm:text-4xl lg:text-5xl font-black text-brand-navy tracking-tight leading-[1.18]">
              Jejak Prestasi Terdata.
              <span class="text-brand-blue block mt-1">Izin Belajar Terjaga.</span>
            </h1>

            <p class="text-sm sm:text-base text-slate-600 leading-relaxed max-w-xl">
              Buku induk keikutsertaan lomba dan izin dispensasi KBM digital berbasis QR untuk sekolah modern.
            </p>

            <!-- Action buttons -->
            <div class="pt-2 flex flex-wrap items-center gap-3">
              <router-link
                to="/login"
                class="px-6 py-3 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-colors flex items-center gap-2"
              >
                <i class="fa-solid fa-right-to-bracket text-brand-gold"></i>
                <span>Masuk Portal</span>
              </router-link>
              <router-link
                to="/school-registration"
                class="px-6 py-3 bg-[#F3F1EF] hover:bg-slate-200 text-slate-800 font-bold text-xs rounded-xl border border-slate-300 transition-colors flex items-center gap-2"
              >
                <i class="fa-solid fa-school text-brand-blue"></i>
                <span>Daftarkan Sekolah</span>
              </router-link>
            </div>

            <!-- Quick Verification Input for Teachers / Inspectors -->
            <div class="pt-3 max-w-md">
              <label class="block text-[11px] font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                Validasi Cepat Surat Dispensasi:
              </label>
              <form @submit.prevent="handleVerifySubmit" class="flex items-center gap-2">
                <div class="relative flex-1">
                  <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-slate-400 text-xs">
                    <i class="fa-solid fa-qrcode"></i>
                  </span>
                  <input
                    v-model="verifyTokenInput"
                    type="text"
                    placeholder="Ketik token verifikasi..."
                    class="w-full pl-8 pr-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded-xl focus:outline-hidden focus:border-brand-blue font-mono"
                  />
                </div>
                <button
                  type="submit"
                  class="px-4 py-2 bg-brand-blue hover:bg-[#0c4e85] text-white font-bold text-xs rounded-xl shadow-xs transition-colors shrink-0 cursor-pointer"
                >
                  Periksa
                </button>
              </form>
            </div>
          </div>

          <!-- Right Column: Student Achievement Showcase (Foto Murid Membawa Piala) -->
          <div class="lg:col-span-5">
            <div class="relative rounded-2xl border-2 border-slate-200 bg-white p-2.5 shadow-md">
              <!-- Image Container -->
              <div class="relative rounded-xl overflow-hidden aspect-4/3 bg-slate-100">
                <img
                  src="/img/students-trophy.jpg"
                  alt="Murid Berprestasi Membawa Piala dan Piagam Kejuaraan"
                  class="w-full h-full object-cover"
                />

                <!-- Floating Bottom Card Tag -->
                <div class="absolute inset-x-3 bottom-3 p-3 bg-white/95 backdrop-blur-xs rounded-xl border border-slate-200/90 shadow-sm flex items-center justify-between gap-2">
                  <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-amber-50 text-brand-gold border border-amber-200 flex items-center justify-center text-sm shrink-0">
                      <i class="fa-solid fa-trophy"></i>
                    </div>
                    <div>
                      <p class="text-xs font-black text-brand-navy leading-tight">Portofolio Prestasi Resmi</p>
                      <p class="text-[10px] text-slate-500">Arsip permanen buku induk siswa</p>
                    </div>
                  </div>
                  <span class="px-2 py-0.5 rounded-sm bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold tracking-wider font-mono uppercase shrink-0">
                    Valid
                  </span>
                </div>
              </div>

              <!-- Real Benefits summary footer -->
              <div class="flex items-center justify-between text-[11px] text-slate-600 pt-3 px-2 pb-1">
                <span class="flex items-center gap-1.5 text-brand-navy font-semibold">
                  <i class="fa-solid fa-medal text-brand-gold"></i>
                  Rekam Prestasi
                </span>
                <span class="flex items-center gap-1.5 text-brand-navy font-semibold">
                  <i class="fa-solid fa-file-circle-check text-brand-blue"></i>
                  Dispensasi KBM
                </span>
                <span class="flex items-center gap-1.5 text-brand-navy font-semibold">
                  <i class="fa-solid fa-qrcode text-emerald-600"></i>
                  Scan 1 Detik
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Core Practical Pillars (Kebutuhan Nyata Sekolah Indonesia) -->
    <section class="py-16 bg-[#F3F1EF]">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center max-w-2xl mx-auto mb-12">
          <p class="text-xs uppercase font-black tracking-widest text-brand-blue mb-1">
            Keunggulan Utama
          </p>
          <h2 class="text-2xl sm:text-3xl font-black text-brand-navy">
            Cepat. Rapi. Terverifikasi.
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 mt-2">
            Solusi kesiswaan modern dari persiapan lomba hingga arsip kelulusan.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- Feature 1: Arsip Partisipasi (Menang / Kalah) -->
          <div class="bg-white rounded-2xl border border-slate-200 p-6 flex flex-col justify-between shadow-xs">
            <div class="space-y-3">
              <div class="w-12 h-12 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center text-xl">
                <i class="fa-solid fa-award"></i>
              </div>
              <h3 class="text-base font-bold text-brand-navy">
                100% Partisipasi Terdata
              </h3>
              <p class="text-xs text-slate-600 leading-relaxed">
                Menang maupun kalah, seluruh ikhtiar lomba tersimpan aman sebagai rekam jejak resmi dan portofolio siswa.
              </p>
            </div>
            <div class="pt-4 border-t border-slate-100 mt-4 text-[11px] font-semibold text-amber-800 flex items-center gap-1.5">
              <i class="fa-solid fa-check text-brand-gold"></i>
              <span>Juara, Finalis, & Peserta</span>
            </div>
          </div>

          <!-- Feature 2: Dispensasi KBM Digital -->
          <div class="bg-white rounded-2xl border border-slate-200 p-6 flex flex-col justify-between shadow-xs">
            <div class="space-y-3">
              <div class="w-12 h-12 rounded-xl bg-blue-50 border border-blue-200 text-brand-blue flex items-center justify-center text-xl">
                <i class="fa-solid fa-file-shield"></i>
              </div>
              <h3 class="text-base font-bold text-brand-navy">
                Dispensasi KBM Digital
              </h3>
              <p class="text-xs text-slate-600 leading-relaxed">
                Surat tugas dinas berkop resmi dan pass izin ponsel terbit instan tanpa ribet cetak kertas.
              </p>
            </div>
            <div class="pt-4 border-t border-slate-100 mt-4 text-[11px] font-semibold text-brand-blue flex items-center gap-1.5">
              <i class="fa-solid fa-check"></i>
              <span>Kop Resmi & Kartu Ponsel</span>
            </div>
          </div>

          <!-- Feature 3: Verifikasi QR Tanpa Ribet -->
          <div class="bg-white rounded-2xl border border-slate-200 p-6 flex flex-col justify-between shadow-xs">
            <div class="space-y-3">
              <div class="w-12 h-12 rounded-xl bg-slate-100 border border-slate-200 text-slate-700 flex items-center justify-center text-xl">
                <i class="fa-solid fa-qrcode"></i>
              </div>
              <h3 class="text-base font-bold text-brand-navy">
                Scan QR Seketika
              </h3>
              <p class="text-xs text-slate-600 leading-relaxed">
                Guru piket cukup scan kamera untuk memvalidasi izin kelas secara transparan tanpa perlu login.
              </p>
            </div>
            <div class="pt-4 border-t border-slate-100 mt-4 text-[11px] font-semibold text-slate-700 flex items-center gap-1.5">
              <i class="fa-solid fa-check text-emerald-600"></i>
              <span>Akses Cepat Tanpa Login</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Institutional Commitment Section (Solid Navy, Gold Hairline, Clean) -->
    <section class="py-16 bg-white border-t border-slate-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-brand-navy rounded-2xl p-8 sm:p-12 text-white border-b-4 border-brand-gold">
          <div class="max-w-2xl space-y-4">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-sm bg-white/10 text-brand-gold text-xs font-bold border border-brand-gold/30 uppercase tracking-wider font-mono">
              Kemitraan Sekolah
            </span>
            <h2 class="text-2xl sm:text-3xl font-black tracking-tight leading-snug">
              Modernkan Kesiswaan Sekolah Anda.
            </h2>
            <p class="text-xs sm:text-sm text-slate-200 leading-relaxed">
              Kelola arsip prestasi dan perizinan dispensasi siswa secara terpusat, cepat, dan transparan.
            </p>
            <div class="pt-2 flex flex-wrap items-center gap-3">
              <router-link
                to="/school-registration"
                class="px-6 py-3 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-colors flex items-center gap-2"
              >
                <span>Daftarkan Sekolah Sekarang</span>
                <i class="fa-solid fa-arrow-right"></i>
              </router-link>
              <router-link
                to="/login"
                class="px-6 py-3 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-colors"
              >
                Masuk Portal
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
