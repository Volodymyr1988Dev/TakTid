import { round05 } from './hookMath'

export function calculateIdealSpacing(L: number, ideal: number) {
  const exact = L / ideal

  const lowerSegments = Math.floor(exact)
  const upperSegments = Math.ceil(exact)

  const roundedSegments = Math.round(exact)
  const perfectLength = roundedSegments * ideal
  const lowerDiff = L - lowerSegments * ideal
  const upperDiff = L - upperSegments * ideal

  const lowerSpacing = L / lowerSegments
  const upperSpacing = L / upperSegments
  const missing = round05(perfectLength - L)

  return {
    ideal,
    exact,
    missing,
    lower: {
      spacing: round05(lowerSpacing),
      segments: lowerSegments,
      //diff: round05(L - lowerSegments * ideal)
      diff: round05(lowerDiff),
      missing: round05(lowerDiff)
    },

    upper: {
      spacing: round05(upperSpacing),
      segments: upperSegments,
      //diff: round05(L - upperSegments * ideal)
      diff: round05(upperDiff),
      missing: round05(upperDiff)
    }
  }
}