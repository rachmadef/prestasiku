import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  // -----------------------------------------------------------------
  // Public Routes
  // -----------------------------------------------------------------
  {
    path: '/',
    name: 'landing',
    component: () => import('@/views/public/LandingView.vue'),
  },
  {
    path: '/competitions',
    name: 'competitions.catalog',
    component: () => import('@/views/public/CompetitionCatalogView.vue'),
  },
  {
    path: '/competitions/:slug',
    name: 'competitions.detail',
    component: () => import('@/views/public/CompetitionDetailView.vue'),
  },
  {
    path: '/verify/:public_id?',
    name: 'verify',
    component: () => import('@/views/public/PublicVerificationView.vue'),
  },
  {
    path: '/dispensasi/verifikasi/:token?',
    name: 'dispensation.verify',
    component: () => import('@/views/public/DispensationVerificationView.vue'),
  },
  {
    path: '/signer/verify/:token?',
    name: 'signer.verify',
    component: () => import('@/views/public/PublicSignerVerificationView.vue'),
  },
  {
    path: '/school-registration',
    redirect: '/login',
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/auth/LoginView.vue'),
    meta: { guestOnly: true },
  },
  {
    path: '/force-change-password',
    name: 'force-change-password',
    component: () => import('@/views/auth/ForceChangePasswordView.vue'),
    meta: { requiresAuth: true },
  },

  // -----------------------------------------------------------------
  // Super Admin Routes
  // -----------------------------------------------------------------
  {
    path: '/admin',
    redirect: '/admin/dashboard',
    meta: { requiresAuth: true, role: 'super_admin' },
    children: [
      {
        path: 'dashboard',
        name: 'admin.dashboard',
        component: () => import('@/views/admin/AdminDashboardView.vue'),
      },
      {
        path: 'schools',
        name: 'admin.schools',
        component: () => import('@/views/admin/AdminSchoolsView.vue'),
      },
      {
        path: 'competitions',
        name: 'admin.competitions',
        component: () => import('@/views/admin/AdminCompetitionsView.vue'),
      },
      {
        path: 'organizers',
        name: 'admin.organizers',
        component: () => import('@/views/admin/AdminOrganizersView.vue'),
      },
      {
        path: 'categories',
        name: 'admin.categories',
        component: () => import('@/views/admin/AdminCategoriesView.vue'),
      },
      {
        path: 'hero-sliders',
        name: 'admin.hero-sliders',
        component: () => import('@/views/admin/AdminHeroSlidersView.vue'),
      },
      {
        path: 'profile',
        name: 'admin.profile',
        component: () => import('@/views/profile/ProfileView.vue'),
      },
    ],
  },

  // -----------------------------------------------------------------
  // School Admin Routes
  // -----------------------------------------------------------------
  {
    path: '/school',
    redirect: '/school/dashboard',
    meta: { requiresAuth: true, role: 'school_admin' },
    children: [
      {
        path: 'dashboard',
        name: 'school.dashboard',
        component: () => import('@/views/school/SchoolDashboardView.vue'),
      },
      {
        path: 'students',
        name: 'school.students',
        component: () => import('@/views/school/SchoolStudentsView.vue'),
      },
      {
        path: 'registrations',
        redirect: '/school/achievements',
      },
      {
        path: 'permissions',
        name: 'school.permissions',
        component: () => import('@/views/school/SchoolPermissionsView.vue'),
      },
      {
        path: 'permissions/form-settings',
        name: 'school.permissions.form-settings',
        component: () => import('@/views/school/SchoolPermissionFormBuilderView.vue'),
      },
      {
        path: 'dispensations',
        name: 'school.dispensations',
        component: () => import('@/views/school/SchoolDispensationsView.vue'),
      },
      {
        path: 'dispensations/form-settings',
        name: 'school.dispensations.form-settings',
        component: () => import('@/views/school/SchoolDispensationFormBuilderView.vue'),
      },
      {
        path: 'achievements',
        name: 'school.achievements',
        component: () => import('@/views/school/SchoolAchievementsView.vue'),
      },
      {
        path: 'supervisors',
        name: 'school.supervisors',
        component: () => import('@/views/school/SchoolSupervisorsView.vue'),
      },
      {
        path: 'signers',
        name: 'school.signers',
        component: () => import('@/views/school/SchoolSignersView.vue'),
      },
      {
        path: 'profile',
        name: 'school.profile',
        component: () => import('@/views/profile/ProfileView.vue'),
      },
    ],
  },

  // -----------------------------------------------------------------
  // Student Routes
  // -----------------------------------------------------------------
  {
    path: '/student',
    redirect: '/student/dashboard',
    meta: { requiresAuth: true, role: 'student' },
    children: [
      {
        path: 'dashboard',
        name: 'student.dashboard',
        component: () => import('@/views/student/StudentDashboardView.vue'),
      },
      {
        path: 'portfolio',
        name: 'student.portfolio',
        component: () => import('@/views/student/StudentPortfolioView.vue'),
      },
      {
        path: 'permissions',
        name: 'student.permissions',
        component: () => import('@/views/student/StudentPermissionsView.vue'),
      },
      {
        path: 'dispensations',
        name: 'student.dispensations',
        component: () => import('@/views/student/StudentDispensationsView.vue'),
      },
      {
        path: 'dispensations/create',
        name: 'student.dispensations.create',
        component: () => import('@/views/student/StudentDispensationCreateView.vue'),
      },
      {
        path: 'competitions',
        name: 'student.competitions',
        component: () => import('@/views/student/StudentCompetitionsView.vue'),
      },
      {
        path: 'registrations',
        redirect: '/student/achievements',
      },
      {
        path: 'achievements',
        name: 'student.achievements',
        component: () => import('@/views/student/StudentAchievementsView.vue'),
      },
      {
        path: 'profile',
        name: 'student.profile',
        component: () => import('@/views/profile/ProfileView.vue'),
      },
    ],
  },

  // General Profile Route
  {
    path: '/profile',
    name: 'profile',
    component: () => import('@/views/profile/ProfileView.vue'),
    meta: { requiresAuth: true },
  },

  // Fallback 404
  {
    path: '/:pathMatch(.*)*',
    redirect: '/',
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  },
})

// Navigation Guard (Vue Router 5 Return Syntax)
router.beforeEach((to, _from) => {
  const authStore = useAuthStore()

  // 1. Guest only routes (e.g. /login)
  if (to.meta.guestOnly && authStore.isAuthenticated) {
    if (authStore.isSuperAdmin) return '/admin/dashboard'
    if (authStore.isSchoolAdmin) return '/school/dashboard'
    if (authStore.isStudent) return '/student/dashboard'
    return '/'
  }

  // 2. Protected routes check
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth)
  if (requiresAuth && !authStore.isAuthenticated) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }

  // 3. Force change password check
  if (
    authStore.isAuthenticated &&
    authStore.requiresPasswordChange &&
    to.path !== '/force-change-password'
  ) {
    return '/force-change-password'
  }

  // 4. Role checking
  const requiredRole = to.matched.find((record) => record.meta.role)?.meta.role as string | undefined
  if (requiredRole && authStore.user) {
    const hasRole = Array.isArray(authStore.user.roles) && authStore.user.roles.includes(requiredRole)
    if (!hasRole) {
      if (authStore.isSuperAdmin) return '/admin/dashboard'
      if (authStore.isSchoolAdmin) return '/school/dashboard'
      if (authStore.isStudent) return '/student/dashboard'
      return '/'
    }
  }

  return true
})

export default router
