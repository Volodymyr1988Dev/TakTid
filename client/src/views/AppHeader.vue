<script setup lang="ts">
import { useAuthStore } from '../stores/auth.store'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

async function onLogout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <header class="app-header">
    <div class="spacer" />
    <button
      v-if="auth.isAuthenticated"
      class="settings"
      @click="router.push('/account')"
    >
      ⚙️
    </button>
    <button
      v-if="auth.isAuthenticated"
      class="logout"
      @click="onLogout"
    >
      Log out
    </button>
  </header>
</template>

<style scoped>
.app-header {
  position: fixed;
  top: 0;
  right: 0;
  left: 0;

  height: 56px;
  display: flex;
  align-items: center;

  padding: 0 16px;
  background: transparent;
  /*border-bottom: 1px solid #e5e5e5;*/
  z-index: 100;
}

.spacer {
  flex: 1;
}

.logout {
  background: transparent;
  border: none;
  cursor: pointer;
  font-weight: 600;
}
.settings {
  background: transparent;
  border: none;
  font-size: 18px;
  cursor: pointer;
  margin-right: 12px;
}
</style>