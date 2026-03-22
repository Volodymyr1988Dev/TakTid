import { createApp } from 'vue'
import { createPinia } from 'pinia';
import router from './router';
import App from './App.vue'
import { useAuthStore } from './stores/auth.store'; 
import dayjs from 'dayjs'
import weekOfYear from 'dayjs/plugin/weekOfYear'
import isoWeek from 'dayjs/plugin/isoWeek'
import isSameOrAfter from 'dayjs/plugin/isSameOrAfter'
import isBetween from 'dayjs/plugin/isBetween'

import './styles/theme.css'
import './styles/calendar.css'

dayjs.extend(weekOfYear)
dayjs.extend(isoWeek)
dayjs.extend(isSameOrAfter)
dayjs.extend(isBetween)

const app = createApp(App);
const pinia = createPinia();


app.use(pinia);
app.use(router);
const auth = useAuthStore()

document.addEventListener("visibilitychange", async () => {
  if (document.visibilityState === "visible") {
    try {
      await auth.initAuth()
    } catch {
      console.log("Session restore failed")
    }
  }
})
app.mount('#app')