/*
import { TimeKind } from "../../../../types/timeKind.enum"
//import type { DayEntry } from "../../../../types/DayEntry.type"

export function getNextDefaultTime() {
  if (!props.entry && props.dayEntries?.length) {

    const workEntries = props.dayEntries
      .filter(e => e.type === TimeKind.WORK || e.type === TimeKind.EXTRA)
      .sort((a, b) => a.startTime.localeCompare(b.startTime))

    if (!workEntries.length) return

    const last = workEntries[workEntries.length - 1]

    if (!last.endTime) return

    startRef.value = normalizeTime(last.endTime)

    const [h, m] = startRef.value.split(':').map(Number)

    const newDate = new Date()
    newDate.setHours(h)
    newDate.setMinutes(m + 60)

    const newH = String(newDate.getHours()).padStart(2, '0')
    const newM = String(newDate.getMinutes()).padStart(2, '0')

    endRef.value = `${newH}:${newM}`
  }
}*/