<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import Badge from '@/components/common/Badge.vue'
import Modal from '@/components/common/Modal.vue'
import { useAuthStore } from '@/stores/auth'
import api, { extractList } from '@/services/api'
import { useNotify } from '@/composables/useNotify'

const { toast } = useNotify()
const authStore = useAuthStore()
const loading = ref(true)
const registrations = ref<any[]>([])
const dispensations = ref<any[]>([])
const achievements = ref<any[]>([])

// Digital Pass Modal for fast classroom presentation
const showPassModal = ref(false)
const selectedDisp = ref<any>(null)

async function fetchStudentDashboard() {
  loading.value = true
  try {
    const [regRes, dispRes, achRes] = await Promise.all([
      api.get('/student/registrations').catch(() => ({ data: { data: [] } })),
      api.get('/student/dispensations').catch(() => ({ data: { data: [] } })),
      api.get('/student/achievements').catch(() => ({ data: { data: [] } })),
    ])
    registrations.value = extractList(regRes.data.data)
    dispensations.value = extractList(dispRes.data.data)
    achievements.value = extractList(achRes.data.data)
  } catch (err) {
    console.error('Error loading student dashboard:', err)
  } finally {
    loading.value = false
  }
}

// Check if student has active or approved dispensation today or upcoming
const todayStr = new Date().toISOString().split('T')[0]

const activeDispensations = computed(() => {
  return dispensations.value.filter((d: any) => {
    if (d.status !== 'approved') return false
    const start = d.start_date ? d.start_date.split('T')[0] : ''
    const end = d.end_date ? d.end_date.split('T')[0] : start
    return todayStr >= start && todayStr <= end
  })
})

const pendingDispensations = computed(() => {
  return dispensations.value.filter((d: any) => d.status === 'pending_approval')
})

const winnerCount = computed(() => {
  return registrations.value.filter((r: any) => r.result_status === 'winner' || r.achievement).length
})

const participantCount = computed(() => {
  return registrations.value.filter((r: any) => r.result_status === 'participant' || r.result_status === 'finalist').length
})

async function openDigitalPass(disp: any) {
  try {
    const res = await api.get(`/student/dispensations/${disp.id}`)
    selectedDisp.value = res.data.data
    showPassModal.value = true
  } catch (err) {
    selectedDisp.value = disp
    showPassModal.value = true
  }
}

function formatDateIndo(dateStr?: string) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return new Intl.DateTimeFormat('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(d)
}

function formatPurpose(p: string) {
  if (p === 'practice') return 'Pembinaan & Latihan'
  if (p === 'competition') return 'Pelaksanaan Lomba'
  return 'Kegiatan Khusus'
}

onMounted(() => {
  fetchStudentDashboard()
})
</script>

