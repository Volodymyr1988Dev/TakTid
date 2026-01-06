export const TimeKind = {
  WORK: 'WORK',
  SICK: 'SICK',
  VAB: 'VAB',
  VACATION: 'VACATION',
  EXTRA: 'EXTRA',
  MEETING: 'MEETING',
} as const

export type TimeKind = typeof TimeKind[keyof typeof TimeKind]