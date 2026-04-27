<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
defineProps<{
  modelValue: 'week' | 'month'
}>()

defineEmits<{
  (e: 'update:modelValue', value: 'week' | 'month'): void
}>()
</script>

<template>
  <div class="tabs">
    <button
      :class="{ active: modelValue === 'week' }"
      @click="$emit('update:modelValue', 'week')"
    >
      📅 {{ t('calendar.week') }}
    </button>
    <button
      :class="{ active: modelValue === 'month' }"
      @click="$emit('update:modelValue', 'month')"
    >
      🗓 {{ t('calendar.month') }}
    </button>
  </div>
</template>