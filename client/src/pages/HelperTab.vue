<script setup lang="ts">
import { ref, watch, computed } from 'vue'

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

const SNAP_EDGES = [12, 15, 18]
const result = ref<Result | null>(null)

function round05(n: number) {
  return Math.round(n * 2) / 2
}

function getSegments(L: number, spacing: number) {
  return Math.floor(L / spacing)
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
  //const segments = Math.floor(L / 60)
  //const segments = getSegments(L)
  const list: number[] = []

  for (let s = 60; s >= 10; s -= 0.5) {
    const spacing = round05(s)
    const segments = getSegments(L, spacing)
    if (segments < 1) continue
    const { left, right } = getEdges(L, spacing, segments)

    if (left >= 6 && right >= 6 && left <= 20 && right <= 20) {
      list.push(spacing)
    }
  }

  return list
})

function snapSpacing(spacing: number) {
  if (length.value === null || length.value === undefined) return spacing

  //const L = length.value
  //const segments = Math.floor(L / 60)

  let best = spacing
  let bestScore = Infinity

  for (const s of validSpacings.value) {
    const L = length.value
    const segments = getSegments(L, s)
    const { left } = getEdges(L, s, segments)

    const snapBonus = SNAP_EDGES.some(e => Math.abs(left - e) < 1)
      ? -5
      : 0

    const score = Math.abs(s - spacing) + snapBonus

    if (score < bestScore) {
      best = s
      bestScore = score
    }
  }

  return best
}
/*
function setBestSpacing() {
  if (!validSpacings.value.length || !validSpacings.value[0]) return
  
  spacingInput.value = validSpacings.value[0]
}
*/
function findBestSpacingFixedSegments() {
  if (!length.value) return

  const L = length.value
  const baseSegments = getSegments(L, spacingInput.value)

  let best = spacingInput.value
  let bestScore = Infinity

  for (let s = 60; s >= 10; s -= 0.5) {
    const spacing = round05(s)

    const { left, right } = getEdges(L, spacing, baseSegments)

    if (left < 6 || right < 6 || left > 20 || right > 20) continue

    const score = Math.abs(spacing - 15)

    if (score < bestScore) {
      best = spacing
      bestScore = score
    }
  }

  spacingInput.value = best
}

function calculate() {
  if (!length.value) return

  const L = length.value
  
  const spacing = spacingInput.value
  const segments = getSegments(L, spacing)
  if (segments < 1) {
    result.value = null
    return
  }
  const { left, right } = getEdges(L, spacing, segments)
  if (
    left < 6 || right < 6 ||
    left > 20 || right > 20
  ) {
    result.value = null
    return
  }

  const marks: number[] = []
  for (let i = 1; i <= segments; i++) {
    marks.push(round05(i * spacing))
  }
  if (result.value === null) {
    console.log('Invalid spacing:', spacing)
  }
  /*
  result.value = {
    edgeLeft: round05(edgeLeft),
    edgeRight: round05(edgeRight),
    spacing,
    hooks,
    segments: baseSegments,
    marks
  }*/
 result.value = {
    edgeLeft: round05(left),
    edgeRight: round05(right),
    spacing,
    hooks: segments + 1,
    segments,
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
    isManual.value = true
    //spacingInput.value = round05(v)
    const snapped = snapSpacing(round05(v))
    if (!validSpacings.value.includes(snapped)) return
    spacingInput.value = snapped
  }
})

function onLineDrag(e: MouseEvent | TouchEvent) {
  if (!length.value || !validSpacings.value.length) return

  isManual.value = true

  const el = (e.currentTarget as HTMLElement)
  const rect = el.getBoundingClientRect()
  let clientX: number

  if (e instanceof TouchEvent) {
    if (!e.touches || e.touches.length === 0) return
    const touch = e.touches[0]
    if (!touch) return
    clientX = touch.clientX
  } else if (e instanceof MouseEvent) {
    clientX = e.clientX
  } else {
    return
  }
  //const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX


  //const percent = (clientX - rect.left) / rect.width
  const percent = Math.min(1, Math.max(0, (clientX - rect.left) / rect.width))
    if (!validSpacings.value.length) {
    console.warn('validSpacings is empty, cannot drag')
    return
  }
  const min = validSpacings.value[validSpacings.value.length - 1]
  const max = validSpacings.value[0]
   if (min === undefined || max === undefined) {
    console.warn('validSpacings is empty, cannot drag')
    return
  }
  let spacing = min + percent * (max - min)

  spacing = snapSpacing(round05(spacing))
  spacingInput.value = spacing
  //let spacing = percent * 60
  //spacing = round05(spacing)

  //spacingInput.value = snapSpacing(spacing)
}
function getDotStyle(mark: number) {
  if (!length.value || mark === undefined) {
    console.warn('length is null, cannot position mark')
    return { left: '0%' }
  }
  return { left: (mark / length.value) * 100 + '%' }
}
// live
/*
watch([length, fixedEdge, spacingInput], () => {
  if (!isManual.value) {
    setBestSpacing()
  }
  setBestSpacing()
  calculate()
})*/
watch([length, fixedEdge/*, validSpacings*/], () => {
  if (!isManual.value) {
    //setBestSpacing()
    findBestSpacingFixedSegments()
  }
  calculate()
})

watch(spacingInput, calculate)
</script>

<template>
  <div class="wrap">
    <h1>Ränna hook megure</h1>

    <input
      v-model.number="length"
      type="number"
      placeholder="Längd/ Long (cm)"
    >

    <input
      v-model.number="fixedEdge"
      type="number"
      placeholder="Fast kant (valfri)/ fixed edge"
    >

    <!-- drag spacing -->
    <div class="slider">
      <label>Avstånd/Space between: {{ spacingDrag }}</label>
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
          <small>Vänster/Left</small>
          <b :class="{ good: result.edgeLeft >= 10 && result.edgeLeft <= 20 }">{{ result.edgeLeft }}</b>
        </div>

        <div>
          <small>Avstånd/Space between</small>
          <b>{{ result.spacing }}</b>
        </div>

        <div>
          <small>Höger / Right</small>
          <b>{{ result.edgeRight }}</b>
        </div>

        <div>
          <small>Krokar / Hooks</small>
          <b>{{ result.hooks }}</b>
        </div>
      </div>

      <!-- marks -->
      <div class="marks">
        <span
          v-for="m in result?.marks || []"
          :key="m"
        >
          {{ m }}
        </span>
      </div>

      <div 
        class="line"
        @mousedown="onLineDrag"
        @mousemove="e => e.buttons && onLineDrag(e)"
        @touchstart="onLineDrag"
        @touchmove="onLineDrag"
      >
        <div
          v-for="m in result?.marks || []"
          :key="m"
          class="dot"
          :style="getDotStyle(m)"
        />
        <!--:style="{ left: (m / length!) * 100 + '%' }"-->
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
.good {
  color: #16a34a;
  font-weight: 700;
}
input[type="range"] {
  width: 100%;
  height: 36px;
  touch-action: pan-x;
}

.line {
  height: 12px;
  cursor: pointer;
}

.dot {
  width: 14px;
  height: 14px;
}

@media (max-width: 480px) {
  .wrap {
    padding: 12px;
  }

  input {
    font-size: 18px;
    padding: 16px;
  }

  .grid b {
    font-size: 20px;
  }
}
</style>