<script setup lang="ts">
import {
  ref,
  watch,
  computed,
  onBeforeUnmount,
  nextTick,
  onServerPrefetch
} from 'vue'
import type { ProjectStats } from '../types/projectStats.type'
import { cloudinary } from '../utils/cloudinary'
//import { getProjectStats, getProjectSummary } from '../api/projectStats.api'
import { getProjectStats } from '../api/projectStats.api'
import { useProjectImageStore } from '../stores/projectImage.store'
import { useProjectReceiptStore } from '../stores/projectReceipts'
import { useStatsStore } from '../stores/stats.store'
import AppLoader from '../components/ui/AppLoader.vue'
import type { TimeEntry } from '../types/TimeEntry.type'
import { useProjectStore } from '../stores/project.store'
import { useI18n } from 'vue-i18n'
import ProjectTasks from '../components/ui/ProjectTasks.vue'
import type { ViewerItem } from '../types/ViewerItem'

const { t } = useI18n()
const projectStore = useProjectStore()
const props = defineProps<{ projectId: string, isAdmin: boolean }>()
const emit = defineEmits<{ (e: 'back'): void }>()
const imageStore = useProjectImageStore()
const receiptStore = useProjectReceiptStore()
const statsStore = useStatsStore()

const showTasks = ref(false)

//const viewerItems = ref<ProjectImage[] | ProjectReceipt[]>([]) 
//const viewerOpen = ref(false)
/*
const fullscreenImage = ref<string | null>(null)
const viewerItems = ref<ViewerItem[]>([])
const viewerIndex = ref(0)
const viewerType = ref<'images' | 'receipts'>('images')
const currentIndex = ref(0)
const receiptViewer = ref(false)
const currentReceiptIndex = ref(0)
*/

const viewerOpen = ref(false)

const viewerType = ref<'images' | 'receipts'>('images')

const viewerItems = ref<ViewerItem[]>([])

const viewerIndex = ref(0)

const currentViewerItem = computed(() => {
    return viewerItems.value[viewerIndex.value] ?? null
})
/*
const currentImage = computed(() => {
    const item = currentViewerItem.value

    if (!item)
        return null

    return item.url
})
*/
const stats = ref<ProjectStats | null>(null)
const loading = ref(true)
const loaded = ref(new Set<string>())
const error = ref<string | null>(null)

const extraPrice = ref<number | null>(null)

const showReceiptMenu = ref(false)
const showReceiptDialog = ref(false)
const receiptInput = ref<HTMLInputElement>()  
const editMode = ref<'area' | 'price' | 'extraPrice' | null>(null)

const expandedUserId = ref<string | null>(null)

const showEdit = ref(false)

const area = ref<number | null>(null)
const price = ref<number | null>(null)

const EMPLOYER_TAX = 0.3142
const EMPLOYER_MULTIPLIER = 1.55
//const MONTH_HOURS = 174

const showDetails = ref<'work' | 'extra' | 'total' | null>(null)
const loadingDetails = ref(false)  
function onLoad(id: string) {
  loaded.value.add(id)
}
/* ================= LOAD STATS ================= */

async function loadStats() {
  if (!props.projectId) return console.log(t('errors.missingProjectId'))
  loading.value = true
  error.value = null

  try {
    const { data } = await getProjectStats(props.projectId)
    stats.value = data

    area.value = data.project.areaM2 ?? null
    price.value = data.project.pricePerM2 ?? null

    extraPrice.value = data.project.pricePerExtraH ?? null
  } catch (err: any) {
    if (err?.response?.status === 403) {
      error.value = t('errors.accessDenied')
    } else {
      error.value = t('errors.loadStats')
    }
  } finally {
    loading.value = false
  }
}

async function saveExtraPrice() {
  await projectStore.updateProject(props.projectId, {
    pricePerExtraH: extraPrice.value,
  })

  await loadStats()

  editMode.value = null
}

