import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { TimeEntry } from '../types/TimeEntry.type'
import type { TimeEntryCreatePayload } from '../types/TimeEntryCreatePayload'
import type { TimeEntryUpdatePayload } from '../types/TimeEntryUpdatePayload.type'
import {
  createTimeEntry,
  updateTimeEntry,
  getTimeEntries,
  deleteTimeEntry,
} from '../api/TimeEntry.api'

export const useTimeEntryStore = defineStore('timeEntries', () => {
  const entries = ref<TimeEntry[]>([])

  async function load(from: string, to: string) {
    entries.value = await getTimeEntries(from, to)
  }

  async function add(payload: TimeEntryCreatePayload) {
    const { data } = await createTimeEntry(payload)
    entries.value.unshift(data)
  }

   async function remove(id: string) {
    await deleteTimeEntry(id)
    entries.value = entries.value.filter(e => e.id !== id)
  }

  async function update(id: string, payload: TimeEntryUpdatePayload) {
  const { data } = await updateTimeEntry(id, payload)

  const idx = entries.value.findIndex(e => e.id === id)
    if (idx !== -1) {
      entries.value[idx] = data
    }
  }

  return { entries, load, add, update, remove }
})