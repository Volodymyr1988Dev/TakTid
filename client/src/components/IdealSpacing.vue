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

  if (!len || len < 20) {
    error.value = 'Length must be ≥ 20 cm'
    return false
  }

  if (!id || id < 20) {
    error.value = 'Ideal spacing must be ≥ 20 cm'
    return false
  }

  error.value = null
  return true
}

watch([length, ideal], () => {
  if (timer) clearTimeout(timer)

  timer = setTimeout(() => {
    if (!validate()) return

    debouncedLength.value = length.value
    debouncedIdeal.value = ideal.value
  }, 400)
})

const result = computed(() => {
  if (!debouncedLength.value || !debouncedIdeal.value) return null
  return calculateIdealSpacing(debouncedLength.value, debouncedIdeal.value)
})
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