
export interface TimePeriodStatus {
  id: string
  periodType: 'WEEK'
  periodStart: string
  periodEnd: string
  locked: boolean
  manuallyLocked: boolean
  automaticallyLocked: boolean
  temporarilyUnlocked: boolean
  unlockedUntil: string | null
  lockedAt: string | null
  lockedByUserId: string | null
  unlockedByUserId: string | null
  reason: string | null
}
