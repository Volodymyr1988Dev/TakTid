<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useSuggestionsStore } from '../../../stores/suggestions.store'
import type { TimeSuggestion } from '../../../types/Suggestion.type'

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

const store = useSuggestionsStore()

onMounted(store.load)


const uniqueSuggestions = computed<TimeSuggestion[]>(() => {
  const map = new Map<string, TimeSuggestion>()

  for (const s of store.items) {
    const key = s.projectId ?? s.type
    if (!map.has(key)) {
      map.set(key, s)
    }
  }

  return [...map.values()]
})
</script>

<template>
  <div class="suggestions">
    <div
      v-for="s in uniqueSuggestions"
      :key="s.projectId ?? s.type"
      class="card"
      @click="emit('select', s)"
    >
      <strong>{{ s.title }}</strong>
      <span>{{ s.type }}</span>
    </div>
  </div>
</template>

<style scoped>
.suggestions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px;
}
.card {
  cursor: pointer;
}
</style>