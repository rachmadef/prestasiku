<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import api, { extractList } from '@/services/api'

const router = useRouter()
const competitions = ref<any[]>([])
const loading = ref(true)
const verifyTokenInput = ref('')

// Hero Sliders state
const sliders = ref<any[]>([])
const currentSlide = ref(0)
const sliderLoading = ref(true)
let autoplayTimer: any = null

// Public Stats state
const stats = ref<{
  total_students: number
  total_achievements: number
  total_competitions: number
}>({
  total_students: 0,
  total_achievements: 0,
  total_competitions: 0,
})
const statsLoading = ref(true)

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

async function fetchPublicStats() {
  statsLoading.value = true
  try {
    const response = await api.get('/public-stats')
    if (response.data?.data) {
      stats.value = response.data.data
    }
  } catch (error) {
    console.error('Error fetching public stats:', error)
  } finally {
    statsLoading.value = false
  }
}

async function fetchHeroSliders() {
  sliderLoading.value = true
  try {
    const response = await api.get('/hero-sliders')
    sliders.value = response.data.data || []
    if (sliders.value.length > 1) {
      startAutoplay()
    }
  } catch (error) {
    console.error('Error fetching hero sliders:', error)
  } finally {
    sliderLoading.value = false
  }
}

function nextSlide() {
  if (sliders.value.length === 0) return
  currentSlide.value = (currentSlide.value + 1) % sliders.value.length
}

function prevSlide() {
  if (sliders.value.length === 0) return
  currentSlide.value = (currentSlide.value - 1 + sliders.value.length) % sliders.value.length
}

function goToSlide(index: number) {
  currentSlide.value = index
}

function startAutoplay() {
  stopAutoplay()
  autoplayTimer = setInterval(() => {
    nextSlide()
  }, 5000)
}

function stopAutoplay() {
  if (autoplayTimer) {
    clearInterval(autoplayTimer)
    autoplayTimer = null
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
  fetchHeroSliders()
  fetchPublicStats()
})

