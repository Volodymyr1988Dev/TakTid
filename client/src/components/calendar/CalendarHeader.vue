<script setup lang="ts">
import { Dayjs } from 'dayjs'

defineProps<{
  mode: 'month' | 'week'
  current: Dayjs
}>()

const emit = defineEmits<{
  (e: 'changeMode', value: 'month' | 'week'): void
}>()
</script>

<template>
  <div class="header">
    <div class="tabs">
      <button
        :class="{ active: mode === 'week' }"
        @click="emit('changeMode', 'week')"
      >
        Vecka
      </button>
      <button
        :class="{ active: mode === 'month' }"
        @click="emit('changeMode', 'month')"
      >
        Månad
      </button>
    </div>

    <div class="title">
      {{ mode === 'month'
        ? current.format('MMMM')
        : `Week ${current.week()}` }}
    </div>
  </div>
</template>