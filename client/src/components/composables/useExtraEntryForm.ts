import { ref, computed, watch } from 'vue'
import type { Ref } from 'vue'
import type { DayEntry } from '../../types/DayEntry.type'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'
import { useTimeEntryImages } from './useTimeEntryImages'
import { EntryState } from '../../types/EntryState'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import type { TimeBasedForm } from '../../types/TimeBasedForm'
//import { useProjectStore } from '../../stores/project.store'

export function useExtraEntryForm(props: {
  date: string
  entry?: DayEntry | null
  projectId: Ref<string | null>
}) {
  const assignmentStore = useProjectAssignmentStore()
  const images = useTimeEntryImages()
  //const projectStore = useProjectStore()

/*
  const isExtra = computed(
    (): props.entry is ExtraDayEntry =>
      !!props.entry && props.entry.kind === EntryState.EXTRA,
  )
  const extraForm = useExtraEntryForm({
    date: props.date,
    entry: props.entry,
    projectId,
  })
*/
  //const projectId = computed(() => projectStore.projectId)
  const startRef = ref('08:00')
  const endRef = ref('17:00')
  const breakMinutesRef = ref(30)
  const commentRef = ref('')
  //const projectId = ref<string | null>(null)
  //const projectId = props.projectId
  const isEdit = computed(() => props.entry?.kind === EntryState.EXTRA /*!!props.entry*/)
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
  /** PREFILL */
  watch(
    () => props.entry,
    //projectId,
    e => {
      if (!e || e.kind !== EntryState.EXTRA) return
      //if (e.kind !== EntryState.EXTRA) return

      startRef.value = normalizeTime(e.startTime ?? '08:00')
      endRef.value = normalizeTime(e.endTime ?? '17:00')
      breakMinutesRef.value = e.breakMinutes ?? 30
      commentRef.value = e.comment ?? ''
        
      //projectId.value = e.projectId ?? e.project?.id ?? null
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
        const payload = {
        projectId: props.projectId.value,
        date: props.date,
        startTime: normalizeTime(startRef.value),
        endTime: normalizeTime(endRef.value),
        breakMinutes: breakMinutesRef.value,
        comment: commentRef.value,
      }
      const saved = isEdit.value //props.entry
        ? await assignmentStore.update(props.entry!.id, payload)
        : await assignmentStore.create(payload)

      //await images.upload(props.projectId.value)
      try {
        await images.upload(props.projectId.value)
      } catch (e) {
        console.error('[Images] upload failed', e)
        // НЕ ламаємо save
      }
      return {
        kind: EntryState.EXTRA,
        //type: 'Extra',
        id: saved.id,
        date: saved.date,
        hours: saved.hours,
        startTime: normalizeTime(saved.startTime),
        endTime: normalizeTime(saved.endTime),
        breakMinutes: saved.breakMinutes ?? 0,
        comment: saved.comment ?? '',
        project: saved.project,
        projectId: saved.project.id,
        //...saved,
      }
    } finally {
      isSavingRef.value = false
    }
  }

  async function remove() {
    if (!isEdit.value/*!props.entry*/) return
    if (!confirm('Delete extra work?')) return
    await assignmentStore.remove(props.entry!.id)
  }

  return {
    start,
    end,
    breakMinutes,
    comment,
    //projectId,
    images,//: useTimeEntryImages(),
    isEdit,
    isSaving,
    calculatedHours,
    save,
    remove,
  } satisfies TimeBasedForm
}