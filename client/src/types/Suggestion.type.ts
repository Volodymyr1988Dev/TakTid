/*import type { TimeKind } from "./timeKind.enum";

export interface TimeSuggestion {
  projectId?: string
  type: TimeKind
  title: string
  breakMinutes?: number
}*/
import { TimeKind } from "./timeKind.enum"
export type TimeSuggestion =
  | {
      kind: 'WORK'
      type: typeof TimeKind.WORK
      title: string
      projectId: string
      breakMinutes?: number
    }
  | {
      kind: 'EXTRA'
      type: typeof TimeKind.EXTRA
      title: string
      projectId: string
      breakMinutes?: number
    }
  | {
      kind: 'ABSENCE'
      type:
        | typeof TimeKind.SICK
        | typeof TimeKind.VAB
        | typeof TimeKind.VACATION
      title: string
    }