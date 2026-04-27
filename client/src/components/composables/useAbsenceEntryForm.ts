import { ref, computed, watch } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import type { AbsenceDayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
import type { AbsenceForm,AbsenceKind } from '../../types/Form.types'
import type { DayEntry } from '../../types/DayEntry.type'
import { isFullDayCovered } from '../helpers/isFullDayCovered'
import { calculateMissingWorkTime } from '../helpers/calculateMissingWorkTime'
import { addMinutes, normalizeTime } from '../helpers/time'
import { useI18n } from 'vue-i18n'

export function useAbsenceEntryForm(props: {
  date: string
  entry?: AbsenceDayEntry | null
  dayEntries?: DayEntry[]
}) {
  const store = useTimeEntryStore()
  const { t } = useI18n()
  const kindRef = ref<AbsenceKind>(
    props.entry?.type ?? TimeKind.SICK
  )
  const commentRef = ref(props.entry?.comment ?? '')
  const isSavingRef = ref(false)
  const errorRef = ref<string | null>(null)
  const comment = computed({
    get: () => commentRef.value,
    set: v => (commentRef.value = v),
  })

  const isSaving = computed(() => isSavingRef.value)

  const isEdit = computed(() => !!props.entry)
  
  const isRedDay = computed(() => kindRef.value === TimeKind.RED_DAY)

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
  async function save(): Promise<AbsenceDayEntry> {
    isSavingRef.value = true
    errorRef.value = null
    
    try {
      const allEntries = props.dayEntries ?? []
      const existingAbsences =
      allEntries.filter(
        (e) =>
          e.type === TimeKind.SICK ||
          e.type === TimeKind.VAB ||
          e.type === TimeKind.VACATION ||
          e.type === TimeKind.RED_DAY ||
          e.type === TimeKind.DAY_OFF,
      ) ?? []
      if (!props.entry && !isRedDay.value && isFullDayCovered(allEntries)) {
        errorRef.value =
          t('errors.unavailableAbsence')
        return Promise.reject()
      }
      const { missingMinutes, lastEnd } =
      calculateMissingWorkTime(allEntries)
    if (!props.entry && !isRedDay.value && existingAbsences.length > 0) {
      errorRef.value =
          t('errors.twoAbsences')
        return Promise.reject()
    }
    if (!props.entry && !isRedDay.value && missingMinutes <= 0) {
      errorRef.value =
          t('errors.dayContains8Hours')
        return Promise.reject()
    }

    //const start = normalizeTime(lastEnd) ?? '09:00'
    const start = isRedDay.value ? '09:00' : normalizeTime(lastEnd) ?? '09:00'
    //const end = normalizeTime(addMinutes(start, missingMinutes))
    const end = isRedDay.value ? '17:00' : normalizeTime(addMinutes(start, missingMinutes))
      const payload =
        kindRef.value === TimeKind.DAY_OFF
          ? {
              type: TimeKind.DAY_OFF,
              comment: commentRef.value,
              startTime: '08:00',
              endTime: '08:01',
              breakMinutes: 0,
            }
          : kindRef.value === TimeKind.RED_DAY
          ? {
              type: TimeKind.RED_DAY,
              comment: commentRef.value,
              startTime: '09:00',
              endTime: '17:00',
              breakMinutes: 0,
            }    
          : {
              type: kindRef.value,
              comment: commentRef.value,
              startTime: start ?? '09:00',
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