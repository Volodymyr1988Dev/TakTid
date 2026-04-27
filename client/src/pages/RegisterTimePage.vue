<script setup lang="ts">
import RegisterTabs from '../components/tabs/RegisterTabs.vue'
import type { Dayjs } from 'dayjs'
import type { TimeSuggestion } from '../types/Suggestion.type'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
defineProps<{ day: Dayjs }>()

const emit = defineEmits<{
  (e: 'select-suggestion', s: TimeSuggestion): void
  (e: 'close'): void
}>()
</script>

<template>
  <div class="register-page">
    <header>
      <button @click="emit('close')">
        ← {{ t('common.back') }}
      </button>
      {{ t('common.registerTime') }}
    </header>

    <RegisterTabs
      @select-suggestion="s => emit('select-suggestion', s)"
    />
  </div>
</template>