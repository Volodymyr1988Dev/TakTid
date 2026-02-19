<script setup lang="ts">
import {
  ref,
  watch,
  computed,
  onMounted,
  onBeforeUnmount,
  nextTick
} from 'vue'

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

const page = ref(1)
const limit = 6
const hasMore = ref(true)

const sentinel = ref<HTMLElement | null>(null)
let observer: IntersectionObserver | null = null

/* LIGHTBOX */
const currentIndex = ref<number | null>(null)
const startX = ref(0)

/* ========================= WATCHERS ========================= */

watch(() => props.projectId, loadStats, { immediate: true })

watch(showImages, async (val) => {
  if (val) {
    page.value = 1
    hasMore.value = true
    imageStore.images = []
    await loadImages()
    await nextTick()
    observeSentinel()
  } else {
    observer?.disconnect()
  }
})

watch(currentIndex, val => {
  document.body.style.overflow = val !== null ? 'hidden' : ''
})

/* ========================= LIFECYCLE ========================= */

onMounted(() => {
  observeSentinel()
})

onBeforeUnmount(() => {
  observer?.disconnect()
})

/* ========================= FUNCTIONS ========================= */

function observeSentinel() {
  if (!sentinel.value) return

  observer?.disconnect()

  observer = new IntersectionObserver(async entries => {
    if (entries[0]?.isIntersecting) {
      await loadImages()
    }
  }, { rootMargin: '200px' })

  observer.observe(sentinel.value)
}

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

/* ========================= LIGHTBOX ========================= */

function openLightbox(index: number) {
  currentIndex.value = index
}

function closeLightbox() {
  currentIndex.value = null
}

function nextImage() {
  if (currentIndex.value === null) return
  if (currentIndex.value < imageStore.images.length - 1) {
    currentIndex.value++
  }
}

function prevImage() {
  if (currentIndex.value === null) return
  if (currentIndex.value > 0) {
    currentIndex.value--
  }
}

/* ========================= SWIPE ========================= */

function touchStart(e: TouchEvent) {
  if (!e.touches[0]) return
  startX.value = e.touches[0].clientX
}

function touchEnd(e: TouchEvent) {
  if (!e.changedTouches[0]) return
  const diff = e.changedTouches[0].clientX - startX.value
  if (diff > 50) prevImage()
  if (diff < -50) nextImage()
}

/* ========================= COMPUTED ========================= */

const totalWork = computed(() => stats.value?.total.work ?? 0)
const totalExtra = computed(() => stats.value?.total.extra ?? 0)
const totalAll = computed(() =>
  (stats.value?.total.work ?? 0) +
  (stats.value?.total.extra ?? 0)
)

/* ========================= CLOUDINARY OPTIMIZATION ========================= */

function optimize(url: string) {
  return url.replace(
    '/upload/',
    '/upload/f_auto,q_auto/'
  )
}

function blur(url: string) {
  return url.replace(
    '/upload/',
    '/upload/w_50,e_blur:300,f_auto,q_auto/'
  )
}
</script>

<template>
  <div 
    class="project-info"
  >
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

    <div 
      v-else-if="stats"
    >
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
      class="images"
    >
      <div 
        class="masonry"
      >
        <div
          v-for="(img, index) in imageStore.images"
          :key="img.id"
          class="masonry-item"
          @click="openLightbox(index)"
        >
          <div 
            class="img-wrapper"
          >
            <img
              class="blur"
              :src="blur(img.url)"
            >

            <img
              class="real"
              :src="optimize(img.url)"
              loading="lazy"
            >
          </div>
        </div>
        <template v-if="imageStore.loading">
          <div
            v-for="n in 6"
            :key="'skeleton'+n"
            class="skeleton"
          />
        </template>
      </div>
      <div 
        ref="sentinel" 
        class="sentinel" 
      />
      <div
        v-if="currentIndex !== null"
        class="lightbox"
        @click.self="closeLightbox"
        @touchstart="touchStart"
        @touchend="touchEnd"
      >
        <button 
          class="nav left" 
          @click.stop="prevImage"
        >
          ‹
        </button>

        <img
          v-if="currentIndex !== null && imageStore.images[currentIndex]"
          :src="optimize(imageStore.images[currentIndex]!.url)"
        >
        <button 
          class="nav right" 
          @click.stop="nextImage"
        >
          ›
        </button>

        <button 
          class="close" 
          @click="closeLightbox"
        >
          ✕
        </button>
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

/* ===== Masonry ===== */

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

.img-wrapper {
  position: relative;
  overflow: hidden;
  border-radius: 10px;
}

.blur {
  width: 100%;
  filter: blur(20px);
  transform: scale(1.1);
  position: absolute;
}

.real {
  width: 100%;
  position: relative;
  z-index: 1;
  cursor: pointer;
  transition: transform .2s ease;
}

.real:hover {
  transform: scale(1.02);
}

.skeleton {
  height: 200px;
  background: linear-gradient(
    90deg,
    #eee 25%,
    #ddd 37%,
    #eee 63%
  );
  background-size: 400% 100%;
  animation: shimmer 1.2s infinite;
  border-radius: 10px;
  margin-bottom: 12px;
}

@keyframes shimmer {
  0% { background-position: 100% 0 }
  100% { background-position: -100% 0 }
}

.sentinel {
  height: 1px;
}

/* ===== Lightbox ===== */

.lightbox {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.95);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.lightbox img {
  max-width: 95%;
  max-height: 95%;
}

.nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 40px;
  color: white;
  cursor: pointer;
}

.left { left: 20px; }
.right { right: 20px; }

.close {
  position: absolute;
  top: 20px;
  right: 20px;
  background: none;
  border: none;
  color: white;
  font-size: 28px;
  cursor: pointer;
}
</style>