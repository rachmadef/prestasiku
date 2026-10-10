<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast, confirm } = useNotify()

const students = ref<any[]>([])
const loading = ref(true)
const searchQuery = ref('')

// Pagination state
const currentPage = ref(1)
const perPage = ref(15)

const filteredStudents = computed(() => {
  const list = Array.isArray(students.value) ? students.value : []
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return list
  return list.filter((s: any) =>
    s.full_name?.toLowerCase().includes(q) ||
    s.nis?.toLowerCase().includes(q) ||
    s.nisn?.toLowerCase().includes(q) ||
    s.class_name?.toLowerCase().includes(q)
  )
})

const totalItems = computed(() => filteredStudents.value.length)
const totalPages = computed(() => Math.ceil(totalItems.value / perPage.value) || 1)

const paginatedStudents = computed(() => {
  const start = (currentPage.value - 1) * perPage.value
  return filteredStudents.value.slice(start, start + perPage.value)
})

const displayRangeStart = computed(() => {
  if (totalItems.value === 0) return 0
  return (currentPage.value - 1) * perPage.value + 1
})

const displayRangeEnd = computed(() => {
  return Math.min(currentPage.value * perPage.value, totalItems.value)
})

// Reset to page 1 on search or limit change
watch([searchQuery, perPage], () => {
  currentPage.value = 1
})

function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

// Generate smart page numbers (e.g. 1, 2, 3 ... 43)
const visiblePages = computed(() => {
  const total = totalPages.value
  const current = currentPage.value
  const delta = 2
  const range: (number | string)[] = []

  for (let i = Math.max(2, current - delta); i <= Math.min(total - 1, current + delta); i++) {
    range.push(i)
  }

  if (current - delta > 2) {
    range.unshift('...')
  }
  if (current + delta < total - 1) {
    range.push('...')
  }

  range.unshift(1)
  if (total > 1) {
    range.push(total)
  }

  return range
})

// Add Student Modal
const showAddModal = ref(false)
const addForm = ref({
  nis: '',
  nisn: '',
  full_name: '',
  email: '',
  phone_number: '',
  grade_level: 10,
  class_name: '',
  gender: 'L',
  birth_date: '',
  birth_place: '',
})
const addingStudent = ref(false)

// Edit Student Modal
const showEditModal = ref(false)
const editingStudentId = ref<number | null>(null)
const editForm = ref({
  full_name: '',
  nis: '',
  nisn: '',
  grade_level: 10,
  class_name: '',
  gender: 'L',
  birth_place: '',
  birth_date: '',
  phone_number: '',
  status: 'active',
})
const updatingStudent = ref(false)

function openEditModal(student: any) {
  editingStudentId.value = student.id
  editForm.value = {
    full_name: student.full_name || '',
    nis: student.nis || '',
    nisn: student.nisn || '',
    grade_level: student.grade_level || 10,
    class_name: student.class_name || '',
    gender: student.gender || 'L',
    birth_place: student.birth_place || '',
    birth_date: student.birth_date ? student.birth_date.split('T')[0] : '',
    phone_number: student.phone_number || '',
    status: student.status || 'active',
  }
  showEditModal.value = true
}

async function handleUpdateStudent() {
  if (!editingStudentId.value) return
  updatingStudent.value = true
  try {
    await api.put(`/school/students/${editingStudentId.value}`, editForm.value)
    showEditModal.value = false
    fetchStudents()
    toast.success('Data siswa berhasil diperbarui!', 'Perubahan Disimpan')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memperbarui data siswa.', 'Gagal Perbarui')
  } finally {
    updatingStudent.value = false
  }
}

async function handleDeleteStudent(student: any) {
  const ok = await confirm({
    title: 'Hapus Data Siswa',
    message: `Apakah Anda yakin ingin menghapus data siswa "${student.full_name}" (NIS: ${student.nis}) beserta akun penggunanya? Tindakan ini tidak dapat dibatalkan.`,
    type: 'danger',
    confirmText: 'Ya, Hapus Siswa',
  })
  if (!ok) return

  try {
    await api.delete(`/school/students/${student.id}`)
    toast.success(`Data siswa ${student.full_name} berhasil dihapus.`, 'Terhapus')
    fetchStudents()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menghapus data siswa.', 'Gagal Hapus')
  }
}

// Bulk Import Modal
const showImportModal = ref(false)
const importFile = ref<File | null>(null)
const importing = ref(false)
const importResult = ref<any>(null)

