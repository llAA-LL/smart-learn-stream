<template>
  <div class="dashboard">
    <!-- Stats Row -->
    <div class="stats-row">
      <div class="stat-card stat-today">
        <div class="stat-inner">
          <div class="stat-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
          </div>
          <div class="stat-body">
            <div class="stat-value">{{ stats.todayMinutes || 0 }}</div>
            <div class="stat-label">今日学习 (分钟)</div>
          </div>
        </div>
        <div class="stat-glow"></div>
      </div>
      <div class="stat-card stat-week">
        <div class="stat-inner">
          <div class="stat-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
          </div>
          <div class="stat-body">
            <div class="stat-value">{{ stats.weekMinutes || 0 }}</div>
            <div class="stat-label">近7天 (分钟)</div>
          </div>
        </div>
        <div class="stat-glow"></div>
      </div>
      <div class="stat-card stat-total">
        <div class="stat-inner">
          <div class="stat-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
          </div>
          <div class="stat-body">
            <div class="stat-value">{{ stats.totalMinutes || 0 }}</div>
            <div class="stat-label">累计学习 (分钟)</div>
          </div>
        </div>
        <div class="stat-glow"></div>
      </div>
    </div>

    <!-- Chart + Quick view -->
    <div class="content-row">
      <div class="card chart-card">
        <div class="card-header">
          <h3>学习趋势</h3>
          <span class="card-sub">近30天</span>
        </div>
        <div ref="chartRef" class="chart-container"></div>
      </div>

      <div class="card rec-card">
        <div class="card-header">
          <h3>今日推荐</h3>
          <router-link to="/recommendations" class="card-link">查看全部 →</router-link>
        </div>
        <div v-if="recommendations.length === 0" class="empty-state">
          <div class="empty-icon">
            <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
          </div>
          <p>暂无推荐，先记录学习吧</p>
        </div>
        <router-link v-for="(rec, idx) in recommendations.slice(0, 5)" :key="rec.kpId"
             :to="`/knowledge-point/${rec.kpId}`"
             class="rec-item" :style="{ animationDelay: idx * 0.05 + 's' }">
          <span class="rec-tag" :class="'tag-' + rec.type?.toLowerCase()">
            {{ rec.type === 'REVIEW' ? '复习' : rec.type === 'NEXT' ? '下一步' : '新知识' }}
          </span>
          <span class="rec-name">{{ rec.kpName }}</span>
          <span class="rec-course" v-if="rec.courseName">{{ rec.courseName }}</span>
        </router-link>
      </div>
    </div>

    <!-- Plans -->
    <div class="card plans-card">
      <div class="card-header">
        <h3>学习计划</h3>
        <router-link to="/plans" class="card-link">查看全部 →</router-link>
      </div>
      <div v-if="plans.length === 0" class="empty-state">
        <div class="empty-icon">
          <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        </div>
        <p>暂无学习计划</p>
        <el-button type="primary" size="small" @click="router.push('/plans')">创建计划</el-button>
      </div>
      <div class="plans-grid" v-else>
        <div v-for="plan in plans.slice(0, 3)" :key="plan.id" class="plan-card">
          <div class="plan-head">
            <span class="plan-title">{{ plan.title }}</span>
            <el-tag :type="plan.status === 'ACTIVE' ? 'success' : 'info'" size="small" effect="plain">
              {{ plan.status === 'ACTIVE' ? '进行中' : '已完成' }}
            </el-tag>
          </div>
          <el-progress
            :percentage="plan.progressPercent || 0"
            :stroke-width="8"
            :color="gradientColor"
            style="margin:12px 0"
          />
          <div class="plan-meta">
            <span>{{ plan.startDate }} ~ {{ plan.endDate }}</span>
            <span>{{ plan.progressPercent }}%</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { graphic } from 'echarts/core'
import { recordApi, planApi, recApi } from '../api'
import { useAsyncData } from '../composables/useAsyncData'
import { useChart } from '../composables/useChart'

/**
 * @typedef {import('../api/types.js').LearningStats} LearningStats
 * @typedef {import('../api/types.js').LearningPlan} LearningPlan
 * @typedef {import('../api/types.js').Recommendation} Recommendation
 */

const router = useRouter()

/** @type {import('vue').Ref<LearningStats>} */
const { data: stats, run: loadStats } = useAsyncData({})
/** @type {import('vue').Ref<LearningPlan[]>} */
const { data: plans, run: loadPlans } = useAsyncData([])
/** @type {import('vue').Ref<Recommendation[]>} */
const { data: recommendations, run: loadRecs } = useAsyncData([])

const chartRef = ref(null)
const chart = useChart(chartRef)
const gradientColor = ['#0d9488', '#4f46e5']

onMounted(async () => {
  try {
    await Promise.all([
      loadStats(() => recordApi.stats().then(r => r.data.data)),
      loadPlans(() => planApi.list().then(r => r.data.data)),
      loadRecs(() => recApi.recommend().then(r => r.data.data))
    ])
    renderTrendChart()
  } catch {
    // 拦截器已统一提示错误，这里仅兜底，避免未捕获的 Promise 异常
  }
})

/**
 * 基于加载到的统计数据渲染「学习趋势」折线图。
 * 图表实例由 useChart 管理：懒初始化、容器尺寸自适应、卸载自动销毁。
 */
