<template>
  <div class="page">
    <div class="page-header">
      <el-button text @click="$router.back()" class="back-btn">← 返回</el-button>
    </div>

    <div v-if="loading" class="loading-state">加载中...</div>

    <template v-else-if="kp">
      <!-- Header -->
      <div class="kp-header card">
        <div class="kp-title-row">
          <h2>{{ kp.name }}</h2>
          <el-button type="primary" size="large" @click="goToQuiz">开始自测</el-button>
        </div>
        <div class="kp-meta">
          <el-tag type="info" size="small">{{ kp.courseName }}</el-tag>
          <span class="meta-level">L{{ kp.level }} 级知识点</span>
          <span v-if="masteryScore !== null" class="meta-mastery">
            掌握度：
            <el-progress :percentage="masteryScore" :stroke-width="8"
              :color="masteryScore >= 60 ? '#11998e' : '#f56c6c'"
              style="width:120px;display:inline-flex;vertical-align:middle" />
          </span>
        </div>
      </div>

      <!-- Learning Content -->
      <div class="content-card card">
        <h3 class="section-title">学习内容</h3>
        <div class="learning-content" v-html="renderedContent"></div>
      </div>

      <!-- Prerequisites -->
      <div class="related-card card" v-if="prerequisites.length > 0">
        <h3 class="section-title">前置知识点</h3>
        <div class="related-list">
          <router-link v-for="pre in prerequisites" :key="pre.id"
            :to="`/knowledge-point/${pre.id}`" class="related-link">
            {{ pre.name }}
          </router-link>
        </div>
      </div>

      <div class="related-card card" v-if="followUpKps.length > 0">
        <h3 class="section-title">后续知识点</h3>
        <div class="related-list">
          <router-link v-for="kp in followUpKps" :key="kp.id"
            :to="`/knowledge-point/${kp.id}`" class="related-link">
            {{ kp.name }}
          </router-link>
        </div>
      </div>

      <!-- Quiz History -->
      <div class="history-card card" v-if="quizHistory.length > 0">
        <h3 class="section-title">自测历史</h3>
        <el-table :data="quizHistory" stripe style="width:100%">
          <el-table-column label="分数" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="row.score >= 60 ? 'success' : 'danger'" size="small" effect="dark">
                {{ row.score }}分
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="正确率" width="120" align="center">
            <template #default="{ row }">
              {{ row.correctCount }}/{{ row.totalQuestions }}
            </template>
          </el-table-column>
          <el-table-column prop="completedAt" label="完成时间" align="center" />
        </el-table>
      </div>

      <!-- Actions -->
      <div class="actions-card">
        <el-button size="large" @click="goToQuiz" type="primary">开始自测</el-button>
        <el-button size="large" @click="$router.back()">返回</el-button>
      </div>
    </template>

    <div v-else class="empty-state">
      <p>知识点不存在</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { kgApi, quizApi, recordApi } from '../api'

const route = useRoute()
const router = useRouter()
const kp = ref(null)
const loading = ref(true)
const masteryScore = ref(null)
const quizHistory = ref([])
const prerequisites = ref([])
const followUpKps = ref([])

const renderedContent = computed(() => {
  const md = kp.value?.learningContent || kp.value?.description || ''
  if (!md) return '<p>暂无学习内容</p>'
  return renderMarkdown(md)
})

