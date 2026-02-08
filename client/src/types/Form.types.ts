import type { TimeBasedForm } from './TimeBasedForm'

export type EntryMode = 'WORK' | 'EXTRA' | 'ABSENCE'

export type WorkForm = TimeBasedForm & {
  kind: 'WORK'
}

export type ExtraForm = TimeBasedForm & {
  kind: 'EXTRA'
}

export type AbsenceForm = {
  kind: 'ABSENCE'
  comment: { value: string }
  isEdit: { value: boolean }
  isSaving: { value: boolean }
  save: () => Promise<any>
  remove: () => Promise<void>
}

export type ActiveForm =
  | { mode: 'WORK'; form: WorkForm }
  | { mode: 'EXTRA'; form: ExtraForm }
  | { mode: 'ABSENCE'; form: AbsenceForm }