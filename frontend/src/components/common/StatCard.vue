<script setup lang="ts">
withDefaults(
  defineProps<{
    title: string
    value: string | number
    icon: string
    subtitle?: string
    trend?: string
    trendPositive?: boolean
    variant?: 'navy' | 'blue' | 'gold' | 'emerald' | 'slate'
  }>(),
  {
    variant: 'navy',
  }
)
</script>

<template>
  <div class="bg-white rounded-2xl p-5 border border-slate-100 shadow-xs hover:shadow-md transition-all duration-200 flex flex-col justify-between">
    <div class="flex items-start justify-between">
      <div>
        <p class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">{{ title }}</p>
        <h3 class="text-2xl lg:text-3xl font-extrabold text-slate-800 tracking-tight">{{ value }}</h3>
      </div>
      <div
        :class="[
          'w-11 h-11 rounded-xl flex items-center justify-center text-lg transition-transform hover:scale-105',
          variant === 'navy' ? 'bg-[#001D60]/10 text-brand-navy' :
          variant === 'blue' ? 'bg-[#1062A7]/10 text-brand-blue' :
          variant === 'gold' ? 'bg-[#F8B700]/15 text-amber-700' :
          variant === 'emerald' ? 'bg-emerald-50 text-emerald-600' :
          'bg-slate-100 text-slate-600'
        ]"
      >
        <i :class="icon"></i>
      </div>
    </div>

    <div v-if="subtitle || trend" class="mt-4 pt-3 border-t border-slate-50 flex items-center justify-between text-xs">
      <span v-if="subtitle" class="text-slate-500 font-medium">{{ subtitle }}</span>
      <span
        v-if="trend"
        :class="[
          'inline-flex items-center gap-1 font-semibold',
          trendPositive ? 'text-emerald-600' : 'text-slate-500'
        ]"
      >
        <i v-if="trendPositive" class="fa-solid fa-arrow-trend-up text-[10px]"></i>
        {{ trend }}
      </span>
    </div>
  </div>
</template>
