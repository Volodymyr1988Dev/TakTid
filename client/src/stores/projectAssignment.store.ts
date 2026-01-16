import { defineStore } from 'pinia'
import * as api from '../api/projectAssignment.api'

export const useProjectAssignmentStore = defineStore('projectAssignment', () => {
  async function create(payload: {
    projectId: string
    date: string
    comment?: string
  }) {
    await api.createExtraWork(payload)
  }

  async function update(id: string, text: string) {
    await api.updateExtraWork(id, text)
  }

  async function remove(id: string) {
    await api.deleteExtraWork(id)
  }

  return { create, update, remove }
})