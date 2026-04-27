<script setup lang="ts">
import { ref, onMounted, computed, onBeforeUnmount } from 'vue'
//import { useI18n } from 'vue-i18n'
import { setLanguage } from '../i18nUtils'
//const { locale } = useI18n()
import { i18n } from '../i18n'

const isOpen = ref(false)

type Language = {
  code: string
  label: string
  flag: string
}

const languages = [
  { code: 'en', label: 'English', flag: '🇬🇧' },
  { code: 'uk', label: 'Українська', flag: '🇺🇦' },
  { code: 'sv', label: 'Svenska', flag: '🇸🇪' },
  { code: 'ro', label: 'Română', flag: '🇷🇴' },
  { code : 'pl', label: 'Polski', flag: '🇵🇱' }
]

const locale = computed<string>(() => i18n.global.locale.value)
const currentLocale = computed(() => locale.value)

async function changeLang(code: string) {
  await setLanguage(code)
  isOpen.value = false
}

function toggle() {
  isOpen.value = !isOpen.value
}

function close() {
  isOpen.value = false
}

const currentLang = computed<Language>(() => {
  const found = languages.find(l => l.code === locale.value)
  if (!languages[0]) {
    throw new Error('Languages array is empty')
  }
  return found ?? languages[0]
})

// закриття по кліку поза
function handleClickOutside(e: MouseEvent) {
  const target = e.target as HTMLElement
  if (!target.closest('.lang-switcher')) {
    close()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})
onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<template>
  <div class="lang-switcher">
    <!-- BUTTON -->
    <button class="lang-btn" @click.stop="toggle">
      <span>{{ currentLang.flag }}</span>
      <span class="code">{{ currentLang.code.toUpperCase() }}</span>
      <span class="arrow">▾</span>
    </button>

    <!-- DROPDOWN -->
    <div v-if="isOpen" class="dropdown">
      <div
        v-for="lang in languages"
        :key="lang.code"
        class="item"
        :class="{ active: lang.code === currentLocale }"
        @click="changeLang(lang.code)"
      >
        <span class="flag">{{ lang.flag }}</span>
        <span class="label">{{ lang.label }}</span>
        <span v-if="lang.code === currentLocale" class="check">✓</span>
        <!--locale currentLocale-->
      </div>
    </div>
  </div>
</template>

<style scoped>
.lang-switcher {
  position: relative;
  display: inline-block;
}

/* BUTTON */
.lang-btn {
  display: flex;
  align-items: center;
  gap: 8px;/*
  background: #f1f5f9;
  border: 1px solid #cbd5f5;*/
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 6px 12px;
  cursor: pointer;
  font-size: 13px;
  transition: 0.2s;

  font-weight: 500;
  transition: all 0.2s ease;
}

.lang-btn:hover {
  /*background: #e2e8f0;*/
  background: #f8fafc;
  border-color: #cbd5f5;
}

.arrow {
  font-size: 10px;
  opacity: 0.7;
}

/* DROPDOWN */
.dropdown {
  position: absolute;
  top: 110%;
  right: 0;
  background: white;
  border-radius: 14px;
  /*box-shadow: 0 10px 25px rgba(0,0,0,0.1);*/
  box-shadow: 0 12px 30px rgba(0,0,0,0.12);

  min-width: 180px;
  padding: 6px;
  z-index: 100;

  animation: fadeIn 0.15s ease;
}

/* ITEM */
.item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 9px 10px;
  border-radius: 10px;
  cursor: pointer;
  transition: 0.15s;
}

.item:hover {
  background: #f1f5f9;
}

.item.active {
  /*background: #e0e7ff;*/
  background: #eef2ff;
}

.flag {
  font-size: 16px;
}

.label {
  flex: 1;
  text-align: left;
  font-size: 13px;
}

.check {
  color: #2563eb;
  font-weight: bold;
}
.auth-lang .label {
  color: #1e293b;
}

.auth-lang .lang-btn {
  color: #1e293b;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>