<script setup lang="ts">
import { ref, computed } from 'vue'
import { calculateIdealSpacing } from './helpers/utils/IdealSpace'

const length = ref<number | null>(null)
const ideal = ref(34)

const result = computed(() => {
  if (!length.value) return null
  return calculateIdealSpacing(length.value, ideal.value)
})
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
            {{ result.missing < 0 ? '+' : '' }}{{ result.missing }} cm
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
</style>