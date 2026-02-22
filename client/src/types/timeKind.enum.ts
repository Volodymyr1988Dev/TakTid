export const TimeKind = {
  WORK: 'WORK',
  EXTRA: 'EXTRA',

  SICK: 'SICK',
  VAB: 'VAB',
  VACATION: 'VACATION',
  //MEETING: 'MEETING',
  DAY_OFF: 'DAY_OFF',
  RED_DAY: 'RED_DAY',
} as const

export type TimeKind = typeof TimeKind[keyof typeof TimeKind]

export type WorkKind =
  | typeof TimeKind.WORK
  | typeof TimeKind.EXTRA

export type AbsenceKind =
  | typeof TimeKind.SICK
  | typeof TimeKind.VAB
  | typeof TimeKind.VACATION
  | typeof TimeKind.DAY_OFF
  | typeof TimeKind.RED_DAY