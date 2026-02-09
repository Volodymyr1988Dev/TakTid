import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { TimeSuggestion } from '../types/Suggestion.type'
import { getSuggestions } from '../api/TimeSuggestion.api'

export const useSuggestionsStore = defineStore('suggestions', () => {
  const items = ref<TimeSuggestion[]>([])
  const loading = ref(false)
  const selected = ref<TimeSuggestion | null>(null)

  function select(s: TimeSuggestion) {
    selected.value = s
  }

  function clear() {
    selected.value = null
  }
  async function load() {
    loading.value = true
    try {
      items.value = await getSuggestions()
    } finally {
      loading.value = false
    }
  }

  return { items, loading, load, select, clear, selected }
})