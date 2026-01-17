<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import dayjs, { Dayjs } from 'dayjs'

import WeekView from '../calendar/WeekView.vue'
import MonthView from '../calendar/MonthView.vue'
import SegmentedTabs from '../ui/SegmentedTabs.vue'
import Toolbar from '../ui/ToolBar.vue'
import RegisterTimePage from '../pages/RegisterTimePage.vue'
import TimeFormModal from '../pages/components/TimeFormModal.vue'
import DayEntryPage from '../pages/components/DayEntryPage.vue'

import { getTimeEntries } from '../../api/TimeEntry.api'
//import type { TimeEntry } from '../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { DayEntry } from '../../types/DayEntry.type'
import { getProjectAssignments } from '../../api/projectAssignment.api'
import type { ProjectAssignment } from '../../types/ProjectAssignment.type'

/* ================= STATE ================= */
type ViewState = 'calendar' | 'tabs' |'dayEntries' | 'modal'
const view = ref<ViewState>('calendar')

const mode = ref<'week' | 'month'>('week')
const current = ref(dayjs())

const entries = ref<DayEntry[]>([])
const selectedDayEntries = ref<DayEntry[]>([])
const editEntry = ref<DayEntry | null>(null)
//const entries = ref<TimeEntry[]>([])
const selectedDay = ref<Dayjs | null>(null)

//const selectedDayEntries = ref<TimeEntry[]>([])
//const editEntry = ref<TimeEntry | null>(null)
const selectedSuggestion = ref<TimeSuggestion | null>(null)

/* ================= FETCH ================= */
watch([mode, current], async () => {
  const from =
    mode.value === 'week'
      ? current.value.clone().startOf('week')
      : current.value.clone().startOf('month')

  const to =
    mode.value === 'week'
      ? current.value.clone().endOf('week')
      : current.value.clone().endOf('month')

  const timeEntries = await getTimeEntries(
    from.format('YYYY-MM-DD'),
    to.format('YYYY-MM-DD'),
  )
  
    let assignments = []
   try {
    assignments = await getProjectAssignments(
      from.format('YYYY-MM-DD'),
      to.format('YYYY-MM-DD'),
    )
    } catch (e) {
      console.warn('Assignments not loaded', e)
    }
  entries.value = [
    ...timeEntries.map(e => ({
      ...e,
      kind: 'WORK' as const,
    })),
    ...assignments.map((a : ProjectAssignment) => ({
      kind: 'EXTRA' as const,
      id: a.id,
      date: a.date,
      hours: a.hours,
      projectId: a.project.id,
      //comment: a.extraWork,
      comment: a.comment,
      startTime: a.startTime,
      endTime: a.endTime,
      breakMinutes: a.breakMinutes,
    })),
  ] 
  //entries.value = await getTimeEntries(
  //  from.format('YYYY-MM-DD'),
  //  to.format('YYYY-MM-DD'),
  //)
}, { immediate: true })

/* ================= HELPERS ================= */
const hoursForDay = (day: Dayjs): number =>
  entries.value
    .filter(e => e.date === day.format('YYYY-MM-DD'))
    .reduce((sum, e) => sum + Number(e.hours), 0)

//const isWork = (e: TimeEntry) =>
//  ['WORK', 'EXTRA', 'MEETING'].includes(e.type)
const isWork = (e: DayEntry) =>
  e.kind === 'WORK' || e.kind === 'EXTRA'

const weekTotal = computed(() => {
  if (mode.value !== 'week') return 0
  const start = current.value.startOf('week')
  const end = current.value.endOf('week')

  return entries.value
    .filter(isWork)
    .filter(e =>
      dayjs(e.date).isBetween(start, end, 'day', '[]'),
    )
    .reduce((sum, e) => sum + Number(e.hours), 0)
})

const monthTotal = computed(() => {
  if (mode.value !== 'month') return 0
  return entries.value
    .filter(isWork)
    .reduce((sum, e) => sum + Number(e.hours), 0)
})

