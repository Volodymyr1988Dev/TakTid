<script setup lang="ts">
import { TimeKind } from '../../../types/timeKind.enum'
import type { TimeSuggestion } from '../../../types/Suggestion.type'

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

function select(type: TimeKind, title: string) {
  emit('select', {
    type,
    title,
    breakMinutes: 0,
  })
}
</script>

<template>
  <div class="grid">
    <div
      class="card"
      @click="select(TimeKind.MEETING, 'Meeting')"
    >
      <strong>Meeting</strong>
    </div>
  </div>
</template>