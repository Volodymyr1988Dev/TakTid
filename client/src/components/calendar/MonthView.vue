<script setup lang="ts">
import { computed } from 'vue'
import dayjs, { Dayjs } from 'dayjs'

const props = defineProps<{
  current: Dayjs
  hoursForDay: (day: Dayjs) => number
}>()

/* ========= WEEKDAYS ========= */
const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

/* ========= RANGE ========= */
const start = computed(() =>
  props.current.startOf('month').startOf('week'),
)

const end = computed(() =>
  props.current.endOf('month').endOf('week'),
)

/* ========= DAYS ========= */
const days = computed(() => {
  const result: Dayjs[] = []
  let d = start.value

  while (d.isBefore(end.value)) {
    result.push(d)
    d = d.add(1, 'day')
  }

  return result
})

/* ========= HELPERS ========= */
const today = dayjs()

const isFuture = (day: Dayjs) =>
  day.isAfter(today, 'day')
</script>

<template>
  <div class="month">
    <div class="weekdays">
      <div v-for="w in weekdays" :key="w">
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
        }"
      >
        <span>{{ day.date() }}</span>

        <small v-if="hoursForDay(day) > 0">
          {{ hoursForDay(day) }}h
        </small>
      </div>
    </div>
  </div>
</template>

<style scoped src="./month.css"></style>