import { createApp } from 'vue'
import { createPinia } from 'pinia';
import router from './router';
import App from './App.vue'
//import { useAuthStore } from './stores/auth.store'

import dayjs from 'dayjs'
import weekOfYear from 'dayjs/plugin/weekOfYear'
import isoWeek from 'dayjs/plugin/isoWeek'
import isSameOrAfter from 'dayjs/plugin/isSameOrAfter'
import isBetween from 'dayjs/plugin/isBetween'

//import './style.css'
import './styles/theme.css'
import './styles/calendar.css'

//const pinia = createPinia()
dayjs.extend(weekOfYear)
dayjs.extend(isoWeek)
dayjs.extend(isSameOrAfter)
dayjs.extend(isBetween)

//createApp(App).mount('#app')
const app = createApp(App);
const pinia = createPinia();


app.use(pinia);
app.use(router);

/*

createApp(App)
  .use(createPinia())
  .use(pinia)
  .use(router)
  .mount('#app');
*/
//const auth = useAuthStore(pinia)
//await auth.initAuth()
//auth.fetchMe().finally(() => {
//auth.initAuth().finally(() => {
  app.mount('#app')
//})