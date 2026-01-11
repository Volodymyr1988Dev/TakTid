<script setup lang="ts">
import { Dayjs } from 'dayjs'

defineProps<{
  day: Dayjs
  hours: number
}>()

defineEmits<{
  (e: 'select', day: Dayjs): void
}>()
</script>

<template>
  <div
    class="day"
    @click="$emit('select', day)"
  >
    <div class="date">
      {{ day.format('ddd D') }}
    </div>
    <div class="hours">
      {{ hours }} h
    </div>
  </div>
</template>