import { defineStore } from 'pinia'
import * as api from '../api/projectAssignment.api'

export const useProjectAssignmentStore = defineStore('projectAssignment', () => {
  async function create(payload: {
     projectId: string
      date: string
      comment?: string
      startTime?: string
      endTime?: string
      breakMinutes?: number
  }) {
    await api.createExtraWork(payload)
  }

  async function update(id: string, payload: {
        comment?: string
        startTime?: string
        endTime?: string
        breakMinutes?: number
  }) {
    await api.updateExtraWork(id, payload)
  }

  async function remove(id: string) {
    await api.deleteExtraWork(id)
  }

  return { create, update, remove }
})