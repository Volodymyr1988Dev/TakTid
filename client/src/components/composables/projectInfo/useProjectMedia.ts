import {
  nextTick,
  onBeforeUnmount,
  ref,
  watch,
  type Ref,
} from 'vue'

import { useProjectImageStore } from '../../../stores/projectImage.store'
import { useProjectReceiptStore } from '../../../stores/projectReceipts'

import type { ProjectImage } from '../../../types/ProjectImage.type'
import type { ProjectReceipt } from '../../../types/projectReceipts.type'

export function useProjectMedia(
  projectId: Ref<string>,
) {
  const imageStore =
    useProjectImageStore()

  const receiptStore =
    useProjectReceiptStore()

  const showImages = ref(false)
  const showReceipts = ref(false)

  const loaded =
    ref<Set<string>>(new Set())

  const page = ref(1)

  const limit = 20

  const hasMore = ref(true)

  const sentinel =
    ref<HTMLElement | null>(null)

  const receiptsLoaded =
    ref(false)

  const deletingImage =
    ref(false)

  const loadingImages =
    ref(false)

  let observer:
    IntersectionObserver | null = null

  let mediaRequestId = 0

  function onLoad(id: string): void {
    loaded.value.add(id)
  }

  function disconnectObserver(): void {
    observer?.disconnect()
    observer = null
  }

  async function loadImages(): Promise<void> {
    if (
      loadingImages.value ||
      !hasMore.value ||
      imageStore.loading
    ) {
      return
    }

    const requestId =
      mediaRequestId

    const currentPage =
      page.value

    loadingImages.value = true

    try {
      const result =
        await imageStore.loadPaginated(
          projectId.value,
          currentPage,
          limit,
        )

      if (
        requestId !== mediaRequestId
      ) {
        return
      }

      if (
        result.page >=
        result.lastPage
      ) {
        hasMore.value = false
      } else {
        page.value =
          currentPage + 1
      }
    } finally {
      if (
        requestId === mediaRequestId
      ) {
        loadingImages.value = false
      }
    }
  }

  function observeSentinel(): void {
    disconnectObserver()

    const element =
      sentinel.value

    if (!element) {
      return
    }

    observer =
      new IntersectionObserver(
        entries => {
          if (
            entries.some(
              entry =>
                entry.isIntersecting,
            )
          ) {
            void loadImages()
          }
        },
        {
          root: null,
          rootMargin: '300px 0px',
          threshold: 0,
        },
      )

    observer.observe(element)
  }

  async function enableImages(): Promise<void> {
    disconnectObserver()

    page.value = 1
    hasMore.value = true

    imageStore.images = []

    loaded.value = new Set()

    await loadImages()

    await nextTick()

    if (
      showImages.value
    ) {
      observeSentinel()
    }
  }

  async function loadReceipts(): Promise<void> {
    if (
      receiptsLoaded.value ||
      receiptStore.loading
    ) {
      return
    }

    const requestId =
      mediaRequestId

    await receiptStore.loadPaginated(
      projectId.value,
      1,
      100,
    )

    if (
      requestId !== mediaRequestId
    ) {
      return
    }

    receiptsLoaded.value = true
  }

  async function toggleReceipts(): Promise<void> {
    showReceipts.value =
      !showReceipts.value

    if (
      showReceipts.value
    ) {
      await loadReceipts()
    }
  }

  async function resetMedia(): Promise<void> {
    mediaRequestId++

    disconnectObserver()

    showImages.value = false
    showReceipts.value = false

    page.value = 1
    hasMore.value = true

    loadingImages.value = false

    loaded.value = new Set()

    receiptsLoaded.value = false

    imageStore.images = []
    receiptStore.receipts = []

    if (projectId.value) {
      await receiptStore.loadCount(
        projectId.value,
      )
    }
  }

  async function uploadReceipts(
    event: Event,
  ): Promise<void> {
    const input =
      event.target as
        | HTMLInputElement
        | null

    const files =
      input?.files

    if (!files?.length) {
      return
    }

    const selectedFiles =
      Array.from(files)

    await receiptStore.upload(
      projectId.value,
      selectedFiles,
    )

    receiptsLoaded.value = false

    await receiptStore.loadCount(
      projectId.value,
    )

    if (showReceipts.value) {
      await loadReceipts()
    }
  }

  async function removeViewerItem(
    item:
      | ProjectImage
      | ProjectReceipt,
    viewerType:
      | 'images'
      | 'receipts',
  ): Promise<void> {
    if (
      viewerType === 'images'
    ) {
      await imageStore.remove(
        item.id,
      )

      loaded.value.delete(
        item.id,
      )

      return
    }

    await receiptStore.remove(
      item.id,
    )

    receiptsLoaded.value = false

    await receiptStore.loadCount(
      projectId.value,
    )

    if (showReceipts.value) {
      await loadReceipts()
    }
  }

  watch(
    showImages,
    async visible => {
      if (!visible) {
        disconnectObserver()
        return
      }

      await enableImages()
    },
  )

  watch(
    projectId,
    async id => {
      if (!id) {
        return
      }

      await resetMedia()
    },
    {
      immediate: true,
    },
  )

  onBeforeUnmount(() => {
    mediaRequestId++
    disconnectObserver()
  })

  return {
    imageStore,
    receiptStore,

    showImages,
    showReceipts,

    loaded,

    page,
    hasMore,

    sentinel,

    receiptsLoaded,

    deletingImage,

    loadingImages,

    onLoad,
    loadImages,
    observeSentinel,

    loadReceipts,
    toggleReceipts,

    uploadReceipts,
    removeViewerItem,

    resetMedia,
  }
}