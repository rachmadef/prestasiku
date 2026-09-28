<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const competition = ref<any>(null)
const loading = ref(true)
const error = ref<string | null>(null)

// Eligibility check state
const checkingEligibility = ref(false)
const eligibilityResult = ref<any>(null)
const showRegisterModal = ref(false)
const formAnswers = ref<Record<string, any>>({})
const submittingForm = ref(false)
const submitSuccess = ref(false)
const submitError = ref<string | null>(null)

// Gemini AI Live Audit & Verification state
const verifyingAI = ref(false)
const aiVerifySummary = ref<string | null>(null)

async function verifyWithAI() {
  if (!competition.value) return
  verifyingAI.value = true
  aiVerifySummary.value = null
  try {
    const res = await api.post(`/competitions/${competition.value.id}/ai-verify`)
    if (res.data?.success) {
      competition.value = res.data.data
      aiVerifySummary.value = res.data.ai_summary || 'Informasi & link pendaftaran/juknis telah berhasil diverifikasi ulang oleh Gemini AI.'
    }
  } catch (err: any) {
    console.error('AI verification failed:', err)
  } finally {
    verifyingAI.value = false
  }
}

async function fetchCompetitionDetail() {
  loading.value = true
  error.value = null
  try {
    const slug = route.params.slug
    const response = await api.get(`/competitions/${slug}`)
    competition.value = response.data.data
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Kompetisi tidak ditemukan.'
  } finally {
    loading.value = false
  }
}

async function checkStudentEligibility() {
  if (!competition.value) return
  checkingEligibility.value = true
  eligibilityResult.value = null
  try {
    const response = await api.get(`/competitions/${competition.value.id}/eligibility`)
    eligibilityResult.value = response.data
    if (response.data.eligible) {
      showRegisterModal.value = true
    }
  } catch (err: any) {
    eligibilityResult.value = {
      eligible: false,
      message: err.response?.data?.message || 'Gagal mengecek kelayakan.',
    }
  } finally {
    checkingEligibility.value = false
  }
}

