import api from './axios'
import type { ProjectImage } from '../types/ProjectImage.type'

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

export function removeProjectImage(imageId: string) {
  return api.delete(`/project-images/${imageId}`)
}