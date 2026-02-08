import { ref, computed, watch } from 'vue'
import type { Ref } from 'vue'
import type { DayEntry } from '../../types/DayEntry.type'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'
import { useTimeEntryImages } from './useTimeEntryImages'
import { EntryState } from '../../types/EntryState'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import type { TimeBasedForm } from '../../types/TimeBasedForm'

export function useExtraEntryForm(props: {
  date: string
  entry?: DayEntry | null
  projectId: Ref<string | null>
}) {
  const assignmentStore = useProjectAssignmentStore()
  const images = useTimeEntryImages()
  const startRef = ref('08:00')
  const endRef = ref('17:00')
  const breakMinutesRef = ref(30)
  const commentRef = ref('')
  const isEdit = computed(() => props.entry?.kind === EntryState.EXTRA)
  const isSavingRef = ref(false)

  const start = computed({
    get: () => startRef.value,
    set: v => (startRef.value = v),
  })
  const end = computed({
    get: () => endRef.value,
    set: v => (endRef.value = v),
  })
  const breakMinutes = computed({
    get: () => breakMinutesRef.value,
    set: v => (breakMinutesRef.value = v),
  })
  const comment = computed({
    get: () => commentRef.value,
    set: v => (commentRef.value = v),
  })
  const isSaving = computed(() => isSavingRef.value)

  const calculatedHours = computed(() => {
      const minutes = calculateWorkedMinutes(
        normalizeTime(startRef.value),
        normalizeTime(endRef.value),
        breakMinutesRef.value,
      )
      return (minutes / 60).toFixed(2)
    })
  function normalizeTime(t: string) {
  return t.slice(0, 5)
  }
  watch(
    () => props.entry,
    e => {
      if (!e || e.kind !== EntryState.EXTRA) return

      startRef.value = normalizeTime(e.startTime ?? '08:00')
      endRef.value = normalizeTime(e.endTime ?? '17:00')
      breakMinutesRef.value = e.breakMinutes ?? 30
      commentRef.value = e.comment ?? ''
    },
    { immediate: true },
  )

async function save(): Promise<DayEntry | undefined> {
  if (!props.projectId.value) {
    alert('Project missing')
    return
  }

  isSavingRef.value = true
  try {
    let saved

    if (isEdit.value) {
      saved = await assignmentStore.update(props.entry!.id, {
        startTime: normalizeTime(startRef.value),
        endTime: normalizeTime(endRef.value),
        breakMinutes: breakMinutesRef.value,
        comment: commentRef.value,
      })
    } else {
      saved = await assignmentStore.create({
        projectId: props.projectId.value,
        date: props.date,
        startTime: normalizeTime(startRef.value),
        endTime: normalizeTime(endRef.value),
        breakMinutes: breakMinutesRef.value,
        comment: commentRef.value,
      })
    }

    if (!saved.project) {
      throw new Error('Saved assignment has no project')
    }

    try {
      await images.upload(props.projectId.value)
    } catch (e) {
      console.error('[Images] upload failed', e)
    }

    return {
      kind: EntryState.EXTRA,
      id: saved.id,
      date: saved.date,
      hours: saved.hours,
      startTime: normalizeTime(saved.startTime),
      endTime: normalizeTime(saved.endTime),
      breakMinutes: saved.breakMinutes ?? 0,
      comment: saved.comment ?? '',
      project: saved.project,
      projectId: saved.project.id,
    }
  } finally {
    isSavingRef.value = false
  }
}
  async function remove() {
    if (!isEdit.value) return
    if (!confirm('Delete extra work?')) return
    await assignmentStore.remove(props.entry!.id)
  }

  return {
    start,
    end,
    breakMinutes,
    comment,
    images,
    isEdit,
    isSaving,
    calculatedHours,
    save,
    remove,
  } satisfies TimeBasedForm
}