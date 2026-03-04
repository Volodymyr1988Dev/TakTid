export interface StatsEntry {
  id: string
  date: string
  type: string
  hours: number
  project?: {
    city: string
    address: string
  }
  comment?: string
}