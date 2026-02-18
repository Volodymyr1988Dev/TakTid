<script setup lang="ts">
import { ref, watch, computed, onMounted } from 'vue'
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

const props = defineProps<{
  projectId: string
}>()

const emit = defineEmits<{
  (e: 'back'): void
}>()

const stats = ref<ProjectStats | null>(null)
const loading = ref(true)
const imageStore = useProjectImageStore()
const showImages = ref(false)
const fullscreenUrl = ref<string | null>(null)
const scrollContainer = ref<HTMLElement | null>(null)
const sentinel = ref<HTMLElement | null>(null)

const page = ref(1)
const limit = 5
const hasMore = ref(true)  
watch(
  () => props.projectId,
  loadStats,
  { immediate: true }
)
/*
watch(showImages, async (val) => {
  if (val) {
    await imageStore.load(props.projectId)
  }
})*/
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
  const observer = new IntersectionObserver(
    entries => {
      if (!entries[0]) return
      if (entries[0].intersectionRatio > 0) {
        loadImages()
      }
    },
    { threshold: 1 }
  )

  if (sentinel.value) {
    observer.observe(sentinel.value)
  }
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

function onScroll() {
  const el = scrollContainer.value
  if (!el) return

  const reachedBottom =
    el.scrollTop + el.clientHeight >= el.scrollHeight - 10

  if (reachedBottom) {
    loadImages()
  }
}

const totalWork = computed(() => stats.value?.total.work ?? 0)
const totalExtra = computed(() => stats.value?.total.extra ?? 0)
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
    <div 
      v-if="showImages" 
      ref="scrollContainer"
      class="images"
      @scroll.passive="onScroll"
    >
      <div v-if="imageStore.loading">
        Loading images…
      </div>
      <Swiper
        v-else
        :slides-per-view="1"
        navigation
        pagination
      >
        <SwiperSlide
          v-for="img in imageStore.images"
          :key="img.id"
        >
          <img
            class="slide-img"
            :src="img.url"
            @click="openFullscreen(img.url)"
          >  
        </SwiperSlide>
      </Swiper>
      <div
        v-if="fullscreenUrl"
        class="fullscreen"
        @click.self="closeFullscreen"
      >
        <button 
          class="close" 
          @click="closeFullscreen"
        >
          ✕
        </button>
        <img 
          :src="fullscreenUrl"
        >
      </div>
      <div ref="sentinel" />
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
.images {
  margin-top: 12px;
}
.slide-img {
  width: 100%;
  max-height: 300px;
  object-fit: contain;
  cursor: pointer;
  border-radius: 8px;
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
.images {
  max-height: 400px;
  overflow-y: auto;
}
</style>