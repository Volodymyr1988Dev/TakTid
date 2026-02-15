import { TimeKind } from '../../../../types/timeKind.enum'
import type { DayEntry } from '../../../../types/DayEntry.type'

export interface DefaultTimeResult {
  start: string
  end: string
}

function normalizeTime(t: string): string {
  return t.slice(0, 5)
}

export function getNextDefaultTime(
  dayEntries?: DayEntry[],
  durationMinutes = 90,
): DefaultTimeResult | null {
  if (!dayEntries?.length) return null

  const workEntries = dayEntries
    .filter(
      (e): e is DayEntry & { startTime: string; endTime: string } =>
        (e.type === TimeKind.WORK || e.type === TimeKind.EXTRA) &&
        !!e.startTime &&
        !!e.endTime,
    )
    .sort((a, b) => a.startTime.localeCompare(b.startTime))

  if (!workEntries.length) return null

  const last = workEntries[workEntries.length - 1]
  if (!last?.endTime) return null

  const start = normalizeTime(last.endTime)

  const [h, m] = start.split(':').map(Number)

  const date = new Date()
  date.setHours(Number(h))
  date.setMinutes(Number(m) + durationMinutes)

  const end =
    String(date.getHours()).padStart(2, '0') +
    ':' +
    String(date.getMinutes()).padStart(2, '0')

  return { start, end }
}