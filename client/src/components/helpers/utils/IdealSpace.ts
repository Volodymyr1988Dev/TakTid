//import { round05 } from './hookMath'

export function calculateIdealSpacing(L: number, ideal: number) {
  const exact = L / ideal

  const lowerSegments = Math.floor(exact)
  const upperSegments = Math.ceil(exact)

  const roundedSegments = Math.round(exact)
  const perfectLength = roundedSegments * ideal
  //const lowerDiff = L - lowerSegments * ideal
  //const upperDiff = L - upperSegments * ideal

  const lowerDiff = lowerSegments * ideal - L
  const upperDiff = upperSegments * ideal - L

  const lowerSpacing = L / lowerSegments
  const upperSpacing = L / upperSegments
  //const missing = L - perfectLength
  const missing = perfectLength - L 
  return {
    ideal,
    exact,
    missing,
    lower: {
      spacing: lowerSpacing,
      segments: lowerSegments,
      diff: lowerDiff,
      missing: lowerDiff
    },

    upper: {
      spacing: upperSpacing,
      segments: upperSegments,
      diff: upperDiff,
      missing: upperDiff
    }
  }
}