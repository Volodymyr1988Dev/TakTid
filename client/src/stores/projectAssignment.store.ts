import { defineStore } from 'pinia'
import * as api from '../api/projectAssignment.api'
import type { ProjectAssignment } from '../types/ProjectAssignment.type'

export const useProjectAssignmentStore = defineStore('projectAssignment', () => {
  async function create(payload: {
     projectId: string
      date: string
      comment?: string
      startTime?: string
      endTime?: string
      breakMinutes?: number
  }): Promise<ProjectAssignment> {
    const { data } = await api.createExtraWork(payload)
    return data
  }

  async function update(id: string, payload: {
        comment?: string
        startTime?: string
        endTime?: string
        breakMinutes?: number
  }): Promise<ProjectAssignment> {
    const { data } = await api.updateExtraWork(id, payload)
    return data
  }

  async function remove(id: string) {
    await api.deleteExtraWork(id)
  }

  return { create, update, remove }
})