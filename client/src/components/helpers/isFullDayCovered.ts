import type { DayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
import { toMinutes } from './time'

export function isFullDayCovered(dayEntries?: DayEntry[]): boolean {
  if (!dayEntries?.length) return false

  const workEntries = dayEntries.filter(
    (e) =>
      e.type === TimeKind.WORK ||
      e.type === TimeKind.EXTRA
  )

  if (!workEntries.length) return false

  const totalMinutes = workEntries.reduce((sum: number, e) => {
    if (!('startTime' in e) || !('endTime' in e)) return sum
    if (!e.startTime || !e.endTime) return sum
    const duration =
      toMinutes(e.endTime) -
      toMinutes(e.startTime) -
      (e.breakMinutes ?? 0)

    return sum + Math.max(duration, 0)
    //return (sum +(toMinutes(e.endTime) - toMinutes(e.startTime)))
  }, 0)

  return totalMinutes >= 8 * 60
}