import api from './axios'
import type { Project } from '../types/Project.dto'

export async function getProjects(): Promise<Project[]> {
  const { data } = await api.get<Project[]>('/projects')
  return data
}