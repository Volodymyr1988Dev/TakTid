<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../../types/timeKind.enum'
//import type { TimeEntry } from '../../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { useTimeEntryStore } from '../../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../../stores/projectAssignment.store'
import type { DayEntry } from '../../../types/DayEntry.type'
import { calculateWorkedMinutes } from '../../pages/components/helpers/time'
import { useProjectImageStore } from '../../../stores/projectImage.store'

/* ================= PROPS ================= */
const props = defineProps<{
  date: string
  preset?: TimeSuggestion | null
  //entry?: TimeEntry | null
  entry?: DayEntry  | null
}>()

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'saved'): void
}>()
const timeStore = useTimeEntryStore()
//const store = useTimeEntryStore()
const assignmentStore = useProjectAssignmentStore()
/* ================= STATE ================= */
const start = ref('08:00')
const end = ref('17:00')
const breakMinutes = ref(60)
const kind = ref<TimeKind>(TimeKind.WORK)
const comment = ref('')
const projectId = ref<string | undefined>(undefined)
const isMeeting = computed(() => kind.value === TimeKind.MEETING)
const mode = ref<'WORK' | 'EXTRA'>('WORK')
const images = ref<File[]>([])
const imageStore = useProjectImageStore()
//const extraText = ref('')
//const extraWork = ref('')
/* ================= PRE-FILL FROM ENTRY ================= */
watch(
  () => props.entry,
  async (e) => {
    if (!e) return
    //if (e.kind === 'WORK') {
    //if (isWorkEntry(e)) {
    if (e.kind === 'WORK') {
      mode.value = 'WORK'
      kind.value = e.type
      start.value = e.startTime
      end.value = e.endTime
      breakMinutes.value = e.breakMinutes ?? 0
      projectId.value = e.projectId
      comment.value = e.comment ?? ''
      if (e.projectId) {
        await imageStore.load(e.projectId)
      }
    } //else {
    //if (isExtraEntry(e)) {
    else if (e.kind === 'EXTRA') {
      mode.value = 'EXTRA'
      start.value = e.startTime ?? '08:00'
      end.value = e.endTime ?? '17:00'
      breakMinutes.value = e.breakMinutes ?? 60
      projectId.value = e.projectId
      comment.value = e.comment ?? ''
      if (e.projectId) {
        await imageStore.load(e.projectId)
      }
    }
    else if (e.kind === 'ABSENCE') {
      mode.value = 'WORK'
      kind.value = e.type
      comment.value = e.comment ?? ''
    }
    else {
      console.warn('Unknown entry kind', e)
    }
  },
  { immediate: true },
)

/* ================= PRE-FILL FROM PRESET =================*/ 

watch(
  () => props.preset,
  p => {
    if (!p) return
    kind.value = p.type
    breakMinutes.value = p.breakMinutes ?? 60
    projectId.value = p.projectId
    //if (!isAbsence.value) {
    //  mode.value = p.type === TimeKind.EXTRA ? 'EXTRA' : 'WORK'
    //}
  },
  { immediate: true },
)

const calculatedHours = computed(() => {

  const worked =calculateWorkedMinutes(
    start.value,
    end.value,
    normalizedBreakMinutes.value,
)
  return worked > 0 ? (worked / 60).toFixed(2) : '0.00'
})

const isEdit = computed(() => !!props.entry)
//const isWork = computed(() => kind.value === TimeKind.WORK)
//const isMeeting = computed(() => kind.value === TimeKind.MEETING)

const isAbsence = computed(() =>
  kind.value === TimeKind.SICK ||
  kind.value === TimeKind.VAB ||
  kind.value === TimeKind.VACATION,
)
const isSaving = ref(false)
const isExtra = computed(() => mode.value === 'EXTRA')

const normalizedBreakMinutes = computed(() => {
  const value = Number(breakMinutes.value)
  return Number.isFinite(value) && value >= 0 ? value : 0
})


function onImagesSelected(e: Event) {
  const files = Array.from((e.target as HTMLInputElement).files ?? [])

  const MAX_FILES = 10
  const MAX_SIZE = 10 * 1024 * 1024 // 10MB

  const valid = files.filter(f =>
    f.type.startsWith('image/') && f.size <= MAX_SIZE
  )

  if (valid.length > MAX_FILES) {
    alert('Max 10 images allowed')
    return
  }

  images.value = valid
}

