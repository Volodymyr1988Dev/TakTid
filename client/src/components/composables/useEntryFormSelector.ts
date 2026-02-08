import { computed, type Ref, type ComputedRef } from 'vue'
import type {
  EntryMode,
  WorkForm,
  ExtraForm,
  AbsenceForm,
  ActiveForm,
} from '../../types/Form.types'

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
      case 'WORK':
        return forms.work
      case 'EXTRA':
        return forms.extra
      case 'ABSENCE':
      default:
        return forms.absence
    }
  })
}