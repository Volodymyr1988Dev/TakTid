<script setup lang="ts">
import { computed, ref } from 'vue'

import BottomTabs from '../components/bottomTabs/BottomTabs.vue'
import TimeTab from '../components/time/TimeTabs.vue'
import ProjectsTab from '../components/Projects/ProjectTab.vue'
import AppHeader from './AppHeader.vue'
import ProjectInfo from '../components/Projects/ProjectInfo.vue'
import { useAuthStore } from '../stores/auth.store'
import { useProjectNavigationStore } from '../stores/projectNavigation.store'
import StatsPage from '../components/pages/components/StatsPage.vue'

const auth = useAuthStore()
const projectNav = useProjectNavigationStore()
const isAdmin = computed(() => {
  if (!auth.isInitialized) return false
  return auth.user?.isAdmin === true
})
const globalLoading = ref(false)
const bottomTab = ref<'time' | 'projects' | 'stats'>('time')
//const selectedProjectId = ref<string | null>(null)

//week-day.today background-color #ede7f6  #6d9cdecc  #78a5e2  #9baae2b5
</script>

<template>
  <div 
    v-if="globalLoading" 
    class="overlay"
  >
    <div class="spinner">
      Please wait, saving…
    </div>
  </div>
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