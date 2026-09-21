<script setup lang="ts">
import { ref, computed } from 'vue'
import PublicLayout from '@/layouts/PublicLayout.vue'
import api from '@/services/api'
import { INDONESIA_PROVINCES, type CityOption } from '@/data/indonesiaRegions'

const form = ref({
  npsn: '',
  school_name: '', // Standardized key matching RegisterSchoolRequest
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

// Region selection state
const selectedProvinceId = ref('')
const selectedCityId = ref('')
const selectedDistrict = ref('')
const isCustomDistrict = ref(false)
const customDistrictName = ref('')
const loadingDistricts = ref(false)
const districtOptions = ref<{ id: string; name: string }[]>([])

// Computed cities for currently selected province
const availableCities = computed<CityOption[]>(() => {
  if (!selectedProvinceId.value) return []
  const prov = INDONESIA_PROVINCES.find(p => p.id === selectedProvinceId.value)
  return prov ? prov.cities : []
})

function formatTitleCase(str: string): string {
  if (!str) return ''
  return str
    .toLowerCase()
    .split(' ')
    .map(word => {
      if (['dki', 'di'].includes(word)) return word.toUpperCase()
      return word.charAt(0).toUpperCase() + word.slice(1)
    })
    .join(' ')
}

function onProvinceChange() {
  const prov = INDONESIA_PROVINCES.find(p => p.id === selectedProvinceId.value)
  form.value.province = prov ? prov.name : ''
  
  // Reset city & district
  selectedCityId.value = ''
  form.value.city = ''
  resetDistrict()
}

async function onCityChange() {
  const city = availableCities.value.find(c => c.id === selectedCityId.value)
  form.value.city = city ? city.name : ''
  
  resetDistrict()
  
  if (selectedCityId.value) {
    await fetchDistricts(selectedCityId.value)
  }
}

function resetDistrict() {
  selectedDistrict.value = ''
  form.value.district = ''
  isCustomDistrict.value = false
  customDistrictName.value = ''
  districtOptions.value = []
}

async function fetchDistricts(cityId: string) {
  loadingDistricts.value = true
  try {
    const res = await api.get(`/districts/${cityId}`)
    const data = res.data
    if (Array.isArray(data) && data.length > 0) {
      districtOptions.value = data.map((d: any) => ({
        id: d.id,
        name: formatTitleCase(d.name),
      }))
      return
    }
  } catch (e) {
    console.warn('Gagal memuat API kecamatan, menggunakan input manual.', e)
  } finally {
    loadingDistricts.value = false
  }

  // Fallback if no districts returned or offline
  isCustomDistrict.value = true
}

function onDistrictChange() {
  if (selectedDistrict.value === '__custom__') {
    isCustomDistrict.value = true
    form.value.district = customDistrictName.value
  } else {
    isCustomDistrict.value = false
    form.value.district = selectedDistrict.value
  }
}

function onCustomDistrictInput() {
  form.value.district = customDistrictName.value
}

const loading = ref(false)
const successMessage = ref<string | null>(null)
const errorMessage = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})

const submittedNpsn = ref('')
const showSuccessModal = ref(false)
const adminPhoneNumber = '085755969705'

const whatsappAdminUrl = computed(() => {
  const school = form.value.school_name || 'Sekolah kami'
  const npsn = submittedNpsn.value || form.value.npsn || '-'
  const pic = form.value.pic_name || 'PIC Sekolah'
  const message = `Halo Admin PrestasiKu, saya ${pic} dari ${school} (NPSN: ${npsn}). Kami telah berhasil mendaftarkan sekolah kami di sistem PrestasiKu. Mohon bantuannya untuk persetujuan (approval) akses login ke dashboard admin sekolah. Terima kasih.`
  return `https://wa.me/6285755969705?text=${encodeURIComponent(message)}`
})

