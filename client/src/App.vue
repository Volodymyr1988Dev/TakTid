<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppToast from './components/ui/AppToast.vue'
//import { onMounted } from 'vue'
//import { useAuthStore } from './stores/auth.store';

//onMounted(async () => {
//  const auth = useAuthStore()
//  await auth.initAuth()
//})
</script>

<template>
  <RouterView />
  <AppToast />
</template>

<style>
html,
body,
#app {
  height: 100%;
  margin: 0;
}
</style>
