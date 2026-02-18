import api from './axios'
import type { ProjectImage } from '../types/ProjectImage.type'

export interface PaginatedImagesResponse {
  data: ProjectImage[]
  total: number
  page: number
  lastPage: number
}

export function uploadProjectImages(
  projectId: string,
  files: File[],
) {
  const formData = new FormData()

  files.forEach(file => {
    formData.append('files', file)
  })

  return api.post<ProjectImage[]>(
    `/project-images/${projectId}`,
    formData,
  )
}

export function getProjectImages(projectId: string) {
  return api.get<ProjectImage[]>(
    `/project-images/project/${projectId}`,
  )
}

export function getProjectImagesPaginated(
  projectId: string,
  page: number,
  limit: number,
) {
  return api.get<PaginatedImagesResponse>(
    `/project-images/project/${projectId}?page=${page}&limit=${limit}`,
  )
}

export function removeProjectImage(imageId: string) {
  return api.delete(`/project-images/${imageId}`)
}