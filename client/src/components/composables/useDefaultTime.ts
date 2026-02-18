import { computed } from 'vue'
import type { DayEntry, WorkDayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
import { normalizeTime, toMinutes, toTimeString } from '../helpers/time'

interface UseDefaultTimeOptions {
  dayEntries?: DayEntry[]
  durationMinutes?: number
}

function isTimeEntry(entry: DayEntry): entry is WorkDayEntry {
  return (
    entry.type === TimeKind.WORK ||
    entry.type === TimeKind.EXTRA
  )
}

export function useDefaultTime(options: UseDefaultTimeOptions) {
  const duration = options.durationMinutes ?? 90

  const defaultTime = computed(() => {
    const entries = (options.dayEntries ?? [])
      .filter(isTimeEntry)
      .filter(e => e.startTime && e.endTime)
      .map(e => ({
        start: toMinutes(normalizeTime(e.startTime)!),
        end: toMinutes(normalizeTime(e.endTime)!),
      }))
      .sort((a, b) => a.start - b.start)

    if (entries.length === 0) {
      return { start: '08:00', end: '17:00' }
    }

    const last = entries[entries.length - 1]
    
    if (!last) {
      return { start: '08:00', end: '17:00' }
    }
    //const lastEnd = last.end
    const endOfWorkDay = toMinutes('17:00')

    if (last.end < endOfWorkDay) {
      return {
        start: toTimeString(last.end),
        end: '17:00',
      }
    }

    return {
      start: toTimeString(last.end),
      end: toTimeString(last.end + duration),
    }
  })

  return { defaultTime }
}