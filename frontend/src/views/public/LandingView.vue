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
    <!-- Dignified Academic Hero Section (Clean, Modern, Solidroad Inspired) -->
    <section class="relative bg-gradient-to-b from-slate-100/80 via-slate-50/40 to-white border-b border-slate-200/80 pt-8 pb-16 lg:pt-12 lg:pb-20 overflow-hidden">
      <!-- Ambient Lighting Glows for Visual Depth & Notch Tab Contrast -->
      <div class="absolute -top-32 left-1/2 -translate-x-1/2 w-[850px] h-[350px] bg-gradient-to-r from-blue-200/40 via-emerald-100/35 to-amber-100/40 blur-3xl pointer-events-none rounded-full"></div>
      <div class="absolute top-24 -left-24 w-80 h-80 bg-blue-100/40 blur-3xl pointer-events-none rounded-full"></div>
      <div class="absolute top-36 -right-24 w-80 h-80 bg-emerald-100/40 blur-3xl pointer-events-none rounded-full"></div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-12 items-center">
          <!-- Left Column: Purpose, Headline & Sleek Quick Validation Input -->
          <div class="lg:col-span-7 space-y-6 text-left">
            <!-- Institutional Pill Badge -->
            <div class="inline-flex items-center gap-2.5 px-4 py-1.5 rounded-full bg-white/90 border border-slate-200/90 shadow-2xs text-slate-800 text-xs font-semibold backdrop-blur-xs">
              <span class="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></span>
              <span class="text-slate-700 font-medium">Buku Prestasi Resmi &bull;</span>
              <span class="font-bold text-slate-900">MA Unggulan K.H. Abd. Wahab Hasbulloh</span>
            </div>

            <!-- Modern Bold Academic Headline -->
            <h1 class="text-3xl sm:text-4xl lg:text-[46px] font-black text-slate-900 tracking-tight leading-[1.15]">
              Jejak Prestasi Terdata.
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-700 via-brand-blue to-emerald-600 block mt-1">
                Izin Belajar Terjaga.
              </span>
            </h1>

            <p class="text-sm sm:text-base text-slate-600 leading-relaxed max-w-xl">
              Platform terpadu buku induk rekam keikutsertaan kompetisi siswa dan penerbitan surat izin dispensasi KBM digital resmi madrasah berbasis verifikasi QR Code.
            </p>

            <!-- Action Pill Buttons (Aligned with Solidroad Green Pill Style) -->
            <div class="pt-1 flex flex-wrap items-center gap-3">
              <router-link
                to="/login"
                class="px-6 py-3 bg-[#10b981] hover:bg-[#059669] text-white font-bold text-xs sm:text-[13px] rounded-full shadow-sm hover:shadow-md transition-all flex items-center gap-2 group cursor-pointer"
              >
                <i class="fa-solid fa-right-to-bracket text-xs"></i>
                <span>Masuk Portal Akses</span>
                <i class="fa-solid fa-arrow-right text-[10px] group-hover:translate-x-0.5 transition-transform"></i>
              </router-link>

              <router-link
                to="/competitions"
                class="px-5 py-3 bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs sm:text-[13px] rounded-full border border-slate-200/90 shadow-2xs hover:shadow-xs transition-all flex items-center gap-2"
              >
                <i class="fa-solid fa-trophy text-amber-500 text-xs"></i>
                <span>Katalog Kompetisi</span>
              </router-link>

              <router-link
                to="/verify"
                class="px-4 py-3 text-slate-600 hover:text-slate-900 font-bold text-xs sm:text-[13px] flex items-center gap-1.5 transition-colors"
              >
                <i class="fa-solid fa-qrcode text-emerald-600 text-xs"></i>
                <span>Scan Cek QR</span>
              </router-link>
            </div>

            <!-- Unified Quick Validation Search Pill Bar (Solidroad Pill Search Style) -->
            <div class="pt-2 max-w-lg">
              <form @submit.prevent="handleVerifySubmit" class="p-1.5 bg-white border border-slate-200/90 rounded-full shadow-sm hover:shadow-md transition-all flex items-center gap-2 focus-within:border-emerald-500 focus-within:ring-2 focus-within:ring-emerald-500/20">
                <div class="pl-4 flex items-center text-emerald-600">
                  <i class="fa-solid fa-qrcode text-sm"></i>
                </div>
                <input
                  v-model="verifyTokenInput"
                  type="text"
                  placeholder="Validasi cepat: ketik token verifikasi / nomor surat..."
                  class="w-full bg-transparent border-none text-xs sm:text-[13px] font-medium text-slate-800 placeholder-slate-400 focus:outline-hidden py-1.5"
                />
                <button
                  type="submit"
                  class="px-5 py-2.5 bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs rounded-full shadow-xs transition-all flex items-center gap-1.5 shrink-0 cursor-pointer"
                >
                  <span>Periksa</span>
                  <i class="fa-solid fa-arrow-right text-[9px]"></i>
                </button>
              </form>
              <div class="flex items-center gap-2 text-[11px] text-slate-400 mt-2 pl-4">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                <span>Verifikasi instan keaslian sertifikat & izin dispensasi resmi tanpa login</span>
              </div>
            </div>

            <!-- Real-Time Statistics Counter Cards (Clean, Cohesive, Modern) -->
            <div class="pt-5 border-t border-slate-200/60 mt-4">
              <div class="grid grid-cols-3 gap-3">
                <!-- Stat 1: Siswa -->
                <div class="p-3.5 sm:p-4 bg-white/90 backdrop-blur-xs border border-slate-200/80 rounded-2xl text-left shadow-2xs hover:shadow-xs transition-shadow">
                  <div class="flex items-center gap-1.5 text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                    <i class="fa-solid fa-user-graduate text-blue-600"></i>
                    <span>Siswa Terdata</span>
                  </div>
                  <div class="text-xl sm:text-2xl font-black text-slate-900">
                    <span v-if="statsLoading" class="inline-block w-12 h-6 bg-slate-200 animate-pulse rounded-md"></span>
                    <span v-else>{{ stats.total_students.toLocaleString('id-ID') }}</span>
                  </div>
                  <div class="text-[10px] text-slate-400 mt-0.5 font-medium">Buku Induk Digital</div>
                </div>

                <!-- Stat 2: Prestasi -->
                <div class="p-3.5 sm:p-4 bg-white/90 backdrop-blur-xs border border-slate-200/80 rounded-2xl text-left shadow-2xs hover:shadow-xs transition-shadow">
                  <div class="flex items-center gap-1.5 text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                    <i class="fa-solid fa-trophy text-amber-500"></i>
                    <span>Rekam Prestasi</span>
                  </div>
                  <div class="text-xl sm:text-2xl font-black text-slate-900">
                    <span v-if="statsLoading" class="inline-block w-12 h-6 bg-slate-200 animate-pulse rounded-md"></span>
                    <span v-else>{{ stats.total_achievements.toLocaleString('id-ID') }}</span>
                  </div>
                  <div class="text-[10px] text-slate-400 mt-0.5 font-medium">Juara & Finalis</div>
                </div>

                <!-- Stat 3: Kompetisi -->
                <div class="p-3.5 sm:p-4 bg-white/90 backdrop-blur-xs border border-slate-200/80 rounded-2xl text-left shadow-2xs hover:shadow-xs transition-shadow">
                  <div class="flex items-center gap-1.5 text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                    <i class="fa-solid fa-compass text-emerald-600"></i>
                    <span>Katalog Lomba</span>
                  </div>
                  <div class="text-xl sm:text-2xl font-black text-slate-900">
                    <span v-if="statsLoading" class="inline-block w-12 h-6 bg-slate-200 animate-pulse rounded-md"></span>
                    <span v-else>{{ stats.total_competitions.toLocaleString('id-ID') }}</span>
                  </div>
                  <div class="text-[10px] text-slate-400 mt-0.5 font-medium">Kompetisi Resmi</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column: Student Achievement Showcase (Slide Foto Juara) -->
          <div class="lg:col-span-5">
            <div
              class="relative rounded-[26px] border border-slate-200/90 bg-white p-2.5 shadow-[0_20px_50px_-12px_rgba(0,0,0,0.12)] group transition-all"
              @mouseenter="stopAutoplay"
              @mouseleave="sliders.length > 1 && startAutoplay()"
            >
              <!-- 1. Skeleton Loading State while fetching slider API -->
              <div v-if="sliderLoading" class="relative rounded-2xl overflow-hidden aspect-4/3 bg-slate-100 animate-pulse flex items-center justify-center">
                <div class="text-center p-4">
                  <i class="fa-solid fa-trophy text-3xl text-brand-gold/40 mb-2 animate-bounce"></i>
                  <p class="text-xs font-bold text-slate-400">Memuat Foto Juara...</p>
                </div>
              </div>

              <!-- 2. Dynamic Carousel when sliders loaded and length > 0 -->
              <div v-else-if="sliders.length > 0" class="relative rounded-2xl overflow-hidden aspect-4/3 bg-slate-100">
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
                    <div class="absolute inset-0 bg-gradient-to-t from-slate-950/85 via-slate-900/25 to-transparent"></div>

                    <!-- Slide Info Card Overlay (Sleek Glassmorphism) -->
                    <div class="absolute inset-x-3 bottom-3 p-3 sm:p-3.5 bg-white/95 backdrop-blur-md rounded-2xl border border-white/60 shadow-lg flex items-center justify-between gap-3">
                      <div class="flex items-center gap-2.5 min-w-0 flex-1">
                        <div class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 border border-amber-200/80 flex items-center justify-center text-sm shrink-0 shadow-2xs">
                          <i class="fa-solid fa-trophy"></i>
                        </div>
                        <div class="min-w-0 flex-1 text-left">
                          <p class="text-xs font-bold text-slate-900 leading-snug line-clamp-1" :title="slide.title">
                            {{ slide.title }}
                          </p>
                          <p v-if="slide.student_name" class="text-[11px] font-semibold text-blue-600 truncate mt-0.5">
                            <i class="fa-solid fa-user-graduate text-[9px] mr-1"></i> {{ slide.student_name }}
                          </p>
                          <p v-else-if="slide.caption" class="text-[10px] text-slate-500 truncate mt-0.5">
                            {{ slide.caption }}
                          </p>
                        </div>
                      </div>
                      <span class="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold tracking-wider uppercase shrink-0">
                        Juara
                      </span>
                    </div>
                  </div>
                </transition-group>

                <!-- Prev & Next Controls -->
                <template v-if="sliders.length > 1">
                  <button
                    @click="prevSlide"
                    class="absolute left-2.5 top-1/2 -translate-y-1/2 w-8 h-8 rounded-full bg-slate-900/60 hover:bg-slate-900 text-white flex items-center justify-center text-xs backdrop-blur-xs shadow-md transition-all opacity-80 group-hover:opacity-100 cursor-pointer z-10"
                    title="Sebelumnya"
                  >
                    <i class="fa-solid fa-chevron-left"></i>
                  </button>
                  <button
                    @click="nextSlide"
                    class="absolute right-2.5 top-1/2 -translate-y-1/2 w-8 h-8 rounded-full bg-slate-900/60 hover:bg-slate-900 text-white flex items-center justify-center text-xs backdrop-blur-xs shadow-md transition-all opacity-80 group-hover:opacity-100 cursor-pointer z-10"
                    title="Berikutnya"
                  >
                    <i class="fa-solid fa-chevron-right"></i>
                  </button>

                  <!-- Dot Indicators -->
                  <div class="absolute top-3 right-3 z-10 flex items-center gap-1.5 bg-slate-900/60 backdrop-blur-xs px-2.5 py-1 rounded-full border border-white/20">
                    <button
                      v-for="(_, index) in sliders"
                      :key="index"
                      @click="goToSlide(index)"
                      :class="[
                        'h-1.5 rounded-full transition-all duration-300 cursor-pointer',
                        currentSlide === index ? 'w-5 bg-amber-400' : 'w-1.5 bg-white/60 hover:bg-white'
                      ]"
                    ></button>
                  </div>
                </template>
              </div>

              <!-- 3. Fallback Default Showcase Image -->
              <div v-else class="relative rounded-2xl overflow-hidden aspect-4/3 bg-slate-100">
                <img
                  src="/img/students-trophy.jpg"
                  alt="Murid Berprestasi Membawa Piala"
                  class="w-full h-full object-cover"
                />
                <div class="absolute inset-x-3 bottom-3 p-3 bg-white/95 backdrop-blur-xs rounded-2xl border border-slate-200/90 shadow-sm flex items-center justify-between gap-2">
                  <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-amber-50 text-brand-gold border border-amber-200 flex items-center justify-center text-sm shrink-0">
                      <i class="fa-solid fa-trophy"></i>
                    </div>
                    <div>
                      <p class="text-xs font-black text-slate-900 leading-tight">Portofolio Prestasi Resmi</p>
                      <p class="text-[10px] text-slate-500">Arsip permanen buku induk siswa</p>
                    </div>
                  </div>
                  <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold tracking-wider uppercase shrink-0">
                    Valid
                  </span>
                </div>
              </div>

              <!-- Micro Feature Badges Under Photo Slider -->
              <div class="grid grid-cols-3 gap-2 pt-3 px-1">
                <div class="flex items-center justify-center gap-1.5 py-2 px-2 rounded-xl bg-slate-50/80 border border-slate-200/60 text-[11px] font-bold text-slate-700">
                  <i class="fa-solid fa-trophy text-amber-500 text-xs"></i>
                  <span class="truncate">Rekam Prestasi</span>
                </div>
                <div class="flex items-center justify-center gap-1.5 py-2 px-2 rounded-xl bg-slate-50/80 border border-slate-200/60 text-[11px] font-bold text-slate-700">
                  <i class="fa-solid fa-file-shield text-blue-600 text-xs"></i>
                  <span class="truncate">Dispensasi KBM</span>
                </div>
                <div class="flex items-center justify-center gap-1.5 py-2 px-2 rounded-xl bg-slate-50/80 border border-slate-200/60 text-[11px] font-bold text-slate-700">
                  <i class="fa-solid fa-qrcode text-emerald-600 text-xs"></i>
                  <span class="truncate">Scan QR 1 Detik</span>
                </div>
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
