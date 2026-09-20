import { ref, reactive } from 'vue'

export type ToastType = 'success' | 'error' | 'warning' | 'info'

export interface ToastItem {
  id: string
  type: ToastType
  title?: string
  message: string
  duration: number
  createdAt: number
}

export interface ConfirmOptions {
  title?: string
  message: string
  type?: 'info' | 'warning' | 'danger' | 'success'
  confirmText?: string
  cancelText?: string
}

// Global reactive state
const toasts = ref<ToastItem[]>([])

const confirmState = reactive<{
  isOpen: boolean
  title: string
  message: string
  type: 'info' | 'warning' | 'danger' | 'success'
  confirmText: string
  cancelText: string
  resolve: ((val: boolean) => void) | null
}>({
  isOpen: false,
  title: '',
  message: '',
  type: 'warning',
  confirmText: 'Lanjutkan',
  cancelText: 'Batal',
  resolve: null,
})

let toastCounter = 0

function showToast(message: string, type: ToastType = 'info', title?: string, duration: number = 4000) {
  const id = `toast-${Date.now()}-${++toastCounter}`
  const defaultTitles: Record<ToastType, string> = {
    success: 'Berhasil',
    error: 'Terjadi Kesalahan',
    warning: 'Peringatan',
    info: 'Informasi',
  }

  const toastItem: ToastItem = {
    id,
    type,
    title: title || defaultTitles[type],
    message,
    duration,
    createdAt: Date.now(),
  }

  toasts.value.push(toastItem)

  if (duration > 0) {
    setTimeout(() => {
      removeToast(id)
    }, duration)
  }

  return id
}

function removeToast(id: string) {
  const index = toasts.value.findIndex(t => t.id === id)
  if (index !== -1) {
    toasts.value.splice(index, 1)
  }
}

function confirm(options: ConfirmOptions): Promise<boolean> {
  return new Promise((resolve) => {
    confirmState.isOpen = true
    confirmState.title = options.title || 'Konfirmasi Tindakan'
    confirmState.message = options.message
    confirmState.type = options.type || 'warning'
    confirmState.confirmText = options.confirmText || 'Lanjutkan'
    confirmState.cancelText = options.cancelText || 'Batal'
    confirmState.resolve = resolve
  })
}

function handleConfirmResult(result: boolean) {
  confirmState.isOpen = false
  if (confirmState.resolve) {
    confirmState.resolve(result)
    confirmState.resolve = null
  }
}

export function useNotify() {
  return {
    toasts,
    confirmState,
    toast: {
      success: (message: string, title?: string, duration?: number) => showToast(message, 'success', title, duration),
      error: (message: string, title?: string, duration?: number) => showToast(message, 'error', title, duration),
      warning: (message: string, title?: string, duration?: number) => showToast(message, 'warning', title, duration),
      info: (message: string, title?: string, duration?: number) => showToast(message, 'info', title, duration),
      remove: removeToast,
    },
    confirm,
    handleConfirmResult,
  }
}

export default useNotify
