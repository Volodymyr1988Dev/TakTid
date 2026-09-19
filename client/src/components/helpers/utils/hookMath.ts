export function round05(n: number): number { return Math.round(n * 2) / 2}

export function round02(n: number): number { return Math.round((n + Number.EPSILON) * 100) / 100 }

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
  return left >= 6 && right >= 6 && left <= 25 && right <= 25
}

export function isValidSingleFixedEdge( fixedEdge: number, otherEdge: number, ): boolean { 
  return ( fixedEdge >= 0 && fixedEdge <= 25 && otherEdge >= 0 && otherEdge <= 25 ) 
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

    //if (!isValidEdge(left, right)) continue
    if (fixedEdge != null) { 
      if (!isValidSingleFixedEdge(fixedEdge, right)) 
        { continue } 
    } else 
      { if (!isValidEdge(left, right)) { continue } 
    }

    const hooks = segments + 1

    const score =
      hooks * 10 +                  
      //Math.abs(left - 15) * 2 +    
      //Math.abs(left - right)  
      Math.abs( (fixedEdge != null ? right : left) - 15, ) * 2 + 
      Math.abs(left - right)     

    if (score < bestScore) {
      bestScore = score
      bestSpacing = spacing
    }
  }

  return bestSpacing
}

export function findSpacingWithTwoFixedEdges( 
  L: number, leftEdge: number, rightEdge: number, 
  ): {
   spacing: number 
   segments: number
  } | null { 
    if ( 
      !Number.isFinite(L) || !Number.isFinite(leftEdge) || !Number.isFinite(rightEdge) 
    ) { 
      return null 
    } if (leftEdge < 0 || rightEdge < 0) { 
      return null 
    } 
    const availableLength = L - leftEdge - rightEdge 
    if (availableLength <= 0) { 
      return null 
    }
    const segments = Math.ceil( availableLength / 60, ) 
    if (segments < 1) {
       return null 
      } 
      const spacing = availableLength / segments 
      return { spacing: round02(spacing), segments, } 
  }