watch(() => [props.projectId, props.isAdmin], async ([id, isAdmin]) => {
  if (!id || isAdmin === undefined) return console.log(t('errors.missingProjectId'))
  loaded.value.clear()
  await loadStats()
}, { immediate: true })
onServerPrefetch(() => Promise.resolve())
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
/*
watch(currentIndex, (i) => {
  const next = imageStore.images[i + 1]
  if (next) {
    const img = new Image()
    img.src = next.url
  }
})*/
watch(
    viewerIndex,
    index=>{

        const next=
            viewerItems.value[index+1]

        if(!next)
            return

        const img=new Image()

        img.src=next.url

    }
)
async function loadImages() {
  if (!hasMore.value || imageStore.loading) return

  const res = await imageStore.loadPaginated(
    props.projectId,
    page.value,
    limit
  )

  await receiptStore.loadPaginated(
      props.projectId,
      1,
      100,
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
  document.body.style = ''
})

function openViewer(
    type:'images'|'receipts',
    items:ViewerItem[],
    index:number,
){

    viewerType.value=type

    viewerItems.value=items

    viewerIndex.value=index

    viewerOpen.value=true

    scrollY=window.scrollY

    document.body.style.position='fixed'
    document.body.style.top=`-${scrollY}px`
    document.body.style.width='100%'

}

let scrollY = 0
function openImage(url: string) {
  const index = imageStore.images.findIndex(i => i.url === url)
  if (index === -1) return
  openViewer(
        'images',
        imageStore.images,
        index,
    )
  /*
  currentIndex.value = index
  fullscreenImage.value = url
  scrollY = window.scrollY
  document.body.style.position = 'fixed'
  document.body.style.top = `-${scrollY}px`
  document.body.style.width = '100%'*/
}

function closeViewer(){

      viewerOpen.value=false

      document.body.style=''

      window.scrollTo(
          0,
          scrollY,
      )

      resetTransform()

  }
/*
function closeImage() {
  fullscreenImage.value = null
  document.body.style = ''
  window.scrollTo(0, scrollY)
  resetTransform()
}*/

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
    const dist = getDistance(e.touches)
    if (!dist) return

    startDistance.value = dist
    lastScale.value = scale.value
  } else if (e.touches.length === 1) {
    const touch = e.touches[0]
    if (!touch) return
    lastTouchX = touch.clientX
    lastTouchY = touch.clientY
  
    isDragging = true

    startX = touch.clientX
    startY = touch.clientY
    isSwiping = true
  }
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
  if (!isSwiping) return
  if (scale.value > 1) {
    isSwiping = false
    return
  }
  const touch = e.changedTouches[0]
  if (!touch) return

  const dx = touch.clientX - startX
  const dy = touch.clientY - startY

  if (Math.abs(dy) > Math.abs(dx) && dy > 80) {
    //closeImage()
    closeViewer()
  }
  if (Math.abs(velocityX) > 20) {
    velocityX < 0 ? /*nextImage()*/ nextViewerItem() : /*prevImage()*/ prevViewerItem()
  }
    if (dx < -50) /*nextImage()*/ nextViewerItem()
    if (dx > 50) /*prevImage()*/ prevViewerItem()
  isSwiping = false
  isDragging = false
}

function getDistance(touches: TouchList): number | undefined {
  if (!touches[0] || !touches[1]) return
  const dx = touches[0].clientX - touches[1].clientX
  const dy = touches[0].clientY - touches[1].clientY
  return Math.sqrt(dx * dx + dy * dy)
}
/*
function nextImage() {
  const next = imageStore.images[currentIndex.value + 1]
  if (!next) return
  currentIndex.value++
  fullscreenImage.value = next.url
  resetTransform()
}*/
function nextViewerItem(){

    if(
        viewerIndex.value>=
        viewerItems.value.length-1
    )
        return

    viewerIndex.value++

    resetTransform()

}
/*
function prevImage() {
 const prev = imageStore.images[currentIndex.value - 1]
  if (!prev) return

  currentIndex.value--
  fullscreenImage.value = prev.url
  resetTransform()
}*/
function prevViewerItem(){

    if(
        viewerIndex.value<=0
    )
        return

    viewerIndex.value--

    resetTransform()

}
/* ================= COMPUTED ================= */

