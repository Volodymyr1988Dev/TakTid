/*export const EntryState = {
  WORK: 'WORK',
  EXTRA: 'EXTRA',
  ABSENCE: 'ABSENCE',
} as const

export type EntryState = typeof EntryState[keyof typeof EntryState]*/
import { TimeKind } from "./timeKind.enum"

export function isAbsenceKind(kind: TimeKind) {
  return (
    kind === 'SICK' ||
    kind === 'VAB' ||
    kind === 'VACATION'
  )
}