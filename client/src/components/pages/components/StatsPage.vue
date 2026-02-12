<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useStatsStore } from '../../../stores/stats.store'
import ExcelJS from 'exceljs'
import { saveAs } from 'file-saver'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'

interface Entry {
  id: string
  date: string
  type: string
  hours: number
  startTime?: string
  endTime?: string
  breakMinutes?: number
  project?: { city: string; address: string }
  comment?: string
}

const stats = useStatsStore()
const expanded = ref<Record<string, boolean>>({})
const detailsOpen = ref<Record<string, boolean>>({})

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

function getDaysInMonth(year: number, month: number) {
  return new Date(year, month, 0).getDate()
}

function buildCalendar(userId: string) {
  const days = getDaysInMonth(year.value, month.value)
  const entries: Entry[] = stats.details[userId]?.entries || []
  const map: Record<number, Entry[]> = {}

  entries.forEach(e => {
    const day = new Date(e.date).getDate()
    if (!map[day]) map[day] = []
    map[day].push(e)
  })

  return Array.from({ length: days }, (_, i) => ({
    day: i + 1,
    entries: map[i + 1] || []
  }))
}

function monthSummary(user: any) {
  return {
    work: user.workHours,
    extra: user.extraHours,
    paid: user.workHours + user.extraHours,
    sick: user.sickHours,
    vacation: user.vacationHours,
    vab: user.vabHours || 0,
    total: user.totalHours
  }
}

async function load() {
  await stats.loadMonth(year.value, month.value)
  expanded.value = {}
  detailsOpen.value = {}
}

