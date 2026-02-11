//import { TimeKind } from './timeKind.enum'
import type { TimeSuggestion } from './Suggestion.type'


export function isWorkSuggestion(
  s: TimeSuggestion
): s is Extract<TimeSuggestion, { kind: 'WORK' }> {
  return s.kind === 'WORK'
}

export function isExtraSuggestion(
  s: TimeSuggestion
): s is Extract<TimeSuggestion, { kind: 'EXTRA' }> {
  return s.kind === 'EXTRA'
}

export function isAbsenceSuggestion(
  s: TimeSuggestion
): s is Extract<TimeSuggestion, { kind: 'ABSENCE' }> {
  return s.kind === 'ABSENCE'
}