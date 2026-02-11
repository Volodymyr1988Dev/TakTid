export const TimeKind = {
  WORK: 'WORK',
  EXTRA: 'EXTRA',
  
  SICK: 'SICK',
  VAB: 'VAB',
  VACATION: 'VACATION',
  //MEETING: 'MEETING',
} as const

export type TimeKind = typeof TimeKind[keyof typeof TimeKind]