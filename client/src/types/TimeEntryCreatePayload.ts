import { TimeKind } from './timeKind.enum'

export interface TimeEntryCreatePayload {
  date: string
  type: TimeKind
  projectId?: string
  startTime?: string
  endTime?: string
  breakMinutes?: number
  comment?: string
}