onUnmounted(() => {
  stopAutoplay()
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
            <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-50 border border-blue-200 text-brand-navy text-xs font-bold">
              <span class="w-2 h-2 rounded-full bg-brand-gold"></span>
              <span>Buku Prestasi — MA Unggulan K.H. Abd. Wahab Hasbulloh</span>
            </div>

            <h1 class="text-3xl sm:text-4xl lg:text-5xl font-black text-brand-navy tracking-tight leading-[1.18]">
              Jejak Prestasi Terdata.
              <span class="text-brand-blue block mt-1">Izin Belajar Terjaga.</span>
            </h1>

            <p class="text-sm sm:text-base text-slate-600 leading-relaxed max-w-xl">
              Buku induk keikutsertaan lomba dan izin dispensasi KBM digital berbasis QR resmi MA Unggulan K.H. Abd. Wahab Hasbulloh.
            </p>

            <!-- Action buttons -->
            <div class="pt-2 flex flex-wrap items-center gap-3">
              <router-link
                to="/login"
                class="px-6 py-3 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-colors flex items-center gap-2"
              >
                <i class="fa-solid fa-right-to-bracket text-brand-gold"></i>
                <span>Masuk Portal Akses</span>
              </router-link>
              <router-link
                to="/competitions"
                class="px-6 py-3 bg-[#F3F1EF] hover:bg-slate-200 text-slate-800 font-bold text-xs rounded-xl border border-slate-300 transition-colors flex items-center gap-2"
              >
                <i class="fa-solid fa-trophy text-brand-blue"></i>
                <span>Katalog Kompetisi</span>
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

            <!-- Real-Time Statistics Counter Cards -->
            <div class="pt-5 border-t border-slate-100 mt-5">
              <div class="grid grid-cols-3 gap-3">
                <div class="p-3 bg-slate-50 border border-slate-200/90 rounded-xl text-left shadow-2xs">
                  <div class="flex items-center gap-1.5 text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                    <i class="fa-solid fa-user-graduate text-brand-navy"></i>
                    <span>Siswa Terdata</span>
                  </div>
                  <div class="text-xl sm:text-2xl font-black text-brand-navy">
                    <span v-if="statsLoading" class="inline-block w-12 h-6 bg-slate-200 animate-pulse rounded-md"></span>
                    <span v-else>{{ stats.total_students.toLocaleString('id-ID') }}</span>
                  </div>
                  <div class="text-[10px] text-slate-500 mt-0.5 font-medium">Buku Induk Digital</div>
                </div>

                <div class="p-3 bg-amber-50/70 border border-amber-200/90 rounded-xl text-left shadow-2xs">
                  <div class="flex items-center gap-1.5 text-amber-800 text-[10px] font-bold uppercase tracking-wider mb-1">
                    <i class="fa-solid fa-trophy text-brand-gold"></i>
                    <span>Rekam Prestasi</span>
                  </div>
                  <div class="text-xl sm:text-2xl font-black text-brand-navy">
                    <span v-if="statsLoading" class="inline-block w-12 h-6 bg-amber-200/50 animate-pulse rounded-md"></span>
                    <span v-else>{{ stats.total_achievements.toLocaleString('id-ID') }}</span>
                  </div>
                  <div class="text-[10px] text-amber-800/80 mt-0.5 font-medium">Juara & Finalis</div>
                </div>

                <div class="p-3 bg-blue-50/70 border border-blue-200/90 rounded-xl text-left shadow-2xs">
                  <div class="flex items-center gap-1.5 text-brand-blue text-[10px] font-bold uppercase tracking-wider mb-1">
                    <i class="fa-solid fa-compass text-brand-blue"></i>
                    <span>Katalog Lomba</span>
                  </div>
                  <div class="text-xl sm:text-2xl font-black text-brand-navy">
                    <span v-if="statsLoading" class="inline-block w-12 h-6 bg-blue-200/50 animate-pulse rounded-md"></span>
                    <span v-else>{{ stats.total_competitions.toLocaleString('id-ID') }}</span>
                  </div>
                  <div class="text-[10px] text-brand-blue/80 mt-0.5 font-medium">Kompetisi Resmi</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column: Student Achievement Showcase (Slide Foto Juara) -->
          <div class="lg:col-span-5">
            <div
              class="relative rounded-2xl border-2 border-slate-200 bg-white p-2.5 shadow-md group"
              @mouseenter="stopAutoplay"
              @mouseleave="sliders.length > 1 && startAutoplay()"
            >
              <!-- 1. Skeleton Loading State while fetching slider API -->
              <div v-if="sliderLoading" class="relative rounded-xl overflow-hidden aspect-4/3 bg-slate-100 animate-pulse flex items-center justify-center">
                <div class="text-center p-4">
                  <i class="fa-solid fa-trophy text-3xl text-brand-gold/40 mb-2 animate-bounce"></i>
                  <p class="text-xs font-bold text-slate-400">Memuat Foto Juara...</p>
                </div>
              </div>

              <!-- 2. Dynamic Carousel when sliders loaded and length > 0 -->
              <div v-else-if="sliders.length > 0" class="relative rounded-xl overflow-hidden aspect-4/3 bg-slate-100">
                <transition-group name="fade-slider">
                  <div
                    v-for="(slide, idx) in sliders"
                    :key="slide.id"
                    v-show="currentSlide === idx"
                    class="absolute inset-0 w-full h-full"
                  >
                    <img
                      :src="slide.image_url"
                      :alt="slide.title"
                      class="w-full h-full object-cover"
                    />

                    <!-- Overlay Gradient -->
                    <div class="absolute inset-0 bg-linear-to-t from-slate-950/80 via-slate-900/20 to-transparent"></div>

                    <!-- Slide Info Card Overlay -->
                    <div class="absolute inset-x-3 bottom-3 p-3 bg-white/95 backdrop-blur-md rounded-xl border border-slate-200/90 shadow-lg flex items-center justify-between gap-3">
                      <div class="flex items-center gap-2.5 min-w-0 flex-1">
                        <div class="w-9 h-9 rounded-lg bg-amber-50 text-brand-gold border border-amber-200 flex items-center justify-center text-base shrink-0 shadow-xs">
                          <i class="fa-solid fa-trophy"></i>
                        </div>
                        <div class="min-w-0 flex-1">
                          <p class="text-xs font-black text-brand-navy leading-tight truncate">
                            {{ slide.title }}
                          </p>
                          <p v-if="slide.student_name" class="text-[11px] font-semibold text-brand-blue truncate mt-0.5">
                            <i class="fa-solid fa-user-graduate text-[9px] mr-1"></i> {{ slide.student_name }}
                          </p>
                          <p v-else-if="slide.caption" class="text-[10px] text-slate-500 truncate mt-0.5">
                            {{ slide.caption }}
                          </p>
                        </div>
                      </div>
                      <span class="px-2 py-1 rounded-md bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold tracking-wider uppercase shrink-0">
                        Prestasi Juara
                      </span>
                    </div>
                  </div>
                </transition-group>

                <!-- Prev & Next Controls -->
                <template v-if="sliders.length > 1">
                  <button
                    @click="prevSlide"
                    class="absolute left-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-full bg-slate-900/60 hover:bg-brand-navy text-white flex items-center justify-center text-xs backdrop-blur-xs shadow-md transition-all opacity-80 group-hover:opacity-100 cursor-pointer z-10"
                    title="Sebelumnya"
                  >
                    <i class="fa-solid fa-chevron-left"></i>
                  </button>
                  <button
                    @click="nextSlide"
                    class="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-full bg-slate-900/60 hover:bg-brand-navy text-white flex items-center justify-center text-xs backdrop-blur-xs shadow-md transition-all opacity-80 group-hover:opacity-100 cursor-pointer z-10"
                    title="Berikutnya"
                  >
                    <i class="fa-solid fa-chevron-right"></i>
                  </button>

                  <!-- Dot Indicators -->
                  <div class="absolute top-3 right-3 z-10 flex items-center gap-1.5 bg-slate-900/50 backdrop-blur-xs px-2 py-1 rounded-full border border-white/20">
                    <button
                      v-for="(_, index) in sliders"
                      :key="index"
                      @click="goToSlide(index)"
                      :class="[
                        'h-1.5 rounded-full transition-all duration-300 cursor-pointer',
                        currentSlide === index ? 'w-5 bg-brand-gold' : 'w-1.5 bg-white/60 hover:bg-white'
                      ]"
                    ></button>
                  </div>
                </template>
              </div>

              <!-- 3. Fallback Default Showcase Image (Hanya tampil jika database slider kosong setelah API selesai memuat) -->
              <div v-else class="relative rounded-xl overflow-hidden aspect-4/3 bg-slate-100">
                <img
                  src="/img/students-trophy.jpg"
                  alt="Murid Berprestasi Membawa Piala"
                  class="w-full h-full object-cover"
                />
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
              MA Unggulan K.H. Abd. Wahab Hasbulloh
            </span>
            <h2 class="text-2xl sm:text-3xl font-black tracking-tight leading-snug">
              Digitalisasi Kesiswaan & Prestasi Peserta Didik.
            </h2>
            <p class="text-xs sm:text-sm text-slate-200 leading-relaxed">
              Kelola arsip prestasi dan perizinan dispensasi KBM siswa MA Unggulan K.H. Abd. Wahab Hasbulloh secara terpusat, cepat, dan transparan.
            </p>
            <div class="pt-2 flex flex-wrap items-center gap-3">
              <router-link
                to="/login"
                class="px-6 py-3 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-colors flex items-center gap-2"
              >
                <span>Masuk ke Portal System</span>
                <i class="fa-solid fa-arrow-right"></i>
              </router-link>
              <router-link
                to="/competitions"
                class="px-6 py-3 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-colors"
              >
                Lihat Katalog Lomba
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>

<style scoped>
.fade-slider-enter-active,
.fade-slider-leave-active {
  transition: opacity 0.8s cubic-bezier(0.4, 0, 0.2, 1), transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-slider-enter-from {
  opacity: 0;
  transform: scale(1.04);
}

.fade-slider-leave-to {
  opacity: 0;
  transform: scale(0.96);
}

.fade-slider-leave-active {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}
</style>
