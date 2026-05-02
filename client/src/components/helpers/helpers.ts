import { Dayjs } from 'dayjs'
import type { DayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'

export function cleanPatch<T extends object>(obj: T): Partial<T> {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([_, v]) => v !== undefined
    )
  ) as Partial<T>
}

export const isWeekend = (day: Dayjs): boolean => {
  const d = day.day()
  return d === 0 || d === 6
}

export function sanitizeNumber(v: any) {
  const n = Number(v)
  return Number.isFinite(n) ? n : null
}
export function isCountedInTotal(e: DayEntry) {
  if (e.type === TimeKind.DAY_OFF) return false
  return [
    TimeKind.WORK,
    TimeKind.EXTRA,
    TimeKind.SICK,
    TimeKind.VACATION,
    TimeKind.VAB,
    TimeKind.RED_DAY,
    TimeKind.MEETING
  ].includes(e.type as Exclude<TimeKind, typeof TimeKind.DAY_OFF>)
}