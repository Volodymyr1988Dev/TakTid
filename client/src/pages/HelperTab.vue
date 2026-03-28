<script setup lang="ts">
import { ref, watch, computed } from 'vue'

import {
  round05,
  getSegments,
  getEdges,
  isValidEdge,
  findBestSpacingAuto
} from '../components/helpers/utils/hookMath'

//import HookCalculator from '../components/HookCalculator.vue'
import IdealSpacing from '../components/IdealSpacing.vue'

const length = ref<number | null>(null)
const fixedEdge = ref<number | null>(null)

const spacingInput = ref(60)
const isManual = ref(false)

const mode = ref<'none' | 'hooks' | 'spacing'>('none')

type Result = {
  edgeLeft: number
  edgeRight: number
  spacing: number
  hooks: number
  segments: number
  marks: number[]
}

const result = ref<Result | null>(null)

const validSpacings = computed(() => {
  if (!length.value) return []

  const list: number[] = []

  for (let s = 60; s >= 10; s -= 0.5) {
    const spacing = round05(s)
    const segments = getSegments(length.value, spacing)
    if (segments < 1) continue

    const { left, right } = getEdges(
      length.value,
      spacing,
      segments,
      fixedEdge.value
    )

    if (isValidEdge(left, right)) {
      list.push(spacing)
    }
  }

  return list
})

function calculate() {
  if (!length.value) {
    result.value = null
    return
  }

  const spacing = spacingInput.value
  const segments = getSegments(length.value, spacing)

  if (segments < 1) {
    result.value = null
    return
  }

  const { left, right } = getEdges(
    length.value,
    spacing,
    segments,
    fixedEdge.value
  )

  if (!isValidEdge(left, right)) {
    result.value = null
    return
  }

  const marks: number[] = []

  for (let i = 1; i <= segments; i++) {
    marks.push(round05(i * spacing))
  }

  result.value = {
    edgeLeft: round05(left),
    edgeRight: round05(right),
    spacing,
    hooks: segments + 1,
    segments,
    marks
  }
}

function autoCalculate() {
  if (!length.value) return

  const best = findBestSpacingAuto(length.value, fixedEdge.value)

  if (best != null) {
    spacingInput.value = best
  }
}

const spacingDrag = computed({
  get: () => spacingInput.value,
  set: (v: number) => {
    isManual.value = true

    const snapped = round05(v)

    if (!validSpacings.value.includes(snapped)) return

    spacingInput.value = snapped
  }
})

function onLineDrag(e: MouseEvent | TouchEvent) {
  if (!length.value || !validSpacings.value.length) return

  isManual.value = true

  const el = e.currentTarget as HTMLElement
  const rect = el.getBoundingClientRect()

  let clientX = 0

  if (e instanceof TouchEvent) {
    if (!e.touches.length) return
    const touch = e.touches[0]
    if (!touch) return
    clientX = touch.clientX
  } else {
    clientX = e.clientX
  }

  const percent = Math.min(
    1,
    Math.max(0, (clientX - rect.left) / rect.width)
  )

  const min = validSpacings.value[validSpacings.value.length - 1]
  const max = validSpacings.value[0]

  if (min === undefined || max === undefined) return

  let spacing = min + percent * (max - min)

  spacing = round05(spacing)

  if (!validSpacings.value.includes(spacing)) return

  spacingInput.value = spacing
}

function getDotStyle(mark: number) {
  if (!length.value) return { left: '0%' }

  return {
    left: `${(mark / length.value) * 100}%`
  }
}

const rulerMarks = computed(() => {
  if (!length.value) return []
  const L = length.value
  const steps = 4 //10
  const step = Math.ceil(L / steps / 10) * 10
  const arr: number[] = []

  for (let i = 0; i <= length.value; i += step) {
    arr.push(i)
  }

  return arr
})

function getRulerStyle(mark: number) {
  if (!length.value) return { left: '0%' }

  return {
    left: `${(mark / length.value) * 100}%`
  }
}

watch([length, fixedEdge], () => {
  if (!isManual.value) {
    autoCalculate()
  }
  calculate()
})

watch(spacingInput, calculate)
</script>

