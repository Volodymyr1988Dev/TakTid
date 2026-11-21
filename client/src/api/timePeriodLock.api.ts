
import api from './axios'
import type { TimePeriodStatus } from '../types/TimePeriodLock.type'

export async function getPeriodStatus(
  date: string,
): Promise<TimePeriodStatus> {
  const { data } = await api.get<TimePeriodStatus>(
    '/timesheet-periods/status',
    { params: { date } },
  )

  return data
}

export async function closeWeek(date: string): Promise<TimePeriodStatus> {
  const { data } = await api.post<TimePeriodStatus>(
    '/timesheet-periods/close',
    undefined,
    { params: { date } },
  )

  return data
}

export async function unlockWeek(date: string): Promise<TimePeriodStatus> {
  const { data } = await api.post<TimePeriodStatus>(
    '/timesheet-periods/unlock',
    undefined,
    { params: { date } },
  )

  return data
}