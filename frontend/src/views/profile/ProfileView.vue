<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

// Active Tab
const activeTab = ref<'profile' | 'password'>('profile')

// Profile Form State
const profileForm = ref({
  name: '',
  email: '',
  phone: '',
})
const profileLoading = ref(false)
const profileSuccess = ref<string | null>(null)
const profileError = ref<string | null>(null)
const profileFieldErrors = ref<Record<string, string[]>>({})

// Password Form State
const passwordForm = ref({
  current_password: '',
  new_password: '',
  new_password_confirmation: '',
})
const showCurrentPassword = ref(false)
const showNewPassword = ref(false)
const showConfirmPassword = ref(false)
const passwordLoading = ref(false)
const passwordSuccess = ref<string | null>(null)
const passwordError = ref<string | null>(null)

function initProfileData() {
  if (authStore.user) {
    profileForm.value.name = authStore.user.name || ''
    profileForm.value.email = authStore.user.email || ''
    profileForm.value.phone = authStore.user.phone || ''
  }
}

onMounted(() => {
  initProfileData()
  // If user must change password, directly switch to password tab
  if (authStore.requiresPasswordChange) {
    activeTab.value = 'password'
  }
})

// Save Profile
async function handleUpdateProfile() {
  profileLoading.value = true
  profileSuccess.value = null
  profileError.value = null
  profileFieldErrors.value = {}

  const res = await authStore.updateProfile({
    name: profileForm.value.name,
    email: profileForm.value.email,
    phone: profileForm.value.phone || null,
  })

  if (res.success) {
    profileSuccess.value = res.message || 'Profil berhasil diperbarui.'
    setTimeout(() => {
      profileSuccess.value = null
    }, 4000)
  } else {
    profileError.value = res.message || 'Gagal memperbarui profil.'
    if (res.errors) {
      profileFieldErrors.value = res.errors
    }
  }
  profileLoading.value = false
}

// Change Password
async function handleChangePassword() {
  passwordLoading.value = true
  passwordSuccess.value = null
  passwordError.value = null

  if (passwordForm.value.new_password !== passwordForm.value.new_password_confirmation) {
    passwordError.value = 'Konfirmasi password baru tidak cocok.'
    passwordLoading.value = false
    return
  }

  if (passwordForm.value.new_password.length < 6) {
    passwordError.value = 'Password baru minimal harus 6 karakter.'
    passwordLoading.value = false
    return
  }

  const res = await authStore.changePassword(
    passwordForm.value.current_password,
    passwordForm.value.new_password,
    passwordForm.value.new_password_confirmation
  )

  if (res.success) {
    passwordSuccess.value = 'Password Anda telah berhasil diperbarui! Silakan gunakan password baru ini untuk login berikutnya.'
    passwordForm.value.current_password = ''
    passwordForm.value.new_password = ''
    passwordForm.value.new_password_confirmation = ''
    setTimeout(() => {
      passwordSuccess.value = null
    }, 6000)
  } else {
    passwordError.value = res.message || 'Gagal mengubah password. Pastikan password saat ini benar.'
  }
  passwordLoading.value = false
}

