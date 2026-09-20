<script setup lang="ts">
import { ref, computed, watch, nextTick, onMounted, onUnmounted } from 'vue'

export interface SelectOption {
  value: any
  label: string
  sublabel?: string
  badge?: string
  badgeColor?: string
  icon?: string
}

const props = withDefaults(
  defineProps<{
    modelValue: any
    options: SelectOption[]
    placeholder?: string
    searchPlaceholder?: string
    required?: boolean
    disabled?: boolean
    clearable?: boolean
    label?: string
    id?: string
  }>(),
  {
    placeholder: 'Pilih...',
    searchPlaceholder: 'Cari data...',
    required: false,
    disabled: false,
    clearable: true,
  }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: any): void
  (e: 'change', value: any): void
}>()

const isOpen = ref(false)
const searchQuery = ref('')
const containerRef = ref<HTMLElement | null>(null)
const searchInputRef = ref<HTMLInputElement | null>(null)
const highlightedIndex = ref(0)

const selectedOption = computed(() => {
  return props.options.find(opt => String(opt.value) === String(props.modelValue)) || null
})

const filteredOptions = computed(() => {
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return props.options

  return props.options.filter(opt => {
    const labelMatch = opt.label.toLowerCase().includes(q)
    const sublabelMatch = opt.sublabel ? opt.sublabel.toLowerCase().includes(q) : false
    const badgeMatch = opt.badge ? opt.badge.toLowerCase().includes(q) : false
    return labelMatch || sublabelMatch || badgeMatch
  })
})

function toggleDropdown() {
  if (props.disabled) return
  if (isOpen.value) {
    closeDropdown()
  } else {
    openDropdown()
  }
}

function openDropdown() {
  isOpen.value = true
  searchQuery.value = ''
  highlightedIndex.value = 0
  nextTick(() => {
    searchInputRef.value?.focus()
  })
}

function closeDropdown() {
  isOpen.value = false
  searchQuery.value = ''
}

function selectOption(opt: SelectOption) {
  emit('update:modelValue', opt.value)
  emit('change', opt.value)
  closeDropdown()
}

function clearSelection(e: MouseEvent) {
  e.stopPropagation()
  emit('update:modelValue', null)
  emit('change', null)
}

function handleKeydown(e: KeyboardEvent) {
  if (!isOpen.value) {
    if (e.key === 'Enter' || e.key === ' ' || e.key === 'ArrowDown') {
      e.preventDefault()
      openDropdown()
    }
    return
  }

  if (e.key === 'Escape') {
    e.preventDefault()
    closeDropdown()
  } else if (e.key === 'ArrowDown') {
    e.preventDefault()
    if (highlightedIndex.value < filteredOptions.value.length - 1) {
      highlightedIndex.value++
    }
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    if (highlightedIndex.value > 0) {
      highlightedIndex.value--
    }
  } else if (e.key === 'Enter') {
    e.preventDefault()
    if (filteredOptions.value[highlightedIndex.value]) {
      selectOption(filteredOptions.value[highlightedIndex.value])
    }
  }
}

function handleClickOutside(e: MouseEvent) {
  if (containerRef.value && !containerRef.value.contains(e.target as Node)) {
    closeDropdown()
  }
}

watch(filteredOptions, () => {
  highlightedIndex.value = 0
})

