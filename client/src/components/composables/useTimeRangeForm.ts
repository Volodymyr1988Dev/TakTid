import { ref, computed } from 'vue'
import { calculateWorkedMinutes } from '../helpers/time'

export function useTimeRangeForm(defaultStart = '08:00', defaultEnd = '17:00') {
  const startRef = ref(defaultStart)
  const endRef = ref(defaultEnd)
  const breakMinutesRef = ref(30)

  function normalize(t: string) {
    return t.slice(0, 5)
  }

  const calculatedHours = computed(() => {
    const minutes = calculateWorkedMinutes(
      normalize(startRef.value),
      normalize(endRef.value),
      breakMinutesRef.value
    )
    return Number((minutes / 60).toFixed(2))
  })

  return {
    startRef,
    endRef,
    breakMinutesRef,
    calculatedHours,
    normalize,
  }
}