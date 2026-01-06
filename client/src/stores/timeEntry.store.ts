import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getTimeEntries } from '../api/TimeEntry'
import type { TimeEntry } from '../types/TimeEntry.type'

export const useTimeEntryStore = defineStore('timeEntries', () => {
  const entries = ref<TimeEntry[]>([])
  const loading = ref(false)

  async function loadByPeriod(from: string, to: string) {
    loading.value = true
    try {
      entries.value = await getTimeEntries(from, to)
    } finally {
      loading.value = false
    }
  }

  return {
    entries,
    loading,
    loadByPeriod,
  }
})