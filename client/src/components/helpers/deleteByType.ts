import { TimeKind } from '../../types/timeKind.enum'
import { useTimeEntryStore } from '../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../stores/projectAssignment.store'

type TimeEntryStore = ReturnType<typeof useTimeEntryStore>
type AssignmentStore = ReturnType<typeof useProjectAssignmentStore>

export async function deleteByType(
  type: TimeKind,
  id: string,
  deps: {
    timeEntryStore: TimeEntryStore
    assignmentStore: AssignmentStore
  },
) {
  if (!id) return

  if (type === TimeKind.WORK) {
    await deps.timeEntryStore.remove(id)
    return
  }

  if (type === TimeKind.EXTRA) {
    await deps.assignmentStore.remove(id)
    return
  }

  if (
    type === TimeKind.SICK ||
    type === TimeKind.VAB ||
    type === TimeKind.VACATION
  ) {
    await deps.timeEntryStore.remove(id)
  }
}