<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import dayjs, { Dayjs } from 'dayjs'

import WeekView from '../components/calendar/WeekView.vue'
import MonthView from '../components/calendar/MonthView.vue'
import SegmentedTabs from '../components/ui/SegmentedTabs.vue'
import Toolbar from '../components/ui/ToolBar.vue'
import RegisterTimePage from '../pages/RegisterTimePage.vue'
import TimeFormModal from './TimeFormModal.vue'
import DayEntryPage from './DayEntryPage.vue'

import { getTimeEntries } from '../api/TimeEntry.api'
import type { TimeSuggestion } from '../types/Suggestion.type'
import type { DayEntry, WorkDayEntry, AbsenceDayEntry, ExtraDayEntry, MeetingDayEntry } from '../types/DayEntry.type'
import type { TimeEntry } from '../types/TimeEntry.type'
import { getProjectAssignments } from '../api/projectAssignment.api'
import type { ProjectAssignment } from '../types/ProjectAssignment.type'
import { TimeKind } from '../types/timeKind.enum'
import { useAuthStore } from '../stores/auth.store'
import { useProjectStore } from '../stores/project.store'
import type { Totals } from '../types/totals'
import { useSuggestionsStore } from '../stores/suggestions.store'
import { useI18n } from 'vue-i18n'
import { isCountedInTotal } from '../components/helpers/helpers'
import { useTimePeriodLockStore } from '../stores/timePeriodLock.store'

defineProps<{
  isAdmin: boolean
}>()
const { t } = useI18n()
type ViewState = 'calendar' | 'tabs' |'dayEntries' | 'modal'
const view = ref<ViewState>('calendar')
const navigating = ref(false)
const mode = ref<'week' | 'month'>('week')
const current = ref(dayjs())

const entries = ref<DayEntry[]>([])
const selectedDayEntries = ref<DayEntry[]>([])

const selectedDay = ref<Dayjs | null>(null)
const editEntry = ref<DayEntry | null>(null)

const auth = useAuthStore()
const projectStore = useProjectStore()
const lockStore = useTimePeriodLockStore()
//const isAdmin = computed(() => auth.user?.isAdmin === true)
const selectedDayLocked = computed(
  () => lockStore.status?.locked ?? true,
)
const suggestionsStore = useSuggestionsStore()
async function loadVisibleLockStatuses(from: Dayjs, to: Dayjs) {
  const firstWeek = from.clone().startOf('isoWeek')
  const lastWeek = to.clone().endOf('isoWeek')
  const currentWeek = current.value
    .clone()
    .startOf('isoWeek')
    .format('YYYY-MM-DD')

  const requests: Promise<unknown>[] = []

  let week = firstWeek.clone()

  while (
    week.isBefore(lastWeek, 'day') ||
    week.isSame(lastWeek, 'day')
  ) {
    const date = week.format('YYYY-MM-DD')
    const isCurrentWeek = date === currentWeek

    requests.push(
      lockStore.loadStatus(date, isCurrentWeek),
    )

    week = week.add(1, 'week')
  }

  await Promise.all(requests)
}

 function mapToDayEntries(
  timeEntries: TimeEntry[],
  assignments: ProjectAssignment[]
): DayEntry[] {
  const result: DayEntry[] = []

  for (const e of timeEntries) {
    const hours = Number(e.hours)

    if (e.type === TimeKind.WORK) {
      if (!e.projectId && !e.project?.id) continue
      const projectId = e.projectId ?? e.project?.id
      if (!projectId) continue
      const work: WorkDayEntry = {
        id: e.id,
        date: e.date,
        hours,
        type: TimeKind.WORK,
        startTime: e.startTime,
        endTime: e.endTime,
        breakMinutes: e.breakMinutes ?? 0,
        projectId: projectId, //e.projectId ?? e.project!.id,
        project: e.project,
        comment: e.comment ?? '',
      }

      result.push(work)
      continue
    }

    if (e.type === TimeKind.MEETING) {
      const meeting: MeetingDayEntry = {
        id: e.id,
        date: e.date,
        hours,
        type: TimeKind.MEETING,
        startTime: e.startTime,
        endTime: e.endTime,
        breakMinutes: e.breakMinutes ?? 0,
        comment: e.comment ?? '',
      }

      result.push(meeting)
    }

    if (
      e.type === TimeKind.SICK ||
      e.type === TimeKind.VAB ||
      e.type === TimeKind.VACATION ||
      e.type === TimeKind.DAY_OFF ||
      e.type === TimeKind.RED_DAY
    ) {
      const absence: AbsenceDayEntry = {
        id: e.id,
        date: e.date,
        hours,
        type: e.type,
        comment: e.comment ?? '',
      }

      result.push(absence)
    }
  }

  for (const a of assignments) {
    if (!a.project) continue

    const extra: ExtraDayEntry = {
      id: a.id,
      date: a.date,
      hours: a.hours,
      type: TimeKind.EXTRA,
      projectId: a.project.id,
      project: a.project,
      startTime: a.startTime,
      endTime: a.endTime,
      breakMinutes: a.breakMinutes ?? 0,
      comment: a.comment ?? '',
    }

    result.push(extra)
  }

  return result
}

