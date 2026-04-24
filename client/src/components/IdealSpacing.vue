<script setup lang="ts">
import { ref, computed, watch } from 'vue'
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
    error.value = 'Length must be at least 20 cm'
    return false
  }

  if (!id || id < 20) {
    error.value = 'Ideal spacing must be at least 20 cm'
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
  }, 300)
})

const result = computed(() => {
  if (!debouncedLength.value || !debouncedIdeal.value) return null
  return calculateIdealSpacing(debouncedLength.value, debouncedIdeal.value)
})

function generateMarks(spacing: number, max = 200) {
  const marks: number[] = []
  let i = 1
  while (true) {
    const val = +(spacing * i).toFixed(2)
    if (val > max) break
    marks.push(val)
    i++
  }
  return marks
}

function getMarkStyle(mark: number, max = 200) {
  return { left: `${(mark / max) * 100}%` }
}

function getRow(i: number) {
  return i % 2
}
</script>

<template>
  <div class="wrap">
    <h2>Ideal Spacing</h2>

    <div class="field">
      <label>Length (cm)</label>
      <input v-model.number="length" type="number" placeholder="Enter length" />
    </div>

    <div class="field">
      <label>Ideal spacing (cm)</label>
      <input v-model.number="ideal" type="number" placeholder="Enter ideal spacing" />
    </div>

    <p v-if="error" class="error">{{ error }}</p>

    <div v-if="result && !error" class="card">

      <div class="center-block">
        <div class="center-item">
          <small>Exact</small>
          <b>{{ result.exact.toFixed(2) }}</b>
        </div>

        <div class="center-item">
          <small>Ideal</small>
          <b>{{ result.ideal }}</b>
        </div>

        <div class="center-item">
          <small>Difference</small>
          <b :class="{ plus: result.missing > 0, minus: result.missing < 0 }">
            {{ result.missing }}
          </b>
        </div>
      </div>

      <div class="grid-2">
        <div class="col">
          <small>Lower spacing</small>
          <b>{{ result.lower.spacing.toFixed(2) }}</b>

          <div class="sub">segments: {{ result.lower.segments }}</div>

          <div class="scale">
            <div class="line"></div>

            <div
              v-for="(m, i) in generateMarks(result.lower.spacing)"
              :key="m"
              class="mark"
              :style="getMarkStyle(m)"
            >
              <span :style="{ top: `${getRow(i) * -14}px` }">{{ m }}</span>
            </div>
          </div>
        </div>

        <div class="col">
          <small>Upper spacing</small>
          <b>{{ result.upper.spacing.toFixed(2) }}</b>

          <div class="sub">segments: {{ result.upper.segments }}</div>

          <div class="scale">
            <div class="line"></div>

            <div
              v-for="(m, i) in generateMarks(result.upper.spacing)"
              :key="m"
              class="mark"
              :style="getMarkStyle(m)"
            >
              <span :style="{ top: `${getRow(i) * -14}px` }">{{ m }}</span>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<style scoped>
.wrap {
  max-width: 420px;
  margin: auto;
  padding: 16px;
}

.field {
  display: flex;
  flex-direction: column;
  margin-bottom: 10px;
}

label {
  font-size: 12px;
  color: #64748b;
}

input {
  padding: 10px;
  border-radius: 10px;
  border: 1px solid #ccc;
}

.card {
  background: #f1f5f9;
  padding: 12px;
  border-radius: 12px;
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.scale {
  position: relative;
  height: 50px;
}

.line {
  position: absolute;
  top: 25px;
  height: 6px;
  width: 100%;
  background: #cbd5f5;
  border-radius: 6px;
}

.mark {
  position: absolute;
  transform: translateX(-50%);
  font-size: 8px;
}

.error {
  background: #fee2e2;
  padding: 8px;
  border-radius: 8px;
  color: red;
}

@media (max-width: 480px) {
  .mark { font-size: 7px }
}
</style>