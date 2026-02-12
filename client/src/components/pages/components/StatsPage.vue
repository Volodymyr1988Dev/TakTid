<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useStatsStore } from '../../../stores/stats.store'
import ExcelJS from 'exceljs'
import { saveAs } from 'file-saver'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'

// Тип для одного запису
interface Entry {
  id: string
  date: string
  type: string
  hours: number
  startTime?: string
  endTime?: string
  breakMinutes?: number
  project?: {
    city: string
    address: string
  }
  comment?: string
}

const stats = useStatsStore()

const expanded = ref<Record<string, boolean>>({})
const detailsOpen = ref<Record<string, boolean>>({})

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)

// Повертає кількість днів у місяці
function getDaysInMonth(year: number, month: number) {
  return new Date(year, month, 0).getDate()
}

// Формує календар із записами по днях
function buildCalendar(userId: string) {
  const days = getDaysInMonth(year.value, month.value)
  const entries: Entry[] = stats.details[userId]?.entries || []
  const map: Record<number, Entry[]> = {}

  entries.forEach((e) => {
    const day = new Date(e.date).getDate()
    if (!map[day]) map[day] = []
    map[day].push(e)
  })

  return Array.from({ length: days }, (_, i) => ({
    day: i + 1,
    entries: map[i + 1] || []
  }))
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

/* =======================
   EXCEL EXPORT
======================= */
async function exportExcel(userId: string) {
  const entries: Entry[] = stats.details[userId]?.entries || []

  const workbook = new ExcelJS.Workbook()
  const worksheet = workbook.addWorksheet('Stats')

  worksheet.columns = [
    { header: 'Date', key: 'date', width: 15 },
    { header: 'Type', key: 'type', width: 15 },
    { header: 'Hours', key: 'hours', width: 10 },
    { header: 'Start', key: 'start', width: 10 },
    { header: 'End', key: 'end', width: 10 },
    { header: 'Break', key: 'break', width: 10 },
    { header: 'Project', key: 'project', width: 25 },
    { header: 'Comment', key: 'comment', width: 30 }
  ]

  entries.forEach((e) => {
    worksheet.addRow({
      date: e.date,
      type: e.type,
      hours: e.hours,
      start: e.startTime || '',
      end: e.endTime || '',
      break: e.breakMinutes || 0,
      project: e.project ? `${e.project.city} - ${e.project.address}` : '',
      comment: e.comment || ''
    })
  })

  const buffer = await workbook.xlsx.writeBuffer()
  saveAs(new Blob([buffer]), `stats_${userId}_${year.value}_${month.value}.xlsx`)
}

/* =======================
   PDF EXPORT
======================= */
async function exportPDF(userId: string) {
  await nextTick()
  const element = document.getElementById(`calendar-${userId}`)
  if (!element) return

  const canvas = await html2canvas(element)
  const imgData = canvas.toDataURL('image/png')

  const pdf = new jsPDF('p', 'mm', 'a4')
  const imgWidth = 190
  const imgHeight = (canvas.height * imgWidth) / canvas.width

  pdf.addImage(imgData, 'PNG', 10, 10, imgWidth, imgHeight)
  pdf.save(`stats_${userId}_${year.value}_${month.value}.pdf`)
}

onMounted(load)
</script>

<template>
  <div class="stats-page">
    <div class="controls">
      <input v-model="year" type="number" />
      <input v-model="month" type="number" min="1" max="12" />
      <button @click="load">Load</button>
    </div>

    <div v-if="stats.loading" class="loading">Loading...</div>

    <div v-for="u in stats.users" :key="u.user.id" class="user-card">

      <!-- HEADER -->
      <div class="header" @click="expanded[u.user.id] = !expanded[u.user.id]">
        <div>
          <strong>{{ u.user.name }}</strong>
          <small>{{ u.user.email }}</small>
        </div>
        <div class="total">{{ u.totalHours }} h</div>
      </div>

      <!-- SUMMARY -->
      <div v-if="expanded[u.user.id]" class="details">
        <div class="summary-grid">
          <div>Work: {{ u.workHours }} h</div>
          <div>Extra: {{ u.extraHours }} h</div>
          <div>Sick: {{ u.sickHours }} h</div>
          <div>Vacation: {{ u.vacationHours }} h</div>
        </div>

        <button class="more-btn" @click.stop="loadDetails(u.user.id)">
          {{ detailsOpen[u.user.id] ? 'Hide details' : 'More details' }}
        </button>

        <!-- CALENDAR DETAILS -->
        <div
          v-if="detailsOpen[u.user.id] && stats.details[u.user.id]"
          class="calendar-grid-wrapper"
          :id="`calendar-${u.user.id}`"
        >
          <div class="calendar-grid">
            <div
              v-for="day in buildCalendar(u.user.id)"
              :key="day.day"
              class="calendar-cell"
            >
              <div class="day-number">{{ day.day }}</div>

              <div
                v-for="e in day.entries"
                :key="e.id"
                class="entry-block"
              >
                <div :class="typeClass(e.type)">
                  {{ e.type }} ({{ e.hours }}h)
                </div>

                <div class="entry-details">
                  <div v-if="e.startTime && e.endTime">
                    {{ e.startTime }} - {{ e.endTime }}
                    (break: {{ e.breakMinutes ?? 0 }}m)
                  </div>
                  <div v-if="e.project">
                    {{ e.project.city }} – {{ e.project.address }}
                  </div>
                  <div v-if="e.comment" class="comment">
                    "{{ e.comment }}"
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div v-if="!stats.details[u.user.id].entries.length" class="empty">
            No entries for this period
          </div>

          <div class="export-buttons">
            <button @click="exportExcel(u.user.id)">Export Excel</button>
            <button @click="exportPDF(u.user.id)">Export PDF</button>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-page { padding: 24px; max-width: 1100px; margin: auto; }

.controls { display: flex; gap: 12px; margin-bottom: 24px; }

.user-card {
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
  background: white;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.header { display: flex; justify-content: space-between; cursor: pointer; }

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 8px;
  margin: 12px 0;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 8px;
  margin-top: 16px;
}

.calendar-cell {
  border: 1px solid #eee;
  border-radius: 8px;
  min-height: 100px;
  padding: 6px;
  background: #fafafa;
}

.day-number { font-weight: bold; margin-bottom: 6px; }

.entry-block { margin-bottom: 6px; }

.entry-details { margin-left: 6px; font-size: 12px; color: #444; }

.comment { font-style: italic; color: #666; }

.empty { margin-top: 12px; color: #999; }

.badge {
  display: inline-block;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 11px;
  margin-bottom: 2px;
  color: white;
}

.badge.work { background: #2ecc71; }
.badge.extra_work { background: #f39c12; }
.badge.sick { background: #e74c3c; }
.badge.vacation { background: #3498db; }
.badge.vab { background: #9b59b6; }

.export-buttons { margin-top: 16px; display: flex; gap: 12px; }

button {
  padding: 6px 12px;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  background: #2c3e50;
  color: white;
}

button:hover { opacity: 0.9; }
</style>