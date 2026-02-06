<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useSuggestionsStore } from '../../../stores/suggestions.store'
import { useProjectStore } from '../../../stores/project.store';
import type { TimeSuggestion } from '../../../types/Suggestion.type'

//const emit = defineEmits<{
//  (e: 'select', s: TimeSuggestion): void
//}>()
const suggestionsStore = useSuggestionsStore()
//const store = useSuggestionsStore()
const projectStore = useProjectStore()
//onMounted(store.load)
onMounted(suggestionsStore.load)


const uniqueSuggestions = computed<TimeSuggestion[]>(() => {
  const map = new Map<string, TimeSuggestion>()

  for (const s of suggestionsStore.items) {
    const key = s.projectId ?? s.type
    if (!map.has(key)) {
      map.set(key, s)
    }
  }

  return [...map.values()]
})
function selectSuggestion(s: TimeSuggestion) {
  if (s.projectId) {

    const project = projectStore.getById(s.projectId)
    if (project) {
      projectStore.select(project)
    }
  }
  //suggestionsStore.add(s)
}
//@click="emit('select', s)"
</script>

<template>
  <div class="suggestions">
    <div
      v-for="s in uniqueSuggestions"
      :key="s.projectId ?? s.type"
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