<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const mobileMenuOpen = ref(false)

function getDashboardRoute() {
  if (authStore.isSuperAdmin) return '/admin/dashboard'
  if (authStore.isSchoolAdmin) return '/school/dashboard'
  if (authStore.isStudent) return '/student/dashboard'
  return '/login'
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<template>
  <header class="sticky top-0 z-40 w-full bg-brand-navy border-b border-white/10 shadow-md">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-18">
        <!-- Brand Logo (White Version for Blue Navbar) -->
        <router-link to="/" class="flex items-center gap-2.5 sm:gap-3 group focus:outline-hidden">
          <img
            src="/img/icon-white.png"
            alt="PrestasiKu Icon"
            class="hidden md:block h-9 w-auto object-contain transition-transform group-hover:scale-105"
          />
          <img
            src="/img/text-white.png"
            alt="PrestasiKu"
            class="h-6 sm:h-6.5 w-auto object-contain"
          />
        </router-link>

        <!-- Desktop Navigation Links -->
        <nav class="hidden md:flex items-center gap-1 lg:gap-2">
          <router-link
            to="/"
            active-class="text-brand-gold font-bold bg-white/10"
            class="px-3.5 py-2 rounded-xl text-sm font-medium text-slate-200 hover:text-white hover:bg-white/10 transition-colors"
          >
            Beranda
          </router-link>
          <router-link
            to="/competitions"
            active-class="text-brand-gold font-bold bg-white/10"
            class="px-3.5 py-2 rounded-xl text-sm font-medium text-slate-200 hover:text-white hover:bg-white/10 transition-colors"
          >
            <i class="fa-solid fa-trophy mr-1.5 text-brand-gold"></i>
            Katalog Kompetisi
          </router-link>
          <router-link
            to="/verify"
            active-class="text-brand-gold font-bold bg-white/10"
            class="px-3.5 py-2 rounded-xl text-sm font-medium text-slate-200 hover:text-white hover:bg-white/10 transition-colors"
          >
            <i class="fa-solid fa-qrcode mr-1.5 text-sky-300"></i>
            Cek QR Prestasi
          </router-link>
        </nav>

        <!-- Desktop Right Actions -->
        <div class="hidden md:flex items-center gap-3">
          <router-link
            to="/school-registration"
            class="inline-flex items-center gap-2 px-3.5 py-2 text-xs font-semibold text-white bg-white/10 hover:bg-white/20 border border-white/20 rounded-xl transition-colors"
          >
            <i class="fa-solid fa-school text-xs text-emerald-400"></i>
            Daftarkan Sekolah
          </router-link>

          <template v-if="authStore.isAuthenticated">
            <router-link
              :to="getDashboardRoute()"
              class="inline-flex items-center gap-2 px-4 py-2 text-xs font-bold text-brand-navy bg-brand-gold hover:bg-[#e0a600] rounded-xl shadow-xs transition-all hover:shadow-md"
            >
              <i class="fa-solid fa-gauge-high"></i>
              Dashboard ({{ authStore.user?.name.split(' ')[0] }})
            </router-link>
            <button
              type="button"
              @click="handleLogout"
              class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
              title="Keluar"
            >
              <i class="fa-solid fa-arrow-right-from-bracket"></i>
            </button>
          </template>

          <template v-else>
            <router-link
              to="/login"
              class="inline-flex items-center gap-2 px-4 py-2 text-xs font-bold text-brand-navy bg-brand-gold hover:bg-[#e0a600] rounded-xl shadow-xs transition-all hover:shadow-md"
            >
              <i class="fa-solid fa-arrow-right-to-bracket"></i>
              Masuk
            </router-link>
          </template>
        </div>

        <!-- Mobile Three Dots Menu Trigger (as in reference) -->
        <div class="relative flex items-center md:hidden">
          <button
            type="button"
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="w-10 h-10 rounded-xl flex items-center justify-center text-white hover:bg-white/15 active:bg-white/20 focus:outline-hidden transition-colors cursor-pointer"
            aria-label="Menu Opsi"
            :title="mobileMenuOpen ? 'Tutup menu' : 'Menu opsi'"
          >
            <i :class="mobileMenuOpen ? 'fa-solid fa-xmark text-lg' : 'fa-solid fa-ellipsis-vertical text-xl'"></i>
          </button>

          <!-- Floating Three-Dots Popup Card (Right-aligned, as in reference) -->
          <Transition
            enter-active-class="transition duration-150 ease-out origin-top-right"
            enter-from-class="opacity-0 scale-95 -translate-y-1"
            enter-to-class="opacity-100 scale-100 translate-y-0"
            leave-active-class="transition duration-100 ease-in origin-top-right"
            leave-from-class="opacity-100 scale-100 translate-y-0"
            leave-to-class="opacity-0 scale-95 -translate-y-1"
          >
            <div
              v-if="mobileMenuOpen"
              class="absolute right-0 top-full mt-2 w-64 bg-white rounded-2xl shadow-2xl shadow-slate-900/20 border border-slate-100 p-2.5 z-50 text-slate-800"
            >
              <div class="space-y-0.5">
                <router-link
                  to="/"
                  @click="mobileMenuOpen = false"
                  active-class="bg-blue-50 text-brand-navy font-bold"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-700 hover:text-brand-navy hover:bg-slate-50 transition-colors"
                >
                  <i class="fa-solid fa-house w-4 text-center text-indigo-500"></i>
                  <span>Beranda</span>
                </router-link>

                <router-link
                  to="/competitions"
                  @click="mobileMenuOpen = false"
                  active-class="bg-blue-50 text-brand-navy font-bold"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-700 hover:text-brand-navy hover:bg-slate-50 transition-colors"
                >
                  <i class="fa-solid fa-trophy w-4 text-center text-amber-500"></i>
                  <span>Katalog Kompetisi</span>
                </router-link>

                <router-link
                  to="/verify"
                  @click="mobileMenuOpen = false"
                  active-class="bg-blue-50 text-brand-navy font-bold"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-700 hover:text-brand-navy hover:bg-slate-50 transition-colors"
                >
                  <i class="fa-solid fa-qrcode w-4 text-center text-brand-blue"></i>
                  <span>Cek QR Prestasi</span>
                </router-link>

                <router-link
                  to="/school-registration"
                  @click="mobileMenuOpen = false"
                  active-class="bg-emerald-50 text-emerald-800 font-bold"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-emerald-700 hover:bg-emerald-50/70 transition-colors"
                >
                  <i class="fa-solid fa-school w-4 text-center text-emerald-600"></i>
                  <span>Daftarkan Sekolah</span>
                </router-link>
              </div>

              <div class="mt-2 pt-2 border-t border-slate-100">
                <template v-if="authStore.isAuthenticated">
                  <div class="mb-2 px-2.5 py-2 bg-slate-50 rounded-xl">
                    <p class="text-xs font-bold text-slate-800 truncate">{{ authStore.user?.name }}</p>
                    <p class="text-[10px] font-semibold text-slate-400 capitalize">
                      {{ authStore.isSuperAdmin ? 'Super Admin' : authStore.isSchoolAdmin ? 'Admin Sekolah' : 'Siswa' }}
                    </p>
                  </div>
                  <div class="grid grid-cols-2 gap-1.5">
                    <router-link
                      :to="getDashboardRoute()"
                      @click="mobileMenuOpen = false"
                      class="py-2 px-2 text-center text-xs font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl transition-colors flex items-center justify-center gap-1.5"
                    >
                      <i class="fa-solid fa-gauge-high text-[10px]"></i>
                      <span>Dashboard</span>
                    </router-link>
                    <button
                      type="button"
                      @click="handleLogout(); mobileMenuOpen = false"
                      class="py-2 px-2 text-center text-xs font-semibold text-rose-600 bg-rose-50 hover:bg-rose-100 rounded-xl transition-colors cursor-pointer flex items-center justify-center gap-1.5"
                    >
                      <i class="fa-solid fa-arrow-right-from-bracket text-[10px]"></i>
                      <span>Keluar</span>
                    </button>
                  </div>
                </template>

                <template v-else>
                  <router-link
                    to="/login"
                    @click="mobileMenuOpen = false"
                    class="w-full py-2.5 px-3 text-xs font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs transition-colors flex items-center justify-center gap-2"
                  >
                    <i class="fa-solid fa-arrow-right-to-bracket text-brand-gold"></i>
                    <span>Masuk ke Portal</span>
                  </router-link>
                </template>
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </div>

    <!-- Backdrop to close Three-Dots popup when clicking outside -->
    <div
      v-if="mobileMenuOpen"
      class="fixed inset-0 z-30 md:hidden bg-black/10"
      @click="mobileMenuOpen = false"
    ></div>
  </header>
</template>
