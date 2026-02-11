import { computed, type Ref, type ComputedRef } from 'vue'
import type {
  EntryMode,
  WorkForm,
  ExtraForm,
  AbsenceForm,
  ActiveForm,
} from '../../types/Form.types'
import { TimeKind } from '../../types/timeKind.enum'

//export type ActiveForm = WorkForm | ExtraForm | AbsenceForm

export function useEntryFormSelector(
  mode: Ref<EntryMode>,
  forms: {
    work: WorkForm
    extra: ExtraForm
    absence: AbsenceForm
  },
): ComputedRef<ActiveForm> {
  return computed(() => {
    switch (mode.value) {
      case TimeKind.WORK:
        return forms.work
      case TimeKind.EXTRA:
        return forms.extra
      case 'ABSENCE':
      default:
        return forms.absence
    }
  })
}