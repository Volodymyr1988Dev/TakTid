import { ref, computed, watch } from 'vue'
import type { Ref } from 'vue'
import type { DayEntry } from '../../types/DayEntry.type'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'
import { useTimeEntryImages } from './useTimeEntryImages'
import { EntryState } from '../../types/EntryState'
import { calculateWorkedMinutes } from '../pages/components/helpers/time'
import type { TimeBasedForm } from '../../types/TimeBasedForm'

export function useExtraEntryForm(props: {
  date: string
  entry?: DayEntry | null
  projectId: Ref<string | null>
}) {
  const assignmentStore = useProjectAssignmentStore()
  const images = useTimeEntryImages()
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
  const start = ref('08:00')
  const end = ref('17:00')
  const breakMinutes = ref(0)
  const comment = ref('')
  //const projectId = ref<string | null>(null)
  const projectId = props.projectId
  const isEdit = computed(() => props.entry?.kind === EntryState.EXTRA /*!!props.entry*/)
  const isSaving = ref(false)

  const calculatedHours = computed(() => {
      const minutes = calculateWorkedMinutes(
        start.value,
        end.value,
        breakMinutes.value,
      )
      return (minutes / 60).toFixed(2)
    })
  /** PREFILL */
  watch(
    () => props.entry,
    e => {
      if (!e || e.kind !== EntryState.EXTRA) return
      //if (e.kind !== EntryState.EXTRA) return

      start.value = e.startTime
      end.value = e.endTime
      breakMinutes.value = e.breakMinutes ?? 0
      comment.value = e.comment ?? ''

      projectId.value = e.projectId ?? e.project?.id ?? null
    },
    { immediate: true },
  )

  async function save(): Promise<DayEntry | undefined> {
    if (!projectId.value) {
      alert('Project missing')
      return
    }

    //isSaving.value = true
    try {
      const saved = isEdit.value //props.entry
        ? await assignmentStore.update(props.entry!.id, {
            comment: comment.value,
            startTime: start.value,
            endTime: end.value,
            breakMinutes: breakMinutes.value,
          })
        : await assignmentStore.create({
            projectId: projectId.value,
            date: props.date,
            comment: comment.value,
            startTime: start.value,
            endTime: end.value,
            breakMinutes: breakMinutes.value,
          })

      await images.upload(projectId.value)

      return {
        kind: EntryState.EXTRA,
        id: saved.id,
        date: saved.date,
        hours: saved.hours,
        startTime: saved.startTime,
        endTime: saved.endTime,
        breakMinutes: saved.breakMinutes ?? 0,
        comment: saved.comment ?? '',
        project: saved.project,
        projectId: saved.project.id,
      }
    } finally {
      isSaving.value = false
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