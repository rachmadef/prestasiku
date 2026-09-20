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
              <Badge :status="competition.verification_status || 'verified'" size="md" />
              <span class="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-600 bg-slate-100 px-3 py-1 rounded-full uppercase">
                {{ competition.scope || 'Nasional' }}
              </span>
            </div>

            <h1 class="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight leading-snug">
              {{ competition.name }}
            </h1>

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

            <!-- Description -->
            <div>
              <h2 class="text-sm font-bold uppercase tracking-wider text-slate-400 mb-2">Deskripsi Kompetisi</h2>
              <div class="text-sm text-slate-700 leading-relaxed space-y-3 whitespace-pre-line">
                {{ competition.description }}
              </div>
            </div>

            <!-- Verification Audit Box -->
            <div class="p-4 rounded-2xl bg-emerald-50/60 border border-emerald-200/70 flex items-start gap-3 text-xs text-emerald-900">
              <i class="fa-solid fa-circle-check text-emerald-600 text-lg mt-0.5 shrink-0"></i>
              <div>
                <p class="font-bold">Keaslian Sumber Terverifikasi</p>
                <p class="text-emerald-800 mt-0.5">
                  Kompetisi ini telah diverifikasi keabsahannya oleh tim PrestasiKu melalui panduan resmi penyelenggara. Dokumen dan tautan resmi aman diakses.
                </p>
                <div v-if="competition.official_url" class="mt-2">
                  <a
                    :href="competition.official_url"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="inline-flex items-center gap-1.5 font-bold text-brand-navy hover:underline"
                  >
                    <span>Kunjungi Tautan Resmi Lomba</span>
                    <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
                  </a>
                </div>
              </div>
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
                <p class="font-bold text-slate-800 uppercase">{{ competition.educational_level || 'SLTA' }}</p>
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
              <!-- If Student -->
              <template v-if="authStore.isStudent">
                <button
                  type="button"
                  @click="checkStudentEligibility"
                  :disabled="checkingEligibility"
                  class="w-full py-3 px-4 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2"
                >
                  <i v-if="checkingEligibility" class="fa-solid fa-spinner fa-spin"></i>
                  <i v-else class="fa-solid fa-circle-check text-brand-gold"></i>
                  <span>Cek Kelayakan Saya & Daftar</span>
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
                  class="w-full py-3 px-4 bg-brand-blue hover:bg-[#0d4f88] text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2"
                >
                  <i class="fa-solid fa-school-flag"></i>
                  <span>Daftarkan Delegasi Siswa</span>
                </router-link>
              </template>

              <!-- If Not Authenticated -->
              <template v-else>
                <router-link
                  to="/login"
                  class="w-full py-3 px-4 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2"
                >
                  <i class="fa-solid fa-arrow-right-to-bracket text-brand-gold"></i>
                  <span>Masuk untuk Mendaftar</span>
                </router-link>
                <p class="text-[11px] text-center text-slate-400">
                  Pelajar atau perwakilan sekolah wajib memiliki akun untuk mendaftar.
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
        :subtitle="competition?.name"
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
