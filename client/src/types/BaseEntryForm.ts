/*import type { DayEntry } from './DayEntry.type'
import type { EntryState } from './EntryState'

export interface BaseEntryForm {
  kind: EntryState

  comment: string
  isSaving: boolean
  isEdit: boolean

  save(): Promise<DayEntry | null>
  remove(): Promise<void>
}*/ 
import type { Ref, ComputedRef } from 'vue'
import type { DayEntry } from './DayEntry.type'
import type { EntryState } from './EntryState'

export interface BaseEntryForm {
  kind?: EntryState

  comment: Ref<string>
  isSaving: Ref<boolean>
  isEdit: ComputedRef<boolean>

  save(): Promise<DayEntry | null>
  remove(): Promise<void>
}