import api from '../api/axios'
import { defineStore } from 'pinia'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'

export const useStatsStore = defineStore('stats', {
  state: () => ({
    users: [] as AdminUserMonthStats[],
  }),

  actions: {
    async loadMonth(year: number, month: number) {
      const { data } = await api.get<AdminUserMonthStats[]>(
        '/time-entries/stats/month/admin',
        { params: { year, month } },
      )

      this.users = data
    },
  },
})