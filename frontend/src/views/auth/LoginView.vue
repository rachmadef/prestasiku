<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const identifier = ref('')
const password = ref('')
const showPassword = ref(false)
const loading = ref(false)
const errorMessage = ref<string | null>(null)

async function handleLogin() {
  if (!identifier.value || !password.value) return
  loading.value = true
  errorMessage.value = null

  const result = await authStore.login(identifier.value, password.value)
  loading.value = false

  if (result.success && result.user) {
    if (result.user.must_change_password) {
      router.push('/force-change-password')
    } else if (result.user.roles.includes('super_admin')) {
      router.push('/admin/dashboard')
    } else if (result.user.roles.includes('school_admin')) {
      router.push('/school/dashboard')
    } else {
      router.push('/student/dashboard')
    }
  } else {
    errorMessage.value = result.message || 'Login gagal. Periksa kembali data Anda.'
  }
}

function fillCredentials(type: 'admin' = 'admin') {
  errorMessage.value = null
  if (type === 'admin') {
    identifier.value = 'superadmin'
    password.value = 'password'
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#DDE3EA] flex items-center justify-center p-4 sm:p-6 md:p-8 font-sans text-slate-800">
    <!-- Main Modal Card Container -->
    <div class="w-full max-w-3xl md:max-w-4xl bg-white rounded-3xl shadow-xl overflow-hidden flex flex-col md:flex-row relative border border-slate-200/80">
      
      <!-- Left Blue Brand Panel with Layered Cloud Wave Divider -->
      <div class="w-full md:w-5/12 bg-gradient-to-b from-[#001D60] via-[#0A408E] to-[#1062A7] text-white p-8 sm:p-12 flex flex-col justify-center items-center text-center relative overflow-hidden shrink-0">
        
        <!-- Subtle Background Glows -->
        <div class="absolute -top-12 -left-12 w-36 h-36 rounded-full bg-white/5 pointer-events-none"></div>
        <div class="absolute -bottom-12 -right-12 w-40 h-40 rounded-full bg-white/5 pointer-events-none"></div>

        <!-- Center Brand Cluster (Neatly Grouped in Middle) -->
        <div class="z-10 flex flex-col items-center justify-center space-y-3 py-6 md:py-12">
          <p class="text-xs sm:text-sm font-medium tracking-wide text-blue-100/90">
            Selamat Datang di
          </p>

          <!-- Circular White Emblem -->
          <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-full bg-white shadow-xl flex items-center justify-center border-4 border-white/20 transition-transform hover:scale-105">
            <img src="/img/icon-main.png" alt="PrestasiKu" class="w-12 h-12 sm:w-14 sm:h-14 object-contain" />
          </div>

          <!-- Brand Title -->
          <h2 class="text-xl sm:text-2xl font-black text-white tracking-tight">
            PrestasiKu
          </h2>
        </div>

        <!-- Desktop Cloud Wave Divider (Right Edge - Flush Top to Bottom) -->
        <div class="hidden md:block absolute inset-y-0 -right-0.5 w-16 lg:w-20 pointer-events-none z-20">
          <svg viewBox="0 0 100 600" preserveAspectRatio="none" class="w-full h-full text-white fill-current">
            <!-- Back Layer 1 (Darker translucent tint) -->
            <path
              d="M 100,0 C 60,20 0,40 0,90 C 0,140 40,170 40,220 C 40,270 -10,300 -10,350 C -10,400 35,430 35,480 C 35,530 65,560 100,600 L 100,600 L 100,0 Z"
              opacity="0.25"
              class="text-blue-300"
            />
            <!-- Middle Layer 2 (Lighter translucent tint) -->
            <path
              d="M 100,0 C 70,25 15,45 15,95 C 15,145 55,175 55,225 C 55,275 5,305 5,355 C 5,405 50,435 50,485 C 50,535 75,565 100,600 L 100,600 L 100,0 Z"
              opacity="0.5"
              class="text-blue-100"
            />
            <!-- Foreground Layer 3 (Pure White, 100% Flush) -->
            <path
              d="M 100,0 C 80,30 30,50 30,100 C 30,150 70,180 70,230 C 70,280 20,310 20,360 C 20,410 65,440 65,490 C 65,540 85,570 100,600 L 100,600 L 100,0 Z"
            />
          </svg>
        </div>

        <!-- Mobile Cloud Wave Divider (Bottom Edge - Flush Left to Right) -->
        <div class="md:hidden absolute inset-x-0 -bottom-0.5 w-full h-10 pointer-events-none z-20">
          <svg viewBox="0 0 1000 120" preserveAspectRatio="none" class="w-full h-full text-white fill-current">
            <!-- Back Layer 1 -->
            <path
              d="M 0,120 C 15,65 35,25 80,25 C 135,25 160,60 220,60 C 280,60 310,10 380,10 C 450,10 480,50 540,50 C 600,50 630,15 700,15 C 770,15 800,55 860,55 C 910,55 945,25 1000,120 L 1000,120 L 0,120 Z"
              opacity="0.25"
              class="text-blue-300"
            />
            <!-- Middle Layer 2 -->
            <path
              d="M 0,120 C 20,70 40,32 90,32 C 145,32 170,68 230,68 C 290,68 320,18 390,18 C 460,18 490,58 550,58 C 610,58 640,22 710,22 C 780,22 810,62 870,62 C 920,62 955,32 1000,120 L 1000,120 L 0,120 Z"
              opacity="0.5"
              class="text-blue-100"
            />
            <!-- Foreground Layer 3 (Pure White) -->
            <path
              d="M 0,120 C 20,80 45,40 100,40 C 155,40 180,75 240,75 C 300,75 330,25 400,25 C 470,25 500,65 560,65 C 620,65 650,30 720,30 C 790,30 820,70 880,70 C 930,70 965,40 1000,120 L 1000,120 L 0,120 Z"
            />
          </svg>
        </div>
      </div>

      <!-- Right Form Panel (Clean, Minimalist, Airy) -->
      <div class="w-full md:w-7/12 p-8 sm:p-10 md:p-12 flex flex-col justify-center bg-white z-10">
        <div class="max-w-sm w-full mx-auto space-y-5">
          
          <!-- Minimal Form Title -->
          <div>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
              Masuk ke Akun
            </h1>
          </div>

          <!-- Error Alert if any -->
          <div
            v-if="errorMessage"
            class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-center gap-2"
          >
            <i class="fa-solid fa-circle-exclamation text-rose-500 text-sm shrink-0"></i>
            <span>{{ errorMessage }}</span>
          </div>

          <!-- Minimal Form Fields -->
          <form @submit.prevent="handleLogin" class="space-y-4">
            <!-- Identifier Field -->
            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">
                NIS atau Email
              </label>
              <input
                v-model="identifier"
                type="text"
                required
                autocomplete="username"
                placeholder="Masukkan NIS siswa atau email"
                class="w-full px-4 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white focus:ring-2 focus:ring-brand-blue/10 transition-all text-slate-800 font-medium"
              />
            </div>

            <!-- Password Field -->
            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">
                Kata Sandi
              </label>
              <div class="relative">
                <input
                  v-model="password"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  autocomplete="current-password"
                  placeholder="Masukkan kata sandi"
                  class="w-full px-4 pr-10 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white focus:ring-2 focus:ring-brand-blue/10 transition-all text-slate-800 font-medium"
                />
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-brand-navy cursor-pointer"
                  :title="showPassword ? 'Sembunyikan password' : 'Lihat password'"
                >
                  <i :class="showPassword ? 'fa-solid fa-eye-slash text-xs' : 'fa-solid fa-eye text-xs'"></i>
                </button>
              </div>
            </div>

            <!-- Submit Button (Pill shape) -->
            <div class="pt-2">
              <button
                type="submit"
                :disabled="loading"
                class="w-full py-2.5 px-6 bg-gradient-to-r from-brand-navy to-brand-blue hover:opacity-95 text-white font-bold text-xs rounded-full shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
              >
                <i v-if="loading" class="fa-solid fa-spinner fa-spin"></i>
                <span v-else>Masuk</span>
              </button>
            </div>
          </form>

          <!-- Bottom Navigation -->
          <div class="pt-1 text-center">
            <router-link
              to="/"
              class="text-xs text-slate-400 hover:text-brand-navy font-medium transition-colors"
            >
              &larr; Kembali ke Beranda
            </router-link>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>
