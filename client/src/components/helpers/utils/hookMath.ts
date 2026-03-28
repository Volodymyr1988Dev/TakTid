export function round05(n: number): number {
  return Math.round(n * 2) / 2
}

export function getSegments(L: number, spacing: number): number {
  return Math.floor(L / spacing)
}

export function getEdges(
  L: number,
  spacing: number,
  segments: number,
  fixedEdge?: number | null
) {
  const used = segments * spacing
  const remainder = L - used

  let left = remainder / 2
  let right = remainder / 2

  if (fixedEdge != null) {
    left = fixedEdge
    right = remainder - left
  }

  return { left, right }
}

export function isValidEdge(left: number, right: number): boolean {
  return left >= 6 && right >= 6 && left <= 20 && right <= 20
}

export function findBestSpacingAuto(
  L: number,
  fixedEdge?: number | null
): number | null {
  let bestSpacing: number | null = null
  let bestScore = Infinity

  for (let s = 60; s >= 10; s -= 0.5) {
    const spacing = round05(s)

    const segments = getSegments(L, spacing)
    if (segments < 1) continue

    const { left, right } = getEdges(L, spacing, segments, fixedEdge)

    if (!isValidEdge(left, right)) continue

    const hooks = segments + 1

    const score =
      hooks * 10 +                  
      Math.abs(left - 15) * 2 +    
      Math.abs(left - right)       

    if (score < bestScore) {
      bestScore = score
      bestSpacing = spacing
    }
  }

  return bestSpacing
}