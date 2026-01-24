import type { ProjectUserStat } from './projectUserStat.type'

export interface ProjectStats {
  project: {
    id: string
    city: string
    address: string
  }

  users: ProjectUserStat[]

  total: {
    work: number
    extra: number
    all: number
  }
}