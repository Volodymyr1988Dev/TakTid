export interface AdminUserMonthDetails {
  user: {
    id: string;
    name: string;
    email: string;
  };

  entries: {
    id: string;
    date: string;
    type: string;
    hours: number;
    startTime?: string;
    endTime?: string;
    breakMinutes?: number;
    comment?: string;
    project?: {
      id: string;
      city: string;
      address: string;
    } | null;
    source: 'TIME_ENTRY' | 'EXTRA_WORK';
  }[];
}
