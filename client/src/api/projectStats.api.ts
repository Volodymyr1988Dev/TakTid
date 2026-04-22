import api from './axios'
import type { ProjectStats } from '../types/projectStats.type'
import type { ProjectUserEntry } from '../types/ProjectUserEntry'

export function getProjectStats(projectId: string) {
  return api.get<ProjectStats>(`/projects/${projectId}/stats`)
}

export async function getUserProjectEntries(
  projectId: string,
  userId: string
) {
  return api.get<ProjectUserEntry[]>(
     `/stats/project/${projectId}/users/${userId}`, {
    headers: {
      'Cache-Control': 'no-cache'
    }
  }
  )
}