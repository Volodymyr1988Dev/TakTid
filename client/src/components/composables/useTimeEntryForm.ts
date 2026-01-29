import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../types/timeKind.enum'
import type { DayEntry } from '../../types/DayEntry.type'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { TimeEntryUpdatePayload } from '../../types/TimeEntryUpdatePayload.type'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'
import { useTimeEntryImages } from './useTimeEntryImages'

export function useTimeEntryForm(props: {
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}) {
  const timeStore = useTimeEntryStore()
  const assignmentStore = useProjectAssignmentStore()
  const images = useTimeEntryImages()

  /* STATE */
  const start = ref('08:00')
  const end = ref('17:00')
  const breakMinutes = ref(60)
  const kind = ref<TimeKind>(TimeKind.WORK)
  const comment = ref('')
  const projectId = ref<string | null>(null)
  const mode = ref<'WORK' | 'EXTRA'>('WORK')

  const isSaving = ref(false)
  const isHydrating = ref(false)
  const isDirty = ref(false)

  /* COMPUTED */
  const isEdit = computed(() => !!props.entry)

  const isAbsence = computed(() =>
    kind.value === TimeKind.SICK ||
    kind.value === TimeKind.VAB ||
    kind.value === TimeKind.VACATION,
  )

  const normalizedBreakMinutes = computed(() =>
    Math.max(0, Number(breakMinutes.value) || 0),
  )

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

  /* PREFILL FROM ENTRY */
  watch(
    () => props.entry,
    e => {
      isHydrating.value = true
      isDirty.value = false

      if (!e) {
        isHydrating.value = false
        return
      }

      comment.value = e.comment ?? ''

      if (e.kind === 'WORK') {
        kind.value = e.type
        start.value = e.startTime.slice(0, 5)
        end.value = e.endTime.slice(0, 5)
        breakMinutes.value = e.breakMinutes
        projectId.value = e.projectId
        mode.value = 'WORK'
      }

      if (e.kind === 'EXTRA') {
        start.value = e.startTime.slice(0, 5)
        end.value = e.endTime.slice(0, 5)
        breakMinutes.value = e.breakMinutes
        projectId.value = e.projectId
        mode.value = 'EXTRA'
      }

      if (e.kind === 'ABSENCE') {
        kind.value = e.type
      }

      isHydrating.value = false
    },
    { immediate: true },
  )

  watch([start, end, breakMinutes, kind], () => {
    if (!isHydrating.value) isDirty.value = true
  })

  /* SAVE */
  async function save() {
    if (isSaving.value) return
    isSaving.value = true

    try {
      /* ABSENCE */
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

      /* EXTRA */
      if (mode.value === 'EXTRA') {
        if (!projectId.value) {
          alert('Project is required')
          return
        }

        props.entry?.kind === 'EXTRA'
          ? await assignmentStore.update(props.entry.id, {
              comment: comment.value,
              startTime: start.value,
              endTime: end.value,
              breakMinutes: normalizedBreakMinutes.value,
            })
          : await assignmentStore.create({
              projectId: projectId.value,
              date: props.date,
              comment: comment.value,
              startTime: start.value,
              endTime: end.value,
              breakMinutes: normalizedBreakMinutes.value,
            })

        await images.upload(projectId.value)
        return
      }

      /* WORK */
      const payload: TimeEntryUpdatePayload = {
        startTime: start.value,
        endTime: end.value,
        breakMinutes: normalizedBreakMinutes.value,
        comment: comment.value,
        ...(projectId.value && { projectId: projectId.value }),
      }

      props.entry?.kind === 'WORK'
        ? await timeStore.update(props.entry.id, payload)
        : await timeStore.add({
            date: props.date,
            type: kind.value,
            ...payload,
          })

      await images.upload(projectId.value ?? undefined)
    } finally {
      isSaving.value = false
    }
  }

  async function remove() {
    if (!props.entry) return
    if (!confirm('Delete this entry?')) return

    props.entry.kind === 'EXTRA'
      ? await assignmentStore.remove(props.entry.id)
      : await timeStore.remove(props.entry.id)
  }

  return {
    start,
    end,
    breakMinutes,
    kind,
    comment,
    projectId,
    mode,

    images,

    calculatedHours,
    isEdit,
    isAbsence,
    isSaving,

    save,
    remove,
  }
}