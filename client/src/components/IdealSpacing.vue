<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { calculateIdealSpacing } from './helpers/utils/IdealSpace'
import { sanitizeNumber } from './helpers/helpers'

const length = ref<number | null>(null)
const ideal = ref<number | null>(34)

const debouncedLength = ref<number | null>(null)
const debouncedIdeal = ref<number | null>(34)

const error = ref<string | null>(null)
let timer: ReturnType<typeof setTimeout> | null = null

function validate() {
  const len = sanitizeNumber(length.value)
  const id = sanitizeNumber(ideal.value)

  if (!len || len < 20) return (error.value = 'Length ≥ 20 cm'), false
  if (!id || id < 20) return (error.value = 'Ideal ≥ 20 cm'), false

  error.value = null
  return true
}

watch([length, ideal], () => {
  if (timer) clearTimeout(timer)

  timer = setTimeout(() => {
    if (!validate()) return

    debouncedLength.value = length.value
    debouncedIdeal.value = ideal.value
  }, 300)
})

const result = computed(() => {
  if (!debouncedLength.value || !debouncedIdeal.value) return null
  return calculateIdealSpacing(debouncedLength.value, debouncedIdeal.value)
})
/*
function getMarkStyle(mark: number, max = 200) {
  return { left: `${(mark / max) * 100}%` }
}

function getRow(i: number) {
  return i % 3
}*/
</script>

<template>
  <div>
    <h2>Ideal spacing</h2>

    <input v-model.number="length" type="number" placeholder="Length" />
    <input v-model.number="ideal" type="number" placeholder="Ideal spacing" />

    <p v-if="error" class="error">{{ error }}</p>

    <div v-if="result">
      <p>Exact: {{ result.exact }}</p>
      <p>Ideal: {{ result.ideal }}</p>
      <p>Missing: {{ result.missing }}</p>
    </div>
  </div>
</template>

<style scoped>
.error {
  color: red;
}
</style>