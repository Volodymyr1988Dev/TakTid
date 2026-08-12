<script setup lang="ts">
import { ref } from 'vue'

import { useI18n } from 'vue-i18n'

import type { ViewerItem } from '../../types/ViewerItem'
import type { ProjectImage } from '../../types/ProjectImage.type'
import type { ProjectReceipt } from '../../types/projectReceipts.type'

const props = defineProps<{
  projectId: string
  isAdmin: boolean

  imageStore: any
  receiptStore: any

  showImages: boolean
  showReceipts: boolean

  loaded: Set<string>

  /*
   * Vue unwraps refs passed through template.
   *
   * Therefore this must be HTMLElement | null,
   * not Ref<HTMLElement | null>.
   */
  sentinel: HTMLElement | null

  viewerOpen: boolean
  viewerType: 'images' | 'receipts'

  viewerItems: ViewerItem[]

  currentViewerItem:
    | ViewerItem
    | null

  scale: number
  translateX: number
  translateY: number

  deletingImage: boolean
}>()

const emit = defineEmits<{
  toggleImages: []
  toggleReceipts: []

  imageLoad: [id: string]

  openImage: [url: string]
  openReceipt: [index: number]

  uploadReceipts: [event: Event]

  delete: [
    item?: ProjectImage | ProjectReceipt,
  ]

  closeViewer: []

  touchStart: [event: TouchEvent]
  touchMove: [event: TouchEvent]
  touchEnd: [event: TouchEvent]

  setSentinel: [
    element: HTMLElement | null,
  ]
}>()

const { t } = useI18n()

const receiptInput =
  ref<HTMLInputElement | null>(null)

/**
 * Vue template refs can receive either
 * DOM elements or component instances.
 *
 * We only care about HTMLElement.
 
function setSentinel(
  element:
    | Element
    | ComponentPublicInstance
    | null,
): void {
  emit(
    'setSentinel',
    element instanceof HTMLElement
      ? element
      : null,
  )
}
*/
function handleToggleImages(): void {
  emit('toggleImages')
}

function handleToggleReceipts(): void {
  emit('toggleReceipts')
}

function handleImageLoad(
  id: string,
): void {
  emit('imageLoad', id)
}

function handleOpenImage(
  url: string,
): void {
  emit('openImage', url)
}

function handleOpenReceipt(
  index: string | number,
): void {
  emit(
    'openReceipt',
    Number(index),
  )
}

function handleUploadReceipts(
  event: Event,
): void {
  emit(
    'uploadReceipts',
    event,
  )

  if (receiptInput.value) {
    receiptInput.value.value = ''
  }
}

function handleDelete(
  item?: ProjectImage | ProjectReceipt,
): void {
  emit('delete', item)
}

function handleCloseViewer(): void {
  emit('closeViewer')
}

function handleTouchStart(
  event: TouchEvent,
): void {
  emit(
    'touchStart',
    event,
  )
}

function handleTouchMove(
  event: TouchEvent,
): void {
  emit(
    'touchMove',
    event,
  )
}

function handleTouchEnd(
  event: TouchEvent,
): void {
  emit(
    'touchEnd',
    event,
  )
}

function openReceiptInput(): void {
  receiptInput.value?.click()
}
</script>

<template>
  <section class="media-section">
    <!-- ==================== IMAGES ==================== -->

    <button
      type="button"
      class="receipt-btn"
      @click="handleToggleImages"
    >
      {{
        showImages
          ? t('project.hideImages')
          : t('project.showImages')
      }}
    </button>

    <div
      v-if="showImages"
      class="images-grid"
    >
      <div
        v-for="image in imageStore.images"
        :key="image.id"
        class="image-wrapper"
      >
        <div
          v-if="!loaded.has(image.id)"
          class="skeleton"
        />

        <img
          :src="image.url"
          class="image"
          :class="{
            loaded: loaded.has(image.id),
          }"
          loading="lazy"
          alt=""
          @load="
            handleImageLoad(image.id)
          "
          @click="
            handleOpenImage(image.url)
          "
        >
      </div>

      <div
        ref="setSentinel"
        class="sentinel"
      />
    </div>

    <!-- ==================== RECEIPTS ==================== -->

    <div class="receipts-section">
      <div class="receipts-header">
        <button
          type="button"
          class="receipt-btn"
          @click="handleToggleReceipts"
        >
          🧾
          {{
            showReceipts
              ? t(
                  'project.hideReceipts',
                )
              : t(
                  'project.showReceipts',
                )
          }}
          ({{ receiptStore.count }})
        </button>

        <button
          type="button"
          class="add-receipt-btn"
          @click="openReceiptInput"
        >
          ➕
          {{ t('project.addReceipt') }}
        </button>
      </div>

      <div
        v-if="showReceipts"
        class="receipt-grid"
      >
        <div
          v-if="receiptStore.loading"
          class="receipt-loading"
        >
          {{
            t(
              'project.loadingReceipts',
            )
          }}
        </div>

        <div
          v-for="(
            receipt,
            index
          ) in receiptStore.receipts"
          :key="receipt.id"
          class="receipt-card"
          @click="
            handleOpenReceipt(index)
          "
        >
          <button
            v-if="isAdmin"
            type="button"
            class="delete-btn"
            :disabled="deletingImage"
            @click.stop="
              handleDelete(receipt)
            "
          >
            🗑
          </button>

          <img
            :src="receipt.url"
            loading="lazy"
            alt=""
          >

          <div class="receipt-date">
            {{ receipt.createdAt }}
          </div>
        </div>
      </div>
    </div>

    <!-- ==================== FULLSCREEN VIEWER ==================== -->

    <div
      v-if="viewerOpen"
      class="image-modal"
      @click="handleCloseViewer"
    >
      <img
        v-if="currentViewerItem"
        :src="currentViewerItem.url"
        class="image-modal-content"
        :style="{
          transform:
            `translate(${translateX}px, ${translateY}px) scale(${scale})`,
        }"
        alt=""
        @click.stop
        @touchstart="
          handleTouchStart($event)
        "
        @touchmove="
          handleTouchMove($event)
        "
        @touchend="
          handleTouchEnd($event)
        "
      >

      <button
        type="button"
        class="image-close"
        @click.stop="handleCloseViewer"
      >
        ✕
      </button>

      <button
        v-if="isAdmin"
        type="button"
        class="image-delete"
        :disabled="deletingImage"
        @click.stop="handleDelete()"
      >
        🗑
      </button>
    </div>

    <!-- ==================== FILE INPUT ==================== -->

    <input
      ref="receiptInput"
      hidden
      type="file"
      multiple
      accept="image/*"
      @change="handleUploadReceipts"
    >
  </section>
