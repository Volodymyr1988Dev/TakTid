<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import dayjs, { Dayjs } from 'dayjs'

import WeekView from '../calendar/WeekView.vue'
import MonthView from '../calendar/MonthView.vue'
import DayModal from '../calendar/DayModal.vue'
import SegmentedTabs from '../ui/SegmentedTabs.vue'
import FabButton from '../ui/FabButton.vue'
import Toolbar from '../ui/ToolBar.vue'

import { getTimeEntries } from '../../api/TimeEntry'
import type { TimeEntry } from '../../types/TimeEntry.type'


const mode = ref<'week' | 'month'>('week')
const current = ref(dayjs())
const entries = ref<TimeEntry[]>([])

watch(
  () => [mode.value, current.value],
  async () => {
    const from =
      mode.value === 'week'
        ? current.value.startOf('week')
        : current.value.startOf('month')

    const to =
      mode.value === 'week'
        ? current.value.endOf('week')
        : current.value.endOf('month')

    entries.value = await getTimeEntries(
      from.format('YYYY-MM-DD'),
      to.format('YYYY-MM-DD'),
    )
  },
  { immediate: true },
)

const selectedDay = ref<Dayjs | null>(null)
const isModalOpen = ref(false)

function openDay(day: Dayjs) {
  selectedDay.value = day
  isModalOpen.value = true
}

function prev() {
  current.value =
    mode.value === 'week'
      ? current.value.subtract(1, 'week')
      : current.value.subtract(1, 'month')
}

function next() {
  current.value =
    mode.value === 'week'
      ? current.value.add(1, 'week')
      : current.value.add(1, 'month')
}
const hoursForDay = (day: Dayjs) =>
  entries.value
    .filter(e => e.date === day.format('YYYY-MM-DD'))
    .reduce((sum, e) => sum + e.hours, 0)

const title = computed(() =>
  mode.value === 'week'
    ? `Week ${current.value.week()} · ${current.value.format('MMM YYYY')}`
    : current.value.format('MMMM YYYY'),
)
</script>

<template>
  <SegmentedTabs v-model="mode" />

  <Toolbar :title="title" @prev="prev" @next="next" />

  <WeekView
    v-if="mode === 'week'"
    :current="current"
    :hours-for-day="hoursForDay"
    @select-day="openDay"
  />

  <MonthView
    v-else
    :current="current"
    :hours-for-day="hoursForDay"
  />

  <FabButton @click="openDay(dayjs())" />

  <DayModal
    v-if="isModalOpen && selectedDay"
    :day="selectedDay"
    @close="isModalOpen = false"
  />
</template>