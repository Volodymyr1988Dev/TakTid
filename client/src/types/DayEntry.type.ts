import { TimeKind } from './timeKind.enum'
import type { Project } from './Project.dto'

/* ================= BASE ================= */

interface BaseDayEntry {
  id: string
  date: string
  hours: number
  comment?: string
  type: TimeKind
  project?: Project
}

/* ================= WORK ================= */

export interface WorkDayEntry extends BaseDayEntry {
  //kind: 'WORK'
  type: typeof TimeKind.WORK
  //type: 'WORK'
  //type: WorkKind
  startTime: string
  endTime: string
  breakMinutes: number

  projectId: string
  project?: {
    id: string
    city: string
    address: string
    images?: any[]
  }
}

/* ================= EXTRA ================= */

export interface ExtraDayEntry extends BaseDayEntry {
  //kind: 'EXTRA'
  //type: 'EXTRA'
  type: typeof TimeKind.EXTRA//WorkKind
  projectId: string
  startTime: string
  endTime: string
  breakMinutes: number
  project?: {
    id: string
    city: string
    address: string
    images?: any[]
  }
}

/* ================= ABSENCE ================= */

export interface AbsenceDayEntry extends BaseDayEntry {
  //kind: 'ABSENCE'
 
  type: 
    | typeof TimeKind.SICK //typeof TimeKind.SICK
    | typeof TimeKind.VAB //typeof TimeKind.VAB
    | typeof TimeKind.VACATION
    | typeof TimeKind.DAY_OFF //typeof TimeKind.VACATION
   //type: 'SICK' | 'VAB' | 'VACATION'
   //type: AbsenceKind
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
  //return e.kind === TimeKind.WORK //'WORK'
  return e.type === TimeKind.WORK//'WORK'
}

export function isExtraEntry(
  e: DayEntry
): e is ExtraDayEntry {
  //return e.kind === TimeKind.EXTRA //'EXTRA'
  return e.type === TimeKind.EXTRA//'EXTRA'
}

export function isAbsenceEntry(
  e: DayEntry
): e is AbsenceDayEntry {
  //return e.kind === 'ABSENCE'
   //return  e.type === 'SICK' || e.type === 'VAB' || e.type === 'VACATION' || e.type === 'DAY_OFF'
  return (
    e.type === TimeKind.SICK ||
    e.type === TimeKind.VAB ||
    e.type === TimeKind.VACATION ||
    e.type === TimeKind.DAY_OFF
  )
  }