const roleBadge = computed(() => {
  if (authStore.isSuperAdmin) {
    return { label: 'Super Administrator', icon: 'fa-solid fa-crown', color: 'bg-amber-100 text-amber-800 border-amber-300' }
  }
  if (authStore.isSchoolAdmin) {
    return { label: 'Admin Sekolah Resmi', icon: 'fa-solid fa-school', color: 'bg-blue-100 text-blue-800 border-blue-300' }
  }
  return { label: 'Siswa Delegasi', icon: 'fa-solid fa-graduation-cap', color: 'bg-emerald-100 text-emerald-800 border-emerald-300' }
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Profil & Keamanan Akun</template>

    <div class="max-w-4xl mx-auto space-y-6 pb-12">
      <!-- 1. Hero Identity Banner -->
      <div class="bg-gradient-to-r from-brand-navy to-[#002f8a] rounded-3xl p-6 sm:p-8 text-white shadow-md relative overflow-hidden">
        <!-- Decorative Glow -->
        <div class="absolute -right-10 -bottom-10 w-48 h-48 bg-white/5 rounded-full blur-2xl pointer-events-none"></div>

        <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-6">
          <div class="flex items-center gap-5">
            <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl bg-white/10 border-2 border-brand-gold/60 text-brand-gold font-extrabold text-2xl sm:text-3xl flex items-center justify-center shadow-lg shrink-0">
              {{ authStore.user?.name?.charAt(0) || 'U' }}
            </div>
            <div class="space-y-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold border" :class="roleBadge.color">
                  <i :class="roleBadge.icon"></i>
                  <span>{{ roleBadge.label }}</span>
                </span>
                <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 text-[10px] font-semibold border border-emerald-400/30">
                  <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                  <span>Aktif</span>
                </span>
              </div>
              <h2 class="text-xl sm:text-2xl font-black tracking-tight text-white truncate">
                {{ authStore.user?.name }}
              </h2>
              <p class="text-xs text-blue-200/80 font-mono">
                @{{ authStore.user?.username }} • {{ authStore.user?.email }}
              </p>
            </div>
          </div>

          <!-- School Tag for School Admin -->
          <div v-if="authStore.user?.school" class="sm:text-right bg-white/10 p-3.5 rounded-2xl border border-white/15 max-w-xs space-y-0.5">
            <p class="text-[10px] uppercase font-bold text-brand-gold tracking-wider">Instansi Naungan</p>
            <p class="text-xs font-bold text-white truncate">{{ authStore.user.school.name }}</p>
            <p class="text-[11px] text-blue-200/80 font-mono">NPSN: {{ authStore.user.school.npsn }}</p>
          </div>
        </div>
      </div>

      <!-- 2. Segmented Navigation Tabs -->
      <div class="flex items-center gap-2 border-b border-slate-200 pb-2">
        <button
          type="button"
          @click="activeTab = 'profile'"
          :class="[
            'px-5 py-2.5 rounded-xl text-xs font-extrabold flex items-center gap-2 transition-all cursor-pointer',
            activeTab === 'profile'
              ? 'bg-brand-navy text-white shadow-sm'
              : 'text-slate-600 hover:text-slate-900 hover:bg-slate-200/70'
          ]"
        >
          <i class="fa-solid fa-user-gear"></i>
          <span>Informasi Profil & Kontak</span>
        </button>

        <button
          type="button"
          @click="activeTab = 'password'"
          :class="[
            'px-5 py-2.5 rounded-xl text-xs font-extrabold flex items-center gap-2 transition-all cursor-pointer relative',
            activeTab === 'password'
              ? 'bg-brand-navy text-white shadow-sm'
              : 'text-slate-600 hover:text-slate-900 hover:bg-slate-200/70'
          ]"
        >
          <i class="fa-solid fa-key"></i>
          <span>Keamanan & Ganti Password</span>
          <span
            v-if="authStore.requiresPasswordChange"
            class="w-2 h-2 rounded-full bg-rose-500 absolute top-2 right-2 animate-ping"
          ></span>
        </button>
      </div>

      <!-- 3. TAB 1: Detail Profil -->
      <div v-if="activeTab === 'profile'" class="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-xs space-y-6">
        <div>
          <h3 class="text-base font-bold text-slate-900 flex items-center gap-2">
            <i class="fa-solid fa-address-card text-brand-blue"></i>
            Detail Data Pribadi & Kontak
          </h3>
          <p class="text-xs text-slate-500 mt-0.5">
            Perbarui nama lengkap dan nomor narahubung yang dapat dihubungi oleh sistem PrestasiKu.
          </p>
        </div>

        <!-- Feedback Alert -->
        <div v-if="profileSuccess" class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 flex items-center gap-2">
          <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
          <span class="font-medium">{{ profileSuccess }}</span>
        </div>
        <div v-if="profileError" class="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 flex items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-rose-600 text-base"></i>
          <span class="font-medium">{{ profileError }}</span>
        </div>

        <form @submit.prevent="handleUpdateProfile" class="space-y-6">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-5 text-xs">
            <!-- Nama Lengkap -->
            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Nama Lengkap *</label>
              <input
                v-model="profileForm.name"
                type="text"
                required
                placeholder="Nama Lengkap Penanggung Jawab"
                class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <p v-if="profileFieldErrors.name" class="text-[11px] text-rose-600 mt-1 font-medium">
                {{ profileFieldErrors.name[0] }}
              </p>
            </div>

            <!-- Email Resmi -->
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Email Kontak Resmi *</label>
              <input
                v-model="profileForm.email"
                type="email"
                required
                placeholder="email@sekolah.sch.id"
                class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <p v-if="profileFieldErrors.email" class="text-[11px] text-rose-600 mt-1 font-medium">
                {{ profileFieldErrors.email[0] }}
              </p>
            </div>

            <!-- Telepon / WA -->
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nomor WhatsApp / HP</label>
              <input
                v-model="profileForm.phone"
                type="text"
                placeholder="Contoh: 08123456789"
                class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <p v-if="profileFieldErrors.phone" class="text-[11px] text-rose-600 mt-1 font-medium">
                {{ profileFieldErrors.phone[0] }}
              </p>
            </div>

            <!-- Username (Readonly) -->
            <div>
              <label class="block font-semibold text-slate-500 mb-1">
                Username Login Sistem <i class="fa-solid fa-lock text-[10px] ml-1 text-slate-400"></i>
              </label>
              <input
                :value="authStore.user?.username"
                type="text"
                disabled
                class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl font-mono text-slate-500 cursor-not-allowed"
              />
              <span class="text-[10px] text-slate-400 mt-0.5 block">Username dibuat permanen dari NPSN instansi.</span>
            </div>

            <!-- Hak Akses / Role (Readonly) -->
            <div>
              <label class="block font-semibold text-slate-500 mb-1">
                Peran Sistem (Role) <i class="fa-solid fa-lock text-[10px] ml-1 text-slate-400"></i>
              </label>
              <input
                :value="authStore.user?.roles.join(', ')"
                type="text"
                disabled
                class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl uppercase text-slate-500 cursor-not-allowed font-semibold"
              />
            </div>
          </div>

          <!-- School Information Section for School Admin -->
          <div v-if="authStore.user?.school" class="pt-4 border-t border-slate-100">
            <h4 class="text-xs font-bold text-slate-800 uppercase tracking-wider mb-3 flex items-center gap-1.5">
              <i class="fa-solid fa-building text-brand-blue"></i>
              Informasi Instansi Sekolah
            </h4>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs bg-slate-50 p-4 rounded-2xl border border-slate-100">
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-semibold">Nama Sekolah</span>
                <span class="font-bold text-slate-900">{{ authStore.user.school.name }}</span>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-semibold">NPSN</span>
                <span class="font-mono font-bold text-slate-900">{{ authStore.user.school.npsn }}</span>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-semibold">Jenjang Pendidikan</span>
                <span class="font-bold text-slate-900 uppercase">{{ authStore.user.school.educational_level }}</span>
              </div>
            </div>
          </div>

          <!-- Submit Button -->
          <div class="pt-2 flex justify-end">
            <button
              type="submit"
              :disabled="profileLoading"
              class="px-6 py-2.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
            >
              <i v-if="profileLoading" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-floppy-disk text-brand-gold"></i>
              <span>Simpan Perubahan Profil</span>
            </button>
          </div>
        </form>
      </div>

      <!-- 4. TAB 2: Keamanan & Ganti Password -->
      <div v-if="activeTab === 'password'" class="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-xs space-y-6">
        <div>
          <h3 class="text-base font-bold text-slate-900 flex items-center gap-2">
            <i class="fa-solid fa-shield-halved text-brand-blue"></i>
            Perbarui Password Akun
          </h3>
          <p class="text-xs text-slate-500 mt-0.5">
            Gunakan password yang kuat dan mudah Anda ingat untuk melindungi data prestasi sekolah Anda.
          </p>
        </div>

        <!-- Mandatory change notice if active -->
        <div v-if="authStore.requiresPasswordChange" class="p-4 rounded-2xl bg-amber-50 border border-amber-200 text-xs text-amber-900 flex items-start gap-2.5">
          <i class="fa-solid fa-circle-exclamation text-amber-600 text-base mt-0.5"></i>
          <div>
            <p class="font-bold">Password Sementara Terdeteksi</p>
            <p class="text-[11px] text-amber-800 mt-0.5">
              Akun Anda baru saja dibuat menggunakan password default <code>password123</code>. Silakan buat password baru pribadi Anda di bawah ini agar akun tetap aman.
            </p>
          </div>
        </div>

        <!-- Feedback Alert -->
        <div v-if="passwordSuccess" class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 flex items-center gap-2">
          <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
          <span class="font-medium">{{ passwordSuccess }}</span>
        </div>
        <div v-if="passwordError" class="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 flex items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-rose-600 text-base"></i>
          <span class="font-medium">{{ passwordError }}</span>
        </div>

        <form @submit.prevent="handleChangePassword" class="space-y-5 max-w-lg">
          <!-- Password Saat Ini -->
          <div>
            <label class="block font-semibold text-slate-700 text-xs mb-1">Password Saat Ini *</label>
            <div class="relative">
              <input
                v-model="passwordForm.current_password"
                :type="showCurrentPassword ? 'text' : 'password'"
                required
                placeholder="Masukkan password yang Anda gunakan saat ini"
                class="w-full px-3.5 py-2.5 pr-10 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showCurrentPassword = !showCurrentPassword"
                class="absolute right-3 top-2.5 text-slate-400 hover:text-slate-600 text-xs cursor-pointer"
              >
                <i :class="showCurrentPassword ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye'"></i>
              </button>
            </div>
            <span class="text-[10px] text-slate-400 mt-0.5 block">
              Untuk akun baru yang baru didaftarkan, ketik <code>password123</code>.
            </span>
          </div>

          <!-- Password Baru -->
          <div>
            <label class="block font-semibold text-slate-700 text-xs mb-1">Password Baru *</label>
            <div class="relative">
              <input
                v-model="passwordForm.new_password"
                :type="showNewPassword ? 'text' : 'password'"
                required
                minlength="6"
                placeholder="Minimal 6 karakter"
                class="w-full px-3.5 py-2.5 pr-10 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showNewPassword = !showNewPassword"
                class="absolute right-3 top-2.5 text-slate-400 hover:text-slate-600 text-xs cursor-pointer"
              >
                <i :class="showNewPassword ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye'"></i>
              </button>
            </div>
          </div>

          <!-- Konfirmasi Password Baru -->
          <div>
            <label class="block font-semibold text-slate-700 text-xs mb-1">Konfirmasi Password Baru *</label>
            <div class="relative">
              <input
                v-model="passwordForm.new_password_confirmation"
                :type="showConfirmPassword ? 'text' : 'password'"
                required
                minlength="6"
                placeholder="Ulangi password baru persis sama"
                class="w-full px-3.5 py-2.5 pr-10 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
              />
              <button
                type="button"
                @click="showConfirmPassword = !showConfirmPassword"
                class="absolute right-3 top-2.5 text-slate-400 hover:text-slate-600 text-xs cursor-pointer"
              >
                <i :class="showConfirmPassword ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye'"></i>
              </button>
            </div>
            <p
              v-if="passwordForm.new_password && passwordForm.new_password_confirmation && passwordForm.new_password !== passwordForm.new_password_confirmation"
              class="text-[11px] text-rose-600 mt-1 font-medium"
            >
              <i class="fa-solid fa-circle-xmark mr-1"></i> Konfirmasi password tidak cocok.
            </p>
          </div>

          <!-- Security Tip Card -->
          <div class="p-3.5 bg-blue-50/60 border border-blue-200/60 rounded-2xl text-[11px] text-slate-600 space-y-1">
            <p class="font-bold text-brand-navy flex items-center gap-1.5">
              <i class="fa-solid fa-lightbulb text-brand-gold"></i> Tips Keamanan Akun
            </p>
            <ul class="list-disc list-inside space-y-0.5 text-slate-600 pl-1">
              <li>Minimal 6 karakter, kombinasikan huruf besar, angka, atau simbol.</li>
              <li>Setelah mengganti password, Anda akan tetap login di perangkat ini.</li>
            </ul>
          </div>

          <!-- Submit Button -->
          <div class="pt-2">
            <button
              type="submit"
              :disabled="passwordLoading"
              class="px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
            >
              <i v-if="passwordLoading" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-key"></i>
              <span>Perbarui Password</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </DashboardLayout>
</template>
