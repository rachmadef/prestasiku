<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const mobileSidebarOpen = ref(false)

const roleLabel = computed(() => {
  if (authStore.isSuperAdmin) return 'Super Administrator'
  if (authStore.isSchoolAdmin) return 'Admin Sekolah'
  if (authStore.isStudent) return 'Akun Siswa'
  return 'Pengguna'
})

const menuItems = computed(() => {
  if (authStore.isSuperAdmin) {
    return [
      { label: 'Dashboard Utama', path: '/admin/dashboard', icon: 'fa-solid fa-gauge-high' },
      { label: 'Pendaftaran Sekolah', path: '/admin/schools', icon: 'fa-solid fa-school-flag' },
      { label: 'Verifikasi Kompetisi', path: '/admin/competitions', icon: 'fa-solid fa-trophy' },
      { label: 'Penyelenggara (Organizers)', path: '/admin/organizers', icon: 'fa-solid fa-building-columns' },
      { label: 'Kategori Kompetisi', path: '/admin/categories', icon: 'fa-solid fa-tags' },
    ]
  }

  if (authStore.isSchoolAdmin) {
    return [
      { label: 'Dashboard Sekolah', path: '/school/dashboard', icon: 'fa-solid fa-gauge-high' },
      { label: 'Manajemen Siswa', path: '/school/students', icon: 'fa-solid fa-user-graduate' },
      { label: 'Arsip Partisipasi Siswa', path: '/school/registrations', icon: 'fa-solid fa-clipboard-check' },
      { label: 'Perizinan Dispensasi KBM', path: '/school/dispensations', icon: 'fa-solid fa-file-signature' },
      { label: 'Rekam Prestasi Juara', path: '/school/achievements', icon: 'fa-solid fa-medal' },
    ]
  }

  if (authStore.isStudent) {
    return [
      { label: 'Beranda Siswa', path: '/student/dashboard', icon: 'fa-solid fa-gauge-high' },
      { label: 'Arsip Riwayat Lomba', path: '/student/portfolio', icon: 'fa-solid fa-folder-open' },
      { label: 'Izin Dispensasi KBM', path: '/student/dispensations', icon: 'fa-solid fa-file-signature' },
      { label: 'Katalog Lomba Resmi', path: '/student/competitions', icon: 'fa-solid fa-compass' },
      { label: 'Pendaftaran Saya', path: '/student/registrations', icon: 'fa-solid fa-receipt' },
      { label: 'Piagam Juara & QR', path: '/student/achievements', icon: 'fa-solid fa-award' },
    ]
  }

  return []
})

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<template>
  <div class="h-screen w-full bg-[#F3F1EF] flex overflow-hidden">
    <!-- Desktop Sidebar (Navy Background #001D60) -->
    <aside class="hidden lg:flex lg:flex-col lg:w-68 h-full bg-brand-navy text-white shrink-0 shadow-xl border-r border-blue-950/40 select-none">
      <!-- Sidebar Brand Header -->
      <div class="h-20 shrink-0 flex items-center gap-3 px-6 border-b border-white/10">
        <img src="/img/icon-white.png" alt="PrestasiKu Icon" class="h-9 w-auto" />
        <img src="/img/text-white.png" alt="PrestasiKu Logo" class="h-6 w-auto" />
      </div>

      <!-- Role Indicator Pill -->
      <div class="shrink-0 px-6 py-4 border-b border-white/5 bg-white/3">
        <p class="text-[10px] uppercase font-bold tracking-wider text-brand-gold">Role Akses</p>
        <p class="text-sm font-semibold text-white truncate">{{ roleLabel }}</p>
        <p v-if="authStore.user?.school" class="text-xs text-slate-300 truncate mt-0.5">
          <i class="fa-solid fa-school text-[10px] mr-1 text-slate-400"></i>
          {{ authStore.user.school.name }}
        </p>
        <p v-else-if="authStore.user?.student" class="text-xs text-slate-300 truncate mt-0.5">
          <i class="fa-solid fa-id-card text-[10px] mr-1 text-slate-400"></i>
          {{ authStore.user.student.class_name }} • NIS {{ authStore.user.student.nis }}
        </p>
      </div>

      <!-- Navigation Menu -->
      <nav class="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto">
        <router-link
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          :class="[
            'flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-semibold transition-all group',
            route.path === item.path
              ? 'bg-white/15 text-white shadow-xs border-l-4 border-brand-gold pl-2.5'
              : 'text-slate-300 hover:text-white hover:bg-white/8'
          ]"
        >
          <i :class="[item.icon, 'text-base w-5 text-center transition-transform group-hover:scale-110', route.path === item.path ? 'text-brand-gold' : 'text-slate-300']"></i>
          <span>{{ item.label }}</span>
        </router-link>

        <div class="pt-4 mt-4 border-t border-white/10">
          <p class="px-3 text-[10px] uppercase font-bold tracking-wider text-slate-400 mb-2">Tautan Publik</p>
          <router-link
            to="/competitions"
            target="_blank"
            class="flex items-center gap-3 px-3.5 py-2 rounded-xl text-xs text-slate-300 hover:text-white hover:bg-white/8 transition-colors"
          >
            <i class="fa-solid fa-arrow-up-right-from-square text-xs text-brand-gold w-5 text-center"></i>
            <span>Katalog Publik</span>
          </router-link>
          <router-link
            to="/verify"
            target="_blank"
            class="flex items-center gap-3 px-3.5 py-2 rounded-xl text-xs text-slate-300 hover:text-white hover:bg-white/8 transition-colors"
          >
            <i class="fa-solid fa-qrcode text-xs text-brand-blue w-5 text-center"></i>
            <span>Cek QR Publik</span>
          </router-link>
        </div>
      </nav>

      <!-- Sidebar Footer / Logout -->
      <div class="shrink-0 p-4 border-t border-white/10 bg-white/3">
        <button
          type="button"
          @click="handleLogout"
          class="w-full flex items-center justify-center gap-2 px-3 py-2 text-xs font-semibold text-rose-300 hover:text-white hover:bg-rose-600/30 rounded-xl border border-rose-500/20 transition-all"
        >
          <i class="fa-solid fa-arrow-right-from-bracket"></i>
          <span>Keluar Portal</span>
        </button>
      </div>
    </aside>

    <!-- Mobile Drawer -->
    <div
      v-if="mobileSidebarOpen"
      class="fixed inset-0 z-50 lg:hidden flex"
      role="dialog"
      aria-modal="true"
    >
      <div class="fixed inset-0 bg-slate-900/60 transition-opacity" @click="mobileSidebarOpen = false"></div>
      <div class="relative flex-1 flex flex-col max-w-xs w-full bg-brand-navy text-white z-10">
        <div class="h-16 flex items-center justify-between px-5 border-b border-white/10">
          <div class="flex items-center gap-2">
            <img src="/img/icon-white.png" alt="PrestasiKu Icon" class="h-8 w-auto" />
            <img src="/img/text-white.png" alt="PrestasiKu Logo" class="h-5 w-auto" />
          </div>
          <button @click="mobileSidebarOpen = false" class="text-white p-1">
            <i class="fa-solid fa-xmark text-xl"></i>
          </button>
        </div>
        <nav class="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto">
          <router-link
            v-for="item in menuItems"
            :key="item.path"
            :to="item.path"
            @click="mobileSidebarOpen = false"
            :class="[
              'flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold',
              route.path === item.path ? 'bg-white/15 text-white border-l-4 border-brand-gold' : 'text-slate-300'
            ]"
          >
            <i :class="[item.icon, 'text-base w-5 text-center', route.path === item.path ? 'text-brand-gold' : 'text-slate-400']"></i>
            <span>{{ item.label }}</span>
          </router-link>
        </nav>
        <div class="p-4 border-t border-white/10">
          <button
            @click="handleLogout(); mobileSidebarOpen = false"
            class="w-full flex items-center justify-center gap-2 py-2 text-xs font-semibold text-rose-300 bg-rose-900/30 rounded-xl"
          >
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
            Keluar Portal
          </button>
        </div>
      </div>
    </div>

    <!-- Main Workspace Content -->
    <div class="flex-1 flex flex-col min-w-0 h-full overflow-hidden">
      <!-- Top Header -->
      <header class="h-18 shrink-0 bg-white border-b border-slate-200/80 shadow-2xs flex items-center justify-between px-4 sm:px-6 lg:px-8 z-10">
        <div class="flex items-center gap-3">
          <!-- Mobile Toggle -->
          <button
            type="button"
            @click="mobileSidebarOpen = true"
            class="lg:hidden p-2 rounded-xl text-slate-600 hover:bg-slate-100"
          >
            <i class="fa-solid fa-bars text-lg"></i>
          </button>
          <div>
            <h1 class="text-base sm:text-lg font-bold text-slate-800 tracking-tight leading-none">
              <slot name="header-title">Portal PrestasiKu</slot>
            </h1>
            <p class="text-xs text-slate-500 mt-1 hidden sm:block">
              <slot name="header-subtitle">Platform Manajemen Kompetisi & Prestasi Pelajar</slot>
            </p>
          </div>
        </div>

        <!-- Right User Pill -->
        <div class="flex items-center gap-3">
          <div class="hidden sm:flex flex-col text-right">
            <span class="text-xs font-bold text-slate-800">{{ authStore.user?.name }}</span>
            <span class="text-[11px] text-slate-500">{{ authStore.user?.email || authStore.user?.username }}</span>
          </div>
          <div class="w-9 h-9 rounded-xl bg-brand-navy text-white flex items-center justify-center font-bold text-xs shadow-xs">
            {{ authStore.user?.name?.charAt(0) || 'U' }}
          </div>
        </div>
      </header>

      <!-- Password Change Notice if mandatory -->
      <div
        v-if="authStore.user?.must_change_password"
        class="shrink-0 bg-amber-500 text-brand-navy px-6 py-2.5 flex items-center justify-between text-xs font-semibold shadow-xs"
      >
        <div class="flex items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-base"></i>
          <span>Perhatian: Anda masih menggunakan password sementara. Wajib mengganti password demi keamanan akun.</span>
        </div>
        <router-link
          to="/force-change-password"
          class="underline font-bold hover:text-white transition-colors"
        >
          Ganti Sekarang &rarr;
        </router-link>
      </div>

      <!-- Main Scrollable Body -->
      <main class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
        <slot></slot>
      </main>
    </div>
  </div>
</template>
