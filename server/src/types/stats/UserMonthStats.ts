import { User } from '../../entities';

export interface UserMonthStats {
  user: User;
  workHours: number;
  extraHours: number;
  meetingHours: number;
  sickDays: Set<string>;
  vabDays: Set<string>;
  vacationDays: Set<string>;
}
