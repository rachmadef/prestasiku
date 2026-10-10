<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import SearchableSelect from '@/components/common/SearchableSelect.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'
import { exportToExcel } from '@/utils/exportExcel'

const { toast, confirm } = useNotify()

const achievements = ref<any[]>([])
const students = ref<any[]>([])
const competitions = ref<any[]>([])
const loading = ref(true)

// Add Achievement Modal
const showAddModal = ref(false)
const addForm = ref({
  student_id: '',
  competition_id: '',
  competition_name_manual: '',
  achievement_level: 'nasional',
  rank: 'Juara 1',
  field_name: 'Robotika & AI',
  event_date: '',
  organizer_name: '',
})
const adding = ref(false)

const studentOptions = computed(() => {
  return students.value.map((s: any) => ({
    value: s.id,
    label: s.full_name,
    sublabel: `NIS: ${s.nis || '-'} • Kelas ${s.class_name || '-'}`,
    badge: s.grade_level ? `Tingkat ${s.grade_level}` : undefined,
  }))
})

const competitionOptions = computed(() => {
  return competitions.value.map((c: any) => ({
    value: c.id,
    label: c.name || c.title,
    sublabel: `${c.category?.name || 'Kompetisi'} • ${c.organizer?.name || 'Puspresnas / BPTI'}`,
    badge: (c.scope || c.level || '').toUpperCase(),
  }))
})

watch(() => addForm.value.competition_id, (newCompId) => {
  if (newCompId) {
    const comp = competitions.value.find((c: any) => String(c.id) === String(newCompId))
    if (comp) {
      if (comp.scope || comp.level) addForm.value.achievement_level = comp.scope || comp.level
      if (comp.category?.name) addForm.value.field_name = comp.category.name
      if (comp.organizer?.name) addForm.value.organizer_name = comp.organizer.name
    }
  }
})

async function fetchData() {
  loading.value = true
  try {
    const [achRes, studRes, compRes] = await Promise.all([
      api.get('/school/achievements'),
      api.get('/school/students').catch(() => ({ data: { data: [] } })),
      api.get('/competitions?status=published').catch(() => ({ data: { data: [] } })),
    ])
    achievements.value = extractList(achRes.data.data)
    students.value = extractList(studRes.data.data)
    competitions.value = extractList(compRes.data.data)
  } catch (err) {
    console.error('Error fetching school achievements:', err)
  } finally {
    loading.value = false
  }
}

async function handleAddAchievement() {
  adding.value = true
  try {
    const titleVal = addForm.value.competition_name_manual || addForm.value.field_name || 'Kejuaraan Siswa'
    const payload = {
      student_id: addForm.value.student_id,
      competition_id: addForm.value.competition_id || null,
      title: titleVal,
      event_name: titleVal,
      organizer_name: addForm.value.organizer_name || 'Penyelenggara Resmi',
      level: addForm.value.achievement_level || 'nasional',
      rank: addForm.value.rank || 'Juara 1',
      event_date: addForm.value.event_date || new Date().toISOString().split('T')[0],
      status: 'verified',
    }
    await api.post('/school/achievements', payload)
    showAddModal.value = false
    toast.success('Prestasi siswa berhasil dicatat dan diverifikasi!', 'Prestasi Ditambahkan')
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menambahkan prestasi.', 'Gagal Simpan')
  } finally {
    adding.value = false
  }
}

async function handleVerify(ach: any) {
  const compTitle = ach.title || ach.event_name || ach.competition?.name || 'Prestasi Siswa'
  const ok = await confirm({
    title: 'Verifikasi Prestasi & Terbitkan QR',
    message: `Verifikasi prestasi "${compTitle}" untuk siswa ${ach.student?.full_name}? Dokumen akan secara resmi disahkan oleh sekolah dan mendapatkan Public ID serta sertifikat QR Code publik.`,
    type: 'success',
    confirmText: 'Ya, Verifikasi & Terbitkan',
  })
  if (!ok) return

  try {
    await api.post(`/school/achievements/${ach.id}/verify`, {
      status: 'verified',
    })
    toast.success('Prestasi berhasil diverifikasi dan QR Publik resmi telah diterbitkan!', 'Verifikasi Berhasil')
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memverifikasi prestasi.', 'Verifikasi Gagal')
  }
}

