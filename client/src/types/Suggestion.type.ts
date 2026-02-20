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