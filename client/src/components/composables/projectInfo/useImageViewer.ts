import {
  computed,
  onBeforeUnmount,
  ref,
} from 'vue'

import type { ViewerItem } from '../../../types/ViewerItem'

export function useImageViewer() {
  const viewerOpen = ref(false)

  const viewerType =
    ref<'images' | 'receipts'>('images')

  const viewerItems =
    ref<ViewerItem[]>([])

  const viewerIndex = ref(0)

  const scale = ref(1)
  const lastScale = ref(1)

  const startDistance = ref(0)

  const translateX = ref(0)
  const translateY = ref(0)

  let lastTouchX = 0
  let lastTouchY = 0

  let isDragging = false
  let isSwiping = false

  let startX = 0
  let startY = 0

  let velocityX = 0

  let scrollY = 0

  const currentViewerItem =
    computed<ViewerItem | null>(
      () =>
        viewerItems.value[
          viewerIndex.value
        ] ?? null,
    )

  function openViewer(
    type: 'images' | 'receipts',
    items: ViewerItem[],
    index: number,
  ): void {
    if (!items.length) {
      return
    }

    viewerType.value = type
    viewerItems.value = [...items]

    viewerIndex.value = Math.min(
      Math.max(index, 0),
      items.length - 1,
    )

    resetTransform()

    viewerOpen.value = true

    scrollY = window.scrollY

    document.body.style.position = 'fixed'
    document.body.style.top =
      `-${scrollY}px`
    document.body.style.width = '100%'
  }

  function closeViewer(): void {
    if (!viewerOpen.value) {
      return
    }

    viewerOpen.value = false

    document.body.style.position = ''
    document.body.style.top = ''
    document.body.style.width = ''

    window.scrollTo(
      0,
      scrollY,
    )

    resetTransform()

    isDragging = false
    isSwiping = false
  }

  function resetTransform(): void {
    scale.value = 1
    translateX.value = 0
    translateY.value = 0

    lastScale.value = 1
    startDistance.value = 0
  }

  function clamp(
    value: number,
    min: number,
    max: number,
  ): number {
    return Math.min(
      Math.max(value, min),
      max,
    )
  }

  function getDistance(
    touches: TouchList,
  ): number | undefined {
    const first = touches[0]
    const second = touches[1]

    if (!first || !second) {
      return undefined
    }

    const dx =
      first.clientX -
      second.clientX

    const dy =
      first.clientY -
      second.clientY

    return Math.sqrt(
      dx * dx + dy * dy,
    )
  }

  function onTouchStart(
    event: TouchEvent,
  ): void {
    if (event.touches.length === 2) {
      const distance =
        getDistance(event.touches)

      if (!distance) {
        return
      }

      startDistance.value =
        distance

      lastScale.value =
        scale.value

      isSwiping = false
      isDragging = false

      return
    }

    if (event.touches.length !== 1) {
      return
    }

    const touch =
      event.touches[0]

    if (!touch) {
      return
    }

    lastTouchX = touch.clientX
    lastTouchY = touch.clientY

    startX = touch.clientX
    startY = touch.clientY

    isDragging = true
    isSwiping = true

    velocityX = 0
  }

  function onTouchMove(
    event: TouchEvent,
  ): void {
    if (event.touches.length === 2) {
      const distance =
        getDistance(event.touches)

      if (
        !distance ||
        !startDistance.value
      ) {
        return
      }

      scale.value = clamp(
        (
          distance /
          startDistance.value
        ) *
          lastScale.value,
        1,
        4,
      )

      return
    }

    if (
      event.touches.length !== 1 ||
      scale.value <= 1 ||
      !isDragging
    ) {
      return
    }

    const touch =
      event.touches[0]

    if (!touch) {
      return
    }

    const dx =
      touch.clientX - lastTouchX

    const dy =
      touch.clientY - lastTouchY

    velocityX = dx

    const target =
      event.currentTarget as
        | HTMLElement
        | null

    if (!target) {
      return
    }

    const rect =
      target.getBoundingClientRect()

    const maxX = Math.max(
      0,
      (
        rect.width *
          scale.value -
        window.innerWidth
      ) / 2,
    )

    const maxY = Math.max(
      0,
      (
        rect.height *
          scale.value -
        window.innerHeight
      ) / 2,
    )

    translateX.value = clamp(
      translateX.value + dx,
      -maxX,
      maxX,
    )

    translateY.value = clamp(
      translateY.value + dy,
      -maxY,
      maxY,
    )

    lastTouchX = touch.clientX
    lastTouchY = touch.clientY
  }

  function onTouchEnd(
    event: TouchEvent,
  ): void {
    if (!isSwiping) {
      return
    }

    if (scale.value > 1) {
      isSwiping = false
      isDragging = false
      return
    }

    const touch =
      event.changedTouches[0]

    if (!touch) {
      return
    }

    const dx =
      touch.clientX - startX

    const dy =
      touch.clientY - startY

    if (
      Math.abs(dy) >
        Math.abs(dx) &&
      dy > 80
    ) {
      closeViewer()

      isSwiping = false
      isDragging = false

      return
    }

    if (
      dx < -50 ||
      velocityX < -20
    ) {
      nextViewerItem()
    } else if (
      dx > 50 ||
      velocityX > 20
    ) {
      prevViewerItem()
    }

    isSwiping = false
    isDragging = false
  }

  function nextViewerItem(): void {
    if (
      viewerIndex.value >=
      viewerItems.value.length - 1
    ) {
      return
    }

    viewerIndex.value++

    resetTransform()
  }

  function prevViewerItem(): void {
    if (
      viewerIndex.value <= 0
    ) {
      return
    }

    viewerIndex.value--

    resetTransform()
  }

  function replaceViewerItems(
    items: ViewerItem[],
  ): void {
    viewerItems.value = [...items]

    if (!items.length) {
      closeViewer()
      return
    }

    if (
      viewerIndex.value >=
      items.length
    ) {
      viewerIndex.value =
        items.length - 1
    }

    if (
      viewerIndex.value < 0
    ) {
      viewerIndex.value = 0
    }
  }

  onBeforeUnmount(() => {
    if (viewerOpen.value) {
      document.body.style.position = ''
      document.body.style.top = ''
      document.body.style.width = ''

      window.scrollTo(
        0,
        scrollY,
      )
    }
  })

  return {
    viewerOpen,
    viewerType,
    viewerItems,
    viewerIndex,

    currentViewerItem,

    scale,
    translateX,
    translateY,

    openViewer,
    closeViewer,

    onTouchStart,
    onTouchMove,
    onTouchEnd,

    nextViewerItem,
    prevViewerItem,

    replaceViewerItems,
    resetTransform,
  }
}