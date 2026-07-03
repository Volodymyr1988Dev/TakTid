<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
//import { useToastStore } from '../stores/toast.store'
import { useToast } from '../components/composables/useToast'
import { useStatsStore } from '../stores/stats.store'
import ExcelJS from 'exceljs'
import { saveAs } from 'file-saver'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import type { UserDetailsEntry } from '../types/UserDetailsEntry'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

interface UserInfo {
  id: string
  name?: string
  email?: string
}

interface UserStats {
  user: UserInfo
  workHours: number
  extraHours: number
  sickHours: number
  vacationHours: number
  vabHours: number
  redDayHours: number
  totalHours: number
  meetingHours: number
}


const stats = useStatsStore()
const expanded = ref<Record<string, boolean>>({})
const detailsOpen = ref<Record<string, boolean>>({})
const selectedDay = ref<Record<string, number | null>>({})

//const toast = useToastStore()
const toast = useToast()
const isLoading = ref(false)
let debounceTimer: ReturnType<typeof setTimeout> | null = null

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

watch([year, month], () => {
  if (debounceTimer) clearTimeout(debounceTimer)

  debounceTimer = setTimeout(() => {load()}, 600)
})

function getKey (userId: string) {
  return `${userId}-${year.value}-${month.value}`
}

async function ensureDetails(userId: string) {
  const key = getKey(userId)
  if (!stats.details[key]) {
    await stats.loadUserDetails(userId, year.value, month.value)
  }
  const detail = stats.details[key]

  if (!detail) {
    throw new Error(t('stats.errors.loadUserDetails'))
  }

  return detail
}
function getEntries(userId: string): UserDetailsEntry[] {
  return stats.details[getKey(userId)]?.entries || []
}

function getUserName(user: UserInfo) {
  return user.name || user.email || 'Unknown User'
}

function buildCalendar(userId: string) {
  const days = new Date(year.value, month.value, 0).getDate()
  const entries = getEntries(userId)
  const map: Record<number, UserDetailsEntry[]> = {}
  entries
  .forEach((e: UserDetailsEntry ) => {
    const d = new Date(e.date).getDate()
    if (!map[d]) map[d] = []
    map[d].push(e)
  })

  return Array.from({ length: days }, (_, i) => ({
    day: i + 1,
    entries: map[i + 1] || []
  }))
}

function typeClass(type: string) {
  switch (type) {
    case 'WORK': return 'badge work'
    case 'EXTRA_WORK': return 'badge extra'
    case 'MEETING': return 'badge meeting'
    case 'SICK': return 'badge sick'
    case 'VACATION': return 'badge vacation'
    case 'VAB': return 'badge vab'
    case 'RED_DAY': return 'badge red-day'
    default: return 'badge'
  }
}

function typeLabel(type: string) {
  if (type === 'EXTRA_WORK') return 'Extra Work'
  return type
}
async function toggleDetails(userId: string) {
  detailsOpen.value[userId] = !detailsOpen.value[userId]

  if (detailsOpen.value[userId]) {
    await ensureDetails(userId)
  }
}
function summary(u: UserStats) {
  return {
    paid: u.workHours + u.extraHours,
    paidWithRedDay: u.workHours + u.extraHours + u.redDayHours, //(u.redDayHours || 0),
    work: u.workHours,
    extra: u.extraHours,
    meeting: u.meetingHours,
    sick: u.sickHours,
    vacation: u.vacationHours,
    vab: u.vabHours, // || 0,
    redDay: u.redDayHours,// || 0,
    total: u.totalHours
  }
}

async function load() {
  if (!validateInputs()) return

  try {
    isLoading.value = true
    selectedDay.value = {}
    expanded.value = {}
    detailsOpen.value = {}
    await stats.loadMonth(year.value, month.value)
  } catch (e) {
    toast.error(t('stats.errors.load'))
    console.error(e)
  } finally {
    isLoading.value = false
  }
}

