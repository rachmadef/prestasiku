<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const competitions = ref<any[]>([])
const categories = ref<any[]>([])
const organizers = ref<any[]>([])
const loading = ref(true)

// Create Competition Modal
const showCreateModal = ref(false)
const createForm = ref({
  name: '',
  category_id: '',
  organizer_id: '',
  educational_level: 'slta',
  scope: 'nasional',
  participation_type: 'individual',
  description: '',
  official_url: '',
  registration_open_at: '',
  registration_deadline: '',
  event_start_at: '',
  event_end_at: '',
})
const creatingComp = ref(false)

// Verify Modal
const showVerifyModal = ref(false)
const selectedComp = ref<any>(null)
const verifyStatus = ref('published')
const verifyNotes = ref('Sumber resmi panduan lomba telah divalidasi sah oleh Super Admin.')
const submittingVerify = ref(false)

async function fetchCompetitions() {
  loading.value = true
  try {
    const [compsRes, catsRes, orgsRes] = await Promise.all([
      api.get('/admin/competitions'),
      api.get('/admin/categories').catch(() => ({ data: { data: [] } })),
      api.get('/admin/organizers').catch(() => ({ data: { data: [] } })),
    ])
    competitions.value = extractList(compsRes.data.data)
    categories.value = extractList(catsRes.data.data)
    organizers.value = extractList(orgsRes.data.data)
  } catch (err) {
    console.error('Error fetching admin competitions:', err)
  } finally {
    loading.value = false
  }
}

async function handleCreateCompetition() {
  creatingComp.value = true
  try {
    await api.post('/admin/competitions', createForm.value)
    showCreateModal.value = false
    toast.success('Kompetisi baru berhasil ditambahkan!', 'Kompetisi Dibuat')
    fetchCompetitions()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal membuat kompetisi.', 'Gagal Membuat')
  } finally {
    creatingComp.value = false
  }
}

function openVerifyModal(comp: any) {
  selectedComp.value = comp
  verifyStatus.value = 'published'
  showVerifyModal.value = true
}

async function submitVerify() {
  if (!selectedComp.value) return
  submittingVerify.value = true
  try {
    await api.post(`/admin/competitions/${selectedComp.value.id}/verify`, {
      verification_status: verifyStatus.value,
      verification_notes: verifyNotes.value,
    })
    showVerifyModal.value = false
    toast.success(
      verifyStatus.value === 'published' ? 'Kompetisi resmi diterbitkan ke katalog publik!' : 'Status verifikasi kompetisi diperbarui.',
      'Verifikasi Selesai'
    )
    fetchCompetitions()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memverifikasi kompetisi.', 'Gagal Verifikasi')
  } finally {
    submittingVerify.value = false
  }
}

