//import type { WorkKind, AbsenceKind, MeetingKind, TimeKind } from './timeKind.enum'
import type { TimeKind } from './timeKind.enum'

export type WorkSuggestion = {
  type: typeof TimeKind.WORK | typeof TimeKind.EXTRA//WorkKind
  title: string
  projectId: string
  breakMinutes?: number
}

export type AbsenceSuggestion = {
  //type: AbsenceKind
   type:
    | typeof TimeKind.SICK
    | typeof TimeKind.VAB
    | typeof TimeKind.VACATION
    | typeof TimeKind.DAY_OFF
    | typeof TimeKind.RED_DAY
  title: string
}

export type InternalSuggestion = {
  //type: MeetingKind
  type: typeof TimeKind.MEETING
  title: string
}

export type TimeSuggestion =
  | WorkSuggestion
  | AbsenceSuggestion
  | InternalSuggestion