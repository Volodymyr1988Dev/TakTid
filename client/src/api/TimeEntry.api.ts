import api from './axios'
import type { TimeEntry } from '../types/TimeEntry.type'
//import type { TimeKind } from '../types/timeKind.enum'
import type { TimeEntryCreatePayload } from '../types/TimeEntryCreatePayload'
import type { TimeEntryUpdatePayload } from '../types/TimeEntryUpdatePayload.type'
import { normalizeTime } from '../components/pages/components/helpers/helpers'

export async function getTimeEntries(
  from: string,
  to: string,
): Promise<TimeEntry[]> {
  const { data } = await api.get<TimeEntry[]>('/time-entries/period', {
    //withCredentials: true,
    params: { from, to },
  })
  return data
}

export async function createTimeEntry(
  payload: TimeEntryCreatePayload,
): Promise<{ data: TimeEntry }> {
  return api.post('/time-entries', payload)
}

export async function updateTimeEntry(
  id: string,
  payload: TimeEntryUpdatePayload,
) {
  const dto = {
    ...payload,
    startTime: normalizeTime(payload.startTime),
    endTime: normalizeTime(payload.endTime),
  };//payload
  return api.patch(`/time-entries/${id}`, dto)  //payload
}

export async function deleteTimeEntry(id: string): Promise<void> {
  await api.delete(`/time-entries/${id}`)
}

export async function getAdminMonthStats(year: number, month: number) {
  const { data } = await api.get(
    '/time-entries/stats/month/admin',
    { params: { year, month } },
  )
  return data
}