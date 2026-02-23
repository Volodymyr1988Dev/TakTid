import { TimeKind } from '../../types/timeKind.enum'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import { 
  isWorkSuggestion,
  isInternalSuggestion,
  isAbsenceSuggestion
} from '../../types/suggestion.guard'

export function cardClass(s: TimeSuggestion) {
  if (isWorkSuggestion(s)) return 'card-work'
  if (isInternalSuggestion(s)) return 'card-meeting'

  if (isAbsenceSuggestion(s)) {
    switch (s.type) {
      case TimeKind.SICK:
        return 'card-sick'
      case TimeKind.VACATION:
        return 'card-vacation'
      case TimeKind.VAB:
        return 'card-vab'
      case TimeKind.DAY_OFF:
        return 'card-dayoff'
      case TimeKind.RED_DAY:
        return 'card-red'
    }
  }

  return ''
}