<script setup lang="ts">
import { ref, watch, computed } from 'vue'

const length = ref<number | null>(null)

// режими
const fixedEdge = ref<number | null>(null) // один край
//const desiredEdge = ref<number | null>(null) // опціонально

// drag spacing
const spacingInput = ref(60)

type Result = {
  edgeLeft: number
  edgeRight: number
  spacing: number
  hooks: number
  segments: number
  marks: number[]
}

const SNAP_EDGES = [12, 15, 18]

const result = ref<Result | null>(null)

function round05(n: number) {
  return Math.round(n * 2) / 2
}

function getEdges(L: number, spacing: number, segments: number) {
  const used = segments * spacing
  const remainder = L - used

  let left = remainder / 2
  let right = remainder / 2

  if (fixedEdge.value !== null) {
    left = fixedEdge.value
    right = remainder - left
  }

  return { left, right }
}
const validSpacings = computed(() => {
  if (!length.value) return []

  const L = length.value
  const segments = Math.floor(L / 60)

  const list: number[] = []

  for (let s = 60; s >= 10; s -= 0.5) {
    const spacing = round05(s)

    const { left, right } = getEdges(L, spacing, segments)

    if (left >= 6 && right >= 6 && left <= 20 && right <= 20) {
      list.push(spacing)
    }
  }

  return list
})

function snapSpacing(spacing: number) {
  if (!length.value) return spacing

  const L = length.value
  const segments = Math.floor(L / 60)

  let best = spacing
  let bestScore = Infinity

  for (const s of validSpacings.value) {
    const { left } = getEdges(L, s, segments)

    const snapBonus = SNAP_EDGES.some(e => Math.abs(left - e) < 1)
      ? -5
      : 0

    const score =
      Math.abs(s - spacing) + snapBonus

    if (score < bestScore) {
      best = s
      bestScore = score
    }
  }

  return best
}

function calculate() {
  if (!length.value) return

  const L = length.value

  // 🔥 фіксуємо segments (мінімум гаків)
  const baseSegments = Math.floor(L / 60)
  if (baseSegments < 1) return

  const spacing = round05(spacingInput.value)

  let edgeLeft = 0
  let edgeRight = 0

  const used = baseSegments * spacing
  const remainder = L - used

  if (fixedEdge.value !== null) {
    edgeLeft = fixedEdge.value
    edgeRight = remainder - edgeLeft
  } else {
    edgeLeft = remainder / 2
    edgeRight = remainder / 2
  }

  // перевірка
  if (edgeLeft < 6 || edgeRight < 6) {
    result.value = null
    return
  }

  const hooks = baseSegments + 1

  const marks: number[] = []
  for (let i = 1; i <= baseSegments; i++) {
    marks.push(round05(i * spacing))
  }
  if (!validSpacings.value.includes(spacing)) {
    result.value = null
    return
  }

  result.value = {
    edgeLeft: round05(edgeLeft),
    edgeRight: round05(edgeRight),
    spacing,
    hooks,
    segments: baseSegments,
    marks
  }
}/*
function getScore(r: Result) {
  return (60 - r.spacing) * 10 + Math.abs(r.edgeLeft - r.edgeRight)
}*/

// drag → snapping
const spacingDrag = computed({
  get: () => spacingInput.value,
  set: (v: number) => {
    //spacingInput.value = round05(v)
    const snapped = snapSpacing(round05(v))
    spacingInput.value = snapped
  }
})

// live
watch([length, fixedEdge, spacingInput], calculate)
</script>

<template>
  <div class="wrap">
    <h1>Ränna Pro</h1>

    <input
      v-model.number="length"
      type="number"
      placeholder="Längd (cm)"
    >

    <input
      v-model.number="fixedEdge"
      type="number"
      placeholder="Fast kant (valfri)"
    >

    <!-- drag spacing -->
    <div class="slider">
      <label>Avstånd: {{ spacingDrag }}</label>
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
          <small>Vänster</small>
          <b>{{ result.edgeLeft }}</b>
        </div>

        <div>
          <small>Avstånd</small>
          <b>{{ result.spacing }}</b>
        </div>

        <div>
          <small>Höger</small>
          <b>{{ result.edgeRight }}</b>
        </div>

        <div>
          <small>Krokar</small>
          <b>{{ result.hooks }}</b>
        </div>
      </div>

      <!-- marks -->
      <div class="marks">
        <span
          v-for="m in result.marks"
          :key="m"
        >
          {{ m }}
        </span>
      </div>

      <!-- графічна лінія -->
      <div class="line">
        <div
          v-for="m in result.marks"
          :key="m"
          class="dot"
          :style="{ left: (m / length!) * 100 + '%' }"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.wrap {
  max-width: 380px;
  margin: auto;
  padding: 16px;
  font-family: system-ui;
}

h1 {
  text-align: center;
  margin-bottom: 12px;
}

input {
  width: 100%;
  padding: 14px;
  margin-bottom: 10px;
  border-radius: 12px;
  border: 1px solid #ccc;
  font-size: 16px;
}

.slider {
  margin: 10px 0;
}

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

.marks {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  font-size: 12px;
}

.line {
  margin-top: 14px;
  height: 6px;
  background: #cbd5f5;
  border-radius: 10px;
  position: relative;
}

.dot {
  position: absolute;
  top: -4px;
  width: 10px;
  height: 10px;
  background: #2563eb;
  border-radius: 50%;
  transform: translateX(-50%);
}
</style>