<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import { useAuthStore } from '@/stores/auth'
import api, { extractList } from '@/services/api'

const authStore = useAuthStore()
const loading = ref(true)
const students = ref<any[]>([])
const registrations = ref<any[]>([])
const dispensations = ref<any[]>([])
const achievements = ref<any[]>([])

async function fetchSchoolData() {
  loading.value = true
  try {
    const [studRes, regRes, dispRes, achRes] = await Promise.all([
      api.get('/school/students').catch(() => ({ data: { data: [] } })),
      api.get('/school/registrations').catch(() => ({ data: { data: [] } })),
      api.get('/school/dispensations').catch(() => ({ data: { data: [] } })),
      api.get('/school/achievements').catch(() => ({ data: { data: [] } })),
    ])
    students.value = extractList(studRes.data.data)
    registrations.value = extractList(regRes.data.data)
    dispensations.value = extractList(dispRes.data.data)
    achievements.value = extractList(achRes.data.data)
  } catch (err) {
    console.error('Error loading school dashboard:', err)
  } finally {
    loading.value = false
  }
}

// Dispensations needing review or active today
const todayStr = new Date().toISOString().split('T')[0]

const pendingDispensations = computed(() => {
  return dispensations.value.filter((d: any) => d.status === 'pending_approval')
})

const activeDispensationsToday = computed(() => {
  return dispensations.value.filter((d: any) => {
    if (d.status !== 'approved') return false
    const start = d.start_date ? d.start_date.split('T')[0] : ''
    const end = d.end_date ? d.end_date.split('T')[0] : start
    return todayStr >= start && todayStr <= end
  })
})

const winnerCount = computed(() => {
  return registrations.value.filter((r: any) => r.result_status === 'winner' || r.achievement).length
})

const participantArchiveCount = computed(() => {
  return registrations.value.filter((r: any) => r.result_status === 'participant' || r.result_status === 'finalist').length
})

const pendingReviewRegistrations = computed(() => {
  return registrations.value.filter((r: any) => r.status === 'submitted' || r.status === 'in_review')
})

function formatDateIndo(dateStr?: string) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return new Intl.DateTimeFormat('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(d)
}

function formatPurpose(purpose: string) {
  if (purpose === 'practice') return 'Pembinaan & Latihan'
  if (purpose === 'competition') return 'Pelaksanaan Lomba'
  return 'Kegiatan Khusus'
}

