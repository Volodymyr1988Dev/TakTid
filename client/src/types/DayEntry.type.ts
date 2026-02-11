import type { TimeKind } from './timeKind.enum'
import type { Project } from './Project.dto'

/* ================= BASE ================= */

interface BaseDayEntry {
  id: string
  date: string
  hours: number
  comment?: string
  project?: Project
}

/* ================= WORK ================= */

export interface WorkDayEntry extends BaseDayEntry {
  kind: 'WORK'
  type: typeof TimeKind.WORK

  startTime: string
  endTime: string
  breakMinutes: number

  projectId: string
}

/* ================= EXTRA ================= */

export interface ExtraDayEntry extends BaseDayEntry {
  kind: 'EXTRA'

  projectId: string
  startTime: string
  endTime: string
  breakMinutes: number
}

/* ================= ABSENCE ================= */

export interface AbsenceDayEntry extends BaseDayEntry {
  kind: 'ABSENCE'
  type:
    | typeof TimeKind.SICK
    | typeof TimeKind.VAB
    | typeof TimeKind.VACATION
}

/* ================= UNION ================= */

export type DayEntry =
  | WorkDayEntry
  | ExtraDayEntry
  | AbsenceDayEntry

/* ================= GUARDS ================= */

export function isWorkEntry(
  e: DayEntry
): e is WorkDayEntry {
  return e.kind === 'WORK'
}

export function isExtraEntry(
  e: DayEntry
): e is ExtraDayEntry {
  return e.kind === 'EXTRA'
}

export function isAbsenceEntry(
  e: DayEntry
): e is AbsenceDayEntry {
  return e.kind === 'ABSENCE'
}