let loadCounter = 0

async function loadEntries() {
  const id = ++loadCounter

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
      loadVisibleLockStatuses(from, to),
  ])
  
  if (id !== loadCounter) return

  entries.value = mapToDayEntries(timeEntries, assignments)
}

const totals = computed<Totals>(() => {
  return entries.value
    .filter(inCurrentPeriod)
    .reduce<Totals>(
      (acc, e) => {
        const hours = Number(e.hours)

        if (isPaidWork(e)) acc.work += hours

        if (isAbsence(e, TimeKind.SICK)) acc.sick += hours
        if (isAbsence(e, TimeKind.VAB)) acc.vab += hours

        if (isAbsence(e, TimeKind.RED_DAY)) acc.redDay += hours

        if (isAbsence(e, TimeKind.VACATION)) acc.vacation += hours

        return acc
      },
      { work: 0, sick: 0, vab: 0, redDay: 0, vacation: 0 },
    )
})
watch(
  [
    () => auth.isInitialized,
    () => auth.isAuthenticated,
    () => mode.value,
    () => current.value.format('YYYY-MM-DD')
  ],
  async ([ready, isAuth]) => {
    if (!ready || !isAuth) return
    await loadEntries()
  },
  { immediate: true }
)/*
function isWork(e: DayEntry) {
   return e.type === TimeKind.WORK || e.type === TimeKind.EXTRA
}*/

function isPaidWork(e: DayEntry) {
  return e.type === TimeKind.EXTRA || e.type === TimeKind.WORK ||
    e.type === TimeKind.RED_DAY
}

function isAbsence(e: DayEntry, type: TimeKind){ 
  return e.type === type
}

function inCurrentPeriod(e: DayEntry): boolean {
  const date = dayjs(e.date)

  if (mode.value === 'week') {
    return date.isSame(current.value, 'week')
  }

  return date.isBetween(
    current.value.clone().startOf('month'),
    current.value.clone().endOf('month'),
    'day',
    '[]',
  )
}
function sumHours(list: DayEntry[]) {
  return list.reduce((s, e) => s + Number(e.hours), 0)
}

const hoursForDay = (day: Dayjs): number =>
sumHours(entries.value.filter(e => dayjs(e.date).isSame(day, 'day')))

const weekTotal = computed(() => {
  if (mode.value !== 'week') return 0
  const start = current.value.startOf('isoWeek')

  return entries.value
    //.filter(isWork)
    .filter(isCountedInTotal)
    .filter(e =>
      dayjs(e.date).isSame(start, 'week')
    )
    .reduce((sum, e) => sum + Number(e.hours), 0)
})

const monthTotal = computed(() => {
  if (mode.value !== 'month') return 0
  return entries.value
    //.filter(isWork)
    .filter(isCountedInTotal)
    .filter(inCurrentPeriod)
    .reduce((sum, e) => sum + Number(e.hours), 0)
})

async function openDay(day: Dayjs) {
  selectedDay.value = day
  selectedDayEntries.value = entries.value.filter(
    e => dayjs(e.date).isSame(day, 'day'),
  )
  await lockStore.loadStatus(day.format('YYYY-MM-DD'))
  view.value = selectedDayEntries.value.length
    ? 'dayEntries'
    : 'tabs'
}

