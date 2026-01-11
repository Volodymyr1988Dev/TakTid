<script setup lang="ts">
import { ref, watch } from 'vue'
import { getAdminMonthStats } from '../api/TimeEntry.api'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'

const year = ref(new Date().getFullYear())
const month = ref(new Date().getMonth() + 1)

const stats = ref<AdminUserMonthStats[]>([])

watch([year, month], async () => {
  stats.value = await getAdminMonthStats(year.value, month.value)
}, { immediate: true })
</script>

<template>
  <div class="filters">
    <select v-model.number="year">
      <option v-for="y in [2024,2025,2026]" :key="y" :value="y">{{ y }}</option>
    </select>

    <select v-model.number="month">
      <option v-for="m in 12" :key="m" :value="m">{{ m }}</option>
    </select>
  </div>

  <UserStatsCard
    v-for="u in stats"
    :key="u.user.id"
    :stats="u"
  />
</template>