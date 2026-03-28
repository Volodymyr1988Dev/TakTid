<script setup lang="ts">
import { ref, watch } from 'vue'

const length = ref<number | null>(null)
const desiredEdge = ref(15)

type Result = {
  edge: number
  spacing: number
  segments: number
  hooks: number
  pattern: string
  marks2m: number[]
}

const result = ref<Result | null>(null)

const MIN_EDGE = 6
const PRIORITY_MIN = 10
const PRIORITY_MAX = 20

function round05(n: number): number {
  return Math.round(n * 2) / 2
}

function calculate() {
  if (!length.value) return

  const L = length.value

  let best: Result | null = null
  let bestScore = Infinity

  for (let spacing = 60; spacing >= 10; spacing -= 0.5) {
    spacing = round05(spacing)

    const segments = Math.floor(L / spacing)
    if (segments < 1) continue

    const used = segments * spacing
    const remainder = L - used
    const edge = remainder / 2

    if (edge < MIN_EDGE) continue

    const isPriority = edge >= PRIORITY_MIN && edge <= PRIORITY_MAX

    const score =
      Math.abs(edge - desiredEdge.value) +
      (isPriority ? 0 : 100)

    if (score < bestScore) {
      // hooks
      const hooks = segments + 1

      // pattern
      const patternParts = [
        edge.toFixed(2),
        ...Array(segments - 1).fill(spacing.toFixed(1)),
        edge.toFixed(2)
      ]

      // marks every 2m (як ти тепер хочеш)
      const marks2m: number[] = []
      for (let i = 200; i < L; i += 200) {
        marks2m.push(i)
      }

      best = {
        edge: round05(edge),
        spacing,
        segments,
        hooks,
        pattern: patternParts.join(' — '),
        marks2m
      }

      bestScore = score
    }
  }

  result.value = best
}

// авто
watch([length, desiredEdge], calculate)
</script>

<template>
  <div class="container">
    <h1>Ränna</h1>

    <input
      v-model.number="length"
      type="number"
      placeholder="cm"
    >

    <input
      v-model.number="desiredEdge"
      type="number"
      placeholder="edge"
    >

    <div 
      v-if="result" 
      class="card"
    >
      <div class="grid">
        <div>
          <small>Kant</small>
          <b>{{ result.edge }}</b>
        </div>

        <div>
          <small>Avstånd</small>
          <b>{{ result.spacing }}</b>
        </div>

        <div>
          <small>Krokar</small>
          <b>{{ result.hooks }}</b>
        </div>
      </div>

      <div class="pattern">
        {{ result.pattern }}
      </div>

      <div class="marks">
        <span
          v-for="m in result.marks2m"
          :key="m"
        >
          {{ m }}
        </span>
      </div>

      <!-- мобільна лінія -->
      <div class="line">
        <div
          v-for="m in result.marks2m"
          :key="m"
          class="dot"
          :style="{ left: (m / length!) * 100 + '%' }"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 360px;
  margin: 0 auto;
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
  margin-bottom: 8px;
  border-radius: 12px;
  border: 1px solid #ccc;
  font-size: 18px;
}

.card {
  margin-top: 12px;
  padding: 14px;
  border-radius: 16px;
  background: #f1f5f9;
}

.grid {
  display: flex;
  justify-content: space-between;
  text-align: center;
}

.grid small {
  display: block;
  font-size: 12px;
  color: #64748b;
}

.grid b {
  font-size: 20px;
}

.pattern {
  margin-top: 10px;
  font-family: monospace;
  font-size: 12px;
}

.marks {
  margin-top: 8px;
  display: flex;
  justify-content: space-between;
  font-size: 12px;
}

.line {
  margin-top: 12px;
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