<script setup lang="ts">
import { ref, watch, onBeforeUnmount, nextTick } from 'vue'
import { Html5Qrcode, Html5QrcodeSupportedFormats } from 'html5-qrcode'

const props = withDefaults(
  defineProps<{
    modelValue: boolean
    title?: string
    subtitle?: string
    type?: 'achievement' | 'dispensation' | 'general'
  }>(),
  {
    title: 'Scan QR Code Kamera',
    subtitle: 'Arahkan kamera ke QR Code sertifikat prestasi atau surat dispensasi',
    type: 'general',
  }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
  (e: 'scanned', result: { code: string; raw: string; isUrl: boolean }): void
}>()

const scannerElementId = 'qr-camera-scanner-viewport'
let html5QrCode: Html5Qrcode | null = null

const isScanning = ref(false)
const cameraError = ref<string | null>(null)
const cameras = ref<Array<{ id: string; label: string }>>([])
const selectedCameraId = ref<string>('')
const isFileScanning = ref(false)

function extractCode(raw: string): { code: string; raw: string; isUrl: boolean } {
  const trimmed = raw.trim()
  const isUrl = /^https?:\/\//i.test(trimmed)

  if (isUrl) {
    try {
      const url = new URL(trimmed)
      const segments = url.pathname.split('/').filter(Boolean)
      
      // Match /verify/{public_id}
      const verifyIdx = segments.indexOf('verify')
      if (verifyIdx !== -1 && segments[verifyIdx + 1]) {
        return { code: decodeURIComponent(segments[verifyIdx + 1]), raw: trimmed, isUrl: true }
      }

      // Match query params (?id=... or ?token=...)
      const paramId = url.searchParams.get('id') || url.searchParams.get('token') || url.searchParams.get('code')
      if (paramId) {
        return { code: paramId, raw: trimmed, isUrl: true }
      }

      // Last path segment
      if (segments.length > 0) {
        return { code: decodeURIComponent(segments[segments.length - 1]), raw: trimmed, isUrl: true }
      }
    } catch {
      // Fallback
    }
  }

  // Normalize code with spaces or underscores
  const cleanCode = trimmed.replace(/\s+/g, '-').toUpperCase()
  return { code: cleanCode, raw: trimmed, isUrl }
}

function handleScanSuccess(decodedText: string) {
  // Beep sound feedback
  try {
    const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)()
    const osc = audioCtx.createOscillator()
    const gain = audioCtx.createGain()
    osc.type = 'sine'
    osc.frequency.value = 880 // 880 Hz A5 note
    gain.gain.value = 0.1
    osc.connect(gain)
    gain.connect(audioCtx.destination)
    osc.start()
    osc.stop(audioCtx.currentTime + 0.12)
  } catch {
    // AudioContext not allowed or unsupported
  }

  const result = extractCode(decodedText)
  stopScanner().then(() => {
    emit('scanned', result)
    emit('update:modelValue', false)
  })
}

async function startScanner() {
  cameraError.value = null
  isScanning.value = false

  await nextTick()

  try {
    const container = document.getElementById(scannerElementId)
    if (!container) return

    if (!html5QrCode) {
      html5QrCode = new Html5Qrcode(scannerElementId, {
        formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
        verbose: false,
      })
    }

    // Enumerate available video inputs
    try {
      const devices = await Html5Qrcode.getCameras()
      if (devices && devices.length > 0) {
        cameras.value = devices
        if (!selectedCameraId.value) {
          // Prefer environment / back camera
          const backCam = devices.find((d) => /back|rear|environment/i.test(d.label))
          selectedCameraId.value = backCam ? backCam.id : devices[0].id
        }
      }
    } catch {
      // Camera list permission error
    }

    const cameraConfig = selectedCameraId.value
      ? { deviceId: { exact: selectedCameraId.value } }
      : { facingMode: 'environment' }

    await html5QrCode.start(
      cameraConfig,
      {
        fps: 15,
        qrbox: { width: 240, height: 240 },
        aspectRatio: 1.0,
      },
      handleScanSuccess,
      () => {
        // scan failure on frame (ignore to avoid spam)
      }
    )

    isScanning.value = true
  } catch (err: any) {
    console.error('Failed to start camera QR scanner:', err)
    if (err?.name === 'NotAllowedError' || String(err).includes('Permission')) {
      cameraError.value = 'Izin akses kamera ditolak. Harap izinkan akses kamera di peramban Anda untuk memindai QR Code.'
    } else if (err?.name === 'NotFoundError' || String(err).includes('DevicesNotFoundError')) {
      cameraError.value = 'Perangkat kamera tidak ditemukan pada komputer/ponsel ini. Anda juga bisa mengunggah file foto QR code di bawah.'
    } else {
      cameraError.value = 'Gagal membuka kamera: ' + (err?.message || err)
    }
  }
}

