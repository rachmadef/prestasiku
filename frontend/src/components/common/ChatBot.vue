<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { api } from '@/services/api'

interface ChatMessage {
  role: 'user' | 'model'
  text: string
}

const isOpen = ref(false)
const inputMessage = ref('')
const isLoading = ref(false)
const messages = ref<ChatMessage[]>([
  {
    role: 'model',
    text: 'Halo! 👋 Saya **Prestasiku AI Assistant**. Ada yang bisa saya bantu terkait perlombaan, pendaftaran, portofolio prestasi, atau dispensasi KBM?',
  },
])

const messageContainer = ref<HTMLElement | null>(null)

const quickQuestions = [
  'Bagaimana cara mendaftar lomba?',
  'Apa itu Surat Dispensasi KBM?',
  'Bagaimana cara mengunggah Sertifikat Prestasi?',
  'Apa keuntungan mendaftarkan sekolah?',
]

const toggleChat = () => {
  isOpen.value = !isOpen.value
  if (isOpen.value) {
    scrollToBottom()
  }
}

const scrollToBottom = async () => {
  await nextTick()
  if (messageContainer.value) {
    messageContainer.value.scrollTop = messageContainer.value.scrollHeight
  }
}

const handleQuickQuestion = (question: string) => {
  inputMessage.value = question
  sendMessage()
}

const sendMessage = async () => {
  const text = inputMessage.value.trim()
  if (!text || isLoading.value) return

  // Push user message
  messages.value.push({ role: 'user', text })
  inputMessage.value = ''
  isLoading.value = true
  scrollToBottom()

  // Prepare history format for API (exclude error messages)
  const historyPayload = messages.value
    .slice(1, -1)
    .filter((msg) => !msg.text.includes('Gagal') && !msg.text.includes('⚠️'))
    .map((msg) => ({
      role: msg.role,
      parts: [{ text: msg.text }],
    }))

  try {
    const response = await api.post('/chatbot/chat', {
      message: text,
      history: historyPayload,
    })

    if (response.data && response.data.success) {
      messages.value.push({
        role: 'model',
        text: response.data.reply,
      })
    } else {
      messages.value.push({
        role: 'model',
        text: response.data?.message || 'Maaf, gagal memproses tanggapan dari AI.',
      })
    }
  } catch (error: any) {
    const errorMsg = error.response?.data?.message || 'Terjadi gangguan jaringan atau server. Silakan coba lagi.'
    messages.value.push({
      role: 'model',
      text: `⚠️ ${errorMsg}`,
    })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}

const clearChat = () => {
  messages.value = [
    {
      role: 'model',
      text: 'Halo! 👋 Saya **Prestasiku AI Assistant**. Ada yang bisa saya bantu terkait perlombaan, pendaftaran, portofolio prestasi, atau dispensasi KBM?',
    },
  ]
}

const formatMessageText = (text: string) => {
  if (!text) return ''
  // Basic formatting: bold **text**, newlines
  let formatted = text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/\n/g, '<br/>')
  return formatted
}
</script>

