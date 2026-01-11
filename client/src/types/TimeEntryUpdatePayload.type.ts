import { TimeKind } from './timeKind.enum'

export interface TimeEntryUpdatePayload {
  type?: TimeKind
  projectId?: string
  startTime?: string
  endTime?: string
  breakMinutes?: number
  comment?: string
}