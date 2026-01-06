<script setup lang="ts">
import { ref } from 'vue'

import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../components/time/TimeTabs.vue'
import ProjectsTab from '../components/Projects/ProjectTab.vue'

const bottomTab = ref<'time' | 'projects'>('time')
</script>

<template>
  <div class="page">
    <TimeTab v-if="bottomTab === 'time'" />
    <ProjectsTab v-else />

    <BottomTabs v-model="bottomTab" />
  </div>
</template>