<script setup lang="ts">
import { ref } from 'vue'
import PublicLayout from '@/layouts/PublicLayout.vue'
import api from '@/services/api'

const form = ref({
  npsn: '',
  name: '',
  educational_level: 'slta',
  province: '',
  city: '',
  district: '',
  address: '',
  postal_code: '',
  phone: '',
  email: '',
  website: '',
  pic_name: '',
  pic_phone: '',
  pic_email: '',
  pic_position: '',
})

const loading = ref(false)
const successMessage = ref<string | null>(null)
const errorMessage = ref<string | null>(null)

async function submitSchoolRegistration() {
  loading.value = true
  errorMessage.value = null
  successMessage.value = null

  try {
    const response = await api.post('/school-registration', form.value)
    successMessage.value = response.data.message || 'Pengajuan registrasi sekolah berhasil dikirimkan.'
  } catch (err: any) {
    errorMessage.value = err.response?.data?.message || 'Gagal mengirimkan pengajuan registrasi sekolah.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <PublicLayout>
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="text-center max-w-2xl mx-auto mb-10 space-y-2">
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-brand-blue text-xs font-semibold border border-blue-200">
          <i class="fa-solid fa-school text-brand-gold"></i>
          <span>Pengajuan Mandiri Instansi Sekolah</span>
        </span>
        <h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">Formulir Registrasi Sekolah Baru</h1>
        <p class="text-xs sm:text-sm text-slate-600">
          Daftarkan sekolah Anda ke dalam ekosistem PrestasiKu. Setelah diverifikasi oleh Super Admin, Anda akan menerima akun Admin Sekolah resmi untuk mengelola siswa dan delegasi lomba.
        </p>
      </div>

      <!-- Success State -->
      <div v-if="successMessage" class="bg-white rounded-3xl p-8 sm:p-12 border border-emerald-200 shadow-xl text-center space-y-4">
        <div class="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-3xl mx-auto">
          <i class="fa-solid fa-check"></i>
        </div>
        <h2 class="text-xl font-extrabold text-slate-900">Pengajuan Berhasil Dikirimkan!</h2>
        <p class="text-xs sm:text-sm text-slate-600 max-w-md mx-auto leading-relaxed">
          {{ successMessage }} Tim Super Admin PrestasiKu akan meninjau validitas NPSN dan dokumen instansi Anda dalam 1x24 jam kerja.
        </p>
        <div class="pt-4 flex justify-center gap-3">
          <router-link to="/" class="px-5 py-2.5 bg-brand-navy text-white text-xs font-bold rounded-xl shadow-xs">
            Kembali ke Beranda
          </router-link>
          <router-link to="/competitions" class="px-5 py-2.5 bg-slate-100 text-slate-700 text-xs font-bold rounded-xl">
            Jelajah Kompetisi
          </router-link>
        </div>
      </div>

      <!-- Form Body -->
      <div v-else class="bg-white rounded-3xl p-6 sm:p-10 border border-slate-200/80 shadow-md">
        <div v-if="errorMessage" class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 flex items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-rose-600 text-base"></i>
          <span>{{ errorMessage }}</span>
        </div>

        <form @submit.prevent="submitSchoolRegistration" class="space-y-8">
          <!-- Section 1: Profil Sekolah -->
          <div class="space-y-4">
            <h3 class="text-sm font-bold uppercase tracking-wider text-brand-navy flex items-center gap-2 pb-2 border-b border-slate-100">
              <i class="fa-solid fa-building-columns text-brand-blue"></i>
              Data Utama Instansi Sekolah
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div>
                <label class="block font-semibold text-slate-700 mb-1">NPSN (Nomor Pokok Sekolah Nasional) *</label>
                <input
                  v-model="form.npsn"
                  type="text"
                  placeholder="Contoh: 10101010"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Nama Lengkap Sekolah *</label>
                <input
                  v-model="form.name"
                  type="text"
                  placeholder="Contoh: SMAN 1 Prestasi Nusantara"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Jenjang Pendidikan *</label>
                <select
                  v-model="form.educational_level"
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                >
                  <option value="slta">SLTA / SMA / SMK / MA</option>
                  <option value="sltp">SLTP / SMP / MTs</option>
                </select>
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Email Resmi Sekolah *</label>
                <input
                  v-model="form.email"
                  type="email"
                  placeholder="Contoh: info@sekolah.sch.id"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Nomor Telepon Sekolah *</label>
                <input
                  v-model="form.phone"
                  type="text"
                  placeholder="Contoh: 021-7890123"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Website Sekolah (Opsional)</label>
                <input
                  v-model="form.website"
                  type="url"
                  placeholder="https://..."
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>
            </div>
          </div>

          <!-- Section 2: Alamat Wilayah -->
          <div class="space-y-4">
            <h3 class="text-sm font-bold uppercase tracking-wider text-brand-navy flex items-center gap-2 pb-2 border-b border-slate-100">
              <i class="fa-solid fa-location-dot text-brand-blue"></i>
              Wilayah & Alamat Lengkap
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
              <div>
                <label class="block font-semibold text-slate-700 mb-1">Provinsi *</label>
                <input
                  v-model="form.province"
                  type="text"
                  placeholder="Contoh: DKI Jakarta"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Kota / Kabupaten *</label>
                <input
                  v-model="form.city"
                  type="text"
                  placeholder="Contoh: Kota Jakarta Selatan"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Kecamatan *</label>
                <input
                  v-model="form.district"
                  type="text"
                  placeholder="Contoh: Kebayoran Baru"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div class="sm:col-span-2">
                <label class="block font-semibold text-slate-700 mb-1">Alamat Jalan Lengkap *</label>
                <input
                  v-model="form.address"
                  type="text"
                  placeholder="Contoh: Jl. Pendidikan No. 10"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Kode Pos *</label>
                <input
                  v-model="form.postal_code"
                  type="text"
                  placeholder="Contoh: 12110"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>
            </div>
          </div>

          <!-- Section 3: PIC Penanggung Jawab -->
          <div class="space-y-4">
            <h3 class="text-sm font-bold uppercase tracking-wider text-brand-navy flex items-center gap-2 pb-2 border-b border-slate-100">
              <i class="fa-solid fa-user-tie text-brand-blue"></i>
              Penanggung Jawab / Narahubung (PIC)
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div>
                <label class="block font-semibold text-slate-700 mb-1">Nama Lengkap PIC *</label>
                <input
                  v-model="form.pic_name"
                  type="text"
                  placeholder="Nama Pembina / Guru Kesiswaan"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Jabatan PIC *</label>
                <input
                  v-model="form.pic_position"
                  type="text"
                  placeholder="Contoh: Wakasek Kesiswaan / Guru Pembina"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Nomor WhatsApp PIC *</label>
                <input
                  v-model="form.pic_phone"
                  type="text"
                  placeholder="Contoh: 08123456789"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Email PIC *</label>
                <input
                  v-model="form.pic_email"
                  type="email"
                  placeholder="Contoh: pic@sekolah.sch.id"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>
            </div>
          </div>

          <!-- Submit Button -->
          <div class="pt-4 border-t border-slate-100 flex items-center justify-end">
            <button
              type="submit"
              :disabled="loading"
              class="px-8 py-3 bg-brand-navy hover:bg-[#001442] text-white font-extrabold text-xs rounded-xl shadow-md transition-all flex items-center gap-2"
            >
              <i v-if="loading" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-paper-plane text-brand-gold"></i>
              <span>Kirim Pengajuan Registrasi</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </PublicLayout>
</template>
