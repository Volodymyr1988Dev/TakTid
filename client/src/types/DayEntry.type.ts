import type { TimeEntry } from './TimeEntry.type'
import type { TimeKind } from './timeKind.enum'

export type DayEntry =
  | ({
      kind: 'WORK'
      type: TimeKind
    } & TimeEntry)
  | {
      kind: 'EXTRA'
      id: string
      date: string
      hours: number
      projectId: string
      comment?: string
      startTime?: string
      endTime?: string
      breakMinutes?: number
    }