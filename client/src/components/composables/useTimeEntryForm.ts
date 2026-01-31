import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../types/timeKind.enum'
import type { DayEntry } from '../../types/DayEntry.type'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { TimeEntryUpdatePayload } from '../../types/TimeEntryUpdatePayload.type'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'
import { useTimeEntryImages } from './useTimeEntryImages'
import { useProjectStore } from '../../stores/project.store'
import { EntryState } from '../../types/EntryState';

export function useTimeEntryForm(props: {
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}) {
  const timeStore = useTimeEntryStore()
  const assignmentStore = useProjectAssignmentStore()
  const images = useTimeEntryImages()
  const projectStore = useProjectStore()

  /* STATE */
  const state = computed<EntryState>(() => {
    if (isAbsence.value) return EntryState.ABSENCE
    if (mode.value === 'EXTRA') return EntryState.EXTRA
  return EntryState.WORK
  })
  const project = computed(() =>
  projectId.value ? projectStore.getById(projectId.value) : null,
  )
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

  watch(kind, k => {
    if (
      k === TimeKind.SICK ||
      k === TimeKind.VAB ||
      k === TimeKind.VACATION
    ) {
      mode.value = 'WORK'
    }
    })

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

      //if (e.kind === 'WORK') {
      if (e.kind === EntryState.WORK) {
        kind.value = e.type
        start.value = e.startTime.slice(0, 5)
        end.value = e.endTime.slice(0, 5)
        breakMinutes.value = e.breakMinutes
        projectId.value = e.projectId ?? null
        mode.value = 'WORK'
      }

      //if (e.kind === 'EXTRA') {
      if (e.kind === EntryState.EXTRA) {
        start.value = e.startTime.slice(0, 5)
        end.value = e.endTime.slice(0, 5)
        breakMinutes.value = e.breakMinutes
        projectId.value = e.projectId
        mode.value = 'EXTRA'
      }

      //if (e.kind === 'ABSENCE') {
      if (e.kind === EntryState.ABSENCE) {
        kind.value = e.type
      }

      isHydrating.value = false
    },
    { immediate: true },
  )

  watch(
  () => props.preset,
  preset => {
    if (!preset) return

    isHydrating.value = true
    isDirty.value = false

    kind.value = preset.type
    breakMinutes.value = preset.breakMinutes ?? 60

    if (preset.projectId) {
      projectId.value = preset.projectId
      mode.value = 'WORK'
    }

    isHydrating.value = false
  },
  { immediate: true },
)

  watch([start, end, breakMinutes, kind], () => {
    if (!isHydrating.value) isDirty.value = true
  })

  /* SAVE */
  async function save(): Promise<DayEntry | undefined> {
    //let saved
    if (isSaving.value) return
    isSaving.value = true

    try {
      /* ABSENCE */
      //if (isAbsence.value) {
      if (state.value === EntryState.ABSENCE) {
        const payload = {
          date: props.date,
          type: kind.value,
          //type: state.value,
          startTime: '08:00',
          endTime: '17:00',
          breakMinutes: 60,
          comment: comment.value,
        }

        const saved = props.entry
          ? await timeStore.update(props.entry.id, payload)
          : await timeStore.add(payload)

        return {
          //kind: 'ABSENCE' as const,
          kind: EntryState.ABSENCE,
          id: saved.id,
          date: saved.date,
          hours: Number(saved.hours),
          type: saved.type,
          comment: saved.comment ?? '',
        }
      }

      /* EXTRA */
      //if (mode.value === 'EXTRA') {
      if (state.value === EntryState.EXTRA) {
        if (!projectId.value) {
          alert('Project is required')
          return
        }

        //const saved = props.entry?.kind === 'EXTRA'
        const saved = props.entry?.kind === EntryState.EXTRA
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
        return {
          //kind: 'EXTRA' as const,
          kind: EntryState.EXTRA,
          id: saved.id,
          date: saved.date,
          hours: saved.hours,
          projectId: saved.project.id,
          project: saved.project,
          startTime: saved.startTime,
          endTime: saved.endTime,
          breakMinutes: saved.breakMinutes ?? 0,
          comment: saved.comment ?? '',
        }
      }

      /* WORK */
      const payload: TimeEntryUpdatePayload = {
        startTime: start.value,
        endTime: end.value,
        breakMinutes: normalizedBreakMinutes.value,
        comment: comment.value,
        ...(projectId.value && { projectId: projectId.value }),
      }

      //const saved = props.entry?.kind === 'WORK'
      const saved = props.entry?.kind === EntryState.WORK
        ? await timeStore.update(props.entry.id, payload)
        : await timeStore.add({
            date: props.date,
            type: kind.value,
            //type: state.value,
            ...payload,
          })

      await images.upload(projectId.value ?? undefined)
      return {
        //kind: 'WORK' as const,
        kind: EntryState.WORK,
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: saved.type,
        startTime: saved.startTime,
        endTime: saved.endTime,
        breakMinutes: saved.breakMinutes,
        projectId: saved.projectId,
        project: project.value ?? undefined,
        comment: saved.comment ?? '',
      }
    } finally {
      isSaving.value = false
    }
  }

  async function remove() {
    if (!props.entry) return
    if (!confirm('Delete this entry?')) return

    if (
      props.entry.kind === EntryState.WORK &&
      !props.entry.projectId
    ) {
      await timeStore.remove(props.entry.id)
      return
    }
    //props.entry.kind === 'EXTRA'
    props.entry.kind === EntryState.EXTRA
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
    project,
    images,

    calculatedHours,
    isEdit,
    isAbsence,
    isSaving,

    save,
    remove,
  }
}