<template>
  <div class="chatbot-container">
    <!-- Floating Launcher Button -->
    <button 
      @click="toggleChat" 
      class="chat-launcher-btn"
      :class="{ 'is-open': isOpen }"
      aria-label="Tanyakan AI Prestasiku"
      title="Buka Prestasiku AI Assistant"
    >
      <div class="launcher-content">
        <svg v-if="!isOpen" class="icon-sparkles" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2L14.5 9.5L22 12L14.5 14.5L12 22L9.5 14.5L2 12L9.5 9.5L12 2Z" />
        </svg>
        <svg v-else class="icon-close" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
        <span v-if="!isOpen" class="launcher-text">Prestasiku AI</span>
      </div>
    </button>

    <!-- Chat Modal Window -->
    <transition name="chat-slide">
      <div v-if="isOpen" class="chat-window">
        <!-- Header -->
        <div class="chat-header">
          <div class="header-info">
            <div class="ai-avatar">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2L14.5 9.5L22 12L14.5 14.5L12 22L9.5 14.5L2 12L9.5 9.5L12 2Z" />
              </svg>
            </div>
            <div>
              <h3 class="header-title">Prestasiku AI Assistant</h3>
              <p class="header-subtitle">
                <span class="online-indicator"></span> Didukung oleh Google Gemini
              </p>
            </div>
          </div>
          <div class="header-actions">
            <button 
              @click="clearChat" 
              class="header-action-btn" 
              title="Bersihkan Chat"
              aria-label="Bersihkan Chat"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="3 6 5 6 21 6"></polyline>
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
              </svg>
            </button>
            <button @click="toggleChat" class="header-close-btn" aria-label="Tutup Chat" title="Tutup Chat">
              &times;
            </button>
          </div>
        </div>

        <!-- Body / Messages -->
        <div class="chat-body" ref="messageContainer">
          <div 
            v-for="(msg, idx) in messages" 
            :key="idx" 
            :class="['chat-bubble-row', msg.role]"
          >
            <div v-if="msg.role === 'model'" class="bot-avatar">✨</div>
            <div 
              class="chat-bubble"
              v-html="formatMessageText(msg.text)"
            ></div>
          </div>

          <!-- Typing Indicator -->
          <div v-if="isLoading" class="chat-bubble-row model">
            <div class="bot-avatar">✨</div>
            <div class="chat-bubble loading-bubble">
              <span class="dot"></span>
              <span class="dot"></span>
              <span class="dot"></span>
            </div>
          </div>

          <!-- Quick Suggestion Pills -->
          <div v-if="messages.length <= 2 && !isLoading" class="quick-pills-container">
            <p class="quick-title">Pertanyaan populer:</p>

            <div class="pills-grid">
              <button
                v-for="(q, i) in quickQuestions"
                :key="i"
                @click="handleQuickQuestion(q)"
                class="quick-pill-btn"
              >
                {{ q }}
              </button>
            </div>
          </div>
        </div>

        <!-- Input Footer -->
        <div class="chat-footer">
          <form @submit.prevent="sendMessage" class="input-form">
            <input 
              v-model="inputMessage" 
              type="text" 
              placeholder="Ketik pertanyaan seputar Prestasiku..." 
              :disabled="isLoading"
              class="chat-input-field"
            />
            <button 
              type="submit" 
              :disabled="isLoading || !inputMessage.trim()" 
              class="send-btn"
              aria-label="Kirim Pesan"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z" />
              </svg>
            </button>
          </form>
          <div class="disclaimer">
            Asisten ini khusus menjawab topik seputar platform <strong>Prestasiku</strong>.
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style scoped>
.chatbot-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 9999;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
}

/* Floating Launcher Button */
.chat-launcher-btn {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  color: #ffffff;
  border: none;
  padding: 12px 20px;
  border-radius: 9999px;
  cursor: pointer;
  box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.4), 0 8px 10px -6px rgba(37, 99, 235, 0.3);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-launcher-btn:hover {
  transform: translateY(-2px) scale(1.03);
  box-shadow: 0 14px 28px -5px rgba(37, 99, 235, 0.5);
}