const perPageOption = ref<'all' | number>('all')

async function fetchStudents() {
  loading.value = true
  try {
    const res = await api.get('/school/students', {
      params: { per_page: perPageOption.value },
    })
    students.value = extractList(res.data.data)
  } catch (err) {
    console.error('Error loading students:', err)
  } finally {
    loading.value = false
  }
}

async function handleAddStudent() {
  addingStudent.value = true
  try {
    await api.post('/school/students', addForm.value)
    showAddModal.value = false
    addForm.value = {
      nis: '',
      nisn: '',
      full_name: '',
      email: '',
      phone_number: '',
      grade_level: 10,
      class_name: '',
      gender: 'L',
      birth_date: '',
      birth_place: '',
    }
    fetchStudents()
    toast.success('Siswa baru berhasil didaftarkan!', 'Data Tersimpan')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menambahkan siswa.', 'Gagal Simpan')
  } finally {
    addingStudent.value = false
  }
}

async function handleResetPassword(student: any) {
  const ok = await confirm({
    title: 'Reset Kata Sandi Siswa',
    message: `Apakah Anda yakin ingin me-reset kata sandi akun ${student.full_name} kembali ke default "1234"? Siswa akan diminta membuat kata sandi baru saat login berikutnya.`,
    type: 'warning',
    confirmText: 'Ya, Reset Password',
  })
  if (!ok) return

  try {
    const res = await api.post(`/school/students/${student.id}/reset-password`)
    toast.success(res.data.message || 'Password siswa berhasil di-reset ke 1234.', 'Reset Berhasil')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal me-reset password.', 'Gagal Reset')
  }
}

function handleFileChange(e: any) {
  if (e.target.files && e.target.files[0]) {
    importFile.value = e.target.files[0]
  }
}

