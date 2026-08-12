<script setup lang="ts">
import {
  computed,
  toRef,
  watch,
  ref,
} from 'vue'

import { useI18n } from 'vue-i18n'

import AppLoader from '../components/ui/AppLoader.vue'
import ProjectTasks from '../components/ui/ProjectTasks.vue'

import ProjectHeader from '../components/ProjectInfo/ProjectHeader.vue'
import ProjectMetrics from '../components/ProjectInfo/ProjectMetrics.vue'
import ProjectTimeSummary from '../components/ProjectInfo/ProjectTimeSummary.vue'
import ProjectUsers from '../components/ProjectInfo/ProjectUsers.vue'
import ProjectMedia from '../components/ProjectInfo/ProjectMedia.vue'

import { useProjectInfo } from '../components/composables/projectInfo/useProjectInfo'
import { useProjectMedia } from '../components/composables/projectInfo/useProjectMedia'
import { useImageViewer } from '../components/composables/projectInfo/useImageViewer'

import { useStatsStore } from '../stores/stats.store'
import type { ProjectImage } from '../types/ProjectImage.type.ts'
import type { ProjectReceipt } from '../types/projectReceipts.type.ts'
import type { ViewerItem } from '../types/ViewerItem.ts'

const props = defineProps<{
  projectId: string
  isAdmin: boolean
}>()

const emit = defineEmits<{
  back: []
}>()

const { t } = useI18n()

const projectId = toRef(props, 'projectId')
const isAdmin = toRef(props, 'isAdmin')

/*
 * IMPORTANT:
 *
 * We destructure refs from composables.
 *
 * This is intentional.
 * If we use:
 *
 *   projectInfo.stats
 *
 * directly in template, Vue may pass the Ref itself
 * because projectInfo is a normal object.
 *
 * Top-level refs are automatically unwrapped by Vue templates.
 */

const projectInfo = useProjectInfo(
  projectId,
  isAdmin,
)

const {
  stats,
  loading,
  error,

  totalProjectPrice,
  extraHoursPrice,
  workersCost,
  profit,

  area,
  price,
  extraPrice,

  editMode,

  totalWork,
  totalExtra,
  totalAll,

  showDetails,
  filteredDetails,
  loadingDetails,

  expandedUserId,

  loadStats,
  resetForProject,

  saveArea,
  savePrice,
  saveExtraPrice,

  toggleSummary,
  toggleDetails,
} = projectInfo


const media = useProjectMedia(projectId)

const {
  imageStore,
  receiptStore,

  showImages,
  showReceipts,

  loaded,
  sentinel,

  deletingImage,

  loadReceipts,
  toggleReceipts,
  uploadReceipts,
  removeViewerItem,

  onLoad,
  resetMedia,
} = media

const viewer = useImageViewer()

const {
  viewerOpen,
  viewerType,
  viewerItems,
  //viewerIndex,
  currentViewerItem,

  scale,
  translateX,
  translateY,

  openViewer,
  closeViewer,

  onTouchStart,
  onTouchMove,
  onTouchEnd,
  replaceViewerItems,
} = viewer

const statsStore = useStatsStore()

const statsLoadingUserId = computed(
  () => statsStore.loadingProjectUserId,
)

const projectUserEntries = computed(
  () => statsStore.projectUserEntries,
)
const showTasks = ref(false)

function setSentinel(
  element: HTMLElement | null,
): void {
  sentinel.value = element
}

function imageToViewerItem(
  image: ProjectImage,
): ViewerItem {
  return {
    id: image.id,
    url: image.url,
    createdAt: image.createdAt,
    type: 'image',
  }
}

function receiptToViewerItem(
  receipt: ProjectReceipt,
): ViewerItem {
  return {
    id: receipt.id,
    url: receipt.url,
    createdAt: receipt.createdAt,
    type: 'receipt',
  }
}

function getViewerItems(
  type: 'images' | 'receipts',
): ViewerItem[] {
  if (type === 'images') {
    return imageStore.images.map(
      imageToViewerItem,
    )
  }

  return receiptStore.receipts.map(
    receiptToViewerItem,
  )
}

