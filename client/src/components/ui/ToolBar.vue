<script setup lang="ts">
import LockIcon from './LockIcon.vue'
import { useI18n } from 'vue-i18n'

defineProps<{
  title: string
  locked?: boolean
  isAdmin?: boolean
  showLockControls?: boolean
  showLockAction?: boolean
  lockActionLabel?: string
}>()
const { t } = useI18n()
const emit = defineEmits<{
  (e: 'prev'): void
  (e: 'next'): void
  (e: 'toggleLock'): void
}>()
</script>

<template>
  <div class="toolbar">
    <button
      class="nav"
      @click="emit('prev')"
    >
      ‹
    </button>
    <span class="title">{{ title }}</span>
    <button
      class="nav"
      @click="emit('next')"
    >
      ›
    </button>
    <div
      v-if="showLockControls"
      class="lock-controls"
    >
      <span
        class="lock-indicator"
        :class="locked ? 'is-locked' : 'is-open'"
        :title="locked
          ? t('calendar.weekLocked')
          : t('calendar.weekOpen')"
      >
        <LockIcon
          :locked="!!locked"
          :size="19"
        />
      </span>

      <button
        v-if="isAdmin && showLockAction"
        class="lock-button"
        :class="locked ? 'unlock-button' : 'close-button'"
        @click="emit('toggleLock')"
      >
        {{ lockActionLabel ?? (
          locked
            ? t('calendar.unlockWeek')
            : t('calendar.closeWeek')
        ) }}
      </button>
    </div>
  </div>
</template>

<style scoped src="./toolBar.style.css"></style>