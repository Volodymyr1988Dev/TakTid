
import { defineStore } from 'pinia'
import { ref } from 'vue'

import type { TimePeriodStatus } from '../types/TimePeriodLock.type'

import {
  getPeriodStatus,
  closeWeek,
  unlockWeek,
} from '../api/timePeriodLock.api'

function getMonday(date: string): string {
  const parsed = new Date(`${date}T00:00:00.000Z`)
  const day = parsed.getUTCDay()

  parsed.setUTCDate(
    parsed.getUTCDate() + (day === 0 ? -6 : 1 - day),
  )

  return parsed.toISOString().slice(0, 10)
}

export const useTimePeriodLockStore = defineStore(
  'timePeriodLock',
  () => {
    // Статус вибраного тижня
    const status = ref<TimePeriodStatus | null>(null)

    // Статуси всіх завантажених тижнів.
    // Ключ — дата понеділка ISO-тижня.
    const statuses = ref<Record<string, TimePeriodStatus>>({})

    const loading = ref(false)
    //let requestId = 0
    let activeRequestId = 0

    async function loadStatus(
      date: string,
      setCurrent = true,
    ): Promise<TimePeriodStatus> {
      //const currentRequest = ++requestId
      const currentRequest = setCurrent
        ? ++activeRequestId
        : 0

      if (setCurrent) {
        loading.value = true
        status.value = null
      }

      try {
        const result = await getPeriodStatus(date)

        statuses.value = {
          ...statuses.value,
          [result.periodStart]: result,
        }

        if (setCurrent && currentRequest === activeRequestId) {
          status.value = result
        }

        return result
      } finally {
        if (setCurrent && currentRequest === activeRequestId) {
          loading.value = false
        }
      }
    }

    function getStatusForDate(date: string) {
      const monday = getMonday(date)
      return statuses.value[monday] ?? null
    }

    async function close(date: string) {
      await closeWeek(date)
      return loadStatus(date)
    }

    async function unlock(date: string) {
      await unlockWeek(date)
      return loadStatus(date)
    }

    function reset() {
      activeRequestId++
      status.value = null
      statuses.value = {}
      loading.value = false
    }

    return {
      status,
      statuses,
      loading,
      loadStatus,
      getStatusForDate,
      close,
      unlock,
      reset,
    }
  },
)
