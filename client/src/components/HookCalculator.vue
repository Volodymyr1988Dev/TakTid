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
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
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

function validate() {
  const len = sanitizeNumber(length.value)
  const edge = sanitizeNumber(fixedEdge.value)

  if (!len) return (error.value = t('hook.errors.lengthNumber')), false
  if (len < 60) return (error.value = t('hook.errors.length')), false

  if (edge !== null && (edge < 0 || edge > len / 2)) {
    return (error.value = t('hook.errors.edge')), false
  }

  error.value = null
  return true
}

const validSpacings = computed(() => {
  const len = sanitizeNumber(length.value)
  if (!len) return []

  const list: number[] = []

  for (let s = 60; s >= 50; s -= 0.5) {
    const spacing = round05(s)
    const segments = getSegments(len, spacing)
    if (segments < 1) continue

    const { left, right } = getEdges(len, spacing, segments, fixedEdge.value)

    if (isValidEdge(left, right)) {
      list.push(spacing)
    }
  }

  return list
})

function calculate() {
  const len = sanitizeNumber(length.value)
  const spacing = sanitizeNumber(spacingInput.value)

  if (!len || !spacing) return

  const segments = getSegments(len, spacing)
  if (segments < 1) return

  const { left, right } = getEdges(len, spacing, segments, fixedEdge.value)

  if (!isValidEdge(left, right)) return

  result.value = {
    edgeLeft: left,
    edgeRight: right,
    spacing,
    hooks: segments + 1,
    segments,
    marks: Array.from({ length: segments }, (_, i) =>
      round05((i + 1) * spacing)
    )
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
    const snapped = round05(v)

    //if (!validSpacings.value.includes(snapped)) return
    //spacingInput.value = snapped
    const nearest = validSpacings.value.reduce((prev, curr) =>
      Math.abs(curr - snapped) < Math.abs(prev - snapped) ? curr : prev
    )

    spacingInput.value = nearest
  }
})

watch([length, fixedEdge, spacingInput], () => {
  if (timer) clearTimeout(timer)

  timer = setTimeout(() => {
    if (!validate()) return

    if (!isManual.value) autoCalculate()
    calculate()
  }, 300)
})

function getLabelRow(index: number) {
  const total = result.value?.marks.length ?? 0
  if (total <= 10) return 0
  if (total <= 20) return index % 2
  return index % 3
}

function getDotStyle(mark: number) {
  if (!length.value) return { left: '0%' }
  return { left: `${(mark / length.value) * 100}%` }
}

function getEdgeStyle(edge: number) {
  if (!length.value) return { left: '0%' }
  return { left: `${(edge / length.value) * 100}%` }
}
</script>

<template>
  <div class="wrap">
    <h1>{{ t('hook.title') }}</h1>

    <div class="field">
      <label>{{ t('hook.length') }}</label>
      <input 
        v-model.number="length" 
        type="number" 
        :placeholder="t('hook.lengthPlaceholder')" />
    </div>

    <div class="field">
      <label>{{ t('hook.fixedEdge') }}</label>
      <input 
        v-model.number="fixedEdge" 
        type="number" 
        :placeholder="t('hook.fixedEdgePlaceholder')" />
    </div>

    <p v-if="error" class="error">{{ error }}</p>

    <div class="slider">
      <label>{{ t('hook.spacing') }}: {{ spacingDrag }} cm</label>
      <input v-model.number="spacingDrag" type="range" min="50" max="60" step="0.5" />
    </div>

    <div v-if="result" class="card">
      <div class="grid">
        <div><small>Left edge</small><b>{{ result.edgeLeft }}</b></div>
        <div><small>Right edge</small><b>{{ result.edgeRight }}</b></div>
        <div><small>Spacing</small><b>{{ result.spacing }}</b></div>
        <div><small>Hooks</small><b>{{ result.hooks }}</b></div>
      </div>

      <div class="line">
        <div class="edge" :style="getEdgeStyle(result.edgeLeft)" />
        <div class="edge" :style="getEdgeStyle(length! - result.edgeRight)" />

        <div
          v-for="(m, i) in result.marks"
          :key="m"
          class="dot-wrapper"
          :style="getDotStyle(m)"
        >
          <div class="dot" />
          <span class="dot-value" :class="'row-' + getLabelRow(i)">
            {{ m }}
          </span>
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

.error {
  background: #fee2e2;
  color: #b91c1c;
  padding: 8px;
  border-radius: 8px;
}

.line {
  margin-top: 40px;
  height: 10px;
  background: #cbd5f5;
  border-radius: 10px;
  position: relative;
}

.dot-wrapper {
  position: absolute;
  transform: translateX(-50%);
}

.dot {
  width: 10px;
  height: 10px;
  background: #2563eb;
  border-radius: 50%;
}

.dot-value {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 10px;
}

.row-0 { top: -12px; }
.row-1 { top: -24px; }
.row-2 { top: -36px; }

@media (max-width: 480px) {
  .dot-value { font-size: 8px; }
}
</style>