
<script setup lang="ts">
withDefaults(defineProps<{
  locked: boolean
  size?: number
}>(), {
  size: 17,
})
</script>

<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <!-- Корпус замка -->
    <rect
      x="4.5"
      y="10"
      width="15"
      height="11"
      rx="2"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    />

    <!-- Закрита дужка -->
    <path
      v-if="locked"
      d="M8 10V7a4 4 0 0 1 8 0v3"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    />

    <!-- Відкрита дужка, відхилена вправо -->
    <path
      v-else
      d="M8 10V7a4 4 0 0 1 7.5-3.5"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    />

    <!-- Отвір для ключа -->
    <circle
      cx="12"
      cy="15"
      r="1"
      fill="currentColor"
    />
    <path
      d="M12 16v2"
      stroke="currentColor"
      stroke-width="1.7"
      stroke-linecap="round"
    />
  </svg>
</template>
