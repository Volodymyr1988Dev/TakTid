import { ref, computed, watch } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import type { AbsenceDayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
//import { EntryState } from '../../types/EntryState'
import type { AbsenceForm,AbsenceKind } from '../../types/Form.types'

export function useAbsenceEntryForm(props: {
  date: string
  entry?: AbsenceDayEntry | null
}) {
  const store = useTimeEntryStore()

  //const kindRef = ref<TimeKind>(
  const kindRef = ref<AbsenceKind>(
    props.entry?.type ?? TimeKind.SICK
  )
  const commentRef = ref(props.entry?.comment ?? '')
  const isSavingRef = ref(false)
/*
     const kind = computed({
    get: () => kindRef.value,
    set: v => (kindRef.value = v),
  })
*/
  const comment = computed({
    get: () => commentRef.value,
    set: v => (commentRef.value = v),
  })

  const isSaving = computed(() => isSavingRef.value)

  const isEdit = computed(() => !!props.entry)
  //const isActive = computed(() => true)
  
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
  set: v => (kindRef.value = v),
})
  async function save(): Promise<AbsenceDayEntry> {
    isSavingRef.value = true
    try {
        const payload ={
            //date: props.date,
            type: kindRef.value,
            comment: commentRef.value,
            startTime: '08:00',
            endTime: '17:00',
            breakMinutes: 60,
        }
      const saved = props.entry
        ? await store.update(props.entry.id, payload)
        : await store.add({...payload, date: props.date})

      return {
        //kind: EntryState.ABSENCE,
        //kind: 'ABSENCE',
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: saved.type as AbsenceKind, //| typeof TimeKind.SICK | typeof TimeKind.VAB | typeof TimeKind.VACATION,
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
    //kind: 'ABSENCE',
    //type: 'ABSENCE',
    mode: 'ABSENCE',
    absenceType,
    comment,
    isSaving,
    isEdit,
    //isActive,
    save,
    remove,
  } satisfies AbsenceForm
}