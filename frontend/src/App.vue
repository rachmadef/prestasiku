<script setup lang="ts">
import ToastContainer from '@/components/common/ToastContainer.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
</script>

<template>
  <router-view />
  <ToastContainer />
  <ConfirmDialog />
</template>
