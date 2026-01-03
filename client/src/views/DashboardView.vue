<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import dayjs, { Dayjs } from 'dayjs'

import MonthView from '../components/calendar/MonthView.vue'
import WeekView from '../components/calendar/WeekView.vue'
import DayModal from '../components/calendar/DayModal.vue'
import SegmentedTabs from '../components/ui/SegmentedTabs.vue'
import FabButton from '../components/ui/FabButton.vue'
import Toolbar from '../components/ui/ToolBar.vue'

import { getTimeEntries } from '../api/TimeEntry'
import type { TimeEntry } from '../types/TimeEntry.type'

/* ========= STATE ========= */
const mode = ref<'week' | 'month'>('week')
const current = ref(dayjs())

/* ========= DATA ========= */
const entries = ref<TimeEntry[]>([])

/* ========= LOAD ENTRIES ========= */
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

/* ========= MODAL ========= */
const selectedDay = ref<Dayjs | null>(null)
const isModalOpen = ref(false)

function openDay(day: Dayjs) {
  selectedDay.value = day
  isModalOpen.value = true
}

/* ========= NAVIGATION ========= */
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

/* ========= COMPUTED ========= */
const title = computed(() =>
  mode.value === 'week'
    ? `Week ${current.value.week()} · ${current.value.format('MMM YYYY')}`
    : current.value.format('MMMM YYYY'),
)

const hoursForDay = (day: Dayjs) =>
  entries.value
    .filter(e => e.date === day.format('YYYY-MM-DD'))
    .reduce((s, e) => s + e.hours, 0)

const totalMonthHours = computed(() =>
  entries.value.reduce((s, e) => s + e.hours, 0),
)

const existingEntry = computed(() =>
  entries.value.find(
    e => e.date === selectedDay.value?.format('YYYY-MM-DD'),
  ),
)
</script>

<template>
  <div class="page">
    <header class="topbar">
      <h1>Time registration</h1>
    </header>

    <SegmentedTabs v-model="mode" />

    <Toolbar
      :title="title"
      @prev="prev"
      @next="next"
    />

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

    <div v-if="mode === 'month'" class="month-total">
      Total: {{ totalMonthHours }} h
    </div>

    <FabButton @click="openDay(dayjs())" />

    <DayModal
      v-if="isModalOpen && selectedDay"
      :day="selectedDay"
      :entry="existingEntry"
      @close="isModalOpen = false"
    />
  </div>
</template>