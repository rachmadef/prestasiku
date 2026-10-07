<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const permissions = ref<any[]>([])
const students = ref<any[]>([])
const loading = ref(true)
const statusFilter = ref<'all' | 'pending' | 'approved' | 'rejected'>('all')
const searchQuery = ref('')

// Create Permission Modal
const showCreateModal = ref(false)
const creating = ref(false)
const createForm = ref({
  student_id: '',
  competition_name: '',
  competition_level: 'kabupaten',
  news_url: '',
  purpose: '',
  event_start_date: '',
  event_end_date: '',
  parent_name: '',
  custom_fields_data: {} as Record<string, any>,
})

async function fetchData() {
  loading.value = true
  try {
    const [permRes, studRes] = await Promise.all([
      api.get('/school/permissions'),
      api.get('/school/students').catch(() => ({ data: { data: [] } })),
    ])
    permissions.value = extractList(permRes.data.data)
    students.value = extractList(studRes.data.data)
  } catch (err) {
    console.error('Error fetching permissions:', err)
  } finally {
    loading.value = false
  }
}

const pendingCount = computed(() => permissions.value.filter((d: any) => d.status === 'pending').length)
const approvedCount = computed(() => permissions.value.filter((d: any) => d.status === 'approved').length)

const filteredPermissions = computed(() => {
  return permissions.value.filter((d: any) => {
    const matchStatus = statusFilter.value === 'all' || d.status === statusFilter.value
    const matchSearch =
      !searchQuery.value ||
      (d.competition_name && d.competition_name.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (d.reference_number && d.reference_number.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (d.student && d.student.full_name.toLowerCase().includes(searchQuery.value.toLowerCase()))

    return matchStatus && matchSearch
  })
})

async function submitCreatePermission() {
  if (!createForm.value.student_id || !createForm.value.competition_name || !createForm.value.event_start_date) {
    toast.error('Mohon lengkapi nama siswa, nama lomba, dan tanggal pelaksanaan.')
    return
  }

  creating.value = true
  try {
    await api.post('/school/permissions', createForm.value)
    toast.success('Surat perizinan mengikuti lomba berhasil diterbitkan.', 'Perizinan Diterbitkan')
    showCreateModal.value = false
    createForm.value = {
      student_id: '',
      competition_name: '',
      competition_level: 'kabupaten',
      news_url: '',
      purpose: '',
      event_start_date: '',
      event_end_date: '',
      parent_name: '',
      custom_fields_data: {},
    }
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menerbitkan surat perizinan.')
  } finally {
    creating.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Surat Perizinan Mengikuti Lomba</template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Humanized Top Banner -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200/90 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="space-y-1.5 max-w-2xl">
          <div class="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-md bg-slate-100 text-slate-700 text-xs font-semibold">
            <i class="fa-solid fa-file-circle-check text-brand-navy"></i>
            Pelayanan Perizinan & Rekomendasi Lomba Siswa
          </div>
          <h2 class="text-xl sm:text-2xl font-black text-brand-navy tracking-tight">
            Surat Perizinan Mengikuti Lomba
          </h2>
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
            Kelola pengajuan perizinan dan surat rekomendasi bagi peserta didik yang mengikuti ajang kompetisi dari tingkat Kabupaten hingga Internasional.
          </p>
        </div>

        <div class="flex items-center gap-2.5 shrink-0">
          <router-link
            to="/school/permissions/form-settings"
            class="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold border border-slate-300 shadow-2xs transition-all cursor-pointer"
            title="Kustomisasi Format Surat & Import DOCX Template"
          >
            <i class="fa-solid fa-stamp text-brand-navy"></i>
            <span>Format Surat & Kop</span>
          </router-link>

          <button
            type="button"
            @click="showCreateModal = true"
            class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-navy text-white text-xs font-bold shadow-xs hover:bg-[#00164a] transition-all cursor-pointer"
          >
            <i class="fa-solid fa-circle-plus text-brand-gold"></i>
            <span>Terbitkan Surat Perizinan</span>
          </button>
        </div>
      </div>

      <!-- Stat Tiles -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div
          :class="[
            'bg-white rounded-xl p-4 border transition-all cursor-pointer',
            statusFilter === 'pending' ? 'border-amber-400 ring-2 ring-amber-100' : 'border-slate-200/80 hover:border-slate-300'
          ]"
          @click="statusFilter = statusFilter === 'pending' ? 'all' : 'pending'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Menunggu Persetujuan</span>
            <span class="w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse"></span>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-amber-600 font-mono">{{ pendingCount }}</span>
            <span class="text-xs text-slate-500 font-medium">permohonan</span>
          </div>
        </div>

        <div
          :class="[
            'bg-white rounded-xl p-4 border transition-all cursor-pointer',
            statusFilter === 'approved' ? 'border-emerald-400 ring-2 ring-emerald-100' : 'border-slate-200/80 hover:border-slate-300'
          ]"
          @click="statusFilter = statusFilter === 'approved' ? 'all' : 'approved'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Surat Izin Resmi Terbit</span>
            <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-emerald-700 font-mono">{{ approvedCount }}</span>
            <span class="text-xs text-slate-500 font-medium">surat sah</span>
          </div>
        </div>

        <div
          :class="[
            'bg-white rounded-xl p-4 border transition-all cursor-pointer',
            statusFilter === 'all' ? 'border-blue-400 ring-2 ring-blue-100' : 'border-slate-200/80 hover:border-slate-300'
          ]"
          @click="statusFilter = 'all'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-semibold text-slate-500">Total Arsip Perizinan</span>
            <i class="fa-solid fa-folder-closed text-slate-400 text-xs"></i>
          </div>
          <div class="mt-2 flex items-baseline gap-2">
            <span class="text-2xl font-black text-brand-navy font-mono">{{ permissions.length }}</span>
            <span class="text-xs text-slate-500 font-medium">dokumen</span>
          </div>
        </div>
      </div>

      <!-- Search & Filters -->
      <div class="bg-white rounded-xl p-3 sm:p-4 border border-slate-200/80 shadow-xs flex flex-col md:flex-row items-center justify-between gap-3">
        <div class="flex items-center gap-1.5 overflow-x-auto w-full md:w-auto">
          <button
            type="button"
            @click="statusFilter = 'all'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              statusFilter === 'all' ? 'bg-brand-navy text-white shadow-xs' : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Semua ({{ permissions.length }})
          </button>
          <button
            type="button"
            @click="statusFilter = 'approved'"
            :class="[
              'px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap',
              statusFilter === 'approved' ? 'bg-emerald-700 text-white shadow-xs' : 'text-slate-600 hover:bg-slate-100'
            ]"
          >
            Disetujui
          </button>
        </div>

        <div class="relative w-full md:w-80">
          <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Cari siswa, nama lomba, nomor..."
            class="w-full text-xs rounded-lg border border-slate-200 bg-slate-50 pl-8 pr-3 py-2 text-slate-700 focus:bg-white focus:border-brand-navy focus:ring-1 focus:ring-brand-navy transition-all"
          />
        </div>
      </div>

      <!-- Data Table -->
      <div class="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div v-if="loading" class="py-16 text-center">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs text-slate-500 mt-2 font-medium">Memuat data perizinan lomba...</p>
        </div>

        <div v-else-if="filteredPermissions.length === 0" class="py-16 text-center">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-lg mb-3">
            <i class="fa-regular fa-folder-open"></i>
          </div>
          <h3 class="text-sm font-bold text-slate-800">Belum Ada Data Perizinan Lomba</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1">
            Klik tombol "Terbitkan Surat Perizinan" untuk membuat perizinan baru.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs border-collapse">
            <thead class="bg-slate-50 text-slate-500 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[10px]">
              <tr>
                <th class="px-4 py-3">Nomor & Lomba</th>
                <th class="px-4 py-3">Siswa Pemohon</th>
                <th class="px-4 py-3">Tingkatan</th>
                <th class="px-4 py-3">Jadwal Lomba</th>
                <th class="px-4 py-3 text-center">Status</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 text-slate-700">
              <tr v-for="item in filteredPermissions" :key="item.id" class="hover:bg-slate-50/80 transition-colors">
                <td class="px-4 py-3.5">
                  <p class="font-bold text-slate-900 text-xs leading-snug">{{ item.competition_name }}</p>
                  <p class="font-mono text-[11px] text-slate-500 mt-0.5">{{ item.reference_number }}</p>
                  <a v-if="item.news_url" :href="item.news_url" target="_blank" class="text-[11px] text-blue-600 hover:underline flex items-center gap-1 mt-0.5">
                    <i class="fa-solid fa-link text-[9px]"></i> Berita Terkait
                  </a>
                </td>
                <td class="px-4 py-3.5">
                  <p class="font-bold text-slate-900 text-xs">{{ item.student?.full_name || 'Siswa' }}</p>
                  <p class="text-[11px] text-slate-500">{{ item.student?.class_name }} • NIS: {{ item.student?.nis }}</p>
                </td>
                <td class="px-4 py-3.5">
                  <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-bold uppercase bg-slate-100 text-slate-700 border border-slate-200">
                    {{ item.competition_level }}
                  </span>
                </td>
                <td class="px-4 py-3.5">
                  <p class="font-medium text-slate-800 text-xs">{{ item.event_start_date }} s.d. {{ item.event_end_date }}</p>
                </td>
                <td class="px-4 py-3.5 text-center">
                  <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300">
                    Disetujui
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Create Modal -->
      <Modal v-model="showCreateModal" title="Terbitkan Surat Perizinan Mengikuti Lomba" subtitle="Form pengajuan resmi perizinan lomba siswa." size="lg">
        <form @submit.prevent="submitCreatePermission" class="space-y-4">
          <div>
            <label class="block text-xs font-bold text-slate-700 uppercase mb-1">Pilih Siswa *</label>
            <select
              v-model="createForm.student_id"
              required
              class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy"
            >
              <option value="" disabled>-- Pilih Siswa --</option>
              <option v-for="s in students" :key="s.id" :value="s.id">
                {{ s.full_name }} ({{ s.class_name }} - NIS {{ s.nis }})
              </option>
            </select>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase mb-1">Nama Lomba / Kegiatan *</label>
              <input
                v-model="createForm.competition_name"
                type="text"
                required
                placeholder="Contoh: Olympiad Mathematics 2026"
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy"
              />
            </div>
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase mb-1">Tingkatan Lomba *</label>
              <select
                v-model="createForm.competition_level"
                required
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy"
              >
                <option value="kabupaten">Kabupaten / Kota</option>
                <option value="provinsi">Provinsi</option>
                <option value="nasional">Nasional</option>
                <option value="internasional">Internasional</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 uppercase mb-1">Link Berita / Referensi Terkait</label>
            <input
              v-model="createForm.news_url"
              type="url"
              placeholder="https://..."
              class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy"
            />
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase mb-1">Tanggal Mulai *</label>
              <input
                v-model="createForm.event_start_date"
                type="date"
                required
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy"
              />
            </div>
            <div>
              <label class="block text-xs font-bold text-slate-700 uppercase mb-1">Tanggal Selesai *</label>
              <input
                v-model="createForm.event_end_date"
                type="date"
                required
                class="w-full text-xs rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-slate-800 focus:bg-white focus:border-brand-navy"
              />
            </div>
          </div>
        </form>

        <template #footer>
          <button type="button" @click="showCreateModal = false" class="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100">Batal</button>
          <button type="button" @click="submitCreatePermission" :disabled="creating" class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-navy text-white hover:bg-[#00164a]">
            {{ creating ? 'Memproses...' : 'Terbitkan Surat' }}
          </button>
        </template>
      </Modal>
    </div>
  </DashboardLayout>
</template>
