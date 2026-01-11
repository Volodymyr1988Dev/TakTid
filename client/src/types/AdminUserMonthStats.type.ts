export interface AdminUserMonthStats {
  user: {
    id: string
    email: string
    name?: string
  }
  workHours: number
  extraHours: number
  meetingHours: number
  sickDays: number
  vabDays: number
  vacationDays: number
}