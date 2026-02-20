<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSwipe } from '@vueuse/core'
import dayjs, { Dayjs } from 'dayjs'
import { isHoliday } from '../helpers/holiday'
import { isWeekend } from '../helpers/helpers'

const props = defineProps<{
  current: Dayjs
  hoursForDay: (day: Dayjs) => number
}>()

const emit = defineEmits<{
  (e: 'select-day', day: Dayjs): void
  (e: 'prev'): void
  (e: 'next'): void
}>()

const el = ref<HTMLElement | null>(null)


useSwipe(el, {
  onSwipeEnd(_, direction) {
    if (direction === 'left') emit('next')
    if (direction === 'right') emit('prev')
  },
})

const startOfWeek = computed(() =>
  props.current.clone().startOf('isoWeek'),
)

const days = computed(() =>
  Array.from({ length: 7 }, (_, i) =>
    startOfWeek.value.clone().add(i, 'day'),
  ),
)

const today = dayjs()

const isFuture = (day: Dayjs): boolean =>
  day.isAfter(today, 'day')
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