onMounted(() => {
  fetchSchoolData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Pusat Administrasi & Kesiswaan Sekolah</template>
    <template #header-subtitle>
      Arsip partisipasi kejuaraan siswa dan manajemen perizinan dispensasi KBM
    </template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Humanized School Tenant Identity Banner -->
      <div class="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div class="bg-brand-navy px-6 py-5 border-b-4 border-brand-gold text-white flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div class="space-y-1">
            <div class="flex items-center gap-2">
              <span class="text-[10px] font-mono uppercase tracking-widest px-2.5 py-0.5 rounded-sm bg-white/10 text-brand-gold border border-brand-gold/30">
                Lembaga Pendidikan Terdaftar
              </span>
              <span class="text-xs text-slate-300 font-mono">
                NPSN: {{ authStore.user?.school?.npsn || '3010XXXX' }}
              </span>
            </div>
            <h1 class="text-xl md:text-2xl font-black text-white tracking-tight">
              {{ authStore.user?.school?.name || 'Administrasi Sekolah' }}
            </h1>
            <p class="text-xs text-slate-200">
              Pengelolaan delegasi lomba, pendokumentasian rekam jejak peserta, dan penerbitan surat dispensasi belajar resmi.
            </p>
          </div>

          <!-- Direct Operations Actions -->
          <div class="flex flex-wrap items-center gap-2.5 shrink-0">
            <router-link
              to="/school/dispensations"
              class="px-4 py-2.5 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-colors flex items-center gap-2"
            >
              <i class="fa-solid fa-file-circle-plus"></i>
              <span>Buat Dispensasi KBM</span>
            </router-link>
            <router-link
              to="/school/registrations"
              class="px-4 py-2.5 bg-white/15 hover:bg-white/25 text-white font-semibold text-xs rounded-xl border border-white/20 transition-colors flex items-center gap-2"
            >
              <i class="fa-solid fa-clipboard-check text-brand-gold"></i>
              <span>Catat Hasil & Delegasi</span>
            </router-link>
          </div>
        </div>

        <!-- Alert strip if there are pending dispensations -->
        <div
          v-if="pendingDispensations.length > 0"
          class="bg-amber-50 border-b border-amber-200 px-6 py-3 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
        >
          <div class="flex items-center gap-2.5 text-amber-900">
            <i class="fa-solid fa-bell text-amber-600"></i>
            <span>
              Ada <strong>{{ pendingDispensations.length }} permohonan dispensasi KBM</strong> yang menunggu persetujuan dan tanda tangan kesiswaan.
            </span>
          </div>
          <router-link
            to="/school/dispensations"
            class="px-3 py-1 bg-amber-700 hover:bg-amber-800 text-white font-bold text-[11px] rounded-lg transition-colors shrink-0"
          >
            Tinjau Sekarang &rarr;
          </router-link>
        </div>
      </div>

      <!-- Operational Metrics Ledger -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Metric 1: Dispensasi KBM -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-4 flex flex-col justify-between">
          <div class="flex items-center justify-between text-slate-500 mb-2">
            <span class="text-xs font-semibold">Dispensasi KBM</span>
            <span class="w-8 h-8 rounded-lg bg-blue-50 border border-blue-100 text-brand-blue flex items-center justify-center text-sm">
              <i class="fa-solid fa-file-signature"></i>
            </span>
          </div>
          <div>
            <div class="text-2xl font-black text-brand-navy">
              {{ dispensations.length }}
            </div>
            <div class="text-[11px] text-slate-500 mt-0.5 flex items-center gap-1.5">
              <span class="text-emerald-700 font-bold">{{ activeDispensationsToday.length }} aktif hari ini</span>
              <span>•</span>
              <span class="text-amber-700 font-bold">{{ pendingDispensations.length }} pending</span>
            </div>
          </div>
        </div>

        <!-- Metric 2: Arsip Delegasi Lomba -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-4 flex flex-col justify-between">
          <div class="flex items-center justify-between text-slate-500 mb-2">
            <span class="text-xs font-semibold">Total Partisipasi Lomba</span>
            <span class="w-8 h-8 rounded-lg bg-indigo-50 border border-indigo-100 text-indigo-700 flex items-center justify-center text-sm">
              <i class="fa-solid fa-list-check"></i>
            </span>
          </div>
          <div>
            <div class="text-2xl font-black text-brand-navy">
              {{ registrations.length }}
            </div>
            <div class="text-[11px] text-slate-500 mt-0.5">
              Dokumentasi siswa pernah bertanding
            </div>
          </div>
        </div>

        <!-- Metric 3: Rekam Hasil (Juara vs Peserta) -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-4 flex flex-col justify-between">
          <div class="flex items-center justify-between text-slate-500 mb-2">
            <span class="text-xs font-semibold">Distribusi Hasil Lomba</span>
            <span class="w-8 h-8 rounded-lg bg-amber-50 border border-amber-100 text-amber-700 flex items-center justify-center text-sm">
              <i class="fa-solid fa-trophy"></i>
            </span>
          </div>
          <div>
            <div class="text-2xl font-black text-amber-900">
              {{ winnerCount }} <span class="text-xs font-semibold text-slate-500">Juara</span>
            </div>
            <div class="text-[11px] text-slate-500 mt-0.5">
              {{ participantArchiveCount }} peserta terdokumentasi
            </div>
          </div>
        </div>

        <!-- Metric 4: Siswa Terdaftar -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-4 flex flex-col justify-between">
          <div class="flex items-center justify-between text-slate-500 mb-2">
            <span class="text-xs font-semibold">Siswa Terdata</span>
            <span class="w-8 h-8 rounded-lg bg-slate-100 border border-slate-200 text-slate-700 flex items-center justify-center text-sm">
              <i class="fa-solid fa-users"></i>
            </span>
          </div>
          <div>
            <div class="text-2xl font-black text-slate-800">
              {{ students.length }}
            </div>
            <div class="text-[11px] text-slate-500 mt-0.5">
              Basis data siswa tenant aktif
            </div>
          </div>
        </div>
      </div>

      <!-- Two Core Operational Workbenches -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Workbench 1: Dispensasi KBM Siswa (Perlu Ditindaklanjuti & Aktif) -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-6 space-y-4">
          <div class="flex items-center justify-between pb-3 border-b border-slate-100">
            <div>
              <h2 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-id-badge text-brand-blue"></i>
                Dispensasi KBM Siswa Terbaru
              </h2>
              <p class="text-xs text-slate-500">Izin resmi meninggalkan kelas untuk pembinaan & lomba.</p>
            </div>
            <router-link to="/school/dispensations" class="text-xs font-bold text-brand-blue hover:underline">
              Kelola Semua &rarr;
            </router-link>
          </div>

          <div v-if="dispensations.length === 0" class="py-8 text-center text-slate-400 text-xs">
            Belum ada data dispensasi KBM yang diterbitkan.
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="disp in dispensations.slice(0, 4)"
              :key="disp.id"
              class="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3"
            >
              <div>
                <div class="flex items-center gap-2">
                  <span class="font-bold text-xs text-slate-900 font-mono">{{ disp.dispensation_number }}</span>
                  <span
                    :class="[
                      'px-2 py-0.5 rounded text-[10px] font-bold border',
                      disp.status === 'approved' ? 'bg-emerald-50 text-emerald-800 border-emerald-200' :
                      disp.status === 'pending_approval' ? 'bg-amber-50 text-amber-800 border-amber-200' :
                      'bg-slate-100 text-slate-700 border-slate-200'
                    ]"
                  >
                    {{ disp.status === 'approved' ? 'Disahkan' : disp.status === 'pending_approval' ? 'Menunggu Review' : disp.status }}
                  </span>
                </div>
                <p class="text-xs text-slate-700 font-medium mt-1">
                  {{ disp.reason }}
                </p>
                <p class="text-[11px] text-slate-500 mt-0.5">
                  <i class="fa-regular fa-calendar text-[10px] mr-1 text-slate-400"></i>
                  {{ formatDateIndo(disp.start_date) }} • {{ formatPurpose(disp.purpose) }}
                  <span v-if="disp.students && disp.students.length" class="ml-1 text-slate-600 font-semibold">
                    ({{ disp.students.length }} siswa)
                  </span>
                </p>
              </div>

              <router-link
                to="/school/dispensations"
                class="px-3 py-1.5 bg-white hover:bg-slate-100 border border-slate-200 text-slate-700 text-xs font-bold rounded-lg shadow-2xs transition-colors self-start sm:self-auto shrink-0 flex items-center gap-1.5"
              >
                <i class="fa-solid fa-eye text-brand-navy"></i>
                <span>Buka Surat</span>
              </router-link>
            </div>
          </div>
        </div>

        <!-- Workbench 2: Pengarsipan Delegasi Lomba & Catat Hasil -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-6 space-y-4">
          <div class="flex items-center justify-between pb-3 border-b border-slate-100">
            <div>
              <h2 class="text-sm font-bold text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-trophy text-brand-gold"></i>
                Arsip Delegasi & Hasil Lomba Siswa
              </h2>
              <p class="text-xs text-slate-500">Mendokumentasikan seluruh siswa yang pernah berlomba.</p>
            </div>
            <router-link to="/school/registrations" class="text-xs font-bold text-brand-blue hover:underline">
              Buku Arsip &rarr;
            </router-link>
          </div>

          <div v-if="registrations.length === 0" class="py-8 text-center text-slate-400 text-xs">
            Belum ada riwayat pendaftaran atau delegasi lomba siswa.
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="reg in registrations.slice(0, 4)"
              :key="reg.id"
              class="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3"
            >
              <div>
                <h3 class="text-xs font-bold text-slate-900">{{ reg.competition?.name || 'Kompetisi' }}</h3>
                <p class="text-[11px] text-slate-600 mt-0.5">
                  Siswa: <span class="font-bold text-brand-navy">{{ reg.student?.full_name || reg.student?.user?.name }}</span>
                  <span class="text-slate-400 font-mono"> (Kelas {{ reg.student?.class_name }})</span>
                </p>
                <div class="mt-1 flex items-center gap-2">
                  <Badge :status="reg.status" />
                  <span v-if="reg.result_status === 'winner'" class="text-[11px] text-amber-700 font-bold flex items-center gap-1">
                    <i class="fa-solid fa-trophy text-amber-500"></i>
                    {{ reg.rank_details || 'Juara' }}
                  </span>
                  <span v-else-if="reg.result_status === 'participant'" class="text-[11px] text-emerald-700 font-semibold flex items-center gap-1">
                    <i class="fa-solid fa-id-badge text-emerald-500"></i>
                    Peserta Terdaftar
                  </span>
                  <span v-else class="text-[11px] text-slate-400 italic">
                    Hasil belum dicatat
                  </span>
                </div>
              </div>

              <router-link
                to="/school/registrations"
                class="px-3 py-1.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-lg shadow-2xs transition-colors self-start sm:self-auto shrink-0 flex items-center gap-1.5"
              >
                <i class="fa-solid fa-pen-to-square text-brand-gold"></i>
                <span>Kelola / Catat</span>
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