</template>

<style scoped>
.media-section {
  margin-top: 40px;
}

.images-grid {
  column-count: 3;
  column-gap: 10px;
  margin-top: 16px;
}

.image-wrapper {
  position: relative;
  break-inside: avoid;
  margin-bottom: 10px;
}

.image {
  display: block;
  width: 100%;
  border-radius: 8px;
  cursor: zoom-in;
  transition:
    transform .2s,
    opacity .3s;
  opacity: 0;
}

.image.loaded {
  opacity: 1;
}

.image:hover {
  transform: scale(1.03);
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

.sentinel {
  height: 1px;
}

@keyframes skeleton {
  0% {
    background-position: -200px 0;
  }

  100% {
    background-position: 200px 0;
  }
}

.receipts-section {
  margin-top: 40px;
  padding-top: 24px;
  border-top: 1px solid #e5e7eb;
}

.receipts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 22px;
}

.receipt-btn,
.add-receipt-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 12px 22px;
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
}

.receipt-btn {
  background: #2563eb;
}

.add-receipt-btn {
  background: #16a34a;
}

.receipt-btn:hover {
  background: #1d4ed8;
}

.add-receipt-btn:hover {
  background: #15803d;
}

.receipt-btn:disabled,
.add-receipt-btn:disabled {
  opacity: .6;
  cursor: not-allowed;
}

.receipt-grid {
  display: grid;
  grid-template-columns:
    repeat(
      auto-fill,
      minmax(220px, 1fr)
    );
  gap: 22px;
}

.receipt-card {
  position: relative;
  overflow: hidden;
  cursor: pointer;
  border-radius: 16px;
  background: white;
  box-shadow:
    0 10px 30px
    rgba(0, 0, 0, .08);
}

.receipt-card img {
  display: block;
  width: 100%;
  height: 180px;
  aspect-ratio: 4 / 5;
  object-fit: cover;
}

.receipt-date {
  padding: 12px;
  color: #64748b;
  font-size: 13px;
  text-align: center;
  border-top: 1px solid #ececec;
}

.delete-btn {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 20;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: rgba(220, 38, 38, .9);
  color: white;
  cursor: pointer;
}

.delete-btn:disabled {
  opacity: .5;
  cursor: wait;
}

.receipt-loading {
  grid-column: 1 / -1;
  padding: 50px;
  color: #64748b;
  text-align: center;
}

.image-modal {
  position: fixed;
  inset: 0;
  z-index: 8999;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, .9);
  backdrop-filter: blur(8px);
}

.image-modal-content {
  max-width: 95%;
  max-height: 95%;
  border-radius: 10px;
  object-fit: contain;
  touch-action: none;
  cursor: grab;
  box-shadow:
    0 10px 40px
    rgba(0, 0, 0, .6);
  will-change: transform;
}

.image-close {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 42px;
  height: 42px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, .9);
  font-size: 18px;
  cursor: pointer;
}

.image-delete {
  position: absolute;
  top: 20px;
  left: 20px;
  width: 48px;
  height: 48px;
  border: none;
  border-radius: 50%;
  background: rgba(220, 38, 38, .95);
  color: white;
  font-size: 22px;
  cursor: pointer;
}

.image-delete:disabled {
  opacity: .5;
  cursor: wait;
}

@media (max-width: 768px) {
  .receipts-header {
    align-items: center;
  }

  .receipt-btn,
  .add-receipt-btn {
    width: 100%;
  }

  .receipt-grid {
    grid-template-columns:
      repeat(
        auto-fill,
        minmax(160px, 1fr)
      );
    gap: 16px;
  }
}

@media (max-width: 640px) {
  .images-grid {
    column-count: 2;
  }
}
</style>