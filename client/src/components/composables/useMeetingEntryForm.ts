import { ref, computed, watch } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { useTimeRangeForm } from './useTimeRangeForm'
import { TimeKind } from '../../types/timeKind.enum'
import type { MeetingForm } from '../../types/Form.types'
import type { MeetingDayEntry } from '../../types/DayEntry.type'
import { normalizeBreakMinutes } from '../helpers/time'
import { useToast } from './useToast'

export function useMeetingEntryForm(props: {
  date: string
  entry?: MeetingDayEntry | null
}) {
  const store = useTimeEntryStore()
  const toast = useToast()
  
  const {
    startRef,
    endRef,
    breakMinutesRef,
    calculatedHours,
    normalize,
  } = useTimeRangeForm()

  const commentRef = ref('')
  const isSavingRef = ref(false)

  const isEdit = computed(() => !!props.entry)

  watch(
    () => props.entry,
    entry => {
      if (!entry) return
      startRef.value = normalize(entry.startTime)
      endRef.value = normalize(entry.endTime)
      breakMinutesRef.value = entry.breakMinutes ?? 0
      commentRef.value = entry.comment ?? ''
    },
    { immediate: true }
  )

  async function save(): Promise<MeetingDayEntry> {
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
      const payload = {
        date: props.date,
        type: TimeKind.MEETING,
        startTime: normalize(startRef.value),
        endTime: normalize(endRef.value),
        breakMinutes: breakMin, //breakMinutesRef.value,
        comment: commentRef.value,
      }

      const saved = props.entry
        ? await store.update(props.entry.id, payload)
        : await store.add(payload)

      return {
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: TimeKind.MEETING,
        startTime: normalize(saved.startTime),
        endTime: normalize(saved.endTime),
        breakMinutes: normalizeBreakMinutes(saved.breakMinutes),
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
    mode: 'MEETING',
    start: computed({
      get: () => startRef.value,
      set: v => (startRef.value = v),
    }),
    end: computed({
      get: () => endRef.value,
      set: v => (endRef.value = v),
    }),
    form: {
      breakMinutes: computed({
        get: () => breakMinutesRef.value,
        set: v => (breakMinutesRef.value = v),
      }),
    },
    comment: computed({
      get: () => commentRef.value,
      set: v => (commentRef.value = v),
    }),
    calculatedHours,
    isEdit,
    isSaving: computed(() => isSavingRef.value),
    save,
    remove,
  } satisfies MeetingForm
}