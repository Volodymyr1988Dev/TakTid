<script setup lang="ts">
defineProps<{
  modelValue: 'week' | 'month'
}>()

defineEmits<{
  (e: 'update:modelValue', value: 'week' | 'month'): void
}>()
</script>

<template>
  <div class="tabs">
    <button
      :class="{ active: modelValue === 'week' }"
      @click="$emit('update:modelValue', 'week')"
    >
      📅 Vecka
    </button>
    <button
      :class="{ active: modelValue === 'month' }"
      @click="$emit('update:modelValue', 'month')"
    >
      🗓 Månad
    </button>
  </div>
</template>