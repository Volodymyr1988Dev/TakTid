import { ref, computed,watch } from 'vue'
import type { Ref } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import type { WorkDayEntry } from '../../types/DayEntry.type'
import type { TimeEntryUpdatePayload } from '../../types/TimeEntryUpdatePayload.type'
import { useTimeEntryImages } from './useTimeEntryImages'
import { TimeKind } from '../../types/timeKind.enum'
import type { WorkForm } from '../../types/Form.types'

export function useWorkEntryForm(props: {
  date: string
  entry?: WorkDayEntry | null
  projectId: Ref <string | null>
}) {
  const store = useTimeEntryStore()
  const images = useTimeEntryImages()
  const startRef = ref('08:00')
  const endRef = ref('17:00')
  const breakMinutesRef = ref(30)
  const commentRef = ref('')
  const isSavingRef = ref(false)

  const isEdit = computed(() => !!props.entry)

  function normalizeTime(t: string) {
    return t.slice(0, 5)
  }

  const calculatedHours = computed<number>(() => {
    const minutes = calculateWorkedMinutes(
      normalizeTime(startRef.value),
      normalizeTime(endRef.value),
      breakMinutesRef.value,
    )
    return Number((minutes / 60).toFixed(2))
  })

watch(
  () => props.entry,
  e => {
    if (!e) return

    startRef.value = normalizeTime(e.startTime ?? '08:00')
    endRef.value = normalizeTime(e.endTime ?? '17:00')
    breakMinutesRef.value = e.breakMinutes ?? 30
    commentRef.value = e.comment ?? ''
  },
  { immediate: true }
)

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

  async function save(): Promise<WorkDayEntry> {
    if (!props.projectId.value) {
        throw new Error('WORK requires projectId')
    }
    isSavingRef.value = true
    try {
      const payload: TimeEntryUpdatePayload = {
        startTime: normalizeTime(startRef.value),
        endTime: normalizeTime(endRef.value),
        breakMinutes: breakMinutesRef.value,
        comment: commentRef.value,
        projectId: props.projectId.value,
      }

      const saved = props.entry
        ? await store.update(props.entry.id, payload)
        : await store.add({
        date: props.date,
        type: TimeKind.WORK,
        ...payload,
        })

        try {
          await images.upload(props.projectId.value)
        } catch (e) {
          console.error('[Images] upload failed', e)
        }
      return {
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: TimeKind.WORK,//saved.type,
        startTime: normalizeTime(saved.startTime),
        endTime: normalizeTime(saved.endTime),
        breakMinutes: saved.breakMinutes,
        projectId: saved.projectId,
        comment: saved.comment ?? '',
      }
    } finally {
      isSavingRef.value = false
    }
  }

  async function remove() {
    if (!props.entry) return
    await store.remove(props.entry.id)
  }

  return {
    mode: 'WORK',
    start,
    end,
    //breakMinutes,
    form: {
      breakMinutes
    },
    comment,
    calculatedHours,
    images,
    isEdit,
    isSaving,
    save,
    remove,
  } satisfies WorkForm
}