<template>
  <DashboardLayout>
    <template #header-title>Buku Saku & Jejak Prestasi Siswa</template>
    <template #header-subtitle>
      Arsip partisipasi kejuaraan dan perizinan dispensasi KBM mandiri
    </template>

    <div class="space-y-6 max-w-7xl mx-auto">
      <!-- Humanized School Profile Board -->
      <div class="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div class="bg-brand-navy px-6 py-5 border-b-4 border-brand-gold text-white flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="text-[11px] font-bold tracking-wider uppercase px-2.5 py-0.5 rounded-sm bg-white/10 text-brand-gold border border-brand-gold/30">
                Identitas Siswa Aktif
              </span>
              <span class="text-xs text-slate-300 font-mono">
                NIS: {{ authStore.user?.student?.nis || '-' }}
              </span>
            </div>
            <h1 class="text-xl md:text-2xl font-black text-white tracking-tight">
              {{ authStore.user?.name }}
            </h1>
            <p class="text-xs text-slate-200 mt-1">
              Kelas {{ authStore.user?.student?.class_name || '-' }} • {{ authStore.user?.school?.name || 'Sekolah Terdaftar' }}
            </p>
          </div>

          <div class="flex flex-wrap items-center gap-2">
            <router-link
              to="/student/dispensations"
              class="px-4 py-2.5 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-colors flex items-center gap-2"
            >
              <i class="fa-solid fa-file-signature"></i>
              <span>Ajukan Dispensasi KBM</span>
            </router-link>
            <router-link
              to="/student/portfolio"
              class="px-4 py-2.5 bg-white/15 hover:bg-white/25 text-white font-semibold text-xs rounded-xl border border-white/20 transition-colors flex items-center gap-2"
            >
              <i class="fa-solid fa-book-bookmark text-brand-gold"></i>
              <span>Buku Portofolio</span>
            </router-link>
          </div>
        </div>

        <!-- Notification Banner if active dispensation today -->
        <div
          v-if="activeDispensations.length > 0"
          class="bg-emerald-50 border-b border-emerald-200 px-6 py-3.5 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
        >
          <div class="flex items-start sm:items-center gap-3">
            <span class="w-8 h-8 rounded-full bg-emerald-600 text-white flex items-center justify-center shrink-0">
              <i class="fa-solid fa-id-badge text-sm"></i>
            </span>
            <div>
              <p class="font-bold text-emerald-900">
                Izin Dispensasi KBM Anda Berlaku Hari Ini!
              </p>
              <p class="text-emerald-700 text-[11px]">
                Keperluan: {{ activeDispensations[0].reason }} ({{ activeDispensations[0].dispensation_number }})
              </p>
            </div>
          </div>
          <button
            type="button"
            @click="openDigitalPass(activeDispensations[0])"
            class="px-3.5 py-1.5 bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold rounded-lg shadow-2xs transition-colors shrink-0 flex items-center gap-1.5"
          >
            <i class="fa-solid fa-qrcode"></i>
            <span>Tunjukkan Pass Digital Guru</span>
          </button>
        </div>
      </div>

      <!-- Humanized Overview Cards: 2 Main Operational Pillars -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Pillar 1: Dispensasi KBM -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-6 flex flex-col justify-between">
          <div class="space-y-4">
            <div class="flex items-start justify-between pb-3 border-b border-slate-100">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-blue-50 border border-blue-200 text-brand-blue flex items-center justify-center text-lg">
                  <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
                <div>
                  <h2 class="text-sm font-bold text-slate-900">Izin Dispensasi Belajar (KBM)</h2>
                  <p class="text-[11px] text-slate-500">Izin resmi meninggalkan kelas saat pembinaan dan lomba</p>
                </div>
              </div>
              <router-link to="/student/dispensations" class="text-xs font-bold text-brand-blue hover:underline">
                Kelola &rarr;
              </router-link>
            </div>

            <!-- Numbers / Status Snapshot -->
            <div class="grid grid-cols-2 gap-3">
              <div class="p-3.5 bg-slate-50 rounded-xl border border-slate-200">
                <span class="text-[11px] font-medium text-slate-500 block">Total Izin Terbit</span>
                <span class="text-xl font-black text-brand-navy">
                  {{ dispensations.filter((d: any) => d.status === 'approved' || d.status === 'completed').length }}
                </span>
                <span class="text-[10px] text-slate-400 block mt-0.5">Surat resmi ber-QR</span>
              </div>
              <div class="p-3.5 bg-amber-50/70 rounded-xl border border-amber-200/80">
                <span class="text-[11px] font-medium text-amber-800 block">Menunggu Persetujuan</span>
                <span class="text-xl font-black text-amber-900">
                  {{ pendingDispensations.length }}
                </span>
                <span class="text-[10px] text-amber-700 block mt-0.5">Sedang ditinjau kesiswaan</span>
              </div>
            </div>

            <p class="text-xs text-slate-600 leading-relaxed bg-slate-50 p-3 rounded-xl border border-slate-100">
              <i class="fa-solid fa-circle-info text-brand-blue mr-1.5"></i>
              Bila Anda harus menjalani bimbingan intensif atau bertanding di luar sekolah, ajukan permohonan dispensasi. Surat resmi dapat ditunjukkan ke guru piket via ponsel.
            </p>
          </div>

          <div class="pt-4 mt-2 flex items-center justify-between border-t border-slate-100">
            <span class="text-[11px] text-slate-400">
              Terakhir diperbarui: {{ formatDateIndo(dispensations[0]?.updated_at || dispensations[0]?.created_at) }}
            </span>
            <router-link
              to="/student/dispensations"
              class="text-xs font-bold text-brand-navy hover:text-brand-blue"
            >
              Ajukan Permohonan &rarr;
            </router-link>
          </div>
        </div>

        <!-- Pillar 2: Buku Jejak Rekam Lomba (Menang / Peserta) -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-6 flex flex-col justify-between">
          <div class="space-y-4">
            <div class="flex items-start justify-between pb-3 border-b border-slate-100">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center text-lg">
                  <i class="fa-solid fa-award"></i>
                </div>
                <div>
                  <h2 class="text-sm font-bold text-slate-900">Buku Rekam Jejak Lomba</h2>
                  <p class="text-[11px] text-slate-500">Mendokumentasikan seluruh keikutsertaan Anda</p>
                </div>
              </div>
              <router-link to="/student/portfolio" class="text-xs font-bold text-brand-blue hover:underline">
                Portofolio &rarr;
              </router-link>
            </div>

            <!-- Numbers / Outcomes Snapshot -->
            <div class="grid grid-cols-3 gap-2">
              <div class="p-3 bg-slate-50 rounded-xl border border-slate-200 text-center">
                <span class="text-[10px] font-semibold text-slate-500 block uppercase">Total Lomba</span>
                <span class="text-xl font-black text-brand-navy">{{ registrations.length }}</span>
                <span class="text-[10px] text-slate-400 block">Diikuti</span>
              </div>
              <div class="p-3 bg-amber-50/70 rounded-xl border border-amber-200/80 text-center">
                <span class="text-[10px] font-semibold text-amber-800 block uppercase">Juara / Prestasi</span>
                <span class="text-xl font-black text-amber-900">{{ winnerCount }}</span>
                <span class="text-[10px] text-amber-700 block">Piagam</span>
              </div>
              <div class="p-3 bg-blue-50/70 rounded-xl border border-blue-200/80 text-center">
                <span class="text-[10px] font-semibold text-blue-800 block uppercase">Pengalaman</span>
                <span class="text-xl font-black text-brand-blue">{{ participantCount }}</span>
                <span class="text-[10px] text-blue-700 block">Peserta</span>
              </div>
            </div>

            <p class="text-xs text-slate-600 leading-relaxed bg-slate-50 p-3 rounded-xl border border-slate-100">
              <i class="fa-solid fa-shield-heart text-brand-gold mr-1.5"></i>
              Sekolah menghargai setiap perjuangan. Menang maupun gugur di babak awal, data lomba dan sertifikat keikutsertaan Anda tersimpan permanen sebagai modal SNBP / portofolio.
            </p>
          </div>

          <div class="pt-4 mt-2 flex items-center justify-between border-t border-slate-100">
            <span class="text-[11px] text-slate-400">
              Sertifikat terverifikasi: {{ achievements.length }} berkas
            </span>
            <router-link
              to="/student/portfolio"
              class="text-xs font-bold text-brand-navy hover:text-brand-blue"
            >
              Buka Lembar Portofolio &rarr;
            </router-link>
          </div>
        </div>
      </div>

      <!-- Recent Participations & Active Passes Ledger -->
      <div class="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div class="px-6 py-4 border-b border-slate-200 flex items-center justify-between bg-slate-50/50">
          <div>
            <h2 class="text-sm font-bold text-slate-900 flex items-center gap-2">
              <i class="fa-solid fa-list-check text-brand-blue"></i>
              Histori Partisipasi Lomba & Keterangan Hasil
            </h2>
            <p class="text-xs text-slate-500">Seluruh riwayat pendaftaran Anda dan catatan capaian yang tercatat di arsip sekolah.</p>
          </div>
          <router-link to="/student/portfolio" class="text-xs font-bold text-brand-blue hover:underline">
            Lihat Portofolio Lengkap &rarr;
          </router-link>
        </div>

        <div v-if="loading" class="p-8 text-center text-xs text-slate-400">
          <i class="fa-solid fa-spinner fa-spin mr-1"></i> Memuat riwayat pendaftaran...
        </div>

        <div v-else-if="registrations.length === 0" class="p-10 text-center space-y-2">
          <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center text-xl">
            <i class="fa-solid fa-inbox"></i>
          </div>
          <p class="text-xs font-bold text-slate-700">Belum ada riwayat keikutsertaan lomba.</p>
          <p class="text-[11px] text-slate-500 max-w-sm mx-auto">
            Bila Anda mendaftar mandiri atau didelegasikan guru pembimbing, pastikan pendaftaran disetujui agar riwayat tercatat di buku arsip sekolah.
          </p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left text-xs text-slate-600">
            <thead class="bg-slate-50 text-slate-400 font-semibold uppercase tracking-wider text-[10px] border-b border-slate-100">
              <tr>
                <th class="px-6 py-3">Nama Kompetisi</th>
                <th class="px-6 py-3">Penyelenggara / Lingkup</th>
                <th class="px-6 py-3">Waktu Pelaksanaan</th>
                <th class="px-6 py-3">Status Delegasi</th>
                <th class="px-6 py-3">Hasil / Capaian</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-for="reg in registrations.slice(0, 6)" :key="reg.id" class="hover:bg-slate-50/70 transition-colors">
                <td class="px-6 py-3.5">
                  <div class="font-bold text-slate-900">{{ reg.competition?.name || 'Kompetisi Sekolah' }}</div>
                  <div class="text-[11px] text-slate-400">{{ reg.competition?.category?.name || 'Kompetisi Pelajar' }}</div>
                </td>
                <td class="px-6 py-3.5">
                  <div class="text-slate-800 font-medium">{{ reg.competition?.organizer?.name || 'Penyelenggara Resmi' }}</div>
                  <div class="text-[10px] uppercase font-mono text-slate-400">{{ reg.competition?.scope || 'Nasional' }}</div>
                </td>
                <td class="px-6 py-3.5 font-mono text-[11px] text-slate-600">
                  {{ formatDateIndo(reg.created_at) }}
                </td>
                <td class="px-6 py-3.5">
                  <Badge :status="reg.status" />
                </td>
                <td class="px-6 py-3.5">
                  <div v-if="reg.result_status === 'winner'" class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-amber-50 text-amber-800 font-bold border border-amber-200">
                    <i class="fa-solid fa-trophy text-amber-600"></i>
                    <span>{{ reg.rank_details || 'Juara' }}</span>
                  </div>
                  <div v-else-if="reg.result_status === 'participant'" class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-emerald-50 text-emerald-800 font-semibold border border-emerald-200">
                    <i class="fa-solid fa-certificate text-emerald-600"></i>
                    <span>{{ reg.rank_details || 'Peserta Terdaftar' }}</span>
                  </div>
                  <div v-else-if="reg.result_status === 'finalist'" class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-purple-50 text-purple-800 font-semibold border border-purple-200">
                    <i class="fa-solid fa-star text-purple-600"></i>
                    <span>Finalis</span>
                  </div>
                  <span v-else class="text-slate-400 italic text-[11px]">
                    Lomba berlangsung / Hasil belum terdata
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Digital Pass Siswa for Classroom Presentation -->
    <Modal
      v-model="showPassModal"
      title="Pass Izin Digital Siswa (Dispensasi KBM)"
      subtitle="Tunjukkan tampilan ini kepada Guru Mata Pelajaran / Guru Piket"
      size="md"
    >
      <div v-if="selectedDisp" class="space-y-4">
        <!-- Physical card preview -->
        <div class="bg-white border-2 border-brand-navy rounded-2xl overflow-hidden shadow-md">
          <!-- Card Header with School Identity -->
          <div class="bg-brand-navy p-4 text-white text-center border-b-2 border-brand-gold">
            <div class="text-[10px] font-mono uppercase tracking-widest text-brand-gold">KARTU DISPENSASI BELAJAR DIGITAL</div>
            <div class="font-black text-sm uppercase tracking-wide mt-0.5">{{ selectedDisp.school?.name || authStore.user?.school?.name }}</div>
            <div class="text-[10px] text-slate-300 font-mono mt-0.5">No: {{ selectedDisp.dispensation_number }}</div>
          </div>

          <!-- Card Body with QR & Student Info -->
          <div class="p-5 flex flex-col items-center text-center space-y-3 bg-[#FCFCFD]">
            <!-- Student details badge -->
            <div class="w-full bg-slate-50 p-3 rounded-xl border border-slate-200 text-left">
              <div class="flex justify-between items-center text-xs">
                <span class="text-slate-500 font-semibold">Nama Siswa:</span>
                <span class="font-black text-brand-navy text-sm">{{ authStore.user?.name }}</span>
              </div>
              <div class="flex justify-between items-center text-xs mt-1">
                <span class="text-slate-500 font-semibold">NIS / Kelas:</span>
                <span class="font-mono text-slate-800 font-bold">{{ authStore.user?.student?.nis || '-' }} / {{ authStore.user?.student?.class_name || '-' }}</span>
              </div>
              <div class="flex justify-between items-center text-xs mt-1">
                <span class="text-slate-500 font-semibold">Keperluan:</span>
                <span class="font-bold text-slate-900">{{ formatPurpose(selectedDisp.purpose) }}</span>
              </div>
              <div class="flex justify-between items-center text-xs mt-1">
                <span class="text-slate-500 font-semibold">Tanggal Berlaku:</span>
                <span class="font-mono text-emerald-800 font-bold">{{ formatDateIndo(selectedDisp.start_date) }} s/d {{ formatDateIndo(selectedDisp.end_date) }}</span>
              </div>
            </div>

            <!-- Authentic QR Code -->
            <div class="p-3 bg-white rounded-xl border-2 border-slate-200 shadow-2xs">
              <img
                v-if="selectedDisp.qr_code_data_uri"
                :src="selectedDisp.qr_code_data_uri"
                alt="QR Verifikasi"
                class="w-44 h-44 mx-auto"
              />
              <img
                v-else
                :src="`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent('https://prestasiku.id/verify-dispensation/' + selectedDisp.verification_token)}`"
                alt="QR Verifikasi"
                class="w-44 h-44 mx-auto"
              />
            </div>

            <p class="text-[11px] text-slate-500 max-w-xs leading-relaxed">
              Guru piket atau guru mapel dapat memindai QR di atas menggunakan kamera smartphone untuk memverifikasi keabsahan surat tugas resmi kesiswaan.
            </p>
          </div>

          <!-- Card Footer -->
          <div class="bg-slate-100 px-4 py-2.5 text-center text-[10px] text-slate-600 border-t border-slate-200">
            Disahkan oleh: <span class="font-bold text-slate-800">{{ selectedDisp.signed_by_name || 'Kepala Sekolah / Kesiswaan' }}</span>
            <span v-if="selectedDisp.signed_by_position">({{ selectedDisp.signed_by_position }})</span>
          </div>
        </div>

        <div class="flex justify-end">
          <button
            type="button"
            @click="showPassModal = false"
            class="px-5 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold rounded-xl transition-colors"
          >
            Tutup
          </button>
        </div>
      </div>
    </Modal>
  </DashboardLayout>
</template>