async function stopScanner() {
  if (html5QrCode && html5QrCode.isScanning) {
    try {
      await html5QrCode.stop()
    } catch (err) {
      console.warn('Error stopping scanner:', err)
    }
  }
  isScanning.value = false
}

async function switchCamera(deviceId: string) {
  selectedCameraId.value = deviceId
  await stopScanner()
  await startScanner()
}

// Fallback: scan from image file
async function handleFileScan(e: Event) {
  const input = e.target as HTMLInputElement
  if (!input.files || !input.files[0]) return

  const file = input.files[0]
  isFileScanning.value = true
  cameraError.value = null

  try {
    if (!html5QrCode) {
      html5QrCode = new Html5Qrcode(scannerElementId, {
        formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
        verbose: false,
      })
    }
    const decodedText = await html5QrCode.scanFile(file, true)
    handleScanSuccess(decodedText)
  } catch (err: any) {
    cameraError.value = 'Tidak dapat mendeteksi QR Code dari gambar yang diunggah. Pastikan gambar QR jelas dan tidak buram.'
  } finally {
    isFileScanning.value = false
  }
}

function close() {
  stopScanner().then(() => {
    emit('update:modelValue', false)
  })
}

watch(
  () => props.modelValue,
  (open) => {
    if (open) {
      document.body.style.overflow = 'hidden'
      setTimeout(() => {
        startScanner()
      }, 150)
    } else {
      document.body.style.overflow = ''
      stopScanner()
    }
  }
)

onBeforeUnmount(() => {
  stopScanner()
})
</script>

