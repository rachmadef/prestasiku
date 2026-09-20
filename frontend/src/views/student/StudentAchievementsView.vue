<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const achievements = ref<any[]>([])
const loading = ref(true)

// Add Achievement Modal
const showAddModal = ref(false)
const addForm = ref({
  competition_name_manual: '',
  achievement_level: 'nasional',
  rank: 'Juara 1',
  field_name: '',
  event_date: '',
})
const adding = ref(false)

// QR Preview Modal
const showQrModal = ref(false)
const selectedAch = ref<any>(null)

async function fetchAchievements() {
  loading.value = true
  try {
    const res = await api.get('/student/achievements')
    achievements.value = extractList(res.data.data)
  } catch (err) {
    console.error('Error fetching student achievements:', err)
  } finally {
    loading.value = false
  }
}

async function handleAddAchievement() {
  adding.value = true
  try {
    await api.post('/student/achievements', addForm.value)
    showAddModal.value = false
    addForm.value = {
      competition_name_manual: '',
      achievement_level: 'nasional',
      rank: 'Juara 1',
      field_name: '',
      event_date: '',
    }
    toast.success('Pengajuan prestasi berhasil dikirimkan ke sekolah!', 'Pengajuan Berhasil')
    fetchAchievements()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengajukan prestasi.', 'Gagal Pengajuan')
  } finally {
    adding.value = false
  }
}

async function togglePrivacy(ach: any) {
  try {
    const res = await api.patch(`/student/achievements/${ach.id}/toggle-public`)
    ach.is_public = res.data.data.is_public
    toast.info(
      ach.is_public ? 'Prestasi kini dapat diakses melalui portal publik ber-QR.' : 'Prestasi diubah menjadi privat (hanya sekolah & Anda).',
      'Status Visibilitas'
    )
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengubah visibilitas publik.', 'Gagal Ubah')
  }
}

function openQrModal(ach: any) {
  selectedAch.value = ach
  showQrModal.value = true
}

