<script setup lang="ts">
import { ref, computed } from 'vue'
import RegisterTabs from './RegisterTabs.vue'
import TimeFormModal from './components/TimeFormModal.vue'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { TimeEntry } from '../../types/TimeEntry.type'
import type { Dayjs } from 'dayjs'

const props = defineProps<{ day: Dayjs }>()

const selectedDate = computed(() =>
  props.day.format('YYYY-MM-DD'),
)

// 🧠 modal state
const modalOpen = ref(false)
const preset = ref<TimeSuggestion | null>(null)
const editEntry = ref<TimeEntry | null>(null)

// 👉 open from suggestion
function openFromSuggestion(s: TimeSuggestion) {
  preset.value = s
  editEntry.value = null
  modalOpen.value = true
}

// ✏️ open edit
function openEdit(entry: TimeEntry) {
  editEntry.value = entry
  preset.value = null
  modalOpen.value = true
}
</script>

<template>
  <div class="register-page">
    <header class="header">
      Register time
    </header>

    <RegisterTabs
      @select-suggestion="openFromSuggestion"
      @edit-entry="openEdit"
    />

    <TimeFormModal
      v-if="modalOpen"
      :date="selectedDate"
      :preset="preset"
      :entry="editEntry"
      @close="modalOpen = false"
    />
  </div>
</template>

<style src="./register-time.css"></style>