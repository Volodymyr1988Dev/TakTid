import type { TimeKind } from "./timeKind.enum";

export interface TimeSuggestion {
  projectId?: string
  type: TimeKind
  title: string
  breakMinutes?: number
}