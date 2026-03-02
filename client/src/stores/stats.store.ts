import { defineStore } from 'pinia'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'
import type { ProjectUserEntry } from '../types/ProjectUserEntry'
import { getMonthStats, getUserMonthDetails } from '../api/stats.api'
import { getUserProjectEntries } from '../api/projectStats.api'

export const useStatsStore = defineStore('stats', {
  state: () => ({
    users: [] as AdminUserMonthStats[],
    loading: false,
    details: {} as Record<string, any>,

    //monthDetails: {} as Record<string, any>,
    projectUserEntries: {} as Record<string, ProjectUserEntry[]>,
    loadingProjectUserId: null as string | null,
    
  }),

  actions: {
    async loadMonth(year: number, month: number) {
      this.loading = true
      this.users = await getMonthStats(year, month)
      this.loading = false
    },
    async loadUserDetails(userId: string, year: number, month: number) {
      //this.monthDetails[userId]=
      this.details[userId]
        await getUserMonthDetails(userId, year, month);
    },
    async loadProjectUserEntries(projectId: string, userId: string) {
      const key = `${projectId}-${userId}`

      if (this.projectUserEntries[key]) return

      this.loadingProjectUserId = userId

      this.projectUserEntries[key] = []

      try {
        const { data } = await getUserProjectEntries(projectId, userId)

        this.projectUserEntries[key] = data
      } catch (e) {
        delete this.projectUserEntries[key]
      } finally {
        this.loadingProjectUserId = null
      }
    }
  },
})