/* ================= ACTIONS ================= */
function openDay(day: Dayjs) {
  selectedDay.value = day
  selectedDayEntries.value = entries.value.filter(
    e => e.date === day.format('YYYY-MM-DD'),
  )
  view.value = selectedDayEntries.value.length
    ? 'dayEntries'
    : 'tabs'
    /*
    const list = entries.value.filter(
    e => e.date === day.format('YYYY-MM-DD'),
  )
  if (list.length > 0) {
    selectedDayEntries.value = list
    view.value = 'dayEntries'
  } else {
    view.value = 'tabs'
  }
  //view.value = 'tabs'
  */
}

//function editFromList(entry: TimeEntry) {
function editFromList(entry: DayEntry) {
  editEntry.value = entry
  selectedSuggestion.value = null
  view.value = 'modal'
}

function selectSuggestion(s: TimeSuggestion) {
  selectedSuggestion.value = s
  view.value = 'modal'
}

function cancelModal() {
  view.value = selectedDayEntries.value.length
    ? 'dayEntries'
    : 'tabs'
}

async function onSaved() {
  editEntry.value = null
  selectedSuggestion.value = null
  view.value = 'calendar'

  const from =
    mode.value === 'week'
      ? current.value.startOf('week')
      : current.value.startOf('month')

  const to =
    mode.value === 'week'
      ? current.value.endOf('week')
      : current.value.endOf('month')

  //entries.value = await getTimeEntries(
  //  from.format('YYYY-MM-DD'),
  //  to.format('YYYY-MM-DD'),
  //)
  const timeEntries = await getTimeEntries(
    from.format('YYYY-MM-DD'),
    to.format('YYYY-MM-DD'),
  )
  let assignments = []
  try {
    assignments = await getProjectAssignments(
      from.format('YYYY-MM-DD'),
      to.format('YYYY-MM-DD'),
    )
    } catch (e) {
      console.warn('Assignments not loaded', e)
    }
  //const assignments = await getProjectAssignments(
  //  from.format('YYYY-MM-DD'),
  //  to.format('YYYY-MM-DD'),
  //)

  entries.value = [
    ...timeEntries.map(e => ({ ...e, kind: 'WORK' as const })),
    ...assignments.map((a : ProjectAssignment) => ({
      kind: 'EXTRA' as const,
      id: a.id,
      date: a.date,
      hours: a.hours,
      projectId: a.project.id,
      comment: a.comment,
      startTime: a.startTime,
      endTime: a.endTime,
      breakMinutes: a.breakMinutes,
    })),
  ]
}

function prev() {
  current.value =
    mode.value === 'week'
      ? current.value.clone().subtract(1, 'week')
      : current.value.clone().subtract(1, 'month')
}

function next() {
  current.value =
    mode.value === 'week'
      ? current.value.clone().add(1, 'week')
      : current.value.clone().add(1, 'month')
}

function addWork() {
  editEntry.value = null
  selectedSuggestion.value = null
  view.value = 'modal'
}
</script>

<template>
  <!-- CALENDAR -->
  <template v-if="view === 'calendar'">
    <SegmentedTabs v-model="mode" />

    <Toolbar
      :title="mode === 'week'
        ? `Week ${current.week()}`
        : current.format('MMMM YYYY')"
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
      @select-day="openDay"
    />

    <div class="totals">
      <strong v-if="mode === 'week'">Week total: {{ weekTotal }} h</strong>
      <strong v-else>Month total: {{ monthTotal }} h</strong>
    </div>
  </template>

  <DayEntryPage
    v-if="view === 'dayEntries' && selectedDay"
    :date="selectedDay.format('YYYY-MM-DD')"
    :entries="selectedDayEntries"
    @edit="editFromList"
    @add="addWork"
    @back="view = 'calendar'"
  />

  <!-- TABS -->
  <RegisterTimePage
    v-else-if="view === 'tabs' && selectedDay"
    :day="selectedDay"
    @select-suggestion="selectSuggestion"
    @close="view = 'calendar'"
  />

  <!-- MODAL -->
  <TimeFormModal
    v-else-if="view === 'modal' && selectedDay"
    :date="selectedDay.format('YYYY-MM-DD')"
    :preset="selectedSuggestion"
    :entry="editEntry"
    @cancel="cancelModal"
    @saved="onSaved"
  />
</template>
//v-else-if="view === 'modal' && selectedDay && selectedSuggestion"