<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import { useRouter } from 'vue-router'
import api from '@/services/api'
import { formatDateIndo, formatDateRange } from '@/utils/date'

const router = useRouter()

interface PermissionItem {
  id: number
  reference_number: string
  competition_name: string
  competition_level: 'kabupaten' | 'provinsi' | 'nasional' | 'internasional'
  news_url?: string
  purpose?: string
  event_start_date: string
  event_end_date: string
  parent_name?: string
  status: 'pending' | 'approved' | 'rejected'
  rejection_reason?: string
  created_at: string
}

const permissions = ref<PermissionItem[]>([])
const loading = ref(true)

async function fetchData() {
  loading.value = true
  try {
    const permRes = await api.get('/student/permissions')
    permissions.value = permRes.data.data.data || permRes.data.data || []
  } catch (err) {
    console.error('Error fetching student permissions:', err)
  } finally {
    loading.value = false
  }
}

function goToUnifiedForm() {
  router.push('/student/dispensations')
}

const getStatusBadgeClass = (status: string) => {
  if (status === 'approved') return 'bg-emerald-50 text-emerald-700 border-emerald-200'
  if (status === 'rejected') return 'bg-rose-50 text-rose-700 border-rose-200'
  return 'bg-amber-50 text-amber-700 border-amber-200'
}

const getStatusLabel = (status: string) => {
  if (status === 'approved') return 'Disetujui Sekolah'
  if (status === 'rejected') return 'Ditolak'
  return 'Menunggu Persetujuan'
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Form Perizinan & Dispensasi Lomba</template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Unification Announcement Banner -->
      <div class="bg-gradient-to-r from-brand-navy to-[#00164a] text-white rounded-2xl p-6 shadow-md flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-2 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-white/10 text-brand-gold text-xs font-semibold">
            <i class="fa-solid fa-sparkles"></i>
            Pembaruan Alur Layanan Siswa
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-white tracking-tight">
            Form Perizinan & Dispensasi KBM Dijadikan Satu
          </h2>
          <p class="text-xs sm:text-sm text-blue-100/90 leading-relaxed">
            Mulai sekarang, pengajuan izin mengikuti lomba dan pengajuan dispensasi KBM telah digabung menjadi <strong>1 Form Terpadu</strong>. Kamu cukup mengisi 1 form, menunggu persetujuan sekolah, lalu mencetak suratnya.
          </p>
        </div>

        <button
          type="button"
          @click="goToUnifiedForm"
          class="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-brand-gold text-brand-navy text-xs font-black shadow-md hover:bg-amber-400 transition-all cursor-pointer shrink-0"
        >
          <i class="fa-solid fa-file-signature text-sm"></i>
          <span>Buka Form Terpadu Sekarang &rarr;</span>
        </button>
      </div>

      <!-- Historical Permission Records -->
      <div class="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 class="text-sm font-bold text-slate-800">Arsip Pengajuan Perizinan Lomba</h3>
            <p class="text-xs text-slate-500">Riwayat perizinan lomba sebelumnya</p>
          </div>
          <span class="text-xs font-semibold text-slate-500 font-mono">{{ permissions.length }} data</span>
        </div>

        <div v-if="loading" class="py-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2 font-medium">Memuat riwayat perizinan lomba...</p>
        </div>

        <div v-else-if="permissions.length === 0" class="py-16 text-center">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
            <i class="fa-regular fa-folder-open"></i>
          </div>
          <h3 class="text-sm font-bold text-slate-800">Belum Ada Riwayat Perizinan Terpisah</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
            Gunakan tombol di atas untuk mengajukan perizinan & dispensasi KBM melalui formulir terpadu yang baru.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs border-collapse">
            <thead class="bg-slate-50 text-slate-500 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[10px]">
              <tr>
                <th class="px-4 py-3">Nama Lomba & Ref</th>
                <th class="px-4 py-3">Tingkatan</th>
                <th class="px-4 py-3">Jadwal Lomba</th>
                <th class="px-4 py-3">Wali / Berita</th>
                <th class="px-4 py-3 text-center">Status</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 text-slate-700">
              <tr v-for="item in permissions" :key="item.id" class="hover:bg-slate-50/80 transition-colors">
                <td class="px-4 py-3.5">
                  <p class="font-bold text-slate-900 text-xs leading-snug">{{ item.competition_name }}</p>
                  <p class="font-mono text-[11px] text-slate-500 mt-0.5">{{ item.reference_number }}</p>
                </td>
                <td class="px-4 py-3.5">
                  <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold uppercase bg-slate-100 text-slate-700 border border-slate-200">
                    {{ item.competition_level }}
                  </span>
                </td>
                <td class="px-4 py-3.5">
                  <p class="font-medium text-slate-800 text-xs">{{ formatDateRange(item.event_start_date, item.event_end_date) }}</p>
                </td>
                <td class="px-4 py-3.5">
                  <p v-if="item.parent_name" class="text-xs text-slate-700">Wali: {{ item.parent_name }}</p>
                  <a v-if="item.news_url" :href="item.news_url" target="_blank" class="text-[11px] text-blue-600 hover:underline flex items-center gap-1 mt-0.5">
                    <i class="fa-solid fa-link text-[9px]"></i> Link Berita
                  </a>
                </td>
                <td class="px-4 py-3.5 text-center">
                  <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold border" :class="getStatusBadgeClass(item.status)">
                    {{ getStatusLabel(item.status) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
