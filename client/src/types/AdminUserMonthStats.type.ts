export interface AdminUserMonthStats {
  user: {
    id: string
    email: string
    name?: string
  }
  workHours: number
  extraHours: number
  meetingHours: number
  sickHours: number
  sickDays: number
  vabHours: number
  vabDays: number
  vacationHours: number
  vacationDays: number
  redDayHours: number
  redDayDays: number

  totalHours: number
}