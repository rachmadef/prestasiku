<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import SearchableSelect from '@/components/common/SearchableSelect.vue'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()

const registrations = ref<any[]>([])
const competitions = ref<any[]>([])
const students = ref<any[]>([])
const loading = ref(true)

// Review Modal
const showReviewModal = ref(false)
const selectedReg = ref<any>(null)
const reviewAction = ref<'approve' | 'reject'>('approve')
const reviewNotes = ref('')
const reviewing = ref(false)

// Direct Register Modal
const showDirectModal = ref(false)
const directForm = ref({
  competition_id: '',
  student_id: '',
  registration_type: 'individual',
  assignment_letter_number: '',
  notes: '',
})
const registering = ref(false)

// Record Result Modal (Menang / Kalah / Peserta)
const showResultModal = ref(false)
const recordingResult = ref(false)
const resultForm = ref({
  result_status: 'participant',
  rank_details: '',
  result_notes: '',
  certificate_file: null as File | null,
})

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

async function fetchData() {
  loading.value = true
  try {
    const [regRes, compRes, studRes] = await Promise.all([
      api.get('/school/registrations'),
      api.get('/competitions?status=published').catch(() => ({ data: { data: [] } })),
      api.get('/school/students').catch(() => ({ data: { data: [] } })),
    ])
    registrations.value = extractList(regRes.data.data)
    competitions.value = extractList(compRes.data.data)
    students.value = extractList(studRes.data.data)
  } catch (err) {
    console.error('Error fetching school registrations:', err)
  } finally {
    loading.value = false
  }
}

function openReviewModal(reg: any, action: 'approve' | 'reject') {
  selectedReg.value = reg
  reviewAction.value = action
  reviewNotes.value = action === 'approve'
    ? 'Direkomendasikan secara resmi oleh pihak sekolah.'
    : 'Belum memenuhi kriteria seleksi internal sekolah.'
  showReviewModal.value = true
}

async function submitReview() {
  if (!selectedReg.value) return
  reviewing.value = true
  try {
    await api.post(`/school/registrations/${selectedReg.value.id}/review`, {
      action: reviewAction.value,
      notes: reviewNotes.value,
    })
    showReviewModal.value = false
    toast.success(
      reviewAction.value === 'approve' ? 'Delegasi siswa berhasil disahkan oleh sekolah!' : 'Pengajuan delegasi siswa ditolak.',
      'Review Delegasi'
    )
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal memproses review pendaftaran.', 'Gagal Review')
  } finally {
    reviewing.value = false
  }
}

async function submitDirectRegistration() {
  registering.value = true
  try {
    await api.post('/school/registrations/direct', {
      competition_id: directForm.value.competition_id,
      student_id: directForm.value.student_id,
      registration_type: directForm.value.registration_type || 'individual',
      assignment_letter_number: directForm.value.assignment_letter_number || undefined,
      notes: directForm.value.notes,
    })
    showDirectModal.value = false
    directForm.value = {
      competition_id: '',
      student_id: '',
      registration_type: 'individual',
      assignment_letter_number: '',
      notes: '',
    }
    toast.success('Pendaftaran delegasi siswa berhasil disahkan langsung!', 'Pendaftaran Berhasil')
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mendaftarkan delegasi siswa.', 'Pendaftaran Gagal')
  } finally {
    registering.value = false
  }
}

function openResultModal(reg: any) {
  selectedReg.value = reg
  resultForm.value = {
    result_status: reg.result_status && reg.result_status !== 'pending' ? reg.result_status : 'participant',
    rank_details: reg.rank_details || (reg.result_status === 'winner' ? 'Juara 1' : 'Peserta'),
    result_notes: reg.result_notes || '',
    certificate_file: null,
  }
  showResultModal.value = true
}

function handleCertificateFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    resultForm.value.certificate_file = target.files[0]
  }
}

