<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'

const competitions = ref<any[]>([])
const loading = ref(true)

// Eligibility & Registration state
const checkingId = ref<number | null>(null)
const eligibilityModal = ref(false)
const selectedComp = ref<any>(null)
const eligibilityResult = ref<any>(null)

const registerModal = ref(false)
const registerForm = ref({
  notes: '',
  contact_phone: '',
})
const registering = ref(false)
const registerSuccess = ref(false)
const registerError = ref<string | null>(null)

const filterTimeline = ref('')

async function fetchCompetitions() {
  loading.value = true
  try {
    const params: Record<string, any> = { status: 'published' }
    if (filterTimeline.value) params.timeline = filterTimeline.value
    const res = await api.get('/competitions', { params })
    competitions.value = extractList(res.data.data)
  } catch (err) {
    console.error('Error fetching competitions:', err)
  } finally {
    loading.value = false
  }
}

async function checkEligibility(comp: any) {
  checkingId.value = comp.id
  selectedComp.value = comp
  eligibilityResult.value = null
  try {
    const res = await api.get(`/competitions/${comp.id}/eligibility`)
    eligibilityResult.value = res.data
    eligibilityModal.value = true
  } catch (err: any) {
    eligibilityResult.value = {
      eligible: false,
      message: err.response?.data?.message || 'Gagal mengecek kelayakan profil.',
    }
    eligibilityModal.value = true
  } finally {
    checkingId.value = null
  }
}

function openRegisterFromEligibility() {
  eligibilityModal.value = false
  registerSuccess.value = false
  registerError.value = null
  registerForm.value = { notes: '', contact_phone: '' }
  registerModal.value = true
}

async function submitRegistration() {
  if (!selectedComp.value) return
  registering.value = true
  registerError.value = null

  try {
    await api.post('/student/registrations', {
      competition_id: selectedComp.value.id,
      answers: registerForm.value,
    })
    registerSuccess.value = true
    setTimeout(() => {
      registerModal.value = false
    }, 2000)
  } catch (err: any) {
    registerError.value = err.response?.data?.message || 'Gagal mendaftar kompetisi.'
  } finally {
    registering.value = false
  }
}

