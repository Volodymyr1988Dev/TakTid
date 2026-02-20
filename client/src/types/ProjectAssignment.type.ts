export interface ProjectAssignment {
  id: string
  date: string
  hours: number
  comment?: string | null
  startTime: string
  endTime: string
  breakMinutes: number | null

  project: {
    id: string
    city: string
    address: string
  }
  user?: {
    id: string
    email?: string
  }
}
