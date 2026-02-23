import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'

export function createWorkSuggestion(
  projectId: string,
  title = 'Work',
  breakMinutes?: number
): TimeSuggestion {
  return {
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
    type: TimeKind.EXTRA,
    title,
    projectId,
    breakMinutes,
  }
}

export function createMeetingSuggestion(
  title = 'Meeting'
): TimeSuggestion {
  return {
    type: TimeKind.MEETING,
    title,
  }
}

export function createAbsenceSuggestion(
  type:
    | typeof TimeKind.SICK
    | typeof TimeKind.VAB
    | typeof TimeKind.VACATION
    | typeof TimeKind.DAY_OFF
    | typeof TimeKind.RED_DAY,
  title: string
): TimeSuggestion {
  return {
    type,
    title,
  }
}