async function ensureAllDetailsLoaded() {
  await Promise.all(
    stats.users.map(user =>
      ensureDetails(user.user.id)
    )
  )
}

async function exportAllExcel() {
  await ensureAllDetailsLoaded()
  const workbook = new ExcelJS.Workbook()

  for (const user of stats.users) {
    const sheet = workbook.addWorksheet(getUserName(user.user))
    const sum = summary(user)

    sheet.addRow(['Monthly Report'])
    sheet.addRow([`User: ${getUserName(user.user)}`])
    sheet.addRow([`Period: ${month.value}/${year.value}`])
    sheet.addRow([])

    sheet.addRow(['Work', sum.work + sum.extra])
    sheet.addRow(['Work + Red Day', sum.work + sum.extra + sum.redDay])
    sheet.addRow(['Meeting', sum.meeting])
    sheet.addRow(['Sick', sum.sick])
    sheet.addRow(['Vacation', sum.vacation])
    sheet.addRow(['VAB', sum.vab])
    sheet.addRow(['Red Day', sum.redDay])
    sheet.addRow(['Total + Red Days', sum.total + sum.redDay])
    sheet.addRow(['Total', sum.total])
    sheet.addRow([])

    sheet.addRow(['Date','Type','Hours'/*,'Project','Comment'*/])
    const entries = getEntries(user.user.id)
    entries
    .forEach((e: UserDetailsEntry/*: Entry*/) => {
      sheet.addRow([
        e.date,
        e.type,
        e.hours,
        //e.project ? `${e.project.city} - ${e.project.address}` : '',
        //e.comment || ''
      ])
    })
  }

  const buffer = await workbook.xlsx.writeBuffer()
  saveAs(new Blob([buffer]), `All_Users_${month.value}_${year.value}.xlsx`)
}

function validateInputs(): boolean {
  if (!Number.isInteger(year.value) || year.value < 2025) {
    toast.error(t('stats.errors.year'))
    return false
  }

  if (!Number.isInteger(month.value)) {
    toast.error(t('stats.errors.monthValid'))
    return false
  }

  if (month.value < 1 || month.value > 12) {
    toast.error(t('stats.errors.monthRange'))
    return false
  }

  return true
}

async function exportExcelSingle(user: UserStats) {

  const workbook = new ExcelJS.Workbook()
  const sheet = workbook.addWorksheet(getUserName(user.user))
  const sum = summary(user)

  sheet.addRow([`Monthly Report`])
  sheet.addRow([`User: ${getUserName(user.user)}`])
  sheet.addRow([`Period: ${month.value}/${year.value}`])
  sheet.addRow([])

  sheet.addRow(['Work', sum.work + sum.extra])
  sheet.addRow(['Work + Red Days', sum.work + sum.extra + sum.redDay])
  sheet.addRow(['Meeting', sum.meeting])
  sheet.addRow(['Sick', sum.sick])
  sheet.addRow(['Vacation', sum.vacation])
  sheet.addRow(['VAB', sum.vab])
  sheet.addRow(['Red Day', sum.redDay])
  sheet.addRow(['Total', sum.total])
  sheet.addRow(['Total+ Red Days', sum.total + sum.redDay])
  sheet.addRow([])

  sheet.addRow(['Date','Type','Hours'/*,'Project','Comment'*/])
  const entries = getEntries(user.user.id)
  entries
  .forEach((e: UserDetailsEntry) => {
    sheet.addRow([
      e.date,
      typeLabel(e.type),
      e.hours,
      //e.project ? `${e.project.city} - ${e.project.address}` : '',
      //e.comment || ''
    ])
  })

  sheet.columns.forEach(column => {
    let max = 12
    column.eachCell?.({ includeEmpty: true }, cell => {
      const len = String(cell.value ?? '').length
      if (len > max) max = len
    })
    column.width = max + 2
  })

  const buffer = await workbook.xlsx.writeBuffer()
  saveAs(new Blob([buffer]), `${getUserName(user.user)}_${month.value}_${year.value}.xlsx`)
}

