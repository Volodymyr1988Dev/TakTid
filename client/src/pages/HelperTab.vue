<script setup lang="ts">
import { ref } from 'vue'
import HookCalculator from '../components/HookCalculator.vue'
import IdealSpacing from '../components/IdealSpacing.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const mode = ref<'hooks' | 'spacing'>('hooks')
</script>

<template>
  <div class="wrap">
    <div class="tabs">
      <button :class="{ active: mode === 'hooks' }" @click="mode = 'hooks'">
        {{ t('hook.hooks') }}
      </button>

      <button :class="{ active: mode === 'spacing' }" @click="mode = 'spacing'">
        {{ t('hook.spacing') }}
      </button>
    </div>

    <HookCalculator v-if="mode === 'hooks'" />
    <IdealSpacing v-else />
  </div>
</template>

<style scoped>
.wrap {
  max-width: 420px;
  margin: auto;
}

.tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
}

button {
  flex: 1;
  padding: 10px;
  border-radius: 10px;
  background: #e2e8f0;
  border: none;
}

button.active {
  background: #2563eb;
  color: white;
}
</style>