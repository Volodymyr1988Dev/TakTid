import api from './axios'
import type { TimeEntry } from '../types/TimeEntry.type'

export async function getTimeEntries(from: string, to: string) {
  const { data } = await api.get<TimeEntry[]>(
    `/time-entries?from=${from}&to=${to}`,
  )
  return data
}

export function createTimeEntry(payload: {
  date: string
  hours: number
  comment?: string
}) {
  return api.post<TimeEntry>('/time-entries', payload)
}

export function updateTimeEntry(
  id: string,
  payload: { hours: number; comment?: string },
) {
  return api.put<TimeEntry>(`/time-entries/${id}`, payload)
}