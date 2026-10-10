<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast, confirm } = useNotify()

interface HeroSlide {
  id: number
  title: string
  student_name?: string
  caption?: string
  image_path: string
  image_url: string
  order: number
  is_active: boolean
  created_at?: string
}

const sliders = ref<HeroSlide[]>([])
const loading = ref(true)

// Modal State
const showModal = ref(false)
const editingId = ref<number | null>(null)
const submitting = ref(false)

const form = ref({
  title: '',
  student_name: '',
  caption: '',
  image_path: '',
  order: 0,
  is_active: true,
})

const selectedFile = ref<File | null>(null)
const filePreviewUrl = ref<string | null>(null)

async function fetchSliders() {
  loading.value = true
  try {
    const res = await api.get('/admin/hero-sliders')
    sliders.value = extractList(res.data.data)
  } catch (err: any) {
    console.error('Error fetching hero sliders:', err)
  } finally {
    loading.value = false
  }
}

function openAddModal() {
  editingId.value = null
  form.value = {
    title: '',
    student_name: '',
    caption: '',
    image_path: '',
    order: (sliders.value.length + 1),
    is_active: true,
  }
  selectedFile.value = null
  filePreviewUrl.value = null
  showModal.value = true
}

function openEditModal(slide: HeroSlide) {
  editingId.value = slide.id
  form.value = {
    title: slide.title,
    student_name: slide.student_name || '',
    caption: slide.caption || '',
    image_path: slide.image_path || '',
    order: slide.order || 0,
    is_active: slide.is_active,
  }
  selectedFile.value = null
  filePreviewUrl.value = slide.image_url
  showModal.value = true
}

function handleFileChange(e: any) {
  const file = e.target.files?.[0]
  if (file) {
    selectedFile.value = file
    filePreviewUrl.value = URL.createObjectURL(file)
  }
}

