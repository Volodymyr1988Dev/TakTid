<script setup lang="ts">
const emit = defineEmits<{
  (e: 'register-time'): void
}>()
</script>

<template>
  <div class="modal">
    <button @click="emit('register-time')">
      Register time
    </button>
  </div>
</template>