onMounted(() => {
  fetchCompetitions()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Jelajah Lomba & Eligibility Engine</template>
    <template #header-subtitle>Periksa kelayakan jenjang dan umur Anda secara otomatis sebelum mendaftar kompetisi.</template>

    <div class="space-y-6">
      <!-- Filter Bar -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs">
        <div class="flex items-center gap-2">
          <i class="fa-solid fa-filter text-slate-400 text-xs"></i>
          <span class="text-xs font-bold text-slate-700">Filter Pelaksanaan:</span>
        </div>
        <select
          v-model="filterTimeline"
          @change="fetchCompetitions"
          class="px-3.5 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 font-semibold focus:outline-hidden focus:border-brand-blue transition-colors cursor-pointer"
        >
          <option value="">Semua Waktu Lomba</option>
          <option value="upcoming">🚀 Lomba Akan Datang</option>
          <option value="this_month">📅 Pelaksanaan Bulan Ini</option>
          <option value="next_month">🗓️ Pelaksanaan Bulan Depan</option>
        </select>
      </div>

      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 3" :key="i" class="bg-white rounded-2xl p-6 border border-slate-200 animate-pulse space-y-4">
          <div class="h-4 bg-slate-200 rounded-md w-1/3"></div>
          <div class="h-6 bg-slate-200 rounded-md w-3/4"></div>
          <div class="h-20 bg-slate-100 rounded-md"></div>
        </div>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="comp in competitions"
          :key="comp.id"
          class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs flex flex-col justify-between"
        >
          <div>
            <div class="flex items-center justify-between gap-2 mb-3">
              <span class="text-[11px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-md">
                {{ comp.category?.name || 'Kompetisi' }}
              </span>
              <Badge :status="comp.verification_status || 'verified'" />
            </div>

            <h3 class="text-base font-bold text-slate-900 leading-snug line-clamp-2">
              {{ comp.name || comp.title }}
            </h3>

            <p class="text-xs text-slate-500 mt-1">
              {{ comp.organizer?.name || 'Penyelenggara Resmi' }}
            </p>

            <p class="text-xs text-slate-600 mt-3 line-clamp-3 leading-relaxed">
              {{ comp.description }}
            </p>
          </div>

          <div class="mt-6 pt-4 border-t border-slate-100 space-y-3">
            <div class="text-[11px] text-slate-500 flex items-center justify-between">
              <span>{{ comp.educational_level?.toUpperCase() }} • {{ comp.scope }}</span>
              <span class="font-semibold text-slate-700">
                Deadline: {{ comp.registration_deadline ? comp.registration_deadline.split('T')[0] : '-' }}
              </span>
            </div>

            <button
              type="button"
              @click="checkEligibility(comp)"
              :disabled="checkingId === comp.id"
              class="w-full py-2 px-3 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center justify-center gap-1.5"
            >
              <i v-if="checkingId === comp.id" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-calculator text-brand-gold"></i>
              <span>Cek Kelayakan & Daftar</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Eligibility Modal -->
      <Modal v-model="eligibilityModal" title="Hasil Pengecekan Kelayakan" :subtitle="selectedComp?.name" size="md">
        <div class="space-y-4 text-xs">
          <div
            :class="[
              'p-4 rounded-2xl border text-center space-y-2',
              eligibilityResult?.eligible ? 'bg-emerald-50 border-emerald-200 text-emerald-900' : 'bg-rose-50 border-rose-200 text-rose-900'
            ]"
          >
            <div class="w-12 h-12 rounded-full flex items-center justify-center text-2xl mx-auto" :class="eligibilityResult?.eligible ? 'bg-emerald-100 text-emerald-600' : 'bg-rose-100 text-rose-600'">
              <i :class="eligibilityResult?.eligible ? 'fa-solid fa-check' : 'fa-solid fa-xmark'"></i>
            </div>
            <h4 class="text-sm font-bold">
              {{ eligibilityResult?.eligible ? 'Selamat! Anda Memenuhi Syarat Kelayakan' : 'Mohon Maaf, Anda Belum Memenuhi Kriteria' }}
            </h4>
            <p class="text-xs text-slate-600">
              {{ eligibilityResult?.message }}
            </p>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="eligibilityModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Tutup
            </button>
            <button
              v-if="eligibilityResult?.eligible"
              type="button"
              @click="openRegisterFromEligibility"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs"
            >
              Lanjutkan Pendaftaran &rarr;
            </button>
          </div>
        </div>
      </Modal>

      <!-- Register Modal -->
      <Modal v-model="registerModal" title="Kirim Permohonan Pendaftaran Delegasi" :subtitle="selectedComp?.name" size="md">
        <div v-if="registerSuccess" class="py-6 text-center space-y-3">
          <div class="w-14 h-14 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-2xl mx-auto">
            <i class="fa-solid fa-check"></i>
          </div>
          <h4 class="text-sm font-bold text-slate-900">Pendaftaran Berhasil Dikirim!</h4>
          <p class="text-xs text-slate-600">Pihak sekolah akan segera meninjau dan memberikan persetujuan delegasi Anda.</p>
        </div>

        <form v-else @submit.prevent="submitRegistration" class="space-y-4 text-xs">
          <div v-if="registerError" class="p-3 rounded-xl bg-rose-50 text-rose-800 border border-rose-200">
            {{ registerError }}
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Nomor WhatsApp Aktif *</label>
            <input
              v-model="registerForm.contact_phone"
              type="text"
              required
              placeholder="08123456789"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Catatan / Alasan Mengikuti Lomba</label>
            <textarea
              v-model="registerForm.notes"
              rows="3"
              placeholder="Jelaskan persiapan dan motivasi Anda..."
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="registerModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="registering"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs"
            >
              <i v-if="registering" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Kirim Permohonan</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
