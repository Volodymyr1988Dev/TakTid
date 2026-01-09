import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { TimeEntry } from '../types/TimeEntry.type'
import type { TimeEntryPayload } from '../types/TimeEntryPayload.type'
import {
  createTimeEntry,
  updateTimeEntry,
  getTimeEntries,
} from '../api/TimeEntry.api'

export const useTimeEntryStore = defineStore('timeEntries', () => {
  const entries = ref<TimeEntry[]>([])

  async function load(from: string, to: string) {
    entries.value = await getTimeEntries(from, to)
  }

  async function add(payload: TimeEntryPayload) {
    const { data } = await createTimeEntry(payload)
    entries.value.unshift(data)
  }

  async function update(id: string, payload: Partial<TimeEntry>) {
  const { data } = await updateTimeEntry(id, payload)

  const idx = entries.value.findIndex(e => e.id === id)
    if (idx !== -1) {
      entries.value[idx] = data
    }
  }

  return { entries, load, add, update }
})