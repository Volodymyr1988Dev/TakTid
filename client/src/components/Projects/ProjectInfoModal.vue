<input type="file" @change="onFile" />

<div class="photos">
  <img
    v-for="url in project.photos"
    :key="url"
    :src="url"
    class="photo"
  />
</div>

async function onFile(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return

  const url = await uploadPhoto(file)

  await api.patch(`/projects/${project.id}`, {
    photos: [...project.photos, url],
  })
}

<style lang="css">
    .photos {
  display: flex;
  gap: 8px;
  overflow-x: auto;
}

.photo {
  width: 96px;
  height: 96px;
  border-radius: 12px;
  object-fit: cover;
}
</style>

