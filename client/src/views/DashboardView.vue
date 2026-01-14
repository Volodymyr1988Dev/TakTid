<script setup lang="ts">
import { computed, ref } from 'vue'

import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../components/time/TimeTabs.vue'
import ProjectsTab from '../components/Projects/ProjectTab.vue'
import AppHeader from './AppHeader.vue'
import { useAuthStore } from '../stores/auth.store'

const auth = useAuthStore()
const isAdmin = computed(() => {
  if (!auth.isInitialized) return false
  return auth.user?.isAdmin === true
})
const bottomTab = ref<'time' | 'projects' | 'stats'>('time')
</script>

<template>
  <AppHeader />
  <div 
    v-if="!auth.isInitialized" 
    class="page"
  >
    Loading...
  </div>
  <div class="page">
    <TimeTab v-if="bottomTab === 'time'" />
    <ProjectsTab v-else />

    <BottomTabs
      v-model="bottomTab"
      :is-admin="isAdmin"
    />
  </div>
</template>
<style scoped>
.page {
  padding-top: 56px;
}
</style>