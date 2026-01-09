<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto'

const projects = ref<Project[]>([])
const search = ref('')

onMounted(async () => {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
})
</script>

<template>
  <div class="tab-content">
    <input
      class="search"
      v-model="search"
      placeholder="Search"
    />

    <div
      v-for="p in projects"
      :key="p.id"
      class="card"
      @click="$emit('select-project', p)"
    >
      <div class="title">
        {{ p.city }} – {{ p.address }}
      </div>
      <span class="star">☆</span>
    </div>
  </div>
</template>