async function submitSchoolRegistration() {
  loading.value = true
  errorMessage.value = null
  fieldErrors.value = {}
  successMessage.value = null

  try {
    // Send both school_name and name to guarantee backend compatibility
    const payload = {
      ...form.value,
      school_name: form.value.school_name,
      name: form.value.school_name,
    }
    const response = await api.post('/school-registration', payload)
    submittedNpsn.value = form.value.npsn
    successMessage.value = response.data.message || 'Pengajuan registrasi sekolah berhasil dikirimkan.'
    showSuccessModal.value = true
  } catch (err: any) {
    if (err.response?.status === 422) {
      fieldErrors.value = err.response.data?.errors || {}
      errorMessage.value = err.response.data?.message || 'Mohon periksa dan lengkapi kolom yang ditandai merah.'
    } else {
      errorMessage.value = err.response?.data?.message || 'Gagal mengirimkan pengajuan registrasi sekolah.'
    }
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
      <div v-if="successMessage" class="bg-white rounded-3xl p-8 sm:p-12 border border-emerald-200 shadow-xl text-center space-y-5">
        <div class="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-3xl mx-auto">
          <i class="fa-solid fa-check"></i>
        </div>
        <h2 class="text-xl font-extrabold text-slate-900">Pengajuan Berhasil Dikirimkan!</h2>
        <p class="text-xs sm:text-sm text-slate-600 max-w-md mx-auto leading-relaxed">
          {{ successMessage }} Tim Super Admin PrestasiKu akan meninjau validitas NPSN dan identitas instansi Anda dalam 1x24 jam kerja.
        </p>

        <!-- Informational box regarding school admin credentials -->
        <div class="p-4 rounded-2xl bg-blue-50/70 border border-blue-200/70 text-left text-xs text-slate-800 space-y-2 max-w-md mx-auto">
          <div class="font-bold flex items-center gap-1.5 text-brand-navy">
            <i class="fa-solid fa-key text-brand-blue"></i>
            Informasi Akses Admin Sekolah (Setelah Disetujui)
          </div>
          <p class="text-[11px] text-slate-600 leading-relaxed">
            Begitu pengajuan ini disetujui Super Admin, akun Admin Sekolah resmi otomatis aktif dengan format:
          </p>
          <div class="bg-white p-3 rounded-xl border border-blue-100 font-mono text-[11px] space-y-1.5">
            <div class="flex justify-between">
              <span class="text-slate-500 font-sans">Username:</span>
              <span class="font-bold text-brand-blue">admin_{{ submittedNpsn || form.npsn }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500 font-sans">Atau Login Email:</span>
              <span class="font-bold text-slate-700">{{ form.pic_email || 'Email PIC' }}</span>
            </div>
            <div class="flex justify-between border-t border-slate-100 pt-1.5">
              <span class="text-slate-500 font-sans">Password Bawaan:</span>
              <span class="font-bold text-emerald-700">password123</span>
            </div>
            <p class="text-[10px] text-slate-400 font-sans pt-1 italic">
              *Rincian akun & tautan login juga otomatis dikirim ke email PIC.
            </p>
          </div>
        </div>

        <div class="pt-2 flex flex-wrap justify-center gap-3">
          <a
            :href="whatsappAdminUrl"
            target="_blank"
            class="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all inline-flex items-center gap-2 cursor-pointer"
          >
            <i class="fa-brands fa-whatsapp text-sm"></i>
            <span>Hubungi Admin ({{ adminPhoneNumber }})</span>
          </a>
          <router-link to="/login" class="px-5 py-2.5 bg-brand-navy text-white text-xs font-bold rounded-xl shadow-xs hover:bg-[#001442] inline-flex items-center gap-1.5">
            <i class="fa-solid fa-arrow-right-to-bracket"></i>
            <span>Ke Halaman Login</span>
          </router-link>
          <router-link to="/competitions" class="px-5 py-2.5 bg-slate-100 text-slate-700 text-xs font-bold rounded-xl hover:bg-slate-200">
            Jelajah Kompetisi
          </router-link>
        </div>
      </div>

      <!-- Form Body -->
      <div v-else class="bg-white rounded-3xl p-6 sm:p-10 border border-slate-200/80 shadow-md">
        <!-- Error Banner -->
        <div v-if="errorMessage" class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 space-y-1">
          <div class="flex items-center gap-2 font-bold">
            <i class="fa-solid fa-triangle-exclamation text-rose-600 text-base"></i>
            <span>{{ errorMessage }}</span>
          </div>
          <ul v-if="Object.keys(fieldErrors).length > 0" class="list-disc list-inside text-[11px] text-rose-700 pl-6 pt-1 space-y-0.5">
            <li v-for="(msgs, field) in fieldErrors" :key="field">
              {{ msgs[0] }}
            </li>
          </ul>
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
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.npsn ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                />
                <p v-if="fieldErrors.npsn" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.npsn[0] }}
                </p>
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Nama Lengkap Sekolah *</label>
                <input
                  v-model="form.school_name"
                  type="text"
                  placeholder="Contoh: SMAN 1 Prestasi Nusantara / MA Unggulan"
                  required
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.school_name || fieldErrors.name ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                />
                <p v-if="fieldErrors.school_name || fieldErrors.name" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ (fieldErrors.school_name || fieldErrors.name)?.[0] }}
                </p>
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Jenjang Pendidikan *</label>
                <select
                  v-model="form.educational_level"
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                >
                  <option value="slta">SLTA / SMA / SMK / MA</option>
                  <option value="sltp">SLTP / SMP / MTs</option>
                  <option value="both">Keduanya (SLTP & SLTA Terpadu)</option>
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
                  placeholder="Contoh: 021-7890123 / 0857..."
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Website Sekolah (Opsional)</label>
                <input
                  v-model="form.website"
                  type="url"
                  placeholder="https://sekolah.sch.id"
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>
            </div>
          </div>

          <!-- Section 2: Alamat Wilayah (Cascading Dropdown 38 Provinsi 2026) -->
          <div class="space-y-4">
            <div class="flex items-center justify-between pb-2 border-b border-slate-100">
              <h3 class="text-sm font-bold uppercase tracking-wider text-brand-navy flex items-center gap-2">
                <i class="fa-solid fa-location-dot text-brand-blue"></i>
                Wilayah & Alamat Lengkap
              </h3>
              <span class="text-[10px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-full border border-blue-100 flex items-center gap-1">
                <i class="fa-solid fa-map-location-dot text-brand-gold"></i> 38 Provinsi Indonesia (2026)
              </span>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
              <!-- Dropdown 1: Provinsi -->
              <div>
                <label class="block font-semibold text-slate-700 mb-1">
                  Provinsi *
                </label>
                <select
                  v-model="selectedProvinceId"
                  @change="onProvinceChange"
                  required
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.province ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                >
                  <option value="" disabled>-- Pilih Provinsi --</option>
                  <option v-for="prov in INDONESIA_PROVINCES" :key="prov.id" :value="prov.id">
                    {{ prov.name }}
                  </option>
                </select>
                <p v-if="fieldErrors.province" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.province[0] }}
                </p>
              </div>

              <!-- Dropdown 2: Kota / Kabupaten -->
              <div>
                <label class="block font-semibold text-slate-700 mb-1">
                  Kota / Kabupaten *
                </label>
                <select
                  v-model="selectedCityId"
                  @change="onCityChange"
                  :disabled="!selectedProvinceId"
                  required
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors disabled:opacity-50 disabled:cursor-not-allowed',
                    fieldErrors.city ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                >
                  <option value="" disabled>
                    {{ selectedProvinceId ? '-- Pilih Kota / Kabupaten --' : '-- Pilih Provinsi Dulu --' }}
                  </option>
                  <option v-for="city in availableCities" :key="city.id" :value="city.id">
                    {{ city.name }}
                  </option>
                </select>
                <p v-if="fieldErrors.city" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.city[0] }}
                </p>
              </div>

              <!-- Dropdown 3: Kecamatan -->
              <div>
                <div class="flex items-center justify-between mb-1">
                  <label class="block font-semibold text-slate-700">Kecamatan *</label>
                  <span v-if="loadingDistricts" class="text-[10px] text-brand-blue flex items-center gap-1">
                    <i class="fa-solid fa-spinner fa-spin"></i> Memuat...
                  </span>
                </div>

                <!-- Case A: District list loaded from API -->
                <div v-if="districtOptions.length > 0 && !isCustomDistrict">
                  <select
                    v-model="selectedDistrict"
                    @change="onDistrictChange"
                    :disabled="!selectedCityId || loadingDistricts"
                    required
                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue disabled:opacity-50"
                  >
                    <option value="" disabled>-- Pilih Kecamatan --</option>
                    <option v-for="dist in districtOptions" :key="dist.id" :value="dist.name">
                      {{ dist.name }}
                    </option>
                    <option value="__custom__">✏️ Ketik Manual / Lainnya...</option>
                  </select>
                </div>

                <!-- Case B: Manual Input or fallback -->
                <div v-else class="space-y-1.5">
                  <input
                    v-model="customDistrictName"
                    @input="onCustomDistrictInput"
                    type="text"
                    :placeholder="loadingDistricts ? 'Memuat data kecamatan...' : (selectedCityId ? 'Ketik nama kecamatan...' : 'Pilih kota dulu')"
                    :disabled="!selectedCityId || loadingDistricts"
                    required
                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue disabled:opacity-50"
                  />
                  <button
                    v-if="districtOptions.length > 0 && isCustomDistrict"
                    type="button"
                    @click="isCustomDistrict = false; selectedDistrict = ''"
                    class="text-[11px] text-brand-blue hover:underline flex items-center gap-1"
                  >
                    <i class="fa-solid fa-list-ul"></i> Kembali ke daftar pilihan dropdown
                  </button>
                </div>

                <p v-if="fieldErrors.district" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.district[0] }}
                </p>
              </div>

              <!-- Alamat Jalan -->
              <div class="sm:col-span-2">
                <label class="block font-semibold text-slate-700 mb-1">Alamat Jalan Lengkap *</label>
                <input
                  v-model="form.address"
                  type="text"
                  placeholder="Contoh: Jl. K.H. Abd. Wahab Hasbulloh Gg. Pondok, Tambakberas"
                  required
                  class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-hidden focus:border-brand-blue"
                />
              </div>

              <!-- Kode Pos -->
              <div>
                <label class="block font-semibold text-slate-700 mb-1">Kode Pos *</label>
                <input
                  v-model="form.postal_code"
                  type="text"
                  placeholder="Contoh: 61415"
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
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.pic_name ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                />
                <p v-if="fieldErrors.pic_name" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.pic_name[0] }}
                </p>
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Jabatan PIC *</label>
                <input
                  v-model="form.pic_position"
                  type="text"
                  placeholder="Contoh: Wakasek Kesiswaan / Guru Pembina"
                  required
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.pic_position ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                />
                <p v-if="fieldErrors.pic_position" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.pic_position[0] }}
                </p>
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Nomor WhatsApp PIC *</label>
                <input
                  v-model="form.pic_phone"
                  type="text"
                  placeholder="Contoh: 08123456789"
                  required
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.pic_phone ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                />
                <p v-if="fieldErrors.pic_phone" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.pic_phone[0] }}
                </p>
              </div>

              <div>
                <label class="block font-semibold text-slate-700 mb-1">Email PIC *</label>
                <input
                  v-model="form.pic_email"
                  type="email"
                  placeholder="Contoh: pic@sekolah.sch.id"
                  required
                  :class="[
                    'w-full px-3 py-2 bg-slate-50 border rounded-xl focus:outline-hidden focus:border-brand-blue transition-colors',
                    fieldErrors.pic_email ? 'border-rose-400 bg-rose-50/30' : 'border-slate-200'
                  ]"
                />
                <p v-if="fieldErrors.pic_email" class="text-[11px] text-rose-600 mt-1 font-medium">
                  {{ fieldErrors.pic_email[0] }}
                </p>
              </div>
            </div>
          </div>

          <!-- Submit Button -->
          <div class="pt-4 border-t border-slate-100 flex items-center justify-end">
            <button
              type="submit"
              :disabled="loading"
              class="px-8 py-3 bg-brand-navy hover:bg-[#001442] text-white font-extrabold text-xs rounded-xl shadow-md transition-all flex items-center gap-2 cursor-pointer disabled:opacity-60"
            >
              <i v-if="loading" class="fa-solid fa-spinner fa-spin"></i>
              <i v-else class="fa-solid fa-paper-plane text-brand-gold"></i>
              <span>Kirim Pengajuan Registrasi</span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Popup Notifikasi Pendaftaran Berhasil & Kontak Admin -->
    <Teleport to="body">
      <div
        v-if="showSuccessModal"
        class="fixed inset-0 z-50 overflow-y-auto flex items-center justify-center p-4 sm:p-6"
        role="dialog"
        aria-modal="true"
      >
        <!-- Backdrop with soft blur -->
        <div
          class="fixed inset-0 bg-[#001D60]/60 backdrop-blur-xs transition-opacity"
          @click="showSuccessModal = false"
        ></div>

        <!-- Modal Dialog Box -->
        <div class="relative bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl border border-slate-100 z-10 text-center transform transition-all">
          <!-- Icon -->
          <div class="w-16 h-16 rounded-2xl bg-emerald-100 text-emerald-600 flex items-center justify-center text-3xl mx-auto shadow-inner ring-8 ring-emerald-50 mb-4">
            <i class="fa-solid fa-circle-check"></i>
          </div>

          <!-- Title -->
          <h3 class="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
            Pendaftaran Berhasil!
          </h3>

          <!-- Registered School Badge -->
          <div v-if="form.school_name" class="mt-2 inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-brand-navy border border-blue-200/80 text-xs font-semibold">
            <i class="fa-solid fa-school text-brand-blue"></i>
            <span class="truncate max-w-xs">{{ form.school_name }}</span>
            <span class="text-slate-400">•</span>
            <span class="text-slate-600">NPSN: {{ submittedNpsn || form.npsn }}</span>
          </div>

          <!-- Exact message requested by user -->
          <div class="mt-4 p-4 rounded-2xl bg-slate-50 border border-slate-200/80 text-xs sm:text-sm text-slate-700 leading-relaxed text-center font-medium">
            Pendaftaran berhasil. Silahkan hubungi admin dibawah ini untuk mendapatkan persetujuan login ke dashboard admin.
          </div>

          <!-- Admin Contact Pill -->
          <div class="mt-4 flex items-center justify-center gap-3 p-3.5 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900">
            <div class="w-10 h-10 rounded-xl bg-emerald-600 text-white flex items-center justify-center text-lg shadow-xs shrink-0">
              <i class="fa-brands fa-whatsapp"></i>
            </div>
            <div class="text-left">
              <p class="text-[10px] uppercase font-bold tracking-wider text-emerald-700">Admin Persetujuan PrestasiKu</p>
              <p class="text-base font-black text-emerald-950 font-mono tracking-wider">{{ adminPhoneNumber }}</p>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="mt-6 flex flex-col sm:flex-row gap-3">
            <!-- Hubungi Admin Button -->
            <a
              :href="whatsappAdminUrl"
              target="_blank"
              class="flex-1 inline-flex items-center justify-center gap-2 px-5 py-3.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs sm:text-sm font-extrabold shadow-md hover:shadow-lg transition-all cursor-pointer"
            >
              <i class="fa-brands fa-whatsapp text-lg"></i>
              <span>Hubungi Admin ({{ adminPhoneNumber }})</span>
            </a>

            <!-- Selesai / OK Button -->
            <button
              type="button"
              @click="showSuccessModal = false"
              class="sm:w-32 inline-flex items-center justify-center px-5 py-3.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs sm:text-sm font-bold transition-all cursor-pointer border border-slate-200/80"
            >
              <span>Selesai / OK</span>
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </PublicLayout>
</template>
