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

function fillCredentials(type: 'admin' | 'school' | 'student') {
  if (type === 'admin') {
    identifier.value = 'superadmin@prestasiku.id'
    password.value = 'password'
  } else if (type === 'school') {
    identifier.value = 'admin.sman1@prestasiku.id'
    password.value = 'password'
  } else if (type === 'student') {
    identifier.value = '10101010_2026001'
    password.value = '1234'
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-white via-[#F3F1EF] to-[#E2E8F0] flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md text-center">
      <!-- Logo -->
      <router-link to="/" class="inline-flex items-center gap-3 group focus:outline-hidden mb-4">
        <img src="/img/icon-main.png" alt="PrestasiKu Icon" class="h-12 w-auto transition-transform group-hover:scale-105" />
        <img src="/img/text-main.png" alt="PrestasiKu" class="h-8 w-auto" />
      </router-link>
      <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">Masuk ke Portal PrestasiKu</h2>
      <p class="text-xs text-slate-500 mt-1">Gunakan akun Super Admin, Admin Sekolah, atau Akun Siswa</p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-6 shadow-xl sm:rounded-3xl sm:px-10 border border-slate-200/80">
        <!-- Error Alert -->
        <div v-if="errorMessage" class="mb-5 p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 flex items-center gap-2">
          <i class="fa-solid fa-circle-exclamation text-rose-600 text-sm"></i>
          <span>{{ errorMessage }}</span>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1">
              Email / Username / NIS Siswa
            </label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <i class="fa-regular fa-user text-xs"></i>
              </div>
              <input
                v-model="identifier"
                type="text"
                required
                placeholder="Masukkan email, username, atau NIS"
                class="w-full pl-9 pr-3.5 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
            </div>
          </div>

          <div>
            <div class="flex items-center justify-between mb-1">
              <label class="block text-xs font-semibold text-slate-700">Password</label>
            </div>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <i class="fa-solid fa-lock text-xs"></i>
              </div>
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                required
                placeholder="••••••••"
                class="w-full pl-9 pr-10 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showPassword = !showPassword"
                class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-brand-navy focus:outline-hidden cursor-pointer"
                :title="showPassword ? 'Sembunyikan password' : 'Lihat password'"
              >
                <i :class="showPassword ? 'fa-solid fa-eye-slash text-xs' : 'fa-solid fa-eye text-xs'"></i>
              </button>
            </div>
          </div>

          <div class="pt-2">
            <button
              type="submit"
              :disabled="loading"
              class="w-full py-3 px-4 bg-brand-navy hover:bg-[#001442] text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2"
            >
              <i v-if="loading" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-arrow-right-to-bracket text-brand-gold"></i>
              <span>Masuk Sekarang</span>
            </button>
          </div>
        </form>

        <!-- Quick Demo Credentials Fill for Easy Testing -->
        <div class="mt-8 pt-6 border-t border-slate-100">
          <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-3 text-center">
            Akun Percobaan (1-Click Fill)
          </p>
          <div class="grid grid-cols-3 gap-2 text-center">
            <button
              type="button"
              @click="fillCredentials('admin')"
              class="px-2.5 py-2 rounded-xl bg-blue-50 hover:bg-blue-100 text-brand-navy border border-blue-200/60 text-[11px] font-semibold transition-colors"
            >
              <i class="fa-solid fa-user-shield block text-xs mb-0.5 text-brand-blue"></i>
              Super Admin
            </button>
            <button
              type="button"
              @click="fillCredentials('school')"
              class="px-2.5 py-2 rounded-xl bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-200/60 text-[11px] font-semibold transition-colors"
            >
              <i class="fa-solid fa-school block text-xs mb-0.5 text-amber-600"></i>
              Admin SMAN 1
            </button>
            <button
              type="button"
              @click="fillCredentials('student')"
              class="px-2.5 py-2 rounded-xl bg-purple-50 hover:bg-purple-100 text-purple-900 border border-purple-200/60 text-[11px] font-semibold transition-colors"
            >
              <i class="fa-solid fa-graduation-cap block text-xs mb-0.5 text-purple-600"></i>
              Siswa Demo
            </button>
          </div>
        </div>

        <div class="mt-6 text-center">
          <router-link to="/" class="text-xs text-slate-500 hover:text-brand-navy font-medium">
            &larr; Kembali ke Beranda
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>
