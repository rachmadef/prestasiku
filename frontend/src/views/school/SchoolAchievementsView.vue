<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import SearchableSelect from '@/components/common/SearchableSelect.vue'
import api, { extractList, API_BASE_URL } from '@/services/api'
import { useNotify } from '@/composables/useNotify'
import { exportToExcel } from '@/utils/exportExcel'

const { toast, confirm } = useNotify()

const achievements = ref<any[]>([])
const students = ref<any[]>([])
const competitions = ref<any[]>([])
const loading = ref(true)

// Filter & Search
const searchQuery = ref('')
const selectedStatus = ref<'all' | 'verified' | 'pending_verification' | 'draft' | 'rejected'>('all')
const selectedLevel = ref<string>('all')

// Add Achievement Modal State
const showAddModal = ref(false)
const adding = ref(false)
const addCertificateFile = ref<File | null>(null)
const addForm = ref({
  student_id: '',
  competition_id: '',
  competition_name_manual: '',
  achievement_level: 'nasional',
  rank: 'Juara 1',
  field_name: 'Robotika & AI',
  event_date: new Date().toISOString().split('T')[0],
  organizer_name: '',
  status: 'verified',
  is_public: true,
  external_url: '',
})

// Edit Achievement Modal State
const showEditModal = ref(false)
const editing = ref(false)
const editingAchievementId = ref<number | null>(null)
const editCertificateFile = ref<File | null>(null)
const editForm = ref({
  student_id: '',
  competition_id: '',
  competition_name_manual: '',
  achievement_level: 'nasional',
  rank: '',
  field_name: '',
  event_date: '',
  organizer_name: '',
  status: 'verified',
  is_public: true,
  external_url: '',
})

// Detail View Modal State
const showDetailModal = ref(false)
const selectedAchievement = ref<any | null>(null)

// Computed dropdown options
const studentOptions = computed(() => {
  return students.value.map((s: any) => ({
    value: s.id,
    label: s.full_name || s.user?.name || `Siswa #${s.id}`,
    sublabel: `NIS: ${s.nis || '-'} • Kelas ${s.class_name || '-'}`,
    badge: s.grade_level ? `Tingkat ${s.grade_level}` : undefined,
  }))
})

const competitionOptions = computed(() => {
  return competitions.value.map((c: any) => ({
    value: c.id,
    label: c.name || c.title,
    sublabel: `${c.category?.name || 'Kompetisi'} • ${c.organizer?.name || 'Penyelenggara Resmi'}`,
    badge: (c.scope || c.level || '').toUpperCase(),
  }))
})

// Watchers for auto-fill based on competition selected
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

watch(() => editForm.value.competition_id, (newCompId) => {
  if (newCompId) {
    const comp = competitions.value.find((c: any) => String(c.id) === String(newCompId))
    if (comp) {
      if (comp.scope || comp.level) editForm.value.achievement_level = comp.scope || comp.level
      if (comp.category?.name) editForm.value.field_name = comp.category.name
      if (comp.organizer?.name) editForm.value.organizer_name = comp.organizer.name
    }
  }
})

// Filtered achievements for table
const filteredAchievements = computed(() => {
  return achievements.value.filter((ach: any) => {
    // Status filter
    if (selectedStatus.value !== 'all' && (ach.status || 'draft') !== selectedStatus.value) {
      return false
    }

    // Level filter
    if (selectedLevel.value !== 'all') {
      const achLevel = (ach.level || ach.achievement_level || '').toLowerCase()
      if (achLevel !== selectedLevel.value.toLowerCase()) {
        return false
      }
    }

    // Search query
    if (searchQuery.value.trim()) {
      const q = searchQuery.value.toLowerCase().trim()
      const studentName = (ach.student?.full_name || ach.student?.user?.name || '').toLowerCase()
      const nis = (ach.student?.nis || '').toLowerCase()
      const title = (ach.title || ach.event_name || ach.competition?.name || ach.competition_name_manual || '').toLowerCase()
      const rank = (ach.rank || '').toLowerCase()
      const publicId = (ach.public_id || '').toLowerCase()
      const organizer = (ach.organizer_name || ach.field_name || '').toLowerCase()

      return (
        studentName.includes(q) ||
        nis.includes(q) ||
        title.includes(q) ||
        rank.includes(q) ||
        publicId.includes(q) ||
        organizer.includes(q)
      )
    }

    return true
  })
})

// Summary counts
const statsCount = computed(() => {
  const total = achievements.value.length
  const verified = achievements.value.filter((a: any) => a.status === 'verified').length
  const pending = achievements.value.filter((a: any) => a.status === 'pending_verification').length
  const draftOrRejected = achievements.value.filter((a: any) => a.status === 'draft' || a.status === 'rejected').length
  return { total, verified, pending, draftOrRejected }
})

