import api from '../api/axios'
import { defineStore } from 'pinia'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'

export const useStatsStore = defineStore('stats', {
  state: () => ({
    users: [] as AdminUserMonthStats[],
  }),

  actions: {
    async loadMonth(year: number, month: number) {
      this.users = await api.get(`/time-entries/stats/month`, {
        params: { year, month },
      })
    },
  },
})