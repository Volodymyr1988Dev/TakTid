import type { DayEntry, WorkDayEntry, ExtraDayEntry } from '../../../../types/DayEntry.type'
import { TimeKind } from '../../../../types/timeKind.enum'
import { normalizeTime } from './time'

export function getLastWorkEnd(dayEntries?: DayEntry[]): string | null {
  if (!dayEntries?.length) return null

  const workEntries = dayEntries
    .filter(
      (e): e is WorkDayEntry | ExtraDayEntry =>
        e.type === TimeKind.WORK ||
        e.type === TimeKind.EXTRA
    )
    .filter((e) => e.endTime)
    .sort((a, b) =>
      a.startTime.localeCompare(b.startTime)
    )

  if (!workEntries.length) return null

  const last = workEntries[workEntries.length - 1]
  if (!last?.endTime) return null
  return normalizeTime(last.endTime) ?? null
}