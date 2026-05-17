import api from './axios'
import type { Project } from '../types/Project.dto'

export async function getProjects(): Promise<Project[]> {
  const { data } = await api.get<Project[]>('/projects')
  return data
}

export async function deleteProjectApi(id: string): Promise<void> {
  await api.delete(`/projects/${id}`)
}

export async function getProjectDetails(projectId: string) {
  const { data } = await api.get(`/projects/${projectId}/details`)
  return data
}

export async function updateProjectApi(
  id: string,
  data: Partial<Project>,
): Promise<Project> {

  const response = await api.patch<Project>(
    `/projects/${id}`,
    data
  )

  return response.data
}