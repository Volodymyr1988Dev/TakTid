<script setup lang="ts">
import { computed, ref } from 'vue'

import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../components/time/TimeTabs.vue'
import ProjectsTab from '../components/Projects/ProjectTab.vue'
import AppHeader from './AppHeader.vue'
import ProjectInfo from '../components/Projects/ProjectInfo.vue'
import { useAuthStore } from '../stores/auth.store'
import { useProjectNavigationStore } from '../stores/projectNavigation.store'

const auth = useAuthStore()
const projectNav = useProjectNavigationStore()
const isAdmin = computed(() => {
  if (!auth.isInitialized) return false
  return auth.user?.isAdmin === true
})
const bottomTab = ref<'time' | 'projects' | 'stats'>('time')
const selectedProjectId = ref<string | null>(null)
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
    <!--@open-details="id => projectNav.openProject(id)"
    @open-details=" projectNav.openProject"-->
    <ProjectsTab
      v-else-if="bottomTab === 'projects' && !projectNav.selectedProjectId"
      mode="details"
      :project-id="projectNav.selectedProjectId"
      @back="projectNav.closeProject"
    />
    <ProjectInfo
      v-else-if="bottomTab === 'projects' && projectNav.selectedProjectId"
      :project-id="projectNav.selectedProjectId!"
      @back="selectedProjectId = null"
    />
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