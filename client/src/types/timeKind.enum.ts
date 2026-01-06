export const timeKind = {
  WORK: 'WORK',
  SICK: 'SICK',
  VAB: 'VAB',
  VACATION: 'VACATION',
  EXTRA: 'EXTRA',
  MEETING: 'MEETING',
} as const

export type TimeKind =
  (typeof timeKind)[keyof typeof timeKind]