<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Dayjs } from 'dayjs'
import { createTimeEntry, updateTimeEntry } from '../../api/TimeEntry.api'
import type { TimeEntry } from '../../types/TimeEntry.type'
import { TimeKind } from '../../types/timeKind.enum'
import { uploadPhoto } from '../../api/files'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const props = defineProps<{
  day: Dayjs
  entry?: TimeEntry
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'saved'): void
}>()
async function onFile(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return

  photoUrl.value = await uploadPhoto(file)
}
const isEdit = computed(() => !!props.entry)

const comment = ref<string>(props.entry?.comment ?? '')
const type = ref<TimeKind>(props.entry?.type ?? TimeKind.WORK)
const photoUrl = ref<string | null>(null)   

watch(
  () => props.entry,
  e => {
    comment.value = e?.comment ?? ''
    type.value = e?.type ?? TimeKind.WORK
  },
)

async function save() {
  if (isEdit.value && props.entry) {
    await updateTimeEntry(props.entry.id, {
      comment: comment.value,
      type: type.value,
      breakMinutes: props.entry.breakMinutes,
    })
  } else {
    await createTimeEntry({
      date: props.day.format('YYYY-MM-DD'),
      type: type.value,
      comment: comment.value,
    })
  }

  emit('saved')
  emit('close')
}
</script>

<template>
  <div
    class="overlay"
    @click.self="emit('close')"
  >
    <div class="modal">
      <h3>{{ day.format('D MMMM') }}</h3>

      <textarea
        v-model="comment"
        placeholder="t('calendar.comment')"

      />

      <select v-model="type">
        <option :value="TimeKind.WORK">
          {{ t('stats.work') }}
        </option>
        <option :value="TimeKind.EXTRA">
          {{ t('stats.extra') }}
        </option>
        <option :value="TimeKind.SICK">
          {{ t('stats.sick') }}
        </option>
        <option :value="TimeKind.VACATION">
          {{ t('stats.vacation') }}
        </option>
        <option :value="TimeKind.VAB">
          {{ t('stats.vab') }}
        </option>
      </select>
      <input
        type="file"
        @change="onFile"
      >
      <img
        v-if="photoUrl"
        :src="photoUrl"
        class="preview"
      >
      <button @click="save">
        {{ t('calendar.save') }}
      </button>
    </div>
  </div>
</template>
<style scoped src="../../styles/Modal.css"></style>