.chat-launcher-btn.is-open {
  padding: 14px;
  border-radius: 50%;
  background: #1e293b;
  box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.launcher-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon-sparkles {
  width: 22px;
  height: 22px;
  color: #fbbf24;
}

.icon-close {
  width: 20px;
  height: 20px;
}

.launcher-text {
  font-weight: 600;
  font-size: 14px;
  letter-spacing: 0.2px;
}

/* Chat Modal Window */
.chat-window {
  position: absolute;
  bottom: 72px;
  right: 0;
  width: 380px;
  max-width: calc(100vw - 32px);
  height: 540px;
  max-height: calc(100vh - 120px);
  background: #ffffff;
  border-radius: 20px;
  box-shadow: 0 20px 40px -15px rgba(15, 23, 42, 0.25), 0 0 0 1px rgba(15, 23, 42, 0.05);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transform-origin: bottom right;
}

/* Animation */
.chat-slide-enter-active,
.chat-slide-leave-active {
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.chat-slide-enter-from,
.chat-slide-leave-to {
  opacity: 0;
  transform: scale(0.85) translateY(20px);
}

/* Header */
.chat-header {
  background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
  color: #ffffff;
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ai-avatar {
  width: 36px;
  height: 36px;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(4px);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fbbf24;
}

.ai-avatar svg {
  width: 20px;
  height: 20px;
}

.header-title {
  font-size: 15px;
  font-weight: 700;
  margin: 0;
  line-height: 1.2;
}

.header-subtitle {
  font-size: 12px;
  color: #94a3b8;
  margin: 2px 0 0 0;
  display: flex;
  align-items: center;
  gap: 6px;
}

.online-indicator {
  width: 8px;
  height: 8px;
  background: #10b981;
  border-radius: 50%;
  display: inline-block;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.header-action-btn {
  background: transparent;
  border: none;
  color: #94a3b8;
  padding: 6px;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.header-action-btn svg {
  width: 17px;
  height: 17px;
}

.header-action-btn:hover {
  color: #f87171;
  background: rgba(255, 255, 255, 0.1);
}

.header-close-btn {
  background: transparent;
  border: none;
  color: #94a3b8;
  font-size: 24px;
  line-height: 1;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: color 0.2s;
}

.header-close-btn:hover {
  color: #ffffff;
}

/* Chat Body */
.chat-body {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: #f8fafc;
}

.chat-bubble-row {
  display: flex;
  gap: 8px;
  align-items: flex-start;
  max-width: 88%;
}

.chat-bubble-row.user {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.chat-bubble-row.model {
  align-self: flex-start;
}

.bot-avatar {
  width: 28px;
  height: 28px;
  background: #eff6ff;
  border: 1px solid #dbeafe;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  flex-shrink: 0;
}

.chat-bubble {
  padding: 10px 14px;
  border-radius: 16px;
  font-size: 13.5px;
  line-height: 1.5;
  word-break: break-word;
}

.chat-bubble-row.user .chat-bubble {
  background: #2563eb;
  color: #ffffff;
  border-bottom-right-radius: 4px;
}

.chat-bubble-row.model .chat-bubble {
  background: #ffffff;
  color: #1e293b;
  border-bottom-left-radius: 4px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

/* Loading Dots */
.loading-bubble {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 12px 16px;
}

.dot {
  width: 6px;
  height: 6px;
  background: #94a3b8;
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.dot:nth-child(1) { animation-delay: -0.32s; }
.dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

/* Quick Pills */
.quick-pills-container {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed #cbd5e1;
}

.quick-title {
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  margin: 0 0 8px 0;
}

.pills-grid {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.quick-pill-btn {
  background: #ffffff;
  border: 1px solid #cbd5e1;
  color: #334155;
  padding: 8px 12px;
  border-radius: 10px;
  font-size: 12.5px;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s;
}

.quick-pill-btn:hover {
  background: #eff6ff;
  border-color: #93c5fd;
  color: #1d4ed8;
}

/* Chat Footer */
.chat-footer {
  background: #ffffff;
  padding: 12px 16px;
  border-top: 1px solid #e2e8f0;
}

.input-form {
  display: flex;
  gap: 8px;
  align-items: center;
}

.chat-input-field {
  flex: 1;
  padding: 10px 14px;
  border: 1px solid #cbd5e1;
  border-radius: 12px;
  font-size: 13.5px;
  outline: none;
  transition: border-color 0.2s;
}

.chat-input-field:focus {
  border-color: #2563eb;
}

.send-btn {
  background: #2563eb;
  color: #ffffff;
  border: none;
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.2s;
  flex-shrink: 0;
}

.send-btn svg {
  width: 18px;
  height: 18px;
}

.send-btn:hover:not(:disabled) {
  background: #1d4ed8;
}

.send-btn:disabled {
  background: #cbd5e1;
  cursor: not-allowed;
}

.disclaimer {
  font-size: 10.5px;
  color: #94a3b8;
  text-align: center;
  margin-top: 8px;
}
</style>
