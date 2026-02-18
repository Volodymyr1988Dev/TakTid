import Holidays from 'date-holidays'
import type { Dayjs } from 'dayjs'

const hd = new Holidays('SE')

export const isHoliday = (day: Dayjs): boolean => {
  return !!hd.isHoliday(day.toDate())
}