import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { TimeSuggestion } from '../types/Suggestion.type'
import { getSuggestions } from '../api/TimeSuggestion.api'

export const useSuggestionsStore = defineStore('suggestions', () => {
  const items = ref<TimeSuggestion[]>([])
  const loading = ref(false)

  async function load() {
    loading.value = true
    try {
      items.value = await getSuggestions()
    } finally {
      loading.value = false
    }
  }

  return { items, loading, load }
})