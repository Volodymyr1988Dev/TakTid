<script setup lang="ts">
import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { AbsenceKind } from '../../types/timeKind.enum'

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()
//type AbsenceKind = Exclude<TimeKind, 'WORK' | 'EXTRA'>

function select(type: AbsenceKind, title: string) {
  emit('select', {
    type,
    title,
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
    <div
      class="card"
      @click="select(TimeKind.RED_DAY, 'Red Day')"
    >
      <strong>Red Day</strong>
    </div>
  </div>
</template>
<style scoped>
.grid {
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.card {
  display: flex;
  justify-content: space-between;
  background: #fff;
  border-radius: 18px;
  padding: 4px;
  overflow: hidden;
  border: 1px solid #e5e7eb;
  box-shadow: 0 8px 20px rgba(0,0,0,.08);
  transition: transform .15s ease;
}

.card:hover {
  transform: translateY(-2px);
}
</style>