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
      type: 'WORK' | 'EXTRA'
      title: string
      projectId: string
      breakMinutes?: number
    }
  | {
      type: Exclude<TimeKind, 'WORK' | 'EXTRA'>
      title: string
    }