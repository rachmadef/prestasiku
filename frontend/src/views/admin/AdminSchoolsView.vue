<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast, confirm } = useNotify()

const activeTab = ref<'registrations' | 'schools'>('registrations')
const registrations = ref<any[]>([])
const schools = ref<any[]>([])
const loading = ref(true)

// Review Modal State
const showReviewModal = ref(false)
const selectedRegistration = ref<any>(null)
const reviewAction = ref<'approve' | 'reject'>('approve')
const reviewNotes = ref('')
const submittingReview = ref(false)
const reviewMessage = ref<string | null>(null)

async function fetchData() {
  loading.value = true
  try {
    const [regsRes, schoolsRes] = await Promise.all([
      api.get('/admin/school-registrations'),
      api.get('/admin/schools'),
    ])
    registrations.value = extractList(regsRes.data.data)
    schools.value = extractList(schoolsRes.data.data)
  } catch (err) {
    console.error('Error loading school data:', err)
  } finally {
    loading.value = false
  }
}

const adminPassword = ref('')
const approvedAccount = ref<{ username: string; email: string; temporary_password: string } | null>(null)
const copied = ref(false)

function openReviewModal(reg: any, action: 'approve' | 'reject') {
  selectedRegistration.value = reg
  reviewAction.value = action
  adminPassword.value = ''
  approvedAccount.value = null
  copied.value = false
  reviewNotes.value = action === 'approve'
    ? 'NPSN dan identitas instansi telah divalidasi sah.'
    : 'Dokumen dan validitas NPSN tidak dapat diverifikasi.'
  reviewMessage.value = null
  showReviewModal.value = true
}

async function submitReview() {
  if (!selectedRegistration.value) return
  submittingReview.value = true
  reviewMessage.value = null

  try {
    const payload: any = {
      action: reviewAction.value,
      notes: reviewNotes.value,
    }
    if (reviewAction.value === 'approve' && adminPassword.value.trim()) {
      payload.admin_password = adminPassword.value.trim()
    }

    const response = await api.post(`/admin/school-registrations/${selectedRegistration.value.id}/review`, payload)
    
    if (response.data.data?.admin_account) {
      approvedAccount.value = response.data.data.admin_account
      reviewMessage.value = response.data.message
      fetchData()
    } else {
      reviewMessage.value = response.data.message || 'Berhasil memproses pengajuan sekolah.'
      setTimeout(() => {
        showReviewModal.value = false
        fetchData()
      }, 1200)
    }
  } catch (err: any) {
    reviewMessage.value = err.response?.data?.message || 'Gagal memproses peninjauan.'
  } finally {
    submittingReview.value = false
  }
}

function copyCredentials() {
  if (!approvedAccount.value) return
  const text = `Kredensial Admin Sekolah Prestasiku:\nUsername: ${approvedAccount.value.username}\nEmail: ${approvedAccount.value.email}\nPassword: ${approvedAccount.value.temporary_password}\nLogin: http://localhost:5173/login`
  navigator.clipboard.writeText(text)
  copied.value = true
  setTimeout(() => (copied.value = false), 2000)
}