async function loadProjectDetails() {
  if (!props.isAdmin) return
  loadingDetails.value = true

  try {
    await projectStore.loadDetails(props.projectId)
  } finally {
    loadingDetails.value = false
  }
}

async function toggleSummary(type: 'work' | 'extra' | 'total') {
   if (!props.isAdmin) return 
  if (showDetails.value === type) {
    showDetails.value = null
    return
  }

  showDetails.value = type
    await loadProjectDetails()
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

watch(() => props.isAdmin, (isAdmin) => {
  if (!isAdmin) {
    showDetails.value = null
  }
})

function detailBadge(type: string) {
  switch (type) {
    case 'WORK':
      return {
        icon: '🛠',
        text: t('stats.work'),
        class: 'badge-work'
      }

    case 'EXTRA':
      return {
        icon: '💼',
        text: t('stats.extra'),
        class: 'badge-extra'
      }

    default:
      return {
        icon: '⏱',
        text: type,
        class: 'badge-default'
      }
  }
}

const totalWork = computed(() => stats.value?.total.work ?? 0)
const totalExtra = computed(() => stats.value?.total.extra ?? 0)
const totalAll = computed(() => totalWork.value + totalExtra.value)



//const workerCost = workedHours * currentSalary * (1 + EMPLOYER_TAX)

const workersCost = computed(() => {
  const users = stats.value?.users

  if (!users?.length) return 0

  return users.reduce((sum: number, worker) => {
    const salary = worker.currentSalary ?? 0
    const hours = worker.totalHours ?? 0

    const fullCost =
      hours *
      salary *
      //(1 + EMPLOYER_TAX)
      EMPLOYER_MULTIPLIER

    return sum + fullCost
  }, 0)
})

function getWorkerSalary(worker: any) {
  const hourlySalary =
    Number(worker.currentSalary) || 0

  const totalHours =
    Number(worker.totalHours) || 0

  return hourlySalary * totalHours
}

function getWorkerSalaryWithTax(worker: any) {
  return getWorkerSalary(worker) * EMPLOYER_TAX
}
function getWorkerSalaryWithMultiTax(worker: any) {
  return getWorkerSalary(worker) * (1 - EMPLOYER_MULTIPLIER)
}
const profit = computed(() => {
  if (!totalProjectPrice.value) return 0

  return totalProjectPrice.value - workersCost.value
})

async function saveArea() {
  await projectStore.updateProject(props.projectId, {
    areaM2: area.value,
  })

  await loadStats()

  editMode.value = null
}

async function savePrice() {
  await projectStore.updateProject(props.projectId, {
    pricePerM2: price.value,
  })

  await loadStats()

  editMode.value = null
}

const totalProjectPrice = computed(
  () => stats.value?.totalProjectPrice ?? 0
)

const extraHoursPrice = computed(
  () => stats.value?.extraHoursPrice ?? 0
)

const deletingImage = ref(false)
async function deleteCurrentViewerItem() {

    if (!props.isAdmin)
        return

    const current =
        currentViewerItem.value

    if (!current)
        return

    if (
        !confirm(
            t('project.confirmDeleteImage')
        )
    )
        return

    deletingImage.value = true

    try {

        if (
            viewerType.value === 'images'
        ) {

            await imageStore.remove(
                current.id
            )

            viewerItems.value =
                imageStore.images

        }

        else {

            await receiptStore.remove(
                current.id
            )

            viewerItems.value =
                receiptStore.receipts

        }

        if (
            viewerItems.value.length === 0
        ) {

            closeViewer()

            return

        }

        if (
            viewerIndex.value >=
            viewerItems.value.length
        ) {

            viewerIndex.value =
                viewerItems.value.length - 1

        }

    }

    finally {

        deletingImage.value = false

    }

}
/*
async function deleteCurrentImage() {
  if (!props.isAdmin) return

  const current = imageStore.images[currentIndex.value]
  if (!current) return

  if (!confirm(t('project.confirmDeleteImage'))) {
    return
  }

  deletingImage.value = true

  try {
    await imageStore.remove(current.id)

    if (imageStore.images.length === 0) {
      //closeImage()
      closeViewer()
      return
    }

    if (currentIndex.value >= imageStore.images.length) {
      currentIndex.value = imageStore.images.length - 1
    }

    fullscreenImage.value =
      imageStore.images[currentIndex.value]?.url ?? null

    if (!fullscreenImage.value) {
      closeImage()
    }
  } finally {
    deletingImage.value = false
  }
}
*/
async function onReceiptUpload(
    e: Event,
){
    const files=(e.target as HTMLInputElement).files

    if(!files?.length)return

    await receiptStore.upload(
        props.projectId,
        [...files],
    )
}

function openReceipt(index:number){

openViewer(
        'receipts',
        receiptStore.receipts,
        index,
    )
/*    
viewerItems.value = receiptStore.receipts  
//currentReceiptIndex.value=index
currentIndex.value = index

receiptViewer.value=true
*/
}
/*
async function deleteReceipt(){

const receipt=
receiptStore.receipts[
currentReceiptIndex.value
]

if(!receipt)return

if(!confirm('Delete receipt?')) return

await receiptStore.remove( receipt.id )
}
*/
//const baseProjectPrice = computed( () => stats.value?.baseProjectPrice ?? 0 )
</script>

<template>
  <div class="project-info">
    <button 
      class="back" 
      @click="emit('back')"
    >
      ← {{ t('project.back') }}
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
      <div v-if="isAdmin">

        <div class="metrics-header">
            <h3>{{ t('project.metrics') }}</h3>

            <button
              v-if="isAdmin"
              class="edit-project-btn"
              @click="showEdit = !showEdit"
            >
              {{
                showEdit
                  ? t('common.close')
                  : t('project.editProject')
              }}
            </button>
          </div>
        <div class="metrics-wrapper">

          <div class="metric-card">
            <div class="metric-title">
              {{ t('project.totalProjectPrice') }}
            </div>

            <div class="metric-value">
              {{ totalProjectPrice.toLocaleString() }} kr
            </div>
          </div>

          <div class="metric-card extra-income">
            <div class="metric-title">
              {{ t('project.extraHoursIncome') }}
            </div>

            <div class="metric-value">
              {{ extraHoursPrice.toLocaleString() }} kr
            </div>
          </div>

          <div class="metric-card workers-cost">
            <div class="metric-title">
              {{ t('project.workersCost') }}
            </div>

            <div class="metric-value">
              {{ workersCost.toLocaleString() }} kr
            </div>
          </div>

          <div class="metric-card profit-card"
            :class="profit >= 0 ? 'profit-positive' : 'profit-negative'"
          >
            <div class="metric-title">
              {{ t('project.profit') }}
            </div>

            <div
              class="metric-value"
              :class="{ negative: profit < 0 }"
            >
              {{ profit.toLocaleString() }} kr
            </div>
          </div>

        </div>

        <div v-if="showEdit" class="edit-menu">

          <button @click="editMode = 'area'">
            {{ t('project.changeArea') }}
          </button>

          <button @click="editMode = 'price'">
            {{ t('project.changePricePerM2') }}
          </button>

          <button @click="editMode = 'extraPrice'">
            {{ t('project.changeExtraHourPrice') }}
          </button>

        </div>

        <div class="project-small-info">
          <div>
            {{ t('project.area') }}:
            {{ stats.project.areaM2 }} m²
          </div>

          <div>
            {{ t('project.pricePerM2') }}:
            {{ stats.project.pricePerM2 }}
          </div>

          <div>
            {{ t('project.pricePerExtraHour') }}:
            {{ stats.project.pricePerExtraH }} kr
          </div>

          <div>
            {{ t('project.extraHoursIncome') }}:
            {{ extraHoursPrice.toLocaleString() }} kr
          </div>
        </div>
        <div v-if="editMode === 'area'" class="modal">
          <div class="modal-content">
            <label for="area">{{ t('project.area') }}</label>
            <input
              v-model="area"
              type="number"
              :placeholder="t('project.area')"
              id="area"
            >

            <button @click="saveArea">
              {{ t('project.saveArea') }}
            </button>

          </div>
        </div>

        <div v-if="editMode === 'price'" class="modal">
          <div class="modal-content">

            <label for="price">{{ t('project.pricePerM2') }}</label>
            <input
              v-model.number="price"
              type="number"
              :placeholder="t('project.pricePerM2')"
              id="price"
            >

            <button @click="savePrice">
              {{ t('project.savePrice') }}
            </button>

          </div>
        </div>

        <div v-if="editMode === 'extraPrice'" class="modal">
          <div class="modal-content">

            <label for="extraPrice">
              {{ t('project.pricePerExtraHour') }}
            </label>

            <input
              v-model.number="extraPrice"
              type="number"
              id="extraPrice"
            >

            <button @click="saveExtraPrice">
              {{ t('project.saveExtraHourPrice') }}
            </button>

          </div>
        </div>
      <div class="summary">
        <div 
          @click="toggleSummary('work')"
          :class="[
            'summary-item',
            'work',
            { active: showDetails === 'work', clickable: isAdmin }
          ]" 
        >
        <!--:class="{ active: showDetails === 'work', disabled: !isAdmin }"-->
          🛠 {{ t('stats.work') }} <strong>{{ totalWork }}h</strong>
        </div>

        <div 
          @click="toggleSummary('extra')" 
          :class="[
            'summary-item',
            'extra',
            { active: showDetails === 'extra', clickable: isAdmin }
          ]"
        >
          💼 {{ t('stats.extra') }} <strong>{{ totalExtra }}h</strong>
        </div>
        <!--:class="{ active: showDetails === 'extra', disabled: !isAdmin }"-->

        <div 
          @click="toggleSummary('total')" 
          :class="[
            'summary-item',
            'total',
            { active: showDetails === 'total', clickable: isAdmin }
          ]"
        >
        ⏱ {{ t('stats.total') }} <strong>{{ totalAll }}h</strong>
        </div>
        <!--:class="{ active: showDetails === 'total', disabled: !isAdmin }"-->
      </div>
      <!--<div v-if="showDetails && isAdmin" class="project-details"></div>-->
      <div v-if="loadingDetails">{{ t('common.loading') }}</div>

      <div v-else>
        <div
          v-for="entry in filteredDetails"
          :key="entry.id"
          class="detail-row"
        >
          <div class="detail-top">

              <span
                  class="type-badge"
                  :class="detailBadge(entry.type).class"
              >
                  {{ detailBadge(entry.type).icon }}
                  {{ detailBadge(entry.type).text }}
              </span>

              <span class="detail-date">
                  {{ entry.date }}
              </span>

              <span class="detail-hours">
                  {{ entry.hours }}h
              </span>

          </div>

          <div class="user-info">

              <div class="name">
                  {{ entry.user?.name }}
              </div>

              <div class="email">
                  {{ entry.user?.email }}
              </div>

          </div>

          <div
              v-if="entry.comment"
              class="detail-comment"
          >
              {{ entry.comment }}
          </div>
        </div>
        </div>
        <!-- ADMIN VIEW
        <div v-if="isAdmin">-->
          <div
          v-for="u in stats?.users || []"
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
                <span class="work">{{t('stats.work')}} {{ u.workHours }}h</span>
                <span class="extra">{{t('stats.extra')}} {{ u.extraHours }}h</span>
                <span class="total">{{t('stats.total')}} {{ u.totalHours }}h</span>

                <div class="salary-info">
                  <span>
                    {{ t('account.salary') }}:
                    {{ getWorkerSalary(u).toFixed(0) }} kr
                  </span>

                  <span class="tax">
                    {{ t('account.employer31Tax') }}:
                    {{ getWorkerSalaryWithTax(u).toFixed(0) }} kr
                  </span>
                  <span class="tax">
                    {{ t('account.employerTax') }}:
                    {{ getWorkerSalaryWithMultiTax(u).toFixed(0) }} kr
                  </span>
                </div>
              </div>
              
              <button
                v-if="isAdmin"
                class="details-btn"
                @click.stop="toggleDetails(u.id)"
              >
                {{ expandedUserId === u.id ? t('project.hideDetails') : t('project.showDetails') }}
              </button>
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
              <!--line -->
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
        <!--</div>-->
        </div>
      </div>
    </div>
    <!-- USER VIEW -->
    <div v-else class="user-summary">
      <div class="user-card">
        <div class="hours-breakdown">
          <span class="work">{{t('stats.work')}} {{ totalWork }}h</span>
          <span class="extra">{{t('stats.extra')}} {{ totalExtra }}h</span>
          <span class="total">{{t('stats.total')}} {{ totalAll }}h</span>
        </div>
      </div>
    </div>
    <button @click="showTasks = !showTasks">
      {{ showTasks ? 'Hide Tasks' : 'Show Tasks' }}
    </button>
      <ProjectTasks
          v-if="showTasks"
          :project-id="projectId"
          :is-admin="isAdmin"
      />
      <!-- IMAGES -->
      <div class="images-section">
        <button @click="showImages = !showImages">
          {{ showImages ? t('project.hideImages') : t('project.showImages') }}
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
          <!-- v-if="fullscreenImage"  @click="closeImage" -->
          <div
            v-if="viewerOpen"
            class="image-modal"
            @click="closeViewer"
          >
            <!-- :src="fullscreenImage" -->
            <img
              :src="currentViewerItem?.url"
              class="image-modal-content"
              :style="{
                transform: `translate(${translateX}px, ${translateY}px) scale(${scale})`
              }"
              @click.stop
              @touchstart="onTouchStart"
              @touchend="onTouchEnd"
              @touchmove="onTouchMove"
            >
            <!--@click.stop="closeImage"-->
            <button
              class="image-close"
              @click.stop="closeViewer"
            >
              ✕
            </button>
            <!-- @click.stop="deleteCurrentImage" -->
            <button
              v-if="isAdmin"
              class="image-delete"
              :disabled="deletingImage"
              @click.stop="deleteCurrentViewerItem"
            >
              🗑
            </button>
          </div>
          <div ref="sentinel" />
        </div>
      </div>
    </div>
  </div>

  <v-menu
    v-model="showReceiptMenu"
    location="top"
  >
      <template #activator="{ props }">

          <v-btn
              v-bind="props"
              class="receipt-fab"
              icon
              color="primary"
          >
              🧾
          </v-btn>

      </template>

      <v-list>

          <v-list-item
              @click="receiptInput?.click()"
          >
              ➕ Add
          </v-list-item>

          <v-list-item
              @click="showReceiptDialog=true"
          >
              🧾 {{ receiptStore.receipts.length }} Show
          </v-list-item>

      </v-list>

  </v-menu>
  <input
    ref="receiptInput"
    hidden
    type="file"
    multiple
    accept="image/*"
    @change="onReceiptUpload"
  />

  <v-dialog
    v-model="showReceiptDialog"
    fullscreen
