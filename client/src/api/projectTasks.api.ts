import api from './axios'
import type { ProjectTask } from '../types/ProjectTask'

export function getProjectTasks(projectId: string) {
  return api.get<ProjectTask[]>(`/projects/${projectId}/tasks`)
}

export function toggleTask(taskId: string) {
  return api.patch<ProjectTask>(`/projects/tasks/${taskId}/toggle`)
}

export function deleteTask(taskId: string) {
  return api.delete(`/projects/tasks/${taskId}`)
}

export function updateTask(
  taskId: string,
  dto: {
    title?: string
    note?: string | null
    reminder?: string | null
  },
) {
  return api.patch(
    `/projects/tasks/${taskId}`,
    dto,
  )
}

export function importTasks(
  projectId: string,
  files: File[],
) {
  const formData = new FormData()

  files.forEach(file => {
    formData.append(
      'files',
      file,
    )
  })

  return api.post(
    `/projects/${projectId}/import-tasks`,
    formData,
  )
}