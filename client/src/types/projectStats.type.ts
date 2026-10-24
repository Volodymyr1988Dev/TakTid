import type { ProjectUserStat } from './projectUserStat.type'

export interface ProjectStats {
  project: {
    id: string
    city: string
    address: string
    areaM2?: number | null
    pricePerM2?: number | null
    pricePerExtraH?: number | null

    startDate?: string | null
    lastWorkDate?: string | null
    endDate?: string | null
    durationDays?: number | null
    isCompleted?: boolean
  }

  users: ProjectUserStat[]

  total: {
    work: number
    extra: number
    all: number
  }
  totalProjectPrice: number
  baseProjectPrice: number
  extraHoursPrice: number
}