async function toggleSchoolStatus(school: any) {
  const newStatus = school.status === 'suspended' ? 'verified' : 'suspended'
  const isSuspending = newStatus === 'suspended'

  const ok = await confirm({
    title: isSuspending ? 'Tangguhkan Tenant Sekolah' : 'Aktifkan Kembali Sekolah',
    message: isSuspending
      ? `Apakah Anda yakin ingin menangguhkan akses sekolah ${school.name}? Seluruh akun admin dan siswa di sekolah ini tidak dapat mengakses fitur internal sementara waktu.`
      : `Aktifkan kembali akses penuh bagi instansi ${school.name}?`,
    type: isSuspending ? 'danger' : 'success',
    confirmText: isSuspending ? 'Ya, Tangguhkan' : 'Ya, Aktifkan',
  })
  if (!ok) return

  try {
    await api.patch(`/admin/schools/${school.id}/status`, { status: newStatus })
    school.status = newStatus
    toast.success(`Status ${school.name} berhasil diubah menjadi ${newStatus}.`, 'Status Diperbarui')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengubah status sekolah.', 'Gagal Ubah Status')
  }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Manajemen & Verifikasi Sekolah</template>
    <template #header-subtitle>Validasi pendaftaran instansi baru dan pantau status tenant sekolah aktif.</template>

    <div class="space-y-6">
      <!-- Tab Navigation -->
      <div class="flex items-center gap-3 border-b border-slate-200">
        <button
          type="button"
          @click="activeTab = 'registrations'"
          :class="[
            'pb-3 text-xs font-bold transition-colors relative',
            activeTab === 'registrations'
              ? 'text-brand-navy border-b-2 border-brand-navy'
              : 'text-slate-400 hover:text-slate-600'
          ]"
        >
          <i class="fa-solid fa-clock mr-1.5 text-amber-500"></i>
          Antrean Pengajuan Sekolah ({{ registrations.filter(r => r.status === 'pending').length }})
        </button>

        <button
          type="button"
          @click="activeTab = 'schools'"
          :class="[
            'pb-3 text-xs font-bold transition-colors relative',
            activeTab === 'schools'
              ? 'text-brand-navy border-b-2 border-brand-navy'
              : 'text-slate-400 hover:text-slate-600'
          ]"
        >
          <i class="fa-solid fa-building-columns mr-1.5 text-brand-blue"></i>
          Daftar Sekolah Terverifikasi ({{ schools.length }})
        </button>
      </div>

      <!-- Tab 1: Registrations Table -->
      <div v-if="activeTab === 'registrations'" class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 class="text-sm font-bold text-slate-900">Pengajuan Registrasi Sekolah Mandiri</h3>
            <p class="text-xs text-slate-500 mt-0.5">Tinjau kelayakan dan validitas NPSN sebelum memberikan izin akun admin sekolah.</p>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">NPSN & Sekolah</th>
                <th class="px-6 py-3.5">Jenjang</th>
                <th class="px-6 py-3.5">Wilayah</th>
                <th class="px-6 py-3.5">PIC Narahubung</th>
                <th class="px-6 py-3.5">Status</th>
                <th class="px-6 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="registrations.length === 0">
                <td colspan="6" class="px-6 py-8 text-center text-slate-400">
                  Tidak ada data pengajuan registrasi sekolah.
                </td>
              </tr>
              <tr v-for="reg in registrations" :key="reg.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ reg.school_name || reg.name }}</div>
                  <div class="text-[11px] text-slate-400 font-mono">NPSN: {{ reg.npsn }}</div>
                </td>
                <td class="px-6 py-4 uppercase font-semibold text-slate-700">
                  {{ reg.educational_level }}
                </td>
                <td class="px-6 py-4">
                  <div>{{ reg.city }}</div>
                  <div class="text-[11px] text-slate-400">{{ reg.province }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="font-medium text-slate-800">{{ reg.pic_name }} ({{ reg.pic_position }})</div>
                  <div class="text-[11px] text-slate-400">{{ reg.pic_phone }} • {{ reg.pic_email }}</div>
                </td>
                <td class="px-6 py-4">
                  <Badge :status="reg.status" />
                </td>
                <td class="px-6 py-4 text-right space-x-2">
                  <template v-if="reg.status === 'pending'">
                    <button
                      type="button"
                      @click="openReviewModal(reg, 'approve')"
                      class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-2xs"
                    >
                      <i class="fa-solid fa-check mr-1"></i> Setujui
                    </button>
                    <button
                      type="button"
                      @click="openReviewModal(reg, 'reject')"
                      class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 rounded-lg text-xs font-semibold"
                    >
                      <i class="fa-solid fa-xmark mr-1"></i> Tolak
                    </button>
                  </template>
                  <span v-else class="text-[11px] text-slate-400 italic">Selesai ditinjau</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Tab 2: Verified Schools Table -->
      <div v-if="activeTab === 'schools'" class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 class="text-sm font-bold text-slate-900">Tenant Sekolah Aktif</h3>
            <p class="text-xs text-slate-500 mt-0.5">Daftar instansi yang memiliki akses operasional ke PrestasiKu.</p>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">NPSN & Nama Sekolah</th>
                <th class="px-6 py-3.5">Jenjang</th>
                <th class="px-6 py-3.5">Wilayah</th>
                <th class="px-6 py-3.5">Kontak</th>
                <th class="px-6 py-3.5">Status</th>
                <th class="px-6 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="schools.length === 0">
                <td colspan="6" class="px-6 py-8 text-center text-slate-400">
                  Belum ada sekolah terverifikasi.
                </td>
              </tr>
              <tr v-for="sch in schools" :key="sch.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ sch.name }}</div>
                  <div class="text-[11px] text-slate-400 font-mono">NPSN: {{ sch.npsn }}</div>
                </td>
                <td class="px-6 py-4 uppercase font-semibold text-slate-700">
                  {{ sch.educational_level }}
                </td>
                <td class="px-6 py-4">
                  <div>{{ sch.city }}</div>
                  <div class="text-[11px] text-slate-400">{{ sch.province }}</div>
                </td>
                <td class="px-6 py-4">
                  <div>{{ sch.phone || '-' }}</div>
                  <div class="text-[11px] text-slate-400">{{ sch.email || '-' }}</div>
                </td>
                <td class="px-6 py-4">
                  <Badge :status="sch.status" />
                </td>
                <td class="px-6 py-4 text-right">
                  <button
                    type="button"
                    @click="toggleSchoolStatus(sch)"
                    :class="[
                      'px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors',
                      sch.status === 'suspended'
                        ? 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200'
                        : 'bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200'
                    ]"
                  >
                    <i :class="sch.status === 'suspended' ? 'fa-solid fa-lock-open mr-1' : 'fa-solid fa-ban mr-1'"></i>
                    {{ sch.status === 'suspended' ? 'Aktifkan Kembali' : 'Tangguhkan (Suspend)' }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Review Modal -->
      <Modal
        v-model="showReviewModal"
        :title="reviewAction === 'approve' ? 'Setujui Pendaftaran Sekolah' : 'Tolak Pendaftaran Sekolah'"
        :subtitle="selectedRegistration?.school_name || selectedRegistration?.name"
        size="md"
      >
        <!-- Success / Credentials State -->
        <div v-if="approvedAccount" class="space-y-4 p-2">
          <div class="p-4 bg-emerald-50 border border-emerald-200 rounded-2xl text-center space-y-2">
            <div class="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto text-lg">
              <i class="fa-solid fa-check"></i>
            </div>
            <h4 class="text-sm font-bold text-emerald-900">Pendaftaran Disetujui & Akun Aktif!</h4>
            <p class="text-xs text-emerald-700">Akun Admin Sekolah telah berhasil dibuat. Silakan teruskan informasi login ini kepada pihak PIC sekolah.</p>
          </div>

          <div class="bg-slate-50 p-4 rounded-2xl border border-slate-200/80 space-y-2.5 text-xs font-mono">
            <div class="flex justify-between items-center pb-2 border-b border-slate-200">
              <span class="text-slate-500 font-sans font-semibold">Instansi Sekolah:</span>
              <span class="font-bold text-slate-800 text-right font-sans">{{ selectedRegistration?.school_name || selectedRegistration?.name }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-sans">NPSN:</span>
              <span class="font-bold text-slate-800">{{ selectedRegistration?.npsn }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-sans">Username:</span>
              <span class="font-bold text-brand-blue">{{ approvedAccount.username }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-sans">Email PIC:</span>
              <span class="font-bold text-slate-800">{{ approvedAccount.email }}</span>
            </div>
            <div class="flex justify-between items-center bg-amber-50/80 p-2.5 rounded-xl border border-amber-200/60">
              <span class="text-amber-900 font-sans font-semibold">Password Login:</span>
              <span class="font-bold text-amber-950 font-mono text-sm bg-white px-2 py-0.5 rounded border border-amber-300">{{ approvedAccount.temporary_password }}</span>
            </div>
          </div>

          <div class="pt-2 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="copyCredentials"
              class="px-4 py-2 text-xs font-bold bg-brand-navy hover:bg-[#001442] text-white rounded-xl shadow-xs flex items-center gap-1.5 transition-all"
            >
              <i class="fa-solid" :class="copied ? 'fa-check text-emerald-400' : 'fa-copy text-brand-gold'"></i>
              <span>{{ copied ? 'Tersalin ke Clipboard!' : 'Salin Kredensial' }}</span>
            </button>
            <button
              type="button"
              @click="showReviewModal = false"
              class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Selesai & Tutup
            </button>
          </div>
        </div>

        <!-- Review Rejection Message -->
        <div v-else-if="reviewMessage" class="p-4 bg-rose-50 text-rose-800 rounded-xl text-xs text-center font-bold">
          {{ reviewMessage }}
        </div>

        <!-- Form State -->
        <form v-else @submit.prevent="submitReview" class="space-y-4">
          <div class="text-xs text-slate-600 bg-slate-50 p-3.5 rounded-xl border border-slate-100 space-y-1">
            <p><span class="font-semibold">NPSN:</span> {{ selectedRegistration?.npsn }}</p>
            <p><span class="font-semibold">Nama:</span> {{ selectedRegistration?.school_name || selectedRegistration?.name }}</p>
            <p><span class="font-semibold">Email:</span> {{ selectedRegistration?.pic_email || selectedRegistration?.email }}</p>
            <p><span class="font-semibold">PIC:</span> {{ selectedRegistration?.pic_name }} ({{ selectedRegistration?.pic_phone }})</p>
          </div>

          <!-- Optional Custom Admin Password if approving -->
          <div v-if="reviewAction === 'approve'" class="space-y-1">
            <label class="block text-xs font-semibold text-slate-700">
              Password Akun Admin Sekolah (Opsional)
            </label>
            <input
              v-model="adminPassword"
              type="text"
              placeholder="Default: password123"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue font-mono"
            />
            <p class="text-[11px] text-slate-500">
              Biarkan kosong jika ingin memakai password bawaan: <span class="font-mono font-bold text-emerald-700">password123</span> (rincian akun otomatis dikirimkan ke email PIC).
            </p>
          </div>

          <div>
            <label class="block text-xs font-semibold text-slate-700 mb-1">Catatan Verifikator Super Admin *</label>
            <textarea
              v-model="reviewNotes"
              rows="3"
              required
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showReviewModal = false"
              class="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="submittingReview"
              :class="[
                'px-5 py-2 text-xs font-bold text-white rounded-xl shadow-xs transition-all flex items-center gap-1.5',
                reviewAction === 'approve' ? 'bg-emerald-600 hover:bg-emerald-700' : 'bg-rose-600 hover:bg-rose-700'
              ]"
            >
              <i v-if="submittingReview" class="fa-solid fa-spinner fa-spin"></i>
              <span>{{ reviewAction === 'approve' ? 'Konfirmasi Setujui' : 'Konfirmasi Tolak' }}</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>
