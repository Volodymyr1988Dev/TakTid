import { computed, type Ref } from 'vue'
import type {
  ActiveForm,
  EntryMode,
  WorkForm,
  ExtraForm,
  AbsenceForm,
} from '../../types/Form.types'

export function useEntryFormSelector(
  mode: Ref<EntryMode>,
  forms: {
    work: WorkForm
    extra: ExtraForm
    absence: AbsenceForm
  },
) {
  return computed<ActiveForm>(() => {
    if (mode.value === 'WORK') {
      return { mode: 'WORK', form: forms.work }
    }

    if (mode.value === 'EXTRA') {
      return { mode: 'EXTRA', form: forms.extra }
    }

    // fallback — ABSENCE
    return { mode: 'ABSENCE', form: forms.absence }
  })
}