async function remove() {
  if (!props.entry) return
  if (!confirm('Delete this entry?')) return
  //if (isExtraEntry(props.entry)) {
  if (props.entry.kind === 'EXTRA') {
    await assignmentStore.remove(props.entry.id)
  //} else if (isWorkEntry(props.entry)) {
  } else //if (props.entry.kind === 'WORK') 
  {
    await timeStore.remove(props.entry.id)
  }
  //props.entry.kind === 'EXTRA'
  //  ? await assignmentStore.remove(props.entry.id)
  //  : await timeStore.remove(props.entry.id)
  //if (props.entry.kind === 'EXTRA') {
  //  await assignmentStore.remove(props.entry.id)
  //} else {
  //  await timeStore.remove(props.entry.id)
  //}
  emit('saved')
  images.value = []
}
/* ================= SAVE ================= */
async function save() {
  if (isSaving.value) return
  isSaving.value = true
  try {
    if (isAbsence.value) {
      const payload = {
        date: props.date,
        type: kind.value,
        startTime: '08:00',
        endTime: '17:00',
        breakMinutes: 60,
        comment: comment.value,
      }

      props.entry?.kind === 'WORK'
        ? await timeStore.update(props.entry.id, payload)
        : await timeStore.add(payload)

      emit('saved')
      return
    }

    //if (!projectId.value) {
    //  alert('Project is required')
    //  return
    //}

    if (
      kind.value === TimeKind.WORK &&
      !projectId.value
    ) {
      alert('Project is required for work')
      return
    }

    if (isExtra.value) {
      if (props.entry && props.entry.kind === 'EXTRA') 
      {
        //? 
        await assignmentStore.update(props.entry.id, {
            comment: comment.value,
            startTime: start.value,
            endTime: end.value,
            breakMinutes: normalizedBreakMinutes.value,
          })
          //if (images.value.length && projectId.value) {
          //  await imageStore.upload(projectId.value, images.value)
          //}
        } else {
        //: 
        if (!projectId.value) {
            alert('Project is required for extra work')
            return
          }  
         await assignmentStore.create({
            projectId: projectId.value,
            date: props.date,
            comment: comment.value,
            startTime: start.value,
            endTime: end.value,
            breakMinutes: normalizedBreakMinutes.value,
          })
        }
        //if (images.value.length && projectId.value) {
        //  await imageStore.upload(projectId.value, images.value)
        //}
    } else {
      const createPayload = {
        date: props.date,
        type: kind.value,
        //projectId: projectId.value,
        startTime: start.value,
        endTime: end.value,
        breakMinutes: normalizedBreakMinutes.value,
        comment: comment.value,
        ...(projectId.value && { projectId: projectId.value }),
      }
      const updatePayload = {
        startTime: start.value,
        endTime: end.value,
        breakMinutes: normalizedBreakMinutes.value,
        comment: comment.value,
        ...(projectId.value && { projectId: projectId.value }),
      }

      props.entry?.kind === 'WORK'
        ? await timeStore.update(props.entry.id, updatePayload)
        : await timeStore.add(createPayload)

    }
    if (images.value.length && projectId.value) {
        await imageStore.upload(projectId.value, images.value)
      }
  images.value = []    
  emit('saved')
  
  } catch{
    alert('Something went wrong during saving')
  }
  finally{
    isSaving.value = false
  }
  /* -------- ABSENCE -------- */
  
}
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <header class="modal-header">
        <button 
          class="back-btn" 
          @click="emit('cancel'); images = []"
        >
          ← Back
        </button>
      </header>
      <h3>{{ isEdit ? 'Edit time' : 'Register time' }}</h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <!-- WORK / MEETING -->
      <!-- MODE -->
      <div v-if="!isAbsence && !isMeeting">
        <select v-model="mode">
          <option value="WORK">
            Work
          </option>
          <option value="EXTRA">
            Extra work
          </option>
        </select>
      </div>
      <!-- WORK / EXTRA -->
      <div v-if="!isAbsence">
        <input 
          v-model="start" 
          type="time"
        >
        <input 
          v-model="end" 
          type="time" 
        >
        <input 
          v-model.number="breakMinutes"
          type="number"
          min="0"
        >
        <input
          v-if="projectId"
          type="file"
          multiple
          accept="image/*"
          @change="onImagesSelected"
        >
        <div
          v-if="imageStore.images.length"
          class="existing-images"
        >
          <p>Existing images:</p>

          <div class="thumbs">
            <div
              v-for="img in imageStore.images"
              :key="img.id"
              class="thumb"
            >
              <img :src="img.url">
              <button
                class="remove"
                @click="imageStore.remove(img.id)"
              >
                ✕
              </button>
            </div>
          </div>
        </div>
        <div
          v-if="images.length"
          class="selected-images"
        >
          <p>Selected images:</p>
          <ul>
            <li
              v-for="(img, i) in images"
              :key="i"
            >
              {{ img.name }}
            </li>
          </ul>
        </div>
        <p>{{ calculatedHours }} h</p>
      </div>

      <!-- EXTRA 
      <textarea
        v-if="mode === 'EXTRA'"
        v-model="extraText"
        placeholder="Describe extra work"
      /> -->

      <!-- ABSENCE -->
      <p v-if="isAbsence">
        Absence: {{ kind }}
      </p>

      <textarea
        v-model="comment"
        placeholder="Comment"
      />

      <div class="actions">
        <button 
          v-if="isEdit"
          class="danger" 
          @click="remove"
        >
          Delete
        </button>
        <button
          class="primary"
          @click="save"
        >
          Save
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-header {
  display: flex;
  justify-content: flex-start;
  margin-bottom: 8px;
}

.back-btn {
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
  color: #374151;
}

.extra-work {
  margin-top: 8px;
  min-height: 60px;
}
.selected-images {
  margin-top: 8px;
  font-size: 13px;
  color: #444;
}

.selected-images ul {
  padding-left: 16px;
}

.selected-images li {
  line-height: 1.4;
}
.existing-images {
  margin-top: 12px;
}

.thumbs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.thumb {
  position: relative;
}

.thumb img {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 6px;
}

.thumb .remove {
  position: absolute;
  top: -6px;
  right: -6px;
  background: #e11d48;
  color: white;
  border: none;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  cursor: pointer;
}
</style>