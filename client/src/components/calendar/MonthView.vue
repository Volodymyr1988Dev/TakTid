<script setup lang="ts">
import { computed } from 'vue'
import dayjs, { Dayjs } from 'dayjs'

const emit = defineEmits<{
  (e: 'select-day', day: Dayjs): void
}>()

const props = defineProps<{
  current: Dayjs
  hoursForDay: (day: Dayjs) => number
}>()

const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

const start = computed(() =>
  props.current.clone().startOf('month').startOf('isoWeek'),
)

const end = computed(() =>
  props.current.clone().endOf('month').endOf('isoWeek'),
)

const days = computed(() => {
  const result: Dayjs[] = []
  let d = start.value.clone()

  while (d.isBefore(end.value)) {
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
  <div class="month">
    <div class="weekdays">
      <div
        v-for="w in weekdays"
        :key="w"
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