async function exportPDFSingle(user: UserStats) {
  const entries = getEntries(user.user.id)
  const doc = new jsPDF()
  const sum = summary(user)

  doc.setFontSize(16)
  doc.text('Monthly Financial Report', 14, 18)

  doc.setFontSize(11)
  doc.text(`User: ${getUserName(user.user)}`, 14, 28)
  doc.text(`Period: ${month.value}/${year.value}`, 14, 35)

  autoTable(doc, {
    startY: 42,
    head: [['Category', 'Hours']],
    body: [
      ['Work', sum.work + sum.extra],
      ['Work + Red Day', sum.work + sum.extra + sum.redDay],
      ['Meeting', sum.meeting],
      ['Sick', sum.sick],
      ['Vacation', sum.vacation],
      ['VAB', sum.vab],
      ['Red Day', sum.redDay],
      ['TOTAL', sum.total],
      ['TOTAL + RED DAYS', sum.total + sum.redDay]

    ],
    theme: 'grid',
    headStyles: { fillColor: [40, 40, 40] }
  })

  const finalY =
    (doc as jsPDF & { lastAutoTable?: { finalY: number } })
      .lastAutoTable?.finalY || 60

  autoTable(doc, {
    startY: finalY + 10,
    head: [['Date','Type','Hours'/*,'Project','Comment'*/]],
    body: entries.map((e: UserDetailsEntry/*: Entry*/) => [
      e.date,
      typeLabel(e.type),
      e.hours,
      //e.project ? `${e.project.city} - ${e.project.address}` : '',
      e.comment || ''
    ]),
    theme: 'striped',
    styles: { fontSize: 8 }
  })

  doc.save(`${getUserName(user.user)}_${month.value}_${year.value}.pdf`)
}
async function exportAllPDF() {
  await ensureAllDetailsLoaded()
  const doc = new jsPDF()
  for (const user of stats.users) {
    const entries = getEntries(user.user.id)

    const sum = summary(user)

    doc.setFontSize(14)
    doc.text(`User: ${getUserName(user.user)}`, 14, 20)

    autoTable(doc, {
      startY: 25,
      head: [['Category','Hours']],
      body: [
        ['Work', sum.work + sum.extra],
        ['Work + Red Day', sum.work + sum.extra + sum.redDay],
        ['Meeting', sum.meeting],
        ['Sick', sum.sick],
        ['Vacation', sum.vacation],
        ['VAB', sum.vab],
        ['Red Day', sum.redDay],
        ['Total', sum.total],
        ['Total + RED DAYS', sum.total + sum.redDay],
      ]
    })
    const finalY =
        (doc as jsPDF & { lastAutoTable?: { finalY: number } })
            .lastAutoTable?.finalY ?? 30
    autoTable(doc, {
      startY: finalY + 10,
      head: [['Date','Type','Hours'/*,'Project','Comment'*/]],
      body: entries.map((e: UserDetailsEntry) => [
        e.date,
        e.type,
        e.hours,
        //e.project ? `${e.project.city} - ${e.project.address}` : '',
        //e.comment || ''
      ])
    })

    doc.addPage()
  }

  doc.save(`All_Users_${month.value}_${year.value}.pdf`)
}
onMounted(load)
</script>

