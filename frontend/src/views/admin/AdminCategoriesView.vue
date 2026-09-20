<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const categories = ref<any[]>([])
const loading = ref(true)
const showModal = ref(false)
const form = ref({
  name: '',
  description: '',
})
const saving = ref(false)

async function fetchCategories() {
  loading.value = true
  try {
    const res = await api.get('/admin/categories')
    categories.value = extractList(res.data.data)
  } catch (err) {
    console.error('Error loading categories:', err)
  } finally {
    loading.value = false
  }
}

async function handleSave() {
  saving.value = true
  try {
    await api.post('/admin/categories', form.value)
    showModal.value = false
    form.value = { name: '', description: '' }
    toast.success('Kategori kompetisi berhasil disimpan!', 'Data Tersimpan')
    fetchCategories()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menyimpan kategori.', 'Gagal Simpan')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchCategories()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Kategori Bidang Kompetisi</template>
    <template #header-subtitle>Kelola rumpun bidang kejuaraan (Sains, Teknologi, Seni & Bahasa, Olahraga, dsb).</template>

    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <p class="text-xs text-slate-500">Daftar rumpun kategori kompetisi resmi.</p>
        <button
          type="button"
          @click="showModal = true"
          class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Tambah Kategori</span>
        </button>
      </div>

      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Kategori</th>
                <th class="px-6 py-3.5">Slug</th>
                <th class="px-6 py-3.5">Deskripsi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="categories.length === 0">
                <td colspan="3" class="px-6 py-8 text-center text-slate-400">
                  Belum ada kategori.
                </td>
              </tr>
              <tr v-for="cat in categories" :key="cat.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4 font-bold text-slate-900 flex items-center gap-2">
                  <i class="fa-solid fa-tag text-brand-blue"></i>
                  <span>{{ cat.name }}</span>
                </td>
                <td class="px-6 py-4 font-mono text-[11px] text-slate-500">{{ cat.slug }}</td>
                <td class="px-6 py-4 text-slate-600">{{ cat.description || '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <Modal v-model="showModal" title="Tambah Kategori Lomba" size="md">
        <form @submit.prevent="handleSave" class="space-y-4 text-xs">
          <div>
            <label class="block font-semibold text-slate-700 mb-1">Nama Kategori *</label>
            <input
              v-model="form.name"
              type="text"
              required
              placeholder="Contoh: Sains & Matematika"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Deskripsi Kategori</label>
            <textarea
              v-model="form.description"
              rows="3"
              placeholder="Rincian cakupan lomba dalam kategori ini..."
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs"
            >
              Simpan
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
