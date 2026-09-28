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
  if (authStore.isSchoolAdmin) return 'Admin Sekolah / Kesiswaan'
  if (authStore.isStudent) return 'Siswa Terdaftar'
  return 'Pengguna'
})

// Real date in Indonesian
const todayFormatted = computed(() => {
  try {
    return new Intl.DateTimeFormat('id-ID', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }).format(new Date())
  } catch {
    return 'Hari ini'
  }
})

const profileRoute = computed(() => {
  if (authStore.isSuperAdmin) return '/admin/profile'
  if (authStore.isSchoolAdmin) return '/school/profile'
  if (authStore.isStudent) return '/student/profile'
  return '/profile'
})

// Semantic Menu Groups
interface MenuGroup {
  title?: string
  items: {
    label: string
    path: string
    icon: string
    badge?: string
  }[]
}

const menuGroups = computed<MenuGroup[]>(() => {
  if (authStore.isSuperAdmin) {
    return [
      {
        title: 'Pengawasan Sistem',
        items: [
          { label: 'Dashboard Utama', path: '/admin/dashboard', icon: 'fa-solid fa-chart-pie' },
          { label: 'Verifikasi Sekolah', path: '/admin/schools', icon: 'fa-solid fa-school-flag' },
          { label: 'Moderasi Kompetisi', path: '/admin/competitions', icon: 'fa-solid fa-trophy' },
        ],
      },
      {
        title: 'Master Data',
        items: [
          { label: 'Penyelenggara Resmi', path: '/admin/organizers', icon: 'fa-solid fa-building-columns' },
          { label: 'Kategori Lomba', path: '/admin/categories', icon: 'fa-solid fa-tags' },
        ],
      },
      {
        title: 'Pengaturan Akun',
        items: [
          { label: 'Profil & Keamanan', path: '/admin/profile', icon: 'fa-solid fa-user-shield' },
        ],
      },
    ]
  }

  if (authStore.isSchoolAdmin) {
    return [
      {
        title: 'Operasional Sekolah',
        items: [
          { label: 'Dashboard Sekolah', path: '/school/dashboard', icon: 'fa-solid fa-gauge-high' },
          { label: 'Perizinan Dispensasi KBM', path: '/school/dispensations', icon: 'fa-solid fa-file-signature' },
          { label: 'Format Surat & Kop Dinas', path: '/school/dispensations/form-settings', icon: 'fa-solid fa-stamp' },
          { label: 'Arsip Partisipasi Siswa', path: '/school/registrations', icon: 'fa-solid fa-clipboard-check' },
        ],
      },
      {
        title: 'Basis Data & Prestasi',
        items: [
          { label: 'Buku Induk Siswa', path: '/school/students', icon: 'fa-solid fa-user-graduate' },
          { label: 'Rekam Prestasi Juara', path: '/school/achievements', icon: 'fa-solid fa-medal' },
        ],
      },
      {
        title: 'Pengaturan Akun',
        items: [
          { label: 'Profil & Keamanan', path: '/school/profile', icon: 'fa-solid fa-user-shield' },
        ],
      },
    ]
  }

  if (authStore.isStudent) {
    return [
      {
        title: 'Aktivitas Saya',
        items: [
          { label: 'Beranda Siswa', path: '/student/dashboard', icon: 'fa-solid fa-house-user' },
          { label: 'Izin Dispensasi KBM', path: '/student/dispensations', icon: 'fa-solid fa-file-signature' },
        ],
      },
      {
        title: 'Rekam Jejak Lomba',
        items: [
          { label: 'Arsip Riwayat Lomba', path: '/student/portfolio', icon: 'fa-solid fa-folder-open' },
          { label: 'Piagam Juara & QR', path: '/student/achievements', icon: 'fa-solid fa-award' },
          { label: 'Pendaftaran Saya', path: '/student/registrations', icon: 'fa-solid fa-receipt' },
        ],
      },
      {
        title: 'Eksplorasi',
        items: [
          { label: 'Katalog Lomba Resmi', path: '/student/competitions', icon: 'fa-solid fa-compass' },
        ],
      },
      {
        title: 'Pengaturan Akun',
        items: [
          { label: 'Profil & Keamanan', path: '/student/profile', icon: 'fa-solid fa-user-shield' },
        ],
      },
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
  <div class="h-screen w-full bg-[#F3F1EF] flex overflow-hidden font-sans">
    <!-- Desktop Sidebar (Formal Navy #001D60) -->
    <aside class="hidden lg:flex lg:flex-col lg:w-70 h-full bg-brand-navy text-white shrink-0 shadow-lg border-r border-blue-950/40 select-none">
      <!-- Sidebar Brand Header -->
      <div class="h-20 shrink-0 flex items-center justify-between px-6 border-b border-white/10 bg-brand-navy">
        <div class="flex items-center gap-3">
          <img src="/img/icon-white.png" alt="PrestasiKu" class="h-9 w-auto" />
          <div>
            <img src="/img/text-white.png" alt="PrestasiKu" class="h-5 w-auto" />
            <p class="text-[10px] text-blue-200/70 font-medium tracking-tight mt-0.5">Sistem Prestasi & Dispensasi</p>
          </div>
        </div>
      </div>

      <!-- School or Student Affiliation Badge -->
      <div class="shrink-0 px-6 py-3.5 border-b border-white/8 bg-black/15">
        <div class="flex items-center gap-2.5">
          <div class="w-8 h-8 rounded-lg bg-white/10 text-brand-gold flex items-center justify-center text-xs shrink-0">
            <i :class="authStore.isStudent ? 'fa-solid fa-graduation-cap' : 'fa-solid fa-school'"></i>
          </div>
          <div class="min-w-0 flex-1">
            <p class="text-[10px] font-bold uppercase tracking-wider text-brand-gold truncate">
              {{ roleLabel }}
            </p>
            <p v-if="authStore.user?.school" class="text-xs font-semibold text-white truncate leading-tight mt-0.5">
              {{ authStore.user.school.name }}
            </p>
            <p v-else-if="authStore.user?.student" class="text-xs font-semibold text-white truncate leading-tight mt-0.5">
              {{ authStore.user.student.class_name }} • NIS {{ authStore.user.student.nis }}
            </p>
            <p v-else class="text-xs font-medium text-slate-300 truncate leading-tight mt-0.5">
              Pusat Manajemen
            </p>
          </div>
        </div>
      </div>

      <!-- Navigation Menu Groups -->
      <nav class="flex-1 px-4 py-4 space-y-6 overflow-y-auto">
        <div v-for="(group, gIdx) in menuGroups" :key="gIdx" class="space-y-1">
          <p
            v-if="group.title"
            class="px-3 text-[10px] uppercase font-bold tracking-wider text-blue-200/50 mb-2"
          >
            {{ group.title }}
          </p>

          <router-link
            v-for="item in group.items"
            :key="item.path"
            :to="item.path"
            :class="[
              'flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all group',
              route.path === item.path
                ? 'bg-white/15 text-white font-bold shadow-xs border-l-3 border-brand-gold pl-2.5'
                : 'text-blue-100/80 hover:text-white hover:bg-white/8'
            ]"
          >
            <div class="flex items-center gap-3 min-w-0">
              <i
                :class="[
                  item.icon,
                  'text-sm w-4 text-center transition-colors',
                  route.path === item.path ? 'text-brand-gold' : 'text-blue-200/60 group-hover:text-blue-100'
                ]"
              ></i>
              <span class="truncate">{{ item.label }}</span>
            </div>
            <span
              v-if="item.badge"
              class="px-1.5 py-0.5 text-[9px] font-bold rounded-md bg-brand-gold text-brand-navy"
            >
              {{ item.badge }}
            </span>
          </router-link>
        </div>

        <!-- Public Links Section -->
        <div class="pt-3 border-t border-white/10 space-y-1">
          <p class="px-3 text-[10px] uppercase font-bold tracking-wider text-blue-200/50 mb-2">Layanan Publik</p>
          <router-link
            to="/competitions"
            target="_blank"
            class="flex items-center gap-3 px-3 py-2 rounded-xl text-xs text-blue-100/70 hover:text-white hover:bg-white/8 transition-colors"
          >
            <i class="fa-solid fa-arrow-up-right-from-square text-xs text-brand-gold w-4 text-center"></i>
            <span>Katalog Resmi Lomba</span>
          </router-link>
          <router-link
            to="/verify"
            target="_blank"
            class="flex items-center gap-3 px-3 py-2 rounded-xl text-xs text-blue-100/70 hover:text-white hover:bg-white/8 transition-colors"
          >
            <i class="fa-solid fa-qrcode text-xs text-sky-400 w-4 text-center"></i>
            <span>Verifikasi QR Prestasi</span>
          </router-link>
          <router-link
            to="/dispensasi/verifikasi"
            target="_blank"
            class="flex items-center gap-3 px-3 py-2 rounded-xl text-xs text-blue-100/70 hover:text-white hover:bg-white/8 transition-colors"
          >
            <i class="fa-solid fa-shield-check text-xs text-emerald-400 w-4 text-center"></i>
            <span>Verifikasi Surat Dispensasi</span>
          </router-link>
        </div>
      </nav>

      <!-- Sidebar Footer / Human Profile Card -->
      <div class="shrink-0 p-4 border-t border-white/10 bg-black/20">
        <div class="flex items-center justify-between gap-3">
          <router-link
            :to="profileRoute"
            class="flex items-center gap-2.5 min-w-0 flex-1 hover:opacity-90 transition-opacity group cursor-pointer"
            title="Buka Profil & Pengaturan Keamanan"
          >
            <div class="w-8 h-8 rounded-full bg-brand-blue text-white font-bold text-xs flex items-center justify-center shrink-0 border border-white/20 group-hover:scale-105 transition-transform">
              {{ authStore.user?.name?.charAt(0) || 'U' }}
            </div>
            <div class="min-w-0 flex-1">
              <p class="text-xs font-semibold text-white truncate leading-tight group-hover:text-brand-gold transition-colors">
                {{ authStore.user?.name }}
              </p>
              <p class="text-[10px] text-blue-200/70 truncate">
                {{ authStore.user?.username || authStore.user?.email }}
              </p>
            </div>
          </router-link>

          <button
            type="button"
            @click="handleLogout"
            class="p-2 text-blue-200/70 hover:text-rose-300 hover:bg-white/10 rounded-lg transition-colors cursor-pointer shrink-0"
            title="Keluar dari Portal"
          >
            <i class="fa-solid fa-arrow-right-from-bracket text-sm"></i>
          </button>
        </div>
      </div>
    </aside>

    <!-- Mobile Drawer -->
    <Transition name="mobile-sidebar">
      <div
        v-if="mobileSidebarOpen"
        class="fixed inset-0 z-50 lg:hidden flex"
        role="dialog"
        aria-modal="true"
      >
        <div class="sidebar-backdrop fixed inset-0 bg-slate-900/60 backdrop-blur-xs" @click="mobileSidebarOpen = false"></div>
        <div class="sidebar-panel relative flex-1 flex flex-col max-w-xs w-full bg-brand-navy text-white z-10 shadow-2xl">
          <div class="h-16 flex items-center justify-between px-5 border-b border-white/10">
            <div class="flex items-center gap-2">
              <img src="/img/icon-white.png" alt="PrestasiKu" class="h-8 w-auto" />
              <img src="/img/text-white.png" alt="PrestasiKu" class="h-5 w-auto" />
            </div>
            <button @click="mobileSidebarOpen = false" class="text-white p-1 cursor-pointer">
              <i class="fa-solid fa-xmark text-xl"></i>
            </button>
          </div>

          <nav class="flex-1 px-4 py-4 space-y-4 overflow-y-auto">
            <div v-for="(group, gIdx) in menuGroups" :key="gIdx" class="space-y-1">
              <p v-if="group.title" class="px-3 text-[10px] uppercase font-bold tracking-wider text-blue-200/50 mb-1">
                {{ group.title }}
              </p>
              <router-link
                v-for="item in group.items"
                :key="item.path"
                :to="item.path"
                @click="mobileSidebarOpen = false"
                :class="[
                  'flex items-center gap-3 px-3 py-2 rounded-xl text-xs font-medium transition-colors',
                  route.path === item.path ? 'bg-white/15 text-white font-bold border-l-3 border-brand-gold' : 'text-blue-100/80 hover:bg-white/10'
                ]"
              >
                <i :class="[item.icon, 'text-sm w-4 text-center', route.path === item.path ? 'text-brand-gold' : 'text-blue-200/60']"></i>
                <span>{{ item.label }}</span>
              </router-link>
            </div>
          </nav>

          <div class="p-4 border-t border-white/10 bg-black/20">
            <button
              @click="handleLogout(); mobileSidebarOpen = false"
              class="w-full flex items-center justify-center gap-2 py-2 text-xs font-semibold text-rose-200 bg-rose-950/40 hover:bg-rose-900/60 rounded-xl border border-rose-800/30 transition-colors cursor-pointer"
            >
              <i class="fa-solid fa-arrow-right-from-bracket"></i>
              Keluar Portal
            </button>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Main Workspace Area -->
    <div class="flex-1 flex flex-col min-w-0 h-full overflow-hidden">
      <!-- Humanized Clean Top Header Bar -->
      <header class="h-16 shrink-0 bg-white border-b border-slate-200/80 shadow-xs flex items-center justify-between px-4 sm:px-6 lg:px-8 z-10">
        <div class="flex items-center gap-3">
          <!-- Mobile Toggle Button -->
          <button
            type="button"
            @click="mobileSidebarOpen = true"
            class="lg:hidden p-2 rounded-xl text-slate-600 hover:bg-slate-100 cursor-pointer"
          >
            <i class="fa-solid fa-bars text-lg"></i>
          </button>

          <!-- Contextual Breadcrumb / Page Title -->
          <div class="flex items-center gap-2">
            <span class="text-xs font-medium text-slate-400 hidden sm:inline">PrestasiKu</span>
            <span class="text-slate-300 hidden sm:inline">/</span>
            <h1 class="text-sm sm:text-base font-bold text-slate-800 tracking-tight leading-none">
              <slot name="header-title">Portal Utama</slot>
            </h1>
          </div>
        </div>

        <!-- Right Side: Indonesian Date & School Affiliation -->
        <div class="flex items-center gap-3 sm:gap-4">
          <!-- Calendar Date Pill -->
          <div class="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-lg bg-slate-50 border border-slate-200/70 text-slate-600 text-xs font-medium">
            <i class="fa-regular fa-calendar-check text-brand-navy"></i>
            <span>{{ todayFormatted }}</span>
          </div>

          <!-- Active Institution Tag -->
          <div
            v-if="authStore.user?.school"
            class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-50 border border-blue-200/70 text-brand-navy text-xs font-semibold"
          >
            <i class="fa-solid fa-building-columns text-brand-blue"></i>
            <span class="max-w-44 truncate">{{ authStore.user.school.name }}</span>
          </div>

          <!-- User Initial Badge / Profile Link -->
          <router-link
            :to="profileRoute"
            class="flex items-center gap-2 hover:opacity-85 transition-opacity"
            title="Profil Saya & Pengaturan Keamanan"
          >
            <div class="w-8 h-8 rounded-lg bg-brand-navy text-white flex items-center justify-center font-bold text-xs shadow-xs hover:ring-2 hover:ring-brand-gold transition-all">
              {{ authStore.user?.name?.charAt(0) || 'U' }}
            </div>
          </router-link>
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

      <!-- Main Workspace Scrollable Container -->
      <main class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
        <slot></slot>
      </main>
    </div>
  </div>
</template>

<style scoped>
/* Mobile Sidebar In/Out Animations */
.mobile-sidebar-enter-active,
.mobile-sidebar-leave-active {
  transition: opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.mobile-sidebar-enter-from,
.mobile-sidebar-leave-to {
  opacity: 0;
}

.mobile-sidebar-enter-active .sidebar-backdrop,
.mobile-sidebar-leave-active .sidebar-backdrop {
  transition: opacity 0.3s ease-in-out;
}

.mobile-sidebar-enter-from .sidebar-backdrop,
.mobile-sidebar-leave-to .sidebar-backdrop {
  opacity: 0;
}

.mobile-sidebar-enter-active .sidebar-panel,
.mobile-sidebar-leave-active .sidebar-panel {
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.mobile-sidebar-enter-from .sidebar-panel,
.mobile-sidebar-leave-to .sidebar-panel {
  transform: translateX(-100%);
}
</style>
