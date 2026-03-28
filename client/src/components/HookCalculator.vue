<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import {
  round05,
  getSegments,
  getEdges,
  isValidEdge,
  findBestSpacingAuto
} from '../components/helpers/utils/hookMath'

const length = ref<number | null>(null)
const fixedEdge = ref<number | null>(null)

const spacingInput = ref(60)
const isManual = ref(false)

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

  //const min = validSpacings.value.at(-1)!
  const min = validSpacings.value[validSpacings.value.length - 1]
  const max = validSpacings.value[0]
  if (min === undefined || max === undefined) {
    console.warn('validSpacings is empty, cannot drag')
    return
  }
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
    <h2>Hooks calculator</h2>

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
          class="dot"
          :style="getDotStyle(m)"
        />
      </div>
    </div>
  </div>
</template>