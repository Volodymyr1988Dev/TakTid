export interface ProjectUserEntry {
  id: string
  date: string
  type: string
  workHours: number
  extraHours: number
  comment: string | null

  hours: number
  startTime?: string | null
  endTime?: string | null
  breakMinutes?: number | null
  source: 'WORK' | 'EXTRA'
}
export type UserEntriesResponse = {
  user: {
    id: string
    name: string
    email: string
  }
  entries: ProjectUserEntry[]
}