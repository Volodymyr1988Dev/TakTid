<script setup lang="ts">
import { computed, ref } from 'vue'
import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../../composables/useAbsenceEntryForm'
import { useProjectStore } from '../../../stores/project.store'

import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { EntryState } from '../../../types/EntryState'
import type { TimeBasedForm } from '../../../types/TimeBasedForm'

/* ───── props / emits ───── */

const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}>()

const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'cancel'): void
  (e: 'deleted'): void
}>()

/* ───── store ───── */

const projectStore = useProjectStore()

const project = computed(() => projectStore.selectedProject)
const projectId = computed<string | null>(
  () => projectStore.selectedProject?.id ?? null
)

/* ───── state ───── */

const state = ref<EntryState>(
  props.entry?.kind ?? EntryState.WORK
)

/* ───── forms ───── */

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

/* ───── mode (WORK / EXTRA) ───── */

const mode = computed<'WORK' | 'EXTRA'>({
  get: () =>
    state.value === EntryState.EXTRA ? 'EXTRA' : 'WORK',
  set: v => {
    state.value =
      v === 'EXTRA'
        ? EntryState.EXTRA
        : EntryState.WORK
  },
})

/* ───── active time form ───── */

const activeTimeForm = computed<TimeBasedForm | null>(() => {
  if (state.value === EntryState.WORK) return workForm
  if (state.value === EntryState.EXTRA) return extraForm
  return null
})

/* ───── ui helpers ───── */

const isSaving = computed(
  () => Boolean(activeTimeForm.value?.isSaving)
)

const projectMissing = computed(() =>
  (state.value === EntryState.WORK ||
   state.value === EntryState.EXTRA) &&
  !projectId.value
)

/* ───── models ───── */

const startModel = computed({
  get: () => activeTimeForm.value?.start.value ?? '',
  set: v => activeTimeForm.value && (activeTimeForm.value.start.value = v),
})

const endModel = computed({
  get: () => activeTimeForm.value?.end.value ?? '',
  set: v => activeTimeForm.value && (activeTimeForm.value.end.value = v),
})

const breakMinutesModel = computed({
  get: () => activeTimeForm.value?.breakMinutes.value ?? 0,
  set: v => activeTimeForm.value && (activeTimeForm.value.breakMinutes.value = v),
})

const commentModel = computed<string>({
  get: () =>
    state.value === EntryState.ABSENCE
      ? absenceForm.comment.value
      : activeTimeForm.value?.comment.value ?? '',
  set: v => {
    if (state.value === EntryState.ABSENCE) {
      absenceForm.comment.value = v
    } else if (activeTimeForm.value) {
      activeTimeForm.value.comment.value = v
    }
  },
})

const imagePreviews = computed(
  () => activeTimeForm.value?.images.previews.value ?? []
)

/* ───── actions ───── */

async function onSave() {
  console.log('[Modal] Save click', state.value)

  if (state.value === EntryState.ABSENCE) {
    const entry = await absenceForm.save()
    entry && emit('saved', entry)
    return
  }

  if (!activeTimeForm.value) return
  if (projectMissing.value) return

  const entry = await activeTimeForm.value.save()
  entry && emit('saved', entry)
}

async function onDelete() {
  if (state.value === EntryState.ABSENCE) {
    await absenceForm.remove()
  } else {
    await activeTimeForm.value?.remove()
  }

  emit('deleted')
}
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <header class="modal-header">
        <button class="back-btn" @click="emit('cancel')">
          ← Back
        </button>
      </header>

      <h3>
        {{
          (state === EntryState.ABSENCE ||
            activeTimeForm?.isEdit)
            ? 'Edit time'
            : 'Register time'
        }}
      </h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <div v-if="project" class="project-pill">
        <p v-if="projectMissing" class="error">
          Please select a project
        </p>
        <strong>{{ project.city }}</strong>
        <small>{{ project.address }}</small>
      </div>

      <select
        v-if="state !== EntryState.ABSENCE"
        v-model="mode"
      >
        <option value="WORK">Work</option>
        <option value="EXTRA">Extra work</option>
      </select>

      <div v-if="activeTimeForm">
        <input v-model="startModel" type="time" />
        <input v-model="endModel" type="time" />
        <input v-model.number="breakMinutesModel" type="number" min="0" />

        <input
          type="file"
          multiple
          accept="image/*"
          @change="activeTimeForm.images.onSelect"
        />

        <div v-if="imagePreviews.length" class="previews">
          <img v-for="(src, i) in imagePreviews" :key="i" :src="src" />
        </div>

        <p>{{ activeTimeForm.calculatedHours }} h</p>
      </div>

      <p v-else>
        Absence: {{ absenceForm.kind }}
      </p>

      <textarea v-model="commentModel" placeholder="Comment" />

      <div class="actions">
        <button
          v-if="activeTimeForm?.isEdit || state === EntryState.ABSENCE"
          class="danger"
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
  background: #fee2e2;
  padding: 8px 12px;
  border-radius: 8px;
  margin: 8px 0;
}
.project-pill {
  background: #f1f5f9;
  padding: 8px 12px;
  border-radius: 10px;
  cursor: pointer;
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

.modal-header {
  margin-bottom: 8px;
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
</style>