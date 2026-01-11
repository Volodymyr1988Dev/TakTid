<script setup lang="ts">
import { ref } from 'vue'
import SuggestionsTab from './tabs/SuggestionsTab.vue'
import ProjectTab from '../Projects/ProjectTab.vue'
import AbsenceTab from './tabs/AbsenceTab.vue'
import InternalTab from './tabs/InternalTab.vue'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import type { TimeEntry } from '../../types/TimeEntry.type'

const tab = ref<'suggestions' | 'projects' | 'internal' | 'absence'>('suggestions')

const emit = defineEmits<{
  (e: 'selectSuggestion', s: TimeSuggestion): void
  (e: 'editEntry', entry: TimeEntry): void
}>()
</script>

<template>
  <div class="tabs">
    <button
      :class="{ active: tab === 'suggestions' }"
      @click="tab = 'suggestions'"
    >
      Suggestions
    </button>
    <button
      :class="{ active: tab === 'projects' }"
      @click="tab = 'projects'"
    >
      Projects
    </button>
    <button
      :class="{ active: tab === 'internal' }"
      @click="tab = 'internal'"
    >
      Internal
    </button>
    <button
      :class="{ active: tab === 'absence' }"
      @click="tab = 'absence'"
    >
      Absence
    </button>
  </div>

  <SuggestionsTab
    v-if="tab === 'suggestions'"
    @select="(s: TimeSuggestion) => emit('selectSuggestion', s)"
  />

  <ProjectTab
    v-if="tab === 'projects'"
    @select="s => emit('selectSuggestion', s)"
  />

  <InternalTab
    v-if="tab === 'internal'"
    @select="s => emit('selectSuggestion', s)"
  />
  <AbsenceTab
    v-if="tab === 'absence'"
    @select="s => emit('selectSuggestion', s)"
  />
</template>