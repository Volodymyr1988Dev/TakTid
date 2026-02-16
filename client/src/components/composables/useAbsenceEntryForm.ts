import { ref, computed, watch } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import type { AbsenceDayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
import type { AbsenceForm,AbsenceKind } from '../../types/Form.types'
import type { DayEntry } from '../../types/DayEntry.type'
import { isFullDayCovered } from '../pages/components/helpers/isFullDayCovered'
//import { getLastWorkEnd } from '../pages/components/helpers/getLastWorkEnd'
import { calculateMissingWorkTime } from '../pages/components/helpers/calculateMissingWorkTime'
import { addMinutes, normalizeTime } from '../pages/components/helpers/time'

export function useAbsenceEntryForm(props: {
  date: string
  entry?: AbsenceDayEntry | null
  dayEntries?: DayEntry[]
}) {
  const store = useTimeEntryStore()
  const kindRef = ref<AbsenceKind>(
    props.entry?.type ?? TimeKind.SICK
  )
  const commentRef = ref(props.entry?.comment ?? '')
  const isSavingRef = ref(false)
  const errorRef = ref<string | null>(null)
  //const error = computed(() => errorRef.value)
  const comment = computed({
    get: () => commentRef.value,
    set: v => (commentRef.value = v),
  })

  const isSaving = computed(() => isSavingRef.value)

  const isEdit = computed(() => !!props.entry)
  
  watch(
  () => props.entry,
  entry => {
    if (!entry) return

    kindRef.value = entry.type
    commentRef.value = entry.comment ?? ''
  },
  { immediate: true },
)
  
 const absenceType = computed({
  get: () => kindRef.value,
  set: (v: AbsenceKind) => (kindRef.value = v),
})
/*
const hasAbsence = props.dayEntries?.some(
  (e) =>
    e.type === TimeKind.SICK ||
    e.type === TimeKind.VAB ||
    e.type === TimeKind.VACATION ||
    e.type === TimeKind.DAY_OFF,
)*/
  async function save(): Promise<AbsenceDayEntry> {
    isSavingRef.value = true
    errorRef.value = null
    const existingAbsences =
    props.dayEntries?.filter(
      (e) =>
        e.type === TimeKind.SICK ||
        e.type === TimeKind.VAB ||
        e.type === TimeKind.VACATION ||
        e.type === TimeKind.DAY_OFF,
    ) ?? []
    if (!props.entry && isFullDayCovered(props.dayEntries)) {
        throw new Error(
          'Unavailable to create absence, because you have working time all day'
        )
    }
    //const lastEnd = getLastWorkEnd(props.dayEntries)
    const { missingMinutes, lastEnd } =
    calculateMissingWorkTime(props.dayEntries)
  if (!props.entry && existingAbsences.length > 0) {
    //throw new Error('Only one absence entry is allowed per day')
    errorRef.value =
        'Two absence entries are not allowed in one day'
      return Promise.reject()
  }
  if (!props.entry && missingMinutes <= 0) {
    //throw new Error('Day already contains 8 hours of work')
    errorRef.value =
        'Day already contains 8 working hours'
      return Promise.reject()
  }

  const start = normalizeTime(lastEnd) ?? '09:00'
  const end = normalizeTime(addMinutes(start, missingMinutes))
    try {
      const payload =
        kindRef.value === TimeKind.DAY_OFF
          ? {
              type: TimeKind.DAY_OFF,
              comment: commentRef.value,
              startTime: '08:00',
              endTime: '08:01',
              breakMinutes: 0,
            }
          : {
              type: kindRef.value,
              comment: commentRef.value,
              //startTime: lastEnd ?? '08:00',
              startTime: start ?? '09:00',
              //endTime: '17:00',
              endTime: end ?? '17:00',
              breakMinutes: 0,
            }
      const saved = props.entry
        ? await store.update(props.entry.id, payload)
        : await store.add({...payload, date: props.date})

      return {
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: saved.type as AbsenceKind,
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
    mode: 'ABSENCE',
    absenceType,
    comment,
    isSaving,
    isEdit,
    error: errorRef,
    save,
    remove,
  } satisfies AbsenceForm
}