<template>
  <div class="page">
    <div class="page-header">
      <h2>智能推荐</h2>
      <el-button type="primary" size="large" @click="load">刷新推荐</el-button>
    </div>

    <div class="content-grid">
      <!-- Recommendations -->
      <div class="card">
        <h3 class="section-title">学习路径推荐</h3>
        <div v-if="recommendations.length === 0" class="empty-state">
          <div class="empty-icon">🔮</div>
          <p>暂无推荐，多记录学习后系统会为你生成个性化推荐</p>
        </div>
        <router-link v-for="(rec, idx) in recommendations" :key="rec.kpId"
             :to="`/knowledge-point/${rec.kpId}`"
             class="rec-card" :style="{ animationDelay: idx * 0.05 + 's' }">
          <div class="rec-left" :class="'border-' + rec.type?.toLowerCase()"></div>
          <div class="rec-body">
            <div class="rec-top">
              <span class="rec-badge" :class="'badge-' + rec.type?.toLowerCase()">
                {{ rec.type === 'REVIEW' ? '建议复习' : rec.type === 'NEXT' ? '推荐学习' : '探索新知' }}
              </span>
              <span class="rec-course" v-if="rec.courseName">{{ rec.courseName }}</span>
            </div>
            <h4 class="rec-name">{{ rec.kpName }}</h4>
            <p class="rec-reason">💡 {{ rec.reason }}</p>
          </div>
        </router-link>
      </div>
      <div class="card">
        <h3 class="section-title">
          薄弱知识点
          <el-tag type="danger" size="small" effect="plain" style="margin-left:8px">{{ weakPoints.length }} 个</el-tag>
        </h3>
        <div v-if="weakPoints.length === 0" class="empty-state">
          <div class="empty-icon">🎉</div>
          <p>太棒了！没有薄弱知识点</p>
        </div>
        <router-link v-for="wp in weakPoints" :key="wp.id"
             :to="`/knowledge-point/${wp.kpId}`" class="weak-item">
          <div class="weak-info">
            <span class="weak-name">{{ wp.kpName }}</span>
            <span class="weak-count">学习 {{ wp.learnCount }} 次</span>
          </div>
          <el-progress :percentage="wp.masteryScore" :stroke-width="8" color="#f56c6c" style="flex:1;margin:0 16px" />
        </router-link>

        <div class="algo-box">
          <h4>推荐算法</h4>
          <p>基于知识图谱的前置依赖关系 + 你的掌握度评分，系统自动推荐下一步应学习的知识点。</p>
          <p>掌握度 = 70% 历史评分 + 30% 最新自评，每次学习记录后自动更新。</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { recApi } from '../api'
const recommendations = ref([]); const weakPoints = ref([])
async function load() {
  const [r, w] = await Promise.all([recApi.recommend(), recApi.weakPoints()])
  recommendations.value = r.data.data; weakPoints.value = w.data.data
}
onMounted(load)
</script>

<style scoped>
.page { max-width: 1400px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #1a1a2e; margin: 0; }

.content-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
.card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
.section-title { font-size: 16px; font-weight: 600; color: #1a1a2e; margin: 0 0 20px; }

.rec-card {
  display: flex; gap: 0; margin-bottom: 12px; border-radius: 12px;
  background: #fafbfc; overflow: hidden;
  animation: fadeUp 0.4s ease-out both;
  text-decoration: none; cursor: pointer; transition: all 0.2s;
}
.rec-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.rec-left { width: 4px; flex-shrink: 0; }
.border-review { background: #f56c6c; }
.border-next { background: #e6a23c; }
.border-new { background: #409eff; }
.rec-body { padding: 16px; flex: 1; }
.rec-top { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
.rec-badge { font-size: 11px; font-weight: 600; padding: 2px 10px; border-radius: 20px; }
.badge-review { background: #fff0f0; color: #f56c6c; }
.badge-next { background: #fef6e8; color: #e6a23c; }
.badge-new { background: #e8f4fd; color: #409eff; }
.rec-course { font-size: 11px; color: #999; }
.rec-name { font-size: 15px; font-weight: 600; color: #1a1a2e; margin: 0 0 4px; }
.rec-reason { font-size: 12px; color: #888; margin: 0; }

.weak-item { display: flex; align-items: center; padding: 12px 0; border-bottom: 1px solid #f5f5f5; text-decoration: none; cursor: pointer; transition: all 0.2s; }
.weak-item:hover { background: #fafbfc; margin: 0 -8px; padding-left: 8px; padding-right: 8px; border-radius: 8px; }
.weak-item:last-child { border-bottom: none; }
.weak-info { width: 160px; }
.weak-name { font-size: 13px; font-weight: 500; color: #333; display: block; }
.weak-count { font-size: 11px; color: #999; }

.algo-box { margin-top: 24px; padding: 16px; background: #f8f9fc; border-radius: 12px; }
.algo-box h4 { font-size: 13px; font-weight: 600; color: #333; margin: 0 0 8px; }
.algo-box p { font-size: 12px; color: #888; margin: 0 0 4px; line-height: 1.7; }

.empty-state { text-align: center; padding: 60px 20px; color: #999; }
.empty-icon { font-size: 48px; margin-bottom: 12px; }
@keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }

@media (max-width: 900px) { .content-grid { grid-template-columns: 1fr; } }
</style>
