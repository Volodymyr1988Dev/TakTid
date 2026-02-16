export const MINUTES_IN_DAY = 24 * 60

export function normalizeTime(time?: string | null): string | undefined {
  return time ? time.slice(0, 5) : '00:00'
}

export function toMinutes(t: string): number {
  /*
  const parts = t.split(':')
  if (parts.length !== 2) return 0

  const h = Number(parts[0])
  const m = Number(parts[1])

  if (Number.isNaN(h) || Number.isNaN(m)) return 0

  return h * 60 + m
  */
 if (!t) return 0

  const [h = '0', m = '0'] = t.split(':')
  return parseInt(h, 10) * 60 + parseInt(m, 10)
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
  //const worked = endMin - startMin - breakMinutes
  //return worked > 0 ? worked : 0
  return Math.max(0, endMin - startMin - breakMinutes)
}

export function toTimeString(minutes: number): string {
  const safe = Math.max(0, minutes)

  const h = Math.floor(safe / 60)
  const m = safe % 60

  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
}

export function addMinutes(time: string, minutes: number): string {
  const [h, m] = time.split(':').map(Number)
  const total = Number(h) * 60 + Number(m) + minutes
  const newH = Math.floor(total / 60)
  const newM = total % 60

  return `${String(newH).padStart(2, '0')}:${String(newM).padStart(2, '0')}`
}