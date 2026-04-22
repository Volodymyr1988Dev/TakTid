<script setup lang="ts">
import {
  ref,
  watch,
  computed,
  onBeforeUnmount,
  nextTick,
  onServerPrefetch
} from 'vue'

//import type { ProjectUserEntry } from '../types/ProjectUserEntry'
import type { ProjectStats } from '../types/projectStats.type'
import { cloudinary } from '../utils/cloudinary'
//import { getProjectStats, getUserProjectEntries } from '../api/projectStats.api'
import { getProjectStats } from '../api/projectStats.api'
import { useProjectImageStore } from '../stores/projectImage.store'
import { useStatsStore } from '../stores/stats.store'
import AppLoader from '../components/ui/AppLoader.vue'
import type { TimeEntry } from '../types/TimeEntry.type'
import { useProjectStore } from '../stores/project.store'

const projectStore = useProjectStore()
const props = defineProps<{ projectId: string, isAdmin: boolean }>()
const emit = defineEmits<{ (e: 'back'): void }>()
const imageStore = useProjectImageStore()
const statsStore = useStatsStore()

const fullscreenImage = ref<string | null>(null)
const stats = ref<ProjectStats | null>(null)
const loading = ref(true)
const loaded = ref(new Set<string>())
const error = ref<string | null>(null)
const currentIndex = ref(0)

const expandedUserId = ref<string | null>(null)

const showDetails = ref<'work' | 'extra' | 'total' | null>(null)
const projectDetails = ref<TimeEntry[]>([])
const loadingDetails = ref(false)  
//const userEntries = ref<Record<string, ProjectUserEntry[]>>({})
//const loadingUserId = ref<string | null>(null)

//const cache = new Map<string, ProjectUserEntry[]>()
function onLoad(id: string) {
  loaded.value.add(id)
}
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

//watch(() => props.projectId, loadStats, { immediate: true })
watch(() => props.projectId, async () => {
  loaded.value.clear()
  await loadStats()
}, { immediate: true })
onServerPrefetch(loadStats)

/* ================= USER DETAILS ================= */
async function toggleDetails(userId: string) {
  if (expandedUserId.value === userId) {
    expandedUserId.value = null
    return
  }

  expandedUserId.value = userId

  await statsStore.loadProjectUserEntries(
    props.projectId,
    userId
  )

  //const cacheKey = `${props.projectId}-${userId}`
  /*
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
  }*/

}

/* ================= PAGINATION IMAGES ================= */

