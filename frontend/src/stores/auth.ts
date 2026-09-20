import { defineStore } from 'pinia'
import api from '@/services/api'

export interface SchoolInfo {
  id: number
  npsn: string
  name: string
  educational_level: string
  status: string
}

export interface StudentInfo {
  id: number
  nis: string
  nisn: string
  full_name: string
  grade_level: number
  class_name: string
  public_id: string
}

export interface User {
  id: number
  name: string
  email: string
  username: string
  phone: string | null
  must_change_password: boolean
  roles: string[]
  permissions: string[]
  school: SchoolInfo | null
  student: StudentInfo | null
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: (JSON.parse(localStorage.getItem('user') || 'null') as User | null),
    token: localStorage.getItem('token') || null,
    loading: false,
    error: null as string | null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    isSuperAdmin: (state) => state.user?.roles.includes('super_admin') ?? false,
    isSchoolAdmin: (state) => state.user?.roles.includes('school_admin') ?? false,
    isStudent: (state) => state.user?.roles.includes('student') ?? false,
    primaryRole: (state): 'super_admin' | 'school_admin' | 'student' | null => {
      if (!state.user) return null
      if (state.user.roles.includes('super_admin')) return 'super_admin'
      if (state.user.roles.includes('school_admin')) return 'school_admin'
      if (state.user.roles.includes('student')) return 'student'
      return null
    },
    requiresPasswordChange: (state) => !!state.user?.must_change_password,
  },

  actions: {
    async login(identifier: string, password: string) {
      this.loading = true
      this.error = null
      try {
        const response = await api.post('/auth/login', { identifier, password })
        const { token, user } = response.data.data
        this.token = token
        this.user = user
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        return { success: true, user }
      } catch (err: any) {
        this.error = err.response?.data?.message || 'Login gagal. Periksa kembali kredensial Anda.'
        return { success: false, message: this.error }
      } finally {
        this.loading = false
      }
    },

    async fetchMe() {
      if (!this.token) return null
      try {
        const response = await api.get('/auth/me')
        this.user = response.data.data
        localStorage.setItem('user', JSON.stringify(this.user))
        return this.user
      } catch (err) {
        this.logout()
        return null
      }
    },

    async changePassword(currentPassword: string, newPassword: string, newPasswordConfirmation: string) {
      this.loading = true
      this.error = null
      try {
        const response = await api.post('/auth/change-password', {
          current_password: currentPassword,
          password: newPassword,
          password_confirmation: newPasswordConfirmation,
          new_password: newPassword,
          new_password_confirmation: newPasswordConfirmation,
        })
        if (this.user) {
          this.user.must_change_password = false
          localStorage.setItem('user', JSON.stringify(this.user))
        }
        return { success: true, message: response.data.message }
      } catch (err: any) {
        const msg = err.response?.data?.message || 'Gagal mengganti password.'
        return { success: false, message: msg }
      } finally {
        this.loading = false
      }
    },

    logout() {
      if (this.token) {
        api.post('/auth/logout').catch(() => {})
      }
      this.token = null
      this.user = null
      this.error = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    },
  },
})
