<script setup lang="ts">
import { ref, watch } from 'vue'

const length = ref<number | null>(null)
const desiredEdge = ref(15)

type Result = {
  edge: number
  spacing: number
  hooks: number
  pattern: string
  marks: number[]
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

    // кількість гаків
    const hooks = Math.floor(L / spacing) + 1
    const gaps = hooks - 1

    const used = gaps * spacing
    const remainder = L - used
    const edge = remainder / 2

    if (edge < MIN_EDGE) continue

    const isPriority = edge >= PRIORITY_MIN && edge <= PRIORITY_MAX

    const score =
      Math.abs(edge - desiredEdge.value) +
      (isPriority ? 0 : 100)

    if (score < bestScore) {
      const marks: number[] = []

      for (let i = 1; i < hooks; i++) {
        marks.push(round05(i * spacing))
      }

      const patternParts = [
        edge.toFixed(2),
        ...Array(gaps - 1).fill(spacing.toFixed(1)),
        edge.toFixed(2)
      ]

      best = {
        edge: round05(edge),
        spacing,
        hooks,
        pattern: patternParts.join(' — '),
        marks
      }

      bestScore = score
    }
  }

  result.value = best
}

// авто-перерахунок
watch([length, desiredEdge], calculate)
</script>

<template>
  <div class="container">
    <h1>Ränna Kalkylator</h1>

    <input
      v-model.number="length"
      type="number"
      placeholder="Längd (cm)"
    >

    <input
      v-model.number="desiredEdge"
      type="number"
      placeholder="Önskad kant (cm)"
    >

    <div v-if="result" class="card">
      <div class="row">
        <span>Kant (edge):</span>
        <b>{{ result.edge }} cm</b>
      </div>

      <div class="row">
        <span>Avstånd:</span>
        <b>{{ result.spacing }} cm</b>
      </div>

      <div class="row">
        <span>Totalt krokar:</span>
        <b>{{ result.hooks }}</b>
      </div>

      <div class="pattern">
        {{ result.pattern }}
      </div>

      <div class="marks">
        <span
          v-for="m in result.marks"
          :key="m"
          class="mark"
        >
          {{ m }}
        </span>
      </div>

      <!-- проста візуалізація -->
      <div class="line">
        <div
          v-for="m in result.marks"
          :key="'line-' + m"
          class="dot"
          :style="{ left: (m / length!) * 100 + '%' }"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 420px;
  margin: 40px auto;
  padding: 20px;
  font-family: system-ui;
}

h1 {
  margin-bottom: 16px;
}

input {
  width: 100%;
  padding: 12px;
  margin-bottom: 10px;
  border-radius: 10px;
  border: 1px solid #ccc;
}

.card {
  margin-top: 16px;
  padding: 16px;
  border-radius: 14px;
  background: #f8fafc;
}

.row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
}

.pattern {
  margin-top: 10px;
  font-family: monospace;
  font-size: 13px;
  word-break: break-all;
}

.marks {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.mark {
  background: #e2e8f0;
  padding: 4px 6px;
  border-radius: 6px;
  font-size: 12px;
}

.line {
  margin-top: 16px;
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