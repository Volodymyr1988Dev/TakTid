<script setup lang="ts">
import {
  ref,
  watch,
  computed,
  onBeforeUnmount,
  nextTick,
  onServerPrefetch
} from 'vue'

import type { ProjectUserEntry } from '../types/ProjectUserEntry'
import type { ProjectStats } from '../types/projectStats.type'
import { getProjectStats, getUserProjectEntries } from '../api/projectStats.api'
import { useProjectImageStore } from '../stores/projectImage.store'
import AppLoader from '../components/ui/AppLoader.vue'

const props = defineProps<{ projectId: string }>()
const emit = defineEmits<{ (e: 'back'): void }>()

const imageStore = useProjectImageStore()

const stats = ref<ProjectStats | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

const expandedUserId = ref<string | null>(null)
const userEntries = ref<Record<string, ProjectUserEntry[]>>({})
const loadingUserId = ref<string | null>(null)

const cache = new Map<string, ProjectUserEntry[]>()

/* ================= LOAD STATS ================= */

async function loadStats() {
  loading.value = true
  error.value = null

  try {
    const { data } = await getProjectStats(props.projectId)
    stats.value = data
  } catch (err: unknown) {
    error.value =
      err instanceof Error
        ? err.message
        : 'Failed to load project statistics'
  } finally {
    loading.value = false
  }
}

watch(() => props.projectId, loadStats, { immediate: true })
onServerPrefetch(loadStats)

/* ================= USER DETAILS ================= */

async function toggleDetails(userId: string) {
  if (expandedUserId.value === userId) {
    expandedUserId.value = null
    return
  }

  expandedUserId.value = userId

  const cacheKey = `${props.projectId}-${userId}`

  if (cache.has(cacheKey)) {
    userEntries.value[userId] = cache.get(cacheKey)!
    return
  }

  userEntries.value[userId] = []
  loadingUserId.value = userId

  try {
    const { data } = await getUserProjectEntries(
      props.projectId,
      userId
    )

    userEntries.value[userId] = data
    cache.set(cacheKey, data)
  } finally {
    loadingUserId.value = null
  }
}

/* ================= PAGINATION IMAGES ================= */

const showImages = ref(false)
const page = ref(1)
const limit = 6
const hasMore = ref(true)

const sentinel = ref<HTMLElement | null>(null)
let observer: IntersectionObserver | null = null

watch(showImages, async (val) => {
  if (!val) {
    observer?.disconnect()
    return
  }

  page.value = 1
  hasMore.value = true
  imageStore.images = []

  await loadImages()
  await nextTick()
  observeSentinel()
})

async function loadImages() {
  if (!hasMore.value || imageStore.loading) return

  const res = await imageStore.loadPaginated(
    props.projectId,
    page.value,
    limit
  )

  if (res.page >= res.lastPage) {
    hasMore.value = false
  } else {
    page.value++
  }
}

function observeSentinel() {
  if (!sentinel.value) return

  observer?.disconnect()

  observer = new IntersectionObserver(async (entries) => {
    if (entries[0]?.isIntersecting) {
      await loadImages()
    }
  })

  observer.observe(sentinel.value)
}

onBeforeUnmount(() => observer?.disconnect())

/* ================= COMPUTED ================= */

const totalWork = computed(() => stats.value?.total.work ?? 0)
const totalExtra = computed(() => stats.value?.total.extra ?? 0)
const totalAll = computed(() => totalWork.value + totalExtra.value)
</script>

<template>
  <div class="project-info">
    <button 
      class="back" 
      @click="emit('back')"
    >
      ← Back
    </button>

    <AppLoader 
      v-if="loading" 
      text="Loading project..." 
    />

    <div 
      v-else-if="error" 
      class="error"
    >
      {{ error }}
    </div>

    <div v-else-if="stats">
      <h2>
        {{ stats.project.city }} – {{ stats.project.address }}
      </h2>

      <div class="summary">
        <div>Work <strong>{{ totalWork }}h</strong></div>
        <div>Extra <strong>{{ totalExtra }}h</strong></div>
        <div>Total <strong>{{ totalAll }}h</strong></div>
      </div>

      <!-- USERS -->
      <div
        v-for="u in stats.users"
        :key="u.id"
        class="user-card"
      >
        <div class="user-header">
          <div>
            <strong>{{ u.name }}</strong>
            <div class="email">
              {{ u.email }}
            </div>
          </div>

          <div class="hours">
            <span>{{ u.totalHours }}h</span>
            <button @click="toggleDetails(u.id)">
              {{ expandedUserId === u.id ? 'Hide' : 'Details' }}
            </button>
          </div>
        </div>

        <!-- DETAILS -->
        <div
          v-if="expandedUserId === u.id"
          class="details"
        >
          <div
            v-if="loadingUserId === u.id"
            class="details-skeleton"
          >
            <div
              v-for="n in 3"
              :key="n"
              class="line"
            />
          </div>

          <div v-else>
            <div
              v-for="entry in userEntries[u.id] || []"
              :key="entry.id"
              class="entry"
            >
              <div class="date">
                {{ entry.date }}
              </div>

              <div>
                {{ entry.hours }}h ({{ entry.type }})
              </div>

              <div
                v-if="entry.comment"
                class="comment"
              >
                {{ entry.comment }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- IMAGES -->
      <div class="images-section">
        <button @click="showImages = !showImages">
          {{ showImages ? 'Hide Images' : 'Show Images' }}
        </button>

        <div 
          v-if="showImages" 
          class="images-grid"
        >
          <img
            v-for="img in imageStore.images"
            :key="img.id"
            :src="img.url"
            class="image"
          >

          <div ref="sentinel" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.project-info { padding: 20px; max-width: 900px; margin:auto; }

.summary {
  display:flex;
  gap:20px;
  margin-bottom:20px;
}

.user-card {
  border:1px solid #eee;
  padding:16px;
  border-radius:12px;
  margin-bottom:12px;
  background:white;
  transition:.2s;
}

.user-card:hover {
  box-shadow:0 4px 12px rgba(0,0,0,.05);
}

.user-header {
  display:flex;
  justify-content:space-between;
  align-items:center;
}

.email { font-size:12px; color:#777; }

.details {
  margin-top:12px;
  padding:12px;
  background:#f8fafc;
  border-radius:10px;
}

.entry {
  padding:8px 0;
  border-bottom:1px solid #eee;
}

.images-grid {
  margin-top:16px;
  display:grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap:10px;
}

.image {
  width:100%;
  border-radius:8px;
}

.error {
  padding:16px;
  background:#fee2e2;
  color:#991b1b;
  border-radius:8px;
}
</style>