const showImages = ref(false)
const page = ref(1)
const limit = 20
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

  loaded.value.clear()
  await loadImages()
  await nextTick()
  observeSentinel()
})
watch(currentIndex, (i) => {
  const next = imageStore.images[i + 1]
  if (next) {
    const img = new Image()
    img.src = next.url
  }
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

onBeforeUnmount(() => { 
  observer?.disconnect() 
  //document.body.style.overflow = ''
  document.body.style = ''
})
let scrollY = 0
function openImage(url: string) {
  const index = imageStore.images.findIndex(i => i.url === url)
  if (index === -1) return

  currentIndex.value = index
  fullscreenImage.value = url
  scrollY = window.scrollY
  document.body.style.position = 'fixed'
  document.body.style.top = `-${scrollY}px`
  document.body.style.width = '100%'
}

function closeImage() {
  fullscreenImage.value = null

  //document.body.style.position = ''
  document.body.style = ''
  //document.body.style.top = ''
  //document.body.style.width = ''

  window.scrollTo(0, scrollY)
  resetTransform()
}

const scale = ref(1)
const lastScale = ref(1)
const startDistance = ref(0)

const translateX = ref(0)
const translateY = ref(0)

let lastTouchX = 0
let lastTouchY = 0
let isDragging = false

let startX = 0
let startY = 0
let isSwiping = false

function clamp(val: number, min: number, max: number) {
  return Math.min(Math.max(val, min), max)
}

function resetTransform() {
  scale.value = 1
  translateX.value = 0
  translateY.value = 0
}

function onTouchStart(e: TouchEvent) {
  const touch = e.touches[0]
  if (!touch) return

  if (e.touches.length === 2) {
    //startDistance.value = getDistance(e.touches)
    //const newDistance = getDistance(e.touches)
    const dist = getDistance(e.touches)
    if (!dist) return

    startDistance.value = dist
    lastScale.value = scale.value
  } else if (e.touches.length === 1) {
  //if (e.touches.length === 1 && scale.value > 1 && isDragging) {
    const touch = e.touches[0]
    if (!touch) return
    /*
    const dx = touch.clientX - lastTouchX
    const dy = touch.clientY - lastTouchY

    velocityX = dx

    const max = 200 * scale.value

    translateX.value = clamp(translateX.value + dx, -max, max)
    translateY.value = clamp(translateY.value + dy, -max, max)
    */
    lastTouchX = touch.clientX
    lastTouchY = touch.clientY
  
    isDragging = true

    startX = touch.clientX
    startY = touch.clientY
    isSwiping = true
  }

  //startX = touch.clientX
  //startY = touch.clientY
  //isSwiping = true
}
let velocityX = 0

function onTouchMove(e: TouchEvent) {
  if (e.touches.length === 2) {
    const newDistance = getDistance(e.touches)
    if (!newDistance || !startDistance.value) return
    scale.value = Math.min(
      Math.max(1, (newDistance / startDistance.value) * lastScale.value),
      4
    )
  }

  if (e.touches.length === 1 && scale.value > 1 && isDragging) {
    const touch = e.touches[0]
    if (!touch) return
    const dx = touch.clientX - lastTouchX
    const dy = touch.clientY - lastTouchY
    velocityX = dx

    //translateX.value += dx
    //translateY.value += dy

    //const maxX = (window.innerWidth * (scale.value - 1)) / 2
    //const maxY = (window.innerHeight * (scale.value - 1)) / 2
    const rect = (e.target as HTMLElement).getBoundingClientRect()
    const maxX = Math.max(0, (rect.width * scale.value - window.innerWidth) / 2)
    const maxY = Math.max(0, (rect.height * scale.value - window.innerHeight) / 2)
    translateX.value = clamp(translateX.value + dx, -maxX, maxX)
    translateY.value = clamp(translateY.value + dy, -maxY, maxY)

    lastTouchX = touch.clientX
    lastTouchY = touch.clientY
  }
}

function onTouchEnd(e: TouchEvent) {
  //if (!isSwiping || scale.value > 1) return
  if (!isSwiping) return
  if (scale.value > 1) {
    isSwiping = false
    return
  }
  const touch = e.changedTouches[0]
  if (!touch) return

  //if (scale.value < 1) scale.value = 1

  const dx = touch.clientX - startX
  const dy = touch.clientY - startY

  if (Math.abs(dy) > Math.abs(dx) && dy > 80) {
    closeImage()
  }
  if (Math.abs(velocityX) > 20) {
    //if (velocityX < 0) nextImage() else prevImage()
    velocityX < 0 ? nextImage() : prevImage()
  }
 // if (Math.abs(dx) > Math.abs(dy)) {
    if (dx < -50) nextImage()
    if (dx > 50) prevImage()
  //}/*
/*
  const absX = Math.abs(dx)
  const absY = Math.abs(dy)

  if (absX < 40 && absY < 40) {
    isSwiping = false
    return
  }

  if (absY > absX && dy > 80) {
    closeImage()
  }

  if (absX > absY) {
    if (dx < -50) nextImage()
    if (dx > 50) prevImage()
  }*/

  isSwiping = false
  isDragging = false
}

function getDistance(touches: TouchList): number | undefined {
  if (!touches[0] || !touches[1]) return
  //if (touches.length < 2) return
  const dx = touches[0].clientX - touches[1].clientX
  const dy = touches[0].clientY - touches[1].clientY
  return Math.sqrt(dx * dx + dy * dy)
}
/*
const maxTranslate = 150 * scale.value

translateX.value = clamp(translateX.value + dx, -maxTranslate, maxTranslate)
translateY.value = clamp(translateY.value + dy, -maxTranslate, maxTranslate)
function resetTransform() {
  scale.value = 1
  translateX.value = 0
  translateY.value = 0
}
let lastTap = 0

function onTap() {
  const now = Date.now()

  if (now - lastTap < 300) {
    if (scale.value > 1) {
      resetTransform()
    } else {
      scale.value = 2
    }
  }

  lastTap = now
}
/*
let lastTap = 0

function onTap(e: TouchEvent) {
  const now = Date.now()
  if (now - lastTap < 300) {
    scale.value = scale.value > 1 ? 1 : 2
    translateX.value = 0
    translateY.value = 0
  }
  lastTap = now
}
*/
function nextImage() {
  //if (currentIndex.value < imageStore.images.length - 1) {
  //  currentIndex.value++
  //  fullscreenImage.value = imageStore.images[currentIndex.value].url
  //}
  const next = imageStore.images[currentIndex.value + 1]
  if (!next) return

   /*translateX.value = 50
  setTimeout(() => {
    currentIndex.value++
    fullscreenImage.value = next.url
    translateX.value = 0
  }, 100)*/
  currentIndex.value++
  fullscreenImage.value = next.url
  resetTransform()
}

function prevImage() {/*
  if (currentIndex.value > 0) {
    currentIndex.value--
    fullscreenImage.value = imageStore.images[currentIndex.value].url
    
  }*/
 const prev = imageStore.images[currentIndex.value - 1]
  if (!prev) return

  currentIndex.value--
  fullscreenImage.value = prev.url
  resetTransform()
}
/* ================= COMPUTED ================= */
/*
async function loadProjectDetails() {
  loadingDetails.value = true

  try {
    const res = await fetch(`/api/projects/${props.projectId}/details`)
    projectDetails.value = await res.json()
  } finally {
    loadingDetails.value = false
  }
}
*/
async function toggleSummary(type: 'work' | 'extra' | 'total') {
  if (showDetails.value === type) {
    showDetails.value = null
    return
  }

  showDetails.value = type

  if (!projectDetails.value.length) {
    await loadingDetails //loadProjectDetails()
  }
}
const filteredDetails = computed(() => {
  if (!showDetails.value) return []

  if (showDetails.value === 'total') {
    return projectStore.projectDetails
  }

  return projectStore.projectDetails.filter((e: TimeEntry) =>
    showDetails.value === 'work'
      ? e.type === 'WORK'
      : e.type === 'EXTRA'
  )
})

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
      <!--
      <div class="summary">
        <div>Work <strong>{{ totalWork }}h</strong></div>
        <div>Extra <strong>{{ totalExtra }}h</strong></div>
        <div>Total <strong>{{ totalAll }}h</strong></div>
      </div>
      -->
      <div class="summary">
        <div 
          @click="toggleSummary('work')" 
          :class="{ active: showDetails === 'work' }"
        >
          Work <strong>{{ totalWork }}h</strong>
        </div>

        <div 
          @click="toggleSummary('extra')" 
          :class="{ active: showDetails === 'extra' }"
        >
          Extra <strong>{{ totalExtra }}h</strong>
        </div>

        <div 
          @click="toggleSummary('total')" 
          :class="{ active: showDetails === 'total' }"
        >
          Total <strong>{{ totalAll }}h</strong>
        </div>
      </div>
      <div v-if="showDetails" class="project-details">
      <div v-if="loadingDetails">Loading...</div>

      <div v-else>
        <div
          v-for="entry in filteredDetails"
          :key="entry.id"
          class="detail-row"
        >
          <div class="detail-date">{{ entry.date }}</div>
          <div class="detail-user">{{ entry.user?.email }}</div>
          <div class="detail-hours">{{ entry.hours }}h</div>

          <div v-if="entry.comment" class="detail-comment">
            {{ entry.comment }}
          </div>
        </div>
      </div>
    </div>
      <!-- USERS -->
      <div
        v-for="u in stats.users"
        :key="u.id"
        class="user-card"
        :class="{ clickable: isAdmin }"
        @click="isAdmin && toggleDetails(u.id)"
      >
        <div class="user-header">
          <div>
            <strong>{{ u.name }}</strong>
            <div class="email">
              {{ u.email }}
            </div>
          </div>

          <div class="hours">
            <div class="hours-breakdown">
              <span class="work">Work: {{ u.workHours }}h</span>
              <span class="extra">Extra: {{ u.extraHours }}h</span>
              <span class="total">Total: {{ u.totalHours }}h</span>
            </div>

            <button
              v-if="isAdmin"
              class="details-btn"
              @click.stop="toggleDetails(u.id)"
            >
              {{ expandedUserId === u.id ? 'Hide Details' : 'Details' }}
            </button>
          </div>
        </div>

        <!-- DETAILS -->
        <div
          v-if="expandedUserId === u.id"
          class="details"
        >
          <div
            v-if="statsStore.loadingProjectUserId === u.id"
            class="details-skeleton"
          >
            <div
              v-for="n in 3"
              :key="n"
              class="skeleton-line"
            />
            <!--line -->>
          </div>

          <div v-else>
            <div
              v-for="entry in statsStore.projectUserEntries[`${props.projectId}-${u.id}`] || []"
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
          <div
            v-for="img in imageStore.images"
            :key="img.id"
            class="image-wrapper"
          >
            <div 
              v-if="!loaded.has(img.id)" 
              class="skeleton" 
            />

            <img

              :src="cloudinary(img.url, 600)"
              class="image"
              :class="{ loaded: loaded.has(img.id) }"
              loading="lazy"
              @load="onLoad(img.id)"
              @click="openImage(img.url)"
            >
          </div>
          <div
            v-if="fullscreenImage"
            class="image-modal"
            @click="closeImage"
          >
            <img
              :src="fullscreenImage"
              class="image-modal-content"
              :style="{
                transform: `translate(${translateX}px, ${translateY}px) scale(${scale})`
              }"
              @click.stop
              @touchstart="onTouchStart"
              @touchend="onTouchEnd"
              @touchmove="onTouchMove"
            >
            <!--@click="onTap"  @touchmove="onTouchMove"-->
            <button
              class="image-close"
              @click.stop="closeImage"
            >
              ✕
            </button>
          </div>
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

.images-grid {/*
  margin-top:16px;
  display:grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));*/
  column-count: 3;
  gap:10px;
}
.image-wrapper {
  position: relative;
  break-inside: avoid;
  margin-bottom: 10px;
}
.image {
  width:100%;
  border-radius:8px;

  margin-bottom: 10px;
  break-inside: avoid;
  cursor: zoom-in;
  transition: transform .2s, opacity .3s;
  opacity: 0;
}
.image.loaded {
  opacity: 1;
}
.error {
  padding:16px;
  background:#fee2e2;
  color:#991b1b;
  border-radius:8px;
}
.hours {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-top: 6px;
}

.hours-breakdown {
  display: flex;
  gap: 12px;
  font-size: 13px;
}

.work {
  color: #2ecc71;
  font-weight: 500;
}

.extra {
  color: #f1c40f;
  font-weight: 500;
}

.total {
  font-weight: 600;
}

.details-btn {
  padding: 8px 14px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  background: #2563eb;
  color: white;
  font-weight: 500;
  transition: all 0.2s ease;
}

.details-btn:hover {
  background: #1d4ed8;
}

.details-btn:active {
  transform: scale(0.97);
}
.skeleton {
  height: 120px;
  border-radius: 8px;
  background: linear-gradient(
    90deg,
    #eee 25%,
    #f5f5f5 37%,
    #eee 63%
  );
  background-size: 400% 100%;
  animation: skeleton 1.2s infinite;
}
.skeleton-line {
  height: 14px;
  margin-bottom: 8px;
  border-radius: 6px;
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 37%,
    #f0f0f0 63%
  );
  background-size: 400% 100%;
  animation: shimmer 1.4s ease infinite;
}

