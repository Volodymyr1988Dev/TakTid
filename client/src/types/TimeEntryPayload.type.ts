import { TimeKind } from './timeKind.enum'

export interface TimeEntryPayload {
  date: string
  type: TimeKind
  hours: number

  startTime: string
  endTime: string
  breakMinutes: number

  comment?: string
  projectId?: string
}