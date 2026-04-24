<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { calculateIdealSpacing } from './helpers/utils/IdealSpace'
import { sanitizeNumber } from './helpers/helpers'

// ---------------- STATE ----------------
const length = ref<number | null>(null)
const ideal = ref<number | null>(34)

const debouncedLength = ref<number | null>(null)
const debouncedIdeal = ref<number | null>(34)

const error = ref<string | null>(null)
let timer: ReturnType<typeof setTimeout> | null = null

// ---------------- VALIDATION ----------------
function validate() {
  const len = sanitizeNumber(length.value)
  const id = sanitizeNumber(ideal.value)

  if (!len || len < 20) {
    error.value = 'Length must be a number and ≥ 20 cm'
    return false
  }

  if (!id || id < 20) {
    error.value = 'Ideal spacing must be a number and ≥ 20 cm'
    return false
  }

  error.value = null
  return true
}

// ---------------- DEBOUNCE ----------------
watch([length, ideal], () => {
  if (timer) clearTimeout(timer)

  timer = setTimeout(() => {
    if (!validate()) return

    debouncedLength.value = length.value
    debouncedIdeal.value = ideal.value
  }, 300)
})

// ---------------- RESULT ----------------
const result = computed(() => {
  if (!debouncedLength.value || !debouncedIdeal.value) return null
  return calculateIdealSpacing(debouncedLength.value, debouncedIdeal.value)
})

// ---------------- SCALE ----------------
function generateMarks(spacing: number, max = 200) {
  const marks: number[] = []

  let i = 0
  while (true) {
    const val = +(spacing * i).toFixed(2)
    if (val > max) break
    if (val !== 0) marks.push(val)
    //marks.push(val)
    i++
  }

  return marks
}

function getMarkStyle(mark: number, max = 200) {
  return {
    left: `${(mark / max) * 100}%`
  }
}

// 2 rows (clean UI)
function getRow(index: number) {
  return index % 2
}
</script>

<template>
  <div class="wrap">
    <h2>Ideal Spacing</h2>

    <!-- INPUTS -->
    <div class="inputs">
      <div class="field">
        <label>Length (cm)</label>
        <input v-model.number="length" type="number" placeholder="Enter length" />
      </div>

      <div class="field">
        <label>Ideal spacing (cm)</label>
        <input v-model.number="ideal" type="number" placeholder="Enter ideal spacing" />
      </div>
    </div>

    <p v-if="error" class="error">
      {{ error }}
    </p>

    <!-- RESULT -->
    <div v-if="result && !error" class="card">

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
          <small>Difference</small>
          <b :class="{ plus: result.missing > 0, minus: result.missing < 0 }">
            {{ result.missing > 0 ? '+' : '' }}{{ result.missing }} cm
          </b>
        </div>
      </div>

      <!-- LOWER / UPPER -->
      <div class="grid-2">

        <!-- LOWER -->
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

          <div class="scale">
            <div class="line"></div>

            <div
              v-for="(m, i) in generateMarks(result.lower.spacing)"
              :key="'l' + m"
              class="mark"
              :style="getMarkStyle(m)"
            >
              <span
                class="mark-label"
                :style="{ top: `${getRow(i) * -14}px` }"
              >
                {{ m }}
              </span>
            </div>
          </div>
        </div>

        <!-- UPPER -->
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

          <div class="scale">
            <div class="line"></div>

            <div
              v-for="(m, i) in generateMarks(result.upper.spacing)"
              :key="'u' + m"
              class="mark"
              :style="getMarkStyle(m)"
            >
              <span
                class="mark-label"
                :style="{ top: `${getRow(i) * -14}px` }"
              >
                {{ m }}
              </span>
            </div>
          </div>
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

/* INPUTS */
.inputs {
  display: flex;
  gap: 12px;
  margin-bottom: 10px;
}

.field {
  flex: 1;
  display: flex;
  flex-direction: column;
}

label {
  font-size: 12px;
  color: #64748b;
  margin-bottom: 4px;
}

input {
  padding: 10px;
  border-radius: 10px;
  border: 1px solid #ccc;
}

/* ERROR */
.error {
  margin: 10px 0;
  padding: 10px;
  background: #fee2e2;
  color: #b91c1c;
  border-radius: 10px;
}

/* CARD */
.card {
  margin-top: 12px;
  padding: 14px;
  border-radius: 16px;
  background: #f1f5f9;
}

/* CENTER */
.center-block {
  text-align: center;
  margin-bottom: 20px;
  padding: 10px;
  background: #e2e8f0;
  border-radius: 12px;
}

.center-item {
  margin-bottom: 6px;
}

.center-item small {
  display: block;
  font-size: 12px;
  color: #64748b;
}

.center-item b {
  font-size: 20px;
}

/* GRID */
.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
}

.col {
  background: #e2e8f0;
  padding: 14px;
  border-radius: 14px;
  text-align: center;
  box-shadow: inset 0 0 0 1px #cbd5f5;
}

.sub {
  font-size: 13px;
  margin-top: 4px;
}

/* COLORS */
.plus {
  color: #16a34a;
}

.minus {
  color: #dc2626;
}

/* SCALE */
.scale {
  margin-top: 20px;
  position: relative;
  height: 60px;
}

.line {
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
  transform: translateX(-50%);
  text-align: center;
}

.mark::after {
  content: '';
  display: block;
  width: 4px;
  height: 10px;
  background: #2563eb;
  margin: 4px auto 0;
}

.mark-label {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 9px;
  white-space: nowrap;
}
.dot {
  width: 6px;
  height: 6px;
  background: #2563eb;
  border-radius: 50%;
  margin: 20px auto 0;
}

/* MOBILE */
@media (max-width: 480px) {
  .scale {
    height: 70px;
  }

  .mark-label {
    font-size: 7px;
  }

  .inputs {
    flex-direction: column;
  }
}
</style>