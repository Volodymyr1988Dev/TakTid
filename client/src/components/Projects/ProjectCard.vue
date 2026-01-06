<script setup lang="ts">
import { ref } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto';

const props = defineProps<{
  project: Project
  isAdmin: boolean
}>()

const emit = defineEmits<{ deleted: [string] }>()

const openMenu = ref(false)

function toggleMenu() {
  openMenu.value = !openMenu.value
}

async function confirmDelete() {
  if (!confirm('Are you sure?')) return
  await api.delete(`/projects/${props.project.id}`)
  emit('deleted', props.project.id)
}
</script>

<template>
  <div class="project-card">
    <div class="content">
      <strong>{{ project.city }}</strong>
      <span>{{ project.address }}</span>
    </div>

    <span v-if="isAdmin" class="dots" @click="toggleMenu">⋮</span>

    <ul v-if="openMenu" class="menu">
      <li>Info</li>
      <li class="danger" @click="confirmDelete">Delete</li>
    </ul>
  </div>
</template>

<style scoped>
.project-card {
  position: relative;
  border: 1px solid #ddd;
  border-radius: 12px;
  padding: 12px;
  background: #fff;
  transition: box-shadow 0.2s;
}
.project-card:hover {
  box-shadow: 0 4px 14px rgba(0,0,0,0.1);
}
.content span {
  color: #666;
  font-size: 14px;
}
.dots {
  position: absolute;
  top: 8px;
  right: 10px;
  cursor: pointer;
}
.menu {
  position: absolute;
  right: 8px;
  top: 28px;
  background: white;
  border-radius: 8px;
  border: 1px solid #ddd;
  list-style: none;
  padding: 4px 0;
}
.menu li {
  padding: 6px 12px;
  cursor: pointer;
}
.menu li:hover {
  background: #f2f2f2;
}
.menu .danger {
  color: #c00;
}
</style>