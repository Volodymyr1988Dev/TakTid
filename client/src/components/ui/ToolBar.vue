<script setup lang="ts">
defineProps<{
  title: string
}>()

const emit = defineEmits<{
  (e: 'prev'): void
  (e: 'next'): void
}>()
</script>

<template>
  <div class="toolbar">
    <button
      class="nav"
      @click="emit('prev')"
    >
      ‹
    </button>
    <span class="title">{{ title }}</span>
    <button
      class="nav"
      @click="emit('next')"
    >
      ›
    </button>
  </div>
</template>

<style scoped src="./toolBar.style.css"></style>