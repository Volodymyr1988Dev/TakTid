import type { TimeKind } from "./timeKind.enum"

export interface TimeEntry {
  id: string
  //projectId?: string
  date: string
  hours: number
  type: TimeKind
  comment: string
  breakMinutes: number
  project?: {
    id: string
    city: string
    address: string
  }
}