import { ref, computed,watch } from 'vue'
import type { Ref } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
//import { useProjectStore } from '../../stores/project.store'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import type { WorkDayEntry } from '../../types/DayEntry.type'
import type { TimeEntryUpdatePayload } from '../../types/TimeEntryUpdatePayload.type'
import { EntryState } from '../../types/EntryState'
import { useTimeEntryImages } from './useTimeEntryImages'
import { TimeKind } from '../../types/timeKind.enum'
import type { TimeBasedForm } from '../../types/TimeBasedForm'

export function useWorkEntryForm(props: {
  date: string
  entry?: WorkDayEntry | null
  //projectId: { value: string | null }
  projectId: Ref <string | null>
}) {
  const store = useTimeEntryStore()
  const images = useTimeEntryImages()
  //const projectStore = useProjectStore()

  //const projectId = computed(() => projectStore.projectId)
  const start = ref('08:00')
  const end = ref('17:00')
  const breakMinutes = ref(30)
  const comment = ref('')
  const isSaving = ref(false)

  const isEdit = computed(() => !!props.entry)

  function normalizeTime(t: string) {
    return t.slice(0, 5)
  }

  const calculatedHours = computed(() => {
    const minutes = calculateWorkedMinutes(
      normalizeTime(start.value),
      normalizeTime(end.value),
      breakMinutes.value,
    )
    return (minutes / 60).toFixed(2)
  })

  watch(
    props.projectId,
    v => {
        console.log('[WorkForm] projectId:', v)
    },
    { immediate: true }
    )
watch(
  () => props.entry,
  e => {
    if (!e) return

    start.value = normalizeTime(e.startTime ?? '08:00')
    end.value = normalizeTime(e.endTime ?? '17:00')
    breakMinutes.value = e.breakMinutes ?? 30
    comment.value = e.comment ?? ''
  },
  { immediate: true }
)

  async function save(): Promise<WorkDayEntry> {
    //const pid = props.projectId.value
    //const projectId = props.projectId.value ?? undefined
    if (!props.projectId.value) {
        throw new Error('WORK requires projectId')
    }
    //if (!pid) throw new Error('WORK requires projectId')
    //isSaving.value = true
    try {
      const payload: TimeEntryUpdatePayload = {
        startTime: normalizeTime(start.value),
        endTime: normalizeTime(end.value),
        breakMinutes: breakMinutes.value,
        comment: comment.value,
        projectId: props.projectId.value, //:props.projectId.value,
      }

      const saved = props.entry
        ? await store.update(props.entry.id, payload)
        : await store.add({
        date: props.date,
        type: TimeKind.WORK,
        ...payload,
        })

      await images.upload(props.projectId.value /*props.projectId.value*/)

      return {
        kind: EntryState.WORK,
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: saved.type,
        startTime: normalizeTime(saved.startTime),
        endTime: normalizeTime(saved.endTime),
        breakMinutes: saved.breakMinutes,
        projectId: saved.projectId,
        comment: saved.comment ?? '',
      }
    } finally {
      isSaving.value = false
    }
  }

  async function remove() {
    if (!props.entry) return
    await store.remove(props.entry.id)
  }

  return {
    start,
    end,
    breakMinutes,
    comment,
    calculatedHours,
    images,
    isEdit,
    isSaving,
    save,
    remove,
  } satisfies TimeBasedForm
}