function findViewerEntity(
  item: ViewerItem,
):
  | ProjectImage
  | ProjectReceipt
  | undefined {
  if (item.type === 'image') {
    return imageStore.images.find(
      image =>
        image.id === item.id,
    )
  }

  return receiptStore.receipts.find(
    receipt =>
      receipt.id === item.id,
  )
}
/*
const showTasks = computed({
  get: () => projectInfo.showTasks.value,
  set: value => {
    projectInfo.showTasks.value = value
  },
})
*/
/*
 * Open image in fullscreen viewer.
 */
function openImage(url: string): void {
  const index =
    imageStore.images.findIndex(
      image => image.url === url,
    )

  if (index < 0) {
    return
  }

  //const items = imageStore.images.map(imageToViewerItem,
    /*image => ({
      id: image.id,
      url: image.url,
      createdAt: image.createdAt,
      type: 'image' as const,
    }),*/
  //)

  openViewer(
    'images',
    //items,
    getViewerItems('images'),
    index,
  )
}

/*
 * Open receipt in fullscreen viewer.
 */
async function openReceipt(
  index: number,
): Promise<void> {
  await loadReceipts()

   const receipts = receiptStore.receipts
  if (!receipts.length) {
    return
  }

  const safeIndex = Math.min(
    Math.max(index, 0),
    receipts.length - 1,
  )

  //const items =
    //receipts.map(receiptToViewerItem,
      /*receipt => ({
        id: receipt.id,
        url: receipt.url,
        createdAt: receipt.createdAt,
        type: 'receipt' as const,
      }),*/
    //)

  openViewer(
    'receipts',
    //items,
    getViewerItems('receipts'),
    safeIndex,
  )
}

/*
 * Delete current image / receipt.
 
async function deleteCurrentViewerItem(
  item?:  {
    id: string
    url: string
  },
): Promise<void> {
  if (!isAdmin.value) {
    return
  }

  const current =
    item ??
    currentViewerItem.value

  if (!current) {
    return
  }

  if (
    !window.confirm(
      t('project.confirmDeleteImage'),
    )
  ) {
    return
  }

  deletingImage.value = true

  try {
    await removeViewerItem(
      current,
      viewerType.value,
    )

    if (
      viewerType.value === 'images'
    ) {
      viewerItems.value =
        imageStore.images.map(
          image => ({
            id: image.id,
            url: image.url,
            createdAt:
              image.createdAt,
            type: 'image' as const,
          }),
        )
    } else {
      viewerItems.value =
        receiptStore.receipts.map(
          receipt => ({
            id: receipt.id,
            url: receipt.url,
            createdAt:
              receipt.createdAt,
            type: 'receipt' as const,
          }),
        )
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
  } finally {
    deletingImage.value = false
  }
}
*/
async function deleteCurrentViewerItem(
  item?:
    | ProjectImage
    | ProjectReceipt,
): Promise<void> {
  if (!isAdmin.value) {
    return
  }

  /**
   * If the delete button in the receipt grid was clicked,
   * we already receive the real store entity.
   *
   * If the fullscreen delete button was clicked,
   * find the real entity by viewer item id.
   */
  const entity =
    item ??
    (
      currentViewerItem.value
        ? findViewerEntity(
            currentViewerItem.value,
          )
        : undefined
    )

  if (!entity) {
    return
  }

  if (
    !window.confirm(
      t(
        'project.confirmDeleteImage',
      ),
    )
  ) {
    return
  }

  deletingImage.value = true

  try {
    await removeViewerItem(
      entity,
      viewerType.value,
    )

    /**
     * Rebuild viewer items from the stores.
     * This prevents stale deleted items from remaining
     * in the fullscreen viewer.
     */
    const newItems =
      getViewerItems(
        viewerType.value,
      )

    //viewerItems.value = newItems

    if (!newItems.length) {
      closeViewer()
      return
    }

    replaceViewerItems(
      newItems,
    )
    /**
     * Keep the current index valid.
    
    if (
      viewerIndex.value >=
      newItems.length
    ) {
      viewerIndex.value =
        newItems.length - 1
    }

    if (
      viewerIndex.value < 0
    ) {
      viewerIndex.value = 0
    } */
  } finally {
    deletingImage.value = false
  }
}