onMounted(() => {
  fetchAchievements()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Portofolio Prestasi & Sertifikat QR</template>
    <template #header-subtitle>Koleksi penghargaan kejuaraan resmi yang telah diverifikasi sekolah.</template>

    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <p class="text-xs text-slate-500">Daftar capaian prestasi dan kontrol privasi publik (opt-in).</p>
        <button
          type="button"
          @click="showAddModal = true"
          class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2"
        >
          <i class="fa-solid fa-plus text-brand-gold"></i>
          <span>Ajukan Prestasi Mandiri</span>
        </button>
      </div>

      <!-- Privacy Info Banner -->
      <div class="p-4 rounded-2xl bg-blue-50/70 border border-blue-200/70 text-xs text-brand-blue flex items-center gap-3">
        <i class="fa-solid fa-user-shield text-lg text-brand-blue shrink-0"></i>
        <div>
          <span class="font-bold">Prinsip Privacy-by-Default:</span>
          <span class="text-slate-600 ml-1">
            Data prestasi Anda bersifat privat secara bawaan. Anda dapat mengaktifkan toggle "Publik" jika ingin sertifikat ini dapat divalidasi oleh kampus, beasiswa, atau umum melalui QR Code.
          </span>
        </div>
      </div>

      <!-- Achievements Grid -->
      <div v-if="achievements.length === 0" class="bg-white rounded-3xl p-12 text-center border border-slate-200 text-slate-400 text-xs">
        <i class="fa-solid fa-award text-4xl mb-3 text-slate-300 block"></i>
        Belum ada rekam prestasi. Silakan ajukan prestasi yang pernah Anda raih!
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div
          v-for="ach in achievements"
          :key="ach.id"
          class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-2xs flex flex-col justify-between"
        >
          <div>
            <div class="flex items-center justify-between gap-2 mb-3">
              <span class="text-[11px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-md capitalize">
                {{ ach.achievement_level }} • {{ ach.field_name || 'Umum' }}
              </span>
              <Badge :status="ach.verification_status || 'verified'" />
            </div>

            <h3 class="text-base font-extrabold text-slate-900 leading-snug">
              {{ ach.competition?.name || ach.competition_name_manual }}
            </h3>

            <p class="text-sm font-bold text-amber-700 mt-2 flex items-center gap-1.5">
              <i class="fa-solid fa-trophy text-brand-gold"></i>
              <span>{{ ach.rank }}</span>
            </p>

            <div v-if="ach.public_id" class="mt-4 p-3 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-between">
              <div>
                <p class="text-[10px] uppercase font-bold text-slate-400">Public ID Verifikasi</p>
                <p class="text-xs font-mono font-bold text-brand-navy">{{ ach.public_id }}</p>
              </div>
              <button
                type="button"
                @click="openQrModal(ach)"
                class="px-3 py-1.5 bg-brand-navy text-white text-xs font-bold rounded-lg hover:bg-[#001442] shadow-2xs"
              >
                <i class="fa-solid fa-qrcode mr-1"></i> QR
              </button>
            </div>
          </div>

          <!-- Bottom Privacy & Link -->
          <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs">
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                :checked="ach.is_public"
                @change="togglePrivacy(ach)"
                class="rounded-md border-slate-300 text-brand-blue focus:ring-brand-blue"
              />
              <span class="text-slate-700 font-semibold">Tampilkan di Publik</span>
            </label>

            <router-link
              v-if="ach.public_id"
              :to="`/verify/${ach.public_id}`"
              target="_blank"
              class="text-brand-blue hover:underline font-semibold flex items-center gap-1"
            >
              <span>Halaman Publik</span>
              <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Add Achievement Modal -->
      <Modal v-model="showAddModal" title="Pengajuan Prestasi Mandiri" size="md">
        <form @submit.prevent="handleAddAchievement" class="space-y-4 text-xs">
          <div>
            <label class="block font-semibold text-slate-700 mb-1">Nama Kompetisi / Kejuaraan *</label>
            <input
              v-model="addForm.competition_name_manual"
              type="text"
              required
              placeholder="Contoh: Lomba Karya Tulis Ilmiah Remaja Nasional"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Peringkat / Juara yang Diraih *</label>
            <input
              v-model="addForm.rank"
              type="text"
              required
              placeholder="Contoh: Juara 2 / Medali Perak"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block font-semibold text-slate-700 mb-1">Tingkat Wilayah *</label>
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
              <label class="block font-semibold text-slate-700 mb-1">Bidang Lomba</label>
              <input
                v-model="addForm.field_name"
                type="text"
                placeholder="Contoh: Sains & Riset"
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
              <span>Ajukan untuk Verifikasi</span>
            </button>
          </div>
        </form>
      </Modal>

      <!-- QR Code Modal -->
      <Modal v-model="showQrModal" title="Sertifikat Verifikasi QR" :subtitle="selectedAch?.public_id" size="sm">
        <div class="text-center py-4 space-y-4">
          <div class="w-48 h-48 bg-slate-50 rounded-2xl border border-slate-200 mx-auto p-3 flex items-center justify-center">
            <img
              :src="`/api/v1/verify/${selectedAch?.public_id}/qr`"
              alt="QR Code"
              class="w-full h-full object-contain"
              @error="(e: any) => e.target.style.display = 'none'"
            />
          </div>
          <div>
            <p class="text-xs font-bold text-slate-800">{{ selectedAch?.rank }}</p>
            <p class="text-[11px] text-slate-500">{{ selectedAch?.competition?.name || selectedAch?.competition_name_manual }}</p>
          </div>
          <div class="pt-2">
            <router-link
              :to="`/verify/${selectedAch?.public_id}`"
              target="_blank"
              class="inline-flex items-center gap-1.5 px-4 py-2 bg-brand-navy text-white text-xs font-bold rounded-xl shadow-xs"
            >
              <span>Buka Halaman Verifikasi Sah</span>
              <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
            </router-link>
          </div>
        </div>
      </Modal>
    </div>
  </DashboardLayout>
</template>
