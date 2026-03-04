<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppToast from './components/ui/AppToast.vue'
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
