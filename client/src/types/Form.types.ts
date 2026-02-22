import type { Ref, ComputedRef } from 'vue'
import type { DayEntry } from './DayEntry.type'
import { TimeKind } from './timeKind.enum'

interface BaseForm {
  isSaving: Ref<boolean>
  isEdit: Ref<boolean>
  comment: Ref<string>

  save(): Promise<DayEntry | null>
  remove(): Promise<void>
}

interface TimeBaseForm extends BaseForm {
  start: Ref<string>
  end: Ref<string>

  form: {
    breakMinutes: Ref<number>
  }

  calculatedHours: ComputedRef<number>

  images?: {
    previews: Ref<string[]>
    onSelect(e: Event): void
    removeAt(index: number): void
  }
}
export type AbsenceKind =
  | typeof TimeKind.SICK
  | typeof TimeKind.VAB
  | typeof TimeKind.VACATION
  | typeof TimeKind.DAY_OFF
  | typeof TimeKind.RED_DAY
export type EntryMode = 'WORK' | 'EXTRA' | 'ABSENCE'

export interface WorkForm extends TimeBaseForm {
  mode: 'WORK'
}

export interface ExtraForm extends TimeBaseForm {
  mode: 'EXTRA'
}

export interface AbsenceForm extends BaseForm {
  mode: 'ABSENCE'
  absenceType: Ref<AbsenceKind>
  error: Ref<string | null>
}

export type TimeForm = WorkForm | ExtraForm
export type ActiveForm = TimeForm | AbsenceForm