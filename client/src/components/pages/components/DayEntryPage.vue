<script setup lang="ts">
import type { TimeEntry } from '../../../types/TimeEntry.type'

defineProps<{
  date: string
  entries: TimeEntry[]
}>()

const emit = defineEmits<{
  (e: 'edit', entry: TimeEntry): void
  (e: 'back'): void
}>()
</script>

<template>
  <div class="day-entries">
    <header>
      <button @click="emit('back')">
        ← Back
      </button>
      <strong>{{ date }}</strong>
    </header>

    <div
      v-for="e in entries"
      :key="e.id"
      class="entry"
      @click="emit('edit', e)"
    >
      <div>
        {{ e.startTime }} – {{ e.endTime }}
        ({{ e.hours }}h)
      </div>
      <small>{{ e.type }}</small>
    </div>
  </div>
</template>