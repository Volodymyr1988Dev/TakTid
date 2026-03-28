<script setup lang="ts">
import { ref, computed } from 'vue'
import { calculateIdealSpacing } from './helpers/utils/IdealSpace'

const length = ref<number | null>(null)
const ideal = ref(15)

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
      placeholder="Length (cm)"
    >

    <input
      v-model.number="ideal"
      type="number"
      placeholder="Ideal spacing"
    />

    <div v-if="result" class="card">
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

      <div class="grid">
        <div>
          <small>Lower spacing</small>
          <b>{{ result.lower.spacing }}</b>
          <div>segments: {{ result.lower.segments }}</div>
        </div>

        <div>
          <small>Upper spacing</small>
          <b>{{ result.upper.spacing }}</b>
          <div>segments: {{ result.upper.segments }}</div>
        </div>
      </div>
    </div>
  </div>
</template>