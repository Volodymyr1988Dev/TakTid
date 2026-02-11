import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'

export function createWorkSuggestion(
  projectId: string,
  title = 'Work',
  breakMinutes?: number
): TimeSuggestion {
  return {
    kind: 'WORK',
    type: TimeKind.WORK,
    title,
    projectId,
    breakMinutes,
  }
}

export function createExtraSuggestion(
  projectId: string,
  title = 'Extra',
  breakMinutes?: number
): TimeSuggestion {
  return {
    kind: 'EXTRA',
    type: TimeKind.EXTRA,
    title,
    projectId,
    breakMinutes,
  }
}

export function createAbsenceSuggestion(
  type:
    | typeof TimeKind.SICK
    | typeof TimeKind.VAB
    | typeof TimeKind.VACATION,
  title: string
): TimeSuggestion {
  return {
    kind: 'ABSENCE',
    type,
    title,
  }
}