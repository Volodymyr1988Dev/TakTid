import { ref, computed,watch } from 'vue'
import type { Ref } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { calculateWorkedMinutes } from '../helpers/time'
import type { WorkDayEntry } from '../../types/DayEntry.type'
import type { TimeEntryUpdatePayload } from '../../types/TimeEntryUpdatePayload.type'
import { useTimeEntryImages } from './useTimeEntryImages'
import { TimeKind } from '../../types/timeKind.enum'
import type { WorkForm } from '../../types/Form.types'
import type { DayEntry } from '../../types/DayEntry.type'
import { useDefaultTime } from './useDefaultTime'
import { normalizeBreakMinutes } from '../helpers/time'
import { useToast } from './useToast'

export function useWorkEntryForm(props: {
  date: string
  entry?: WorkDayEntry | null
  projectId: Ref <string | null>
  dayEntries?: DayEntry[]
}) {
  const store = useTimeEntryStore()
  const images = useTimeEntryImages()
  const startRef = ref('08:00')
  const endRef = ref('17:00')
  const breakMinutesRef = ref(30)
  const commentRef = ref('')
  const isSavingRef = ref(false)

  const isEdit = computed(() => !!props.entry)

  const toast = useToast()

  const { defaultTime } = useDefaultTime({
    dayEntries: props.dayEntries,
    durationMinutes: 90,
  })

  function normalizeTime(t: string) {
    return t.slice(0, 5)
  }

  const calculatedHours = computed<number>(() => {
    const minutes = calculateWorkedMinutes(
      normalizeTime(startRef.value),
      normalizeTime(endRef.value),
      normalizeBreakMinutes(breakMinutesRef.value),
    )
    return Number((minutes / 60).toFixed(2))
  })
watch(
  [() => props.entry, defaultTime],
  ([entry]) => {
    if (entry) {
      startRef.value = normalizeTime(entry.startTime)
      endRef.value = normalizeTime(entry.endTime)
      breakMinutesRef.value = entry.breakMinutes ?? 30
      commentRef.value = entry.comment ?? ''
      return
    }

    startRef.value = defaultTime.value.start
    endRef.value = defaultTime.value.end
    breakMinutesRef.value = 30
    commentRef.value = ''
  },
  { immediate: true },
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

    let breakMin: number

    try {
      breakMin = normalizeBreakMinutes(breakMinutesRef.value)
    } catch {
      toast.error('Break must be a valid number')
      isSavingRef.value = false
      throw new Error('Invalid break')
    }


    try {
      const payload: TimeEntryUpdatePayload = {
        startTime: normalizeTime(startRef.value),
        endTime: normalizeTime(endRef.value),
        breakMinutes: breakMin,//normalizeBreakMinutes(breakMinutesRef.value),
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
        type: TimeKind.WORK,
        startTime: normalizeTime(saved.startTime),
        endTime: normalizeTime(saved.endTime),
        breakMinutes: normalizeBreakMinutes(saved.breakMinutes),
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