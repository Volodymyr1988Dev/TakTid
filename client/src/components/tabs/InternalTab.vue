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
      <strong>Meeting</strong>
    </div>
  </div>
</template>
<style scoped>
.card {
  padding: 3px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.card:hover {
  transform: translateY(-2px);
}
</style>