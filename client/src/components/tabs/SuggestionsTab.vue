<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useSuggestionsStore } from '../../stores/suggestions.store'
import { useProjectStore } from '../../stores/project.store';
import type { TimeSuggestion } from '../../types/Suggestion.type'
import { isWorkSuggestion, isInternalSuggestion } from '../../types/suggestion.guard';
import { cardClass } from '../helpers/cardClass';

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

const suggestionsStore = useSuggestionsStore()
const projectStore = useProjectStore()
onMounted(suggestionsStore.load)

const uniqueSuggestions = computed<TimeSuggestion[]>(() => {
  const map = new Map<string, TimeSuggestion>()

  const reversed = [...suggestionsStore.items].reverse()

  for (const s of reversed) {
    const key = isWorkSuggestion(s) ? s.projectId : s.type

    if (!map.has(key)) {
      map.set(key, s)
    }
    if (map.size === 5) break
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
    console.log(s.title, 's.title')
    console.log(s.type, 's.type')
  }
  emit('select', s)
}
</script>

<template>
  <div class="suggestions">
    <div
      v-for="s in uniqueSuggestions"
      :key="suggestionKey(s)"
      class="card"
      :class="cardClass(s)"
      @click="selectSuggestion(s)"
    >
      <!-- WORK / EXTRA -->
      <template v-if="isWorkSuggestion(s)">
        <div class="work-card">
          <strong class="title">{{ s.title }}</strong>
        </div>
      </template>

      <!-- MEETING -->
      <template v-else-if="isInternalSuggestion(s)">
        <div class="meeting-card">
          <span>{{ s.type }}</span>
        </div>
      </template>

      <!-- ABSENCE -->
      <template v-else>
        <div class="absence-card">
          <span>{{ s.type }}</span>
        </div>
      </template>
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
  padding: 3px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.card:hover {
  transform: translateY(-2px);
}

.card-work {
  color: #0369a1;
}

.card-meeting {
  color: #5b21b6;
}

.card-sick {
  color: #991b1b;
}

.card-vacation {
  color: #166534;
}

.card-vab {
  color: #854d0e;
}

.card-dayoff {
  color: #3730a3;
}

.card-red {
  color: #7f1d1d;
}
</style>