<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import api, { extractList } from '@/services/api'

const registrations = ref<any[]>([])
const loading = ref(true)

async function fetchRegistrations() {
  loading.value = true
  try {
    const res = await api.get('/student/registrations')
    registrations.value = extractList(res.data.data)
  } catch (err) {
    console.error('Error fetching student registrations:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchRegistrations()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Pendaftaran Saya</template>
    <template #header-subtitle>Pelacakan status verifikasi delegasi sekolah dan keikutsertaan kompetisi.</template>

    <div class="space-y-6">
      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Kompetisi</th>
                <th class="px-6 py-3.5">Penyelenggara & Kategori</th>
                <th class="px-6 py-3.5">Tanggal Daftar</th>
                <th class="px-6 py-3.5">Status Delegasi</th>
                <th class="px-6 py-3.5">Catatan Sekolah</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="registrations.length === 0">
                <td colspan="5" class="px-6 py-10 text-center text-slate-400">
                  <i class="fa-solid fa-receipt text-3xl mb-2 block text-slate-300"></i>
                  Anda belum pernah mendaftar ke kompetisi.
                </td>
              </tr>
              <tr v-for="reg in registrations" :key="reg.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ reg.competition?.name }}</div>
                  <div class="text-[10px] text-slate-400 uppercase font-semibold">{{ reg.competition?.scope }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="font-medium text-slate-800">{{ reg.competition?.organizer?.name || '-' }}</div>
                  <div class="text-[11px] text-slate-400">{{ reg.competition?.category?.name || '-' }}</div>
                </td>
                <td class="px-6 py-4 font-mono text-[11px] text-slate-600">
                  {{ reg.created_at ? reg.created_at.split('T')[0] : '-' }}
                </td>
                <td class="px-6 py-4">
                  <Badge :status="reg.status" />
                </td>
                <td class="px-6 py-4 text-slate-500 italic">
                  {{ reg.school_approval_notes || '-' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
