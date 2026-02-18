<script setup lang="ts">
import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()
type AbsenceKind = Exclude<TimeKind, 'WORK' | 'EXTRA'>

function select(type: AbsenceKind, title: string) {
  emit('select', {
    //kind: 'ABSENCE',
    type,
    title,
    //breakMinutes: 0,
  })
}
</script>

<template>
  <div class="grid">
    <div
      class="card"
      @click="select(TimeKind.SICK, 'Sick')"
    >
      <strong>Sick</strong>
    </div>

    <div
      class="card"
      @click="select(TimeKind.VAB, 'VAB')"
    >
      <strong>VAB</strong>
    </div>

    <div
      class="card"
      @click="select(TimeKind.VACATION, 'Vacation')"
    >
      <strong>Vacation</strong>
    </div>
    <div
      class="card"
      @click="select(TimeKind.DAY_OFF, 'Day off')"
    >
      <strong>Day Off</strong>
    </div>
  </div>
</template>