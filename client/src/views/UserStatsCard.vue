<script setup lang="ts">
import { ref } from 'vue'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'
//import StatsRow from './StatsRow.vue'

defineProps<{ stats: AdminUserMonthStats }>()

const open = ref(false)
</script>

<template>
  <div class="card">
    <header @click="open = !open">
      <strong>{{ stats.user.email }}</strong>
    </header>

    <div v-if="open">
      <StatsRow
        label="Work"
        :value="stats.workHours + ' h'"
      />
      <StatsRow
        label="Extra"
        :value="stats.extraHours + ' h'"
      />
      <StatsRow
        label="Sick days"
        :value="stats.sickDays"
      />
      <StatsRow
        label="VAB days"
        :value="stats.vabDays"
      />
      <StatsRow
        label="Vacation days"
        :value="stats.vacationDays"
      />
    </div>
  </div>
</template>