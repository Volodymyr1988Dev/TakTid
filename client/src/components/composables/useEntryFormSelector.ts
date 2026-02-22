import { computed, type Ref, type ComputedRef } from 'vue'
import type {
  EntryMode,
  WorkForm,
  ExtraForm,
  AbsenceForm,
  ActiveForm,
  MeetingForm,
} from '../../types/Form.types'
import { TimeKind } from '../../types/timeKind.enum'

export function useEntryFormSelector(
  mode: Ref<EntryMode>,
  forms: {
    work: WorkForm
    extra: ExtraForm
    meeting: MeetingForm
    absence: AbsenceForm
  },
): ComputedRef<ActiveForm> {
  return computed(() => {
    switch (mode.value) {
      case TimeKind.WORK:
        return forms.work
      case TimeKind.EXTRA:
        return forms.extra
      case TimeKind.MEETING:
        return forms.meeting  
      case 'ABSENCE':
      default:
        return forms.absence
    }
  })
}