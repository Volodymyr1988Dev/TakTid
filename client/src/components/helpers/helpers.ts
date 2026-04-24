import { Dayjs } from 'dayjs'

export function cleanPatch<T extends object>(obj: T): Partial<T> {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([_, v]) => v !== undefined
    )
  ) as Partial<T>
}

export const isWeekend = (day: Dayjs): boolean => {
  const d = day.day()
  return d === 0 || d === 6
}

export function sanitizeNumber(v: any) {
  const n = Number(v)
  return Number.isFinite(n) ? n : null
}