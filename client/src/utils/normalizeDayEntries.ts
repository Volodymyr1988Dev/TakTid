//import type { TimeEntry } from '../types/TimeEntry.type'
//import type { ProjectAssignment } from '../types/ProjectAssignment.type'
//import type { DayEntry } from '../types/DayEntry.type'
//import { TimeKind } from '../types/timeKind.enum'
//import type { Project } from '../types/Project.dto'
//import { computed } from 'vue'
//import type { ExtraDayEntry } from '../types/DayEntry.type'
/* ---------- helpers ---------- */
/*
function calcHours(
  start?: string,
  end?: string,
  breakMinutes = 0,
): number {
  if (!start || !end) return 0

  const [sh, sm] = start.split(':').map(Number)
  const [eh, em] = end.split(':').map(Number)

  let startMin = sh * 60 + sm
  let endMin = eh * 60 + em

  if (endMin <= startMin) {
    endMin += 24 * 60
  }

  const worked = endMin - startMin - breakMinutes
  return worked > 0 ? +(worked / 60).toFixed(2) : 0
}


export function normalizeTimeEntry(
  e: TimeEntry,
): DayEntry {
  return {
    ...e,
    kind: 'WORK',
    hours: e.hours,
  }
}

export function normalizeProjectAssignment(
  a: ProjectAssignment,
): DayEntry {
  return {
    id: a.id,
    date: a.date,
    kind: 'EXTRA',
    hours: a.hours ?? calcHours(
      a.startTime ?? undefined,
      a.endTime ?? undefined,
      a.breakMinutes ?? 0,
    ),
    comment: a.comment ?? undefined,
    startTime: a.startTime ?? undefined,
    endTime: a.endTime ?? undefined,
    breakMinutes: a.breakMinutes ?? undefined,
    projectId: a.project.id,
    project: {
      id: a.project.id,
      city: a.project.city,
      address: a.project.address,
    },
  }
}

export function normalizeDayEntries(
  time: TimeEntry[],
  extra: ProjectAssignment[],
): DayEntry[] {
  return [
    ...time.map(normalizeTimeEntry),
    ...extra.map(normalizeProjectAssignment),
  ].sort((a, b) => a.date.localeCompare(b.date))
}

export const normalizedBreakMinutes = computed(() => {
  const value = Number(breakMinutes.value)
  return Number.isFinite(value) && value >= 0 ? value : 0
})
  */