export const MINUTES_IN_DAY = 24 * 60

export function normalizeTime(time?: string | null): string | undefined {
  return time ? time.slice(0, 5) : '00:00'
}

export function toMinutes(t: string): number {
 if (!t) return 0

  const normalized = t.slice(0, 5)
  const [h = '0', m = '0'] = normalized.split(':')

  const hours = parseInt(h, 10)
  const minutes = parseInt(m, 10)

  if (Number.isNaN(hours) || Number.isNaN(minutes)) return 0

  return hours * 60 + minutes
}

export function calculateWorkedMinutes(
  start: string,
  end: string,
  breakMinutes = 0,
): number {
  let startMin = toMinutes(start)
  let endMin = toMinutes(end)

  if (endMin <= startMin) {
    endMin += MINUTES_IN_DAY
  }
  return Math.max(0, endMin - startMin - breakMinutes)
}

export function toTimeString(minutes: number): string {
  const safe = Math.max(0, minutes)

  const h = Math.floor(safe / 60)
  const m = safe % 60

  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
}

export function normalizeBreakMinutes(value: unknown): number {
  if (value === null || value === undefined) return 0

  const str = String(value).trim()

  if (str === '') return 0

  const num = Number(str)

  if (Number.isNaN(num)) {
    throw new Error('Break must be a number')
  }

  return Math.max(0, num)
}

export function addMinutes(time: string, minutes: number): string {
  const [h, m] = time.split(':').map(Number)
  const total = Number(h) * 60 + Number(m) + minutes
  const newH = Math.floor(total / 60)
  const newM = total % 60

  return `${String(newH).padStart(2, '0')}:${String(newM).padStart(2, '0')}`
}