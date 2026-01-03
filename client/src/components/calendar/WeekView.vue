<script setup lang="ts">
import { computed } from 'vue'
import dayjs, { Dayjs } from 'dayjs'
//import WeekDayRow from './WeekDayRow.vue'

const props = defineProps<{
  current: Dayjs
  hoursForDay: (day: Dayjs) => number
}>()

const emit = defineEmits<{
  (e: 'select-day', day: Dayjs): void
}>()

const startOfWeek = computed(() =>
  props.current.startOf('week'),
)

const days = computed(() =>
  Array.from({ length: 7 }, (_, i) =>
    startOfWeek.value.add(i, 'day'),
  ),
)
const today = dayjs()
//const totalWeekHours = computed(() =>
//  days.value.reduce(
//    (s, d) => s + props.hoursForDay(d),
//    0,
//  ),
//)
</script>

<template>
  <div class="week-row">
    <div
      v-for="day in days"
      :key="day.format('YYYY-MM-DD')"
      class="week-day"
      :class="{ today: day.isSame(today, 'day') }"
      @click="emit('select-day', day)"
    >
      <div class="weekday">{{ day.format('ddd') }}</div>
      <div class="date">{{ day.format('D') }}</div>
      <div class="hours">
        {{ hoursForDay(day) }}h
      </div>
    </div>
  </div>
</template>
<style scoped src="./week.css"></style>