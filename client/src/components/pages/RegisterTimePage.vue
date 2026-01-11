<script setup lang="ts">
import RegisterTabs from './RegisterTabs.vue'
import type { Dayjs } from 'dayjs'
import type { TimeSuggestion } from '../../types/Suggestion.type'

defineProps<{ day: Dayjs }>()

const emit = defineEmits<{
  (e: 'select-suggestion', s: TimeSuggestion): void
  (e: 'close'): void
}>()
</script>

<template>
  <div class="register-page">
    <header>
      <button @click="emit('close')">
        ← Back
      </button>
      Register time
    </header>

    <RegisterTabs
      @select-suggestion="s => emit('select-suggestion', s)"
    />
  </div>
</template>