async function loadDetails(userId: string) {
  if (!stats.details[userId]) {
    await stats.loadUserDetails(userId, year.value, month.value)
  }
  detailsOpen.value[userId] = !detailsOpen.value[userId]
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

/* ================= EXCEL ================= */

async function exportExcelSingle(user: any) {
  const workbook = new ExcelJS.Workbook()
  const sheet = workbook.addWorksheet(user.user.name)

  const summary = monthSummary(user)

  sheet.addRow([`User: ${user.user.name}`])
  sheet.addRow([`Period: ${month.value}/${year.value}`])
  sheet.addRow([])
  sheet.addRow(['Work (Paid)', summary.paid])
  sheet.addRow(['VAB', summary.vab])
  sheet.addRow(['Sick', summary.sick])
  sheet.addRow(['Vacation', summary.vacation])
  sheet.addRow(['Total', summary.total])
  sheet.addRow([])

  sheet.addRow(['Date','Type','Hours','Project','Comment'])

  stats.details[user.user.id]?.entries.forEach((e: Entry) => {
    sheet.addRow([
      e.date,
      typeLabel(e.type),
      e.hours,
      e.project ? `${e.project.city} - ${e.project.address}` : '',
      e.comment || ''
    ])
  })

  const buffer = await workbook.xlsx.writeBuffer()
  saveAs(new Blob([buffer]), `${user.user.name}_${month.value}_${year.value}.xlsx`)
}

async function exportExcelAll() {
  const workbook = new ExcelJS.Workbook()

  for (const user of stats.users) {
    if (!stats.details[user.user.id]) {
      await stats.loadUserDetails(user.user.id, year.value, month.value)
    }

    const sheet = workbook.addWorksheet(user.user.name)
    const summary = monthSummary(user)

    sheet.addRow([`User: ${user.user.name}`])
    sheet.addRow([`Period: ${month.value}/${year.value}`])
    sheet.addRow([])
    sheet.addRow(['Work (Paid)', summary.paid])
    sheet.addRow(['VAB', summary.vab])
    sheet.addRow(['Sick', summary.sick])
    sheet.addRow(['Vacation', summary.vacation])
    sheet.addRow(['Total', summary.total])
    sheet.addRow([])

    sheet.addRow(['Date','Type','Hours','Project','Comment'])

    stats.details[user.user.id]?.entries.forEach((e: Entry) => {
      sheet.addRow([
        e.date,
        typeLabel(e.type),
        e.hours,
        e.project ? `${e.project.city} - ${e.project.address}` : '',
        e.comment || ''
      ])
    })
  }

  const buffer = await workbook.xlsx.writeBuffer()
  saveAs(new Blob([buffer]), `All_Users_${month.value}_${year.value}.xlsx`)
}

/* ================= PDF ================= */

async function exportPDFSingle(user: any) {
  await nextTick()
  const element = document.getElementById(`calendar-${user.user.id}`)
  if (!element) return

  const canvas = await html2canvas(element)
  const imgData = canvas.toDataURL('image/png')
  const pdf = new jsPDF()
  pdf.text(`User: ${user.user.name}`, 10, 10)
  pdf.addImage(imgData, 'PNG', 10, 20, 190, 0)

  const summary = monthSummary(user)
  pdf.text(`Work (Paid): ${summary.paid}`, 10, 280)
  pdf.text(`VAB: ${summary.vab}`, 70, 280)
  pdf.text(`Sick: ${summary.sick}`, 110, 280)
  pdf.text(`Vacation: ${summary.vacation}`, 150, 280)

  pdf.save(`${user.user.name}_${month.value}_${year.value}.pdf`)
}

async function exportPDFAll() {
  const pdf = new jsPDF()

  for (const user of stats.users) {
    if (!stats.details[user.user.id]) {
      await stats.loadUserDetails(user.user.id, year.value, month.value)
    }

    pdf.addPage()
    pdf.text(`User: ${user.user.name}`, 10, 10)

    const summary = monthSummary(user)
    pdf.text(`Work (Paid): ${summary.paid}`, 10, 20)
    pdf.text(`VAB: ${summary.vab}`, 10, 30)
    pdf.text(`Sick: ${summary.sick}`, 10, 40)
    pdf.text(`Vacation: ${summary.vacation}`, 10, 50)
  }

  pdf.save(`All_Users_${month.value}_${year.value}.pdf`)
}

onMounted(load)
</script>

<template>
<div class="stats-page">

  <div class="controls">
    <input v-model="year" type="number" />
    <input v-model="month" type="number" min="1" max="12" />
    <button @click="load">Load</button>
    <button @click="exportExcelAll">Export All Excel</button>
    <button @click="exportPDFAll">Export All PDF</button>
  </div>

  <div v-for="u in stats.users" :key="u.user.id" class="user-card">
    <div class="header" @click="expanded[u.user.id] = !expanded[u.user.id]">
      <div>
        <strong>{{ u.user.name }}</strong><br/>
        Work: {{ u.workHours }} h |
        Extra: {{ u.extraHours }} h |
        Paid Work: {{ u.workHours + u.extraHours }} h |
        Sick: {{ u.sickHours }} h |
        Vacation: {{ u.vacationHours }} h |
        VAB: {{ u.vabHours || 0 }} h
      </div>
      <div>{{ u.totalHours }} h</div>
    </div>

    <div v-if="expanded[u.user.id]" class="details">
      <button @click.stop="loadDetails(u.user.id)">
        {{ detailsOpen[u.user.id] ? 'Hide details' : 'More details' }}
      </button>

      <div
        v-if="detailsOpen[u.user.id] && stats.details[u.user.id]"
        class="calendar-grid-wrapper"
        :id="`calendar-${u.user.id}`"
      >
        <div class="calendar-grid">
          <div v-for="day in buildCalendar(u.user.id)" :key="day.day" class="calendar-cell">
            <div class="day-number">{{ day.day }}</div>

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

        <div class="export-buttons">
          <button @click="exportExcelSingle(u)">Excel</button>
          <button @click="exportPDFSingle(u)">PDF</button>
        </div>

      </div>
    </div>
  </div>
</div>
</template>

<style scoped>
.stats-page { padding:24px; max-width:1200px; margin:auto; }
.calendar-grid { display:grid; grid-template-columns:repeat(7,1fr); gap:8px; }
.calendar-cell { border:1px solid #eee; border-radius:8px; padding:6px; min-height:90px; }
.day-number { font-weight:bold; margin-bottom:4px; }

.entry-badge {
  font-size:11px;
  padding:4px 6px;
  border-radius:50px;
  color:white;
  margin-bottom:4px;
}

.badge.work { background:#2ecc71; }
.badge.extra { background:#f1c40f; color:black; }
.badge.sick { background:#e74c3c; }
.badge.vacation { background:#3498db; }
.badge.vab { background:#9b59b6; }

.user-card {
  border:1px solid #eee;
  border-radius:12px;
  padding:16px;
  margin-bottom:20px;
  background:white;
}
</style>