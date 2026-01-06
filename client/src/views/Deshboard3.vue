<script setup lang="ts">
import { ref } from 'vue'
import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../components/time/TimeTabs.vue'
import ProjectsTab from '../components/Projects/ProjectTab.vue'

const bottomTab = ref<'time' | 'projects'>('time')
</script>

<template>
  <div class="page">
    <component
      :is="bottomTab === 'time' ? TimeTab : ProjectsTab"
    />

    <BottomTabs v-model="bottomTab" />
  </div>
</template>