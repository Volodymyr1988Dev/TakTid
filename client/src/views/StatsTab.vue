<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useStatsStore } from '../stores/stats.store'

const store = useStatsStore()
const expanded = ref<Record<string, boolean>>({})

onMounted(() => {
  store.loadMonth(2026, 1)
})

function toggle(userId: string) {
  expanded.value[userId] = !expanded.value[userId]
}
</script>

<template>
  <div 
    v-for="u in store.users"

    :key="u.user.id"
  >
    <h3 @click="toggle(u.user.id)">
      {{ u.user.name ?? u.user.email }}
    </h3>

    <div v-if="expanded[u.user.id]">
      <StatsCard
        title="Work" 
        :value="u.workHours + ' h'" 
      />
      <StatsCard 
        title="Extra" 
        :value="u.extraHours + ' h'" 
      />
      <StatsCard 
        title="Meetings" 
        :value="u.meetingHours + ' h'" 
      />

      <StatsCard 
        title="Sick days" 
        :value="u.sickDays" 
      />
      <StatsCard 
        title="VAB days" 
        :value="u.vabDays" 
      />
      <StatsCard 
        title="Vacation days" 
        :value="u.vacationDays" 
      />
    </div>
  </div>
</template>