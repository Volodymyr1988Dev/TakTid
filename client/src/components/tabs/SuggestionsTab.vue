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
          <span>{{ s.title }}</span>
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
}/*
.card {
  cursor: pointer;
}
.strong-type {
  font-size: small;
}
*/
.card {
  padding: 14px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.card:hover {
  transform: translateY(-2px);
}

/* WORK */
.card-work {
  background: #e0f2fe;
  border: 1px solid #38bdf8;
  color: #0369a1;
}

/* MEETING */
.card-meeting {
  background: #ede9fe;
  border: 1px solid #8b5cf6;
  color: #5b21b6;
}

/* ABSENCE TYPES */

.card-sick {
  background: #fee2e2;
  border: 1px solid #ef4444;
  color: #991b1b;
}

.card-vacation {
  background: #dcfce7;
  border: 1px solid #22c55e;
  color: #166534;
}

.card-vab {
  background: #fef9c3;
  border: 1px solid #eab308;
  color: #854d0e;
}

.card-dayoff {
  background: #e0e7ff;
  border: 1px solid #6366f1;
  color: #3730a3;
}

.card-red {
  background: #fecaca;
  border: 1px solid #dc2626;
  color: #7f1d1d;
}
</style>