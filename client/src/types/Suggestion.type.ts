/*import type { TimeKind } from "./timeKind.enum";

export interface TimeSuggestion {
  projectId?: string
  type: TimeKind
  title: string
  breakMinutes?: number
}*/
import type { WorkKind, AbsenceKind } from './timeKind.enum'

export type WorkSuggestion = {
  type: WorkKind
  title: string
  projectId: string
  breakMinutes?: number
}

export type AbsenceSuggestion = {
  type: AbsenceKind
  title: string
}

export type TimeSuggestion =
  | WorkSuggestion
  | AbsenceSuggestion