async function submitRegistration() {
  if (!competition.value) return
  submittingForm.value = true
  submitError.value = null
  try {
    const payload = {
      competition_id: competition.value.id,
      answers: formAnswers.value,
    }
    await api.post('/student/registrations', payload)
    submitSuccess.value = true
    setTimeout(() => {
      showRegisterModal.value = false
      router.push('/student/registrations')
    }, 2000)
  } catch (err: any) {
    submitError.value = err.response?.data?.message || 'Gagal mengirimkan pendaftaran.'
  } finally {
    submittingForm.value = false
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

const registrationLink = computed(() => {
  return competition.value?.registration_url || competition.value?.official_website_url || competition.value?.official_url || null
})

function getSourceBadge(type: string) {
  switch (type) {
    case 'puspresnas':
      return { label: 'Portal Puspresnas', icon: 'fa-solid fa-landmark', color: 'bg-indigo-50 text-indigo-700 border-indigo-200' }
    case 'official_website':
      return { label: 'Website Resmi Penyelenggara', icon: 'fa-solid fa-globe', color: 'bg-blue-50 text-blue-700 border-blue-200' }
    case 'circular_letter':
      return { label: 'Buku Pedoman & Juknis', icon: 'fa-solid fa-file-lines', color: 'bg-emerald-50 text-emerald-700 border-emerald-200' }
    case 'news_portal':
      return { label: 'Siaran Pers / Berita', icon: 'fa-solid fa-newspaper', color: 'bg-amber-50 text-amber-700 border-amber-200' }
    case 'instagram':
      return { label: 'Media Sosial Resmi', icon: 'fa-brands fa-instagram', color: 'bg-pink-50 text-pink-700 border-pink-200' }
    default:
      return { label: 'Tautan Referensi', icon: 'fa-solid fa-link', color: 'bg-slate-50 text-slate-700 border-slate-200' }
  }
}

function getCurationBadge(type: string) {
  switch (type) {
    case 'resmi_negara':
      return {
        label: 'Resmi Negara',
        icon: 'fa-solid fa-shield-halved',
        color: 'bg-blue-50 text-blue-700 border-blue-200',
        desc: 'Ajang resmi berjenjang yang digelar pemerintah dan terkurasi Puspresnas Kemendikdasmen RI.',
      }
    case 'terkurasi_puspresnas':
      return {
        label: 'Terkurasi Puspresnas',
        icon: 'fa-solid fa-circle-check',
        color: 'bg-amber-50 text-amber-800 border-amber-200',
        desc: 'Telah lolos verifikasi Kurasi Prestasi Puspresnas melalui Sistem Informasi Manajemen Talenta (SIMT).',
      }
    case 'bergengsi_non_kurasi':
      return {
        label: 'Bergengsi Non-Terkurasi',
        icon: 'fa-solid fa-star',
        color: 'bg-purple-50 text-purple-700 border-purple-200',
        desc: 'Ajang bergengsi independen tingkat nasional. Sangat berguna untuk pengalaman kompetitif dan portofolio prestasi.',
      }
    default:
      return {
        label: 'Resmi Negara',
        icon: 'fa-solid fa-shield-halved',
        color: 'bg-blue-50 text-blue-700 border-blue-200',
        desc: 'Ajang resmi berjenjang yang digelar pemerintah dan terkurasi Puspresnas.',
      }
  }
}

onMounted(() => {
  fetchCompetitionDetail()
})
</script>

<template>
  <PublicLayout>
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <!-- Back Link -->
      <router-link
        to="/competitions"
        class="inline-flex items-center gap-2 text-xs font-semibold text-slate-500 hover:text-brand-navy mb-6 transition-colors"
      >
        <i class="fa-solid fa-arrow-left"></i>
        <span>Kembali ke Katalog Kompetisi</span>
      </router-link>

      <!-- Loading State -->
      <div v-if="loading" class="bg-white rounded-3xl p-8 border border-slate-200 animate-pulse space-y-6">
        <div class="h-8 bg-slate-200 rounded-md w-1/2"></div>
        <div class="h-4 bg-slate-100 rounded-md w-1/4"></div>
        <div class="h-32 bg-slate-100 rounded-md"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-rose-50 border border-rose-200 rounded-3xl p-8 text-center text-rose-800">
        <i class="fa-solid fa-triangle-exclamation text-3xl mb-2 text-rose-600"></i>
        <h2 class="text-base font-bold">{{ error }}</h2>
        <router-link to="/competitions" class="inline-block mt-4 text-xs font-bold underline">
          Kembali ke Katalog
        </router-link>
      </div>

      <!-- Content -->
      <div v-else-if="competition" class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Main Column (2 cols) -->
        <div class="lg:col-span-2 space-y-8">
          <!-- Main Card -->
          <div class="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-2xs space-y-6">
            <div class="flex flex-wrap items-center gap-2">
              <span class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-blue bg-blue-50 px-3 py-1 rounded-full">
                <i class="fa-solid fa-tag text-[10px]"></i>
                {{ competition.category?.name || 'Kompetisi' }}
              </span>

              <!-- Curation Tier Badge -->
              <span
                class="inline-flex items-center gap-1.5 text-xs font-bold px-3 py-1 rounded-full border shadow-2xs"
                :class="getCurationBadge(competition.curation_type || 'resmi_negara').color"
              >
                <i :class="getCurationBadge(competition.curation_type || 'resmi_negara').icon" class="text-[10px]"></i>
                <span>{{ getCurationBadge(competition.curation_type || 'resmi_negara').label }}</span>
                <span v-if="competition.curation_rating" class="ml-1 px-1.5 py-0.2 bg-white/80 rounded-md text-[10px] font-bold">
                  {{ competition.curation_rating }}
                </span>
              </span>

              <Badge :status="competition.verification_status || 'verified'" size="md" />
              <span class="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-600 bg-slate-100 px-3 py-1 rounded-full uppercase">
                {{ competition.level || competition.scope || 'Nasional' }}
              </span>
            </div>

            <h1 class="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight leading-snug">
              {{ competition.title || competition.name }}
            </h1>

            <!-- Curation Callout Banner -->
            <div
              class="p-4 rounded-2xl border flex items-start gap-3 text-xs leading-relaxed"
              :class="getCurationBadge(competition.curation_type || 'resmi_negara').color"
            >
              <div class="text-base mt-0.5 shrink-0">
                <i :class="getCurationBadge(competition.curation_type || 'resmi_negara').icon"></i>
              </div>
              <div class="space-y-0.5">
                <p class="font-bold">
                  Tingkat Kepercayaan: {{ getCurationBadge(competition.curation_type || 'resmi_negara').label }}
                  <span v-if="competition.curation_number" class="ml-1 text-[11px] font-normal opacity-90">
                    ({{ competition.curation_number }})
                  </span>
                </p>
                <p class="opacity-90">
                  {{ getCurationBadge(competition.curation_type || 'resmi_negara').desc }}
                </p>
              </div>
            </div>

            <div class="flex flex-wrap items-center gap-y-2 gap-x-6 text-xs text-slate-500 pt-2 border-t border-slate-100">
              <div class="flex items-center gap-2">
                <i class="fa-solid fa-building-columns text-slate-400"></i>
                <span class="font-medium text-slate-700">{{ competition.organizer?.name || 'Penyelenggara Resmi' }}</span>
              </div>
              <div class="flex items-center gap-2">
                <i class="fa-solid fa-users text-slate-400"></i>
                <span class="font-medium text-slate-700 capitalize">
                  Tipe Partisipasi: {{ competition.participation_type || 'Individu' }}
                </span>
              </div>
            </div>

            <!-- Description & Summary -->
            <div class="space-y-3">
              <div class="flex items-center justify-between gap-2">
                <h2 class="text-sm font-bold uppercase tracking-wider text-slate-400">
                  Rangkuman & Deskripsi Kompetisi
                </h2>
                <span class="inline-flex items-center gap-1.5 text-[11px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-full border border-blue-100">
                  <i class="fa-solid fa-layer-group text-[10px]"></i>
                  <span>Disintesis dari Sumber Resmi</span>
                </span>
              </div>
              <div class="text-sm text-slate-700 leading-relaxed space-y-3 whitespace-pre-line bg-slate-50/60 p-5 rounded-2xl border border-slate-200/60">
                {{ competition.description }}
              </div>
            </div>

            <!-- Quick Document & Portal Links Bar -->
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2">
              <a
                v-if="registrationLink"
                :href="registrationLink"
                target="_blank"
                rel="noopener noreferrer"
                class="flex items-center gap-3 p-3.5 rounded-2xl bg-blue-50/80 hover:bg-blue-100/90 border border-blue-200/80 text-brand-blue transition-all group shadow-2xs"
              >
                <div class="w-9 h-9 rounded-xl bg-brand-blue text-white flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform">
                  <i class="fa-solid fa-paper-plane text-xs"></i>
                </div>
                <div class="min-w-0">
                  <p class="text-[10px] font-bold uppercase tracking-wider text-brand-blue/70">Pendaftaran</p>
                  <p class="text-xs font-bold text-slate-900 truncate flex items-center gap-1">
                    <span>Link Pendaftaran</span>
                    <i class="fa-solid fa-arrow-up-right-from-square text-[9px] text-slate-400"></i>
                  </p>
                </div>
              </a>

              <a
                v-if="competition.guide_book_url"
                :href="competition.guide_book_url"
                target="_blank"
                rel="noopener noreferrer"
                class="flex items-center gap-3 p-3.5 rounded-2xl bg-emerald-50/80 hover:bg-emerald-100/90 border border-emerald-200/80 text-emerald-800 transition-all group shadow-2xs"
              >
                <div class="w-9 h-9 rounded-xl bg-emerald-600 text-white flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform">
                  <i class="fa-solid fa-file-pdf text-xs"></i>
                </div>
                <div class="min-w-0">
                  <p class="text-[10px] font-bold uppercase tracking-wider text-emerald-700/80">Panduan Teknis</p>
                  <p class="text-xs font-bold text-slate-900 truncate flex items-center gap-1">
                    <span>Buku Juknis PDF</span>
                    <i class="fa-solid fa-arrow-up-right-from-square text-[9px] text-slate-400"></i>
                  </p>
                </div>
              </a>

              <a
                v-if="competition.official_website_url || competition.official_url"
                :href="competition.official_website_url || competition.official_url"
                target="_blank"
                rel="noopener noreferrer"
                class="flex items-center gap-3 p-3.5 rounded-2xl bg-purple-50/80 hover:bg-purple-100/90 border border-purple-200/80 text-purple-800 transition-all group shadow-2xs"
              >
                <div class="w-9 h-9 rounded-xl bg-purple-600 text-white flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform">
                  <i class="fa-solid fa-globe text-xs"></i>
                </div>
                <div class="min-w-0">
                  <p class="text-[10px] font-bold uppercase tracking-wider text-purple-700/80">Penyelenggara</p>
                  <p class="text-xs font-bold text-slate-900 truncate flex items-center gap-1">
                    <span>Website Resmi</span>
                    <i class="fa-solid fa-arrow-up-right-from-square text-[9px] text-slate-400"></i>
                  </p>
                </div>
              </a>
            </div>
          </div>

          <!-- Gemini AI Live Audit & Verification Card -->
          <div class="bg-gradient-to-r from-slate-900 to-indigo-950 rounded-3xl p-6 sm:p-7 text-white border border-slate-800 shadow-sm space-y-4">
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-2xl bg-brand-gold/20 text-brand-gold flex items-center justify-center text-lg shrink-0 border border-brand-gold/30">
                  <i class="fa-solid fa-wand-magic-sparkles"></i>
                </div>
                <div>
                  <h3 class="text-sm sm:text-base font-extrabold text-white flex items-center gap-2">
                    <span>Audit & Verifikasi Real-time Gemini AI</span>
                    <span class="text-[10px] font-bold text-emerald-400 bg-emerald-500/20 px-2 py-0.5 rounded-md border border-emerald-500/30">
                      Live Grounded
                    </span>
                  </h3>
                  <p class="text-xs text-slate-300 mt-0.5">
                    Memastikan link pendaftaran, juknis, dan jadwal lomba sesuai dengan info resmi terkini.
                  </p>
                </div>
              </div>

              <button
                type="button"
                @click="verifyWithAI"
                :disabled="verifyingAI"
                class="px-4 py-2.5 bg-brand-gold hover:bg-amber-400 text-slate-950 font-extrabold text-xs rounded-xl transition-all shadow-sm shrink-0 flex items-center gap-2 cursor-pointer disabled:opacity-50"
              >
                <i v-if="verifyingAI" class="fa-solid fa-spinner fa-spin"></i>
                <i v-else class="fa-solid fa-rotate text-xs"></i>
                <span>{{ verifyingAI ? 'Memproses Audit AI...' : 'Verifikasi Ulang via Gemini AI' }}</span>
              </button>
            </div>

            <!-- AI Summary Alert Box -->
            <div v-if="aiVerifySummary" class="p-4 rounded-2xl bg-emerald-950/60 border border-emerald-500/40 text-emerald-200 text-xs leading-relaxed flex items-start gap-2.5">
              <i class="fa-solid fa-circle-check text-emerald-400 text-sm mt-0.5 shrink-0"></i>
              <div>
                <p class="font-bold text-white mb-0.5">Hasil Audit AI Terkini:</p>
                <p>{{ aiVerifySummary }}</p>
              </div>
            </div>
            <div v-else-if="competition.verification_notes" class="p-3.5 rounded-2xl bg-slate-800/60 border border-slate-700/60 text-slate-300 text-xs leading-relaxed flex items-start gap-2">
              <i class="fa-solid fa-circle-info text-brand-gold text-xs mt-0.5 shrink-0"></i>
              <p>{{ competition.verification_notes }}</p>
            </div>
          </div>

          <!-- Multi-Source Verification & Reference Section -->
          <div class="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-2xs space-y-5">
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-4 border-b border-slate-100">
              <div>
                <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                  <i class="fa-solid fa-shield-halved text-emerald-600"></i>
                  Kurasi & Rangkuman Multi-Sumber Terverifikasi
                </h2>
                <p class="text-xs text-slate-500 mt-0.5">
                  Informasi kompetisi ini dirangkum dari beberapa portal website resmi penyelenggara yang telah diaudit keabsahannya oleh tim PrestasiKu.
                </p>
              </div>
              <span class="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 px-3 py-1 rounded-full border border-emerald-200/60 shrink-0">
                <i class="fa-solid fa-circle-check text-emerald-600"></i>
                Sumber Asli Sah
              </span>
            </div>

            <!-- List of sources -->
            <div v-if="competition.sources && competition.sources.length > 0" class="space-y-3">
              <div
                v-for="(src, idx) in competition.sources"
                :key="src.id || idx"
                class="p-4 rounded-2xl border border-slate-200/80 hover:border-brand-blue/50 bg-slate-50/40 hover:bg-white transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-4 group shadow-2xs"
              >
                <div class="space-y-1.5 flex-1">
                  <div class="flex items-center gap-2 flex-wrap">
                    <span
                      class="inline-flex items-center gap-1.5 text-[11px] font-bold px-2.5 py-0.5 rounded-lg border"
                      :class="getSourceBadge(src.source_type).color"
                    >
                      <i :class="getSourceBadge(src.source_type).icon"></i>
                      {{ getSourceBadge(src.source_type).label }}
                    </span>
                    <span class="text-[10px] text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-md font-semibold flex items-center gap-1 border border-emerald-100">
                      <i class="fa-solid fa-check text-[9px]"></i> Valid
                    </span>
                  </div>

                  <h3 class="text-xs sm:text-sm font-bold text-slate-900 group-hover:text-brand-blue transition-colors">
                    {{ src.source_title || 'Tautan Referensi Resmi Lomba' }}
                  </h3>

                  <p v-if="src.notes" class="text-xs text-slate-600 leading-relaxed">
                    {{ src.notes }}
                  </p>
                </div>

                <a
                  :href="src.source_url"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="inline-flex items-center justify-center gap-2 px-3.5 py-2 rounded-xl text-xs font-bold text-brand-navy bg-white hover:bg-brand-navy hover:text-white border border-slate-200 hover:border-brand-navy transition-all shrink-0 shadow-2xs"
                >
                  <span>Buka Sumber</span>
                  <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
                </a>
              </div>
            </div>

            <!-- Fallback if no sources in array -->
            <div v-else class="p-4 rounded-2xl bg-slate-50 border border-slate-100 text-xs text-slate-600 flex items-center justify-between">
              <span>Informasi disintesis dari portal resmi penyelenggara. Dokumen dan tautan resmi aman diakses.</span>
              <a
                v-if="competition.official_website_url || competition.official_url"
                :href="competition.official_website_url || competition.official_url"
                target="_blank"
                rel="noopener noreferrer"
                class="font-bold text-brand-navy hover:underline inline-flex items-center gap-1"
              >
                <span>Kunjungi Website Resmi</span>
                <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
              </a>
            </div>
          </div>

          <!-- Eligibility Details -->
          <div class="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-2xs space-y-4">
            <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
              <i class="fa-solid fa-list-check text-brand-blue"></i>
              Ketentuan Kelayakan (Eligibility Engine)
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div class="p-4 rounded-2xl bg-slate-50 border border-slate-100">
                <p class="text-slate-400 font-medium mb-1">Tingkat Pendidikan</p>
                <p class="font-bold text-slate-800 uppercase">{{ competition.target_level || competition.educational_level || 'SLTA' }}</p>
              </div>
              <div class="p-4 rounded-2xl bg-slate-50 border border-slate-100">
                <p class="text-slate-400 font-medium mb-1">Rekomendasi Sekolah</p>
                <p class="font-bold text-slate-800">
                  {{ competition.requires_school_approval ? 'Wajib Disetujui Sekolah' : 'Pendaftaran Langsung Siswa' }}
                </p>
              </div>
              <div v-if="competition.eligibility?.min_age || competition.eligibility?.max_age" class="p-4 rounded-2xl bg-slate-50 border border-slate-100">
                <p class="text-slate-400 font-medium mb-1">Batasan Umur</p>
                <p class="font-bold text-slate-800">
                  {{ competition.eligibility.min_age || '12' }} - {{ competition.eligibility.max_age || '19' }} Tahun
                </p>
              </div>
              <div v-if="competition.eligibility?.allowed_grades" class="p-4 rounded-2xl bg-slate-50 border border-slate-100">
                <p class="text-slate-400 font-medium mb-1">Tingkat Kelas Diizinkan</p>
                <p class="font-bold text-slate-800">
                  Kelas {{ competition.eligibility.allowed_grades.join(', ') }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Sidebar Column (1 col) -->
        <div class="space-y-6">
          <!-- Action & Timeline Card -->
          <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs space-y-6 sticky top-24">
            <h2 class="text-sm font-bold uppercase tracking-wider text-slate-400">Jadwal & Aksi</h2>

            <!-- Timeline -->
            <div class="space-y-4 text-xs">
              <div class="flex items-start gap-3">
                <div class="w-8 h-8 rounded-lg bg-blue-50 text-brand-blue flex items-center justify-center shrink-0">
                  <i class="fa-regular fa-calendar-plus"></i>
                </div>
                <div>
                  <p class="text-slate-400">Pendaftaran Dibuka</p>
                  <p class="font-bold text-slate-800">{{ formatDate(competition.registration_open_at) }}</p>
                </div>
              </div>

              <div class="flex items-start gap-3">
                <div class="w-8 h-8 rounded-lg bg-amber-50 text-amber-700 flex items-center justify-center shrink-0">
                  <i class="fa-regular fa-calendar-xmark"></i>
                </div>
                <div>
                  <p class="text-slate-400">Batas Akhir Pendaftaran</p>
                  <p class="font-bold text-slate-800">{{ formatDate(competition.registration_deadline) }}</p>
                </div>
              </div>

              <div class="flex items-start gap-3">
                <div class="w-8 h-8 rounded-lg bg-purple-50 text-purple-700 flex items-center justify-center shrink-0">
                  <i class="fa-regular fa-flag"></i>
                </div>
                <div>
                  <p class="text-slate-400">Pelaksanaan Lomba</p>
                  <p class="font-bold text-slate-800">
                    {{ formatDate(competition.event_start_at) }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="pt-4 border-t border-slate-100 space-y-3">
              <!-- Direct Official Registration Link (Link Pendaftaran Lomba) -->
              <div v-if="registrationLink">
                <a
                  :href="registrationLink"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="w-full py-3.5 px-4 bg-gradient-to-r from-brand-blue to-[#0050a0] hover:from-[#0050a0] hover:to-brand-blue text-white font-extrabold text-xs rounded-xl shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2.5 group"
                >
                  <i class="fa-solid fa-arrow-up-right-from-square text-brand-gold group-hover:scale-110 transition-transform"></i>
                  <span>Link Pendaftaran Lomba</span>
                </a>
                <p class="text-[11px] text-center text-slate-500 mt-1.5 flex items-center justify-center gap-1">
                  <i class="fa-solid fa-circle-check text-[10px] text-emerald-600"></i>
                  <span>Tautan registrasi resmi penyelenggara</span>
                </p>
              </div>

              <!-- Divider for PrestasiKu Internal Services -->
              <div class="relative py-1.5 flex items-center justify-center">
                <div class="absolute inset-0 flex items-center">
                  <div class="w-full border-t border-slate-200"></div>
                </div>
                <span class="relative bg-white px-2.5 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                  Atau via PrestasiKu
                </span>
              </div>

              <!-- If Student -->
              <template v-if="authStore.isStudent">
                <button
                  type="button"
                  @click="checkStudentEligibility"
                  :disabled="checkingEligibility"
                  class="w-full py-3 px-4 bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center justify-center gap-2"
                >
                  <i v-if="checkingEligibility" class="fa-solid fa-spinner fa-spin"></i>
                  <i v-else class="fa-solid fa-circle-check text-brand-gold"></i>
                  <span>Daftar Internal (Rekomendasi Sekolah)</span>
                </button>

                <!-- Eligibility alert message -->
                <div
                  v-if="eligibilityResult && !eligibilityResult.eligible"
                  class="p-3 bg-rose-50 border border-rose-200 rounded-xl text-xs text-rose-800"
                >
                  <p class="font-bold flex items-center gap-1 mb-1">
                    <i class="fa-solid fa-circle-xmark"></i>
                    Belum Memenuhi Syarat
                  </p>
                  <p>{{ eligibilityResult.message || 'Profil Anda tidak memenuhi kriteria lomba ini.' }}</p>
                </div>
              </template>

              <!-- If School Admin -->
              <template v-else-if="authStore.isSchoolAdmin">
                <router-link
                  to="/school/registrations"
                  class="w-full py-3 px-4 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center justify-center gap-2"
                >
                  <i class="fa-solid fa-school-flag text-brand-gold"></i>
                  <span>Daftarkan Delegasi Siswa</span>
                </router-link>
              </template>

              <!-- If Not Authenticated -->
              <template v-else>
                <router-link
                  to="/login"
                  class="w-full py-3 px-4 bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs rounded-xl shadow-xs transition-all flex items-center justify-center gap-2"
                >
                  <i class="fa-solid fa-arrow-right-to-bracket text-brand-gold"></i>
                  <span>Masuk untuk Rekomendasi Sekolah</span>
                </router-link>
                <p class="text-[11px] text-center text-slate-400">
                  Untuk delegasi resmi & permohonan surat izin KBM.
                </p>
              </template>
            </div>
          </div>
        </div>
      </div>

      <!-- Dynamic Form Application Modal for Student -->
      <Modal
        v-model="showRegisterModal"
        title="Form Pendaftaran Kompetisi"
        :subtitle="competition?.title || competition?.name"
        size="lg"
      >
        <div v-if="submitSuccess" class="py-8 text-center space-y-3">
          <div class="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-3xl mx-auto">
            <i class="fa-solid fa-check"></i>
          </div>
          <h3 class="text-base font-bold text-slate-900">Pendaftaran Berhasil Dikirimkan!</h3>
          <p class="text-xs text-slate-600">
            Pendaftaran Anda sedang diproses. Anda akan dialihkan ke halaman pelacakan status pendaftaran...
          </p>
        </div>

        <form v-else @submit.prevent="submitRegistration" class="space-y-4">
          <div class="p-4 bg-blue-50 border border-blue-200 rounded-2xl text-xs text-brand-blue flex items-center gap-3">
            <i class="fa-solid fa-circle-info text-base"></i>
            <div>
              <p class="font-bold">Kelayakan Terverifikasi</p>
              <p class="text-slate-600 mt-0.5">
                Jenjang dan profil Anda cocok untuk kompetisi ini. Silakan lengkapi formulir pendaftaran di bawah ini.
              </p>
            </div>
          </div>

          <div v-if="submitError" class="p-3 bg-rose-50 border border-rose-200 rounded-xl text-xs text-rose-800">
            {{ submitError }}
          </div>

          <!-- Dynamic Form Fields if available, otherwise general fields -->
          <div class="space-y-3">
            <div>
              <label class="block text-xs font-semibold text-slate-700 mb-1">Nama Siswa / Pendaftar</label>
              <input
                type="text"
                :value="authStore.user?.name"
                disabled
                class="w-full px-3 py-2 text-xs bg-slate-100 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed"
              />
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-700 mb-1">Catatan / Motivasi Keikutsertaan</label>
              <textarea
                v-model="formAnswers.notes"
                rows="3"
                placeholder="Tuliskan pengalaman atau motivasi mengikuti lomba..."
                class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue"
              ></textarea>
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-700 mb-1">Nomor Kontak WhatsApp Aktif</label>
              <input
                v-model="formAnswers.contact_phone"
                type="text"
                placeholder="Contoh: 08123456789"
                required
                class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue"
              />
            </div>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showRegisterModal = false"
              class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl transition-colors"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="submittingForm"
              class="px-5 py-2 text-xs font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs transition-all flex items-center gap-1.5"
            >
              <i v-if="submittingForm" class="fa-solid fa-spinner fa-spin"></i>
              <span>Kirim Pendaftaran</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </PublicLayout>
</template>
