export interface ProjectAssignment {
  id: string
  date: string
  hours: number
  comment?: string | null
  startTime?: string | null
  endTime?: string | null
  breakMinutes?: number | null

  project: {
    id: string
    //name?: string
    city: string
    address: string
  }
  user?: {
    id: string
    email?: string
  }
}
