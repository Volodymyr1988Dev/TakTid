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
import type { TimeEntry } from '../../types/TimeEntry.type'
import { getProjectAssignments } from '../../api/projectAssignment.api'
import type { ProjectAssignment } from '../../types/ProjectAssignment.type'
import { TimeKind } from '../../types/timeKind.enum'
import { useAuthStore } from '../../stores/auth.store'
import { useProjectStore } from '../../stores/project.store'
import type { Totals } from '../../types/totals'

/* ================= STATE ================= */
type ViewState = 'calendar' | 'tabs' |'dayEntries' | 'modal'
const view = ref<ViewState>('calendar')

const mode = ref<'week' | 'month'>('week')
const current = ref(dayjs())

const entries = ref<DayEntry[]>([])
const selectedDayEntries = ref<DayEntry[]>([])

const selectedDay = ref<Dayjs | null>(null)
const editEntry = ref<DayEntry | null>(null)

const auth = useAuthStore()
const projectStore = useProjectStore()
//const selectedDayEntries = ref<TimeEntry[]>([])
//const editEntry = ref<TimeEntry | null>(null)
const selectedSuggestion = ref<TimeSuggestion | null>(null)

function mapToDayEntries(
  timeEntries: TimeEntry[],
  assignments: ProjectAssignment[],
): DayEntry[] {
  const workEntries: DayEntry[] = timeEntries.map(e => {
    const project = projectStore.getById(e.projectId)

    if (!project) {
      throw new Error(
        `Project not found for TimeEntry ${e.id} (projectId=${e.projectId})`,
      )
    }

    return {
      ...e,
      kind: 'WORK',
      project,
      comment: e.comment ?? '',
    }
  })

  const extraEntries: DayEntry[] = assignments.map(a => {
    if (!a.project) {
      throw new Error(
        `Project missing in ProjectAssignment ${a.id}`,
      )
    }

    return {
      kind: 'EXTRA',
      id: a.id,
      date: a.date,
      hours: a.hours,
      projectId: a.project.id,
      project: a.project,

      comment: a.comment ?? '',
      startTime: a.startTime,
      endTime: a.endTime,
      breakMinutes: a.breakMinutes ?? 0,
    }
  })

  return [...workEntries, ...extraEntries]
}

async function loadEntries() {

  const from =
    mode.value === 'week'
      ? current.value.clone().startOf('isoWeek')
      : current.value.clone().startOf('month')

  const to =
    mode.value === 'week'
      ? current.value.clone().endOf('isoWeek')
      : current.value.clone().endOf('month')

  await projectStore.load()
  const [timeEntries, assignments] = await Promise.all([
    getTimeEntries(from.format('YYYY-MM-DD'), to.format('YYYY-MM-DD')),
    getProjectAssignments(from.format('YYYY-MM-DD'), to.format('YYYY-MM-DD'))
      .catch(() => []),
  ])

  entries.value = mapToDayEntries(timeEntries, assignments)
  /*
  const timeEntries = await getTimeEntries(
    from.format('YYYY-MM-DD'),
    to.format('YYYY-MM-DD'),
  )
    //let assignments: ProjectAssignment[] = []
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
      project: projectStore.getById(e.projectId),
    })),
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
  */
}

const totals = computed<Totals>(() => {
  return entries.value
    .filter(inCurrentPeriod)
    .reduce<Totals>(
      (acc, e) => {
        const hours = Number(e.hours)

        if (isWork(e)) acc.work += hours

        if (isAbsence(e, TimeKind.SICK)) acc.sick += hours
        if (isAbsence(e, TimeKind.VAB)) acc.vab += hours
        if (isAbsence(e, TimeKind.VACATION)) acc.vacation += hours
        if (isAbsence(e, TimeKind.MEETING)) acc.vacation += hours

        return acc
      },
      { work: 0, sick: 0, vab: 0, vacation: 0 },
    )
})
/* ================= FETCH ================= */
watch(
  ()=>[ auth.isInitialized, auth.isAuthenticated, mode.value, current.value],
  //async ([isInitialized, isAuth]) => {
  async ([ready, isAuth]) => {
    if (ready && isAuth) //loadEntries()
    //if (!Initialized || !isAuth) //{
      //console.error('User not authenticated, skipping time entries load')
    //  return
    //}
   // try {
      await loadEntries()
    //} catch (e) {
    //  console.error('Failed to load time entries', e)
  //}
}, { immediate: true })

/* ================= HELPERS ================= */
function isWork(e: DayEntry) {
  return e.kind === 'WORK' || e.kind === 'EXTRA'
}

function isAbsence(e: DayEntry, kind: TimeKind) {
  return e.kind === 'WORK' && e.type === kind
}

function inCurrentPeriod(e: DayEntry): boolean {
  return mode.value === 'week'
    ? dayjs(e.date).isSame(current.value, 'week')
    : dayjs(e.date).isSame(current.value, 'month')
}

function sumHours(list: DayEntry[]) {
  return list.reduce((s, e) => s + Number(e.hours), 0)
}

const hoursForDay = (day: Dayjs): number =>
sumHours(entries.value.filter(e => dayjs(e.date).isSame(day, 'day')))
  //entries.value
    //.filter(e => e.date === day.format('YYYY-MM-DD'))

    //.filter(e => dayjs(e.date).isSame(day, 'day'))
    //.reduce((sum, e) => sum + Number(e.hours), 0)

const weekTotal = computed(() => {
  if (mode.value !== 'week') return 0
  const start = current.value.startOf('isoWeek')

  return entries.value
    .filter(isWork)
    .filter(e =>
      dayjs(e.date).isSame(start, 'week')
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
    //e => e.date === day.format('YYYY-MM-DD'),
    e => dayjs(e.date).isSame(day, 'day'),
  )
  view.value = selectedDayEntries.value.length
    ? 'dayEntries'
    : 'tabs'
}

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
  await loadEntries()
  /*
  const from =
    mode.value === 'week'
      ? current.value.startOf('isoWeek')
      : current.value.startOf('month')

  const to =
    mode.value === 'week'
      ? current.value.endOf('isoWeek')
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
    ...timeEntries.map(e => ({ ...e, kind: 'WORK' as const, project: projectStore.getById(e.projectId)})),
    ...assignments.map((a : ProjectAssignment) => ({
      kind: 'EXTRA' as const,
      id: a.id,
      date: a.date,
      hours: a.hours,
      project: a.project,
      projectId: a.project.id,
      comment: a.comment,
      startTime: a.startTime,
      endTime: a.endTime,
      breakMinutes: a.breakMinutes,
    })),
  ]
  */
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
  selectedSuggestion.value = {
    type: TimeKind.WORK,
  } as TimeSuggestion
  view.value = 'tabs'
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
      <div class="total-item main">
        <span>{{ mode === 'week' ? 'Week total' : 'Month total' }}</span>
        <strong>{{ mode === 'week' ? weekTotal : monthTotal }} h</strong>
      </div>

      <div class="total-item">
        <span>Sick</span>
        <strong>{{ totals.sick }} h</strong>
      </div>

      <div class="total-item">
        <span>VAB</span>
        <strong>{{ totals.vab }} h</strong>
      </div>

      <div class="total-item">
        <span>Total work</span>
        <strong>{{ totals.work }} h</strong>
      </div>
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