<script setup lang="ts">
import type { DayEntry } from '../types/DayEntry.type';
import { TimeKind } from '../types/timeKind.enum';

defineProps<{
  date: string
  entries: DayEntry[]
}>()

const emit = defineEmits<{
  (e: 'edit', entry: DayEntry): void
  (e: 'back'): void
  (e: 'add'): void
}>()

function getTitle(entry: DayEntry) {
  if (entry.type === 'EXTRA') return 'Extra work'
  if (
    entry.type === TimeKind.SICK ||
    entry.type === TimeKind.VAB ||
    entry.type === TimeKind.VACATION ||
    entry.type === TimeKind.DAY_OFF ||
    entry.type === TimeKind.RED_DAY
  ) {
    return `Absence (${entry.type})`
  }
  return entry.project
  ? `Work · ${entry.project.city}`
  : 'Work'
}

function getProjectSubtitle(e: DayEntry) {
  if (!e.project) return ''

  const city = e.project.city
  const address = e.project.address

  return address
    ? `${city}, ${address.split(',')[0]}`
    : city
}
</script>

<template>
  <div class="day-entries">
    <header>
      <button @click="emit('back')">
        ← Back
      </button>
      <button @click="emit('add')">
        + Add work
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
      <small v-if="e.type === 'WORK' || e.type === 'EXTRA'">
        {{ getProjectSubtitle(e) }}
      </small>
    </div>
  </div>
</template>