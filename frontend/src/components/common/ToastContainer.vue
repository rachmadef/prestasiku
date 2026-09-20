<script setup lang="ts">
import { useNotify, type ToastItem } from '@/composables/useNotify'

const { toasts, toast } = useNotify()

function getIconClass(type: string) {
  switch (type) {
    case 'success':
      return 'fa-solid fa-circle-check text-emerald-500'
    case 'error':
      return 'fa-solid fa-circle-xmark text-rose-500'
    case 'warning':
      return 'fa-solid fa-triangle-exclamation text-amber-500'
    case 'info':
    default:
      return 'fa-solid fa-circle-info text-brand-blue'
  }
}

function getBadgeBg(type: string) {
  switch (type) {
    case 'success':
      return 'bg-emerald-50 border-emerald-200/60'
    case 'error':
      return 'bg-rose-50 border-rose-200/60'
    case 'warning':
      return 'bg-amber-50 border-amber-200/60'
    case 'info':
    default:
      return 'bg-blue-50 border-blue-200/60'
  }
}

function getBorderAccent(type: string) {
  switch (type) {
    case 'success':
      return 'border-emerald-500/30'
    case 'error':
      return 'border-rose-500/30'
    case 'warning':
      return 'border-amber-500/30'
    case 'info':
    default:
      return 'border-brand-blue/30'
  }
}

function getProgressBg(type: string) {
  switch (type) {
    case 'success':
      return 'bg-emerald-500'
    case 'error':
      return 'bg-rose-500'
    case 'warning':
      return 'bg-amber-500'
    case 'info':
    default:
      return 'bg-brand-blue'
  }
}
</script>

<template>
  <div
    class="fixed top-5 right-5 z-[99999] flex flex-col gap-3 pointer-events-none max-w-sm sm:max-w-md w-full px-4 sm:px-0"
    aria-live="polite"
  >
    <TransitionGroup
      enter-active-class="transform ease-out duration-300 transition"
      enter-from-class="translate-y-[-12px] opacity-0 sm:translate-x-4 scale-95"
      enter-to-class="translate-y-0 opacity-100 sm:translate-x-0 scale-100"
      leave-active-class="transition ease-in duration-200"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-90 translate-x-4"
    >
      <div
        v-for="item in toasts"
        :key="item.id"
        class="pointer-events-auto relative overflow-hidden bg-white/95 backdrop-blur-md rounded-2xl shadow-xl shadow-slate-900/10 border transition-all hover:shadow-2xl"
        :class="getBorderAccent(item.type)"
        role="alert"
      >
        <div class="p-4 flex items-start gap-3.5">
          <!-- Icon Badge -->
          <div
            class="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 border"
            :class="getBadgeBg(item.type)"
          >
            <i :class="[getIconClass(item.type), 'text-lg']"></i>
          </div>

          <!-- Text Body -->
          <div class="flex-1 min-w-0 pt-0.5">
            <h4 class="text-xs sm:text-sm font-bold text-slate-900 leading-tight">
              {{ item.title }}
            </h4>
            <p class="text-xs text-slate-600 mt-1 leading-relaxed break-words font-normal">
              {{ item.message }}
            </p>
          </div>

          <!-- Close Button -->
          <button
            type="button"
            @click="toast.remove(item.id)"
            class="text-slate-400 hover:text-slate-700 p-1 rounded-lg hover:bg-slate-100 transition-colors shrink-0 -mr-1 -mt-1 cursor-pointer"
            aria-label="Tutup Notifikasi"
          >
            <i class="fa-solid fa-xmark text-sm"></i>
          </button>
        </div>

        <!-- Progress Bar Auto Dismiss -->
        <div
          v-if="item.duration > 0"
          class="h-1 w-full bg-slate-100 overflow-hidden"
        >
          <div
            class="h-full origin-left animate-[toastProgress_linear_forwards]"
            :class="getProgressBg(item.type)"
            :style="{ animationDuration: `${item.duration}ms` }"
          ></div>
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<style>
@keyframes toastProgress {
  from {
    width: 100%;
  }
  to {
    width: 0%;
  }
}
</style>
