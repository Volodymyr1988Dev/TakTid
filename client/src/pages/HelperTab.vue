<script setup lang="ts">
import { ref } from 'vue'

const length = ref<number | null>(null)
const customEdge = ref<number | null>(null)

const result = ref<{
  edgeLeft: number
  edgeRight: number
  spacing: number
  segments: number
  pattern: string
  marks: number[]
} | null>(null)

function round05(num: number) {
  return Math.round(num * 2) / 2
}

function calculate() {
  if (!length.value) return

  const L = length.value

  let best: any = null

  const edgeMin = customEdge.value ?? 10
  const edgeMax = customEdge.value ?? 20

  for (let edge = edgeMin; edge <= edgeMax; edge += 0.01) {
    if (!customEdge.value && edge < 10) continue

    const usable = L - edge * 2
    if (usable <= 0) continue

    const segments = Math.ceil(usable / 60)

    let spacing = usable / segments
    spacing = round05(spacing)

    if (spacing > 60) continue

    if (!best || spacing > best.spacing) {
      best = {
        edgeLeft: edge,
        edgeRight: edge,
        spacing,
        segments
      }
    }
  }

  // fallback (edge >= 6)
  if (!best && !customEdge.value) {
    for (let edge = 6; edge <= 20; edge += 0.01) {
      const usable = L - edge * 2
      if (usable <= 0) continue

      const segments = Math.ceil(usable / 60)

      let spacing = usable / segments
      spacing = round05(spacing)

      if (spacing > 60) continue

      if (!best || spacing > best.spacing) {
        best = {
          edgeLeft: edge,
          edgeRight: edge,
          spacing,
          segments
        }
      }
    }
  }

  if (!best) return

  // pattern
  const parts = [
    best.edgeLeft.toFixed(1),
    ...Array(best.segments - 1).fill(best.spacing.toFixed(1)),
    best.edgeRight.toFixed(1)
  ]

  // marks every 2m (200cm)
  const marks: number[] = []
  for (let i = 200; i < L; i += 200) {
    marks.push(i)
  }

  result.value = {
    ...best,
    pattern: parts.join(' — '),
    marks
  }
}
</script>

<template>
  <div class="helpers">
    <h2>Ränna Calculator</h2>

    <input
      v-model.number="length"
      type="number"
      placeholder="Length (cm)"
    >

    <input
      v-model.number="customEdge"
      type="number"
      placeholder="Custom edge (optional)"
    >

    <button @click="calculate">
      Calculate
    </button>

    <div v-if="result" class="result">
      <div v-if="!customEdge">
        <b>Edge:</b> {{ result.edgeLeft.toFixed(2) }} cm
      </div>

      <div v-else>
        <b>Spacing:</b> {{ result.spacing }} cm
      </div>

      <div>
        <b>Between hooks:</b> {{ result.spacing }} cm
      </div>

      <div>
        <b>Pattern:</b>
        <div 
          class="pattern"
        >
          {{ result.pattern }}
        </div>
      </div>

      <div>
        <b>Marks every 2m:</b>
        <span 
          v-for="m in result.marks" 
          :key="m"
        >
          {{ m }} cm
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.helpers {
  padding: 16px;
  max-width: 400px;
}

input {
  width: 100%;
  padding: 10px;
  margin-bottom: 10px;
}

button {
  width: 100%;
  padding: 12px;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.result {
  margin-top: 16px;
  padding: 12px;
  background: #f1f5f9;
  border-radius: 10px;
}

.pattern {
  margin-top: 8px;
  font-family: monospace;
  word-break: break-all;
}
</style>