import api from './axios'

export function createExtraWork(payload: {
  projectId: string
  date: string
  comment?: string
  startTime?: string
  endTime?: string
  breakMinutes?: number
}) {
  return api.post('/project-assignments', payload)
}

export function getProjectAssignments(from: string, to: string) {
  return api
    .get('/project-assignments', { params: { from, to } })
    .then(r => r.data)
}

export function updateExtraWork(id: string, payload: {
    comment?: string
    startTime?: string
    endTime?: string
    breakMinutes?: number},) {
  return api.patch(`/project-assignments/${id}`, payload)
}

export function deleteExtraWork(id: string) {
  return api.delete(`/project-assignments/${id}`)
}