onMounted(() => {
  document.addEventListener('mousedown', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('mousedown', handleClickOutside)
})
</script>

<template>
  <div ref="containerRef" class="relative w-full text-xs select-none">
    <!-- Optional Label -->
    <label
      v-if="label"
      :for="id"
      class="block font-semibold text-slate-700 mb-1"
    >
      {{ label }}
      <span v-if="required" class="text-rose-500">*</span>
    </label>

    <!-- Trigger Box -->
    <button
      :id="id"
      type="button"
      @click="toggleDropdown"
      @keydown="handleKeydown"
      :disabled="disabled"
      class="w-full text-left px-3.5 py-2.5 bg-slate-50 hover:bg-slate-100/70 border border-slate-200 rounded-xl transition-all flex items-center justify-between gap-2 focus:outline-hidden focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/15"
      :class="[
        disabled ? 'opacity-60 cursor-not-allowed bg-slate-100' : 'cursor-pointer',
        isOpen ? 'border-brand-blue ring-2 ring-brand-blue/15 bg-white' : ''
      ]"
      aria-haspopup="listbox"
      :aria-expanded="isOpen"
    >
      <div class="flex-1 min-w-0 pr-1">
        <template v-if="selectedOption">
          <div class="flex items-center gap-2 flex-wrap">
            <span class="font-bold text-slate-900 truncate">
              {{ selectedOption.label }}
            </span>
            <span
              v-if="selectedOption.badge"
              class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-blue-50 text-brand-blue border border-blue-200"
            >
              {{ selectedOption.badge }}
            </span>
          </div>
          <p v-if="selectedOption.sublabel" class="text-[11px] text-slate-500 truncate mt-0.5">
            {{ selectedOption.sublabel }}
          </p>
        </template>
        <template v-else>
          <span class="text-slate-400 font-normal">
            {{ placeholder }}
          </span>
        </template>
      </div>

      <!-- Right Controls -->
      <div class="flex items-center gap-1.5 shrink-0 text-slate-400">
        <button
          v-if="clearable && selectedOption && !disabled"
          type="button"
          @click="clearSelection"
          class="p-1 rounded-md hover:text-slate-600 hover:bg-slate-200/60 transition-colors"
          title="Hapus Pilihan"
        >
          <i class="fa-solid fa-xmark text-xs"></i>
        </button>
        <i
          class="fa-solid fa-chevron-down text-[10px] transition-transform duration-200"
          :class="{ 'rotate-180 text-brand-blue': isOpen }"
        ></i>
      </div>
    </button>

    <!-- Hidden native input for form validation if required -->
    <input
      v-if="required"
      type="text"
      tabindex="-1"
      class="opacity-0 absolute inset-0 pointer-events-none w-full h-full"
      :value="modelValue || ''"
      required
    />

    <!-- Dropdown Floating Panel -->
    <Transition
      enter-active-class="transition duration-150 ease-out"
      enter-from-class="opacity-0 scale-95 translate-y-[-4px]"
      enter-to-class="opacity-100 scale-100 translate-y-0"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="opacity-100 scale-100 translate-y-0"
      leave-to-class="opacity-0 scale-95 translate-y-[-4px]"
    >
      <div
        v-if="isOpen"
        class="absolute left-0 right-0 z-50 mt-1.5 bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col max-h-72"
        role="listbox"
      >
        <!-- Search Input Bar -->
        <div class="p-2.5 bg-slate-50/90 border-b border-slate-100 shrink-0 relative">
          <div class="relative flex items-center">
            <i class="fa-solid fa-magnifying-glass absolute left-3 text-slate-400 text-xs pointer-events-none"></i>
            <input
              ref="searchInputRef"
              v-model="searchQuery"
              type="text"
              :placeholder="searchPlaceholder"
              @keydown="handleKeydown"
              class="w-full pl-8 pr-8 py-2 bg-white border border-slate-200 rounded-xl text-xs text-slate-800 placeholder-slate-400 focus:outline-hidden focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/15"
            />
            <button
              v-if="searchQuery"
              type="button"
              @click="searchQuery = ''; searchInputRef?.focus()"
              class="absolute right-2.5 text-slate-400 hover:text-slate-600 p-1 text-xs"
            >
              <i class="fa-solid fa-xmark"></i>
            </button>
          </div>
          <div v-if="filteredOptions.length > 0" class="flex items-center justify-between px-1 mt-1 text-[10px] text-slate-400">
            <span>Ditemukan {{ filteredOptions.length }} pilihan</span>
            <span class="italic">Tekan Enter untuk memilih</span>
          </div>
        </div>

        <!-- Options List -->
        <div class="overflow-y-auto flex-1 p-1.5 divide-y divide-slate-50 space-y-0.5">
          <div
            v-if="filteredOptions.length === 0"
            class="py-8 px-4 text-center text-slate-400"
          >
            <i class="fa-solid fa-magnifying-glass text-2xl text-slate-300 mb-2 block"></i>
            <p class="font-semibold text-xs text-slate-600">Tidak ada hasil yang cocok</p>
            <p class="text-[11px] text-slate-400 mt-0.5">Coba gunakan kata kunci nama atau nomor lain.</p>
          </div>

          <div
            v-for="(opt, idx) in filteredOptions"
            :key="opt.value"
            @click="selectOption(opt)"
            @mouseenter="highlightedIndex = idx"
            class="px-3 py-2.5 rounded-xl cursor-pointer transition-colors flex items-center justify-between gap-3"
            :class="[
              String(opt.value) === String(modelValue)
                ? 'bg-blue-50/90 text-brand-navy font-bold'
                : highlightedIndex === idx
                  ? 'bg-slate-100/80 text-slate-900'
                  : 'text-slate-700 hover:bg-slate-50'
            ]"
            role="option"
            :aria-selected="String(opt.value) === String(modelValue)"
          >
            <div class="min-w-0 flex-1">
              <div class="flex items-center gap-2">
                <span class="text-xs truncate" :class="String(opt.value) === String(modelValue) ? 'font-bold text-brand-navy' : 'font-semibold'">
                  {{ opt.label }}
                </span>
                <span
                  v-if="opt.badge"
                  class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600 border border-slate-200"
                >
                  {{ opt.badge }}
                </span>
              </div>
              <p v-if="opt.sublabel" class="text-[11px] text-slate-400 truncate mt-0.5 font-normal">
                {{ opt.sublabel }}
              </p>
            </div>

            <!-- Checkmark -->
            <div
              v-if="String(opt.value) === String(modelValue)"
              class="w-5 h-5 rounded-full bg-brand-navy text-white flex items-center justify-center shrink-0 text-[10px]"
            >
              <i class="fa-solid fa-check"></i>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>
