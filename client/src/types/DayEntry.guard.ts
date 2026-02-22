import { TimeKind } from './timeKind.enum'
import type {
  DayEntry,
  WorkDayEntry,
  AbsenceDayEntry,
} from './DayEntry.type'

export function isWorkEntry(
  e: DayEntry
): e is WorkDayEntry {
  return (
    e.type === TimeKind.WORK ||
    e.type === TimeKind.EXTRA
  )
}

export function isAbsenceEntry(
  e: DayEntry
): e is AbsenceDayEntry {
  return (
    e.type === TimeKind.SICK ||
    e.type === TimeKind.VAB ||
    e.type === TimeKind.VACATION || 
    e.type === TimeKind.DAY_OFF ||
    e.type === TimeKind.RED_DAY
  )
}