@keyframes shimmer {
  0% {
    background-position: 100% 0;
  }
  100% {
    background-position: 0 0;
  }
}
@keyframes skeleton {
  0% { background-position: -200px 0 }
  100% { background-position: 200px 0 }
}
.user-card.clickable {
  cursor: pointer;
}

.user-card.clickable:hover {
  background: #f1f5f9;
}

.summary div {
  cursor: pointer;
  padding: 6px 10px;
  border-radius: 8px;
  transition: 0.2s;
}

.summary div:hover {
  background: #f1f5f9;
}

.summary .active {
  background: #2563eb;
  color: white;
}

.project-details {
  margin-top: 16px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 10px;
}

.detail-row {
  display: grid;
  grid-template-columns: 90px 1fr 70px;
  gap: 10px;
  padding: 8px 0;
  border-bottom: 1px solid #eee;
}

.detail-comment {
  grid-column: span 3;
  font-size: 13px;
  color: #666;
}

@media (max-width: 640px) {

  .detail-row {
    grid-template-columns: 1fr;
  }

  .detail-comment {
    grid-column: span 1;
  }

  .summary {
    flex-direction: column;
    gap: 8px;
  }

  .user-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .hours {
    width: 100%;
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .hours-breakdown {
    flex-wrap: wrap;
    gap: 8px;
  }

  .details-btn {
    width: 100%;
    text-align: center;
  }

  .images-grid {
    /*grid-template-columns: repeat(auto-fill, minmax(90px, 1fr));*/
    column-count: 2;
  }
}
.image:hover {
  transform: scale(1.05);
}

/* FULLSCREEN MODAL */

.image-modal {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(8px);
  animation: fadeIn 0.2s ease;
}

.image-modal-content {
  max-width: 95%;
  max-height: 95%;
  border-radius: 10px;

  transition: transform 0.25s ease, opacity 0.2s ease;
  will-change: transform;
  /*touch-action: pan-y;*/

  touch-action: none;
  cursor: grab;
  box-shadow: 0 10px 40px rgba(0,0,0,0.6);
}
@keyframes fadeIn {
  from { opacity: 0 }
  to { opacity: 1 }
}
.image-close {
  position: absolute;
  top: 20px;
  right: 20px;
  /*background: white;*/
  background: rgba(255,255,255,0.9);
  backdrop-filter: blur(6px);

  border: none;
  border-radius: 50%;
  width: 42px;
  height: 42px;
  font-size: 18px;
  cursor: pointer;
  transition: transform 0.2s;
}
.image-close:active {
  transform: scale(0.9);
}
</style>