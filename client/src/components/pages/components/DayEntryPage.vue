<script setup lang="ts">
import type { DayEntry } from '../../../types/DayEntry.type';
//import type { TimeEntry } from '../../../types/TimeEntry.type'
import { TimeKind } from '../../../types/timeKind.enum';

defineProps<{
  date: string
  //entries: TimeEntry[]
  entries: DayEntry[]
}>()

const emit = defineEmits<{
  //(e: 'edit', entry: TimeEntry): void
  (e: 'edit', entry: DayEntry): void
  (e: 'back'): void
}>()

//function getTitle(entry: TimeEntry) {
function getTitle(entry: DayEntry) {
  if (entry.kind === 'EXTRA') return 'Extra work'
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
      <small>{{ e.comment }}</small>
    </div>
  </div>
</template>