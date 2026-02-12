<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useStatsStore } from '../../../stores/stats.store'

const stats = useStatsStore()
const expanded = ref<Record<string, boolean>>({})
const detailsOpen = ref<Record<string, boolean>>({})

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

async function load() {
  await stats.loadMonth(year.value, month.value)
  expanded.value = {}
  detailsOpen.value = {}
}
async function loadDetails(userId: string) {
  if (!stats.details[userId]) {
    await stats.loadUserDetails(userId, year.value, month.value)
  }
  detailsOpen.value[userId] = !detailsOpen.value[userId]
}
function typeClass(type: string) {
  switch (type) {
    case 'WORK':
      return 'badge work'
    case 'EXTRA_WORK':
      return 'badge extra'
    case 'SICK':
      return 'badge sick'
    case 'VACATION':
      return 'badge vacation'
    case 'VAB':
      return 'badge vab'
    default:
      return 'badge'
  }
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

    <div 
      v-if="stats.loading" 
      class="loading"
    >
      Loading...
    </div>

    <div
      v-for="u in stats.users"
      :key="u.user.id"
      class="user-card"
    >
      <!-- HEADER -->
      <div
        class="header"
        @click="expanded[u.user.id] = !expanded[u.user.id]"
      >
        <div>
          <strong>{{ u.user.name }}</strong>
          <small>{{ u.user.email }}</small>
        </div>
        <div class="total">
          {{ u.totalHours }} h
        </div>
      </div>

      <!-- SUMMARY -->
      <div 
        v-if="expanded[u.user.id]" 
        class="details"
      >
        <div class="summary-grid">
          <div>Work: {{ u.workHours }} h</div>
          <div>Extra: {{ u.extraHours }} h</div>
          <div>Sick: {{ u.sickHours }} h ({{ u.sickDays }} days)</div>
          <div>VAB: {{ u.vabHours }} h ({{ u.vabDays }} days)</div>
          <div>Vacation: {{ u.vacationHours }} h ({{ u.vacationDays }} days)</div>
        </div>

        <button
          class="more-btn"
          @click.stop="loadDetails(u.user.id)"
        >
          {{ detailsOpen[u.user.id] ? 'Hide details' : 'More details' }}
        </button>

        <!-- CALENDAR DETAILS -->
        <div
          v-if="detailsOpen[u.user.id] && stats.details[u.user.id]"
          class="calendar"
        >
          <div
            v-for="e in stats.details[u.user.id].entries"
            :key="e.id"
            class="calendar-entry"
          >
            <div class="entry-left">
              <div 
                class="date"
              >
                {{ e.date }}
              </div>
              <div :class="typeClass(e.type)">
                {{ e.type }}
              </div>
            </div>

            <div class="entry-center">
              <div class="hours">
                {{ e.hours }} h
              </div>

              <div v-if="e.startTime">
                {{ e.startTime }} - {{ e.endTime }}
                (break: {{ e.breakMinutes ?? 0 }}m)
              </div>

              <div 
                v-if="e.project" 
                class="project"
              >
                {{ e.project.city }} – {{ e.project.address }}
              </div>

              <div 
                v-if="e.comment" 
                class="comment"
              >
                "{{ e.comment }}"
              </div>
            </div>
          </div>

          <div
            v-if="!stats.details[u.user.id].entries.length"
            class="empty"
          >
            No entries for this period
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-page {
  padding: 24px;
  max-width: 900px;
  margin: auto;
}

.controls {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.controls input {
  padding: 6px;
  width: 100px;
}

.controls button {
  padding: 6px 12px;
  cursor: pointer;
}

.loading {
  margin-bottom: 20px;
}

.user-card {
  border: 1px solid #ddd;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  background: #fff;
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}

.header {
  display: flex;
  justify-content: space-between;
  cursor: pointer;
}

.header small {
  display: block;
  color: #666;
  font-size: 12px;
}

.total {
  font-size: 18px;
  font-weight: bold;
}

.details {
  margin-top: 16px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 8px;
  margin-bottom: 12px;
}

.more-btn {
  margin-bottom: 16px;
  padding: 6px 12px;
  cursor: pointer;
}

.calendar {
  border-top: 1px solid #eee;
  padding-top: 12px;
}

.calendar-entry {
  display: flex;
  gap: 16px;
  padding: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.entry-left {
  width: 120px;
}

.date {
  font-weight: bold;
}

.entry-center {
  flex: 1;
}

.hours {
  font-weight: bold;
}

.project {
  color: #444;
}

.comment {
  font-style: italic;
  color: #666;
}

.empty {
  padding: 12px;
  color: #999;
}

/* BADGES */
.badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 8px;
  font-size: 12px;
  margin-top: 4px;
  background: #ccc;
  color: white;
}

.work { background: #2ecc71; }
.extra { background: #f39c12; }
.sick { background: #e74c3c; }
.vacation { background: #3498db; }
.vab { background: #9b59b6; }
</style>