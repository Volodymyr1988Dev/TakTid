<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSwipe } from '@vueuse/core'
import dayjs, { Dayjs } from 'dayjs'

const props = defineProps<{
  current: Dayjs
  hoursForDay: (day: Dayjs) => number
}>()

const emit = defineEmits<{
  (e: 'select-day', day: Dayjs): void
  (e: 'prev'): void
  (e: 'next'): void
}>()

/* ========= SWIPE ========= */
const el = ref<HTMLElement | null>(null)

useSwipe(el, {
  onSwipeEnd(_, direction) {
    if (direction === 'left') emit('next')
    if (direction === 'right') emit('prev')
  },
})

/* ========= DAYS ========= */
const startOfWeek = computed(() =>
  props.current.startOf('week'),
)

const days = computed(() =>
  Array.from({ length: 7 }, (_, i) =>
    startOfWeek.value.add(i, 'day'),
  ),
)

/* ========= HELPERS ========= */
const today = dayjs()

const isFuture = (day: Dayjs) =>
  day.isAfter(today, 'day')

/* ========= TOTAL ========= */
const totalWeekHours = computed(() =>
  days.value.reduce(
    (s, d) => s + props.hoursForDay(d),
    0,
  ),
)
</script>

<template>
  <div ref="el" class="week-row">
    <div
      v-for="day in days"
      :key="day.format('YYYY-MM-DD')"
      class="week-day"
      :class="{
        today: day.isSame(today, 'day'),
        disabled: isFuture(day),
      }"
      @click="!isFuture(day) && emit('select-day', day)"
    >
      <div class="weekday">{{ day.format('ddd') }}</div>
      <div class="date">{{ day.format('D') }}</div>
      <div class="hours">
        {{ hoursForDay(day) }}h
      </div>
    </div>

    <div class="week-total">
      {{ totalWeekHours }}h
    </div>
  </div>
</template>

<style scoped src="./week.css"></style>