// Data fetcher
async function fetchData() {
  loading.value = true
  try {
    const [achRes, studRes, compRes] = await Promise.all([
      api.get('/school/achievements'),
      api.get('/school/students?all=1').catch(() => ({ data: { data: [] } })),
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

// C - CREATE
function handleAddFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    addCertificateFile.value = input.files[0]
  } else {
    addCertificateFile.value = null
  }
}

async function handleAddAchievement() {
  if (!addForm.value.student_id) {
    toast.error('Harap pilih siswa terlebih dahulu.', 'Validasi Form')
    return
  }

  adding.value = true
  try {
    const titleVal = addForm.value.competition_name_manual || addForm.value.field_name || 'Kejuaraan Siswa'
    
    // Normalize level
    let normalizedLevel = addForm.value.achievement_level
    if (normalizedLevel === 'kabupaten') normalizedLevel = 'kota_kabupaten'

    if (addCertificateFile.value) {
      const formData = new FormData()
      formData.append('student_id', String(addForm.value.student_id))
      if (addForm.value.competition_id) {
        formData.append('competition_id', String(addForm.value.competition_id))
      }
      formData.append('title', titleVal)
      formData.append('event_name', titleVal)
      formData.append('organizer_name', addForm.value.organizer_name || 'Penyelenggara Resmi')
      formData.append('level', normalizedLevel)
      formData.append('rank', addForm.value.rank || 'Juara 1')
      formData.append('event_date', addForm.value.event_date || new Date().toISOString().split('T')[0])
      formData.append('status', addForm.value.status)
      formData.append('is_public', addForm.value.is_public ? '1' : '0')
      if (addForm.value.external_url) {
        formData.append('external_url', addForm.value.external_url)
      }
      formData.append('certificate_file', addCertificateFile.value)

      await api.post('/school/achievements', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    } else {
      const payload = {
        student_id: addForm.value.student_id,
        competition_id: addForm.value.competition_id || null,
        title: titleVal,
        event_name: titleVal,
        organizer_name: addForm.value.organizer_name || 'Penyelenggara Resmi',
        level: normalizedLevel,
        rank: addForm.value.rank || 'Juara 1',
        event_date: addForm.value.event_date || new Date().toISOString().split('T')[0],
        status: addForm.value.status,
        is_public: addForm.value.is_public,
        external_url: addForm.value.external_url || null,
      }
      await api.post('/school/achievements', payload)
    }

    showAddModal.value = false
    addCertificateFile.value = null
    toast.success('Prestasi siswa berhasil dicatat dan tersimpan!', 'Prestasi Ditambahkan')
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menambahkan prestasi.', 'Gagal Simpan')
  } finally {
    adding.value = false
  }
}

// R - READ / DETAIL
function openDetailModal(ach: any) {
  selectedAchievement.value = ach
  showDetailModal.value = true
}

// U - UPDATE
function openEditModal(ach: any) {
  editingAchievementId.value = ach.id
  let achLevel = ach.level || ach.achievement_level || 'nasional'
  if (achLevel === 'kabupaten') achLevel = 'kota_kabupaten'

  editForm.value = {
    student_id: ach.student_id || ach.student?.id || '',
    competition_id: ach.competition_id ? String(ach.competition_id) : '',
    competition_name_manual: ach.title || ach.event_name || '',
    achievement_level: achLevel,
    rank: ach.rank || '',
    field_name: ach.field_name || '',
    event_date: ach.event_date ? ach.event_date.split('T')[0] : '',
    organizer_name: ach.organizer_name || '',
    status: ach.status || 'verified',
    is_public: ach.is_public !== undefined ? Boolean(ach.is_public) : true,
    external_url: ach.documents?.[0]?.external_url || '',
  }
  editCertificateFile.value = null
  showEditModal.value = true
}

function handleEditFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    editCertificateFile.value = input.files[0]
  } else {
    editCertificateFile.value = null
  }
}

async function handleUpdateAchievement() {
  if (!editingAchievementId.value) return
  if (!editForm.value.student_id) {
    toast.error('Harap pilih siswa terlebih dahulu.', 'Validasi Form')
    return
  }

  editing.value = true
  try {
    const titleVal = editForm.value.competition_name_manual || editForm.value.field_name || 'Kejuaraan Siswa'
    let normalizedLevel = editForm.value.achievement_level
    if (normalizedLevel === 'kabupaten') normalizedLevel = 'kota_kabupaten'

    if (editCertificateFile.value) {
      const formData = new FormData()
      formData.append('_method', 'PUT')
      formData.append('student_id', String(editForm.value.student_id))
      if (editForm.value.competition_id) {
        formData.append('competition_id', String(editForm.value.competition_id))
      }
      formData.append('title', titleVal)
      formData.append('event_name', titleVal)
      formData.append('organizer_name', editForm.value.organizer_name || 'Penyelenggara Resmi')
      formData.append('level', normalizedLevel)
      formData.append('rank', editForm.value.rank || 'Juara 1')
      formData.append('event_date', editForm.value.event_date || new Date().toISOString().split('T')[0])
      formData.append('status', editForm.value.status)
      formData.append('is_public', editForm.value.is_public ? '1' : '0')
      if (editForm.value.external_url) {
        formData.append('external_url', editForm.value.external_url)
      }
      formData.append('certificate_file', editCertificateFile.value)

      await api.post(`/school/achievements/${editingAchievementId.value}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    } else {
      const payload = {
        student_id: editForm.value.student_id,
        competition_id: editForm.value.competition_id || null,
        title: titleVal,
        event_name: titleVal,
        organizer_name: editForm.value.organizer_name || 'Penyelenggara Resmi',
        level: normalizedLevel,
        rank: editForm.value.rank || 'Juara 1',
        event_date: editForm.value.event_date || new Date().toISOString().split('T')[0],
        status: editForm.value.status,
        is_public: editForm.value.is_public,
        external_url: editForm.value.external_url || null,
      }
      await api.put(`/school/achievements/${editingAchievementId.value}`, payload)
    }

    showEditModal.value = false
    editCertificateFile.value = null
    toast.success('Data prestasi berhasil diperbarui!', 'Perubahan Disimpan')
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memperbarui data prestasi.', 'Gagal Simpan')
  } finally {
    editing.value = false
  }
}

// D - DELETE
async function handleDeleteAchievement(ach: any) {
  const compTitle = ach.title || ach.event_name || ach.competition?.name || 'Prestasi'
  const studentName = ach.student?.full_name || ach.student?.user?.name || 'Siswa'

  const ok = await confirm({
    title: 'Hapus Rekam Prestasi',
    message: `Apakah Anda yakin ingin menghapus prestasi "${compTitle}" milik siswa ${studentName}? Data sertifikat dan QR ID publik yang terkait akan ikut dihapus.`,
    type: 'danger',
    confirmText: 'Ya, Hapus Prestasi',
  })
  if (!ok) return

  try {
    await api.delete(`/school/achievements/${ach.id}`)
    toast.success('Data prestasi berhasil dihapus.', 'Berhasil Dihapus')
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menghapus prestasi.', 'Gagal Hapus')
  }
}

// Verification Action
async function handleVerify(ach: any) {
  const compTitle = ach.title || ach.event_name || ach.competition?.name || 'Prestasi Siswa'
  const studentName = ach.student?.full_name || ach.student?.user?.name || 'Siswa'

  const ok = await confirm({
    title: 'Verifikasi Prestasi & Terbitkan QR',
    message: `Verifikasi prestasi "${compTitle}" untuk siswa ${studentName}? Dokumen akan secara resmi disahkan oleh sekolah dan mendapatkan Public ID serta sertifikat QR Code publik.`,
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

// Download Document
async function downloadDoc(achId: number, docId: number, fileName?: string) {
  try {
    const res = await api.get(`/school/achievements/${achId}/documents/${docId}`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(new Blob([res.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', fileName || 'dokumen_prestasi.pdf')
    document.body.appendChild(link)
    link.click()
    link.remove()
  } catch (err: any) {
    toast.error('Gagal mengunduh berkas dokumen.', 'Unduh Gagal')
  }
}

// Excel Export
function exportAchievementsExcel() {
  if (!filteredAchievements.value || filteredAchievements.value.length === 0) {
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

  const rows = filteredAchievements.value.map((ach: any, idx: number) => [
    idx + 1,
    ach.student?.full_name || ach.student?.user?.name || '-',
    ach.student?.nis || '-',
    ach.student?.class_name || '-',
    ach.title || ach.event_name || ach.competition?.name || ach.competition_name_manual || '-',
    ach.rank || '-',
    (ach.level || ach.achievement_level || '').replace('_', ' ').toUpperCase(),
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
      <!-- Quick Stats Cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
        <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs">
          <div class="text-[11px] font-semibold text-slate-500 uppercase">Total Rekam Prestasi</div>
          <div class="text-2xl font-black text-brand-navy mt-1">{{ statsCount.total }}</div>
        </div>
        <div class="bg-white p-4 rounded-2xl border border-emerald-100 shadow-2xs">
          <div class="text-[11px] font-semibold text-emerald-600 uppercase flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
            Terverifikasi & QR
          </div>
          <div class="text-2xl font-black text-emerald-700 mt-1">{{ statsCount.verified }}</div>
        </div>
        <div class="bg-white p-4 rounded-2xl border border-amber-100 shadow-2xs">
          <div class="text-[11px] font-semibold text-amber-600 uppercase flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-full bg-amber-500"></span>
            Menunggu Verifikasi
          </div>
          <div class="text-2xl font-black text-amber-700 mt-1">{{ statsCount.pending }}</div>
        </div>
        <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs">
          <div class="text-[11px] font-semibold text-slate-500 uppercase flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-full bg-slate-400"></span>
            Draft / Ditolak
          </div>
          <div class="text-2xl font-black text-slate-700 mt-1">{{ statsCount.draftOrRejected }}</div>
        </div>
      </div>

      <!-- Action & Search Toolbar -->
      <div class="bg-white p-4 rounded-3xl border border-slate-200/80 shadow-2xs space-y-3">
        <div class="flex items-center justify-between gap-3 flex-wrap">
          <div class="flex-1 min-w-[260px] relative">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Cari nama siswa, NIS, judul prestasi, atau Public ID..."
              class="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div class="flex items-center gap-2 flex-wrap">
            <!-- Filter Tingkat -->
            <select
              v-model="selectedLevel"
              class="px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 focus:outline-hidden focus:border-brand-blue"
            >
              <option value="all">Semua Tingkat</option>
              <option value="internasional">Internasional</option>
              <option value="nasional">Nasional</option>
              <option value="provinsi">Provinsi</option>
              <option value="kota_kabupaten">Kota / Kabupaten</option>
            </select>

            <!-- Export Excel -->
            <button
              type="button"
              @click="exportAchievementsExcel"
              class="px-3.5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer"
            >
              <i class="fa-solid fa-file-excel"></i>
              <span>Export Excel</span>
            </button>

            <!-- Tambah Prestasi Button -->
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

        <!-- Filter Status Pills -->
        <div class="flex items-center gap-2 pt-2 border-t border-slate-100 flex-wrap text-xs">
          <span class="text-slate-400 text-[11px] font-semibold mr-1">Status:</span>
          <button
            type="button"
            @click="selectedStatus = 'all'"
            :class="[
              'px-3 py-1 rounded-lg font-semibold transition-all cursor-pointer',
              selectedStatus === 'all' ? 'bg-brand-navy text-white shadow-2xs' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            ]"
          >
            Semua ({{ statsCount.total }})
          </button>
          <button
            type="button"
            @click="selectedStatus = 'verified'"
            :class="[
              'px-3 py-1 rounded-lg font-semibold transition-all cursor-pointer',
              selectedStatus === 'verified' ? 'bg-emerald-600 text-white shadow-2xs' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'
            ]"
          >
            Terverifikasi ({{ statsCount.verified }})
          </button>
          <button
            type="button"
            @click="selectedStatus = 'pending_verification'"
            :class="[
              'px-3 py-1 rounded-lg font-semibold transition-all cursor-pointer',
              selectedStatus === 'pending_verification' ? 'bg-amber-600 text-white shadow-2xs' : 'bg-amber-50 text-amber-700 hover:bg-amber-100'
            ]"
          >
            Menunggu Verifikasi ({{ statsCount.pending }})
          </button>
          <button
            type="button"
            @click="selectedStatus = 'draft'"
            :class="[
              'px-3 py-1 rounded-lg font-semibold transition-all cursor-pointer',
              selectedStatus === 'draft' ? 'bg-slate-700 text-white shadow-2xs' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            ]"
          >
            Draft
          </button>
        </div>
      </div>

      <!-- Achievements Table (READ) -->
      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-5 py-3.5">Nama Siswa</th>
                <th class="px-5 py-3.5">Nama Kompetisi</th>
                <th class="px-5 py-3.5">Capaian / Peringkat</th>
                <th class="px-5 py-3.5">Public ID & QR</th>
                <th class="px-5 py-3.5">Status Verifikasi</th>
                <th class="px-5 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="loading">
                <td colspan="6" class="px-6 py-12 text-center text-slate-400">
                  <i class="fa-solid fa-spinner fa-spin text-xl text-brand-navy mb-2"></i>
                  <p>Memuat rekam prestasi siswa...</p>
                </td>
              </tr>
              <tr v-else-if="filteredAchievements.length === 0">
                <td colspan="6" class="px-6 py-12 text-center text-slate-400">
                  <div class="w-12 h-12 mx-auto mb-2 rounded-2xl bg-slate-100 flex items-center justify-center text-slate-400">
                    <i class="fa-solid fa-trophy text-lg"></i>
                  </div>
                  <p class="font-medium text-slate-600">Tidak ada data rekam prestasi yang sesuai.</p>
                  <p class="text-[11px] text-slate-400 mt-1">Coba sesuaikan kata kunci pencarian atau ubah filter status.</p>
                </td>
              </tr>
              <tr v-for="ach in filteredAchievements" :key="ach.id" class="hover:bg-slate-50/60 transition-colors">
                <!-- Siswa -->
                <td class="px-5 py-4">
                  <div class="font-bold text-slate-900">{{ ach.student?.full_name || ach.student?.user?.name || '-' }}</div>
                  <div class="text-[11px] text-slate-400 mt-0.5">
                    Kelas {{ ach.student?.class_name || '-' }} • NIS {{ ach.student?.nis || '-' }}
                  </div>
                </td>

                <!-- Kompetisi & Tingkat -->
                <td class="px-5 py-4">
                  <div class="font-semibold text-slate-800 line-clamp-1" :title="ach.title || ach.event_name">
                    {{ ach.title || ach.event_name || ach.competition?.name || ach.competition_name_manual || '-' }}
                  </div>
                  <div class="text-[11px] text-slate-400 mt-0.5 capitalize">
                    <span class="inline-block px-1.5 py-0.2 bg-slate-100 rounded text-[10px] font-medium mr-1 text-slate-600">
                      {{ (ach.level || ach.achievement_level || 'nasional').replace('_', ' ') }}
                    </span>
                    {{ ach.organizer_name || ach.field_name || '-' }}
                  </div>
                </td>

                <!-- Peringkat -->
                <td class="px-5 py-4">
                  <div class="font-bold text-amber-700 flex items-center gap-1.5">
                    <i class="fa-solid fa-trophy text-brand-gold text-xs"></i>
                    <span>{{ ach.rank }}</span>
                  </div>
                  <div v-if="ach.documents && ach.documents.length > 0" class="text-[10px] text-emerald-600 flex items-center gap-1 mt-0.5">
                    <i class="fa-solid fa-paperclip"></i>
                    <span>Ada Berkas</span>
                  </div>
                </td>

                <!-- Public ID & QR -->
                <td class="px-5 py-4 font-mono text-[11px]">
                  <span v-if="ach.public_id" class="text-brand-navy font-bold bg-blue-50/80 px-2 py-0.5 rounded-md border border-blue-100">
                    {{ ach.public_id }}
                  </span>
                  <span v-else class="text-slate-400 italic text-[10px]">Belum terbit</span>
                </td>

                <!-- Status -->
                <td class="px-5 py-4">
                  <Badge :status="ach.status || 'draft'" />
                </td>

                <!-- AKSI (Detail, Edit, Hapus, Verifikasi, QR) -->
                <td class="px-5 py-4 text-right space-x-1.5 whitespace-nowrap">
                  <!-- Terbitkan QR jika belum verified -->
                  <button
                    v-if="ach.status !== 'verified'"
                    type="button"
                    @click="handleVerify(ach)"
                    class="px-2.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-2xs transition-all cursor-pointer inline-flex items-center gap-1"
                    title="Verifikasi & Terbitkan QR"
                  >
                    <i class="fa-solid fa-shield-check"></i>
                    <span>Terbitkan QR</span>
                  </button>

                  <!-- Link QR Publik jika sudah verified -->
                  <router-link
                    v-if="ach.public_id"
                    :to="`/verify/${ach.public_id}`"
                    target="_blank"
                    class="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-brand-blue rounded-lg text-xs font-semibold transition-all cursor-pointer inline-flex items-center gap-1"
                    title="Lihat Sertifikat QR Publik"
                  >
                    <i class="fa-solid fa-qrcode"></i>
                    <span>QR</span>
                  </router-link>

                  <!-- Detail Button -->
                  <button
                    type="button"
                    @click="openDetailModal(ach)"
                    class="p-1.5 text-slate-500 hover:text-brand-blue hover:bg-slate-100 rounded-lg transition-all cursor-pointer"
                    title="Lihat Detail Lengkap"
                  >
                    <i class="fa-solid fa-eye text-xs"></i>
                  </button>

                  <!-- Edit Button -->
                  <button
                    type="button"
                    @click="openEditModal(ach)"
                    class="p-1.5 text-slate-500 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-all cursor-pointer"
                    title="Edit Prestasi"
                  >
                    <i class="fa-solid fa-pen-to-square text-xs"></i>
                  </button>

                  <!-- Delete Button -->
                  <button
                    type="button"
                    @click="handleDeleteAchievement(ach)"
                    class="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-all cursor-pointer"
                    title="Hapus Prestasi"
                  >
                    <i class="fa-solid fa-trash-can text-xs"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ========================================== -->
      <!-- MODAL DETAIL PRESTASI (READ)                -->
      <!-- ========================================== -->
      <Modal v-model="showDetailModal" title="Detail Rekam Prestasi Siswa" size="lg">
        <div v-if="selectedAchievement" class="space-y-4 text-xs">
          <!-- Banner Header -->
          <div class="bg-gradient-to-r from-brand-navy to-blue-900 text-white p-4 rounded-2xl flex items-center justify-between gap-3">
            <div>
              <div class="text-[10px] text-blue-200 uppercase tracking-wider font-semibold">Capaian Prestasi</div>
              <h3 class="text-base font-bold text-brand-gold flex items-center gap-2 mt-0.5">
                <i class="fa-solid fa-trophy"></i>
                <span>{{ selectedAchievement.rank }}</span>
              </h3>
              <p class="text-xs text-blue-100 font-medium mt-1">
                {{ selectedAchievement.title || selectedAchievement.event_name }}
              </p>
            </div>
            <div class="text-right">
              <Badge :status="selectedAchievement.status || 'draft'" />
              <div v-if="selectedAchievement.public_id" class="text-[10px] text-blue-200 font-mono mt-1">
                {{ selectedAchievement.public_id }}
              </div>
            </div>
          </div>

          <!-- Informasi Siswa & Sekolah -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-slate-50 p-4 rounded-2xl border border-slate-200/80">
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Nama Lengkap Siswa</span>
              <span class="text-xs font-bold text-slate-800">
                {{ selectedAchievement.student?.full_name || selectedAchievement.student?.user?.name || '-' }}
              </span>
            </div>
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">NIS / NISN</span>
              <span class="text-xs font-semibold text-slate-700">
                {{ selectedAchievement.student?.nis || '-' }} / {{ selectedAchievement.student?.nisn || '-' }}
              </span>
            </div>
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Kelas & Jenjang</span>
              <span class="text-xs font-semibold text-slate-700">
                Kelas {{ selectedAchievement.student?.class_name || '-' }} (Tingkat {{ selectedAchievement.student?.grade_level || '-' }})
              </span>
            </div>
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Tingkat Wilayah</span>
              <span class="text-xs font-bold text-brand-blue uppercase">
                {{ (selectedAchievement.level || selectedAchievement.achievement_level || '-').replace('_', ' ') }}
              </span>
            </div>
          </div>

          <!-- Rincian Kompetisi & Penyelenggara -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-white p-4 rounded-2xl border border-slate-200/80">
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Penyelenggara</span>
              <span class="text-xs font-semibold text-slate-700">
                {{ selectedAchievement.organizer_name || selectedAchievement.field_name || '-' }}
              </span>
            </div>
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Tanggal Pelaksanaan</span>
              <span class="text-xs font-semibold text-slate-700">
                {{ selectedAchievement.event_date ? new Date(selectedAchievement.event_date).toLocaleDateString('id-ID', { dateStyle: 'long' }) : '-' }}
              </span>
            </div>
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Verifikator</span>
              <span class="text-xs font-semibold text-slate-700">
                {{ selectedAchievement.verified_by?.name || selectedAchievement.verifiedBy?.name || 'Sekolah' }}
                <span v-if="selectedAchievement.verified_at" class="text-[10px] text-slate-400 block font-normal">
                  {{ new Date(selectedAchievement.verified_at).toLocaleString('id-ID') }}
                </span>
              </span>
            </div>
            <div>
              <span class="text-[11px] text-slate-400 font-medium block">Visibilitas Publik</span>
              <span class="text-xs font-semibold text-slate-700">
                {{ selectedAchievement.is_public ? 'Nama Lengkap Ditampilkan Publik' : 'Disamarkan (Privacy by Default)' }}
              </span>
            </div>
          </div>

          <!-- Berkas & Sertifikat Dokumen -->
          <div class="bg-slate-50 p-4 rounded-2xl border border-slate-200/80">
            <span class="text-[11px] text-slate-500 font-bold block mb-2">Berkas Sertifikat / Piagam</span>
            <div v-if="selectedAchievement.documents && selectedAchievement.documents.length > 0" class="space-y-2">
              <div
                v-for="doc in selectedAchievement.documents"
                :key="doc.id"
                class="flex items-center justify-between p-2.5 bg-white rounded-xl border border-slate-200"
              >
                <div class="flex items-center gap-2 overflow-hidden">
                  <i class="fa-solid fa-file-pdf text-rose-500 text-sm"></i>
                  <div class="truncate">
                    <p class="font-semibold text-slate-800 text-xs truncate">{{ doc.file_name || 'Piagam / Sertifikat Kejuaraan' }}</p>
                    <p class="text-[10px] text-slate-400">{{ (doc.file_size ? (doc.file_size / 1024).toFixed(1) + ' KB' : 'Dokumen Terlampir') }}</p>
                  </div>
                </div>
                <div class="flex items-center gap-2">
                  <button
                    v-if="doc.file_path"
                    type="button"
                    @click="downloadDoc(selectedAchievement.id, doc.id, doc.file_name)"
                    class="px-2.5 py-1 bg-brand-navy hover:bg-[#001442] text-white rounded-lg text-xs font-semibold transition-all cursor-pointer flex items-center gap-1"
                  >
                    <i class="fa-solid fa-download"></i> Unduh
                  </button>
                  <a
                    v-if="doc.external_url"
                    :href="doc.external_url"
                    target="_blank"
                    class="px-2.5 py-1 bg-blue-50 text-brand-blue rounded-lg text-xs font-semibold hover:bg-blue-100 flex items-center gap-1"
                  >
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Link Eksternal
                  </a>
                </div>
              </div>
            </div>
            <div v-else class="text-slate-400 italic text-[11px]">
              Belum ada berkas fisik atau link sertifikat yang dilampirkan.
            </div>
          </div>

          <!-- Footer Actions -->
          <div class="pt-3 border-t border-slate-100 flex items-center justify-between gap-2 flex-wrap">
            <div>
              <router-link
                v-if="selectedAchievement.public_id"
                :to="`/verify/${selectedAchievement.public_id}`"
                target="_blank"
                class="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-brand-blue rounded-xl text-xs font-bold inline-flex items-center gap-1.5"
              >
                <i class="fa-solid fa-qrcode"></i> Buka Halaman Verifikasi QR
              </router-link>
            </div>
            <div class="flex items-center gap-2">
              <button
                type="button"
                @click="showDetailModal = false; openEditModal(selectedAchievement)"
                class="px-3.5 py-1.5 bg-amber-500 hover:bg-amber-600 text-white rounded-xl font-bold cursor-pointer inline-flex items-center gap-1"
              >
                <i class="fa-solid fa-pen-to-square"></i> Edit
              </button>
              <button
                type="button"
                @click="showDetailModal = false"
                class="px-4 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl"
              >
                Tutup
              </button>
            </div>
          </div>
        </div>
      </Modal>

      <!-- ========================================== -->
      <!-- MODAL TAMBAH PRESTASI (CREATE)              -->
      <!-- ========================================== -->
      <Modal v-model="showAddModal" title="Catat Rekam Prestasi Siswa" size="lg">
        <form @submit.prevent="handleAddAchievement" class="space-y-4 text-xs">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div class="sm:col-span-2">
              <SearchableSelect
                v-model="addForm.student_id"
                label="Pilih Siswa *"
                placeholder="Pilih atau cari nama siswa / NIS..."
                searchPlaceholder="Ketik nama siswa atau NIS..."
                :options="studentOptions"
                required
              />
            </div>

            <div class="sm:col-span-2">
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
              <label class="block font-semibold text-slate-700 mb-1">Nama Kompetisi / Kejuaraan Manual *</label>
              <input
                v-model="addForm.competition_name_manual"
                type="text"
                required
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
                <option value="internasional">Tingkat Internasional</option>
                <option value="nasional">Tingkat Nasional</option>
                <option value="provinsi">Tingkat Provinsi</option>
                <option value="kota_kabupaten">Tingkat Kota / Kabupaten</option>
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
                placeholder="Contoh: Robotika, MTQ, Riset, Matematika"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Penyelenggara Lomba</label>
              <input
                v-model="addForm.organizer_name"
                type="text"
                placeholder="Contoh: Puspresnas, Kemendikbud, Universitas Brawijaya"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tanggal Kejuaraan *</label>
              <input
                v-model="addForm.event_date"
                type="date"
                required
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Status Verifikasi</label>
              <select
                v-model="addForm.status"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="verified">Terverifikasi (Terbitkan QR Otomatis)</option>
                <option value="pending_verification">Menunggu Verifikasi</option>
                <option value="draft">Simpan sebagai Draft</option>
              </select>
            </div>

            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Unggah Sertifikat / Piagam (Opsional)</label>
              <input
                type="file"
                accept=".pdf,.jpg,.jpeg,.png"
                @change="handleAddFileChange"
                class="w-full text-xs text-slate-500 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-[#001442] file:cursor-pointer"
              />
              <p class="text-[10px] text-slate-400 mt-1">Format PDF, JPG, PNG maksimal 5 MB.</p>
            </div>

            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Atau Link Eksternal Berkas (Opsional)</label>
              <input
                v-model="addForm.external_url"
                type="url"
                placeholder="https://drive.google.com/..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div class="sm:col-span-2 flex items-center gap-2 pt-1">
              <input
                type="checkbox"
                id="add_is_public"
                v-model="addForm.is_public"
                class="rounded border-slate-300 text-brand-navy focus:ring-brand-blue"
              />
              <label for="add_is_public" class="text-xs text-slate-600 cursor-pointer">
                Tampilkan nama lengkap siswa secara publik saat QR verifikasi discan
              </label>
            </div>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showAddModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl cursor-pointer"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="adding"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs cursor-pointer disabled:opacity-50"
            >
              <i v-if="adding" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Simpan Prestasi</span>
            </button>
          </div>
        </form>
      </Modal>

      <!-- ========================================== -->
      <!-- MODAL EDIT PRESTASI (UPDATE)                -->
      <!-- ========================================== -->
      <Modal v-model="showEditModal" title="Edit Rekam Prestasi Siswa" size="lg">
        <form @submit.prevent="handleUpdateAchievement" class="space-y-4 text-xs">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div class="sm:col-span-2">
              <SearchableSelect
                v-model="editForm.student_id"
                label="Pilih Siswa *"
                placeholder="Pilih atau cari nama siswa / NIS..."
                searchPlaceholder="Ketik nama siswa atau NIS..."
                :options="studentOptions"
                required
              />
            </div>

            <div class="sm:col-span-2">
              <SearchableSelect
                v-model="editForm.competition_id"
                label="Pilih dari Database Kompetisi (Opsional)"
                placeholder="Pilih lomba resmi (opsional)..."
                searchPlaceholder="Ketik nama lomba (OSN, FLS2N, O2SN, dll)..."
                :options="competitionOptions"
                :clearable="true"
              />
            </div>

            <div v-if="!editForm.competition_id" class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Nama Kompetisi / Kejuaraan Manual *</label>
              <input
                v-model="editForm.competition_name_manual"
                type="text"
                required
                placeholder="Contoh: Lomba Cipta Puisi Pelajar Nasional"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tingkat Prestasi *</label>
              <select
                v-model="editForm.achievement_level"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="internasional">Tingkat Internasional</option>
                <option value="nasional">Tingkat Nasional</option>
                <option value="provinsi">Tingkat Provinsi</option>
                <option value="kota_kabupaten">Tingkat Kota / Kabupaten</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Peringkat / Capaian Juara *</label>
              <input
                v-model="editForm.rank"
                type="text"
                required
                placeholder="Contoh: Juara 1 / Medali Emas"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Bidang / Kategori Lomba</label>
              <input
                v-model="editForm.field_name"
                type="text"
                placeholder="Contoh: Robotika, MTQ, Riset, Matematika"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Penyelenggara Lomba</label>
              <input
                v-model="editForm.organizer_name"
                type="text"
                placeholder="Contoh: Puspresnas, Kemendikbud, Universitas Brawijaya"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tanggal Kejuaraan *</label>
              <input
                v-model="editForm.event_date"
                type="date"
                required
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Status Verifikasi</label>
              <select
                v-model="editForm.status"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="verified">Terverifikasi (Sah & Terbit QR)</option>
                <option value="pending_verification">Menunggu Verifikasi</option>
                <option value="rejected">Ditolak</option>
                <option value="draft">Draft</option>
              </select>
            </div>

            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Ganti Berkas Sertifikat / Piagam (Opsional)</label>
              <input
                type="file"
                accept=".pdf,.jpg,.jpeg,.png"
                @change="handleEditFileChange"
                class="w-full text-xs text-slate-500 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-amber-600 file:text-white hover:file:bg-amber-700 file:cursor-pointer"
              />
              <p class="text-[10px] text-slate-400 mt-1">Kosongkan jika tidak ingin mengubah berkas sertifikat yang sudah ada.</p>
            </div>

            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Link Eksternal Berkas</label>
              <input
                v-model="editForm.external_url"
                type="url"
                placeholder="https://drive.google.com/..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div class="sm:col-span-2 flex items-center gap-2 pt-1">
              <input
                type="checkbox"
                id="edit_is_public"
                v-model="editForm.is_public"
                class="rounded border-slate-300 text-brand-navy focus:ring-brand-blue"
              />
              <label for="edit_is_public" class="text-xs text-slate-600 cursor-pointer">
                Tampilkan nama lengkap siswa secara publik saat QR verifikasi discan
              </label>
            </div>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showEditModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl cursor-pointer"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="editing"
              class="px-5 py-2 font-bold text-white bg-amber-600 hover:bg-amber-700 rounded-xl shadow-xs cursor-pointer disabled:opacity-50"
            >
              <i v-if="editing" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Simpan Perubahan</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
