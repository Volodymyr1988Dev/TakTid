import { TimeKind } from './timeKind.enum'
//import type { WorkKind, AbsenceKind } from './timeKind.enum'
import type {
  TimeSuggestion,
  WorkSuggestion,
  AbsenceSuggestion,
} from './Suggestion.type'

export function isWorkSuggestion(
  s: TimeSuggestion
): s is WorkSuggestion {
  return (
    s.type === TimeKind.WORK ||
    s.type === TimeKind.EXTRA
  )
}

export function isAbsenceSuggestion(
  s: TimeSuggestion
): s is AbsenceSuggestion {
  return (
    s.type === TimeKind.SICK ||
    s.type === TimeKind.VAB ||
    s.type === TimeKind.VACATION ||
    s.type === TimeKind.DAY_OFF ||
    s.type === TimeKind.RED_DAY
  )
}