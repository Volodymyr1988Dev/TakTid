import { round05 } from './hookMath'

export function calculateIdealSpacing(L: number, ideal: number) {
  const exact = L / ideal

  const lowerSegments = Math.floor(exact)
  const upperSegments = Math.ceil(exact)

  const lowerSpacing = L / lowerSegments
  const upperSpacing = L / upperSegments

  return {
    ideal,
    exact,

    lower: {
      spacing: round05(lowerSpacing),
      segments: lowerSegments,
      diff: round05(L - lowerSegments * ideal)
    },

    upper: {
      spacing: round05(upperSpacing),
      segments: upperSegments,
      diff: round05(L - upperSegments * ideal)
    }
  }
}