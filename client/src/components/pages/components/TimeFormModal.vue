<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../../composables/useAbsenceEntryForm'
import { useEntryFormSelector } from '../../composables/useEntryFormSelector'

import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { EntryState } from '../../../types/EntryState'
import type { EntryMode } from '../../../types/Form.types'

import { useProjectStore } from '../../../stores/project.store'

/* ================= props / emits ================= */

const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}>()

const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'deleted'): void
  (e: 'cancel'): void
}>()

/* ================= mode ================= */

const mode = ref<EntryMode>(
  props.entry?.kind === EntryState.EXTRA
    ? 'EXTRA'
    : props.entry?.kind === EntryState.ABSENCE
      ? 'ABSENCE'
      : 'WORK',
)

/* ================= project ================= */

const projectStore = useProjectStore()

const isTimeMode = computed(() => mode.value !== 'ABSENCE')

const projectId = computed(() =>
  isTimeMode.value
    ? projectStore.selectedProject?.id ?? null
    : null,
)

const projectMissing = computed(
  () => isTimeMode.value && !projectId.value,
)

/* ================= forms ================= */

const workForm = useWorkEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.WORK ? props.entry : null,
  projectId,
})

const extraForm = useExtraEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.EXTRA ? props.entry : null,
  projectId,
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.ABSENCE ? props.entry : null,
})

const active = useEntryFormSelector(mode, {
  work: { ...workForm, kind: 'WORK' },
  extra: { ...extraForm, kind: 'EXTRA' },
  absence: { ...absenceForm, kind: 'ABSENCE' },
})

/* ================= derived ================= */

const isSaving = computed(() => active.value.form.isSaving.value)
const deleting = ref(false)

/* ================= models ================= */

const startModel = computed({
  get: () =>
    active.value.mode === 'ABSENCE'
      ? ''
      : active.value.form.start.value,
  set: v => {
    if (active.value.mode !== 'ABSENCE') {
      active.value.form.start.value = v
    }
  },
})

const endModel = computed({
  get: () =>
    active.value.mode === 'ABSENCE'
      ? ''
      : active.value.form.end.value,
  set: v => {
    if (active.value.mode !== 'ABSENCE') {
      active.value.form.end.value = v
    }
  },
})

const breakMinutesModel = computed({
  get: () =>
    active.value.mode === 'ABSENCE'
      ? 0
      : active.value.form.breakMinutes.value,
  set: v => {
    if (active.value.mode !== 'ABSENCE') {
      active.value.form.breakMinutes.value = v
    }
  },
})

const commentModel = computed({
  get: () => active.value.form.comment.value,
  set: v => {
    active.value.form.comment.value = v
  },
})

const imagePreviews = computed(() =>
  active.value.mode === 'ABSENCE'
    ? []
    : active.value.form.images.previews.value,
)

const calculatedHours = computed(() =>
  active.value.mode === 'ABSENCE'
    ? ''
    : active.value.form.calculatedHours,
)

/* ================= text ================= */

const savingText = computed(() =>
  deleting.value
    ? 'Please wait, removing entry…'
    : 'Please wait, saving entry…',
)
const images = computed(() => {
  if (active.value.mode === 'ABSENCE') return null
  return active.value.form.images
})

/* ================= effects ================= */

watch(
  () => props.entry,
  entry => {
    //if ((e?.kind === 'WORK' || e?.kind === 'EXTRA') && e.projectId) {
    //  projectStore.getById(e.projectId)
    //}
    if (!entry) return

    if (entry.kind === EntryState.WORK) {
      mode.value = 'WORK'
    } else if (entry.kind === EntryState.EXTRA) {
      mode.value = 'EXTRA'
    } else if (entry.kind === EntryState.ABSENCE) {
      mode.value = 'ABSENCE'
    }
  },
  { immediate: true },
)

watch(
  () => props.preset,
  preset => {
    if (!preset) return
    if (props.entry) return
    mode.value = 'ABSENCE'
    absenceForm.kind.value = preset.type
  },
  //{ immediate: true },
)

/* ================= actions ================= */

async function onSave() {
  if (projectMissing.value) {
    alert('Please select a project')
    return
  }

  const entry = await active.value.form.save()
  if (entry) emit('saved', entry)
}

async function onDelete() {
  deleting.value = true
  try {
    await active.value.form.remove()
    emit('deleted')
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <header class="modal-header">
        <button 
          class="back-btn" 
          @click="emit('cancel')"
        >
          ← Back
        </button>
      </header>

      <h3>
        {{
          mode === 'ABSENCE'
            ? `Register absence (${absenceForm.kind})`
            : active.form.isEdit.value
              ? 'Edit time'
              : 'Register time'
        }}
      </h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <div
        v-if="isTimeMode && projectStore.selectedProject"
        class="project-pill"
      >
        <p  
          v-if="projectMissing" 
          class="error"
        >
          Please select a project
        </p>
        <strong>{{ projectStore.selectedProject.city }}</strong>
        <small>{{ projectStore.selectedProject.address }}</small>
      </div>

      <select 
        v-if="isTimeMode" 
        v-model="mode"
      >
        <option value="WORK">
          Work
        </option>
        <option value="EXTRA">
          Extra work
        </option>
      </select>

      <div v-if="isTimeMode">
        <input 
          v-model="startModel" 
          type="time" 
        >
        <input 
          v-model="endModel" 
          type="time" 
        >
        <input 
          v-model.number="breakMinutesModel" 
          type="number" 
          min="0" 
        >

        <div v-if="images">
          <input
            type="file"
            multiple
            accept="image/*"
            @change="images.onSelect"
          >

          <div
            v-if="imagePreviews.length"
            class="previews"
          >
            <img
              v-for="(src, i) in imagePreviews"
              :key="i"
              :src="src"
            >
          </div>
        </div>
        <p>{{ calculatedHours }} h</p>
      </div>

      <p v-else>
        Absence: {{ absenceForm.kind }}
      </p>

      <textarea 
        v-model="commentModel" 
        placeholder="Comment" 
      />

      <div class="actions">
        <span 
          v-if="isSaving" 
          class="loading"
        >
          {{ savingText }}
        </span>

        <button
          v-if="active.form.isEdit.value"
          class="danger"
          :disabled="isSaving"
          @click="onDelete"
        >
          Delete
        </button>

        <button
          class="primary"
          :disabled="isSaving"
          @click="onSave"
        >
          Save
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.error {
  color: #dc2626;
  background: #c89191;
  padding: 8px 12px;
  border-radius: 8px;
  margin: 8px 0;
}
.project-pill {
  background: #f1f5f9;
  padding: 8px 12px;
  border-radius: 10px;
  margin-bottom: 12px;
}
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.4);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal {
  background: white;
  padding: 16px;
  border-radius: 12px;
  width: 420px;
}
.back-btn {
  background: none;
  border: none;
  cursor: pointer;
}
.actions {
  display: flex;
  justify-content: space-between;
  margin-top: 16px;
}
.primary {
  background: #2563eb;
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
}
.danger {
  background: #dc2626;
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
}
.previews {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}
.previews img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 6px;
}
.loading {
  font-size: 14px;
  color: #475569;
}
</style>