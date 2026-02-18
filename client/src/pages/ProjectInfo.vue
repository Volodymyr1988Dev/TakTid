<script setup lang="ts">
import { ref, watch, computed, onMounted, onBeforeUnmount } from 'vue'
import { getProjectStats } from '../api/projectStats.api'
import { useProjectImageStore } from '../stores/projectImage.store'
import AppLoader from '../components/ui/AppLoader.vue'

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

const props = defineProps<{ projectId: string }>()
const emit = defineEmits<{ (e: 'back'): void }>()

const stats = ref<ProjectStats | null>(null)
const loading = ref(true)

const imageStore = useProjectImageStore()
const showImages = ref(false)
const fullscreenUrl = ref<string | null>(null)

const page = ref(1)
const limit = 6
const hasMore = ref(true)

const sentinel = ref<HTMLElement | null>(null)
let observer: IntersectionObserver | null = null

watch(() => props.projectId, loadStats, { immediate: true })

watch(showImages, async (val) => {
  if (val) {
    page.value = 1
    hasMore.value = true
    imageStore.images = []
    await loadImages()
  }
})

watch(fullscreenUrl, val => {
  document.body.style.overflow = val ? 'hidden' : ''
})

onMounted(() => {
  observer = new IntersectionObserver(
    entries => {
      if (entries[0]?.isIntersecting) {
        loadImages()
      }
    },
    { threshold: 0.1 }
  )

  if (sentinel.value) {
    observer.observe(sentinel.value)
  }
})

onBeforeUnmount(() => {
  observer?.disconnect()
})

async function loadStats() {
  loading.value = true
  try {
    const { data } = await getProjectStats(props.projectId)
    stats.value = data
  } finally {
    loading.value = false
  }
}

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

function openFullscreen(url: string) {
  fullscreenUrl.value = url
}

function closeFullscreen() {
  fullscreenUrl.value = null
}

const totalWork = computed(() => stats.value?.total.work ?? 0)
const totalExtra = computed(() => stats.value?.total.extra ?? 0)
const totalAll = computed(() =>
  (stats.value?.total.work ?? 0) +
  (stats.value?.total.extra ?? 0)
)
</script>

<template>
  <div class="project-info">
    <button class="back" @click="emit('back')">
      ← Back
    </button>

    <AppLoader
      v-if="loading"
      text="Loading project statistics..."
    />

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

    <button
      class="toggle-images"
      @click="showImages = !showImages"
    >
      {{ showImages ? 'Hide images' : 'Show project images' }}
    </button>

    <div v-if="showImages" class="images">
      <div class="masonry">
        <div
          v-for="img in imageStore.images"
          :key="img.id"
          class="masonry-item"
        >
          <img
            :src="img.url"
            @click="openFullscreen(img.url)"
          />
        </div>
      </div>

      <div ref="sentinel" class="sentinel" />

      <div v-if="imageStore.loading" class="loading-more">
        Loading more...
      </div>

      <div
        v-if="fullscreenUrl"
        class="fullscreen"
        @click.self="closeFullscreen"
      >
        <button class="close" @click="closeFullscreen">
          ✕
        </button>
        <img :src="fullscreenUrl" />
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
.toggle-images {
  margin-top: 16px;
}
.project-info {
  padding: 16px;
}

.images {
  margin-top: 16px;
}

.masonry {
  column-count: 2;
  column-gap: 12px;
}

@media (min-width: 768px) {
  .masonry {
    column-count: 3;
  }
}

.masonry-item {
  break-inside: avoid;
  margin-bottom: 12px;
}

.masonry-item img {
  width: 100%;
  border-radius: 10px;
  cursor: pointer;
  transition: transform .2s ease;
}

.masonry-item img:hover {
  transform: scale(1.02);
}

.sentinel {
  height: 1px;
}

.loading-more {
  text-align: center;
  padding: 12px;
  color: #777;
}

.fullscreen {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.fullscreen img {
  max-width: 95%;
  max-height: 95%;
}

.close {
  position: absolute;
  top: 16px;
  right: 16px;
  background: none;
  border: none;
  color: white;
  font-size: 28px;
  cursor: pointer;
}
</style>