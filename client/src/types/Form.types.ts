import type { Ref, ComputedRef } from 'vue'
import type { DayEntry } from './DayEntry.type'
import { TimeKind } from './timeKind.enum'
//import type { TimeBasedForm } from './TimeBasedForm'

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
export type EntryMode = 'WORK' | 'EXTRA' | 'ABSENCE'

export interface WorkForm extends TimeBaseForm {
  mode: 'WORK'
  //type: typeof TimeKind.WORK
}

export interface ExtraForm extends TimeBaseForm {
  mode: 'EXTRA'
  //type: typeof TimeKind.EXTRA
}

export interface AbsenceForm extends BaseForm {
  mode: 'ABSENCE'
  //type: 'ABSENCE'
  absenceType: Ref<AbsenceKind> //Ref<string>
  //comment: { value: string }
  //isEdit: { value: boolean }
  //isSaving: { value: boolean }
  //save: () => Promise<any>
  //remove: () => Promise<void>
}

//export type ActiveForm = WorkForm | ExtraForm | AbsenceForm
export type TimeForm = WorkForm | ExtraForm
export type ActiveForm = TimeForm | AbsenceForm