<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const currentPassword = ref('')
const newPassword = ref('')
const newPasswordConfirmation = ref('')
const showCurrentPassword = ref(false)
const showNewPassword = ref(false)
const showConfirmPassword = ref(false)
const loading = ref(false)
const errorMessage = ref<string | null>(null)
const successMessage = ref<string | null>(null)

async function handleChangePassword() {
  if (!currentPassword.value) {
    errorMessage.value = 'Password saat ini wajib diisi.'
    return
  }
  if (!newPassword.value) {
    errorMessage.value = 'Password baru wajib diisi.'
    return
  }
  if (newPassword.value.length < 6) {
    errorMessage.value = 'Password baru minimal harus 6 karakter.'
    return
  }
  if (newPassword.value !== newPasswordConfirmation.value) {
    errorMessage.value = 'Konfirmasi password baru tidak cocok.'
    return
  }
  loading.value = true
  errorMessage.value = null

  const res = await authStore.changePassword(
    currentPassword.value,
    newPassword.value,
    newPasswordConfirmation.value
  )
  loading.value = false

  if (res.success) {
    successMessage.value = 'Password berhasil diperbarui! Mengalihkan ke dashboard...'
    setTimeout(() => {
      if (authStore.isSuperAdmin) router.push('/admin/dashboard')
      else if (authStore.isSchoolAdmin) router.push('/school/dashboard')
      else router.push('/student/dashboard')
    }, 1500)
  } else {
    errorMessage.value = res.message || 'Gagal mengubah password.'
  }
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md text-center">
      <img src="/img/icon-main.png" alt="PrestasiKu" class="h-12 w-auto mx-auto mb-3" />
      <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">Wajib Ganti Password</h2>
      <p class="text-xs text-slate-500 mt-1 max-w-xs mx-auto">
        Akun Anda terdeteksi masih menggunakan password awal bawaan sistem. Silakan tentukan password baru yang aman.
      </p>
    </div>

    <div class="mt-6 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-6 shadow-xl sm:rounded-3xl sm:px-10 border border-slate-200">
        <div v-if="successMessage" class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 text-center font-bold">
          <i class="fa-solid fa-circle-check text-emerald-600 text-lg block mb-1"></i>
          {{ successMessage }}
        </div>

        <form v-else @submit.prevent="handleChangePassword" class="space-y-4">
          <div v-if="errorMessage" class="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 flex items-center gap-2">
            <i class="fa-solid fa-triangle-exclamation text-rose-600 text-sm"></i>
            <span>{{ errorMessage }}</span>
          </div>

          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1">Password Saat Ini (Default: 1234)</label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <i class="fa-solid fa-key text-xs"></i>
              </div>
              <input
                v-model="currentPassword"
                :type="showCurrentPassword ? 'text' : 'password'"
                required
                placeholder="Password saat ini"
                class="w-full pl-9 pr-10 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showCurrentPassword = !showCurrentPassword"
                class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-brand-navy focus:outline-hidden cursor-pointer"
                :title="showCurrentPassword ? 'Sembunyikan password' : 'Lihat password'"
              >
                <i :class="showCurrentPassword ? 'fa-solid fa-eye-slash text-xs' : 'fa-solid fa-eye text-xs'"></i>
              </button>
            </div>
          </div>

          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1">Password Baru</label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <i class="fa-solid fa-lock text-xs"></i>
              </div>
              <input
                v-model="newPassword"
                :type="showNewPassword ? 'text' : 'password'"
                required
                minlength="6"
                placeholder="Minimal 6 karakter"
                class="w-full pl-9 pr-10 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showNewPassword = !showNewPassword"
                class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-brand-navy focus:outline-hidden cursor-pointer"
                :title="showNewPassword ? 'Sembunyikan password' : 'Lihat password'"
              >
                <i :class="showNewPassword ? 'fa-solid fa-eye-slash text-xs' : 'fa-solid fa-eye text-xs'"></i>
              </button>
            </div>
          </div>

          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1">Konfirmasi Password Baru</label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <i class="fa-solid fa-shield-halved text-xs"></i>
              </div>
              <input
                v-model="newPasswordConfirmation"
                :type="showConfirmPassword ? 'text' : 'password'"
                required
                minlength="6"
                placeholder="Ulangi password baru"
                class="w-full pl-9 pr-10 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showConfirmPassword = !showConfirmPassword"
                class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-brand-navy focus:outline-hidden cursor-pointer"
                :title="showConfirmPassword ? 'Sembunyikan password' : 'Lihat password'"
              >
                <i :class="showConfirmPassword ? 'fa-solid fa-eye-slash text-xs' : 'fa-solid fa-eye text-xs'"></i>
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
              <i v-else class="fa-solid fa-shield-check text-brand-gold"></i>
              <span>Simpan & Lanjutkan</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
