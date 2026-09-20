<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import Badge from '@/components/common/Badge.vue'
import { useAuthStore } from '@/stores/auth'
import api, { extractList } from '@/services/api'

const authStore = useAuthStore()
const loading = ref(true)
const registrations = ref<any[]>([])
const achievements = ref<any[]>([])
const featuredCompetitions = ref<any[]>([])

async function fetchStudentData() {
  loading.value = true
  try {
    const [regRes, achRes, compRes] = await Promise.all([
      api.get('/student/registrations').catch(() => ({ data: { data: [] } })),
      api.get('/student/achievements').catch(() => ({ data: { data: [] } })),
      api.get('/competitions?status=published&per_page=3').catch(() => ({ data: { data: [] } })),
    ])
    registrations.value = extractList(regRes.data.data)
    achievements.value = extractList(achRes.data.data)
    featuredCompetitions.value = extractList(compRes.data.data)
  } catch (err) {
    console.error('Error loading student dashboard:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchStudentData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Portal Prestasi Siswa</template>
    <template #header-subtitle>
      Selamat datang, {{ authStore.user?.name }} • {{ authStore.user?.student?.class_name || 'Pelajar' }}
    </template>

    <div class="space-y-8">
      <!-- Welcome Hero Banner -->
      <div class="rounded-3xl bg-gradient-to-r from-brand-navy via-[#0A2E7A] to-brand-blue text-white p-6 sm:p-8 shadow-md relative overflow-hidden">
        <div class="relative z-10 max-w-xl space-y-2">
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-brand-gold/20 text-brand-gold text-xs font-bold border border-brand-gold/30">
            <i class="fa-solid fa-graduation-cap"></i>
            Pelajar Berprestasi
          </span>
          <h2 class="text-xl sm:text-2xl font-black tracking-tight">
            Kembangkan Bakat & Ukir Prestasi Terbaikmu!
          </h2>
          <p class="text-xs sm:text-sm text-slate-200 leading-relaxed">
            Temukan kompetisi yang sesuai dengan jenjang kelasmu, ajukan delegasi sekolah, dan kumpulkan sertifikat ber-QR terverifikasi untuk portofolio masa depanmu.
          </p>
          <div class="pt-2">
            <router-link
              to="/student/competitions"
              class="inline-flex items-center gap-2 px-4 py-2 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-all"
            >
              <span>Jelajah Lomba & Cek Kelayakan</span>
              <i class="fa-solid fa-arrow-right"></i>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Quick Metrics -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <StatCard
          title="Kompetisi Terdaftar"
          :value="registrations.length"
          icon="fa-solid fa-receipt"
          variant="blue"
          subtitle="Riwayat pengajuan delegasi"
        />
        <StatCard
          title="Prestasi Terverifikasi"
          :value="achievements.filter(a => a.verification_status === 'verified').length"
          icon="fa-solid fa-trophy"
          variant="gold"
          subtitle="Sertifikat resmi ber-QR"
        />
      </div>

      <!-- Section: Registrations & Upcoming Competitions -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- My Active Registrations -->
        <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-clipboard-list text-brand-blue"></i>
                Status Pendaftaran Saya
              </h2>
              <p class="text-xs text-slate-500">Pantau proses persetujuan pihak sekolah dan status keikutsertaan.</p>
            </div>
            <router-link to="/student/registrations" class="text-xs font-bold text-brand-blue hover:underline">
              Semua &rarr;
            </router-link>
          </div>

          <div v-if="registrations.length === 0" class="py-8 text-center text-slate-400 text-xs">
            Kamu belum mendaftar ke kompetisi manapun. Yuk jelajah lomba sekarang!
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="reg in registrations.slice(0, 4)"
              :key="reg.id"
              class="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-between"
            >
              <div>
                <h3 class="text-xs font-bold text-slate-800">{{ reg.competition?.name || 'Kompetisi' }}</h3>
                <p class="text-[11px] text-slate-500 mt-0.5">
                  Diajukan pada: {{ reg.created_at ? reg.created_at.split('T')[0] : '-' }}
                </p>
              </div>
              <Badge :status="reg.status" />
            </div>
          </div>
        </div>

        <!-- Recommended Competitions -->
        <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-compass text-brand-gold"></i>
                Kompetisi Buka Pendaftaran
              </h2>
              <p class="text-xs text-slate-500">Kompetisi terverifikasi yang dapat kamu ikuti saat ini.</p>
            </div>
            <router-link to="/student/competitions" class="text-xs font-bold text-brand-blue hover:underline">
              Katalog &rarr;
            </router-link>
          </div>

          <div v-if="featuredCompetitions.length === 0" class="py-8 text-center text-slate-400 text-xs">
            Belum ada kompetisi baru.
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="comp in featuredCompetitions"
              :key="comp.id"
              class="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-between"
            >
              <div class="pr-2">
                <h3 class="text-xs font-bold text-slate-800 line-clamp-1">{{ comp.name }}</h3>
                <p class="text-[11px] text-slate-500 mt-0.5">{{ comp.category?.name }} • {{ comp.scope }}</p>
              </div>
              <router-link
                :to="`/competitions/${comp.slug || comp.id}`"
                class="px-3 py-1.5 bg-brand-navy text-white text-xs font-semibold rounded-lg shadow-2xs hover:bg-[#001442] shrink-0"
              >
                Cek Syarat
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