>

<v-card>

  <v-toolbar>

  <v-btn
  icon
  @click="showReceiptDialog=false"
  >

  ←

  </v-btn>

  <v-toolbar-title>

  Receipts

  </v-toolbar-title>

  </v-toolbar>

  <div class="receipt-grid">

  <div
  v-for="(receipt,index)
  in receiptStore.receipts"

  :key="receipt.id"

  class="receipt-card"

  @click="openReceipt(index)"
  >
  <!--  @click="deleteReceipt()" @click="deleteCurrentViewerItem()"-->
    <v-btn
      v-if="isAdmin"
      icon
      class="delete-btn"
      @click.stop="receiptStore.remove(receipt.id)"
      >

      🗑

      </v-btn>
  <img
  :src="receipt.url"
  />

  <div class="receipt-date">

  {{ receipt.createdAt }}

  </div>

  </div>

  </div>

  </v-card>

</v-dialog>
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

.negative {
  color: #dc2626;
}
.user-card:hover {
  box-shadow:0 4px 12px rgba(0,0,0,.05);
}

.user-header {
  display:flex;
  justify-content:space-between;
  align-items:center;
}

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
  /*cursor: pointer;*/
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
  /*display: grid;
  grid-template-columns: 90px 1fr 70px;
  display: flex;
  gap: 15px;
  padding: 8px 0;
  border-bottom: 1px solid #eee;*/
  display: grid;
  grid-template-columns:
      110px
      110px
      minmax(180px,1fr)
      80px;
  gap: 12px;
  align-items: center;

  padding: 12px 0;
  border-bottom: 1px solid #eee;
}

