import { defineStore } from 'pinia'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'
import { getMonthStats } from '../api/stats.api'

export const useStatsStore = defineStore('stats', {
  state: () => ({
    users: [] as AdminUserMonthStats[],
    loading: false,
  }),

  actions: {
    async loadMonth(year: number, month: number) {
      this.loading = true
      this.users = await getMonthStats(year, month)
      this.loading = false
    },
  },
})