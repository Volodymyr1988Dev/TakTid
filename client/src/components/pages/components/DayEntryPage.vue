<script setup lang="ts">
import type { TimeEntry } from '../../../types/TimeEntry.type'
import { TimeKind } from '../../../types/timeKind.enum';

defineProps<{
  date: string
  entries: TimeEntry[]
}>()

const emit = defineEmits<{
  (e: 'edit', entry: TimeEntry): void
  (e: 'back'): void
}>()

function getTitle(entry: TimeEntry) {
  //if (entry.type === TimeKind.EXTRA) return 'Extra'
  if (
    entry.type === TimeKind.SICK ||
    entry.type === TimeKind.VAB ||
    entry.type === TimeKind.VACATION
  ) {
    return `Absence (${entry.type})`
  }
  return 'Work'
}
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
        <strong>{{ getTitle(e) }}</strong>
      </div>
      <div v-if="e.type === TimeKind.WORK">
        {{ e.startTime }} – {{ e.endTime }} ({{ e.hours }}h)
      </div>

      <div v-else-if="e.type === 'EXTRA'">
        <em>Extra work</em>
      </div>
      <div v-else>
        <em>Absence</em>
      </div>
      <small>{{ e.type }}</small>
    </div>
  </div>
</template>