.detail-comment {
  /*grid-column: span 3;
   grid-column:1/-1;
  margin-top:4px;*/

  margin-top:8px;
  word-break:break-word;

  font-size: 13px;
  color: #666;
}
.summary div.disabled {
  cursor: default;
  opacity: 0.6;
  pointer-events: none;
}

.summary div.disabled:hover {
  background: transparent;
}

.name {
  font-weight: 600;
  font-size: 14px;
}

.email {
  font-size: 11px;
  color: #94a3b8;
}
.user-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.summary-item {
  padding: 8px 14px;
  border-radius: 10px;
  font-weight: 500;
  transition: all 0.2s ease;
  user-select: none;
}
.summary-item.work {
  color: #2ecc71;
}

.summary-item.extra {
  color: #f1c40f;
}

.summary-item.total {
  color: #111;
}

/* кнопка тільки для адміна */
.summary-item.clickable {
  cursor: pointer;
  border: 1px solid #e5e7eb;
  background: white;
}

.summary-item.clickable:hover {
  background: rgb(107, 12, 240);
  transform: translateY(-1px);
}
.profit-positive {
  border: 2px solid #16a34a;
  background: #f0fdf4;
}

.profit-negative {
  border: 2px solid #dc2626;
  background: #fef2f2;
}

.profit-positive .metric-value {
  color: #16a34a;
}

