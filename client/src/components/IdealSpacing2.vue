<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { calculateIdealSpacing } from './helpers/utils/IdealSpace'

const length = ref<number | null>(null)
//const ideal = ref(34)
const ideal = ref<number | null>(34)

const debouncedLength = ref<number | null>(null)
const debouncedIdeal = ref<number | null>(34)
const error = ref<string | null>(null)
let timer: ReturnType<typeof setTimeout> | null = null
 
function isValidNumber(value: any) {
  return typeof value === 'number' && !isNaN(value)
}

function validate() {
  if (length.value !== null && (!isValidNumber(length.value) || length.value < 20)) {
    error.value = 'Length must be a number and greater than 20 cm'
    return false
  }

  if (ideal.value !== null && (!isValidNumber(ideal.value) || ideal.value < 20)) {
    error.value = 'Ideal spacing must be a number and greater than 20 cm'
    return false
  }

  error.value = null
  return true
}

watch([length, ideal], () => {
  if (timer) clearTimeout(timer)

  timer = setTimeout(() => {
    if (!validate()) return

    debouncedLength.value = length.value
    debouncedIdeal.value = ideal.value
  }, 400) // debounce
})

const result = computed(() => {
  //if (!length.value) return null
  if (!debouncedLength.value || !debouncedIdeal.value) return null
  //return calculateIdealSpacing(length.value, ideal.value)
  return calculateIdealSpacing(debouncedLength.value, debouncedIdeal.value)
})

function generateMarks(spacing: number, max = 200) {
  const marks: number[] = []

  let i = 1
  while (true) {
    const val = +(spacing * i).toFixed(2)
    if (val > max) break
    marks.push(val)
    i++
  }

  return marks
}

function getMarkStyle(mark: number, max = 200) {
  return {
    left: `${(mark / max) * 100}%`
  }
}
function getRow(index: number) {
  return index % 2 // 2 рядки
}
</script>

<template>
  <div class="wrap">
    <h2>Ideal spacing</h2>

    <input
      v-model.number="length"
      type="number"
      placeholder="Length (sm)"
    >

    <input
      v-model.number="ideal"
      type="number"
      placeholder="Ideal spacing"
    >

    <div v-if="result" class="card">

      <!-- CENTER BLOCK -->
      <div class="center-block">
        <div class="center-item">
          <small>Exact</small>
          <b>{{ result.exact.toFixed(2) }}</b>
        </div>

        <div class="center-item">
          <small>Ideal</small>
          <b>{{ result.ideal }}</b>
        </div>

        <div class="center-item">
          <small>to ideal (roof) need</small>
          <b :class="{ plus: result.missing > 0, minus: result.missing < 0 }">
            {{ result.missing > 0 ? '+' : '' }}{{ result.missing }} cm
          </b>
        </div>
      </div>

      <!-- LOWER / UPPER -->
      <div class="grid-2">
        <div class="col">
          <small>Lower spacing</small>
          <b>{{ result.lower.spacing.toFixed(2) }}</b>

          <div class="sub">
            segments: {{ result.lower.segments }}
          </div>

          <div
            class="sub"
            :class="result.lower.missing > 0 ? 'plus' : 'minus'"
          >
            {{ result.lower.missing > 0 ? '+' : '' }}
            {{ result.lower.missing }} cm
          </div>
          <div class="scale-2m">
            <div class="line"></div>

            <div
              v-for="(m, i) in generateMarks(result.lower.spacing)"
              :key="'l' + m"
              class="mark"
              :style="getMarkStyle(m)"
            >
              <span 
                class="mark-label"
                :style="{ top: `${getRow(i) * -14}px` }">{{ m }}</span>
          </div>
        </div>
        </div>

        <div class="col">
          <small>Upper spacing</small>
          <b>{{ result.upper.spacing.toFixed(2) }}</b>

          <div class="sub">
            segments: {{ result.upper.segments }}
          </div>
          <div
            class="sub"
            :class="result.upper.missing > 0 ? 'plus' : 'minus'"
          >
            {{ result.upper.missing > 0 ? '+' : '' }}
            {{ result.upper.missing }} cm
          </div>
          <div class="scale-2m">
            <div class="line"></div>

            <div
              v-for="(m, i) in generateMarks(result.upper.spacing)"
              :key="'u' + m"
              class="mark"
              :style="getMarkStyle(m)"
            >
              <span 
                class="mark-label"
                :style="{ top: `${getRow(i) * -14}px` }">{{ m }}</span>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>
<style scoped>  
.center-block {
  text-align: center;
  margin-bottom: 20px;
}

.center-item {
  margin-bottom: 8px;
}

.center-item small {
  display: block;
  font-size: 12px;
  color: #64748b;
}

.center-item b {
  font-size: 20px;
}

/* 2 columns */
.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.col {
  background: #e2e8f0;
  padding: 12px;
  border-radius: 12px;
  text-align: center;
}

.col small {
  display: block;
  font-size: 11px;
  color: #64748b;
}

.col b {
  font-size: 18px;
}

.sub {
  font-size: 13px;
  margin-top: 4px;
}

/* colors */
.plus {
  color: #16a34a;
}

.minus {
  color: #dc2626;
}
.scale-2m {
  margin-top: 25px /*12px*/;
  position: relative;
  height: 60px;
}

.scale-2m .line {
  position: absolute;
  top: 30px;
  left: 0;
  right: 0;
  height: 6px;
  background: #cbd5f5;
  border-radius: 6px;
}

.mark {
  position: absolute;
  top: 0;
  transform: translateX(-50%);
  text-align: center;
}

.mark span {
  font-size: 8px;
  white-space: nowrap;
  transform: translateY(-4px);
}

.mark::after {
  content: '';
  display: block;
  width: 6px;
  height: 10px;
  background: #2563eb;
  margin: 18px auto 0;
}
.mark-label {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 9px;
  white-space: nowrap;
}
@media (max-width: 480px) {
  .scale-2m {
    height: 70px;
  }

  .mark-label {
    font-size: 7px; /* менше */
  }
}
</style>