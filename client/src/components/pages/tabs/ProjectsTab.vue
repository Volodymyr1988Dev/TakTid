<div class="search">
  <input placeholder="Search" />
</div>
<ProjectCard
  v-for="project in projects"
  :key="project.id"
  @click="selectProject(project)"
/>