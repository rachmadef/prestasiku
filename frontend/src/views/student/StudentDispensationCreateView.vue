<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import api from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const router = useRouter()
const { toast } = useNotify()

const loadingSchema = ref(true)
const requesting = ref(false)
const formSchema = ref<any[]>([])
const classmates = ref<any[]>([])
const customFieldsData = ref<Record<string, any>>({})

const requestForm = ref({
  competition_name: '',
  competition_field: '',
  competition_level: 'nasional',
  organizer: '',
  execution_type: 'offline',
  location: '',
  dispensation_type: 'pelaksanaan_lomba',
  purpose: '',
  start_date: '',
  end_date: '',
  is_all_day: true,
  start_time: '',
  end_time: '',
  supervisor_name: '',
  homeroom_teacher: '',
  phone_number: '',
  notes: '',
  additional_student_ids: [] as number[],
  attachment_file: null as File | null,
})

async function fetchFormSchema() {
  try {
    const res = await api.get('/student/dispensations/form-schema').catch(() => ({ data: { data: { schema: [] } } }))
    formSchema.value = res.data?.data?.schema || []
  } catch (err) {
    console.error('Error fetching form schema:', err)
  } finally {
    loadingSchema.value = false
  }
}

async function fetchClassmates() {
  try {
    const res = await api.get('/student/dispensations/classmates')
    classmates.value = res.data.data || []
  } catch (err) {
    console.error('Error fetching classmates:', err)
  }
}

function handleAttachmentChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    requestForm.value.attachment_file = target.files[0]
  }
}

