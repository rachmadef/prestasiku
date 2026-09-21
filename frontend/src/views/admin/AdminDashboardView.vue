<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import Badge from '@/components/common/Badge.vue'
import api, { extractList } from '@/services/api'

const loading = ref(true)
const pendingSchools = ref<any[]>([])
const competitions = ref<any[]>([])
const stats = ref({
  pendingSchoolsCount: 0,
  inReviewCompetitionsCount: 0,
  verifiedSchoolsCount: 0,
  publishedCompetitionsCount: 0,
})

async function fetchDashboardData() {
  loading.value = true
  try {
    const [schoolsRes, compsRes, regSchoolsRes] = await Promise.all([
      api.get('/admin/school-registrations').catch(() => ({ data: { data: [] } })),
      api.get('/admin/competitions').catch(() => ({ data: { data: [] } })),
      api.get('/admin/schools').catch(() => ({ data: { data: [] } })),
    ])

    const allRegs = extractList(schoolsRes.data.data)
    pendingSchools.value = allRegs.filter((r: any) => r.status === 'pending')
    stats.value.pendingSchoolsCount = pendingSchools.value.length

    const allComps = extractList(compsRes.data.data)
    competitions.value = allComps
    stats.value.inReviewCompetitionsCount = allComps.filter((c: any) => c.verification_status === 'in_review').length
    stats.value.publishedCompetitionsCount = allComps.filter((c: any) => c.verification_status === 'published').length

    const allVerifiedSchools = extractList(regSchoolsRes.data.data)
    stats.value.verifiedSchoolsCount = allVerifiedSchools.length
  } catch (err) {
    console.error('Error fetching admin stats:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Dashboard Super Administrator</template>
    <template #header-subtitle>Pusat kendali, moderasi sekolah, dan verifikasi pipeline kompetisi nasional.</template>

    <div class="space-y-8">
      <!-- Top Stat Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Pengajuan Sekolah Pending"
          :value="stats.pendingSchoolsCount"
          icon="fa-solid fa-school-flag"
          variant="gold"
          subtitle="Memerlukan tinjauan NPSN"
        />
        <StatCard
          title="Lomba Perlu Verifikasi"
          :value="stats.inReviewCompetitionsCount"
          icon="fa-solid fa-hourglass-half"
          variant="blue"
          subtitle="Pipeline verifikasi sumber"
        />
        <StatCard
          title="Total Sekolah Terdaftar"
          :value="stats.verifiedSchoolsCount"
          icon="fa-solid fa-building-columns"
          variant="navy"
          subtitle="Tenant sekolah aktif"
        />
        <StatCard
          title="Kompetisi Dipublikasikan"
          :value="stats.publishedCompetitionsCount"
          icon="fa-solid fa-trophy"
          variant="emerald"
          subtitle="Dapat diakses publik"
        />
      </div>

      <!-- Pending Reviews Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Pending Schools Queue -->
        <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-school-flag text-amber-600"></i>
                Antrean Verifikasi Sekolah
              </h2>
              <p class="text-xs text-slate-500">Pendaftaran sekolah baru yang menunggu verifikasi NPSN.</p>
            </div>
            <router-link to="/admin/schools" class="text-xs font-bold text-brand-blue hover:underline">
              Kelola Semua &rarr;
            </router-link>
          </div>

          <div v-if="pendingSchools.length === 0" class="py-8 text-center text-slate-400 text-xs">
            <i class="fa-solid fa-circle-check text-2xl text-emerald-500 mb-2 block"></i>
            Tidak ada pengajuan sekolah yang tertunda. Semua telah ditinjau!
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="reg in pendingSchools.slice(0, 4)"
              :key="reg.id"
              class="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-between"
            >
              <div>
                <h3 class="text-xs font-bold text-slate-800">{{ reg.school_name || reg.name }}</h3>
                <p class="text-[11px] text-slate-500 mt-0.5">NPSN: {{ reg.npsn }} • {{ reg.city }}, {{ reg.province }}</p>
                <p class="text-[10px] text-slate-400 mt-1">PIC: {{ reg.pic_name }} ({{ reg.pic_phone }})</p>
              </div>
              <router-link
                to="/admin/schools"
                class="px-3 py-1.5 bg-brand-navy text-white text-xs font-semibold rounded-lg shadow-2xs hover:bg-[#001442]"
              >
                Tinjau
              </router-link>
            </div>
          </div>
        </div>

        <!-- Recent Competitions Pipeline -->
        <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-trophy text-brand-blue"></i>
                Status Kompetisi Terkini
              </h2>
              <p class="text-xs text-slate-500">Daftar kompetisi dalam siklus verifikasi dan publikasi.</p>
            </div>
            <router-link to="/admin/competitions" class="text-xs font-bold text-brand-blue hover:underline">
              Semua Kompetisi &rarr;
            </router-link>
          </div>

          <div v-if="competitions.length === 0" class="py-8 text-center text-slate-400 text-xs">
            Belum ada data kompetisi.
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="comp in competitions.slice(0, 4)"
              :key="comp.id"
              class="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-between"
            >
              <div class="pr-3">
                <h3 class="text-xs font-bold text-slate-800 line-clamp-1">{{ comp.name }}</h3>
                <p class="text-[11px] text-slate-500 mt-0.5">{{ comp.organizer?.name || 'Penyelenggara' }} • {{ comp.scope }}</p>
              </div>
              <div class="shrink-0 flex items-center gap-2">
                <Badge :status="comp.verification_status" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