function editFromList(entry: DayEntry) {
  editEntry.value = entry
  suggestionsStore.clear()
  view.value = 'modal'
}

function selectSuggestion(s: TimeSuggestion) {
  suggestionsStore.select(s)
  editEntry.value = null
  view.value = 'modal'
}

function cancelModal() {
  view.value = selectedDayEntries.value.length
    ? 'dayEntries'
    : 'tabs'
}

async function onSaved() {
  navigating.value = true

  editEntry.value = null
  suggestionsStore.clear()
  
  await loadEntries()
  view.value = 'calendar'
  
  navigating.value = false
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
  suggestionsStore.clear()
  view.value = 'tabs'
}

async function reloadCalendar () {
  navigating.value = true
  editEntry.value = null

  await loadEntries()
  view.value = 'calendar'
  navigating.value = false
}

function isWeekLocked(day: Dayjs): boolean {
  const date = day.format('YYYY-MM-DD')
  return lockStore.getStatusForDate(date)?.locked ?? false
}
async function toggleWeekLock() {
  const date = current.value.format('YYYY-MM-DD')

  if (lockStore.status?.locked) {
    await lockStore.unlock(date)
  } else {
    await lockStore.close(date)
  }
}
</script>

<template>
  <template v-if="view === 'calendar'">
    <SegmentedTabs v-model="mode" />

    <Toolbar
      :title="mode === 'week'
        ? t('calendar.weekLabel', { num: current.week() }) //`Week ${current.week()}`
        : current.format('MMMM YYYY')"
      :locked="lockStore.status?.locked ?? true"
      :is-admin="isAdmin" 
      :show-lock-controls="mode === 'week'" 
      @prev="prev"
      @next="next"
      @toggle-lock="toggleWeekLock"
    />

    <WeekView
      v-if="mode === 'week'"
      :current="current"
      :hours-for-day="hoursForDay"
      :is-week-locked="isWeekLocked"
      @select-day="openDay"
    />

    <MonthView
      v-else
      :current="current"
      :hours-for-day="hoursForDay"
      :is-week-locked="isWeekLocked"
      @select-day="openDay"
    />

    <div class="totals">
      <div 
        v-if="(mode === 'week' ? weekTotal : monthTotal) > 0"
        class="total-item main"
      >
        <span>{{ mode === 'week' ? t('calendar.weekTotal') : t('calendar.monthTotal') }}</span>
        <strong>{{ mode === 'week' ? weekTotal : monthTotal }} h</strong>
      </div>

      <div
        v-if="totals.sick > 0" 
        class="total-item"
      >
        <span>{{ t('stats.sick') }}</span>
        <strong>{{ totals.sick }} h</strong>
      </div>

      <div 
        v-if="totals.vab > 0"
        class="total-item"
      >
        <span>{{ t('stats.vab') }}</span>
        <strong>{{ totals.vab }} h</strong>
      </div>

      <div 
        v-if="totals.vacation > 0"
        class="total-item"
      >
        <span>{{ t('stats.vacation') }}</span>
        <strong>{{ totals.vacation }} h</strong>
      </div>

      <div 
        v-if="totals.work > 0"
        class="total-item"
      >
        <span>{{ t('stats.work') }}</span>
        <strong>{{ totals.work }} h</strong>
      </div>
    </div>
  </template>

  <DayEntryPage
    v-if="view === 'dayEntries' && selectedDay"
    :date="selectedDay.format('YYYY-MM-DD')"
    :entries="selectedDayEntries"
    :locked="selectedDayLocked"
    @edit="editFromList"
    @add="addWork"
    @back="view = 'calendar'"
  />

  <RegisterTimePage
    v-else-if="view === 'tabs' && selectedDay"
    :day="selectedDay"
    @select-suggestion="selectSuggestion"
    @close="view = 'calendar'"
  />

  <TimeFormModal
    v-else-if="view === 'modal' && selectedDay"
    :date="selectedDay.format('YYYY-MM-DD')"
    :preset="suggestionsStore.selected"
    :entry="editEntry"
    :day-entries="selectedDayEntries"
    :external-loading="navigating"
    @cancel="cancelModal"
    @deleted="reloadCalendar"
    @saved="onSaved"
  />
</template>