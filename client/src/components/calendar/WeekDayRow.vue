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
    class="week-row"
    @click="$emit('select', day)"
  >
    <div class="date">
      <div class="weekday">
        {{ day.format('ddd') }}
      </div>
      <div class="day">
        {{ day.format('D MMM') }}
      </div>
    </div>

    <div class="hours">
      {{ hours > 0 ? hours + ' h' : '—' }}
    </div>
  </div>
</template>