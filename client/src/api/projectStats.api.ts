import api from './axios'
import type { ProjectStats } from '../types/projectStats.type'

export function getProjectStats(projectId: string) {
  return api.get<ProjectStats>(`/projects/${projectId}/stats`)
}