<template>
  <Teleport to="body">
    <Transition name="fade">
      <div
        v-if="modelValue"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/80 backdrop-blur-sm"
        role="dialog"
        aria-modal="true"
      >
        <div class="bg-white rounded-3xl max-w-md w-full shadow-2xl border border-slate-100 overflow-hidden relative animate-in fade-in zoom-in duration-200">
          <!-- Modal Header -->
          <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/75">
            <div class="flex items-center gap-2.5">
              <div class="w-8 h-8 rounded-xl bg-brand-navy text-brand-gold flex items-center justify-center text-sm shadow-xs">
                <i class="fa-solid fa-camera"></i>
              </div>
              <div>
                <h3 class="text-xs font-bold text-slate-800">{{ title }}</h3>
                <p class="text-[10px] text-slate-400">{{ subtitle }}</p>
              </div>
            </div>
            <button
              type="button"
              @click="close"
              class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-200/60 flex items-center justify-center text-xs transition-all cursor-pointer"
            >
              <i class="fa-solid fa-xmark"></i>
            </button>
          </div>

          <!-- Scanner Body -->
          <div class="p-5 space-y-4">
            <!-- Camera Viewport Box -->
            <div class="relative w-full aspect-square bg-slate-950 rounded-2xl overflow-hidden border-2 border-slate-200 flex items-center justify-center">
              <div :id="scannerElementId" class="w-full h-full"></div>

              <!-- Overlay Scanner Frame -->
              <div
                v-if="isScanning"
                class="absolute inset-0 pointer-events-none flex items-center justify-center"
              >
                <div class="relative w-56 h-56 border-2 border-brand-gold/80 rounded-2xl shadow-[0_0_0_9999px_rgba(0,0,0,0.45)]">
                  <!-- Corner accents -->
                  <span class="absolute -top-1 -left-1 w-5 h-5 border-t-4 border-l-4 border-brand-gold rounded-tl-lg"></span>
                  <span class="absolute -top-1 -right-1 w-5 h-5 border-t-4 border-r-4 border-brand-gold rounded-tr-lg"></span>
                  <span class="absolute -bottom-1 -left-1 w-5 h-5 border-b-4 border-l-4 border-brand-gold rounded-bl-lg"></span>
                  <span class="absolute -bottom-1 -right-1 w-5 h-5 border-b-4 border-r-4 border-brand-gold rounded-br-lg"></span>

                  <!-- Red Laser Animation -->
                  <div class="w-full h-0.5 bg-gradient-to-r from-transparent via-red-500 to-transparent shadow-[0_0_8px_#ef4444] animate-pulse absolute top-1/2 -translate-y-1/2"></div>
                </div>
              </div>

              <!-- Loading / Starting Camera State -->
              <div v-if="!isScanning && !cameraError" class="absolute inset-0 bg-slate-900/90 flex flex-col items-center justify-center text-white text-center p-4">
                <i class="fa-solid fa-spinner fa-spin text-2xl text-brand-gold mb-2"></i>
                <p class="text-xs font-semibold">Mengaktifkan kamera...</p>
                <p class="text-[10px] text-slate-400 mt-1">Harap berikan izin browser saat diminta.</p>
              </div>

              <!-- Error Alert Inside Box -->
              <div v-if="cameraError" class="absolute inset-0 bg-rose-950/90 p-5 flex flex-col items-center justify-center text-center text-white space-y-2">
                <i class="fa-solid fa-triangle-exclamation text-2xl text-rose-400"></i>
                <p class="text-xs font-semibold text-rose-200">Kamera Tidak Aktif</p>
                <p class="text-[11px] text-rose-300/80 leading-relaxed max-w-xs">{{ cameraError }}</p>
                <button
                  type="button"
                  @click="startScanner"
                  class="mt-2 px-3 py-1 bg-white text-rose-900 rounded-lg text-xs font-bold hover:bg-rose-100 cursor-pointer"
                >
                  Coba Lagi
                </button>
              </div>
            </div>

            <!-- Controls: Switch camera if multiple cameras exist -->
            <div v-if="cameras.length > 1" class="flex items-center justify-between gap-2 text-xs">
              <span class="text-slate-400 text-[11px] font-medium flex items-center gap-1">
                <i class="fa-solid fa-video"></i> Pilihan Kamera:
              </span>
              <select
                :value="selectedCameraId"
                @change="switchCamera(($event.target as HTMLSelectElement).value)"
                class="px-2.5 py-1 bg-slate-100 border border-slate-200 rounded-lg text-xs font-semibold text-slate-700"
              >
                <option v-for="cam in cameras" :key="cam.id" :value="cam.id">
                  {{ cam.label || 'Kamera ' + cam.id.slice(0, 4) }}
                </option>
              </select>
            </div>

            <!-- File Upload Alternative (Scan dari Gambar / Screenshot) -->
            <div class="pt-3 border-t border-slate-100 flex items-center justify-between gap-2">
              <div class="text-[11px] text-slate-500">
                <span>Punya foto atau tangkapan layar QR?</span>
              </div>
              <label class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold cursor-pointer transition-all inline-flex items-center gap-1.5 shrink-0">
                <i v-if="isFileScanning" class="fa-solid fa-spinner fa-spin"></i>
                <i v-else class="fa-solid fa-image text-brand-blue"></i>
                <span>Unggah Foto QR</span>
                <input
                  type="file"
                  accept="image/*"
                  @change="handleFileScan"
                  class="hidden"
                />
              </label>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

