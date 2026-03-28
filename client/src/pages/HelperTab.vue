<script setup lang="ts">
import { ref } from 'vue'

const length = ref<number | null>(null)

type Result = {
  edge: number
  spacing: number
  segments: number
  hooks: number
  pattern: string
  marks: number[]
}

const result = ref<Result | null>(null)

const IDEAL_EDGE = 15
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
      Math.abs(edge - IDEAL_EDGE) + (isPriority ? 0 : 100)

    if (score < bestScore) {
      const marks: number[] = []

      for (let i = 1; i <= segments; i++) {
        marks.push(round05(i * spacing))
      }

      const patternParts = [
        edge.toFixed(2),
        ...Array(segments - 1).fill(spacing.toFixed(1)),
        edge.toFixed(2)
      ]

      best = {
        edge: round05(edge),
        spacing,
        segments,
        hooks: segments + 1,
        pattern: patternParts.join(' — '),
        marks
      }

      bestScore = score
    }
  }

  result.value = best
}
</script>

<template>
  <div class="container">
    <h1>Ränna Calculator</h1>

    <input
      v-model.number="length"
      type="number"
      placeholder="Length (cm)"
    >

    <button @click="calculate">
      Calculate
    </button>

    <div 
      v-if="result" 
      class="card"
    >
      <div class="row">
        <span>Edge:</span>
        <b>{{ result.edge }} cm</b>
      </div>

      <div class="row">
        <span>Spacing:</span>
        <b>{{ result.spacing }} cm</b>
      </div>

      <div class="row">
        <span>Hooks:</span>
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
  margin-bottom: 12px;
  border-radius: 10px;
  border: 1px solid #ccc;
  font-size: 16px;
}

button {
  width: 100%;
  padding: 12px;
  border-radius: 10px;
  border: none;
  background: #2563eb;
  color: white;
  font-size: 16px;
  cursor: pointer;
  transition: 0.2s;
}

button:hover {
  background: #1d4ed8;
}

.card {
  margin-top: 20px;
  padding: 16px;
  border-radius: 14px;
  background: #f8fafc;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.pattern {
  margin-top: 12px;
  font-family: monospace;
  font-size: 13px;
  word-break: break-all;
  color: #334155;
}

.marks {
  margin-top: 12px;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.mark {
  background: #e2e8f0;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
}
</style>