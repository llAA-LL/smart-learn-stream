import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      // RAG AI 助教后端（Spring AI + DeepSeek）
      '/api/rag': {
        target: 'http://localhost:9091',
        changeOrigin: true
      },
      '/api/agent': {
        target: 'http://localhost:5002',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/agent/, '')
      },
      '/api': {
        target: 'http://localhost:9090',
        changeOrigin: true
      }
    }
  }
})