async function submitResult() {
  if (!selectedReg.value) return
  recordingResult.value = true
  try {
    const formData = new FormData()
    formData.append('result_status', resultForm.value.result_status)
    formData.append('rank_details', resultForm.value.rank_details)
    if (resultForm.value.result_notes) {
      formData.append('result_notes', resultForm.value.result_notes)
    }
    if (resultForm.value.certificate_file) {
      formData.append('certificate_file', resultForm.value.certificate_file)
    }

    await api.post(`/school/registrations/${selectedReg.value.id}/result`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Hasil lomba dan arsip partisipasi siswa berhasil didokumentasikan.', 'Arsip Diperbarui')
    showResultModal.value = false
    fetchData()
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mencatat hasil lomba.', 'Gagal')
  } finally {
    recordingResult.value = false
  }
}

async function downloadCertificate(regId: number) {
  try {
    const res = await api.get(`/school/registrations/${regId}/certificate`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(new Blob([res.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `Sertifikat-Delegasi-${regId}.pdf`)
    document.body.appendChild(link)
    link.click()
    link.remove()
  } catch (err) {
    toast.error('Gagal mengunduh berkas sertifikat.', 'Unduh Gagal')
  }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Delegasi & Pendaftaran Kompetisi</template>
    <template #header-subtitle>Persetujuan permohonan delegasi lomba siswa dan pendaftaran langsung perwakilan sekolah.</template>

    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <p class="text-xs text-slate-500">Daftar delegasi lomba sekolah dalam periode aktif.</p>
        <button
          type="button"
          @click="showDirectModal = true"
          class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center gap-2"
        >
          <i class="fa-solid fa-user-plus text-brand-gold"></i>
          <span>Daftarkan Delegasi Langsung</span>
        </button>
      </div>

      <!-- Registrations Table -->
      <div class="bg-white rounded-3xl border border-slate-200/80 shadow-2xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50/75 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3.5">Nama Siswa</th>
                <th class="px-6 py-3.5">Kompetisi Dituju</th>
                <th class="px-6 py-3.5">Tanggal</th>
                <th class="px-6 py-3.5">Status Delegasi</th>
                <th class="px-6 py-3.5">Hasil / Arsip</th>
                <th class="px-6 py-3.5 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="registrations.length === 0">
                <td colspan="6" class="px-6 py-8 text-center text-slate-400">
                  Belum ada pengajuan pendaftaran lomba.
                </td>
              </tr>
              <tr v-for="reg in registrations" :key="reg.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-900">{{ reg.student?.full_name || reg.student?.user?.name }}</div>
                  <div class="text-[11px] text-slate-400 font-mono">NIS: {{ reg.student?.nis }} • Kelas {{ reg.student?.class_name }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="font-semibold text-slate-800">{{ reg.competition?.name }}</div>
                  <div class="text-[11px] text-slate-400">{{ reg.competition?.category?.name || '-' }}</div>
                </td>
                <td class="px-6 py-4 text-slate-500 font-mono text-[11px]">
                  {{ reg.created_at ? reg.created_at.split('T')[0] : '-' }}
                </td>
                <td class="px-6 py-4">
                  <Badge :status="reg.status" />
                </td>
                <!-- Hasil / Arsip Lomba -->
                <td class="px-6 py-4">
                  <div v-if="reg.result_status === 'winner'" class="flex items-center gap-1.5 text-amber-700 font-bold">
                    <i class="fa-solid fa-trophy text-amber-500"></i>
                    <span>{{ reg.rank_details || 'Juara' }}</span>
                  </div>
                  <div v-else-if="reg.result_status === 'participant'" class="flex items-center gap-1.5 text-emerald-700 font-bold">
                    <i class="fa-solid fa-id-badge text-emerald-500"></i>
                    <span>{{ reg.rank_details || 'Peserta Terdaftar' }}</span>
                  </div>
                  <div v-else-if="reg.result_status === 'finalist'" class="flex items-center gap-1.5 text-purple-700 font-bold">
                    <i class="fa-solid fa-star text-purple-500"></i>
                    <span>Finalis</span>
                  </div>
                  <span v-else class="text-slate-400 text-[11px] italic">
                    Belum ada hasil
                  </span>
                </td>
                <td class="px-6 py-4 text-right space-x-1.5 whitespace-nowrap">
                  <template v-if="reg.status === 'submitted' || reg.status === 'in_review'">
                    <button
                      type="button"
                      @click="openReviewModal(reg, 'approve')"
                      class="px-2.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-2xs"
                    >
                      <i class="fa-solid fa-check mr-1"></i> Rekomendasikan
                    </button>
                    <button
                      type="button"
                      @click="openReviewModal(reg, 'reject')"
                      class="px-2.5 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 rounded-lg text-xs font-semibold"
                    >
                      <i class="fa-solid fa-xmark mr-1"></i> Tolak
                    </button>
                  </template>

                  <!-- Tombol Catat Hasil Lomba -->
                  <button
                    type="button"
                    @click="openResultModal(reg)"
                    class="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-brand-navy border border-blue-200 rounded-lg text-xs font-bold transition-all"
                    title="Catat Hasil (Menang / Kalah / Peserta)"
                  >
                    <i class="fa-solid fa-medal mr-1 text-brand-gold"></i>
                    <span>Catat Hasil</span>
                  </button>

                  <!-- Tombol Unduh Sertifikat jika ada -->
                  <button
                    v-if="reg.certificate_file"
                    type="button"
                    @click="downloadCertificate(reg.id)"
                    class="px-2 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200 rounded-lg text-xs font-bold"
                    title="Unduh Sertifikat"
                  >
                    <i class="fa-solid fa-file-arrow-down"></i>
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
        :title="reviewAction === 'approve' ? 'Rekomendasikan Delegasi Siswa' : 'Tolak Pengajuan Delegasi'"
        :subtitle="selectedReg?.competition?.name"
        size="md"
      >
        <form @submit.prevent="submitReview" class="space-y-4 text-xs">
          <div class="p-3 bg-slate-50 rounded-xl border border-slate-100">
            <p><span class="font-semibold">Nama Siswa:</span> {{ selectedReg?.student?.full_name }}</p>
            <p><span class="font-semibold">Kelas:</span> {{ selectedReg?.student?.class_name }}</p>
            <p><span class="font-semibold">Kompetisi:</span> {{ selectedReg?.competition?.name }}</p>
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Catatan Sekolah / Rekomendasi *</label>
            <textarea
              v-model="reviewNotes"
              rows="3"
              required
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showReviewModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="reviewing"
              :class="[
                'px-5 py-2 font-bold text-white rounded-xl shadow-xs transition-all',
                reviewAction === 'approve' ? 'bg-emerald-600 hover:bg-emerald-700' : 'bg-rose-600 hover:bg-rose-700'
              ]"
            >
              <i v-if="reviewing" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Konfirmasi</span>
            </button>
          </div>
        </form>
      </Modal>

      <!-- Direct Register Modal -->
      <Modal v-model="showDirectModal" title="Pendaftaran Delegasi Langsung" size="md">
        <form @submit.prevent="submitDirectRegistration" class="space-y-4 text-xs">
          <div>
            <SearchableSelect
              v-model="directForm.competition_id"
              label="Pilih Kompetisi"
              placeholder="Cari kompetisi resmi (OSN, FLS2N, dll)..."
              searchPlaceholder="Ketik nama kompetisi..."
              :options="competitionOptions"
              required
            />
          </div>

          <div>
            <SearchableSelect
              v-model="directForm.student_id"
              label="Pilih Siswa Perwakilan"
              placeholder="Pilih atau cari nama siswa / NIS..."
              searchPlaceholder="Ketik nama siswa, NIS, atau kelas..."
              :options="studentOptions"
              required
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Nomor Surat Tugas Sekolah</label>
            <input
              v-model="directForm.assignment_letter_number"
              type="text"
              placeholder="Contoh: 421/ST-SMAN1/2026"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1">Catatan Delegasi (Opsional)</label>
            <textarea
              v-model="directForm.notes"
              rows="2"
              placeholder="Catatan seleksi atau pembimbing delegasi..."
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showDirectModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="registering"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs"
            >
              <i v-if="registering" class="fa-solid fa-spinner fa-spin mr-1"></i>
              <span>Daftarkan Siswa</span>
            </button>
          </div>
        </form>
      </Modal>

      <!-- Record Competition Result Modal (Menang / Kalah / Peserta) -->
      <Modal v-model="showResultModal" title="Catat Hasil & Arsip Partisipasi Lomba" size="md">
        <form @submit.prevent="submitResult" class="space-y-4 text-xs">
          <div class="p-3 bg-slate-50 rounded-xl border border-slate-200">
            <p><span class="font-semibold text-slate-500">Siswa:</span> <span class="font-bold text-slate-800">{{ selectedReg?.student?.full_name }}</span> (NIS: {{ selectedReg?.student?.nis }})</p>
            <p><span class="font-semibold text-slate-500">Kompetisi:</span> <span class="font-bold text-slate-800">{{ selectedReg?.competition?.name }}</span></p>
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1">Status Hasil Lomba *</label>
            <select
              v-model="resultForm.result_status"
              required
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            >
              <option value="participant">Peserta / Partisipan (Dokumentasi Pengalaman Berlomba)</option>
              <option value="winner">Juara / Pemenang (Juara 1, 2, 3, Harapan, Emas/Perak/Perunggu)</option>
              <option value="finalist">Finalis / Semifinalis</option>
            </select>
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1">Predikat / Keterangan Peringkat *</label>
            <input
              v-model="resultForm.rank_details"
              type="text"
              required
              placeholder="Contoh: Peserta Babak Penyisihan, Juara 1 Nasional, Finalis 10 Besar"
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            />
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1">Berkas Sertifikat (PDF / JPG / PNG, maks 5MB)</label>
            <input
              type="file"
              accept=".pdf,.jpg,.jpeg,.png"
              @change="handleCertificateFileChange"
              class="w-full text-slate-600 file:mr-3 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-navy file:text-white hover:file:bg-blue-900 cursor-pointer"
            />
            <p class="text-[10px] text-slate-400 mt-1">Dapat berupa sertifikat kepesertaan (certificate of participation) atau piagam kejuaraan.</p>
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1">Catatan Tambahan (Opsional)</label>
            <textarea
              v-model="resultForm.result_notes"
              rows="2"
              placeholder="Catatan skor, evaluasi pembina, atau jalannya lomba..."
              class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
            ></textarea>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button
              type="button"
              @click="showResultModal = false"
              class="px-4 py-2 font-semibold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              Batal
            </button>
            <button
              type="submit"
              :disabled="recordingResult"
              class="px-5 py-2 font-bold text-white bg-brand-navy hover:bg-[#001442] rounded-xl shadow-xs flex items-center gap-2"
            >
              <i v-if="recordingResult" class="fa-solid fa-spinner fa-spin"></i>
              <span>Simpan & Arsipkan</span>
            </button>
          </div>
        </form>
      </Modal>
    </div>
  </DashboardLayout>
</template>

