<script setup lang="ts">
import { watch, onMounted, onUnmounted } from 'vue'
import { useNotify } from '@/composables/useNotify'

const { confirmState, handleConfirmResult } = useNotify()

function onKeyDown(e: KeyboardEvent) {
  if (confirmState.isOpen && e.key === 'Escape') {
    handleConfirmResult(false)
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeyDown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', onKeyDown)
})

// Prevent background scroll when modal open
watch(() => confirmState.isOpen, (open) => {
  if (open) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})

function getHeaderIcon(type: string) {
  switch (type) {
    case 'danger':
      return 'fa-solid fa-triangle-exclamation text-rose-500'
    case 'warning':
      return 'fa-solid fa-circle-exclamation text-amber-500'
    case 'success':
      return 'fa-solid fa-circle-check text-emerald-500'
    case 'info':
    default:
      return 'fa-solid fa-circle-info text-brand-blue'
  }
}

function getHeaderBadgeBg(type: string) {
  switch (type) {
    case 'danger':
      return 'bg-rose-50 border-rose-200'
    case 'warning':
      return 'bg-amber-50 border-amber-200'
    case 'success':
      return 'bg-emerald-50 border-emerald-200'
    case 'info':
    default:
      return 'bg-blue-50 border-blue-200'
  }
}

function getConfirmButtonClass(type: string) {
  switch (type) {
    case 'danger':
      return 'bg-rose-600 hover:bg-rose-700 text-white shadow-rose-600/20'
    case 'warning':
      return 'bg-amber-500 hover:bg-amber-600 text-white shadow-amber-500/20'
    case 'success':
      return 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-emerald-600/20'
    case 'info':
    default:
      return 'bg-brand-navy hover:bg-brand-blue text-white shadow-brand-navy/20'
  }
}
</script>

<template>
  <Transition
    enter-active-class="transition duration-200 ease-out"
    enter-from-class="opacity-0"
    enter-to-class="opacity-100"
    leave-active-class="transition duration-150 ease-in"
    leave-from-class="opacity-100"
    leave-to-class="opacity-0"
  >
    <div
      v-if="confirmState.isOpen"
      class="fixed inset-0 z-[100000] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs"
      @click.self="handleConfirmResult(false)"
    >
      <div
        class="bg-white rounded-3xl max-w-md w-full shadow-2xl border border-slate-200/80 overflow-hidden transform transition-all animate-[modalPop_0.25s_cubic-bezier(0.16,1,0.3,1)]"
        role="dialog"
        aria-modal="true"
      >
        <div class="p-6 sm:p-7 text-center">
          <!-- Icon Badge -->
          <div
            class="mx-auto w-14 h-14 rounded-2xl flex items-center justify-center border shadow-xs mb-4"
            :class="getHeaderBadgeBg(confirmState.type)"
          >
            <i :class="[getHeaderIcon(confirmState.type), 'text-2xl']"></i>
          </div>

          <!-- Title -->
          <h3 class="text-base sm:text-lg font-black text-slate-900 tracking-tight">
            {{ confirmState.title }}
          </h3>

          <!-- Message -->
          <p class="text-xs sm:text-sm text-slate-600 mt-2 leading-relaxed">
            {{ confirmState.message }}
          </p>

          <!-- Buttons Action -->
          <div class="mt-6 flex items-center gap-3">
            <button
              type="button"
              @click="handleConfirmResult(false)"
              class="flex-1 py-2.5 px-4 rounded-xl border border-slate-200 text-xs font-bold text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer"
            >
              {{ confirmState.cancelText }}
            </button>
            <button
              type="button"
              @click="handleConfirmResult(true)"
              class="flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all shadow-md cursor-pointer"
              :class="getConfirmButtonClass(confirmState.type)"
            >
              {{ confirmState.confirmText }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style>
@keyframes modalPop {
  0% {
    opacity: 0;
    transform: scale(0.92);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}
</style>