onMounted(() => {
  fetchCompetitions()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Manajemen & Verifikasi Kompetisi</template>
    <template #header-subtitle>Kelola alur verifikasi sumber, publikasi lomba, dan formulir dinamis.</template>

    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <p class="text-xs text-slate-500">Daftar seluruh database kompetisi dalam sistem PrestasiKu.</p>
        <button
          type="button"
          @click="showCreateModal = true"
          class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Tambah Kompetisi Baru</span>
        </button>
      </div>

      <!-- Competitions Table -->
      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Kompetisi</th>
                <th class="px-6 py-3.5">Penyelenggara & Kategori</th>
                <th class="px-6 py-3.5">Jenjang / Lingkup</th>
                <th class="px-6 py-3.5">Deadline</th>
                <th class="px-6 py-3.5">Status Verifikasi</th>
                <th class="px-6 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="competitions.length === 0">
                <td colspan="6" class="px-6 py-8 text-center text-slate-400">
                  Belum ada data kompetisi.
                </td>
              </tr>
              <tr v-for="comp in competitions" :key="comp.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900 line-clamp-1">{{ comp.name }}</div>
                  <div v-if="comp.official_url" class="text-[10px] text-brand-blue truncate max-w-xs">
                    <a :href="comp.official_url" target="_blank" class="hover:underline">
                      {{ comp.official_url }}
                    </a>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <div class="font-medium text-slate-800">{{ comp.organizer?.name || '-' }}</div>
                  <div class="text-[11px] text-slate-400">{{ comp.category?.name || '-' }}</div>
                </td>
                <td class="px-6 py-4">
                  <span class="font-semibold uppercase text-slate-700">{{ comp.educational_level }}</span>
                  <span class="text-[11px] text-slate-400 block capitalize">{{ comp.scope }}</span>
                </td>
                <td class="px-6 py-4 font-mono text-[11px] text-slate-600">
                  {{ comp.registration_deadline ? comp.registration_deadline.split('T')[0] : '-' }}
                </td>
                <td class="px-6 py-4">
                  <Badge :status="comp.verification_status" />
                </td>
                <td class="px-6 py-4 text-right space-x-2">
                  <button
                    type="button"
                    @click="openVerifyModal(comp)"
                    class="px-3 py-1.5 bg-brand-blue hover:bg-[#0d4f88] text-white rounded-lg text-xs font-semibold shadow-2xs"
                  >
                    <i class="fa-solid fa-shield-halved mr-1"></i> Verifikasi
                  </button>
                  <router-link
                    :to="`/competitions/${comp.slug || comp.id}`"
                    target="_blank"
                    class="px-2.5 py-1.5 text-slate-500 hover:text-brand-navy hover:bg-slate-100 rounded-lg text-xs font-semibold"
                    title="Pratinjau Publik"
                  >
                    <i class="fa-solid fa-arrow-up-right-from-square"></i>
                  </router-link>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Create Modal -->
      <Modal
        v-model="showCreateModal"
        title="Buat Kompetisi Baru"
        subtitle="Tambahkan data lomba resmi ke dalam sistem PrestasiKu"
        size="lg"
      >
        <form @submit.prevent="handleCreateCompetition" class="space-y-4">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Nama Kompetisi *</label>
              <input
                v-model="createForm.name"
                type="text"
                required
                placeholder="Contoh: Olimpiade Sains Siswa Nasional 2026"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Kategori *</label>
              <select
                v-model="createForm.category_id"
                required
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="">Pilih Kategori</option>
                <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Penyelenggara *</label>
              <select
                v-model="createForm.organizer_id"
                required
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="">Pilih Penyelenggara</option>
                <option v-for="o in organizers" :key="o.id" :value="o.id">{{ o.name }}</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Jenjang Pendidikan *</label>
              <select
                v-model="createForm.educational_level"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="slta">SLTA / SMA / SMK / MA</option>
                <option value="sltp">SLTP / SMP / MTs</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tingkat Wilayah *</label>
              <select
                v-model="createForm.scope"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              >
                <option value="nasional">Nasional</option>
                <option value="provinsi">Provinsi</option>
              </select>
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tanggal Buka Pendaftaran</label>
              <input
                v-model="createForm.registration_open_at"
                type="date"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1">Batas Akhir Pendaftaran</label>
              <input
                v-model="createForm.registration_deadline"
                type="date"
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Tautan Resmi (Official URL)</label>
              <input
                v-model="createForm.official_url"
                type="url"
                placeholder="https://..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              />
            </div>

            <div class="sm:col-span-2">
              <label class="block font-semibold text-slate-700 mb-1">Deskripsi Lengkap</label>
              <textarea
                v-model="createForm.description"
                rows="3"
                placeholder="Penjelasan rincian kompetisi..."
                class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
              ></textarea>
            </div>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showCreateModal = false"
              class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="creatingComp"
              class="px-5 py-2 text-xs font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs transition-all flex items-center gap-1.5"
            >
              <i v-if="creatingComp" class="fa-solid fa-spinner fa-spin"></i>
              <span>Simpan Kompetisi</span>
            </button>
          </div>
        </form>
      </Modal>

      <!-- Verify Modal -->
      <Modal
        v-model="showVerifyModal"
        title="Verifikasi Pipeline Kompetisi"
        :subtitle="selectedComp?.name"
        size="md"
      >
        <form @submit.prevent="submitVerify" class="space-y-4">
          <div class="text-xs">
            <label class="block font-semibold text-slate-700 mb-1">Tentukan Status Verifikasi *</label>
            <select
              v-model="verifyStatus"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-medium"
            >
              <option value="published">Resmi & Dipublikasikan (Tampil di Katalog)</option>
              <option value="verified_source">Sumber Terverifikasi (Belum Terbit)</option>
              <option value="in_review">Menunggu Verifikasi Sumber</option>
              <option value="draft">Kembalikan ke Draft</option>
              <option value="rejected">Tolak Kompetisi (Tidak Memenuhi Standar)</option>
            </select>
          </div>

          <div class="text-xs">
            <label class="block font-semibold text-slate-700 mb-1">Catatan Verifikator *</label>
            <textarea
              v-model="verifyNotes"
              rows="3"
              required
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showVerifyModal = false"
              class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="submittingVerify"
              class="px-5 py-2 text-xs font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs transition-all flex items-center gap-1.5"
            >
              <i v-if="submittingVerify" class="fa-solid fa-spinner fa-spin"></i>
              <span>Simpan Status</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
