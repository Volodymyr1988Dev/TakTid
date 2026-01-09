import api from './axios'
import type { TimeEntry } from '../types/TimeEntry.type'
//import type { TimeKind } from '../types/timeKind.enum'
import type { TimeEntryPayload } from '../types/TimeEntryPayload.type'

export async function getTimeEntries(
  from: string,
  to: string,
): Promise<TimeEntry[]> {
  const { data } = await api.get<TimeEntry[]>('/time-entries/period', {
    params: { from, to },
  })
  return data
}

export async function createTimeEntry(
  payload: TimeEntryPayload,
): Promise<{ data: TimeEntry }> {
  return api.post('/time-entries', payload)
}

export async function updateTimeEntry(
  id: string,
  payload: Partial<TimeEntryPayload>,
) {
  return api.patch(`/time-entries/${id}`, payload)
}