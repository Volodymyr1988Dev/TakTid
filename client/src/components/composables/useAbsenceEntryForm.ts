import { ref, computed } from 'vue'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import type { AbsenceDayEntry } from '../../types/DayEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
import { EntryState } from '../../types/EntryState'

export function useAbsenceEntryForm(props: {
  date: string
  entry?: AbsenceDayEntry | null
}) {
  const store = useTimeEntryStore()

  const kindRef = ref<TimeKind>(
    props.entry?.type ?? TimeKind.SICK
  )
  const commentRef = ref(props.entry?.comment ?? '')
  const isSavingRef = ref(false)

     const kind = computed({
    get: () => kindRef.value,
    set: v => (kindRef.value = v),
  })

  const comment = computed({
    get: () => commentRef.value,
    set: v => (commentRef.value = v),
  })

  const isSaving = computed(() => isSavingRef.value)

  const isEdit = computed(() => !!props.entry)
  const isActive = computed(() => true)
  async function save(): Promise<AbsenceDayEntry> {
    isSavingRef.value = true
    try {
        const payload ={
            date: props.date,
            type: kindRef.value,
            comment: commentRef.value
        }
      const saved = props.entry
        ? await store.update(props.entry.id, payload)
        : await store.add(payload)

      return {
        kind: EntryState.ABSENCE,
        id: saved.id,
        date: saved.date,
        hours: Number(saved.hours),
        type: saved.type, //as 'SICK' | 'VAB' | 'VACATION',
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
    kind,
    comment,
    isSaving,
    isEdit,
    isActive,
    save,
    remove,
  }
}