function exportAchievementsExcel() {
  if (!achievements.value || achievements.value.length === 0) {
    toast.error('Tidak ada data rekam prestasi untuk di-export.', 'Export Gagal')
    return
  }

  const headers = [
    'No',
    'Nama Siswa',
    'NIS',
    'Kelas',
    'Nama Kompetisi / Kejuaraan',
    'Peringkat / Capaian',
    'Tingkat Wilayah',
    'Penyelenggara',
    'Tanggal Kejuaraan',
    'Public ID Verifikasi',
    'Status Verifikasi',
  ]

  const rows = achievements.value.map((ach: any, idx: number) => [
    idx + 1,
    ach.student?.full_name || ach.student?.user?.name || '-',
    ach.student?.nis || '-',
    ach.student?.class_name || '-',
    ach.title || ach.event_name || ach.competition?.name || ach.competition_name_manual || '-',
    ach.rank || '-',
    (ach.level || ach.achievement_level || '').toUpperCase(),
    ach.organizer_name || ach.field_name || '-',
    ach.event_date || '-',
    ach.public_id || '-',
    (ach.status || 'draft').toUpperCase(),
  ])

  exportToExcel('Rekap_Prestasi_Siswa_MA_Unggulan', headers, rows)
  toast.success('File Rekapitulasi Excel Prestasi berhasil diunduh!', 'Export Berhasil')
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Rekam Prestasi Siswa Sekolah</template>
    <template #header-subtitle>Pencatatan rekam jejak juara, sertifikat, dan penerbitan QR verifikasi digital.</template>

    <div class="space-y-6">
      <div class="flex items-center justify-between gap-3 flex-wrap">
        <p class="text-xs text-slate-500">Daftar capaian prestasi siswa yang tercatat di pangkalan data sekolah.</p>
        <div class="flex items-center gap-2">
          <button
            type="button"
            @click="exportAchievementsExcel"
            class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer"
          >
            <i class="fa-solid fa-file-excel"></i>
            <span>Export Excel</span>
          </button>
          <button
            type="button"
            @click="showAddModal = true"
            class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer"
          >
            <i class="fa-solid fa-plus text-brand-gold"></i>
            <span>Catat Prestasi Baru</span>
          </button>
        </div>
      </div>

      <!-- Achievements Table -->
      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Siswa</th>
                <th class="px-6 py-3.5">Nama Kompetisi</th>
                <th class="px-6 py-3.5">Capaian / Peringkat</th>
                <th class="px-6 py-3.5">Public ID & QR</th>
                <th class="px-6 py-3.5">Status Verifikasi</th>
                <th class="px-6 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="achievements.length === 0">
                <td colspan="6" class="px-6 py-8 text-center text-slate-400">
                  Belum ada rekam prestasi yang dicatat.
                </td>
              </tr>
              <tr v-for="ach in achievements" :key="ach.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ ach.student?.full_name || ach.student?.user?.name || '-' }}</div>
                  <div class="text-[11px] text-slate-400">Kelas {{ ach.student?.class_name || '-' }} • NIS {{ ach.student?.nis || '-' }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="font-semibold text-slate-800">{{ ach.title || ach.event_name || ach.competition?.name || ach.competition_name_manual || '-' }}</div>
                  <div class="text-[11px] text-slate-400 capitalize">{{ (ach.level || ach.achievement_level || '').replace('_', ' ') }} • {{ ach.organizer_name || ach.field_name || '-' }}</div>
                </td>
                <td class="px-6 py-4 font-bold text-amber-700 flex items-center gap-1">
                  <i class="fa-solid fa-trophy text-brand-gold text-xs"></i>
                  <span>{{ ach.rank }}</span>
                </td>
                <td class="px-6 py-4 font-mono text-[11px]">
                  <span v-if="ach.public_id" class="text-brand-navy font-bold bg-blue-50 px-2 py-0.5 rounded-md">
                    {{ ach.public_id }}
                  </span>
                  <span v-else class="text-slate-400 italic">Belum terbit</span>
                </td>
                <td class="px-6 py-4">
                  <Badge :status="ach.status || 'draft'" />
                </td>
                <td class="px-6 py-4 text-right space-x-2">
                  <button
                    v-if="ach.status !== 'verified'"
                    type="button"
                    @click="handleVerify(ach)"
                    class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-2xs cursor-pointer"
                  >
                    <i class="fa-solid fa-shield-check mr-1"></i> Terbitkan QR
                  </button>
                  <router-link
                    v-if="ach.public_id"
                    :to="`/verify/${ach.public_id}`"
                    target="_blank"
                    class="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-brand-blue rounded-lg text-xs font-semibold cursor-pointer"
                    title="Lihat Sertifikat QR"
                  >
                    <i class="fa-solid fa-qrcode mr-1"></i> QR
                  </router-link>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Add Achievement Modal -->
      <Modal v-model="showAddModal" title="Catat Rekam Prestasi Siswa" size="lg">
        <form @submit.prevent="handleAddAchievement" class="space-y-4 text-xs">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <SearchableSelect
                v-model="addForm.student_id"
                label="Pilih Siswa"
                placeholder="Pilih atau cari nama siswa / NIS..."
                searchPlaceholder="Ketik nama siswa atau NIS..."
                :options="studentOptions"
                required
              />
            </div>

            <div>
              <SearchableSelect
                v-model="addForm.competition_id"
                label="Pilih dari Database Kompetisi (Opsional)"
                placeholder="Pilih lomba resmi (opsional)..."
                searchPlaceholder="Ketik nama lomba (OSN, FLS2N, O2SN, dll)..."
                :options="competitionOptions"
                :clearable="true"
              />
            </div>

            <div v-if="!addForm.competition_id" class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Nama Kompetisi Manual *</label>
              <input
                v-model="addForm.competition_name_manual"
                type="text"
                placeholder="Contoh: Lomba Cipta Puisi Pelajar Nasional"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tingkat Prestasi *</label>
              <select
                v-model="addForm.achievement_level"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="nasional">Tingkat Nasional</option>
                <option value="provinsi">Tingkat Provinsi</option>
                <option value="kabupaten">Tingkat Kota / Kabupaten</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Peringkat / Capaian Juara *</label>
              <input
                v-model="addForm.rank"
                type="text"
                required
                placeholder="Contoh: Juara 1 / Medali Emas"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Bidang / Kategori Lomba</label>
              <input
                v-model="addForm.field_name"
                type="text"
                placeholder="Contoh: Robotika, Sains, Matematika"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tanggal Kejuaraan</label>
              <input
                v-model="addForm.event_date"
                type="date"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showAddModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="adding"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs"
            >
              <i v-if="adding" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Simpan Prestasi</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
