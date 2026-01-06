<script setup lang="ts">
import { computed } from 'vue'
import { useAuthStore } from '../../stores/auth.store'

const auth = useAuthStore()

const projects: any[] = []
const isAdmin = computed(() => auth.user?.isAdmin === true)
</script>

<template>
  <div class="projects">
    <p v-if="!projects.length">
      Попросіть адміністратора внести проект
    </p>

    <ul v-else>
      <li v-for="p in projects" :key="p.id">
        {{ p.city }} – {{ p.address }}
      </li>
    </ul>

    <button v-if="isAdmin">
      Create project
    </button>
  </div>
</template>