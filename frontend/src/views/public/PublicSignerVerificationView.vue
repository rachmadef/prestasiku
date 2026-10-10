<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'

const route = useRoute()
const token = ref((route.params.token as string) || '')
const inputToken = ref('')
const loading = ref(false)
const verificationResult = ref<any>(null)
const errorMsg = ref('')

async function verifyToken(t: string) {
  if (!t) return
  loading.value = true
  errorMsg.value = ''
  verificationResult.value = null

  try {
    const res = await api.get(`/signers/verify/${t}`)
    verificationResult.value = res.data.data
  } catch (err: any) {
    errorMsg.value = err.response?.data?.message || 'Kode QR TTD Digital tidak valid atau data guru tidak ditemukan di sistem sekolah.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (token.value) {
    verifyToken(token.value)
  }
})
</script>

<template>
  <div class="min-h-screen bg-[#F3F1EF] py-8 px-4 sm:px-6 lg:px-8 font-sans text-slate-800">
    <div class="max-w-2xl mx-auto space-y-6">
      <!-- Top Brand Bar -->
      <div class="text-center space-y-2">
        <router-link to="/" class="inline-flex items-center gap-2.5">
          <img src="/img/icon-main.png" alt="PrestasiKu" class="h-10 w-auto" />
          <img src="/img/text-main.png" alt="PrestasiKu" class="h-6 w-auto" />
        </router-link>
        <p class="text-[11px] uppercase tracking-wider font-bold text-slate-500">
          Sistem Verifikasi Profil Guru & TTD Digital Pengesah Surat
        </p>
      </div>

      <!-- Manual Input Box if no token in URL -->
      <div v-if="!token" class="bg-white rounded-xl p-5 shadow-xs border border-slate-200">
        <label class="block text-xs font-bold text-slate-700 mb-1.5">Masukkan Kode Token TTD Digital Guru:</label>
        <div class="flex gap-2">
          <input
            v-model="inputToken"
            type="text"
            placeholder="Contoh token TTD..."
            class="flex-1 text-xs rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
          <button
            type="button"
            @click="verifyToken(inputToken)"
            class="px-4 py-2.5 bg-brand-navy text-white text-xs font-bold rounded-lg hover:bg-[#00164a] transition-all cursor-pointer"
          >
            Verifikasi
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="bg-white rounded-xl p-10 text-center shadow-xs border border-slate-200">
        <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
        <p class="text-xs text-slate-500 mt-2 font-medium">Memuat detail profil guru dari basis data sekolah...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="errorMsg" class="bg-white rounded-xl p-8 text-center shadow-xs border border-rose-200 space-y-3">
        <div class="w-12 h-12 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center mx-auto text-xl">
          <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="text-base font-bold text-rose-900">Detail Guru Tidak Ditemukan</h3>
        <p class="text-xs text-slate-600 max-w-sm mx-auto leading-relaxed">{{ errorMsg }}</p>
      </div>

      <!-- Verified Teacher Detail Card (Mirrors screenshot design with PrestasiKu polish) -->
      <div v-else-if="verificationResult" class="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">
        <!-- Banner Verification Header -->
        <div
          :class="[
            'p-4 text-center text-white flex items-center justify-center gap-2 text-xs font-bold',
            verificationResult.is_active ? 'bg-[#001D60]' : 'bg-slate-700'
          ]"
        >
          <i class="fa-solid fa-shield-check text-brand-gold text-sm"></i>
          <span>TANDA TANGAN DIGITAL TERVERIFIKASI SAH SEBAGAI PENGESAH RESMI</span>
        </div>

        <div class="p-6 md:p-8 space-y-8">
          <!-- Page Title (Detail Guru) -->
          <div class="text-center">
            <h1 class="text-2xl md:text-3xl font-serif font-bold text-teal-800 tracking-tight">
              Detail Guru
            </h1>
            <p class="text-xs text-slate-500 mt-1 font-medium">
              {{ verificationResult.school?.name }} (NPSN: {{ verificationResult.school?.npsn }})
            </p>
          </div>

          <!-- Centered Formal Photo & Caption -->
          <div class="text-center space-y-4 max-w-md mx-auto">
            <!-- Formal Photo Box -->
            <div class="w-44 h-56 mx-auto rounded-xl overflow-hidden shadow-md border-4 border-slate-100 bg-slate-100 flex items-center justify-center relative">
              <img
                v-if="verificationResult.photo_url"
                :src="verificationResult.photo_url"
                :alt="verificationResult.name"
                class="w-full h-full object-cover"
              />
              <div v-else class="text-center p-4 text-slate-400">
                <i class="fa-solid fa-user-tie text-5xl mb-2 text-slate-300"></i>
                <p class="text-[11px] font-medium text-slate-400">Pas Foto Guru</p>
              </div>
            </div>

            <!-- Biography / Title Caption -->
            <div class="space-y-1">
              <h2 class="text-sm md:text-base font-bold text-slate-900 leading-snug">
                {{ verificationResult.biography || ('Biografi ' + verificationResult.position_title + ' ' + verificationResult.school?.name) }}
              </h2>
            </div>
          </div>

          <!-- Personal Data Fields Table (Nama, TTL, Alamat) -->
          <div class="max-w-lg mx-auto bg-slate-50/70 p-5 rounded-xl border border-slate-200 text-xs md:text-sm space-y-3">
            <div class="grid grid-cols-12 gap-2 py-1">
              <div class="col-span-3 text-slate-600 font-bold">Nama</div>
              <div class="col-span-1 text-center font-bold">:</div>
              <div class="col-span-8 font-bold text-slate-900">{{ verificationResult.name }}</div>
            </div>

            <div v-if="verificationResult.nip && verificationResult.nip !== 'NIP. Pengesah Resmi Sekolah'" class="grid grid-cols-12 gap-2 py-1 border-t border-slate-200/60">
              <div class="col-span-3 text-slate-600 font-bold">NIP</div>
              <div class="col-span-1 text-center font-bold">:</div>
              <div class="col-span-8 font-semibold text-slate-800">{{ verificationResult.nip }}</div>
            </div>

            <div class="grid grid-cols-12 gap-2 py-1 border-t border-slate-200/60">
              <div class="col-span-3 text-slate-600 font-bold">TTL</div>
              <div class="col-span-1 text-center font-bold">:</div>
              <div class="col-span-8 font-semibold text-slate-800">
                {{ verificationResult.ttl_formatted || '-' }}
              </div>
            </div>

            <div class="grid grid-cols-12 gap-2 py-1 border-t border-slate-200/60">
              <div class="col-span-3 text-slate-600 font-bold">Alamat</div>
              <div class="col-span-1 text-center font-bold">:</div>
              <div class="col-span-8 font-semibold text-slate-800 leading-relaxed">
                {{ verificationResult.address || '-' }}
              </div>
            </div>
          </div>

          <!-- Education History Section (Riwayat Pendidikan) -->
          <div class="max-w-lg mx-auto space-y-2">
            <h3 class="text-sm font-bold text-slate-900 border-b-2 border-teal-700 pb-1.5 inline-block">
              Riwayat Pendidikan
            </h3>
            <div class="p-4 rounded-xl bg-white border border-slate-200 text-xs text-slate-700 leading-relaxed whitespace-pre-line shadow-xs">
              {{ verificationResult.education_history || 'Data riwayat pendidikan terdaftar di arsip sekolah.' }}
            </div>
          </div>

          <!-- Authenticity & Security Footer Note -->
          <div class="max-w-lg mx-auto p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-start gap-3">
            <i class="fa-solid fa-certificate text-amber-600 text-base shrink-0 mt-0.5"></i>
            <div class="space-y-1">
              <p class="font-bold text-amber-950">Status Otentisitas TTD Digital:</p>
              <p class="text-[11.5px] leading-relaxed text-amber-800">
                {{ verificationResult.verification_note }}
              </p>
            </div>
          </div>
        </div>

        <!-- Back Link Footer -->
        <div class="px-6 py-4 bg-slate-50 border-t border-slate-200 text-center">
          <router-link
            to="/"
            class="text-xs font-bold text-brand-navy hover:underline inline-flex items-center gap-1.5"
          >
            <i class="fa-solid fa-arrow-left"></i>
            <span>Kembali ke Halaman Utama</span>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>
