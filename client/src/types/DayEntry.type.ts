import { TimeKind } from './timeKind.enum'
import type { Project } from './Project.dto'

interface BaseDayEntry {
  id: string
  date: string
  hours: number
  comment?: string
  type: TimeKind
  project?: Project
}

interface TimedEntry {
  startTime: string
  endTime: string
  breakMinutes: number
}

export interface WorkDayEntry extends BaseDayEntry, TimedEntry {
  type: typeof TimeKind.WORK
  //startTime: string
  //endTime: string
  //breakMinutes: number

  projectId: string
  project?: {
    id: string
    city: string
    address: string
    images?: any[]
  }
}

export interface ExtraDayEntry extends BaseDayEntry, TimedEntry {
  type: typeof TimeKind.EXTRA
  projectId: string
  //startTime: string
  //endTime: string
  //breakMinutes: number
  project?: {
    id: string
    city: string
    address: string
    images?: any[]
  }
}

export interface AbsenceDayEntry extends BaseDayEntry {
 
  type: 
    | typeof TimeKind.SICK
    | typeof TimeKind.VAB
    | typeof TimeKind.VACATION
    | typeof TimeKind.DAY_OFF
    | typeof TimeKind.RED_DAY
}

export interface MeetingDayEntry extends BaseDayEntry, TimedEntry {
  type: typeof TimeKind.MEETING
}

export type DayEntry =
  | WorkDayEntry
  | ExtraDayEntry
  | AbsenceDayEntry
  | MeetingDayEntry

export function isWorkEntry(
  e: DayEntry
): e is WorkDayEntry {
  return e.type === TimeKind.WORK
}

export function isExtraEntry(
  e: DayEntry
): e is ExtraDayEntry {
  return e.type === TimeKind.EXTRA
}

export function isMeetingEntry(
  e: DayEntry
): e is MeetingDayEntry {
  return e.type === TimeKind.MEETING
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