<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { calculateIdealSpacing } from './helpers/utils/IdealSpace'
import { sanitizeNumber } from './helpers/helpers'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
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
    error.value = t('calculator.errorLength')
    return false
  }

  if (!id || id < 20) {
    error.value = t('calculator.errorIdeal')
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
    <h2>{{ t('calculator.idealSpacing') }}</h2>

    <!-- INPUTS -->
    <div class="inputs">
      <div class="field">
        <label>{{ t('calculator.length') }}</label>
        <input v-model.number="length" type="number" placeholder="{{ t('calculator.length') }}" />
      </div>

      <div class="field">
        <label>{{ t('calculator.idealSpacing') }}</label>
        <input v-model.number="ideal" type="number" placeholder="{{ t('calculator.idealSpacing') }}" />
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
          <small>{{ t('calculator.exact') }}</small>
          <b>{{ result.exact.toFixed(2) }}</b>
        </div>

        <div class="center-item">
          <small>{{ t('calculator.ideal') }}</small>
          <b>{{ result.ideal }}</b>
        </div>

        <div class="center-item">
          <small>{{ t('calculator.difference') }}</small>
          <b :class="{ plus: result.missing > 0, minus: result.missing < 0 }">
            {{ result.missing > 0 ? '+' : '' }}{{ result.missing }} cm
          </b>
        </div>
      </div>

      <!-- LOWER / UPPER -->
      <div class="grid-2">

        <!-- LOWER -->
        <div class="col">
          <small>{{ t('calculator.lower') }}</small>
          <b>{{ result.lower.spacing.toFixed(2) }}</b>

          <div class="sub">
            {{ t('calculator.segments') }}: {{ result.lower.segments }}
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
              <span class="mark-label" :class="`row-${getRow(i)}`">
                {{ m }}
              </span>
            </div>
          </div>
        </div>

        <!-- UPPER -->
        <div class="col">
          <small>{{ t('calculator.upper') }}</small>
          <b>{{ result.upper.spacing.toFixed(2) }}</b>

          <div class="sub">
            {{ t('calculator.segments') }}: {{ result.upper.segments }}
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
              <span class="mark-label" :class="`row-${getRow(i)}`">
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
  padding: 16px;
  border-radius: 14px;
  text-align: center;
  box-shadow: inset 0 0 0 1px #cbd5f5;
}
.col b {
  font-size: 18px;
  color: #1e293b;
}
.sub {
  font-size: 13px;
  margin-top: 4px;
  color: #475569;
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
  /*margin-top: 20px;*/
  position: relative;
  /*padding-top: 28px;*/
  height: 70px;
}/*
.scale::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(to right, #f1f5f9, transparent 10%, transparent 90%, #f1f5f9);
  pointer-events: none;
}*/
.line {
  position: absolute;
  top: 50%;
  /*bottom: 0;*/
  left: 0;
  right: 0;
  height: 4px;
  background: #cbd5f5;
  border-radius: 4px;
  transform: translateY(-50%);
}

.mark {
  position: absolute;
  top: 50%;
  transform: translateX(-50%);
}

.mark::after {
  content: '';
  position: absolute;
  /*bottom: 3px;*/
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: #2563eb;
  border-radius: 50%;
  /*
  display: block;
  width: 4px;
  height: 10px;
  background: #2563eb;
  margin: 4px auto 0;*/
}

.mark-label {
  position: absolute;
  bottom: 100%; /* ключ! */
  left: 50%;
  transform: translateX(-50%);
  font-size: 10px;
  white-space: nowrap;
  color: #334155;
  font-weight: 500;
  background: #f1f5f9;
  padding: 2px 6px;
  border-radius: 6px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.08);
  pointer-events: none;
  /*
  position: absolute;
  bottom: 14px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 10px;
  white-space: nowrap;
  color: #334155;
  font-weight: 500;
  top: -16px;*/
  /*
  left: 50%;
  transform: translateX(-50%);
  font-size: 9px;
  white-space: nowrap;*/
}
.row-0 {
  margin-bottom: 6px;
}

.row-1 {
  margin-bottom: 20px;
}/*
.dot {
  width: 6px;
  height: 6px;
  background: #2563eb;
  border-radius: 50%;
  margin: 20px auto 0;
}*/

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