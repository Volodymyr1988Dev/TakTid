import type { ProjectUserStat } from './projectUserStat.type'

export interface ProjectStats {
  project: {
    id: string
    city: string
    address: string
    areaM2?: number | null
    pricePerM2?: number | null
  }

  users: ProjectUserStat[]

  total: {
    work: number
    extra: number
    all: number
  }
  totalProjectPrice: number
}