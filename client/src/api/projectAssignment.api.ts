import api from './axios'

export function createExtraWork(payload: {
  projectId: string
  date: string
  //text: string
}) {
  return api.post('/project-assignments', payload)
}

export function updateExtraWork(id: string, text: string) {
  return api.patch(`/project-assignments/${id}`, { text })
}

export function deleteExtraWork(id: string) {
  return api.delete(`/project-assignments/${id}`)
}