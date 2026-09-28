<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import Badge from '@/components/common/Badge.vue'
import api, { extractList } from '@/services/api'

const route = useRoute()
const router = useRouter()

const competitions = ref<any[]>([])
const categories = ref<any[]>([])
const curationGroups = ref<any[]>([])
const loading = ref(true)

const searchQuery = ref((route.query.q as string) || '')
const selectedCategory = ref((route.query.category as string) || '')
const selectedLevel = ref((route.query.level as string) || '')
const selectedScope = ref((route.query.scope as string) || '')
const selectedCuration = ref((route.query.curation as string) || '')
const selectedTimeline = ref((route.query.timeline as string) || '')

async function fetchCategories() {
  try {
    const response = await api.get('/categories')
    categories.value = extractList(response.data.data)
  } catch (err) {
    console.error('Error loading categories:', err)
  }
}

async function fetchCurationGroups() {
  try {
    const params: Record<string, any> = {}
    if (selectedLevel.value) params.educational_level = selectedLevel.value
    const response = await api.get('/curation-groups', { params })
    if (response.data?.data?.groups) {
      curationGroups.value = response.data.data.groups
    }
  } catch (err) {
    console.error('Error loading curation groups:', err)
  }
}

function getCurationCount(key: string): number {
  const found = curationGroups.value.find((g) => g.key === key)
  if (found && typeof found.count === 'number') {
    return found.count
  }
  // Fallback count from active list
  return competitions.value.filter((c) => (c.curation_type || 'resmi_negara') === key).length
}

async function fetchCompetitions() {
  loading.value = true
  try {
    const params: Record<string, any> = {
      status: 'published',
    }
    if (searchQuery.value) params.q = searchQuery.value
    if (selectedCategory.value) params.category_id = selectedCategory.value
    if (selectedLevel.value) params.educational_level = selectedLevel.value
    if (selectedScope.value) params.scope = selectedScope.value
    if (selectedCuration.value) params.curation_type = selectedCuration.value
    if (selectedTimeline.value) params.timeline = selectedTimeline.value

    const response = await api.get('/competitions', { params })
    competitions.value = extractList(response.data.data)
  } catch (err) {
    console.error('Error fetching competitions:', err)
  } finally {
    loading.value = false
  }
}

function handleFilter() {
  router.replace({
    query: {
      ...(searchQuery.value ? { q: searchQuery.value } : {}),
      ...(selectedCategory.value ? { category: selectedCategory.value } : {}),
      ...(selectedLevel.value ? { level: selectedLevel.value } : {}),
      ...(selectedScope.value ? { scope: selectedScope.value } : {}),
      ...(selectedCuration.value ? { curation: selectedCuration.value } : {}),
      ...(selectedTimeline.value ? { timeline: selectedTimeline.value } : {}),
    },
  })
  fetchCompetitions()
  fetchCurationGroups()
}

function selectCuration(key: string) {
  if (selectedCuration.value === key) {
    selectedCuration.value = ''
  } else {
    selectedCuration.value = key
  }
  handleFilter()
}

function resetFilters() {
  searchQuery.value = ''
  selectedCategory.value = ''
  selectedLevel.value = ''
  selectedScope.value = ''
  selectedCuration.value = ''
  selectedTimeline.value = ''
  router.replace({ query: {} })
  fetchCompetitions()
  fetchCurationGroups()
}

function formatDate(dateStr: string) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

function getCurationBadge(type: string) {
  switch (type) {
    case 'resmi_negara':
      return {
        label: 'Resmi Negara',
        icon: 'fa-solid fa-shield-halved',
        color: 'bg-blue-50 text-blue-700 border-blue-200',
      }
    case 'terkurasi_puspresnas':
      return {
        label: 'Terkurasi Puspresnas',
        icon: 'fa-solid fa-circle-check',
        color: 'bg-amber-50 text-amber-800 border-amber-200',
      }
    case 'bergengsi_non_kurasi':
      return {
        label: 'Bergengsi Non-Terkurasi',
        icon: 'fa-solid fa-star',
        color: 'bg-purple-50 text-purple-700 border-purple-200',
      }
    default:
      return {
        label: 'Resmi Negara',
        icon: 'fa-solid fa-shield-halved',
        color: 'bg-blue-50 text-blue-700 border-blue-200',
      }
  }
}

onMounted(() => {
  fetchCategories()
  fetchCurationGroups()
  fetchCompetitions()
})

