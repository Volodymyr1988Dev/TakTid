export function toMinutes(t: string): number {
  const parts = t.split(':')
  if (parts.length !== 2) return 0

  const h = Number(parts[0])
  const m = Number(parts[1])

  if (Number.isNaN(h) || Number.isNaN(m)) return 0

  return h * 60 + m
}

export function calculateWorkedMinutes(
  start: string,
  end: string,
  breakMinutes = 0,
): number {
  let startMin = toMinutes(start)
  let endMin = toMinutes(end)

  if (endMin <= startMin) {
    endMin += 24 * 60
  }
  //const worked = endMin - startMin - breakMinutes
  //return worked > 0 ? worked : 0
  return Math.max(0, endMin - startMin - breakMinutes)
}