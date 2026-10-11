import axios from 'axios'

export const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || '/api/v1').replace(/\/+$/, '')
export const STORAGE_BASE_URL = (import.meta.env.VITE_STORAGE_BASE_URL || (import.meta.env.VITE_API_BASE_URL ? import.meta.env.VITE_API_BASE_URL.replace(/\/api(\/v1)?\/?$/, '') + '/storage' : '/storage')).replace(/\/+$/, '')

export function getStorageUrl(path: string | null | undefined): string | null {
  if (!path) return null
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  const cleanPath = path.replace(/^\/+/, '')
  return `${STORAGE_BASE_URL}/${cleanPath}`
}

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
  withCredentials: false,
})

// Request Interceptor: Attach Sanctum Bearer Token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
}, (error) => {
  return Promise.reject(error)
})

// Response Interceptor: Handle Token Expiration
api.interceptors.response.use((response) => {
  return response
}, (error) => {
  if (error.response && error.response.status === 401) {
    // If not already on login page, clear token and redirect
    if (window.location.pathname !== '/login') {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login?expired=1'
    }
  }
  return Promise.reject(error)
})

export function extractList<T = any>(payload: any): T[] {
  if (!payload) return []
  if (Array.isArray(payload)) return payload
  if (payload.data && Array.isArray(payload.data)) return payload.data
  return []
}

export default api
export { api }

