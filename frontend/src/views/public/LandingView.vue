<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import Badge from '@/components/common/Badge.vue'
import api, { extractList } from '@/services/api'

const router = useRouter()
const competitions = ref<any[]>([])
const loading = ref(true)
const searchQuery = ref('')

async function fetchFeaturedCompetitions() {
  loading.value = true
  try {
    const response = await api.get('/competitions', {
      params: { per_page: 6, status: 'published' },
    })
    competitions.value = extractList(response.data.data)
  } catch (error) {
    console.error('Error fetching competitions:', error)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  if (searchQuery.value.trim()) {
    router.push({ path: '/competitions', query: { q: searchQuery.value.trim() } })
  } else {
    router.push('/competitions')
  }
}

function formatDate(dateStr: string) {
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
    <!-- Hero Section -->
    <section class="relative overflow-hidden pt-12 pb-20 lg:pt-20 lg:pb-28 bg-gradient-to-b from-white via-[#F3F1EF]/60 to-[#F3F1EF]">
      <!-- Background decorative glow -->
      <div class="absolute -top-24 -right-24 w-96 h-96 bg-[#1062A7]/10 rounded-full blur-3xl pointer-events-none"></div>
      <div class="absolute top-1/2 -left-24 w-80 h-80 bg-[#F8B700]/10 rounded-full blur-3xl pointer-events-none"></div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="text-center max-w-3xl mx-auto space-y-6">
          <!-- Tag Badge -->
          <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-50 border border-blue-200/80 text-brand-blue text-xs font-semibold shadow-2xs">
            <i class="fa-solid fa-trophy text-brand-gold"></i>
            <span>Platform Resmi Prestasi Pelajar SLTP & SLTA</span>
          </div>

          <!-- Headline -->
          <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-slate-900 tracking-tight leading-[1.15]">
            Temukan Lomba Resmi, Raih Juara, dan Buktikan dengan
            <span class="text-transparent bg-clip-text bg-gradient-to-r from-brand-navy via-brand-blue to-brand-gold">
              QR Terverifikasi
            </span>
          </h1>

          <!-- Subheadline -->
          <p class="text-base sm:text-lg text-slate-600 leading-relaxed">
            PrestasiKu menghubungkan pelajar, sekolah, dan penyelenggara dalam satu ekosistem: database kompetisi resmi terverifikasi, eligibility checker otomatis, dan portofolio prestasi dengan privasi terjamin.
          </p>

          <!-- Search Bar -->
          <form @submit.prevent="handleSearch" class="pt-2 max-w-xl mx-auto">
            <div class="flex items-center p-1.5 bg-white rounded-2xl shadow-lg border border-slate-200/80 transition-all focus-within:border-brand-blue focus-within:ring-3 focus-within:ring-brand-blue/10">
              <div class="pl-3.5 pr-2 text-slate-400">
                <i class="fa-solid fa-magnifying-glass"></i>
              </div>
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Cari kompetisi sains, robotika, seni, debat, dsb..."
                class="flex-1 bg-transparent border-none text-sm text-slate-800 placeholder-slate-400 focus:outline-hidden py-2"
              />
              <button
                type="submit"
                class="px-5 py-2.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-1.5"
              >
                <span>Cari</span>
                <i class="fa-solid fa-arrow-right text-[11px]"></i>
              </button>
            </div>
          </form>

          <!-- Stat Highlights -->
          <div class="pt-8 flex flex-wrap items-center justify-center gap-6 sm:gap-10 text-xs font-semibold text-slate-500">
            <div class="flex items-center gap-2">
              <i class="fa-solid fa-shield-check text-emerald-600 text-sm"></i>
              <span>100% Sumber Resmi Terverifikasi</span>
            </div>
            <div class="flex items-center gap-2">
              <i class="fa-solid fa-user-lock text-brand-blue text-sm"></i>
              <span>Privacy-by-Default untuk Pelajar</span>
            </div>
            <div class="flex items-center gap-2">
              <i class="fa-solid fa-school text-brand-gold text-sm"></i>
              <span>Multi-Tenant Siap Sekolah</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 4 Pillars Section -->
    <section class="py-16 bg-white border-y border-slate-100">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center max-w-2xl mx-auto mb-12">
          <p class="text-xs uppercase font-bold tracking-wider text-brand-blue mb-1">Keunggulan Sistem</p>
          <h2 class="text-2xl sm:text-3xl font-extrabold text-slate-900">Mengapa Memilih PrestasiKu?</h2>
          <p class="text-sm text-slate-600 mt-2">Didesain khusus untuk kebutuhan operasional sekolah dan masa depan prestasi siswa.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <!-- Pillar 1 -->
          <div class="p-6 rounded-2xl bg-brand-surface/70 border border-slate-200/70 card-hover">
            <div class="w-12 h-12 rounded-xl bg-blue-100/70 text-brand-blue flex items-center justify-center text-xl mb-4">
              <i class="fa-solid fa-certificate"></i>
            </div>
            <h3 class="text-base font-bold text-slate-900 mb-2">Verified Database</h3>
            <p class="text-xs text-slate-600 leading-relaxed">
              Semua info lomba divalidasi sumber resminya oleh Super Admin sebelum dipublikasikan demi menghindari penipuan.
            </p>
          </div>

          <!-- Pillar 2 -->
          <div class="p-6 rounded-2xl bg-brand-surface/70 border border-slate-200/70 card-hover">
            <div class="w-12 h-12 rounded-xl bg-amber-100/70 text-amber-700 flex items-center justify-center text-xl mb-4">
              <i class="fa-solid fa-robot"></i>
            </div>
            <h3 class="text-base font-bold text-slate-900 mb-2">Eligibility Engine</h3>
            <p class="text-xs text-slate-600 leading-relaxed">
              Pengecekan otomatis jenjang SLTP/SLTA, tingkatan kelas, batasan umur, dan domisili dalam hitungan detik.
            </p>
          </div>

          <!-- Pillar 3 -->
          <div class="p-6 rounded-2xl bg-brand-surface/70 border border-slate-200/70 card-hover">
            <div class="w-12 h-12 rounded-xl bg-purple-100/70 text-purple-700 flex items-center justify-center text-xl mb-4">
              <i class="fa-solid fa-shield-halved"></i>
            </div>
            <h3 class="text-base font-bold text-slate-900 mb-2">Privacy-by-Default</h3>
            <p class="text-xs text-slate-600 leading-relaxed">
              Data pribadi dan NIS/NISN siswa terlindungi. Hanya prestasi dengan izin opt-in yang dapat diakses publik.
            </p>
          </div>

          <!-- Pillar 4 -->
          <div class="p-6 rounded-2xl bg-brand-surface/70 border border-slate-200/70 card-hover">
            <div class="w-12 h-12 rounded-xl bg-emerald-100/70 text-emerald-700 flex items-center justify-center text-xl mb-4">
              <i class="fa-solid fa-qrcode"></i>
            </div>
            <h3 class="text-base font-bold text-slate-900 mb-2">Verifikasi QR Publik</h3>
            <p class="text-xs text-slate-600 leading-relaxed">
              Sertifikat dan piagam ber-ID publik unik (PKU-2026-XXXXXX) yang mudah dipindai oleh pihak kampus atau dinas.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Featured Competitions Section -->
    <section class="py-16 bg-[#F3F1EF]">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col sm:flex-row sm:items-end justify-between mb-10 gap-4">
          <div>
            <p class="text-xs uppercase font-bold tracking-wider text-brand-blue mb-1">Eksplorasi Kompetisi</p>
            <h2 class="text-2xl sm:text-3xl font-extrabold text-slate-900">Kompetisi Pilihan Terbaru</h2>
            <p class="text-sm text-slate-600 mt-1">Kompetisi resmi tingkat provinsi dan nasional yang sedang membuka pendaftaran.</p>
          </div>
          <router-link
            to="/competitions"
            class="inline-flex items-center gap-2 text-xs font-bold text-brand-navy hover:text-brand-blue transition-colors self-start sm:self-auto"
          >
            <span>Lihat Semua Kompetisi</span>
            <i class="fa-solid fa-arrow-right"></i>
          </router-link>
        </div>

        <!-- Loading Skeleton -->
        <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="i in 3" :key="i" class="bg-white rounded-2xl p-6 border border-slate-200 animate-pulse space-y-4">
            <div class="h-4 bg-slate-200 rounded-md w-1/3"></div>
            <div class="h-6 bg-slate-200 rounded-md w-3/4"></div>
            <div class="h-16 bg-slate-100 rounded-md"></div>
          </div>
        </div>

        <!-- Competitions Grid -->
        <div v-else-if="competitions.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="comp in competitions"
            :key="comp.id"
            class="bg-white rounded-2xl p-6 border border-slate-200/80 card-hover flex flex-col justify-between shadow-2xs"
          >
            <div>
              <!-- Top tags -->
              <div class="flex items-center justify-between gap-2 mb-3">
                <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-md">
                  <i class="fa-solid fa-tag text-[9px]"></i>
                  {{ comp.category?.name || 'Kompetisi' }}
                </span>
                <Badge :status="comp.verification_status || 'verified'" />
              </div>

              <!-- Title -->
              <h3 class="text-base font-bold text-slate-900 leading-snug line-clamp-2 hover:text-brand-blue transition-colors">
                <router-link :to="`/competitions/${comp.slug || comp.id}`">
                  {{ comp.name || comp.title }}
                </router-link>
              </h3>

              <!-- Organizer & Scope -->
              <p class="text-xs text-slate-500 mt-2 flex items-center gap-1.5">
                <i class="fa-solid fa-building-columns text-[10px] text-slate-400"></i>
                <span>{{ comp.organizer?.name || 'Penyelenggara Resmi' }}</span>
              </p>

              <!-- Description -->
              <p class="text-xs text-slate-600 mt-3 line-clamp-3 leading-relaxed">
                {{ comp.description || 'Kompetisi resmi bagi pelajar berprestasi tingkat nasional.' }}
              </p>
            </div>

            <!-- Card Bottom Meta & Button -->
            <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between">
              <div class="text-[11px] text-slate-500">
                <p class="font-medium text-slate-700 flex items-center gap-1">
                  <i class="fa-regular fa-calendar-check text-brand-gold"></i>
                  Batas: {{ formatDate(comp.registration_deadline) }}
                </p>
                <p class="text-[10px] uppercase text-slate-400">{{ comp.scope || 'Nasional' }} • {{ comp.educational_level?.toUpperCase() || 'SLTA' }}</p>
              </div>

              <router-link
                :to="`/competitions/${comp.slug || comp.id}`"
                class="px-3.5 py-1.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl transition-all shadow-xs"
              >
                Detail
              </router-link>
            </div>
          </div>
        </div>

        <!-- Empty state -->
        <div v-else class="text-center py-12 bg-white rounded-2xl border border-slate-200">
          <i class="fa-solid fa-trophy text-4xl text-slate-300 mb-3"></i>
          <h3 class="text-base font-bold text-slate-700">Belum Ada Kompetisi Dipublikasikan</h3>
          <p class="text-xs text-slate-500 mt-1">Silakan kunjungi kembali nanti untuk pembaruan jadwal lomba.</p>
        </div>
      </div>
    </section>

    <!-- School Registration CTA Section -->
    <section class="py-16 bg-white border-t border-slate-100">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-gradient-to-r from-brand-navy via-[#0A2E7A] to-brand-blue rounded-3xl p-8 sm:p-12 text-white relative overflow-hidden shadow-xl">
          <div class="absolute right-0 bottom-0 opacity-10 translate-x-12 translate-y-12 pointer-events-none">
            <i class="fa-solid fa-trophy text-[300px]"></i>
          </div>

          <div class="relative z-10 max-w-2xl space-y-4">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-brand-gold/20 text-brand-gold text-xs font-bold border border-brand-gold/30">
              <i class="fa-solid fa-school"></i>
              Portal Instansi Sekolah
            </span>
            <h2 class="text-2xl sm:text-4xl font-extrabold tracking-tight">
              Daftarkan Sekolah Anda, Kelola Prestasi Siswa Lebih Efisien
            </h2>
            <p class="text-sm text-slate-200 leading-relaxed">
              Bergabunglah dengan ekosistem PrestasiKu. Nikmati kemudahan pengelolaan delegasi lomba, penerbitan surat tugas, pelacakan histori pendaftaran, serta pengarsipan prestasi otomatis dengan QR digital.
            </p>
            <div class="pt-3 flex flex-wrap items-center gap-3">
              <router-link
                to="/school-registration"
                class="px-6 py-3 bg-brand-gold hover:bg-amber-400 text-brand-navy font-extrabold text-xs rounded-xl shadow-md transition-all flex items-center gap-2"
              >
                <span>Ajukan Registrasi Sekolah</span>
                <i class="fa-solid fa-arrow-right"></i>
              </router-link>
              <router-link
                to="/login"
                class="px-5 py-3 bg-white/10 hover:bg-white/20 text-white font-bold text-xs rounded-xl border border-white/20 transition-colors"
              >
                Masuk Akun Sekolah
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
