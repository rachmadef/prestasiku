<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const organizers = ref<any[]>([])
const loading = ref(true)
const showModal = ref(false)
const form = ref({
  name: '',
  type: 'instansi_pemerintah',
  website: '',
  contact_email: '',
  contact_phone: '',
  verification_status: 'verified',
})
const saving = ref(false)

async function fetchOrganizers() {
  loading.value = true
  try {
    const res = await api.get('/admin/organizers')
    organizers.value = extractList(res.data.data)
  } catch (err) {
    console.error('Error loading organizers:', err)
  } finally {
    loading.value = false
  }
}

async function handleSave() {
  saving.value = true
  try {
    await api.post('/admin/organizers', form.value)
    showModal.value = false
    form.value = {
      name: '',
      type: 'instansi_pemerintah',
      website: '',
      contact_email: '',
      contact_phone: '',
      verification_status: 'verified',
    }
    toast.success('Penyelenggara lomba berhasil disimpan!', 'Data Tersimpan')
    fetchOrganizers()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal menyimpan penyelenggara.', 'Gagal Simpan')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchOrganizers()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Penyelenggara Kompetisi (Organizers)</template>
    <template #header-subtitle>Kelola direktori lembaga, yayasan, kementerian, dan instansi penyelenggara lomba.</template>

    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <p class="text-xs text-slate-500">Daftar penyelenggara terdaftar dan status verifikasinya.</p>
        <button
          type="button"
          @click="showModal = true"
          class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Tambah Penyelenggara</span>
        </button>
      </div>

      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Lembaga</th>
                <th class="px-6 py-3.5">Jenis Organisasi</th>
                <th class="px-6 py-3.5">Kontak & Website</th>
                <th class="px-6 py-3.5">Status Verifikasi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="organizers.length === 0">
                <td colspan="4" class="px-6 py-8 text-center text-slate-400">
                  Belum ada data penyelenggara.
                </td>
              </tr>
              <tr v-for="org in organizers" :key="org.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ org.name }}</div>
                </td>
                <td class="px-6 py-4 capitalize font-medium text-slate-700">
                  {{ org.type?.replace('_', ' ') || '-' }}
                </td>
                <td class="px-6 py-4">
                  <div>{{ org.contact_email || '-' }} • {{ org.contact_phone || '-' }}</div>
                  <div v-if="org.website" class="text-[10px] text-brand-blue">
                    <a :href="org.website" target="_blank" class="hover:underline">{{ org.website }}</a>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <Badge :status="org.verification_status || 'verified'" />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <Modal v-model="showModal" title="Tambah Penyelenggara Lomba" size="md">
        <form @submit.prevent="handleSave" class="space-y-4 text-xs">
          <div>
            <label class="block font-semibold text-slate-700 mb-1">Nama Lembaga / Penyelenggara *</label>
            <input
              v-model="form.name"
              type="text"
              required
              placeholder="Contoh: Pusat Prestasi Nasional (Puspresnas)"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Tipe Organisasi *</label>
            <select
              v-model="form.type"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            >
              <option value="instansi_pemerintah">Instansi Pemerintah / Kementerian</option>
              <option value="perguruan_tinggi">Perguruan Tinggi / Universitas</option>
              <option value="organisasi_profesi">Organisasi Profesi / Ilmiah</option>
              <option value="yayasan">Yayasan / Komunitas</option>
            </select>
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Website Resmi</label>
            <input
              v-model="form.website"
              type="url"
              placeholder="https://..."
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Email Kontak</label>
              <input
                v-model="form.contact_email"
                type="email"
                placeholder="info@..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Telepon / WhatsApp</label>
              <input
                v-model="form.contact_phone"
                type="text"
                placeholder="021-..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>
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