function renderTrendChart() {
  const dailyData = stats.value.dailyStats || []
  chart.render({
    tooltip: {
      trigger: 'axis',
      backgroundColor: '#fff',
      borderColor: '#e8e8e8',
      textStyle: { color: '#334155' },
      boxShadow: '0 8px 24px rgba(15,23,42,0.12)'
    },
    grid: { left: 44, right: 24, top: 20, bottom: 24 },
    xAxis: {
      type: 'category', data: dailyData.map(d => d.date),
      axisLine: { lineStyle: { color: 'rgba(15,23,42,0.1)' } },
      axisLabel: { color: '#94a3b8', fontSize: 11 }
    },
    yAxis: {
      type: 'value', name: '分钟',
      splitLine: { lineStyle: { color: 'rgba(15,23,42,0.06)' } },
      axisLabel: { color: '#94a3b8' }
    },
    series: [{
      data: dailyData.map(d => d.minutes),
      type: 'line', smooth: true,
      symbol: 'circle', symbolSize: 6,
      lineStyle: { width: 3, color: '#0d9488' },
      itemStyle: { color: '#0d9488' },
      areaStyle: {
        color: new graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(13,148,136,0.24)' },
          { offset: 1, color: 'rgba(13,148,136,0.01)' }
        ])
      }
    }]
  })
}
</script>

<style scoped>
.dashboard { max-width: 1400px; margin: 0 auto; }

/* Stats */
.stats-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
.stat-card {
  position: relative; border-radius: 16px; padding: 24px;
  overflow: hidden; animation: fadeUp 0.5s ease-out both;
}
.stat-card:nth-child(2) { animation-delay: 0.1s; }
.stat-card:nth-child(3) { animation-delay: 0.2s; }
.stat-today { background: linear-gradient(135deg, #0d9488, #2dd4bf); }
.stat-week { background: linear-gradient(135deg, #4f46e5, #6366f1); }
.stat-total { background: linear-gradient(135deg, #d97706, #f59e0b); }
.stat-inner { display: flex; align-items: center; gap: 16px; position: relative; z-index: 1; }
.stat-icon { width: 52px; height: 52px; border-radius: 14px; background: rgba(255,255,255,0.2); display: flex; align-items: center; justify-content: center; }
.stat-body { color: #fff; }
.stat-value { font-size: 32px; font-weight: 700; line-height: 1.2; }
.stat-label { font-size: 13px; opacity: 0.85; margin-top: 2px; }
.stat-glow {
  position: absolute; right: -30px; top: -30px;
  width: 120px; height: 120px; border-radius: 50%;
  background: rgba(255,255,255,0.1);
}

/* Content row */
.content-row { display: grid; grid-template-columns: 1.5fr 1fr; gap: 20px; margin-bottom: 24px; }
.card {
  background: var(--surface); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  animation: fadeUp 0.5s ease-out both;
}
.chart-card { padding: 24px; animation-delay: 0.3s; }
.rec-card { padding: 24px; animation-delay: 0.4s; }
.card-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 16px;
}
.card-header h3 { font-size: 16px; font-weight: 650; color: var(--text-1); margin: 0; letter-spacing: -0.01em; }
.card-sub { font-size: 12px; color: var(--text-3); }
.card-link { font-size: 13px; color: var(--accent); text-decoration: none; transition: color 0.15s ease; }
.card-link:hover { color: var(--accent-hover); }
.chart-container { height: 280px; }

/* Recommendations */
.rec-item {
  display: flex; align-items: center; gap: 10px;
  padding: 12px; margin-bottom: 8px;
  border-radius: 10px; background: #f8f9fc;
  animation: fadeUp 0.4s ease-out both;
  text-decoration: none; cursor: pointer;
  transition: background 0.18s ease, transform 0.18s ease;
}
.rec-item:hover { background: var(--accent-soft); transform: translateX(2px); }
.rec-tag {
  font-size: 11px; font-weight: 600; padding: 2px 8px;
  border-radius: 6px; white-space: nowrap;
}
.tag-review { background: var(--rose-soft); color: var(--rose); }
.tag-next { background: var(--amber-soft); color: var(--amber); }
.tag-new { background: var(--sky-soft); color: var(--sky); }
.rec-name { flex: 1; font-size: 13px; font-weight: 500; color: var(--text-1); }
.rec-course { font-size: 11px; color: var(--text-3); }

/* Plans */
.plans-card { padding: 24px; margin-bottom: 24px; animation-delay: 0.5s; }
.plans-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
.plan-card {
  padding: 20px; border-radius: 12px;
  border: 1px solid var(--border);
  transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}
.plan-card:hover {
  border-color: var(--accent-border);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}
.plan-head { display: flex; justify-content: space-between; align-items: center; }
.plan-title { font-weight: 600; font-size: 14px; color: var(--text-1); }
.plan-meta { display: flex; justify-content: space-between; font-size: 12px; color: var(--text-3); }

/* Empty */
.empty-state { text-align: center; padding: 40px 20px; color: var(--text-3); }
.empty-state .empty-icon {
  width: 52px; height: 52px;
  margin: 0 auto 12px;
  padding: 11px;
  border-radius: 16px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--accent);
  display: flex; align-items: center; justify-content: center;
}
.empty-state p { font-size: 14px; margin: 0; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 1200px) {
  .stats-row { grid-template-columns: repeat(3, 1fr); }
  .content-row { grid-template-columns: 1fr; }
  .plans-grid { grid-template-columns: 1fr; }
}
</style>