.profit-negative .metric-value {
  color: #dc2626;
}
.summary-item.active {
  background: #2563eb;
  /*color: white;*/
  color: white;
  border-color: #2563eb;
  transform: scale(0.97);
}
.user-info {
  margin-top:8px;
  /*
  display: flex;
  flex-direction: column;
  min-width:0;*/
}
.email,
.name{
    overflow-wrap:anywhere;
}

.project-metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 14px;
  margin: 20px 0;
}

.metrics-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.metric-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 2px 8px rgba(0,0,0,.04);
}

.metric-card.total {
  background: #eff6ff;
  border-color: #2563eb;
}

.metric-label {
  font-size: 13px;
  color: #64748b;
}

.metric-title {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 8px;
}
.metric-value {
  font-size: 30px;
  font-weight: 700;
  color: #111827;
}
.workers-cost {
  background: #fafafa;
  border: 1px solid #f1f5f9;
  box-shadow: none;
}

.workers-cost .metric-value {
  color: #dc2626;
  font-size: 24px;
}
.extra-income {
  background: #f8fff9;
  border: 1px solid #dcfce7;
  box-shadow: none;
}

.extra-income .metric-value {
  color: #16a34a;
  font-size: 24px;
}
.project-small-info {
  margin-top: 12px;
  font-size: 12px;
  color: #888;

  display: flex;
  gap: 16px;
}
.metrics-header {
  display:flex;
  justify-content:space-between;
  align-items:center;
  margin-bottom:12px;
}