/*
 * When project changes:
 *
 * - cancel/reset old project state
 * - close viewer
 * - clear media
 * - load new stats
 */
function onProjectChanged(): void {
  closeViewer()
  resetForProject()
  void resetMedia()
  //resetMedia()
  showTasks.value = false
  sentinel.value = null
}

watch(
  () => props.projectId,
  async id => {
    if (!id) {
      return
    }

    onProjectChanged()

    await loadStats()
  },
  {
    immediate: true,
  },
)

watch(
  () => props.isAdmin,
  isAdminValue => {
    if (!isAdminValue) {
      showDetails.value = null
      editMode.value = null
      showTasks.value = false
      closeViewer()
    }
  },
)
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

    <template
      v-else-if="stats"
    >
      <ProjectHeader
        :project="stats.project"
      />

      <ProjectMetrics
        v-if="isAdmin"
        :stats="stats"
        :is-admin="isAdmin"
        :total-project-price="
          totalProjectPrice
        "
        :extra-hours-price="
          extraHoursPrice
        "
        :workers-cost="
          workersCost
        "
        :profit="profit"
        :area="area"
        :price="price"
        :extra-price="extraPrice"
        :edit-mode="editMode"
        @update:area="
          area = $event
        "
        @update:price="
          price = $event
        "
        @update:extra-price="
          extraPrice = $event
        "
        @update:edit-mode="
          editMode = $event
        "
        @save-area="saveArea"
        @save-price="savePrice"
        @save-extra-price="
          saveExtraPrice
        "
      />

      <ProjectTimeSummary
        :is-admin="isAdmin"
        :total-work="totalWork"
        :total-extra="totalExtra"
        :total-all="totalAll"
        :show-details="showDetails"
        :filtered-details="
          filteredDetails
        "
        :loading-details="
          loadingDetails
        "
        @toggle="toggleSummary"
      />

      <ProjectUsers
        v-if="isAdmin"
        :project-id="projectId"
        :stats="stats"
        :is-admin="isAdmin"
        :expanded-user-id="
          expandedUserId
        "
        :loading-project-user-id="
          statsLoadingUserId
        "
        :project-user-entries="
          projectUserEntries
        "
        @toggle="toggleDetails"
      />

      <button
        class="toggle-tasks-btn receipt-btn"
        @click="
          showTasks = !showTasks
        "
      >
        {{
          showTasks
            ? t('project.hideTasks')
            : t('project.showTasks')
        }}
      </button>

      <ProjectTasks
        v-if="showTasks"
        :project-id="projectId"
        :is-admin="isAdmin"
      />

      <ProjectMedia
        :project-id="projectId"
        :is-admin="isAdmin"
        :image-store="imageStore"
        :receipt-store="receiptStore"
        :show-images="showImages"
        :show-receipts="showReceipts"
        :loaded="loaded"
        :sentinel="sentinel"
        :viewer-open="viewerOpen"
        :viewer-type="viewerType"
        :viewer-items="viewerItems"
        :current-viewer-item="
          currentViewerItem
        "
        :scale="scale"
        :translate-x="translateX"
        :translate-y="translateY"
        :deleting-image="
          deletingImage
        "
        @set-sentinel="setSentinel"
        @toggle-images="
          showImages = !showImages
        "
        @toggle-receipts="
          toggleReceipts
        "
        @image-load="onLoad"
        @open-image="openImage"
        @open-receipt="openReceipt"
        @upload-receipts="
          uploadReceipts
        "
        @delete="
          deleteCurrentViewerItem
        "
        @close-viewer="
          closeViewer
        "
        @touch-start="
          onTouchStart
        "
        @touch-move="
          onTouchMove
        "
        @touch-end="
          onTouchEnd
        "
      />
    </template>
  </div>
</template>