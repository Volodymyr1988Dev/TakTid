import type { ValueTransformer } from 'typeorm'

export const decimalTransformer: ValueTransformer = {
  to(value: number | null): number | null {
    return value
  },

  from(value: string | null): number | null {
    if (value === null) {
      return null
    }

    const numberValue = Number(value)

    return Number.isFinite(numberValue)
      ? numberValue
      : null
  },
}