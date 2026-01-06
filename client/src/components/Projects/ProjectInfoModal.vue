<input type="file" @change="onFile" />

<img
  v-for="url in project.photos"
  :key="url"
  :src="url"
  class="photo"
/>