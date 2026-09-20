<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import Badge from '@/components/common/Badge.vue'
import { useAuthStore } from '@/stores/auth'
import api, { extractList } from '@/services/api'

const authStore = useAuthStore()
const loading = ref(true)
const students = ref<any[]>([])
const registrations = ref<any[]>([])
const achievements = ref<any[]>([])

const stats = ref({
  totalStudents: 0,
  pendingRegistrations: 0,
  verifiedAchievements: 0,
})

async function fetchSchoolData() {
  loading.value = true
  try {
    const [studRes, regRes, achRes] = await Promise.all([
      api.get('/school/students').catch(() => ({ data: { data: [] } })),
      api.get('/school/registrations').catch(() => ({ data: { data: [] } })),
      api.get('/school/achievements').catch(() => ({ data: { data: [] } })),
    ])
    students.value = extractList(studRes.data.data)
    registrations.value = extractList(regRes.data.data)
    achievements.value = extractList(achRes.data.data)

    stats.value.totalStudents = students.value.length
    stats.value.pendingRegistrations = registrations.value.filter((r: any) => r.status === 'submitted' || r.status === 'in_review').length
    stats.value.verifiedAchievements = achievements.value.filter((a: any) => a.verification_status === 'verified').length
  } catch (err) {
    console.error('Error loading school dashboard:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchSchoolData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Pusat Operasional Sekolah (School Hub)</template>
    <template #header-subtitle>{{ authStore.user?.school?.name }} • NPSN: {{ authStore.user?.school?.npsn }}</template>

    <div class="space-y-8">
      <!-- Quick Metric Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          title="Total Siswa Terdaftar"
          :value="stats.totalStudents"
          icon="fa-solid fa-user-graduate"
          variant="navy"
          subtitle="Tenant sekolah aktif"
        />
        <StatCard
          title="Pengajuan Delegasi Pending"
          :value="stats.pendingRegistrations"
          icon="fa-solid fa-clipboard-question"
          variant="gold"
          subtitle="Menunggu persetujuan sekolah"
        />
        <StatCard
          title="Prestasi Terverifikasi"
          :value="stats.verifiedAchievements"
          icon="fa-solid fa-medal"
          variant="emerald"
          subtitle="Memiliki QR resmi"
        />
      </div>

      <!-- Action Shortcut Banner -->
      <div class="p-6 rounded-3xl bg-gradient-to-r from-brand-navy to-brand-blue text-white shadow-lg flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="space-y-1 text-center sm:text-left">
          <h2 class="text-base font-bold flex items-center justify-center sm:justify-start gap-2">
            <i class="fa-solid fa-bolt text-brand-gold"></i>
            Aksi Cepat Operasional
          </h2>
          <p class="text-xs text-slate-200">
            Unggah data siswa secara massal menggunakan template Excel atau daftarkan delegasi lomba langsung.
          </p>
        </div>
        <div class="flex items-center gap-2 shrink-0">
          <router-link
            to="/school/students"
            class="px-4 py-2 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-all flex items-center gap-1.5"
          >
            <i class="fa-solid fa-file-excel"></i>
            <span>Import Siswa</span>
          </router-link>
          <router-link
            to="/school/registrations"
            class="px-4 py-2 bg-white/15 hover:bg-white/25 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all"
          >
            Tinjau Delegasi
          </router-link>
        </div>
      </div>

      <!-- Pending Delegations Desk -->
      <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs space-y-4">
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
              <i class="fa-solid fa-clipboard-check text-brand-blue"></i>
              Pengajuan Delegasi Lomba Terbaru
            </h2>
            <p class="text-xs text-slate-500">Permohonan persetujuan sekolah yang diajukan oleh siswa untuk mengikuti kompetisi.</p>
          </div>
          <router-link to="/school/registrations" class="text-xs font-bold text-brand-blue hover:underline">
            Lihat Semua &rarr;
          </router-link>
        </div>

        <div v-if="registrations.length === 0" class="py-8 text-center text-slate-400 text-xs">
          Belum ada pendaftaran delegasi lomba dari siswa.
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="reg in registrations.slice(0, 5)"
            :key="reg.id"
            class="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-between"
          >
            <div>
              <h3 class="text-xs font-bold text-slate-800">{{ reg.competition?.name || 'Kompetisi' }}</h3>
              <p class="text-[11px] text-slate-500 mt-0.5">
                Siswa: <span class="font-semibold text-slate-700">{{ reg.student?.full_name || reg.student?.user?.name }}</span>
                (Kelas {{ reg.student?.class_name }})
              </p>
            </div>
            <div class="flex items-center gap-3">
              <Badge :status="reg.status" />
              <router-link
                to="/school/registrations"
                class="px-3 py-1.5 bg-brand-navy text-white text-xs font-semibold rounded-lg shadow-2xs hover:bg-[#001442]"
              >
                Detail
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