watch(() => route.query.q, (newQ) => {
  if (newQ !== undefined) {
    searchQuery.value = (newQ as string) || ''
    fetchCompetitions()
  }
})

watch(() => route.query.curation, (newC) => {
  if (newC !== undefined) {
    selectedCuration.value = (newC as string) || ''
    fetchCompetitions()
  }
})
</script>

<template>
  <PublicLayout>
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">

      <!-- Hero Header & 3 Curation Tier Cards -->
      <div class="mb-10 text-center">
        <span class="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-brand-blue bg-blue-50 px-3.5 py-1 rounded-full border border-blue-100 mb-3">
          <i class="fa-solid fa-award text-brand-gold"></i>
          Pusat Kurasi & Direktori Prestasi Pelajar
        </span>
        <h1 class="text-3xl sm:text-4xl font-black text-slate-900 tracking-tight">Daftar Kompetisi</h1>
        <p class="text-sm text-slate-500 mt-2 max-w-xl mx-auto leading-relaxed">
          Tiga sumber data dengan tingkat kepercayaan berbeda. Pilih salah satu untuk menyaring daftar lomba.
        </p>

        <!-- 3 Interactive Curation Cards (ProdiPlan Inspired) -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-5 mt-8 text-left">
          
          <!-- Card 1: Resmi Negara -->
          <button
            type="button"
            @click="selectCuration('resmi_negara')"
            :class="[
              'group relative p-6 rounded-3xl border transition-all duration-300 text-left w-full cursor-pointer flex flex-col justify-between shadow-2xs',
              selectedCuration === 'resmi_negara'
                ? 'bg-blue-50/80 border-blue-500 ring-2 ring-blue-500/30 shadow-md scale-[1.02]'
                : 'bg-white border-slate-200/90 hover:border-blue-300 hover:shadow-md'
            ]"
          >
            <div>
              <div class="flex items-center justify-between gap-3 mb-4">
                <div class="w-12 h-12 rounded-2xl bg-blue-100/80 text-blue-700 flex items-center justify-center text-xl group-hover:scale-110 transition-transform shadow-2xs">
                  <i class="fa-solid fa-shield-halved"></i>
                </div>
                <span
                  v-if="selectedCuration === 'resmi_negara'"
                  class="text-[11px] font-bold text-blue-700 bg-blue-100 px-2.5 py-0.5 rounded-full"
                >
                  Aktif Dipilih
                </span>
              </div>
              <h2 class="text-lg font-extrabold text-slate-900 group-hover:text-blue-700 transition-colors">
                Resmi Negara
              </h2>
              <p class="text-xs text-slate-500 mt-1.5 leading-relaxed">
                Ajang resmi berjenjang yang digelar pemerintah dan terkurasi Puspresnas.
              </p>
            </div>
            <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs font-bold text-orange-600">
              <span>{{ getCurationCount('resmi_negara') }} kompetisi</span>
              <span class="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </div>
          </button>

          <!-- Card 2: Terkurasi Puspresnas -->
          <button
            type="button"
            @click="selectCuration('terkurasi_puspresnas')"
            :class="[
              'group relative p-6 rounded-3xl border transition-all duration-300 text-left w-full cursor-pointer flex flex-col justify-between shadow-2xs',
              selectedCuration === 'terkurasi_puspresnas'
                ? 'bg-amber-50/80 border-amber-500 ring-2 ring-amber-500/30 shadow-md scale-[1.02]'
                : 'bg-white border-slate-200/90 hover:border-amber-300 hover:shadow-md'
            ]"
          >
            <div>
              <div class="flex items-center justify-between gap-3 mb-4">
                <div class="w-12 h-12 rounded-2xl bg-amber-100/80 text-amber-700 flex items-center justify-center text-xl group-hover:scale-110 transition-transform shadow-2xs">
                  <i class="fa-solid fa-circle-check"></i>
                </div>
                <span
                  v-if="selectedCuration === 'terkurasi_puspresnas'"
                  class="text-[11px] font-bold text-amber-800 bg-amber-100 px-2.5 py-0.5 rounded-full"
                >
                  Aktif Dipilih
                </span>
              </div>
              <h2 class="text-lg font-extrabold text-slate-900 group-hover:text-amber-700 transition-colors">
                Terkurasi Puspresnas
              </h2>
              <p class="text-xs text-slate-500 mt-1.5 leading-relaxed">
                Sudah lolos kurasi Puspresnas lewat SIMT. Punya rating kurasi dan rincian cabangnya.
              </p>
            </div>
            <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs font-bold text-orange-600">
              <span>{{ getCurationCount('terkurasi_puspresnas') }} kompetisi</span>
              <span class="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </div>
          </button>

          <!-- Card 3: Bergengsi Non-Terkurasi -->
          <button
            type="button"
            @click="selectCuration('bergengsi_non_kurasi')"
            :class="[
              'group relative p-6 rounded-3xl border transition-all duration-300 text-left w-full cursor-pointer flex flex-col justify-between shadow-2xs',
              selectedCuration === 'bergengsi_non_kurasi'
                ? 'bg-purple-50/80 border-purple-500 ring-2 ring-purple-500/30 shadow-md scale-[1.02]'
                : 'bg-white border-slate-200/90 hover:border-purple-300 hover:shadow-md'
            ]"
          >
            <div>
              <div class="flex items-center justify-between gap-3 mb-4">
                <div class="w-12 h-12 rounded-2xl bg-purple-100/80 text-purple-700 flex items-center justify-center text-xl group-hover:scale-110 transition-transform shadow-2xs">
                  <i class="fa-solid fa-star"></i>
                </div>
                <span
                  v-if="selectedCuration === 'bergengsi_non_kurasi'"
                  class="text-[11px] font-bold text-purple-700 bg-purple-100 px-2.5 py-0.5 rounded-full"
                >
                  Aktif Dipilih
                </span>
              </div>
              <h2 class="text-lg font-extrabold text-slate-900 group-hover:text-purple-700 transition-colors">
                Bergengsi Non-Terkurasi
              </h2>
              <p class="text-xs text-slate-500 mt-1.5 leading-relaxed">
                Belum masuk kurasi Puspresnas. Tetap berguna sebagai pengalaman dan pelengkap portofolio.
              </p>
            </div>
            <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs font-bold text-orange-600">
              <span>{{ getCurationCount('bergengsi_non_kurasi') }} kompetisi</span>
              <span class="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </div>
          </button>
        </div>

        <!-- Reset Button If Curation Filter Active -->
        <div v-if="selectedCuration" class="mt-4 flex items-center justify-center gap-2">
          <button
            type="button"
            @click="selectCuration('')"
            class="inline-flex items-center gap-1.5 px-3.5 py-1.5 text-xs font-semibold text-slate-600 bg-white hover:bg-slate-100 border border-slate-200 rounded-full transition-colors cursor-pointer shadow-2xs"
          >
            <i class="fa-solid fa-rotate-left text-[10px]"></i>
            <span>Tampilkan Semua Kategori Kepercayaan</span>
          </button>
        </div>
      </div>

      <!-- Filters & Search Bar -->
      <div class="bg-white rounded-2xl p-4 sm:p-5 border border-slate-200/80 shadow-2xs mb-8">
        <form @submit.prevent="handleFilter" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-6 gap-3">
          <!-- Text Search -->
          <div class="lg:col-span-2 relative">
            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <i class="fa-solid fa-magnifying-glass text-xs"></i>
            </div>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Cari nama lomba, bidang, kampus..."
              class="w-full pl-9 pr-3.5 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 placeholder-slate-400 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            />
          </div>

          <!-- Filter Status Pendaftaran / Waktu Pelaksanaan Lomba -->
          <div>
            <select
              v-model="selectedTimeline"
              @change="handleFilter"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 font-semibold focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            >
              <option value="">Semua Status Pendaftaran</option>
              <option value="open">🟢 Pendaftaran Sudah Dibuka</option>
              <option value="not_started">⏳ Pendaftaran Belum Dibuka</option>
              <option value="completed">🏁 Lomba Sudah Terlaksana</option>
            </select>
          </div>

          <!-- Curation Select -->
          <div>
            <select
              v-model="selectedCuration"
              @change="handleFilter"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            >
              <option value="">Semua Kepercayaan</option>
              <option value="resmi_negara">🛡️ Resmi Negara</option>
              <option value="terkurasi_puspresnas">🏅 Terkurasi Puspresnas</option>
              <option value="bergengsi_non_kurasi">⭐ Bergengsi Non-Kurasi</option>
            </select>
          </div>

          <!-- Category Select -->
          <div>
            <select
              v-model="selectedCategory"
              @change="handleFilter"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            >
              <option value="">Semua Bidang</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                {{ cat.name }}
              </option>
            </select>
          </div>

          <!-- Scope & Reset -->
          <div class="flex items-center gap-2">
            <select
              v-model="selectedScope"
              @change="handleFilter"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            >
              <option value="">Semua Wilayah</option>
              <option value="nasional">Nasional</option>
              <option value="provinsi">Provinsi</option>
            </select>
            <button
              type="button"
              @click="resetFilters"
              class="px-3 py-2 text-xs font-semibold text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-colors shrink-0 cursor-pointer"
              title="Reset Filter"
            >
              <i class="fa-solid fa-rotate-left"></i>
            </button>
          </div>
        </form>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 6" :key="i" class="bg-white rounded-2xl p-6 border border-slate-200 animate-pulse space-y-4">
          <div class="h-4 bg-slate-200 rounded-md w-1/3"></div>
          <div class="h-6 bg-slate-200 rounded-md w-3/4"></div>
          <div class="h-20 bg-slate-100 rounded-md"></div>
        </div>
      </div>

      <!-- Competitions Grid -->
      <div v-else-if="competitions.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="comp in competitions"
          :key="comp.id"
          class="bg-white rounded-3xl p-6 border border-slate-200/80 card-hover flex flex-col justify-between shadow-2xs group"
        >
          <div>
            <!-- Tags & Curation Badges -->
            <div class="flex items-center justify-between gap-2 mb-3">
              <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-md">
                <i class="fa-solid fa-tag text-[9px]"></i>
                {{ comp.category?.name || 'Kompetisi' }}
              </span>

              <!-- Curation Tier Badge -->
              <span
                class="inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-0.5 rounded-full border shadow-2xs"
                :class="getCurationBadge(comp.curation_type || 'resmi_negara').color"
              >
                <i :class="getCurationBadge(comp.curation_type || 'resmi_negara').icon" class="text-[9px]"></i>
                <span>{{ getCurationBadge(comp.curation_type || 'resmi_negara').label }}</span>
                <span v-if="comp.curation_rating" class="ml-0.5 opacity-80 text-[9px]">
                  • {{ comp.curation_rating }}
                </span>
              </span>
            </div>

            <!-- Title -->
            <h2 class="text-base font-bold text-slate-900 leading-snug line-clamp-2 group-hover:text-brand-blue transition-colors">
              <router-link :to="`/competitions/${comp.slug || comp.id}`">
                {{ comp.title || comp.name }}
              </router-link>
            </h2>

            <!-- Organizer -->
            <p class="text-xs text-slate-500 mt-2 flex items-center gap-1.5">
              <i class="fa-solid fa-building-columns text-[10px] text-slate-400"></i>
              <span class="truncate">{{ comp.organizer?.name || 'Penyelenggara Resmi' }}</span>
            </p>

            <!-- Description -->
            <p class="text-xs text-slate-600 mt-3 line-clamp-3 leading-relaxed">
              {{ comp.description || 'Kompetisi terverifikasi dengan informasi dan juknis resmi.' }}
            </p>
          </div>

          <!-- Card Bottom Meta -->
          <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between">
            <div class="text-[11px] text-slate-500">
              <p class="font-medium text-slate-700 flex items-center gap-1">
                <i class="fa-regular fa-calendar-check text-brand-gold"></i>
                Batas: {{ formatDate(comp.registration_deadline) }}
              </p>
              <p class="text-[10px] uppercase text-slate-400 mt-0.5">
                {{ comp.level || comp.scope || 'Nasional' }} • {{ (comp.target_level || comp.educational_level || 'SLTA').toUpperCase() }}
              </p>
            </div>

            <router-link
              :to="`/competitions/${comp.slug || comp.id}`"
              class="px-4 py-2 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl transition-all shadow-xs"
            >
              Lihat Detail
            </router-link>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-16 bg-white rounded-3xl border border-slate-200">
        <div class="w-16 h-16 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center text-2xl mx-auto mb-4">
          <i class="fa-solid fa-filter-circle-xmark"></i>
        </div>
        <h3 class="text-base font-bold text-slate-800">Tidak Ada Kompetisi Ditemukan</h3>
        <p class="text-xs text-slate-500 max-w-sm mx-auto mt-1 mb-5">
          Tidak ada hasil yang cocok dengan kriteria filter kurasi Anda. Silakan coba atur ulang filter.
        </p>
        <button
          type="button"
          @click="resetFilters"
          class="px-4 py-2 bg-brand-navy text-white text-xs font-bold rounded-xl shadow-xs cursor-pointer"
        >
          Reset Semua Filter
        </button>
      </div>
    </div>
  </PublicLayout>
</template>
