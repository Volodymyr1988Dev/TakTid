import api from '../api/axios'
import type { AdminUserMonthStats } from '../types/AdminUserMonthStats.type'

export async function getMonthStats(
  year: number,
  month: number,
): Promise<AdminUserMonthStats[]> {

  const { data } = await api.get<AdminUserMonthStats[]>(
    '/stats/month',
    { params: { year, month } },
  )

  return data
}

export async function getUserMonthDetails(
  userId: string,
  year: number,
  month: number,
) {
  const { data } = await api.get(
    `/stats/month/${userId}`,
    { params: { year, month } },
  );

  return data;
}