.edit-project-btn {
  border:none;
  background:#2563eb;
  color:white;
  padding:8px 14px;
  border-radius:10px;
  cursor:pointer;
  font-weight:600;
}

.salary-info {
  display: flex;
  flex-direction: column;
  gap: 6px;

  margin-top: 10px;

  font-size: 13px;
  padding-top: 10px;
  border-top: 1px solid #f1f5f9;
}
.salary-info span:first-child {
  color: #0f172a;
  font-weight: 600;
}

.tax {
  color: #ef4444;
  font-weight: 500;
  opacity: 0.85;
}

.detail-type {
  display: flex;
  align-items: center;
  gap: 12px;
}
.detail-hours{
    justify-self:end;
    white-space:nowrap;
}
.type-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;

  padding: 5px 14px;

  border-radius: 999px;

  font-size: 13px;

  font-weight: 600;
}

.badge-work {
  background: #2ecc71;
  color: white;
}

.badge-extra {
  background: #f1c40f;
  color: black;
}

.badge-default {
  background: #94a3b8;
  color: white;
}
.detail-top{
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:12px;
    flex-wrap:wrap;
}
.image-delete {
  position: absolute;

  top: 20px;
  left: 20px;

  width: 48px;
  height: 48px;

  border: none;
  border-radius: 50%;

  background: rgba(220, 38, 38, 0.95);

  color: white;

  font-size: 22px;

  cursor: pointer;

  display: flex;
  align-items: center;
  justify-content: center;

  transition: 0.2s;

  box-shadow: 0 6px 20px rgba(0,0,0,.35);
}

