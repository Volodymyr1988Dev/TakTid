import api from './axios'
import type { TimeEntry } from '../types/TimeEntry.type'
import { TimeKind } from '../types/timeKind.enum'

export async function getTimeEntries(from: string, to: string): Promise<TimeEntry[]> {
 const { data } = await api.get<TimeEntry[]>('/time-entries/period', {
    params: { from, to },
  })
  return data
}

export async function createTimeEntry(payload: {
  date: string
  hours: number
  type: TimeKind
  projectId?: string
  comment: string
  breakMinutes?: number
  photoUrl?: string
}) {
  const { data } = await api.post<TimeEntry>('/time-entries', payload)
  return data
}

export async function updateTimeEntry(
  id: string,
  payload: Partial<{
    hours: number
    type: TimeKind
    comment: string
    breakMinutes: number
  }>,
) {
  await api.patch(`/time-entries/${id}`, payload)
}