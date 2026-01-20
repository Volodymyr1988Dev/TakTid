import type { TimeKind } from "./timeKind.enum"

export interface TimeEntry {
  id: string
  //projectId?: string
  startTime: string
  endTime: string
  date: string
  hours: number
  type: TimeKind
  comment: string
  breakMinutes: number
  projectId: string
  photoUrl?: string
}