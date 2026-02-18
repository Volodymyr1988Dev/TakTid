<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useStatsStore } from '../../../stores/stats.store'
import ExcelJS from 'exceljs'
import { saveAs } from 'file-saver'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

/* ================= TYPES ================= */

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
  vabHours?: number
  totalHours: number
}

/* ================= STATE ================= */

const stats = useStatsStore()
const expanded = ref<Record<string, boolean>>({})
const detailsOpen = ref<Record<string, boolean>>({})
const selectedDay = ref<Record<string, number | null>>({})

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

/* ================= HELPERS ================= */

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
    case 'SICK': return 'badge sick'
    case 'VACATION': return 'badge vacation'
    case 'VAB': return 'badge vab'
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
    work: u.workHours,
    extra: u.extraHours,
    sick: u.sickHours,
    vacation: u.vacationHours,
    vab: u.vabHours || 0,
    total: u.totalHours
  }
}

async function load() {
  await stats.loadMonth(year.value, month.value)
  expanded.value = {}
  detailsOpen.value = {}
}

/* ================= EXCEL ================= */
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
    //sheet.addRow(['Extra Work', sum.extra])
    sheet.addRow(['Sick', sum.sick])
    sheet.addRow(['Vacation', sum.vacation])
    sheet.addRow(['VAB', sum.vab])
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
  //sheet.addRow(['Extra Work', sum.extra])
  sheet.addRow(['Sick', sum.sick])
  sheet.addRow(['Vacation', sum.vacation])
  sheet.addRow(['VAB', sum.vab])
  sheet.addRow(['Total', sum.total])
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

  // ✅ AUTO WIDTH
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

/* ================= PDF ================= */

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
      //['Extra Work', sum.extra],
      ['Sick', sum.sick],
      ['Vacation', sum.vacation],
      ['VAB', sum.vab],
      ['TOTAL', sum.total]
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
        //['Extra Work', sum.extra],
        ['Sick', sum.sick],
        ['Vacation', sum.vacation],
        ['VAB', sum.vab],
        ['Total', sum.total]
      ]
    })
    const finalY =
        (doc as jsPDF & { lastAutoTable?: { finalY: number } })
            .lastAutoTable?.finalY ?? 30
    autoTable(doc, {
      //startY: (doc as jsPDF & { lastAutoTable?: { finalY: number } }).lastAutoTable?.finalY + 10,
      //const finalY =
      //  (doc as jsPDF & { lastAutoTable?: { finalY: number } })
      //      .lastAutoTable?.finalY ?? 30

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
  <div class="stats-page">
    <div class="controls">
      <input 
        v-model="year" 
        type="number" 
      >
      <input 
        v-model="month" 
        type="number" 
        min="1" 
        max="12" 
      >
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
          Sick: {{ u.sickHours }}h |
          Vacation: {{ u.vacationHours }}h |
          VAB: {{ u.vabHours || 0 }}h
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
          <!-- MOBILE TAP INFO -->
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

          <!-- LIST BELOW CALENDAR -->
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
.badge.extra { background:#f1c40f; color:black; }
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
}
.header {
  background-color: #2563eb;
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