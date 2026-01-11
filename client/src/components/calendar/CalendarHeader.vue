<script setup lang="ts">
import { Dayjs } from 'dayjs'
import { useAuthStore } from '../../stores/auth.store'

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
        Vecka
      </button>

      <button
        :class="{ active: mode === 'month' }"
        @click="emit('changeMode', 'month')"
      >
        Månad
      </button>
    </div>

    <div class="center">
      {{ mode === 'month'
        ? current.format('MMMM YYYY')
        : `Week ${current.week()}` }}
    </div>

    <div 
      v-if="showLogout !==false"
      class="right"
    >
      <button 
        class="logout" 
        @click="logout"
      >
        Log out
      </button>
    </div>
  </div>
</template>
<style scoped src="./calendar-header.css"></style>



