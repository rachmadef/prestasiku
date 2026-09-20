<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    status: string
    size?: 'sm' | 'md' | 'lg'
  }>(),
  {
    size: 'sm',
  }
)

const statusConfig = computed(() => {
  const s = props.status?.toLowerCase() || ''

  if (s === 'verified' || s === 'published' || s === 'approved' || s === 'active' || s === 'completed') {
    return {
      bg: 'bg-emerald-50 text-emerald-700 border-emerald-200',
      icon: 'fa-solid fa-circle-check',
      label: props.status === 'verified' ? 'Terverifikasi' :
             props.status === 'published' ? 'Dipublikasikan' :
             props.status === 'approved' ? 'Disetujui' :
             props.status === 'active' ? 'Aktif' : props.status,
    }
  }

  if (s === 'verified_source' || s === 'in_review' || s === 'pending' || s === 'submitted') {
    return {
      bg: 'bg-blue-50 text-brand-blue border-blue-200',
      icon: 'fa-solid fa-clock',
      label: props.status === 'verified_source' ? 'Sumber Terverifikasi' :
             props.status === 'in_review' ? 'Dalam Peninjauan' :
             props.status === 'pending' ? 'Menunggu' :
             props.status === 'submitted' ? 'Diajukan' : props.status,
    }
  }

  if (s === 'draft') {
    return {
      bg: 'bg-slate-100 text-slate-700 border-slate-200',
      icon: 'fa-solid fa-file-lines',
      label: 'Draft',
    }
  }

  if (s === 'rejected' || s === 'suspended' || s === 'cancelled') {
    return {
      bg: 'bg-rose-50 text-rose-700 border-rose-200',
      icon: 'fa-solid fa-circle-xmark',
      label: props.status === 'rejected' ? 'Ditolak' :
             props.status === 'suspended' ? 'Ditangguhkan' :
             props.status === 'cancelled' ? 'Dibatalkan' : props.status,
    }
  }

  if (s === 'expired') {
    return {
      bg: 'bg-amber-50 text-amber-800 border-amber-200',
      icon: 'fa-solid fa-hourglass-end',
      label: 'Kedaluwarsa',
    }
  }

  return {
    bg: 'bg-slate-50 text-slate-600 border-slate-200',
    icon: 'fa-solid fa-circle-info',
    label: props.status,
  }
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'lg':
      return 'text-sm px-3 py-1 gap-1.5'
    case 'md':
      return 'text-xs px-2.5 py-0.5 gap-1.5'
    case 'sm':
    default:
      return 'text-[11px] px-2 py-0.5 gap-1 font-medium'
  }
})
</script>

<template>
  <span
    :class="[
      'inline-flex items-center rounded-full border shadow-2xs transition-colors font-medium',
      statusConfig.bg,
      sizeClasses,
    ]"
  >
    <i :class="[statusConfig.icon, 'text-[0.9em]']"></i>
    <span>{{ statusConfig.label }}</span>
  </span>
</template>
