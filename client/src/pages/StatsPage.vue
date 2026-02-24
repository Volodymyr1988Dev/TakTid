<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useToast } from '../components/composables/useToast'
import { useStatsStore } from '../stores/stats.store'
import ExcelJS from 'exceljs'
import { saveAs } from 'file-saver'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

interface Entry {
  id: string
  date: string
  type: string
  hours: number
  project?: { city: string; address: string }
  comment?: string
}

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

const toast = useToast()
const isLoading = ref(false)
let debounceTimer: ReturnType<typeof setTimeout> | null = null

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

watch([year, month], () => {
  if (debounceTimer) clearTimeout(debounceTimer)

  debounceTimer = setTimeout(() => {
    load()
  }, 600)
})

function getDaysInMonth(y: number, m: number) {
  return new Date(y, m, 0).getDate()
}

function getUserName(user: UserInfo) {
  return user.name || user.email || 'Unknown User'
}

function buildCalendar(userId: string) {
  const days = getDaysInMonth(year.value, month.value)
  const entries: Entry[] = stats.details[userId]?.entries || []
  const map: Record<number, Entry[]> = {}

  entries.forEach(e => {
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

  if (detailsOpen.value[userId] && !stats.details[userId]) {
    await stats.loadUserDetails(userId, year.value, month.value)
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
    await stats.loadMonth(year.value, month.value)
    expanded.value = {}
    detailsOpen.value = {}
  } catch (e) {
    toast.error('Failed to load statistics')
    console.error(e)
  } finally {
    isLoading.value = false
  }
}

async function exportAllExcel() {
  const workbook = new ExcelJS.Workbook()

  for (const user of stats.users) {
    if (!stats.details[user.user.id]) {
      await stats.loadUserDetails(user.user.id, year.value, month.value)
    }

    const sheet = workbook.addWorksheet(getUserName(user.user))
    const sum = summary(user)

    sheet.addRow(['Monthly Report'])
    sheet.addRow([`User: ${getUserName(user.user)}`])
    sheet.addRow([`Period: ${month.value}/${year.value}`])
    sheet.addRow([])

    sheet.addRow(['Work', sum.work + sum.extra])
    sheet.addRow(['Work + Red Day', sum.work + sum.extra + sum.redDay])
    //sheet.addRow(['Extra Work', sum.extra])
    sheet.addRow(['Meeting', sum.meeting])
    sheet.addRow(['Sick', sum.sick])
    sheet.addRow(['Vacation', sum.vacation])
    sheet.addRow(['VAB', sum.vab])
    sheet.addRow(['Red Day', sum.redDay])
    sheet.addRow(['Total + Red Days', sum.total + sum.redDay])
    sheet.addRow(['Total', sum.total])
    sheet.addRow([])

    sheet.addRow(['Date','Type','Hours','Project','Comment'])

    stats.details[user.user.id].entries.forEach((e: Entry) => {
      sheet.addRow([
        e.date,
        e.type,
        e.hours,
        e.project ? `${e.project.city} - ${e.project.address}` : '',
        e.comment || ''
      ])
    })
  }

  const buffer = await workbook.xlsx.writeBuffer()
  saveAs(new Blob([buffer]), `All_Users_${month.value}_${year.value}.xlsx`)
}

function validateInputs(): boolean {
  if (!Number.isInteger(year.value) || year.value < 2025) {
    toast.error('Year must be a valid number greater than 2025')
    return false
  }

  if (!Number.isInteger(month.value)) {
    toast.error('Month must be a valid number')
    return false
  }

  if (month.value < 1 || month.value > 12) {
    toast.error('Month must be between 1 and 12')
    return false
  }

  return true
}

async function exportExcelSingle(user: UserStats) {
  if (!stats.details[user.user.id]) {
    await stats.loadUserDetails(user.user.id, year.value, month.value)
  }

  const workbook = new ExcelJS.Workbook()
  const sheet = workbook.addWorksheet(getUserName(user.user))
  const sum = summary(user)

  sheet.addRow([`Monthly Report`])
  sheet.addRow([`User: ${getUserName(user.user)}`])
  sheet.addRow([`Period: ${month.value}/${year.value}`])
  sheet.addRow([])

  sheet.addRow(['Work', sum.work + sum.extra])
  sheet.addRow(['Work + Red Days', sum.work + sum.extra + sum.redDay])
  //sheet.addRow(['Extra Work', sum.extra])
  sheet.addRow(['Meeting', sum.meeting])
  sheet.addRow(['Sick', sum.sick])
  sheet.addRow(['Vacation', sum.vacation])
  sheet.addRow(['VAB', sum.vab])
  sheet.addRow(['Red Day', sum.redDay])
  sheet.addRow(['Total', sum.total])
  sheet.addRow(['Total+ Red Days', sum.total + sum.redDay])
  sheet.addRow([])

  sheet.addRow(['Date','Type','Hours','Project','Comment'])

  stats.details[user.user.id].entries.forEach((e: Entry) => {
    sheet.addRow([
      e.date,
      typeLabel(e.type),
      e.hours,
      e.project ? `${e.project.city} - ${e.project.address}` : '',
      e.comment || ''
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
  if (!stats.details[user.user.id]) {
    await stats.loadUserDetails(user.user.id, year.value, month.value)
  }

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
      //['Extra Work', sum.extra],
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
    head: [['Date','Type','Hours','Project','Comment']],
    body: stats.details[user.user.id].entries.map((e: Entry) => [
      e.date,
      typeLabel(e.type),
      e.hours,
      e.project ? `${e.project.city} - ${e.project.address}` : '',
      e.comment || ''
    ]),
    theme: 'striped',
    styles: { fontSize: 8 }
  })

  doc.save(`${getUserName(user.user)}_${month.value}_${year.value}.pdf`)
}
async function exportAllPDF() {
  const doc = new jsPDF()

  for (const user of stats.users) {
    if (!stats.details[user.user.id]) {
      await stats.loadUserDetails(user.user.id, year.value, month.value)
    }

    const sum = summary(user)

    doc.setFontSize(14)
    doc.text(`User: ${getUserName(user.user)}`, 14, 20)

    autoTable(doc, {
      startY: 25,
      head: [['Category','Hours']],
      body: [
        ['Work', sum.work + sum.extra],
        ['Work + Red Day', sum.work + sum.extra + sum.redDay],
        //['Extra Work', sum.extra],
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
      head: [['Date','Type','Hours','Project','Comment']],
      body: stats.details[user.user.id].entries.map((e: Entry) => [
        e.date,
        e.type,
        e.hours,
        e.project ? `${e.project.city} - ${e.project.address}` : '',
        e.comment || ''
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
    <div class="date-controls">
      <div class="input-group">
        <label>Year</label>
        <input
          v-model.number="year"
          type="number"
          min="2025"
          max="2100"
        >
      </div>

      <div class="input-group">
        <label>Month</label>
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
    
      <button @click="load">
        Load
      </button>
      <button @click="exportAllExcel">
        Export Excel
      </button>
      <button @click="exportAllPDF">
        Export PDF
      </button>
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
          Work: {{ u.workHours }}h |
          Extra: {{ u.extraHours }}h |
          Total Work: {{ u.workHours + u.extraHours }}h |
          Total Work + Red Day: {{ u.workHours + u.extraHours + u.redDayHours }}h |
          Meeting: {{ u.meetingHours }}h |
          Sick: {{ u.sickHours }}h |
          Vacation: {{ u.vacationHours }}h |
          Red Day: {{ u.redDayHours }}h |
          VAB: {{ u.vabHours /*|| 0*/ }}h
        </div>
        <div>{{ u.totalHours }} h</div>
      </div>

      <div 
        v-if="expanded[u.user.id]"
      >
        <button @click="toggleDetails(u.user.id)">
          {{ detailsOpen[u.user.id] ? 'Hide Details' : 'Details' }}
        </button>

        <div 
          v-if="detailsOpen[u.user.id] && stats.details[u.user.id]" 
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
              v-for="e in buildCalendar(u.user.id)
                .find(d => d.day === selectedDay[u.user.id])?.entries"
              :key="e.id"
            >
              <strong>{{ e.date }}</strong> —
              {{ e.project?.city }} {{ e.project?.address }} —
              {{ e.comment }}
            </div>
          </div>

          <div class="details-list">
            <div
              v-for="e in stats.details[u.user.id].entries"
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
.stats-page { padding:24px; max-width:1200px; margin:auto; }
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
  display: flex;
  gap: 20px;
  align-items: flex-end;
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
}
</style>