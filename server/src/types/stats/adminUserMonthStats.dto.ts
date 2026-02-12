export interface AdminUserMonthStats {
  user: {
    id: string;
    email: string;
    name?: string;
  };

  workHours: number;
  extraHours: number;

  sickHours: number;
  sickDays: number;
  vabHours: number;
  vabDays: number;
  vacationHours: number;
  vacationDays: number;

  totalHours: number;
}
