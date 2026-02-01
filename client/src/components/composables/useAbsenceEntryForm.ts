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

  const kind = ref<TimeKind>(props.entry?.type ?? TimeKind.SICK)
  const comment = ref(props.entry?.comment ?? '')
  const isSaving = ref(false)

  const isEdit = computed(() => !!props.entry)
  const isActive = computed(() => true)

  async function save(): Promise<AbsenceDayEntry> {
    isSaving.value = true
    try {
        const payload ={
            date: props.date,
            type: kind.value,
            comment: comment.value
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
      isSaving.value = false
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