async function handleRequestDispensation() {
  if (formSchema.value && formSchema.value.length > 0) {
    const custom = customFieldsData.value || {}
    for (const [key, val] of Object.entries(custom)) {
      if (!val) continue
      const lowerKey = key.toLowerCase()
      if (!requestForm.value.competition_name && (lowerKey.includes('lomba') || lowerKey.includes('nama') || lowerKey.includes('kegiatan') || lowerKey.includes('olimpiade'))) {
        requestForm.value.competition_name = String(val)
      }
      if (!requestForm.value.start_date && (lowerKey.includes('tanggal') || lowerKey.includes('tgl') || lowerKey.includes('mulai') || lowerKey.includes('pelaksanaan'))) {
        requestForm.value.start_date = String(val)
      }
    }
    if (!requestForm.value.competition_name) {
      const firstVal = Object.values(custom).find(v => typeof v === 'string' && v.trim().length > 0)
      requestForm.value.competition_name = firstVal ? String(firstVal) : 'Pengajuan Perizinan & Dispensasi Lomba'
    }
    if (!requestForm.value.purpose) {
      requestForm.value.purpose = requestForm.value.competition_name
    }
    if (!requestForm.value.start_date) {
      const dateVal = Object.values(custom).find(v => typeof v === 'string' && v.match(/^\d{4}-\d{2}-\d{2}$/))
      requestForm.value.start_date = dateVal ? String(dateVal) : new Date().toISOString().substring(0, 10)
    }
    if (!requestForm.value.end_date) {
      requestForm.value.end_date = requestForm.value.start_date
    }
  } else {
    if (!requestForm.value.competition_name || !requestForm.value.purpose || !requestForm.value.start_date || !requestForm.value.end_date) {
      toast.error('Mohon lengkapi semua bidang yang bertanda bintang (*).', 'Validasi Form')
      return
    }
  }

  requesting.value = true
  try {
    const formData = new FormData()
    formData.append('competition_name', requestForm.value.competition_name)
    if (requestForm.value.competition_field) formData.append('competition_field', requestForm.value.competition_field)
    if (requestForm.value.competition_level) formData.append('competition_level', requestForm.value.competition_level)
    if (requestForm.value.organizer) formData.append('organizer', requestForm.value.organizer)
    if (requestForm.value.execution_type) formData.append('execution_type', requestForm.value.execution_type)
    if (requestForm.value.location) formData.append('location', requestForm.value.location)
    formData.append('dispensation_type', requestForm.value.dispensation_type)
    formData.append('purpose', requestForm.value.purpose)
    formData.append('start_date', requestForm.value.start_date)
    formData.append('end_date', requestForm.value.end_date)
    formData.append('is_all_day', requestForm.value.is_all_day ? '1' : '0')
    if (requestForm.value.start_time) formData.append('start_time', requestForm.value.start_time)
    if (requestForm.value.end_time) formData.append('end_time', requestForm.value.end_time)
    if (requestForm.value.supervisor_name) formData.append('supervisor_name', requestForm.value.supervisor_name)
    if (requestForm.value.homeroom_teacher) formData.append('homeroom_teacher', requestForm.value.homeroom_teacher)
    if (requestForm.value.phone_number) formData.append('phone_number', requestForm.value.phone_number)
    if (requestForm.value.notes) formData.append('notes', requestForm.value.notes)
    if (requestForm.value.attachment_file) {
      formData.append('attachment_file', requestForm.value.attachment_file)
    }

    if (requestForm.value.additional_student_ids && requestForm.value.additional_student_ids.length > 0) {
      requestForm.value.additional_student_ids.forEach((id: number) => {
        formData.append('additional_student_ids[]', String(id))
      })
    }

    if (Object.keys(customFieldsData.value).length > 0) {
      formData.append('custom_fields_data', JSON.stringify(customFieldsData.value))
    }

    await api.post('/student/dispensations', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    toast.success('Permohonan perizinan & dispensasi KBM berhasil dikirim ke pihak sekolah. Menunggu validasi admin/kesiswaan.', 'Pengajuan Berhasil')
    router.push('/student/dispensations')
  } catch (err: any) {
    toast.error(err.response?.data?.message || 'Gagal mengajukan perizinan & dispensasi KBM.', 'Gagal Pengajuan')
  } finally {
    requesting.value = false
  }
}

onMounted(() => {
  fetchFormSchema()
  fetchClassmates()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Form Perizinan & Dispensasi KBM</template>

    <div class="space-y-6 max-w-4xl mx-auto pb-12">
      <!-- Top Navigation & Title Bar -->
      <div class="flex items-center justify-between">
        <router-link
          to="/student/dispensations"
          class="inline-flex items-center gap-2 text-xs font-bold text-slate-600 hover:text-brand-navy transition-colors bg-white px-3.5 py-2 rounded-xl border border-slate-200 shadow-2xs"
        >
          <i class="fa-solid fa-arrow-left"></i>
          <span>Kembali ke Riwayat Pengajuan</span>
        </router-link>
      </div>

      <!-- Main Header Banner -->
      <div class="bg-gradient-to-r from-brand-navy via-[#00287a] to-blue-900 rounded-2xl p-6 text-white shadow-md relative overflow-hidden">
        <div class="relative z-10 space-y-2 max-w-2xl">
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 text-brand-gold text-xs font-bold backdrop-blur-xs border border-white/15">
            <i class="fa-solid fa-file-pen"></i>
            Formulir Terpadu Perizinan Siswa
          </span>
          <h2 class="text-2xl sm:text-3xl font-black tracking-tight">
            Form Perizinan Lomba & Dispensasi KBM
          </h2>
          <p class="text-xs sm:text-sm text-blue-100/90 leading-relaxed">
            Isi data perlombaan dan jadwal dispensasi yang kamu ikuti. Cukup isi 1 formulir jika terdapat beberapa peserta didik dari 1 kelas yang mengikuti lomba yang sama.
          </p>
        </div>
        <div class="absolute -right-8 -bottom-8 text-white/5 text-9xl pointer-events-none font-black">
          <i class="fa-solid fa-trophy"></i>
        </div>
      </div>

      <!-- Form Container -->
      <form @submit.prevent="handleRequestDispensation" class="bg-white rounded-2xl border border-slate-200/90 shadow-sm p-6 sm:p-8 space-y-6">

        <!-- SECTION A: INFORMASI LOMBA / OLIMPIADE -->
        <div class="space-y-4">
          <div class="flex items-center gap-3 pb-3 border-b border-slate-200">
            <div class="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold text-sm shadow-2xs">
              <i class="fa-solid fa-trophy"></i>
            </div>
            <div>
              <h3 class="text-base font-black text-brand-navy">A. Informasi Lomba / Olimpiade</h3>
              <p class="text-xs text-slate-500">Identitas dan detail perlombaan yang diikuti</p>
            </div>
          </div>

          <div>
            <label class="block font-bold text-slate-800 text-xs mb-1.5">
              Nama Lomba / Olimpiade <span class="text-rose-500">*</span>
            </label>
            <input
              v-model="requestForm.competition_name"
              type="text"
              required
              placeholder="Contoh: Olimpiade Sains Nasional (OSN) Bidang Matematika 2026"
              class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
            />
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">Bidang Lomba</label>
              <input
                v-model="requestForm.competition_field"
                type="text"
                placeholder="Contoh: Matematika / Informatika / Biologi"
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>

            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">Penyelenggara Lomba</label>
              <input
                v-model="requestForm.organizer"
                type="text"
                placeholder="Contoh: Kemendikbud / BPTI / PT Pateron Indonesia"
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">
                Tingkat Lomba <span class="text-rose-500">*</span>
              </label>
              <select
                v-model="requestForm.competition_level"
                required
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden cursor-pointer transition-all"
              >
                <option value="kabupaten">Kabupaten / Kota</option>
                <option value="provinsi">Provinsi</option>
                <option value="nasional">Nasional</option>
                <option value="internasional">Internasional</option>
              </select>
            </div>

            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">
                Mode Pelaksanaan <span class="text-rose-500">*</span>
              </label>
              <select
                v-model="requestForm.execution_type"
                required
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden cursor-pointer transition-all"
              >
                <option value="offline">Offline (Tatap Muka / Tempat)</option>
                <option value="online">Online (Daring dari Rumah/Sekolah)</option>
              </select>
            </div>
          </div>
        </div>

        <!-- SECTION B: RINCIAN DISPENSASI BELAJAR (KBM) -->
        <div class="space-y-4 pt-4">
          <div class="flex items-center gap-3 pb-3 border-b border-slate-200">
            <div class="w-8 h-8 rounded-xl bg-blue-50 text-brand-blue flex items-center justify-center font-bold text-sm shadow-2xs">
              <i class="fa-solid fa-clock"></i>
            </div>
            <div>
              <h3 class="text-base font-black text-brand-navy">B. Rincian Dispensasi Belajar (KBM)</h3>
              <p class="text-xs text-slate-500">Jadwal dan keperluan izin meninggalkan kelas</p>
            </div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">
                Jenis Dispensasi <span class="text-rose-500">*</span>
              </label>
              <select
                v-model="requestForm.dispensation_type"
                required
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden cursor-pointer transition-all"
              >
                <option value="pelaksanaan_lomba">Hari-H Pelaksanaan Lomba</option>
                <option value="persiapan_latihan">Bimbingan & Latihan Intensif</option>
                <option value="lainnya">Kegiatan Prestasi Lainnya</option>
              </select>
            </div>

            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">Tempat / Ruangan Pelaksanaan</label>
              <input
                v-model="requestForm.location"
                type="text"
                placeholder="Contoh: Lab Biologi Gedung B / Ruang Guru / Online"
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>
          </div>

          <div>
            <label class="block font-bold text-slate-800 text-xs mb-1.5">
              Keperluan / Agenda Izin <span class="text-rose-500">*</span>
            </label>
            <textarea
              v-model="requestForm.purpose"
              rows="2"
              required
              placeholder="Contoh: Mengikuti Bimbingan Olimpiade Matematika / Pelaksanaan Babak Penyisihan..."
              class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
            ></textarea>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">
                Tanggal Mulai <span class="text-rose-500">*</span>
              </label>
              <input
                v-model="requestForm.start_date"
                type="date"
                required
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>

            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">
                Tanggal Selesai <span class="text-rose-500">*</span>
              </label>
              <input
                v-model="requestForm.end_date"
                type="date"
                required
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>
          </div>

          <div class="p-4 bg-slate-50 rounded-xl border border-slate-200/80 space-y-3">
            <label class="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                v-model="requestForm.is_all_day"
                class="w-4 h-4 rounded text-brand-navy border-slate-300 focus:ring-brand-navy"
              />
              <span class="text-xs sm:text-sm font-bold text-slate-800">Izin Seharian Penuh (Selama Jam Pembelajaran KBM)</span>
            </label>

            <div v-if="!requestForm.is_all_day" class="grid grid-cols-2 gap-4 pt-2 border-t border-slate-200">
              <div>
                <label class="block font-bold text-slate-700 text-xs mb-1">Jam Mulai</label>
                <input
                  v-model="requestForm.start_time"
                  type="text"
                  placeholder="07.25"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-white px-3 py-2 focus:border-brand-navy focus:outline-hidden"
                />
              </div>
              <div>
                <label class="block font-bold text-slate-700 text-xs mb-1">Jam Selesai</label>
                <input
                  v-model="requestForm.end_time"
                  type="text"
                  placeholder="12.00"
                  class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-white px-3 py-2 focus:border-brand-navy focus:outline-hidden"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- SECTION C: GURU PEMBINA, WALI KELAS & ANGGOTA TIM -->
        <div class="space-y-4 pt-4">
          <div class="flex items-center gap-3 pb-3 border-b border-slate-200">
            <div class="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold text-sm shadow-2xs">
              <i class="fa-solid fa-user-check"></i>
            </div>
            <div>
              <h3 class="text-base font-black text-brand-navy">C. Guru Pembina & Wali Kelas</h3>
              <p class="text-xs text-slate-500">Persetujuan pendamping lomba dan anggota sekelas</p>
            </div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">Guru Pembina / Pendamping Lomba</label>
              <input
                v-model="requestForm.supervisor_name"
                type="text"
                placeholder="Contoh: Dra. Sri Wahyuni, M.Pd."
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>

            <div>
              <label class="block font-bold text-slate-800 text-xs mb-1.5">Nama Wali Kelas</label>
              <input
                v-model="requestForm.homeroom_teacher"
                type="text"
                placeholder="Contoh: Bpk. Rojiul / Ibu Ani, S.Pd."
                class="w-full text-xs sm:text-sm rounded-xl border border-slate-300 bg-slate-50/50 px-3.5 py-2.5 focus:bg-white focus:border-brand-navy focus:outline-hidden transition-all"
              />
            </div>
          </div>

          <!-- Siswa Tambahan (1 Surat Untuk 1 Kelas) -->
          <div v-if="classmates.length > 0" class="space-y-2 pt-2">
            <div class="flex items-center justify-between">
              <label class="block font-bold text-slate-800 text-xs">
                Siswa Lain / Anggota Tim Sekelas (Opsional - Cukup 1 Surat Untuk 1 Kelas)
              </label>
              <span class="text-[11px] font-bold text-brand-blue bg-blue-50 px-2 py-0.5 rounded">
                {{ requestForm.additional_student_ids.length }} siswa dipilih
              </span>
            </div>
            <p class="text-xs text-slate-500">
              Centang nama siswa lain jika ada beberapa peserta didik dari kelasmu yang mengikuti lomba yang sama. Namanya akan otomatis masuk dalam lampiran surat.
            </p>
            <div class="max-h-48 overflow-y-auto p-3 bg-slate-50/80 rounded-xl border border-slate-300 space-y-1.5">
              <label
                v-for="c in classmates"
                :key="c.id"
                class="flex items-center justify-between p-2 hover:bg-white rounded-lg cursor-pointer transition-colors text-xs border border-transparent hover:border-slate-200"
              >
                <div class="flex items-center gap-2.5">
                  <input
                    type="checkbox"
                    :value="c.id"
                    v-model="requestForm.additional_student_ids"
                    class="w-4 h-4 rounded text-brand-navy border-slate-300 focus:ring-brand-navy"
                  />
                  <span class="font-bold text-slate-900">{{ c.full_name }}</span>
                </div>
                <span class="text-[11px] text-slate-500 font-mono">Kelas {{ c.class_name || '-' }} • NIS {{ c.nis || '-' }}</span>
              </label>
            </div>
          </div>

          <div>
            <label class="block font-bold text-slate-800 text-xs mb-1.5">
              Dokumen Pendukung / Surat Undangan (Opsional)
            </label>
            <input
              type="file"
              accept=".pdf,.jpg,.jpeg,.png"
              @change="handleAttachmentChange"
              class="w-full text-slate-600 text-xs file:mr-3 file:py-2.5 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-brand-navy file:text-white hover:file:bg-[#00164a] cursor-pointer border border-slate-300 rounded-xl bg-slate-50/50 p-1"
            />
            <p class="text-[11px] text-slate-500 mt-1">Format file yang didukung: PDF, JPG, PNG (Maks 5 MB)</p>
          </div>
        </div>

        <!-- Submission Buttons Footer -->
        <div class="pt-6 border-t border-slate-200 flex items-center justify-end gap-3">
          <router-link
            to="/student/dispensations"
            class="px-5 py-2.5 rounded-xl font-bold text-xs text-slate-600 hover:bg-slate-100 transition-all cursor-pointer"
          >
            Batal
          </router-link>

          <button
            type="submit"
            :disabled="requesting"
            class="px-6 py-2.5 rounded-xl font-bold text-xs bg-brand-navy text-white hover:bg-[#00164a] disabled:opacity-50 transition-all shadow-md flex items-center gap-2 cursor-pointer"
          >
            <i v-if="requesting" class="fa-solid fa-circle-notch fa-spin"></i>
            <i v-else class="fa-solid fa-paper-plane text-brand-gold"></i>
            <span>{{ requesting ? 'Mengirimkan...' : 'Kirim Pengajuan Form' }}</span>
          </button>
        </div>
      </form>
    </div>
  </DashboardLayout>
</template>