<template>
  <div v-if="isLoading">
    <div 
      v-for="i in 3" 
      :key="i" 
      class="user-card skeleton"
    >
      <div class="skeleton-line title" />
      <div class="skeleton-line" />
      <div class="skeleton-line short" />
    </div>
  </div>
  <div class="stats-page">
    <!--class controls-->
    <div class="date-controls">
      <div class='date-group'>
        <div class="input-group">
          <label>{{ t('stats.year') }}</label>
          <input
            v-model.number="year"
            type="number"
            min="2025"
            max="2100"
          >
        </div>

        <div class="input-group">
          <label>{{ t('stats.month') }}</label>
          <select v-model.number="month">
            <option 
              v-for="m in 12" 
              :key="m" 
              :value="m"
            >
              {{ m }}
            </option>
          </select>
        </div>
      </div>  
    <!--Load-->
      <div class='button-group'>
        <button @click="load">
          {{ t('stats.load') }}
        </button>
        <button @click="exportAllExcel">
          {{ t('stats.exportExcel') }}
        </button>
        <button @click="exportAllPDF">
          {{ t('stats.exportPDF') }}
        </button>
      </div>  
    </div>

    <div 
      v-for="u in stats.users" 
      :key="u.user.id" 
      class="user-card"
    >
      <div 
        class="header" 
        @click="expanded[u.user.id] = !expanded[u.user.id]"
      >
        <div>
          <strong>{{ getUserName(u.user) }}
          </strong>
          <br>
          {{ t('stats.work') }}: {{ u.workHours }}h |
          {{ t('stats.extra') }}: {{ u.extraHours }}h |
          {{ t('stats.totalWork') }}: {{ u.workHours + u.extraHours }}h |
          {{ t('stats.totalWorkRedDay') }}: {{ u.workHours + u.extraHours + u.redDayHours }}h |
          {{ t('stats.meeting') }}: {{ u.meetingHours }}h |
          {{ t('stats.sick') }}: {{ u.sickHours }}h |
          {{ t('stats.vacation') }}: {{ u.vacationHours }}h |
          {{ t('stats.redDay') }}: {{ u.redDayHours }}h |
          {{ t('stats.vab') }}: {{ u.vabHours /*|| 0*/ }}h
        </div>
        <div>{{ u.totalHours }} h</div>
      </div>

      <div 
        v-if="expanded[u.user.id]"
      >
        <button @click="toggleDetails(u.user.id)">
          {{ detailsOpen[u.user.id] ? t('stats.hideDetails') : t('stats.details') }}
        </button>
        <!--stats.details[u.user.id]  ${u.user.id}-${year}-${month}-->
        <div 
          v-if="detailsOpen[u.user.id] && stats.details[getKey(u.user.id)]" 
          class="details-list"
        >
          <div 
            class="calendar-grid"
          >
            <div
              v-for="day in buildCalendar(u.user.id)"
              :key="day.day"
              class="calendar-cell"
              @click="selectedDay[u.user.id] = day.day"
            >
              <div class="day-number">
                {{ day.day }}
              </div>

              <div
                v-for="e in day.entries"
                :key="e.id"
                :class="typeClass(e.type)"
                class="entry-badge"
                :title="`${e.project?.city || ''} ${e.project?.address || ''} ${e.comment || ''}`"
              >
                {{ typeLabel(e.type) }} ({{ e.hours }}h)
              </div>
            </div>
          </div>
          <div 
            v-if="selectedDay[u.user.id]" 
            class="mobile-info"
          >
            <div
              v-for="e in (buildCalendar(u.user.id)
                .find(d => d.day === selectedDay[u.user.id])?.entries || [])"
              :key="e.id"
            >
              <strong>{{ e.date }}</strong> —
              {{ e.project?.city }} {{ e.project?.address }} —
              {{ e.comment }}
            </div>
          </div>

          <div class="details-list">
            <!--stats.details[getKey(u.user.id)]?.entries  getEntries(u.user.id)-->
            <div
              v-for="e in getEntries(u.user.id)"
              :key="e.id"
            >
              {{ e.date }} —
              {{ typeLabel(e.type) }} —
              {{ e.hours }}h —
              {{ e.project?.city }} {{ e.project?.address }} —
              {{ e.comment }}
            </div>
          </div>

          <div class="export-buttons">
            <button @click="exportExcelSingle(u)">
              Excel
            </button>
            <button 
              @click="exportPDFSingle(u)"
            >
              PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-page { padding:24px; /*max-width:1200px;*/ margin:auto; width:100%;
    max-width:100%;
    overflow-x:hidden;
    box-sizing:border-box; }