<template>
  <div class="wrap">
    <div class="tabs">
      <button
        :class="{ active: mode === 'hooks' }"
        @click="mode = 'hooks'"
      >
        Hooks
      </button>

      <button
        :class="{ active: mode === 'spacing' }"
        @click="mode = 'spacing'"
      >
        Spacing
      </button>
    </div>

    <!-- 🔥 HOOKS -->
    <div v-if="mode === 'hooks'">
      <h1>Ränna hook measure</h1>

      <input 
        v-model.number="length" 
        type="number" 
        placeholder="Length (cm)" 
      >

      <input
        v-model.number="fixedEdge"
        type="number"
        placeholder="Fixed edge (optional)"
      >

      <div class="slider">
        <label>Spacing: {{ spacingDrag }}</label>
        <input
          v-model.number="spacingDrag"
          type="range"
          min="10"
          max="60"
          step="0.5"
        >
      </div>

      <div 
        v-if="result" 
        class="card"
      >
        <div class="grid">
          <div>
            <small>Left</small>
            <b>{{ result.edgeLeft }}</b>
          </div>

          <div>
            <small>Spacing</small>
            <b>{{ result.spacing }}</b>
          </div>

          <div>
            <small>Right</small>
            <b>{{ result.edgeRight }}</b>
          </div>

          <div>
            <small>Hooks</small>
            <b>{{ result.hooks }}</b>
          </div>
        </div>

        <div class="ruler">
          <div
            v-for="m in rulerMarks"
            :key="m"
            class="ruler-mark"
            :style="getRulerStyle(m)"
          >
            <span>{{ m }}</span>
          </div>
        </div>
        <div
          class="line"
          @mousedown="onLineDrag"
          @mousemove="e => e.buttons && onLineDrag(e)"
          @touchstart="onLineDrag"
          @touchmove="onLineDrag"
        >
          <div
            v-for="m in result.marks"
            :key="m"
            class="dot-wrapper"
            :style="getDotStyle(m)"
          >
            <span class="dot-value">{{ m }}</span>
            <div class="dot" />
          </div>
        </div>
      </div>
    </div>

    <!-- 🔥 SPACING -->
    <IdealSpacing v-if="mode === 'spacing'" />
  </div>
</template>

<style scoped>
.wrap {
  max-width: 420px;
  margin: auto;
  padding: 16px;
  font-family: system-ui;
}

.tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 14px;
}

.tabs button {
  flex: 1;
  padding: 12px;
  border-radius: 12px;
  border: none;
  background: #e2e8f0;
  font-weight: 600;
  cursor: pointer;
}

.tabs button.active {
  background: #2563eb;
  color: white;
}

/* INPUT */
input {
  width: 100%;
  padding: 14px;
  margin-bottom: 10px;
  border-radius: 12px;
  border: 1px solid #ccc;
  font-size: 16px;
}

/* CARD */
.card {
  margin-top: 12px;
  padding: 14px;
  border-radius: 16px;
  background: #f1f5f9;
}

.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  text-align: center;
}

.grid small {
  display: block;
  font-size: 11px;
  color: #64748b;
}

.grid b {
  font-size: 18px;
}

.ruler {
  position: relative;
  height: 20px;
  margin-top: 12px;
  border-bottom: 2px solid #94a3b8;
}

.ruler-mark {
  position: absolute;
  bottom: 0;
  transform: translateX(-50%);
  font-size: 10px;
}

.ruler-mark::before {
  content: '';
  display: block;
  width: 1px;
  height: 8px;
  background: #475569;
  margin: auto;
}

.line {
  margin-top: 10px;
  height: 12px;
  background: #cbd5f5;
  border-radius: 10px;
  position: relative;
  cursor: pointer;
}

.dot {
  position: absolute;
  top: -4px;
  width: 14px;
  height: 14px;
  background: #2563eb;
  border-radius: 50%;
  transform: translateX(-50%);
}
.plus {
  color: #16a34a;
}

.minus {
  color: #dc2626;
}
.dot-wrapper {
  position: absolute;
  top: -18px;
  transform: translateX(-50%);
  text-align: center;
}

.dot-value {
  font-size: 10px;
  color: #1e293b;
  display: block;
  margin-bottom: 2px;
}
</style>