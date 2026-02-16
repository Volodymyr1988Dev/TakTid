import type { DayEntry, WorkDayEntry, ExtraDayEntry } from '../../../../types/DayEntry.type'
import { TimeKind } from '../../../../types/timeKind.enum'
import { calculateWorkedMinutes } from './time'

const FULL_DAY_MINUTES = 8 * 60

export function calculateMissingWorkTime(dayEntries?: DayEntry[]) {
  if (!dayEntries?.length) {
    return {
      missingMinutes: FULL_DAY_MINUTES,
      lastEnd: '09:00',
    }
  }

  const workEntries = dayEntries.filter(
    (e): e is WorkDayEntry | ExtraDayEntry =>
      e.type === TimeKind.WORK ||
      e.type === TimeKind.EXTRA,
  )

  if (!workEntries.length) {
    return {
      missingMinutes: FULL_DAY_MINUTES,
      lastEnd: '09:00',
    }
  }
  const workedMinutes = workEntries.reduce((sum, e) => {
    if (!e.startTime || !e.endTime) return sum
    const duration = calculateWorkedMinutes(
        e.startTime,
        e.endTime,
        e.breakMinutes ?? 0
    )
    return sum + duration
  }, 0)

  const sorted = [...workEntries].sort((a, b) =>
    a.startTime.localeCompare(b.startTime),
  )
  const lastEntry = sorted[sorted.length - 1]
  const lastEnd =
    lastEntry?.endTime ?? '09:00'
  return {
    missingMinutes: Math.max(FULL_DAY_MINUTES - workedMinutes, 0),
    lastEnd,
  }
}