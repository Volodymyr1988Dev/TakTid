<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSwipe } from '@vueuse/core'
import dayjs, { Dayjs } from 'dayjs'
import { isHoliday } from '../helpers/holiday'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const emit = defineEmits<{
  (e: 'select-day', day: Dayjs): void
  (e: 'prev'): void
  (e: 'next'): void
}>()

const props = defineProps<{
  current: Dayjs
  hoursForDay: (day: Dayjs) => number
}>()

const el = ref<HTMLElement | null>(null)

useSwipe(el, {
  onSwipeEnd(_, direction) {
    if (direction === 'left') emit('next')
    if (direction === 'right') emit('prev')
  },
})

//const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
const weekdays = [
  t('week.mon'),
  t('week.tue'),
  t('week.wed'),
  t('week.thu'),
  t('week.fri'),
  t('week.sat'),
  t('week.sun'),
]
const start = computed(() =>
  props.current.clone().startOf('month').startOf('isoWeek'),
)

const end = computed(() =>
  props.current.clone().endOf('month').endOf('isoWeek'),
)

const days = computed(() => {
  const result: Dayjs[] = []
  let d = start.value.clone()

  while (d.isBefore(end.value)|| d.isSame(end.value, 'day')) {
    result.push(d)
    d = d.clone().add(1, 'day')
  }

  return result
})

const today = dayjs()

const isFuture = (day: Dayjs): boolean =>
  day.isAfter(today, 'day')

function selectDay(day: Dayjs): void {
  if (isFuture(day)) return
  emit('select-day', day)
}
</script>

<template>
  <div 
    ref="el" 
    class="month"
  >
    <div class="weekdays">
      <div
        v-for="w in weekdays"
        :key="w"
        :class="{ weekendLabel: w === 'Sat' || w === 'Sun' }"
      >
        {{ w }}
      </div>
    </div>

    <div class="month-grid">
      <div
        v-for="day in days"
        :key="day.format('YYYY-MM-DD')"
        class="day"
        :class="{
          today: day.isSame(today, 'day'),
          muted: !day.isSame(current, 'month'),
          disabled: isFuture(day),
          holiday: isHoliday(day),
        }"
        @click="selectDay(day)"
      >
        <div class="day-number">
          {{ day.date() }}
        </div>

        <div
          v-if="hoursForDay(day) > 0"
          class="day-hours"
        >
          {{ hoursForDay(day) }} h
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped src="./month.css"></style>