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

    <div 
      v-if="result" 
      class="card"
    >
      <div class="grid">
        <div>
          <small>Exact</small>
          <b>{{ result.exact.toFixed(2) }}</b>
        </div>
        <div>
          <small>Ideal</small>
          <b>{{ result.ideal }}</b>
        </div>
      </div>
      <div>
        <small>Missing to ideal (roof)</small>
        <b :class="{ plus: result.missing > 0, minus: result.missing < 0 }">
          {{ result.missing > 0 ? '+' : '' }}{{ result.missing }} cm
        </b>
      </div>
      <div class="grid">
        <div>
          <small>Lower spacing</small>
          <b>{{ result.lower.spacing }}</b>
          <div>segments: {{ result.lower.segments }}</div>
          <div :class="result.lower.missing > 0 ? 'plus' : 'minus'">
            {{ result.lower.missing > 0 ? '+' : '' }}{{ result.lower.missing }} cm
          </div>
        </div>
        <div>
          <small>Upper spacing</small>
          <b>{{ result.upper.spacing }}</b>
          <div>segments: {{ result.upper.segments }}</div>
          <div :class="result.upper.missing > 0 ? 'plus' : 'minus'">
            {{ result.upper.missing > 0 ? '+' : '' }}{{ result.upper.missing }} cm
          </div>
        </div>
      </div>
    </div>
  </div>
</template>