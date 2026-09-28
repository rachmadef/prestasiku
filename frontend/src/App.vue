<script setup lang="ts">
import ToastContainer from '@/components/common/ToastContainer.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import ChatBot from '@/components/common/ChatBot.vue'
</script>

<template>
  <router-view />
  <ToastContainer />
  <ConfirmDialog />
  <ChatBot />
</template>