.image-delete:hover {
  background: #b91c1c;
  transform: scale(1.08);
}

.image-delete:active {
  transform: scale(.95);
}

.image-delete:disabled {
  opacity: .5;
  cursor: wait;
}

.receipt-grid{

display:grid;

grid-template-columns:
repeat(auto-fill,minmax(160px,1fr));

gap:16px;

padding:16px;

}
.receipt-card{

cursor:pointer;

border-radius:12px;

overflow:hidden;

box-shadow:0 4px 12px rgba(0,0,0,.15);

}

.receipt-card img{

width:100%;

height:180px;

object-fit:cover;

display:block;

}
.receipt-date{

padding:8px;

font-size:13px;

text-align:center;

}
.receipt-fab{

position:fixed;

right:24px;

bottom:24px;

width:60px;

height:60px;

border-radius:50%;

z-index:500;

box-shadow:
0 8px 24px rgba(0,0,0,.25);

}

@media (max-width:768px){

.detail-row{

    display:flex;
    flex-direction:column;

    align-items:flex-start;

    gap:8px;

    padding:14px;

    margin-bottom:12px;

    border:1px solid #e5e7eb;

    border-radius:12px;

    background:white;
}

.detail-type,
.detail-date,
.detail-user,
.detail-hours,
.detail-comment{

    width:100%;
}

.detail-hours{
/*
    text-align:right;

    font-size:18px;

    font-weight:700;*/
    align-self:flex-end;
}

.detail-date{

    color:#64748b;
}

.user-info{

    width:100%;
}

.email{

    word-break:break-word;
}
.summary{

    grid-template-columns:1fr;
}

.summary-item{

    width:100%;

    text-align:center;
}
.hours{

    display:grid;

    gap:12px;
}

.hours-breakdown{

    display:grid;

    grid-template-columns:1fr;

    gap:6px;
}

.details-btn{

    width:100%;
}
.metrics-wrapper{

    grid-template-columns:1fr;
}

.metric-card{

    padding:16px;
}

.metric-value{

    font-size:24px;
}
.project-small-info{

    display:grid;

    grid-template-columns:1fr;

    gap:6px;
}
.detail-top{
        flex-direction:column;
        align-items:flex-start;
    }

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