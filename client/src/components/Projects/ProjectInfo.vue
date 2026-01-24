<script setup lang="ts">
import { ref, watch, computed } from 'vue'
//import api from '../../api/axios'
import { getProjectStats } from '../../api/projectStats.api'

type UserStat = {
  id: string
  name: string
  email: string
  workHours: number
  extraHours: number
  totalHours: number
}

type ProjectStats = {
  project: {
    id: string
    city: string
    address: string
  }
  users: UserStat[]
  total: {
    work: number
    extra: number
    all: number
  }
}

const props = defineProps<{
  projectId: string
}>()

const emit = defineEmits<{
  (e: 'back'): void
}>()

const stats = ref<ProjectStats | null>(null)
const loading = ref(true)
/*
const totals = computed(() => {
  const entries = entriesStore.byProject(props.projectId)

  return {
    work: entries.filter(e => e.kind === 'WORK').reduce((s,e)=>s+e.hours,0),
    extra: entries.filter(e => e.kind === 'EXTRA').reduce((s,e)=>s+e.hours,0),
  }
})
*/
watch(
  () => props.projectId,
  loadStats,
  { immediate: true }
)

async function loadStats() {
  loading.value = true
  try {
    const { data } = await getProjectStats(props.projectId)
    stats.value = data
  } finally {
    loading.value = false
  }
}

const totalWork = computed(() => stats.value?.total.work ?? 0)
const totalExtra = computed(() => stats.value?.total.extra ?? 0)
//const totalAll = computed(() => stats.value?.total.all ?? 0)
const totalAll = computed(() => {
  return (stats.value?.total.work ?? 0) + (stats.value?.total.extra ?? 0)
})
</script>

<template>
  <div class="project-info">
    <button 
      class="back"
      @click="emit('back')"
    >
      ← Back
    </button>

    <div v-if="loading">
      Loading…
    </div>

    <div v-else-if="stats">
      <h2>
        {{ stats.project.city }} – {{ stats.project.address }}
      </h2>

      <div class="summary">
        <div>Work: <strong>{{ totalWork }} h</strong></div>
        <div>Extra: <strong>{{ totalExtra }} h</strong></div>
        <div>Total: <strong>{{ totalAll }} h</strong></div>
      </div>

      <hr>

      <div
        v-for="u in stats.users"
        :key="u.id"
        class="user-row"
      >
        <div class="user-main">
          <strong>{{ u.name }}</strong>
          <span class="email">{{ u.email }}</span>
        </div>

        <div class="hours">
          <span>Work: {{ u.workHours }}h</span>
          <span>Extra: {{ u.extraHours }}h</span>
          <strong>Total: {{ u.totalHours }}h</strong>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.project-info {
  padding: 16px;
}
.back {
  margin-bottom: 12px;
}
.summary {
  display: flex;
  gap: 16px;
  margin: 12px 0;
}
.user-row {
  padding: 12px 0;
  border-bottom: 1px solid #eee;
}
.user-main {
  display: flex;
  flex-direction: column;
}
.email {
  font-size: 12px;
  color: #777;
}
.hours {
  display: flex;
  gap: 12px;
  margin-top: 6px;
}
</style>