.calendar-grid { display:grid; grid-template-columns:repeat(7,1fr); gap:8px; }
.calendar-cell { border:1px solid #eee; border-radius:8px; padding:6px; min-height:90px; cursor:pointer; }
.day-number { font-weight:bold; margin-bottom:4px; }

.entry-badge {
  font-size:11px;
  padding:4px 6px;
  border-radius:50px;
  margin-bottom:4px;
  color:white;
}

.badge.work { background:#2ecc71; }
.badge.red-day { background: #e67e22; }
.badge.extra { background:#f1c40f; color:black; }
.badge.meeting{ background: blue; color: orange}
.badge.sick { background:#e74c3c; }
.badge.vacation { background:#3498db; }
.badge.vab { background:#9b59b6; }

.mobile-info {
  margin-top:10px;
  padding:10px;
  background:#f8f8f8;
  border-radius:8px;
}

.details-list {
  margin-top:15px;
  font-size:13px;
  border-top:1px solid #eee;
  padding-top:10px;
}

.export-buttons { margin-top:15px; display:flex; gap:10px; }

.user-card {
  border:1px solid #eee;
  border-radius:12px;
  padding:16px;
  margin-bottom:20px;
  background:white;

  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.user-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.06);
}
.header {
  background-color: #2563eb;
  color: white;
  padding: 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.2s ease;
}

.date-controls {
  /*display: flex;*/
  gap: 20px;
  align-items: flex-end;

  box-sizing:border-box;
}
.header:hover {
  background: #1d4ed8;
}
.input-group {
  display: flex;
  flex-direction: column;
}

.input-group label {
  font-size: 12px;
  margin-bottom: 4px;
  color: #666;
}

.input-group input {
  padding: 8px 10px;
  border-radius: 8px;
  border: 1px solid #ddd;
  font-size: 14px;
  width: 120px;
  transition: all 0.2s ease;
}

.input-group input:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
}

.input-group select {
  padding: 8px 10px;
  border-radius: 8px;
  border: 1px solid #ddd;
  font-size: 14px;
  width: 120px;
  transition: all 0.2s ease;
  background: white;
  cursor: pointer;
}

.input-group select:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
}

/* Skeleton animation */
@keyframes shimmer {
  0% { background-position: -400px 0; }
  100% { background-position: 400px 0; }
}

.skeleton-line {
  height: 14px;
  border-radius: 6px;
  margin-bottom: 10px;
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 50%,
    #f0f0f0 75%
  );
  background-size: 400px 100%;
  animation: shimmer 1.4s infinite linear;
}

.skeleton-line.title {
  height: 20px;
  width: 60%;
}

.skeleton-line.short {
  width: 40%;
}

.user-card.skeleton {
  padding: 20px;
}

button {
  padding: 8px 14px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  background: #2563eb;
  color: white;
  font-weight: 500;
  transition: all 0.2s ease;
}

button:hover {
  background: #1d4ed8;
}

button:active {
  transform: scale(0.97);
}

@media (max-width: 768px) {
  .calendar-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .date-group {
    display: flex;
    gap: 10px;
  }
  .button-group {
    display: flex;
    gap: 10px;
  }

  .calendar-cell {
    min-height: 70px;
    font-size: 12px;
  }

  .entry-badge {
    font-size: 9px;
    padding: 2px 4px;
  }
}
@media (max-width: 600px) {
  .calendar-grid {
    grid-template-columns: repeat(auto-fit, minmax(90px, 1fr));
  }
  .stats-header{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:8px;
  }

  .stats-header button{
      grid-column:span 2;
  }
}
</style>