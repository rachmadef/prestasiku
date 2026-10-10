<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api from '@/services/api'

interface Signer {
  id: number
  school_id: number
  name: string
  nip: string | null
  position_title: string
  role_type: 'waka_kesiswaan' | 'pj_lomba' | 'kepala_sekolah' | 'other'
  signature_token: string
  photo_path: string | null
  photo_url?: string | null
  birth_place: string | null
  birth_date: string | null
  address: string | null
  education_history: string | null
  biography: string | null
  phone: string | null
  email: string | null
  is_active: boolean
  qr_code_url?: string
  qr_code_data_uri?: string
}

const signers = ref<Signer[]>([])
const loading = ref(false)
const searchQuery = ref('')
const selectedRoleFilter = ref<string>('all')

// Modal states
const showFormModal = ref(false)
const isEditing = ref(false)
const formLoading = ref(false)
const currentSignerId = ref<number | null>(null)
const selectedPhotoFile = ref<File | null>(null)
const photoPreviewUrl = ref<string | null>(null)

const formData = ref({
  name: '',
  nip: '',
  position_title: '',
  role_type: 'waka_kesiswaan' as 'waka_kesiswaan' | 'pj_lomba' | 'kepala_sekolah' | 'other',
  birth_place: '',
  birth_date: '',
  address: '',
  education_history: '',
  biography: '',
  phone: '',
  email: '',
  is_active: true,
})

// QR Code Preview Modal
const showQrModal = ref(false)
const selectedSignerForQr = ref<Signer | null>(null)
const copySuccess = ref(false)

const roleOptions = [
  { value: 'waka_kesiswaan', label: 'Waka Kesiswaan (Wakil Kepala Sekolah Bidang Kesiswaan)' },
  { value: 'pj_lomba', label: 'Guru PJ Lomba / Olimpiade (Penanggung Jawab Lomba)' },
  { value: 'kepala_sekolah', label: 'Kepala Sekolah' },
  { value: 'other', label: 'Guru / Pembina Prestasi Lainnya' },
]

async function fetchSigners() {
  loading.value = true
  try {
    const res = await api.get('/school/signers')
    signers.value = res.data.data
  } catch (err: any) {
    console.error('Gagal mengambil data guru penandatangan dispen:', err)
  } finally {
    loading.value = false
  }
}

const filteredSigners = computed(() => {
  return signers.value.filter((signer) => {
    const matchRole = selectedRoleFilter.value === 'all' || signer.role_type === selectedRoleFilter.value
    const q = searchQuery.value.toLowerCase()
    const matchQuery =
      !q ||
      signer.name.toLowerCase().includes(q) ||
      (signer.nip && signer.nip.toLowerCase().includes(q)) ||
      signer.position_title.toLowerCase().includes(q)
    return matchRole && matchQuery
  })
})

const wakaSigner = computed(() => signers.value.find((s) => s.role_type === 'waka_kesiswaan' && s.is_active))
const pjSigner = computed(() => signers.value.find((s) => s.role_type === 'pj_lomba' && s.is_active))

function handlePhotoChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    selectedPhotoFile.value = file
    photoPreviewUrl.value = URL.createObjectURL(file)
  }
}

function openCreateModal(presetRole?: 'waka_kesiswaan' | 'pj_lomba') {
  isEditing.value = false
  currentSignerId.value = null
  selectedPhotoFile.value = null
  photoPreviewUrl.value = null
  formData.value = {
    name: '',
    nip: '',
    position_title: presetRole === 'waka_kesiswaan' ? 'Waka Kesiswaan' : (presetRole === 'pj_lomba' ? 'Guru PJ Lomba & Olimpiade' : ''),
    role_type: presetRole || 'waka_kesiswaan',
    birth_place: '',
    birth_date: '',
    address: '',
    education_history: '',
    biography: '',
    phone: '',
    email: '',
    is_active: true,
  }
  showFormModal.value = true
}

function openEditModal(signer: Signer) {
  isEditing.value = true
  currentSignerId.value = signer.id
  selectedPhotoFile.value = null
  photoPreviewUrl.value = signer.photo_path ? `/storage/${signer.photo_path}` : null
  formData.value = {
    name: signer.name,
    nip: signer.nip || '',
    position_title: signer.position_title,
    role_type: signer.role_type,
    birth_place: signer.birth_place || '',
    birth_date: signer.birth_date ? signer.birth_date.substring(0, 10) : '',
    address: signer.address || '',
    education_history: signer.education_history || '',
    biography: signer.biography || '',
    phone: signer.phone || '',
    email: signer.email || '',
    is_active: signer.is_active,
  }
  showFormModal.value = true
}