async function handleSubmit() {
  if (!form.value.title.trim()) {
    toast.error('Judul prestasi / foto wajib diisi.', 'Form tidak valid')
    return
  }

  submitting.value = true
  try {
    const formData = new FormData()
    formData.append('title', form.value.title)
    if (form.value.student_name) formData.append('student_name', form.value.student_name)
    if (form.value.caption) formData.append('caption', form.value.caption)
    formData.append('order', String(form.value.order))
    formData.append('is_active', form.value.is_active ? '1' : '0')

    if (selectedFile.value) {
      formData.append('image_file', selectedFile.value)
    } else if (form.value.image_path) {
      formData.append('image_path', form.value.image_path)
    }

    if (editingId.value) {
      await api.post(`/admin/hero-sliders/${editingId.value}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      toast.success('Foto juara hero berhasil diperbarui!', 'Berhasil Simpan')
    } else {
      await api.post('/admin/hero-sliders', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      toast.success('Foto juara hero baru berhasil ditambahkan!', 'Berhasil Tambah')
    }

    showModal.value = false
    fetchSliders()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menyimpan data foto hero slider.', 'Gagal Simpan')
  } finally {
    submitting.value = false
  }
}

async function toggleActive(slide: HeroSlide) {
  try {
    await api.patch(`/admin/hero-sliders/${slide.id}/toggle-active`)
    slide.is_active = !slide.is_active
    toast.info(`Status foto "${slide.title}" telah diubah.`, 'Status Diperbarui')
  } catch (err: any) {
    toast.error('Gagal mengubah status aktif foto.', 'Gagal')
  }
}

async function handleDelete(slide: HeroSlide) {
  const ok = await confirm({
    title: 'Hapus Foto Juara Hero',
    message: `Apakah Anda yakin ingin menghapus foto "${slide.title}" dari slider halaman depan?`,
    type: 'danger',
    confirmText: 'Ya, Hapus Foto',
  })
  if (!ok) return

  try {
    await api.delete(`/admin/hero-sliders/${slide.id}`)
    toast.success('Foto hero slider berhasil dihapus.', 'Terhapus')
    fetchSliders()
  } catch (err: any) {
    toast.error('Gagal menghapus foto hero slider.', 'Gagal Hapus')
  }
}

onMounted(() => {
  fetchSliders()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Kelola Slide Foto Juara Hero</template>
    <template #header-subtitle>Pengaturan foto-foto siswa berprestasi yang tampil pada slide halaman awal portal.</template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Top Action Bar -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <h2 class="text-xl font-extrabold text-brand-navy tracking-tight flex items-center gap-2">
            <i class="fa-solid fa-images text-brand-gold"></i>
            <span>Banner Foto Juara Halaman Depan</span>
          </h2>
          <p class="text-xs text-slate-500 mt-1">
            Foto yang diaktifkan di sini akan tampil sebagai slide carousel pada halaman awal MA Unggulan K.H. Abd. Wahab Hasbulloh.
          </p>
        </div>

        <button
          type="button"
          @click="openAddModal"
          class="px-4 py-2.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2 cursor-pointer shrink-0"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Tambah Foto Juara Baru</span>
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="py-12 text-center text-slate-400 text-xs">
        <i class="fa-solid fa-spinner fa-spin text-2xl mb-2 block"></i>
        Memuat daftar foto slider hero...
      </div>

      <!-- Sliders Cards Grid -->
      <div v-else-if="sliders.length === 0" class="bg-white rounded-3xl p-12 text-center border border-slate-200 text-slate-400 text-xs">
        <i class="fa-solid fa-images text-4xl mb-3 text-slate-300 block"></i>
        Belum ada foto juara yang ditambahkan. Klik tombol "+ Tambah Foto Juara Baru" di atas.
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="slide in sliders"
          :key="slide.id"
          class="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden flex flex-col justify-between group hover:shadow-md transition-all"
        >
          <div>
            <!-- Image Header Container -->
            <div class="relative aspect-16/9 bg-slate-100 overflow-hidden">
              <img :src="slide.image_url" :alt="slide.title" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
              <div class="absolute top-3 left-3 flex items-center gap-2">
                <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-black/60 backdrop-blur-xs text-white">
                  Urutan: {{ slide.order }}
                </span>
                <span
                  :class="[
                    'px-2.5 py-1 rounded-full text-[10px] font-bold border backdrop-blur-xs',
                    slide.is_active ? 'bg-emerald-500/90 text-white border-emerald-400' : 'bg-slate-700/90 text-slate-200 border-slate-600'
                  ]"
                >
                  {{ slide.is_active ? 'Aktif' : 'Non-Aktif' }}
                </span>
              </div>
            </div>

            <!-- Content Card -->
            <div class="p-5 space-y-2">
              <h3 class="text-sm font-extrabold text-slate-900 leading-snug">
                {{ slide.title }}
              </h3>
              <p v-if="slide.student_name" class="text-xs font-bold text-brand-navy flex items-center gap-1.5">
                <i class="fa-solid fa-user-graduate text-brand-gold"></i>
                <span>{{ slide.student_name }}</span>
              </p>
              <p v-if="slide.caption" class="text-[11px] text-slate-500 leading-relaxed">
                {{ slide.caption }}
              </p>
            </div>
          </div>

          <!-- Bottom Actions -->
          <div class="p-4 bg-slate-50/70 border-t border-slate-100 flex items-center justify-between">
            <button
              type="button"
              @click="toggleActive(slide)"
              :class="[
                'px-3 py-1.5 rounded-lg text-xs font-bold transition-colors cursor-pointer',
                slide.is_active ? 'bg-amber-100 text-amber-800 hover:bg-amber-200' : 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
              ]"
            >
              <i :class="['fa-solid mr-1', slide.is_active ? 'fa-eye-slash' : 'fa-eye']"></i>
              <span>{{ slide.is_active ? 'Sembunyikan' : 'Tampilkan' }}</span>
            </button>

            <div class="flex items-center gap-2">
              <button
                type="button"
                @click="openEditModal(slide)"
                class="px-3 py-1.5 bg-brand-blue text-white rounded-lg text-xs font-bold hover:bg-[#0d4f87] transition-colors cursor-pointer"
                title="Edit data slider"
              >
                <i class="fa-solid fa-pen-to-square"></i>
              </button>
              <button
                type="button"
                @click="handleDelete(slide)"
                class="px-3 py-1.5 bg-rose-50 text-rose-600 hover:bg-rose-100 rounded-lg text-xs font-bold transition-colors cursor-pointer"
                title="Hapus slider"
              >
                <i class="fa-solid fa-trash-can"></i>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Add/Edit Modal -->
      <Modal v-model="showModal" :title="editingId ? 'Edit Foto Juara Hero' : 'Tambah Foto Juara Hero Baru'" size="lg">
        <form @submit.prevent="handleSubmit" class="space-y-4 text-xs">
          <div>
            <label class="block font-semibold text-slate-700 mb-1">Judul Prestasi / Kejuaraan *</label>
            <input
              v-model="form.title"
              type="text"
              required
              placeholder="Contoh: Juara 1 KSN Matematika & Sains 2026"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
            />
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Nama Siswa / Tim Juara</label>
              <input
                v-model="form.student_name"
                type="text"
                placeholder="Contoh: Achmad Azam Maulana Ibrahim"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Urutan Tampil (Order)</label>
              <input
                v-model.number="form.order"
                type="number"
                min="0"
                placeholder="0"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
              />
            </div>
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Keterangan Tambahan / Caption</label>
            <input
              v-model="form.caption"
              type="text"
              placeholder="Contoh: Medali Emas & Sertifikat Puspresnas Riset Kesiswaan"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
            />
          </div>

          <!-- File Upload or Path -->
          <div class="space-y-2">
            <label class="block font-semibold text-slate-700">Foto Juara / Banner *</label>

            <div v-if="filePreviewUrl" class="relative rounded-2xl overflow-hidden aspect-16/9 bg-slate-100 border border-slate-200">
              <img :src="filePreviewUrl" alt="Preview Foto" class="w-full h-full object-cover" />
              <button
                type="button"
                @click="selectedFile = null; filePreviewUrl = null; form.image_path = ''"
                class="absolute top-2 right-2 p-1.5 bg-rose-600 text-white rounded-lg hover:bg-rose-700 transition-colors cursor-pointer"
                title="Ganti Foto"
              >
                <i class="fa-solid fa-xmark text-sm"></i>
              </button>
            </div>

            <label
              v-else
              class="flex flex-col items-center justify-center p-6 border-2 border-dashed border-slate-300 rounded-2xl bg-slate-50 hover:bg-blue-50/50 hover:border-brand-blue/50 cursor-pointer transition-colors text-center"
            >
              <i class="fa-solid fa-cloud-arrow-up text-3xl text-slate-400 mb-2"></i>
              <span class="font-bold text-slate-700 text-xs">Upload Foto Juara (JPG, PNG, WEBP)</span>
              <span class="text-[10px] text-slate-400 mt-1">Maksimal 5 MB • Rasio 16:9 disarankan</span>
              <input
                type="file"
                accept="image/*"
                @change="handleFileChange"
                class="hidden"
              />
            </label>
          </div>

          <!-- Status Toggle -->
          <div class="pt-2">
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                v-model="form.is_active"
                class="rounded-md border-slate-300 text-brand-blue focus:ring-brand-blue"
              />
              <span class="text-xs font-semibold text-slate-700">Aktifkan foto pada slide carousel halaman depan</span>
            </label>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl cursor-pointer"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="submitting"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs cursor-pointer flex items-center gap-1.5"
            >
              <i v-if="submitting" class="fa-solid fa-spinner fa-spin"></i>
              <span>Simpan Foto Slider</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
