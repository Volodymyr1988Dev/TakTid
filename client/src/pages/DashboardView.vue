<script setup lang="ts">
import { computed, ref } from 'vue'

import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../pages/TimeTabs.vue'
import ProjectsTab from '../pages/ProjectTab.vue'
import AppHeader from '../components/ui/AppHeader.vue'
import ProjectInfo from '../pages/ProjectInfo.vue'
import { useAuthStore } from '../stores/auth.store'
import { useProjectNavigationStore } from '../stores/projectNavigation.store'
//import StatsPage from '../components/pages/StatsPage.vue'
import StatsPage from '../pages/StatsPage.vue'

const auth = useAuthStore()
const projectNav = useProjectNavigationStore()
const isAdmin = computed(() => {
  if (!auth.isInitialized) return false
  return auth.user?.isAdmin === true
})
//const globalLoading = ref(false)
const bottomTab = ref<'time' | 'projects' | 'stats'>('time')
//const selectedProjectId = ref<string | null>(null)

//week-day.today background-color #ede7f6  #6d9cdecc  #78a5e2  #9baae2b5
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
    <ProjectsTab
      v-else-if="bottomTab === 'projects' && !projectNav.selectedProjectId"
      mode="details"
      :project-id="projectNav.selectedProjectId"
      @back="projectNav.closeProject"
    />
    <ProjectInfo
      v-else-if="bottomTab === 'projects' && projectNav.selectedProjectId"
      :project-id="projectNav.selectedProjectId!"
      @back="projectNav.closeProject"
    />
    <StatsPage v-else-if="bottomTab === 'stats' && isAdmin" />
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