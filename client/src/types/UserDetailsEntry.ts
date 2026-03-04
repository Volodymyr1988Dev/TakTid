export interface UserDetailsEntry {
  id: string
  date: string
  type: string
  hours: number
  comment: string | null
  project?: {
    city: string
    address: string
  }
}