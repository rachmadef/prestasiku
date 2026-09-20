<script setup lang="ts">
import Navbar from '@/components/common/Navbar.vue'
import Footer from '@/components/common/Footer.vue'
</script>

<template>
  <div class="min-h-screen flex flex-col bg-brand-surface selection:bg-brand-gold/30 selection:text-brand-navy">
    <Navbar />
    <main class="flex-1">
      <slot></slot>
    </main>
    <Footer />
  </div>
</template>
