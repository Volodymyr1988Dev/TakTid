//import type { TimeEntry } from './TimeEntry.type'
import type { TimeKind } from './timeKind.enum'
import type { Project } from './Project.dto'
/*
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
      */
  export type DayEntry =
  | WorkDayEntry
  | ExtraDayEntry
  | AbsenceDayEntry

interface BaseDayEntry {
  id: string
  date: string
  hours: number
  kind: 'WORK' | 'EXTRA' | 'ABSENCE'
  /**
   * UI-only joined project
   */
  project?: Project
}

/**
 * WORK = regular TimeEntry
 */
export interface WorkDayEntry extends BaseDayEntry//, TimeEntry 
{
  kind: 'WORK'
  type: TimeKind
  //type: 'WORK'


  startTime: string
  endTime: string
  breakMinutes: number
  comment?: string

  projectId?: string
  project?: Project

}

/**
 * EXTRA = ProjectAssignment
 */
export interface ExtraDayEntry extends BaseDayEntry {
  kind: 'EXTRA'
  projectId: string
  comment?: string
  startTime: string
  endTime: string
  breakMinutes: number
}

/**
 * ABSENCE = vacation / sick / vab
 */
export interface AbsenceDayEntry extends BaseDayEntry {
  kind: 'ABSENCE'
  //type: TimeKind
  type: 'SICK' | 'VAB' | 'VACATION'
  comment?: string
}

export function isWorkEntry(e: DayEntry): e is WorkDayEntry {
  return e.kind === 'WORK'
}

export function isExtraEntry(e: DayEntry): e is ExtraDayEntry {
  return e.kind === 'EXTRA'
}

export function isAbsenceEntry(e: DayEntry): e is AbsenceDayEntry {
  return e.kind === 'ABSENCE'
}