async function submitImport() {
  if (!importFile.value) return
  importing.value = true
  importResult.value = null
  const formData = new FormData()
  formData.append('file', importFile.value)

  try {
    const res = await api.post('/school/students-import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    importResult.value = res.data
    toast.success('File CSV data siswa berhasil diimpor!', 'Impor Selesai')
    fetchStudents()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengimpor file.', 'Impor Gagal')
  } finally {
    importing.value = false
  }
}

async function downloadTemplate() {
  try {
    const res = await api.get('/school/students-import/template', {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(new Blob([res.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', 'template_import_siswa_prestasiku.xlsx')
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
  } catch (err) {
    console.error('Error downloading template:', err)
  }
}

onMounted(() => {
  fetchStudents()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Manajemen Siswa</template>
    <template #header-subtitle>Kelola data siswa tenant sekolah, akun login, dan import data massal.</template>

    <div class="space-y-6">
      <!-- Action Bar -->
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-3">
        <div class="flex items-center gap-3 flex-1 max-w-xl">
          <div class="relative flex-1">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
              <i class="fa-solid fa-magnifying-glass text-xs"></i>
            </div>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Cari nama siswa, NIS, atau kelas..."
              class="w-full pl-9 pr-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue shadow-2xs"
            />
          </div>

          <!-- Total Count Badge -->
          <span class="px-3 py-2 bg-blue-50 text-brand-blue border border-blue-200/80 rounded-xl text-xs font-bold shrink-0 flex items-center gap-1.5">
            <i class="fa-solid fa-users text-brand-gold"></i>
            <span>{{ filteredStudents.length }} Siswa</span>
          </span>
        </div>

        <div class="flex items-center gap-2">
          <!-- Limit selector dropdown -->
          <div class="flex items-center gap-1.5 bg-white px-3 py-1.5 border border-slate-200 rounded-xl text-xs shrink-0">
            <span class="text-slate-500 font-semibold">Tampilkan:</span>
            <select
              v-model="perPageOption"
              @change="fetchStudents"
              class="bg-transparent font-bold text-brand-navy focus:outline-hidden cursor-pointer"
            >
              <option value="all">Semua Siswa</option>
              <option :value="20">20 per Hal</option>
              <option :value="50">50 per Hal</option>
              <option :value="100">100 per Hal</option>
            </select>
          </div>

          <button
            type="button"
            @click="showImportModal = true"
            class="px-3.5 py-2 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200/80 rounded-xl text-xs font-bold transition-colors flex items-center gap-1.5 cursor-pointer shrink-0"
          >
            <i class="fa-solid fa-file-excel"></i>
            <span>Import Excel / CSV</span>
          </button>
          <button
            type="button"
            @click="showAddModal = true"
            class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white rounded-xl text-xs font-bold transition-all shadow-xs flex items-center gap-1.5 cursor-pointer shrink-0"
          >
            <i class="fa-solid fa-user-plus text-brand-gold"></i>
            <span>Tambah Siswa</span>
          </button>
        </div>
      </div>

      <!-- Students Table -->
      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Siswa</th>
                <th class="px-6 py-3.5">NIS / NISN</th>
                <th class="px-6 py-3.5">Tingkat & Kelas</th>
                <th class="px-6 py-3.5">JK</th>
                <th class="px-6 py-3.5">Status Akun</th>
                <th class="px-6 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="students.length === 0">
                <td colspan="6" class="px-6 py-8 text-center text-slate-400">
                  Belum ada siswa terdaftar. Silakan tambah atau import data.
                </td>
              </tr>
              <tr
                v-for="st in paginatedStudents"
                :key="st.id"
                class="hover:bg-slate-50/50 transition-colors"
              >
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ st.full_name }}</div>
                  <div class="text-[11px] text-slate-400">{{ st.user?.email || '-' }}</div>
                </td>
                <td class="px-6 py-4 font-mono text-[11px]">
                  <div>NIS: {{ st.nis }}</div>
                  <div class="text-slate-400">NISN: {{ st.nisn || '-' }}</div>
                </td>
                <td class="px-6 py-4">
                  <span class="font-semibold text-slate-800">Kelas {{ st.class_name }}</span>
                  <span class="text-[10px] text-slate-400 block">(Tingkat {{ st.grade_level }})</span>
                </td>
                <td class="px-6 py-4 font-semibold text-slate-700">
                  {{ st.gender === 'L' ? 'Laki-laki' : 'Perempuan' }}
                </td>
                <td class="px-6 py-4">
                  <Badge :status="st.status || 'active'" />
                </td>
                <td class="px-6 py-4 text-right">
                  <div class="flex items-center justify-end gap-1.5">
                    <button
                      type="button"
                      @click="openEditModal(st)"
                      class="px-2.5 py-1 text-brand-blue hover:text-[#0c4e85] hover:bg-blue-50 border border-blue-200/80 rounded-lg text-xs font-bold transition-colors flex items-center gap-1 cursor-pointer"
                      title="Edit Data Siswa"
                    >
                      <i class="fa-solid fa-pen-to-square"></i>
                      <span>Edit</span>
                    </button>
                    <button
                      type="button"
                      @click="handleResetPassword(st)"
                      class="px-2.5 py-1 text-slate-700 hover:text-amber-800 hover:bg-amber-50 border border-slate-200 rounded-lg text-xs font-semibold transition-colors flex items-center gap-1 cursor-pointer"
                      title="Reset Password ke default '1234'"
                    >
                      <i class="fa-solid fa-key text-brand-gold"></i>
                      <span>Reset</span>
                    </button>
                    <button
                      type="button"
                      @click="handleDeleteStudent(st)"
                      class="px-2.5 py-1 text-rose-600 hover:text-rose-700 hover:bg-rose-50 border border-rose-200 rounded-lg text-xs font-bold transition-colors flex items-center gap-1 cursor-pointer"
                      title="Hapus Data Siswa"
                    >
                      <i class="fa-solid fa-trash-can"></i>
                      <span>Hapus</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination Footer Bar (Centered & Spaced Away From Floating AI Widget) -->
        <div class="px-6 py-4 bg-slate-50/75 border-t border-slate-100 flex flex-col md:flex-row items-center justify-center gap-4 sm:gap-6 text-xs text-slate-600">
          <!-- Information Range & Limit Selector -->
          <div class="flex flex-wrap items-center justify-center gap-3">
            <span class="font-medium">
              Menampilkan <span class="font-bold text-slate-900">{{ displayRangeStart }}-{{ displayRangeEnd }}</span> dari <span class="font-bold text-slate-900">{{ totalItems }}</span> siswa
            </span>
            <span v-if="searchQuery" class="text-[11px] text-brand-blue bg-blue-50 px-2 py-0.5 rounded-md font-semibold border border-blue-100">
              (Terfilter dari {{ students.length }} total)
            </span>

            <!-- Per Page Selector -->
            <div class="flex items-center gap-1.5 ml-2 bg-white px-2.5 py-1 border border-slate-200 rounded-lg shadow-2xs">
              <span class="text-slate-500 font-semibold text-[11px]">Per hal:</span>
              <select
                v-model="perPage"
                class="bg-transparent text-slate-800 font-bold focus:outline-hidden cursor-pointer text-xs"
              >
                <option :value="10">10</option>
                <option :value="15">15</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>

          <!-- Page Navigation Buttons (Centered) -->
          <div class="flex items-center gap-1.5 justify-center">
            <!-- Previous Page Button -->
            <button
              type="button"
              @click="goToPage(currentPage - 1)"
              :disabled="currentPage === 1"
              class="px-3 py-1.5 rounded-lg border bg-white font-semibold text-slate-700 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors shadow-2xs flex items-center gap-1 cursor-pointer"
            >
              <i class="fa-solid fa-chevron-left text-[10px]"></i>
              <span>Sebelumnya</span>
            </button>

            <!-- Page Number Buttons -->
            <div class="flex items-center gap-1">
              <template v-for="(p, idx) in visiblePages" :key="idx">
                <span v-if="p === '...'" class="px-1 text-slate-400 font-bold">...</span>
                <button
                  v-else
                  type="button"
                  @click="goToPage(p as number)"
                  :class="[
                    'w-7.5 h-7.5 rounded-lg font-bold transition-all text-xs flex items-center justify-center cursor-pointer',
                    currentPage === p
                      ? 'bg-brand-navy text-white shadow-2xs ring-2 ring-brand-navy/20'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-100'
                  ]"
                >
                  {{ p }}
                </button>
              </template>
            </div>

            <!-- Next Page Button -->
            <button
              type="button"
              @click="goToPage(currentPage + 1)"
              :disabled="currentPage === totalPages"
              class="px-3 py-1.5 rounded-lg border bg-white font-semibold text-slate-700 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors shadow-2xs flex items-center gap-1 cursor-pointer"
            >
              <span>Berikutnya</span>
              <i class="fa-solid fa-chevron-right text-[10px]"></i>
            </button>
          </div>
        </div>
      </div>

      <!-- Add Student Modal -->
      <Modal v-model="showAddModal" title="Tambah Data Siswa Baru" size="lg">
        <form @submit.prevent="handleAddStudent" class="space-y-4 text-xs">
          <div class="p-3 bg-blue-50 border border-blue-200 rounded-xl text-brand-blue flex items-center gap-2">
            <i class="fa-solid fa-circle-info"></i>
            <span>Akun siswa akan otomatis dibuatkan dengan password awal <strong>1234</strong>. Siswa wajib mengganti password saat login pertama kali.</span>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nama Lengkap Siswa *</label>
              <input
                v-model="addForm.full_name"
                type="text"
                required
                placeholder="Contoh: Muhammad Farhan"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Email Siswa *</label>
              <input
                v-model="addForm.email"
                type="email"
                required
                placeholder="farhan@siswa.sch.id"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">NIS (Nomor Induk Siswa) *</label>
              <input
                v-model="addForm.nis"
                type="text"
                required
                placeholder="2026002"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">NISN (10 Digit)</label>
              <input
                v-model="addForm.nisn"
                type="text"
                placeholder="0081234567"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tingkat Kelas *</label>
              <select
                v-model="addForm.grade_level"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option :value="7">Kelas 7 (SLTP)</option>
                <option :value="8">Kelas 8 (SLTP)</option>
                <option :value="9">Kelas 9 (SLTP)</option>
                <option :value="10">Kelas 10 (SLTA)</option>
                <option :value="11">Kelas 11 (SLTA)</option>
                <option :value="12">Kelas 12 (SLTA)</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nama Rombel / Kelas *</label>
              <input
                v-model="addForm.class_name"
                type="text"
                required
                placeholder="Contoh: X MIPA 2"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Jenis Kelamin *</label>
              <select
                v-model="addForm.gender"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="L">Laki-laki (L)</option>
                <option value="P">Perempuan (P)</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tempat Lahir</label>
              <input
                v-model="addForm.birth_place"
                type="text"
                placeholder="Contoh: Jakarta"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tanggal Lahir</label>
              <input
                v-model="addForm.birth_date"
                type="date"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nomor WhatsApp Siswa</label>
              <input
                v-model="addForm.phone_number"
                type="text"
                placeholder="0812..."
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
              :disabled="addingStudent"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs"
            >
              Simpan Siswa
            </button>
          </div>
        </form>
      </Modal>

      <!-- Edit Student Modal -->
      <Modal v-model="showEditModal" title="Edit Data Siswa" size="lg">
        <form @submit.prevent="handleUpdateStudent" class="space-y-4 text-xs">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nama Lengkap Siswa *</label>
              <input
                v-model="editForm.full_name"
                type="text"
                required
                placeholder="Contoh: Muhammad Farhan"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">NIS (Nomor Induk Siswa)</label>
              <input
                v-model="editForm.nis"
                type="text"
                disabled
                class="w-full px-3 py-2 bg-slate-100 border border-slate-200 rounded-xl text-slate-500 font-mono cursor-not-allowed"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">NISN (10 Digit)</label>
              <input
                v-model="editForm.nisn"
                type="text"
                placeholder="0081234567"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-mono"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tingkat Kelas *</label>
              <select
                v-model="editForm.grade_level"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option :value="7">Kelas 7 (SLTP)</option>
                <option :value="8">Kelas 8 (SLTP)</option>
                <option :value="9">Kelas 9 (SLTP)</option>
                <option :value="10">Kelas 10 (SLTA)</option>
                <option :value="11">Kelas 11 (SLTA)</option>
                <option :value="12">Kelas 12 (SLTA)</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nama Rombel / Kelas *</label>
              <input
                v-model="editForm.class_name"
                type="text"
                required
                placeholder="Contoh: X MIPA 2"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Jenis Kelamin *</label>
              <select
                v-model="editForm.gender"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="L">Laki-laki (L)</option>
                <option value="P">Perempuan (P)</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tempat Lahir</label>
              <input
                v-model="editForm.birth_place"
                type="text"
                placeholder="Contoh: Jombang"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tanggal Lahir</label>
              <input
                v-model="editForm.birth_date"
                type="date"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nomor WhatsApp Siswa</label>
              <input
                v-model="editForm.phone_number"
                type="text"
                placeholder="0812..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Status Akun Siswa *</label>
              <select
                v-model="editForm.status"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-semibold text-slate-800"
              >
                <option value="active">Aktif</option>
                <option value="graduated">Lulus</option>
                <option value="transferred">Pindah Sekolah</option>
                <option value="inactive">Non-Aktif</option>
              </select>
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
              :disabled="updatingStudent"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
            >
              <i v-if="updatingStudent" class="fa-solid fa-spinner fa-spin"></i>
              <span>Simpan Perubahan</span>
            </button>
          </div>
        </form>
      </Modal>

      <!-- Bulk Import Modal -->
      <Modal v-model="showImportModal" title="Import Data Siswa Massal" size="md">
        <div class="space-y-4 text-xs">
          <div class="p-4 bg-slate-50 rounded-2xl border border-slate-100 flex items-center justify-between">
            <div>
              <p class="font-bold text-slate-800">Unduh Format Template</p>
              <p class="text-slate-500 mt-0.5">Gunakan format Excel standar untuk menghindari kesalahan pemindaian kolom.</p>
            </div>
            <button
              type="button"
              @click="downloadTemplate"
              class="px-3 py-1.5 bg-brand-blue text-white rounded-lg font-bold shadow-2xs hover:bg-[#0d4f88] shrink-0"
            >
              <i class="fa-solid fa-download mr-1"></i> Template
            </button>
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Pilih Berkas Spreadsheet (.xlsx, .csv) *</label>
            <input
              type="file"
              accept=".xlsx,.xls,.csv"
              @change="handleFileChange"
              class="w-full text-xs text-slate-500 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-[#001442]"
            />
          </div>

          <div v-if="importResult" class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800">
            <p class="font-bold flex items-center gap-1.5 mb-1">
              <i class="fa-solid fa-circle-check"></i>
              Import Selesai!
            </p>
            <p>Total data berhasil diproses.</p>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showImportModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Tutup
            </button>
            <button
              type="button"
              @click="submitImport"
              :disabled="!importFile || importing"
              class="px-5 py-2 font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl shadow-xs disabled:opacity-50"
            >
              <i v-if="importing" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Mulai Import</span>
            </button>
          </div>
        </div>
      </Modal>
    </div>
  </DashboardLayout>
</template>
