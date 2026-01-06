<script setup lang="ts">
import { ref } from 'vue'

import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../components/time/TimeTabs.vue'
import ProjectsTab from '../components/Projects/ProjectTab.vue'
import AppHeader from './AppHeader.vue'

const bottomTab = ref<'time' | 'projects'>('time')
</script>

<template>
  <AppHeader />
  <div class="page">
    <TimeTab v-if="bottomTab === 'time'" />
    <ProjectsTab v-else />

    <BottomTabs v-model="bottomTab" />
  </div>
</template>
<style scoped>
.page {
  padding-top: 56px;
}
</style>