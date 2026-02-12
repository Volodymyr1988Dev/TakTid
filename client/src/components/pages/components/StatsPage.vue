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

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

/* ================= HELPERS ================= */

function getUserName(user: UserInfo) {
  return user.name || user.email || 'Unknown User'
}

async function toggleDetails(userId: string) {
  detailsOpen.value[userId] = !detailsOpen.value[userId]

  if (detailsOpen.value[userId] && !stats.details[userId]) {
    await stats.loadUserDetails(userId, year.value, month.value)
  }
}

function summary(u: UserStats) {
  return {
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

/* ================= EXPORT ALL USERS ================= */

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

    sheet.addRow(['Work', sum.work])
    sheet.addRow(['Extra Work', sum.extra])
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
        ['Work', sum.work],
        ['Extra Work', sum.extra],
        ['Sick', sum.sick],
        ['Vacation', sum.vacation],
        ['VAB', sum.vab],
        ['Total', sum.total]
      ]
    })

    autoTable(doc, {
      startY: (doc as any).lastAutoTable.finalY + 10,
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
    <input v-model="year" type="number" />
    <input v-model="month" type="number" min="1" max="12" />
    <button @click="load">Load</button>
    <button @click="exportAllExcel">Export Excel</button>
    <button @click="exportAllPDF">Export PDF</button>
  </div>

  <div v-for="u in stats.users" :key="u.user.id" class="user-card">

    <div class="header" @click="expanded[u.user.id] = !expanded[u.user.id]">
      <strong>{{ getUserName(u.user) }}</strong>
      <div>{{ u.totalHours }} h</div>
    </div>

    <div v-if="expanded[u.user.id]">
      <button @click="toggleDetails(u.user.id)">
        {{ detailsOpen[u.user.id] ? 'Hide Details' : 'Details' }}
      </button>

      <div v-if="detailsOpen[u.user.id] && stats.details[u.user.id]" class="details-list">
        <div
          v-for="e in stats.details[u.user.id].entries"
          :key="e.id"
        >
          {{ e.date }} —
          {{ e.type }} —
          {{ e.hours }}h —
          {{ e.project?.city }} {{ e.project?.address }} —
          {{ e.comment }}
        </div>
      </div>
    </div>

  </div>
</div>
</template>

<style scoped>
.stats-page { padding:24px; max-width:1200px; margin:auto; }
.controls { display:flex; gap:10px; margin-bottom:20px; }

.user-card {
  border:1px solid #eee;
  border-radius:12px;
  padding:16px;
  margin-bottom:20px;
  background:white;
}

.header {
  display:flex;
  justify-content:space-between;
  cursor:pointer;
  font-weight:bold;
}

.details-list {
  margin-top:10px;
  font-size:14px;
}
</style>