function openQrModal(signer: Signer) {
  selectedSignerForQr.value = signer
  copySuccess.value = false
  showQrModal.value = true
}

async function handleSave() {
  if (!formData.value.name || !formData.value.position_title) {
    alert('Mohon lengkapi Nama dan Jabatan Guru.')
    return
  }

  formLoading.value = true
  try {
    const data = new FormData()
    data.append('name', formData.value.name)
    data.append('position_title', formData.value.position_title)
    data.append('role_type', formData.value.role_type)
    if (formData.value.nip) data.append('nip', formData.value.nip)
    if (formData.value.birth_place) data.append('birth_place', formData.value.birth_place)
    if (formData.value.birth_date) data.append('birth_date', formData.value.birth_date)
    if (formData.value.address) data.append('address', formData.value.address)
    if (formData.value.education_history) data.append('education_history', formData.value.education_history)
    if (formData.value.biography) data.append('biography', formData.value.biography)
    if (formData.value.phone) data.append('phone', formData.value.phone)
    if (formData.value.email) data.append('email', formData.value.email)
    data.append('is_active', formData.value.is_active ? '1' : '0')

    if (selectedPhotoFile.value) {
      data.append('photo', selectedPhotoFile.value)
    }

    if (isEditing.value && currentSignerId.value) {
      data.append('_method', 'PUT')
      await api.post(`/school/signers/${currentSignerId.value}`, data, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    } else {
      await api.post('/school/signers', data, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    }
    showFormModal.value = false
    await fetchSigners()
  } catch (err: any) {
    alert(err.response?.data?.message || 'Gagal menyimpan data guru penandatangan.')
  } finally {
    formLoading.value = false
  }
}

async function handleDelete(signer: Signer) {
  if (!confirm(`Apakah Anda yakin ingin menghapus data penandatangan "${signer.name}"?`)) return

  try {
    await api.delete(`/school/signers/${signer.id}`)
    await fetchSigners()
  } catch (err: any) {
    alert(err.response?.data?.message || 'Gagal menghapus data guru penandatangan.')
  }
}

async function copyVerificationLink() {
  if (!selectedSignerForQr.value?.qr_code_url) return
  try {
    await navigator.clipboard.writeText(selectedSignerForQr.value.qr_code_url)
    copySuccess.value = true
    setTimeout(() => {
      copySuccess.value = false
    }, 2500)
  } catch {
    alert('Gagal menyalin tautan.')
  }
}

function downloadQrCode() {
  if (!selectedSignerForQr.value?.qr_code_data_uri) return
  const link = document.createElement('a')
  link.href = selectedSignerForQr.value.qr_code_data_uri
  const safeName = selectedSignerForQr.value.name.replace(/[^a-zA-Z0-9]/g, '_')
  link.download = `QR_TTD_${safeName}.svg`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

function getRoleBadgeClass(role: string) {
  switch (role) {
    case 'waka_kesiswaan':
      return 'bg-purple-100 text-purple-800 border-purple-200'
    case 'pj_lomba':
      return 'bg-amber-100 text-amber-800 border-amber-200'
    case 'kepala_sekolah':
      return 'bg-blue-100 text-blue-800 border-blue-200'
    default:
      return 'bg-slate-100 text-slate-700 border-slate-200'
  }
}

function getRoleLabel(role: string) {
  switch (role) {
    case 'waka_kesiswaan':
      return 'Waka Kesiswaan'
    case 'pj_lomba':
      return 'Guru PJ Lomba/Olimpiade'
    case 'kepala_sekolah':
      return 'Kepala Sekolah'
    default:
      return 'Guru Pengesah'
  }
}

onMounted(() => {
  fetchSigners()
})
</script>

<template>
  <DashboardLayout>
    <div class="space-y-6 pb-12 font-sans text-slate-800">
      <!-- Page Header -->
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 text-xs font-semibold text-slate-500 mb-1">
            <span>Operasional Sekolah</span>
            <i class="fa-solid fa-chevron-right text-[10px]"></i>
            <span class="text-brand-navy font-bold">Kelola Guru TTD Surat Dispen & QR Code</span>
          </div>
          <h1 class="text-2xl font-bold text-slate-900 tracking-tight flex items-center gap-2.5">
            <i class="fa-solid fa-qrcode text-brand-navy"></i>
            <span>Guru Penandatangan Dispen & QR Code</span>
          </h1>
          <p class="text-xs text-slate-600 mt-1 max-w-2xl leading-relaxed">
            Kelola data guru pengesah tetap surat dispensasi KBM (Waka Kesiswaan & Guru PJ Lomba/Olimpiade). Setiap guru dilengkapi QR Code TTD Digital yang terverifikasi saat dipindai.
          </p>
        </div>

        <div class="flex items-center gap-2">
          <button
            type="button"
            @click="openCreateModal()"
            class="px-4 py-2.5 bg-brand-navy hover:bg-[#00174c] text-white text-xs font-bold rounded-xl shadow-sm transition-all flex items-center gap-2 cursor-pointer"
          >
            <i class="fa-solid fa-user-plus"></i>
            <span>Tambah Guru Signer</span>
          </button>
        </div>
      </div>

      <!-- Quick Summary Cards for Waka Kesiswaan & Guru PJ Lomba -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- Waka Kesiswaan Card -->
        <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs flex items-center justify-between">
          <div class="space-y-1">
            <p class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Waka Kesiswaan (Pengesah)</p>
            <h3 class="text-base font-bold text-slate-900 truncate max-w-[200px]">
              {{ wakaSigner ? wakaSigner.name : 'Belum Ditentukan' }}
            </h3>
            <p class="text-xs text-slate-500">
              {{ wakaSigner ? (wakaSigner.nip || 'NIP Terdaftar') : 'Silakan tambahkan data Waka Kesiswaan' }}
            </p>
          </div>
          <div class="w-12 h-12 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-user-shield"></i>
          </div>
        </div>

        <!-- Guru PJ Lomba Card -->
        <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs flex items-center justify-between">
          <div class="space-y-1">
            <p class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Guru PJ Lomba / Olimpiade</p>
            <h3 class="text-base font-bold text-slate-900 truncate max-w-[200px]">
              {{ pjSigner ? pjSigner.name : 'Belum Ditentukan' }}
            </h3>
            <p class="text-xs text-slate-500">
              {{ pjSigner ? (pjSigner.nip || 'NIP Terdaftar') : 'Silakan tambahkan Guru PJ Lomba' }}
            </p>
          </div>
          <div class="w-12 h-12 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-award"></i>
          </div>
        </div>

        <!-- Total Signers Card -->
        <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs flex items-center justify-between">
          <div class="space-y-1">
            <p class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Total Guru TTD Terdaftar</p>
            <h3 class="text-2xl font-extrabold text-brand-navy">
              {{ signers.length }} <span class="text-xs font-semibold text-slate-500">Guru</span>
            </h3>
            <p class="text-xs text-emerald-600 font-semibold flex items-center gap-1">
              <i class="fa-solid fa-circle-check"></i>
              <span>TTD Digital QR Code Aktif</span>
            </p>
          </div>
          <div class="w-12 h-12 rounded-xl bg-blue-100 text-brand-navy flex items-center justify-center text-xl shrink-0">
            <i class="fa-solid fa-file-signature"></i>
          </div>
        </div>
      </div>

      <!-- Main Section: Filters & Data Grid -->
      <div class="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <!-- Controls Header -->
        <div class="p-4 border-b border-slate-200 bg-slate-50/50 flex flex-col md:flex-row md:items-center justify-between gap-3">
          <!-- Filter Tabs -->
          <div class="flex items-center gap-1 overflow-x-auto pb-1 md:pb-0">
            <button
              type="button"
              @click="selectedRoleFilter = 'all'"
              :class="[
                'px-3 py-1.5 rounded-lg text-xs font-bold transition-all whitespace-nowrap cursor-pointer',
                selectedRoleFilter === 'all'
                  ? 'bg-brand-navy text-white shadow-xs'
                  : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
              ]"
            >
              Semua Guru
            </button>
            <button
              type="button"
              @click="selectedRoleFilter = 'waka_kesiswaan'"
              :class="[
                'px-3 py-1.5 rounded-lg text-xs font-bold transition-all whitespace-nowrap cursor-pointer',
                selectedRoleFilter === 'waka_kesiswaan'
                  ? 'bg-purple-700 text-white shadow-xs'
                  : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
              ]"
            >
              Waka Kesiswaan
            </button>
            <button
              type="button"
              @click="selectedRoleFilter = 'pj_lomba'"
              :class="[
                'px-3 py-1.5 rounded-lg text-xs font-bold transition-all whitespace-nowrap cursor-pointer',
                selectedRoleFilter === 'pj_lomba'
                  ? 'bg-amber-600 text-white shadow-xs'
                  : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
              ]"
            >
              Guru PJ Lomba / Olimpiade
            </button>
          </div>

          <!-- Search Input -->
          <div class="relative w-full md:w-64">
            <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Cari nama, NIP, jabatan..."
              class="w-full pl-9 pr-3 py-1.5 text-xs rounded-xl border border-slate-300 focus:border-brand-navy focus:outline-hidden bg-white"
            />
          </div>
        </div>

        <!-- Loading Table -->
        <div v-if="loading" class="p-12 text-center text-slate-500 space-y-2">
          <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
          <p class="text-xs font-medium">Memuat data guru penandatangan...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredSigners.length === 0" class="p-12 text-center space-y-3">
          <div class="w-14 h-14 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto text-xl">
            <i class="fa-solid fa-user-slash"></i>
          </div>
          <h3 class="text-sm font-bold text-slate-700">Belum Ada Guru Penandatangan</h3>
          <p class="text-xs text-slate-500 max-w-sm mx-auto">
            Silakan tambahkan data Waka Kesiswaan atau Guru PJ Lomba untuk mengaktifkan TTD berbasis QR Code pada surat dispensasi.
          </p>
          <div class="flex justify-center gap-2 pt-2">
            <button
              type="button"
              @click="openCreateModal('waka_kesiswaan')"
              class="px-3 py-2 bg-purple-700 hover:bg-purple-800 text-white text-xs font-bold rounded-xl transition-all cursor-pointer"
            >
              + Tambah Waka Kesiswaan
            </button>
            <button
              type="button"
              @click="openCreateModal('pj_lomba')"
              class="px-3 py-2 bg-amber-600 hover:bg-amber-700 text-white text-xs font-bold rounded-xl transition-all cursor-pointer"
            >
              + Tambah Guru PJ Lomba
            </button>
          </div>
        </div>

        <!-- Signers Grid / Cards -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
          <div
            v-for="signer in filteredSigners"
            :key="signer.id"
            class="bg-white rounded-xl border border-slate-200 p-4 hover:shadow-md transition-all flex flex-col justify-between space-y-4 relative group"
          >
            <!-- Card Header -->
            <div class="flex items-start gap-3">
              <!-- Signer Avatar / Icon -->
              <div class="w-12 h-12 rounded-xl bg-slate-100 text-brand-navy font-bold text-lg flex items-center justify-center shrink-0 border border-slate-200 shadow-xs">
                {{ signer.name.charAt(0) }}
              </div>
              <div class="min-w-0 flex-1">
                <div class="flex items-center gap-1.5 flex-wrap mb-1">
                  <span :class="['px-2 py-0.5 rounded-md text-[10px] font-bold border', getRoleBadgeClass(signer.role_type)]">
                    {{ getRoleLabel(signer.role_type) }}
                  </span>
                  <span :class="['px-2 py-0.5 rounded-md text-[10px] font-bold', signer.is_active ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-500']">
                    {{ signer.is_active ? 'Aktif' : 'Nonaktif' }}
                  </span>
                </div>
                <h4 class="text-sm font-bold text-slate-900 leading-snug line-clamp-1">
                  {{ signer.name }}
                </h4>
                <p class="text-xs text-slate-500 font-medium truncate">
                  {{ signer.position_title }}
                </p>
                <p class="text-[11px] text-slate-400 mt-0.5">
                  {{ signer.nip ? 'NIP: ' + signer.nip : 'NIP: Tidak Dicantumkan' }}
                </p>
              </div>
            </div>

            <!-- QR Code Mini Thumbnail & Verification Link -->
            <div class="p-3 rounded-lg bg-slate-50 border border-slate-100 flex items-center justify-between">
              <div class="flex items-center gap-2.5">
                <div class="w-10 h-10 bg-white p-1 rounded border border-slate-200 shrink-0">
                  <img :src="signer.qr_code_data_uri" alt="QR Mini" class="w-full h-full object-contain" />
                </div>
                <div class="min-w-0">
                  <p class="text-[11px] font-bold text-slate-700">TTD QR Code Digital</p>
                  <p class="text-[10px] text-slate-500 truncate max-w-[130px]">Terverifikasi Sah</p>
                </div>
              </div>
              <button
                type="button"
                @click="openQrModal(signer)"
                class="px-2.5 py-1.5 bg-brand-navy hover:bg-[#00174c] text-white text-[11px] font-bold rounded-lg transition-all flex items-center gap-1 cursor-pointer shrink-0"
              >
                <i class="fa-solid fa-qrcode"></i>
                <span>Lihat QR</span>
              </button>
            </div>

            <!-- Card Action Footer -->
            <div class="pt-2 border-t border-slate-100 flex items-center justify-between gap-2 text-xs">
              <button
                type="button"
                @click="openEditModal(signer)"
                class="text-slate-600 hover:text-brand-navy font-semibold inline-flex items-center gap-1 cursor-pointer"
              >
                <i class="fa-solid fa-pen-to-square"></i>
                <span>Edit</span>
              </button>

              <button
                type="button"
                @click="handleDelete(signer)"
                class="text-rose-600 hover:text-rose-800 font-semibold inline-flex items-center gap-1 cursor-pointer"
              >
                <i class="fa-solid fa-trash-can"></i>
                <span>Hapus</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Form (Tambah / Edit Guru TTD) -->
    <Modal
      v-model="showFormModal"
      :title="isEditing ? 'Edit Data Guru Penandatangan' : 'Tambah Guru Penandatangan Baru'"
      subtitle="Kelola profil guru pengesah, jabatan kedinasan, dan keabsahan TTD berbasis QR Code"
      size="lg"
      @close="showFormModal = false"
    >
      <form @submit.prevent="handleSave" id="signerForm" class="space-y-4 text-xs">
        <!-- Foto Formal Guru -->
        <div class="flex items-center gap-4 p-3.5 bg-slate-50 rounded-xl border border-slate-200">
          <div class="w-16 h-20 bg-slate-200 rounded-lg overflow-hidden shrink-0 border border-slate-300 flex items-center justify-center text-slate-400 shadow-inner">
            <img v-if="photoPreviewUrl" :src="photoPreviewUrl" alt="Foto Preview" class="w-full h-full object-cover" />
            <i v-else class="fa-solid fa-user-tie text-2xl"></i>
          </div>
          <div class="flex-1 min-w-0">
            <label class="block text-xs font-bold text-slate-700 mb-1">Foto Formal Guru (Pas Foto)</label>
            <input
              type="file"
              accept="image/*"
              @change="handlePhotoChange"
              class="w-full text-xs text-slate-500 file:mr-2 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-bold file:bg-brand-navy file:text-white hover:file:bg-[#00174c] cursor-pointer"
            />
            <p class="text-[10px] text-slate-400 mt-1">Format: JPG, PNG. Maksimal 5MB.</p>
          </div>
        </div>

        <!-- Role Type Selection -->
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">
            Peran Pengesah / Role Dispen <span class="text-rose-500">*</span>
          </label>
          <select
            v-model="formData.role_type"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden bg-white font-medium"
          >
            <option v-for="opt in roleOptions" :key="opt.value" :value="opt.value">
              {{ opt.label }}
            </option>
          </select>
        </div>

        <!-- Nama Lengkap Guru -->
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">
            Nama Lengkap & Gelar <span class="text-rose-500">*</span>
          </label>
          <input
            v-model="formData.name"
            type="text"
            placeholder="Contoh: Drs. H. Abd. Haris"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            required
          />
        </div>

        <!-- Jabatan Kedinasan -->
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">
            Jabatan Resmi Kedinasan <span class="text-rose-500">*</span>
          </label>
          <input
            v-model="formData.position_title"
            type="text"
            placeholder="Contoh: Wakil Kepala Sekolah Bidang Kesiswaan"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            required
          />
        </div>

        <!-- TTL (Tempat & Tanggal Lahir) -->
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Tempat Lahir</label>
            <input
              v-model="formData.birth_place"
              type="text"
              placeholder="Contoh: Sumenep"
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Lahir</label>
            <input
              v-model="formData.birth_date"
              type="date"
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
        </div>

        <!-- Alamat Tempat Tinggal -->
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Alamat Tempat Tinggal</label>
          <textarea
            v-model="formData.address"
            rows="2"
            placeholder="Contoh: Jln. Abd. Rahman Saleh Gg. IV Jombang"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          ></textarea>
        </div>

        <!-- Riwayat Pendidikan -->
        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Riwayat Pendidikan</label>
          <textarea
            v-model="formData.education_history"
            rows="2"
            placeholder="Contoh: S1 Pendidikan Agama Islam - IAIN Sunan Ampel (1992), S2 Manajemen Pendidikan (2005)"
            class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          ></textarea>
        </div>

        <!-- Kontak No HP & Email -->
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">No. WhatsApp / HP</label>
            <input
              v-model="formData.phone"
              type="text"
              placeholder="08123456789"
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Email Guru</label>
            <input
              v-model="formData.email"
              type="email"
              placeholder="guru@sekolah.sch.id"
              class="w-full text-xs rounded-xl border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
            />
          </div>
        </div>

        <!-- Status Aktif Toggle -->
        <div class="pt-2 flex items-center justify-between">
          <span class="text-xs font-bold text-slate-700">Status Guru Penandatangan Aktif</span>
          <label class="relative inline-flex items-center cursor-pointer">
            <input type="checkbox" v-model="formData.is_active" class="sr-only peer" />
            <div class="w-11 h-6 bg-slate-200 peer-focus:outline-hidden rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-600"></div>
          </label>
        </div>
      </form>

      <template #footer>
        <button
          type="button"
          @click="showFormModal = false"
          class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl text-xs transition-all cursor-pointer"
        >
          Batal
        </button>
        <button
          type="button"
          @click="handleSave"
          :disabled="formLoading"
          class="px-5 py-2.5 bg-brand-navy hover:bg-[#00174c] text-white text-xs font-bold rounded-xl transition-all flex items-center gap-1.5 cursor-pointer shadow-xs disabled:opacity-50"
        >
          <i v-if="formLoading" class="fa-solid fa-circle-notch fa-spin"></i>
          <span>{{ isEditing ? 'Simpan Perubahan' : 'Tambah Signer' }}</span>
        </button>
      </template>
    </Modal>

    <!-- Modal QR Code Preview & Download -->
    <Modal
      v-model="showQrModal"
      title="QR Code TTD Digital Guru"
      subtitle="Pindai QR ini untuk mengecek keabsahan profil guru dan pengesahan surat"
      size="md"
      @close="showQrModal = false"
    >
      <div v-if="selectedSignerForQr" class="space-y-4 text-center text-xs">
        <div>
          <h4 class="text-base font-bold text-slate-900">
            {{ selectedSignerForQr.name }}
          </h4>
          <p class="text-xs text-brand-navy font-semibold mt-0.5">
            {{ selectedSignerForQr.position_title }}
          </p>
          <p class="text-[11px] text-slate-400">
            {{ selectedSignerForQr.nip ? 'NIP: ' + selectedSignerForQr.nip : 'Pengesah Resmi Sekolah' }}
          </p>
        </div>

        <!-- QR Code Display Box -->
        <div class="p-4 bg-slate-50 rounded-2xl border border-slate-200 inline-block shadow-inner">
          <img
            :src="selectedSignerForQr.qr_code_data_uri"
            alt="QR Code TTD"
            class="w-48 h-48 mx-auto object-contain"
          />
        </div>

        <p class="text-[11px] text-slate-500 max-w-xs mx-auto leading-relaxed">
          QR Code ini otomatis dicetak pada Surat Dispensasi KBM. Jika dipindai, akan menampilkan profil & status keabsahan guru ini.
        </p>

        <!-- Buttons -->
        <div class="space-y-2 pt-2">
          <div class="flex items-center gap-2">
            <button
              type="button"
              @click="downloadQrCode"
              class="flex-1 py-2.5 bg-brand-navy hover:bg-[#00174c] text-white text-xs font-bold rounded-xl transition-all flex items-center justify-center gap-2 cursor-pointer shadow-xs"
            >
              <i class="fa-solid fa-download"></i>
              <span>Unduh Gambar QR</span>
            </button>

            <button
              type="button"
              @click="copyVerificationLink"
              class="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold rounded-xl transition-all flex items-center justify-center gap-2 cursor-pointer border border-slate-200"
            >
              <i :class="copySuccess ? 'fa-solid fa-check text-emerald-600' : 'fa-solid fa-copy'"></i>
              <span>{{ copySuccess ? 'Tautan Tersalin!' : 'Salin Tautan QR' }}</span>
            </button>
          </div>

          <a
            :href="selectedSignerForQr.qr_code_url"
            target="_blank"
            class="block w-full py-2 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 text-xs font-bold rounded-xl transition-all border border-emerald-200 text-center font-semibold"
          >
            <i class="fa-solid fa-arrow-up-right-from-square mr-1"></i>
            <span>Uji Coba Pindai QR Code (Buka Halaman Profil)</span>
          </a>
        </div>
      </div>
    </Modal>
  </DashboardLayout>
</template>
