import type { Project } from './Project.dto'
import { TimeKind } from './timeKind.enum'

/* ================= COMMON ================= */

interface BaseEntry {
  id: string
  date: string
  hours: number
  comment?: string
}

/* ================= TIME ================= */

export interface TimeDayEntry extends BaseEntry {
  kind: 'TIME'
  type: typeof TimeKind.WORK
       | typeof TimeKind.EXTRA

  startTime: string
  endTime: string
  breakMinutes: number

  projectId: string
  project?: Project
}

/* ================= ABSENCE ================= */

export interface AbsenceDayEntry extends BaseEntry {
  kind: 'ABSENCE'
  type: typeof TimeKind.SICK
       | typeof TimeKind.VAB
       | typeof TimeKind.VACATION
}

/* ================= UNION ================= */

export type DayEntry =
  | TimeDayEntry
  | AbsenceDayEntry

/* ================= GUARDS ================= */

export function isTimeEntry(
  e: DayEntry
): e is TimeDayEntry {
  return e.kind === 'TIME'
}

export function isAbsenceEntry(
  e: DayEntry
): e is AbsenceDayEntry {
  return e.kind === 'ABSENCE'
}