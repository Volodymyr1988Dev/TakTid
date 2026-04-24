<script setup lang="ts">
import { ref, watch, computed } from 'vue'

import {
  round05,
  getSegments,
  getEdges,
  isValidEdge,
  findBestSpacingAuto
} from './helpers/utils/hookMath'

import { sanitizeNumber } from './helpers/helpers'

type Result = {
  edgeLeft: number
  edgeRight: number
  spacing: number
  hooks: number
  segments: number
  marks: number[]
}

const length = ref<number | null>(null)
const fixedEdge = ref<number | null>(null)

const spacingInput = ref(60)
const isManual = ref(false)

const result = ref<Result | null>(null)

const error = ref<string | null>(null)
let timer: ReturnType<typeof setTimeout> | null = null

function validate(): boolean {
  const len = sanitizeNumber(length.value)

  if (!len) {
    error.value = 'Length must be a number'
    return false
  }

  if (len < 60) {
    error.value = 'Length must be at least 60 cm'
    return false
  }

  error.value = null
  return true
}

function calculate() {
  const len = sanitizeNumber(length.value)
  const spacing = sanitizeNumber(spacingInput.value)

  if (!len || !spacing) return

  const segments = getSegments(len, spacing)
  if (segments < 1) return

  const { left, right } = getEdges(
    len,
    spacing,
    segments,
    fixedEdge.value
  )

  if (!isValidEdge(left, right)) return

  const marks = Array.from(
    { length: segments },
    (_, i) => round05((i + 1) * spacing)
  )

  result.value = {
    edgeLeft: left,
    edgeRight: right,
    spacing,
    hooks: segments + 1,
    segments,
    marks
  }
}

function autoCalculate() {
  const len = sanitizeNumber(length.value)
  if (!len) return

  const best = findBestSpacingAuto(len, fixedEdge.value)
  if (best) spacingInput.value = best
}

const spacingDrag = computed({
  get: () => spacingInput.value,
  set: (v: number) => {
    isManual.value = true
    spacingInput.value = round05(v)
  }
})

watch([length, fixedEdge, spacingInput], () => {
  if (timer) clearTimeout(timer)

  timer = setTimeout(() => {
    if (!validate()) return

    if (!isManual.value) {
      autoCalculate()
    }

    calculate()
  }, 400)
})

function getDotStyle(mark: number, lengthVal: number) {
  return {
    left: `${(mark / lengthVal) * 100}%`
  }
}

function getEdgeStyle(edge: number, lengthVal: number) {
  return {
    left: `${(edge / lengthVal) * 100}%`
  }
}
</script>

<template>
  <div>
    <h1>Hook Calculator</h1>

    <p v-if="error" class="error">{{ error }}</p>

    <input v-model.number="length" type="number" placeholder="Length (cm)" />
    <input v-model.number="fixedEdge" type="number" placeholder="Fixed edge" />

    <div class="slider">
      <label>Spacing: {{ spacingDrag }}</label>
      <input v-model.number="spacingDrag" type="range" min="10" max="60" step="0.5" />
    </div>

    <div v-if="result" class="card">
      <div class="grid">
        <div><small>Left</small><b>{{ result.edgeLeft }}</b></div>
        <div><small>Spacing</small><b>{{ result.spacing }}</b></div>
        <div><small>Right</small><b>{{ result.edgeRight }}</b></div>
        <div><small>Hooks</small><b>{{ result.hooks }}</b></div>
      </div>

      <div class="line">
        <div
          class="edge edge-left"
          :style="getEdgeStyle(result.edgeLeft, length!)"
        />

        <div
          class="edge edge-right"
          :style="getEdgeStyle(length! - result.edgeRight, length!)"
        />

        <div
          v-for="m in result.marks"
          :key="m"
          class="dot-wrapper"
          :style="getDotStyle(m, length!)"
        >
          <div class="dot" />
          <span class="dot-value">{{ m }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.error {
  color: red;
  margin-bottom: 10px;
}

.card {
  margin-top: 20px;
  padding: 12px;
  background: #f1f5f9;
  border-radius: 12px;
}

.grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.line {
  margin-top: 40px;
  height: 10px;
  background: #cbd5f5;
  border-radius: 8px;
  position: relative;
}

.dot-wrapper {
  position: absolute;
  top: -10px;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.dot {
  width: 10px;
  height: 10px;
  background: #2563eb;
  border-radius: 50%;
}

.dot-value {
  font-size: 10px;
}
</style>