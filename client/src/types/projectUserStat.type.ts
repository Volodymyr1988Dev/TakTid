export interface ProjectUserStat {
  id: string
  name: string
  email: string
  workHours: number
  extraHours: number
  totalHours: number

  currentSalary?: number | null
}