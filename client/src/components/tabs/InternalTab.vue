<script setup lang="ts">
import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

function selectMeeting() {
  emit('select', {
    type: TimeKind.MEETING,
    title: 'Internal meeting',
  })
}
</script>

<template>
  <div class="grid">
    <div
      class="card"
      @click="selectMeeting"
    >
      <strong>Internal Meeting</strong>
      <small>Non project related</small>
    </div>
  </div>
</template>