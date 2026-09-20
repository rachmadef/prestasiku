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
const loading = ref(true)

const searchQuery = ref((route.query.q as string) || '')
const selectedCategory = ref((route.query.category as string) || '')
const selectedLevel = ref((route.query.level as string) || '')
const selectedScope = ref((route.query.scope as string) || '')

async function fetchCategories() {
  try {
    const response = await api.get('/categories')
    categories.value = extractList(response.data.data)
  } catch (err) {
    console.error('Error loading categories:', err)
  }
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
    },
  })
  fetchCompetitions()
}

function resetFilters() {
  searchQuery.value = ''
  selectedCategory.value = ''
  selectedLevel.value = ''
  selectedScope.value = ''
  router.replace({ query: {} })
  fetchCompetitions()
}

function formatDate(dateStr: string) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

onMounted(() => {
  fetchCategories()
  fetchCompetitions()
})

watch(() => route.query.q, (newQ) => {
  if (newQ !== undefined) {
    searchQuery.value = (newQ as string) || ''
    fetchCompetitions()
  }
})
</script>

<template>
  <PublicLayout>
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <!-- Header -->
      <div class="mb-8">
        <span class="inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider text-brand-blue mb-1">
          <i class="fa-solid fa-trophy text-brand-gold"></i>
          Verified Competition Directory
        </span>
        <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">Katalog Kompetisi Pelajar</h1>
        <p class="text-sm text-slate-600 mt-1 max-w-2xl">
          Eksplorasi seluruh kompetisi resmi tingkat provinsi dan nasional yang telah terverifikasi keaslian sumber dan informasinya.
        </p>
      </div>

      <!-- Filters & Search Bar -->
      <div class="bg-white rounded-2xl p-4 sm:p-5 border border-slate-200/80 shadow-2xs mb-8">
        <form @submit.prevent="handleFilter" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
          <!-- Text Search -->
          <div class="lg:col-span-2 relative">
            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <i class="fa-solid fa-magnifying-glass text-xs"></i>
            </div>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Cari nama kompetisi, bidang, penyelenggara..."
              class="w-full pl-9 pr-3.5 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 placeholder-slate-400 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            />
          </div>

          <!-- Category Select -->
          <div>
            <select
              v-model="selectedCategory"
              @change="handleFilter"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            >
              <option value="">Semua Kategori</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                {{ cat.name }}
              </option>
            </select>
          </div>

          <!-- Level Select -->
          <div>
            <select
              v-model="selectedLevel"
              @change="handleFilter"
              class="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-800 focus:outline-hidden focus:border-brand-blue focus:bg-white transition-colors"
            >
              <option value="">Semua Jenjang</option>
              <option value="sltp">SLTP / SMP / MTs</option>
              <option value="slta">SLTA / SMA / SMK / MA</option>
            </select>
          </div>

          <!-- Scope Select -->
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
              class="px-3 py-2 text-xs font-semibold text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-colors shrink-0"
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
          class="bg-white rounded-2xl p-6 border border-slate-200/80 card-hover flex flex-col justify-between shadow-2xs"
        >
          <div>
            <!-- Tags & Badges -->
            <div class="flex items-center justify-between gap-2 mb-3">
              <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-brand-blue bg-blue-50 px-2.5 py-0.5 rounded-md">
                <i class="fa-solid fa-tag text-[9px]"></i>
                {{ comp.category?.name || 'Kompetisi' }}
              </span>
              <Badge :status="comp.verification_status || 'verified'" />
            </div>

            <!-- Title -->
            <h2 class="text-base font-bold text-slate-900 leading-snug line-clamp-2 hover:text-brand-blue transition-colors">
              <router-link :to="`/competitions/${comp.slug || comp.id}`">
                {{ comp.name || comp.title }}
              </router-link>
            </h2>

            <!-- Organizer -->
            <p class="text-xs text-slate-500 mt-2 flex items-center gap-1.5">
              <i class="fa-solid fa-building-columns text-[10px] text-slate-400"></i>
              <span>{{ comp.organizer?.name || 'Penyelenggara Resmi' }}</span>
            </p>

            <!-- Description -->
            <p class="text-xs text-slate-600 mt-3 line-clamp-3 leading-relaxed">
              {{ comp.description || 'Kompetisi resmi berstandar nasional dengan sertifikasi kredibel.' }}
            </p>
          </div>

          <!-- Card Bottom Meta -->
          <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between">
            <div class="text-[11px] text-slate-500">
              <p class="font-medium text-slate-700 flex items-center gap-1">
                <i class="fa-regular fa-calendar-check text-brand-gold"></i>
                Batas: {{ formatDate(comp.registration_deadline) }}
              </p>
              <p class="text-[10px] uppercase text-slate-400">{{ comp.scope || 'Nasional' }} • {{ comp.educational_level?.toUpperCase() || 'SLTA' }}</p>
            </div>

            <router-link
              :to="`/competitions/${comp.slug || comp.id}`"
              class="px-4 py-1.5 bg-brand-navy hover:bg-[#001442] text-white text-xs font-bold rounded-xl transition-all shadow-xs"
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
          Tidak ada hasil yang cocok dengan kriteria pencarian Anda. Silakan coba atur ulang filter.
        </p>
        <button
          type="button"
          @click="resetFilters"
          class="px-4 py-2 bg-brand-navy text-white text-xs font-bold rounded-xl shadow-xs"
        >
          Reset Semua Filter
        </button>
      </div>
    </div>
  </PublicLayout>
</template>
