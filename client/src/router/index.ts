import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
import LoginView from '../pages/LoginView.vue'
import RegisterView from '../pages/RegisterView.vue'
import DashboardView from '../pages/DashboardView.vue'
import ProjectInfo from '../pages/ProjectInfo.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      component: LoginView,
      meta: { guestOnly: true },
    },
    {
      path: '/register',
      component: RegisterView,
      meta: { guestOnly: true },
    },
    {
      path: '/dashboard',
      component: DashboardView,
      meta: { requiresAuth: true },
    },
    {
      path: '/',
      redirect: '/dashboard',
    },
    {
      path: '/projects/:id',
      component: ProjectInfo,
    },
    {
      path: '/account',
      component: () => import('../pages/AccountView.vue'),
      meta: { requiresAuth: true },
    }
  ],
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  if (!auth.isInitialized) {
    await auth.initAuth()
  }
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return '/login'
  }

  if (to.meta.guestOnly && auth.isAuthenticated) {
    return '/dashboard'
  }
  if (to.meta.requiresAdmin && !auth.user?.isAdmin) {
    return '/dashboard'
  }
  return true
})

export default router