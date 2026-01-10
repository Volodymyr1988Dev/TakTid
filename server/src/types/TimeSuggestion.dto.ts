import { timeKind } from './enums/enum';

export class TimeSuggestionDto {
  type: timeKind;
  title: string;
  projectId?: string;
  breakMinutes: number;
}
