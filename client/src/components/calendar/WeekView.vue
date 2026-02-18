<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSwipe } from '@vueuse/core'
import dayjs, { Dayjs } from 'dayjs'
import Holidays from 'date-holidays'
import { isWeekend } from '../pages/components/helpers/helpers'

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

const hd = new Holidays('SE')

const isHoliday = (day: Dayjs): boolean => {
  return !!hd.isHoliday(day.toDate())
}

useSwipe(el, {
  onSwipeEnd(_, direction) {
    if (direction === 'left') emit('next')
    if (direction === 'right') emit('prev')
  },
})

/* ========= DAYS ========= */
const startOfWeek = computed(() =>
  props.current.clone().startOf('isoWeek'),
)

const days = computed(() =>
  Array.from({ length: 7 }, (_, i) =>
    startOfWeek.value.clone().add(i, 'day'),
  ),
)

/* ========= HELPERS ========= */
const today = dayjs()

const isFuture = (day: Dayjs): boolean =>
  day.isAfter(today, 'day')

/* ========= TOTAL ========= 
const totalWeekHours = computed((): number =>
  days.value.reduce(
    (sum, day) => sum + props.hoursForDay(day),
    0,
  ),
)
*/
</script>

<template>
  <div
    ref="el"
    class="week-row"
  >
    <div
      v-for="day in days"
      :key="day.format('YYYY-MM-DD')"
      class="week-day"
      :class="{
        today: day.isSame(today, 'day'),
        disabled: isFuture(day),
        weekend: isWeekend(day),
        holiday: isHoliday(day),
      }"
      @click="!isFuture(day) && emit('select-day', day)"
    >
      <div class="weekday">
        {{ day.format('ddd') }}
      </div>
      <div class="date">
        {{ day.format('D') }}
      </div>
      <div class="hours">
        {{ hoursForDay(day) }}h
      </div>
    </div>
  </div>
</template>

<style scoped src="./week.css"></style>