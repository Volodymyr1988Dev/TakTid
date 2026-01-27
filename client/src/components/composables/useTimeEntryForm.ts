import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../types/timeKind.enum'
import type { DayEntry } from '../../types/DayEntry.type'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { TimeEntryUpdatePayload } from '../../types/TimeEntryUpdatePayload.type'
//import type { TimeEntryFormKind } from '../../types/TimeEntryFormKind'
//import { normalizeTime } from '../pages/components/helpers/helpers'
import { calculateWorkedMinutes } from '../../components/pages/components/helpers/time'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'
import { useProjectImageStore } from '../../stores/projectImage.store'

import {
  isWorkEntry,
  isExtraEntry,
  isAbsenceEntry,
} from '../../types/DayEntry.type'

export function useTimeEntryForm(props: {
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}) {
  /* ================= STORES ================= */
  const timeStore = useTimeEntryStore()
  const assignmentStore = useProjectAssignmentStore()
  const imageStore = useProjectImageStore()

  /* ================= STATE ================= */
  const start = ref('08:00')
  const end = ref('17:00')
  const breakMinutes = ref(60)
  const kind = ref<TimeKind>(TimeKind.WORK)
  const comment = ref('')
  const projectId = ref<string | undefined>()
  const images = ref<File[]>([])

  /* ================= UI ================= */
  //const errors = ref<Record<string, string>>({})
  const isSaving = ref(false)
  const isHydrating = ref(false)
  const isDirty = ref(false)

  const isEdit = computed(() => !!props.entry)

  const isAbsence = computed(
    () =>
      kind.value === TimeKind.SICK ||
      kind.value === TimeKind.VAB ||
      kind.value === TimeKind.VACATION,
  )

  const isExtra = computed(() => kind.value === TimeKind.EXTRA)

  const normalizedBreakMinutes = computed(() => {
    const v = Number(breakMinutes.value)
    return Number.isFinite(v) && v >= 0 ? v : 0
  })

    function normalizeTime(
    time?: string | null,
    fallback = '00:00',
    ): string {
    if (!time) return fallback

    return time.slice(0, 5)
    }

  function requireProjectId(): string {
  if (!projectId.value) {
    throw new Error('Project is required for this entry type')
  }
  return projectId.value
}

  /* ================= PREFILL ENTRY ================= */
  watch(
    () => props.entry,
    async e => {
      if (!e) return

      isHydrating.value = true
      isDirty.value = false

      if (isAbsenceEntry(e)) {
        kind.value = e.type
      } else if (isExtraEntry(e)) {
        kind.value = TimeKind.EXTRA
      } else {
        kind.value = e.type
      }

      comment.value = e.comment ?? ''

      if (isWorkEntry(e) || isExtraEntry(e)) {
        start.value = normalizeTime(e.startTime)
        end.value = normalizeTime(e.endTime)
        breakMinutes.value = e.breakMinutes
        projectId.value = e.projectId
      }

      if (projectId.value) {
        await imageStore.load(projectId.value)
      }

      isHydrating.value = false
    },
    { immediate: true },
  )

  /* ================= PREFILL PRESET ================= */
  watch(
    () => props.preset,
    p => {
      if (!p || props.entry) return
      kind.value = p.type
      breakMinutes.value = p.breakMinutes ?? 60
      projectId.value = p.projectId
    },
    { immediate: true },
  )

  /* ================= DIRTY ================= */
  watch([start, end, breakMinutes], () => {
    if (!isHydrating.value) isDirty.value = true
  })

  /* ================= HOURS ================= */
  const calculatedHours = computed(() => {
    if (props.entry && !isDirty.value) {
      return props.entry.hours.toFixed(2)
    }

    const minutes = calculateWorkedMinutes(
      start.value,
      end.value,
      normalizedBreakMinutes.value,
    )

    return minutes > 0 ? (minutes / 60).toFixed(2) : '0.00'
  })

  /* ================= SAVE ================= */
  async function save() {
    if (isSaving.value) return
    isSaving.value = true

    try {
      if (isAbsence.value) {
        const payload = {
          date: props.date,
          type: kind.value,
          startTime: '08:00',
          endTime: '17:00',
          breakMinutes: 60,
          comment: comment.value,
        }

        props.entry
          ? await timeStore.update(props.entry.id, payload)
          : await timeStore.add(payload)

        return
      }
      const pid = requireProjectId()

      const payload: TimeEntryUpdatePayload = {
        startTime: start.value,
        endTime: end.value,
        breakMinutes: normalizedBreakMinutes.value,
        comment: comment.value,
        projectId: pid,
      }

      if (isExtra.value) {
        props.entry
          ? await assignmentStore.update(props.entry.id, payload)
          : await assignmentStore.create({
              date: props.date,
              projectId: pid,
              ...payload,
            })
      } else {
        props.entry
          ? await timeStore.update(props.entry.id, payload)
          : await timeStore.add({
              date: props.date,
              type: TimeKind.WORK,
              ...payload,
            })
      }

      if (images.value.length && projectId.value) {
        await imageStore.upload(projectId.value, images.value)
        images.value = []
      }
    } finally {
      isSaving.value = false
    }
  }

  /* ================= DELETE ================= */
  async function remove() {
    if (!props.entry) return
    if (!confirm('Delete this entry?')) return

    if (props.entry.kind === 'EXTRA') {
      await assignmentStore.remove(props.entry.id)
    } else {
      await timeStore.remove(props.entry.id)
    }
  }

  return {
    start,
    end,
    breakMinutes,
    kind,
    comment,
    projectId,

    imageStore,
    calculatedHours,

    isEdit,
    isAbsence,
    isSaving,

    save,
    remove,
  }
}