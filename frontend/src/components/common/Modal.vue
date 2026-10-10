<script setup lang="ts">
import { watch } from 'vue'

const props = withDefaults(
  defineProps<{
    modelValue: boolean
    title?: string
    subtitle?: string
    size?: 'sm' | 'md' | 'lg' | 'xl' | '2xl'
  }>(),
  {
    size: 'lg',
  }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
  (e: 'close'): void
}>()

function close() {
  emit('update:modelValue', false)
  emit('close')
}

watch(
  () => props.modelValue,
  (val) => {
    if (val) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
  }
)
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-pop">
      <div
        v-if="modelValue"
        class="fixed inset-0 z-50 overflow-y-auto"
        aria-labelledby="modal-title"
        role="dialog"
        aria-modal="true"
      >
        <!-- Backdrop -->
        <div
          class="fixed inset-0 bg-[#001D60]/40 transition-opacity"
          @click="close"
        ></div>

        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
          <div
            :class="[
              'relative transform overflow-hidden rounded-2xl bg-white text-left shadow-2xl transition-all sm:my-8 w-full border border-slate-100 modal-card-box',
              size === 'sm' ? 'sm:max-w-md' :
              size === 'md' ? 'sm:max-w-lg' :
              size === 'lg' ? 'sm:max-w-2xl' :
              size === 'xl' ? 'sm:max-w-4xl' : 'sm:max-w-5xl'
            ]"
          >
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50/50">
              <div>
                <h3 id="modal-title" class="text-lg font-bold text-slate-900 flex items-center gap-2">
                  <slot name="title-icon"></slot>
                  {{ title }}
                </h3>
                <p v-if="subtitle" class="text-xs text-slate-500 mt-0.5">{{ subtitle }}</p>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
                @click="close"
              >
                <i class="fa-solid fa-xmark text-lg"></i>
              </button>
            </div>

            <!-- Body -->
            <div class="px-6 py-5 max-h-[75vh] overflow-y-auto">
              <slot></slot>
            </div>

            <!-- Footer -->
            <div v-if="$slots.footer" class="px-6 py-4 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-2">
              <slot name="footer"></slot>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>
