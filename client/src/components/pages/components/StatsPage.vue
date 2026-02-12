<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useStatsStore } from '../../../stores/stats.store'

const stats = useStatsStore()
const expanded = ref<Record<string, boolean>>({})

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

async function load() {
  await stats.loadMonth(year.value, month.value)
}

onMounted(load)
</script>

<template>
  <div class="stats-page">
    <div class="controls">
      <input 
        v-model="year"
        type="number"  
      >
      <input
        v-model="month" 
        type="number" 
        min="1" 
        max="12" 
      >
      <button @click="load">
        Load
      </button>
    </div>

    <div v-if="stats.loading">
      Loading...
    </div>

    <div
      v-for="u in stats.users"
      :key="u.user.id"
      class="user-card"
    >
      <div
        class="header"
        @click="expanded[u.user.id] = !expanded[u.user.id]"
      >
        <strong>{{ u.user.name }}</strong>
        <span>{{ u.totalHours }} h</span>
      </div>

      <div 
        v-if="expanded[u.user.id]" 
        class="details"
      >
        <p>Work: {{ u.workHours }} h</p>
        <p>Extra: {{ u.extraHours }} h</p>
        <p>Sick: {{ u.sickHours }} h ({{ u.sickDays }} days)</p>
        <p>VAB: {{ u.vabHours }} h ({{ u.vabDays }} days)</p>
        <p>Vacation: {{ u.vacationHours }} h ({{ u.vacationDays }} days)</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-page {
  padding: 16px;
}

.controls {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.user-card {
  border: 1px solid #ddd;
  padding: 12px;
  margin-bottom: 8px;
  border-radius: 8px;
}

.header {
  display: flex;
  justify-content: space-between;
  cursor: pointer;
}

.details {
  margin-top: 8px;
  font-size: 14px;
}
</style>