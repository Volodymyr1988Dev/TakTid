<script setup lang="ts">
import { Dayjs } from 'dayjs'
import { useAuthStore } from '../../stores/auth.store'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
defineProps<{
  mode: 'month' | 'week'
  current: Dayjs
  showLogout?: boolean
}>()

const emit = defineEmits<{
  (e: 'changeMode', value: 'month' | 'week'): void
  (e: 'prev'): void
  (e: 'next'): void
}>()

const auth = useAuthStore()

function logout(): void {
  auth.logout()
}
</script>

<template>
  <div class="header">
    <div class="left">
      <button
        :class="{ active: mode === 'week' }"
        @click="emit('changeMode', 'week')"
      >
        {{ t('calendar.week') }}
      </button>

      <button
        :class="{ active: mode === 'month' }"
        @click="emit('changeMode', 'month')"
      >
        {{ t('calendar.month') }}
      </button>
    </div>

    <div class="center">
      {{ mode === 'month'
        ? current.format('MMMM YYYY')
        : t('calendar.weekLabel', { num: current.week() }) }}//`${t('calendar.week')} ${current.week()}` }}
    </div>

    <div 
      v-if="showLogout !==false"
      class="right"
    >
      <button 
        class="logout" 
        @click="logout"
      >
        {{ t('calendar.logout') }}
      </button>
    </div>
  </div>
</template>
<style scoped src="./calendar-header.css"></style>



