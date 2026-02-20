<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useSuggestionsStore } from '../../stores/suggestions.store'
import { useProjectStore } from '../../stores/project.store';
import type { TimeSuggestion } from '../../types/Suggestion.type'
import { isWorkSuggestion } from '../../types/suggestion.guard';

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

const suggestionsStore = useSuggestionsStore()
const projectStore = useProjectStore()
onMounted(suggestionsStore.load)


const uniqueSuggestions = computed<TimeSuggestion[]>(() => {
  const map = new Map<string, TimeSuggestion>()

  for (const s of suggestionsStore.items) {
    const key = isWorkSuggestion(s) ? s.projectId : s.type
    if (!map.has(key)) {map.set(key, s)}
  }

  return [...map.values()]
})
function suggestionKey(s: TimeSuggestion): string {
  return isWorkSuggestion(s) ? s.projectId : s.type
}
function selectSuggestion(s: TimeSuggestion) {

  if (isWorkSuggestion(s)) {
    const project = projectStore.getById(s.projectId)
    if (project) projectStore.select(project)
    emit('select', s)
  }
}
</script>

<template>
  <div class="suggestions">
    <div
      v-for="s in uniqueSuggestions"
      :key="suggestionKey(s)"
      class="card"
      @click="selectSuggestion(s)"
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