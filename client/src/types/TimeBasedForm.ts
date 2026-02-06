import type { Ref, ComputedRef } from 'vue'
import type { DayEntry } from './DayEntry.type'

export interface TimeBasedForm {
  start: Ref<string>
  end: Ref<string>
  breakMinutes: Ref<number>
  calculatedHours: ComputedRef<string>

  images: {
    previews: Ref<string[]>
    onSelect: (e: Event) => void
    //removeImage: (id: string) => Promise<void>
  }

  comment: Ref<string>
  isEdit: ComputedRef<boolean>
  isSaving: Ref<boolean>
  //save: () => Promise<DayEntry | null>
  save: () => Promise<DayEntry | undefined>
  remove: () => Promise<void>
} /*
import type { BaseEntryForm } from './BaseEntryForm'

export interface TimeBasedForm extends BaseEntryForm {
  start: string
  end: string
  breakMinutes: number

  calculatedHours: string

  images: {
    previews: string[]
    onSelect(e: Event): void
  }
}*/