function renderMarkdown(md) {
  let html = md
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

  // Code blocks (``` ... ```)
  html = html.replace(/```(\w*)\n([\s\S]*?)```/g, (_, lang, code) => {
    return `<pre class="code-block"><code class="${lang || ''}">${code.trim()}</code></pre>`
  })

  // Inline code
  html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>')

  // Headings
  html = html.replace(/^### (.+)$/gm, '<h4>$1</h4>')
  html = html.replace(/^## (.+)$/gm, '<h3>$1</h3>')
  html = html.replace(/^# (.+)$/gm, '<h2>$1</h2>')

  // Bold
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')

  // Unordered lists
  html = html.replace(/^- (.+)$/gm, '<li>$1</li>')
  html = html.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')

  // Ordered lists
  html = html.replace(/^\d+\. (.+)$/gm, '<li>$1</li>')

  // Paragraphs (double newlines)
  html = html.replace(/\n\n/g, '</p><p>')

  // Single newlines → <br>
  html = html.replace(/\n/g, '<br>')

  return '<p>' + html + '</p>'
}

function goToQuiz() {
  if (kp.value) {
    router.push(`/self-test?kpId=${kp.value.id}&courseId=${kp.value.courseId}`)
  }
}

onMounted(async () => {
  const id = route.params.id
  try {
    const [kpRes, masteryRes, quizRes] = await Promise.all([
      kgApi.getNode(id),
      recordApi.mastery().catch(() => ({ data: { data: [] } })),
      quizApi.history().catch(() => ({ data: { data: [] } }))
    ])

    kp.value = kpRes.data.data
    if (!kp.value) { loading.value = false; return }

    // Get mastery for this KP
    const allMastery = masteryRes.data.data || []
    const m = allMastery.find(m => m.kpId === kp.value.id)
    masteryScore.value = m ? m.masteryScore : null

    // Filter quiz history for this KP
    const allHistory = quizRes.data.data || []
    quizHistory.value = allHistory.filter(h => h.kpId === kp.value.id)

    // Load prerequisites
    const allKpsRes = await kgApi.listNodes()
    const allKps = allKpsRes.data.data || []

    // Find prerequisites (KPs that this KP depends on)
    const prereqIds = kp.value.prerequisiteIds || []
    prerequisites.value = allKps.filter(k => prereqIds.includes(k.id))

    // Find follow-up KPs (KPs that depend on this KP, same course)
    followUpKps.value = allKps.filter(k =>
      k.courseId === kp.value.courseId &&
      (k.prerequisiteIds || []).includes(kp.value.id)
    )
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page { max-width: 900px; margin: 0 auto; }
.page-header { margin-bottom: 16px; }
.back-btn { font-size: 14px; color: #0f766e; }

.loading-state { text-align: center; padding: 80px 0; color: #999; font-size: 15px; }
.empty-state { text-align: center; padding: 80px 0; color: #999; }

.card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); margin-bottom: 20px; }

/* Header */
.kp-header { padding: 28px; }
.kp-title-row { display: flex; justify-content: space-between; align-items: center; }
.kp-title-row h2 { font-size: 22px; font-weight: 700; color: #18181b; margin: 0; }
.kp-meta { display: flex; align-items: center; gap: 16px; margin-top: 12px; flex-wrap: wrap; }
.meta-level { font-size: 13px; color: #999; }
.meta-mastery { font-size: 13px; color: #666; display: flex; align-items: center; gap: 8px; }

/* Learning content */
.section-title { font-size: 16px; font-weight: 600; color: #18181b; margin: 0 0 16px; }

.learning-content {
  font-size: 14px; color: #444; line-height: 1.8;
}
.learning-content :deep(h2) { font-size: 18px; color: #18181b; margin: 24px 0 12px; padding-bottom: 8px; border-bottom: 2px solid #0f766e; }
.learning-content :deep(h3) { font-size: 16px; color: #333; margin: 20px 0 10px; }
.learning-content :deep(h4) { font-size: 14px; color: #555; margin: 16px 0 8px; }
.learning-content :deep(p) { margin: 0 0 8px; }
.learning-content :deep(strong) { color: #18181b; }
.learning-content :deep(ul) { margin: 8px 0; padding-left: 20px; }
.learning-content :deep(li) { margin-bottom: 4px; }
.learning-content :deep(.inline-code) {
  background: #f4f4f5; color: #0f766e; padding: 2px 6px; border-radius: 4px;
  font-family: 'Consolas', 'Courier New', monospace; font-size: 13px;
}
.learning-content :deep(.code-block) {
  background: #1e1e2e; color: #cdd6f4;
  padding: 16px; border-radius: 10px;
  overflow-x: auto; margin: 12px 0;
  font-family: 'Consolas', 'Courier New', monospace; font-size: 13px;
  line-height: 1.6;
}

/* Related */
.related-list { display: flex; flex-wrap: wrap; gap: 8px; }
.related-link {
  display: inline-block; padding: 6px 14px;
  background: #f0fdfa; color: #0f766e; border-radius: 20px;
  font-size: 13px; text-decoration: none; transition: all 0.2s;
}
.related-link:hover { background: #0f766e; color: #fff; }

/* Actions */
.actions-card { display: flex; gap: 12px; justify-content: center; margin-top: 24px; }
</style>
