<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'

const route = useRoute()
const token = ref((route.params.token as string) || '')
const inputToken = ref('')
const loading = ref(false)
const verificationResult = ref<any>(null)
const errorMsg = ref('')

async function verifyToken(t: string) {
  if (!t) return
  loading.value = true
  errorMsg.value = ''
  verificationResult.value = null

  try {
    const res = await api.get(`/dispensations/verify/${t}`)
    verificationResult.value = res.data.data
  } catch (err: any) {
    errorMsg.value = err.response?.data?.message || 'Kode verifikasi QR tidak valid atau surat dispensasi tidak ditemukan di database sekolah.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (token.value) {
    verifyToken(token.value)
  }
})
</script>

<template>
  <div class="min-h-screen bg-[#F3F1EF] py-8 px-4 sm:px-6 lg:px-8 font-sans text-slate-800">
    <div class="max-w-xl mx-auto space-y-6">
      <!-- Official Header -->
      <div class="text-center space-y-2">
        <router-link to="/" class="inline-flex items-center gap-2.5">
          <img src="/img/icon-main.png" alt="PrestasiKu" class="h-10 w-auto" />
          <img src="/img/text-main.png" alt="PrestasiKu" class="h-6 w-auto" />
        </router-link>
        <p class="text-[11px] uppercase tracking-wider font-bold text-slate-500">
          Sistem Verifikasi Keabsahan Surat Dispensasi Belajar (KBM)
        </p>
      </div>

      <!-- Manual Input Box if no token in URL -->
      <div v-if="!token" class="bg-white rounded-xl p-5 shadow-xs border border-slate-200">
        <label class="block text-xs font-bold text-slate-700 mb-1.5">Masukkan Kode Token Verifikasi:</label>
        <div class="flex gap-2">
          <input
            v-model="inputToken"
            type="text"
            placeholder="Contoh kode token dari surat..."
            class="flex-1 text-xs rounded-lg border border-slate-300 p-2.5 focus:border-brand-navy focus:outline-hidden"
          />
          <button
            type="button"
            @click="verifyToken(inputToken)"
            class="px-4 py-2.5 bg-brand-navy text-white text-xs font-bold rounded-lg hover:bg-[#00164a] transition-all cursor-pointer"
          >
            Verifikasi
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="bg-white rounded-xl p-10 text-center shadow-xs border border-slate-200">
        <i class="fa-solid fa-circle-notch fa-spin text-2xl text-brand-navy"></i>
        <p class="text-xs text-slate-500 mt-2 font-medium">Memverifikasi keabsahan dokumen di basis data sekolah...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="errorMsg" class="bg-white rounded-xl p-8 text-center shadow-xs border border-rose-200 space-y-3">
        <div class="w-12 h-12 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center mx-auto text-xl">
          <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="text-base font-bold text-rose-900">Verifikasi Tidak Ditemukan</h3>
        <p class="text-xs text-slate-600 max-w-sm mx-auto leading-relaxed">{{ errorMsg }}</p>
      </div>

      <!-- Official Verified Certificate Result -->
      <div v-else-if="verificationResult" class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <!-- Verification Banner Header -->
        <div
          :class="[
            'p-6 text-center text-white space-y-2',
            verificationResult.is_active_today
              ? 'bg-[#001D60]'
              : (verificationResult.status === 'approved' ? 'bg-slate-700' : 'bg-rose-700')
          ]"
        >
          <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-[11px] font-bold backdrop-blur-xs">
            <i class="fa-solid fa-shield-check text-brand-gold"></i>
            <span>DOKUMEN RESMI TERDATA</span>
          </div>

          <h2 class="text-lg sm:text-xl font-black tracking-tight uppercase">
            {{ verificationResult.school_name }}
          </h2>
          <p class="text-xs text-blue-100/90 font-mono">
            {{ verificationResult.reference_number }}
          </p>

          <div class="pt-2">
            <span
              v-if="verificationResult.is_active_today"
              class="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-xs font-black bg-emerald-500 text-white shadow-xs"
            >
              <i class="fa-solid fa-circle-check"></i>
              SAH & BERLAKU AKTIF HARI INI
            </span>
            <span
              v-else-if="verificationResult.period_status === 'completed'"
              class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-white/20 text-white"
            >
              Masa Berlaku Izin Telah Berakhir
            </span>
            <span
              v-else
              class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-white/20 text-white"
            >
              Izin Mulai Berlaku: {{ verificationResult.start_date }}
            </span>
          </div>
        </div>

        <!-- Verification Detail Body -->
        <div class="p-6 space-y-5 text-xs">
          <!-- Information Card -->
          <div class="bg-slate-50 rounded-xl p-4 border border-slate-200/80 space-y-2.5">
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold tracking-wider">Nama Kegiatan / Lomba</span>
              <span class="text-sm font-bold text-brand-navy">{{ verificationResult.competition_name }}</span>
            </div>
            <div>
              <span class="text-slate-400 block text-[10px] uppercase font-bold tracking-wider">Tujuan Dispensasi</span>
              <p class="text-slate-700 font-medium leading-relaxed">{{ verificationResult.purpose }}</p>
            </div>
            <div class="grid grid-cols-2 gap-2 pt-2 border-t border-slate-200">
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Periode Tanggal</span>
                <span class="font-bold text-slate-800">{{ verificationResult.start_date }} s.d. {{ verificationResult.end_date }}</span>
              </div>
              <div>
                <span class="text-slate-400 block text-[10px] uppercase font-bold">Waktu</span>
                <span class="font-bold text-slate-800">{{ verificationResult.is_all_day ? 'Seharian Penuh' : `${verificationResult.start_time} - ${verificationResult.end_time}` }}</span>
              </div>
            </div>
          </div>

          <!-- Custom School Specific Fields (if any) -->
          <div
            v-if="verificationResult.form_schema && verificationResult.form_schema.length > 0 && verificationResult.custom_fields_data && Object.keys(verificationResult.custom_fields_data).length > 0"
            class="bg-blue-50/60 rounded-xl p-4 border border-blue-200/70 space-y-2"
          >
            <span class="text-brand-navy block text-[10px] uppercase font-bold tracking-wider flex items-center gap-1.5">
              <i class="fa-solid fa-sparkles text-brand-gold"></i>
              <span>Rincian Tambahan Khusus {{ verificationResult.school_name }}</span>
            </span>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
              <template v-for="cf in verificationResult.form_schema" :key="cf.id">
                <div v-if="verificationResult.custom_fields_data[cf.name] !== undefined && verificationResult.custom_fields_data[cf.name] !== ''" class="bg-white p-2.5 rounded-lg border border-blue-100">
                  <span class="text-slate-400 block text-[10px] uppercase font-bold">{{ cf.label }}</span>
                  <span class="font-bold text-slate-800">
                    {{ typeof verificationResult.custom_fields_data[cf.name] === 'boolean' ? (verificationResult.custom_fields_data[cf.name] ? 'Ya / Terpenuhi' : 'Tidak') : verificationResult.custom_fields_data[cf.name] }}
                  </span>
                </div>
              </template>
            </div>
          </div>

          <!-- Students List Table -->
          <div>
            <h3 class="text-xs uppercase tracking-wider font-bold text-slate-500 mb-2">
              Siswa Penerima Dispensasi ({{ verificationResult.students?.length ?? 0 }} Orang)
            </h3>
            <div class="border border-slate-200 rounded-lg overflow-hidden">
              <table class="w-full text-left text-xs border-collapse">
                <thead class="bg-slate-100 text-slate-600 font-bold border-b border-slate-200 text-[11px]">
                  <tr>
                    <th class="px-3 py-2 text-center w-8">No</th>
                    <th class="px-3 py-2">Nama Lengkap</th>
                    <th class="px-3 py-2 text-center">Kelas</th>
                    <th class="px-3 py-2 text-center">NIS</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  <tr v-for="(student, idx) in verificationResult.students" :key="student.nis" class="hover:bg-slate-50">
                    <td class="px-3 py-2 text-center text-slate-400">{{ Number(idx) + 1 }}</td>
                    <td class="px-3 py-2 font-bold text-slate-900">{{ student.full_name }}</td>
                    <td class="px-3 py-2 text-center font-medium text-slate-700">{{ student.class_name }}</td>
                    <td class="px-3 py-2 text-center text-slate-500 font-mono">{{ student.nis }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Approval Details Footer -->
          <div class="flex items-center justify-between text-[11px] text-slate-500 pt-3 border-t border-slate-100">
            <div>
              <p>Guru Pembina: <span class="font-semibold text-slate-700">{{ verificationResult.supervisor_name || '-' }}</span></p>
            </div>
            <div class="text-right">
              <p>Disetujui: <span class="font-semibold text-emerald-800">{{ verificationResult.approved_by }}</span></p>
              <p class="text-[10px]">{{ verificationResult.approved_at }}</p>
            </div>
          </div>
        </div>

        <div class="bg-slate-50 px-6 py-3 border-t border-slate-200 text-center">
          <p class="text-[11px] text-slate-500">
            Diverifikasi Resmi oleh <span class="font-bold text-brand-navy">PrestasiKu</span> • Terhubung dengan Basis Data Sekolah
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
