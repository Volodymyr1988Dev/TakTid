import api from './axios'
import type { TimeSuggestion } from '../types/Suggestion.type'

export async function getSuggestions(): Promise<TimeSuggestion[]> {
  const { data } = await api.get<TimeSuggestion[]>('/time-entries/suggestions')
  return data
}