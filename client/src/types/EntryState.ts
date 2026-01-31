export const EntryState = {
  WORK: 'WORK',
  EXTRA: 'EXTRA',
  ABSENCE: 'ABSENCE',
} as const

export type EntryState = typeof EntryState[keyof typeof EntryState]