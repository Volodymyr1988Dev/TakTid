<script setup lang="ts">
import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
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
      <strong>{{ t('stats.meeting') }}</strong>
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