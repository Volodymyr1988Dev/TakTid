import { defineStore } from 'pinia'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'
import { getMonthStats, getUserMonthDetails } from '../api/stats.api'

export const useStatsStore = defineStore('stats', {
  state: () => ({
    users: [] as AdminUserMonthStats[],
    loading: false,
    details: {} as Record<string, any>,
  }),

  actions: {
    async loadMonth(year: number, month: number) {
      this.loading = true
      this.users = await getMonthStats(year, month)
      this.loading = false
    },
    async loadUserDetails(userId: string, year: number, month: number) {
      this.details[userId] =
        await getUserMonthDetails(userId, year, month);
    }
  },
})