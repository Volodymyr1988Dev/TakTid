<script setup lang="ts">
import { onMounted } from 'vue'
import { useSuggestionsStore } from '../../../stores/suggestions.store'
import type { TimeSuggestion } from '../../../types/Suggestion.type'

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

const store = useSuggestionsStore()

onMounted(() => {
  store.load()
})
</script>

<template>
  <div class="suggestions">
    <div
      v-for="s in store.items"
      :key="s.type + s.projectId"
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
</style>