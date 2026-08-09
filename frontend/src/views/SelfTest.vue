<template>
  <div class="page">
    <div class="page-header">
      <h2>知识点自测</h2>
    </div>

    <!-- KP Selector -->
    <div class="select-card card">
      <div class="select-row">
        <div class="select-item">
          <label>选择课程</label>
          <el-select v-model="selectedCourse" placeholder="选择课程" size="large" style="width:100%"
                     @change="onCourseChange">
            <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </div>
        <div class="select-arrow">→</div>
        <div class="select-item">
          <label>选择知识点</label>
          <el-select v-model="selectedKp" placeholder="选择知识点" size="large" style="width:100%"
                     :disabled="!selectedCourse">
            <el-option v-for="kp in filteredKps" :key="kp.id" :label="kp.name" :value="kp.id" />
          </el-select>
        </div>
        <el-button type="primary" size="large" :disabled="!selectedKp" @click="startQuiz"
                   :loading="generating" class="start-btn">
          开始自测
        </el-button>
        <router-link v-if="selectedKp" :to="`/knowledge-point/${selectedKp}`"
                     class="go-learn-link">先学习</router-link>
      </div>
      <div v-if="selectedKp && lastScore !== null" class="last-score">
        上次成绩：<b :class="lastScore >= 60 ? 'text-green' : 'text-red'">{{ lastScore }}分</b>
      </div>
    </div>

    <!-- Quiz Area -->
    <div class="card quiz-area" v-if="step !== 'select'">
      <!-- Loading -->
      <div v-if="step === 'loading'" class="quiz-loading">
        <p>正在生成题目...</p>
      </div>

      <!-- Questions -->
      <div v-else-if="step === 'quiz'" class="quiz-questions">
        <h3 class="quiz-kp-name">{{ selectedKpName }}</h3>
        <div v-for="(q, idx) in questions" :key="q.id" class="quiz-question">
          <div class="q-header">
            <span class="q-num">{{ idx + 1 }}</span>
            <el-tag size="small" :type="q.questionType === 'MULTI_CHOICE' ? 'warning' : 'primary'">
              {{ q.questionType === 'SINGLE_CHOICE' ? '单选' : q.questionType === 'MULTI_CHOICE' ? '多选' : '判断' }}
            </el-tag>
            <span class="q-difficulty">{{ '★'.repeat(q.difficulty || 1) }}</span>
          </div>
          <p class="q-content">{{ q.content }}</p>
          <div class="q-options">
            <template v-if="q.questionType === 'TRUE_FALSE'">
              <el-radio-group v-model="answers[q.id]" class="option-group">
                <el-radio value="true" class="option-item">正确</el-radio>
                <el-radio value="false" class="option-item">错误</el-radio>
              </el-radio-group>
            </template>
            <template v-else-if="q.questionType === 'SINGLE_CHOICE'">
              <el-radio-group v-model="answers[q.id]" class="option-group">
                <el-radio v-for="opt in parseOptions(q.options)" :key="opt.key"
                          :value="opt.key" class="option-item">
                  {{ opt.key }}. {{ opt.text }}
                </el-radio>
              </el-radio-group>
            </template>
            <template v-else>
              <el-checkbox-group v-model="answers[q.id]" class="option-group">
                <el-checkbox v-for="opt in parseOptions(q.options)" :key="opt.key"
                             :label="opt.key" :value="opt.key" class="option-item">
                  {{ opt.key }}. {{ opt.text }}
                </el-checkbox>
              </el-checkbox-group>
            </template>
          </div>
        </div>
        <el-button type="primary" size="large" @click="submitQuiz" :loading="submitting"
                   :disabled="!allAnswered" style="width:100%;margin-top:20px">
          提交
        </el-button>
      </div>

      <!-- Results -->
      <div v-else-if="step === 'result'" class="quiz-result">
        <div class="result-summary">
          <div class="result-circle" :class="result.passed ? 'passed' : 'failed'">
            <span class="result-num">{{ result.score }}</span>
            <span class="result-label">分</span>
          </div>
          <div class="result-info">
            <p class="result-count">{{ result.correctCount }} / {{ result.totalQuestions }} 正确</p>
            <el-tag :type="result.passed ? 'success' : 'danger'" size="large">
              {{ result.passed ? '已通过' : '未通过，继续加油' }}
            </el-tag>
          </div>
        </div>

        <div class="result-breakdown">
          <h4>答题详情</h4>
          <div v-for="(a, idx) in result.answers" :key="a.questionId" class="breakdown-item"
               :class="a.correct ? 'bd-correct' : 'bd-wrong'">
            <div class="bd-header">
              <span :class="['bd-icon', a.correct ? 'icon-ok' : 'icon-wrong']">
                {{ a.correct ? '✓' : '✗' }}
              </span>
              <span class="bd-num">第{{ idx + 1 }}题</span>
            </div>
            <p class="bd-content">{{ a.questionContent }}</p>
            <div class="bd-answers">
              <span>你的答案：<b :class="a.correct ? 'text-green' : 'text-red'">{{ a.userAnswer || '未作答' }}</b></span>
              <span v-if="!a.correct">正确答案：<b class="text-green">{{ a.correctAnswer }}</b></span>
            </div>
            <p v-if="a.explanation" class="bd-explain">{{ a.explanation }}</p>
          </div>
        </div>

        <div class="result-actions">
          <el-button size="large" @click="resetQuiz">再来一次</el-button>
          <el-button size="large" type="primary" @click="backToSelect">选择其他知识点</el-button>
        </div>
      </div>
    </div>

    <!-- History -->
    <div class="card" v-if="history.length > 0">
      <h3 class="section-title">自测历史</h3>
      <el-table :data="history" stripe style="width:100%">
        <el-table-column prop="kpName" label="知识点" />
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
        <el-table-column prop="completedAt" label="时间" width="170" align="center" />
      </el-table>
      <div v-if="historyTotal > historyPageSize" class="pagination-wrap">
        <el-pagination background layout="prev, pager, next, total" :total="historyTotal"
                       :page-size="historyPageSize" :current-page="historyPage"
                       @current-change="onHistoryPageChange" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { quizApi, courseApi, kgApi } from '../api'

const route = useRoute()

const courses = ref([])
const kps = ref([])
const selectedCourse = ref(null)
const selectedKp = ref(null)
const generating = ref(false)
const submitting = ref(false)
const history = ref([])
const historyPage = ref(1)
const historyPageSize = ref(10)
const historyTotal = ref(0)

const step = ref('select')  // select | loading | quiz | result
const questions = ref([])
const answers = reactive({})
const result = ref({})

const filteredKps = computed(() => {
  if (!selectedCourse.value) return []
  return kps.value.filter(k => k.courseId === selectedCourse.value)
})

const selectedKpName = computed(() => {
  const kp = kps.value.find(k => k.id === selectedKp.value)
  return kp?.name || ''
})

const lastScore = computed(() => {
  const h = history.value.filter(h => h.kpId === selectedKp.value)
  return h.length > 0 ? h[0].score : null
})

const allAnswered = computed(() => {
  return questions.value.every(q => {
    const a = answers[q.id]
    if (q.questionType === 'MULTI_CHOICE') return a && a.length > 0
    return !!a
  })
})

function parseOptions(opts) {
  if (!opts) return []
  try { return typeof opts === 'string' ? JSON.parse(opts) : opts } catch { return [] }
}

function onCourseChange() {
  selectedKp.value = null
  step.value = 'select'
}

async function loadData() {
  const [c, k, h] = await Promise.all([
    courseApi.list(), kgApi.listNodes(),
    quizApi.history({ page: historyPage.value, pageSize: historyPageSize.value })
      .catch(() => ({ data: { data: { list: [], total: 0 } } }))
  ])
  courses.value = c.data.data
  kps.value = k.data.data
  history.value = h.data.data.list || []
  historyTotal.value = h.data.data.total || 0

  function onHistoryPageChange(p) {
    historyPage.value = p
    loadData()
  }

  // Handle query params: pre-select course and KP from detail page
  const qKpId = route.query.kpId
  const qCourseId = route.query.courseId
  if (qKpId && qCourseId) {
    selectedCourse.value = Number(qCourseId)
    selectedKp.value = Number(qKpId)
  }
}

async function startQuiz() {
  generating.value = true
  step.value = 'loading'
  for (const k in answers) delete answers[k]
  try {
    const res = await quizApi.generate(selectedKp.value)
    questions.value = res.data.data
    questions.value.forEach(q => {
      if (q.questionType === 'MULTI_CHOICE') answers[q.id] = []
    })
    step.value = 'quiz'
  } catch {
    step.value = 'select'
  }
  generating.value = false
}

async function submitQuiz() {
  submitting.value = true
  const answerList = questions.value.map(q => ({
    questionId: q.id,
    userAnswer: q.questionType === 'MULTI_CHOICE'
      ? (answers[q.id] || []).sort().join('')
      : answers[q.id] || ''
  }))
  try {
    const res = await quizApi.submit({ kpId: selectedKp.value, answers: answerList })
    result.value = res.data.data
    step.value = 'result'
    loadData() // refresh history
  } catch { /* shown by interceptor */ }
  submitting.value = false
}

function resetQuiz() {
  for (const k in answers) delete answers[k]
  questions.value = []
  result.value = {}
  startQuiz()
}

function backToSelect() {
  step.value = 'select'
  questions.value = []
  result.value = {}
  for (const k in answers) delete answers[k]
}

onMounted(loadData)
</script>

<style scoped>
.page { max-width: 900px; margin: 0 auto; }
.page-header { margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #1a1a2e; margin: 0; }

.card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); margin-bottom: 20px; }

/* Selector */
.select-card { padding: 28px; }
.select-row { display: flex; align-items: flex-end; gap: 16px; }
.select-item { flex: 1; }
.select-item label { display: block; font-size: 13px; color: #999; margin-bottom: 6px; }
.select-arrow { font-size: 24px; color: #ccc; padding-bottom: 12px; }
.start-btn { min-width: 120px; height: 40px; }
.go-learn-link {
  font-size: 13px; color: #11998e; text-decoration: none;
  padding: 8px 16px; border: 1px solid #11998e44; border-radius: 8px;
  transition: all 0.2s; white-space: nowrap; align-self: flex-end; margin-bottom: 4px;
}
.go-learn-link:hover { background: #11998e; color: #fff; }
.last-score { margin-top: 12px; font-size: 13px; color: #999; }
.text-green { color: #11998e; }
.text-red { color: #f5576c; }

/* Quiz area */
.quiz-area { min-height: 200px; }
.quiz-loading { text-align: center; padding: 80px 0; color: #999; font-size: 15px; }
.quiz-kp-name { font-size: 16px; color: #1a1a2e; margin: 0 0 20px; padding-bottom: 12px; border-bottom: 2px solid #667eea; }

/* Questions */
.quiz-question { margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
.quiz-question:last-child { border-bottom: none; }
.q-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.q-num {
  width: 24px; height: 24px; border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff; display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 600;
}
.q-difficulty { font-size: 11px; color: #e6a23c; margin-left: auto; }
.q-content { font-size: 15px; color: #333; margin: 0 0 10px; line-height: 1.6; }
.option-group { display: flex; flex-direction: column; gap: 4px; width: 100%; }
.option-item { margin: 0; padding: 10px 14px; border-radius: 8px; width: 100%; }
.option-item:hover { background: #f5f5ff; }

/* Results */
.result-summary { display: flex; align-items: center; gap: 24px; padding-bottom: 20px; border-bottom: 1px solid #f0f0f0; margin-bottom: 20px; }
.result-circle {
  width: 90px; height: 90px; border-radius: 50%; display: flex; flex-direction: column;
  align-items: center; justify-content: center; color: #fff; flex-shrink: 0;
}
.result-circle.passed { background: linear-gradient(135deg, #11998e, #38ef7d); }
.result-circle.failed { background: linear-gradient(135deg, #f093fb, #f5576c); }
.result-num { font-size: 32px; font-weight: 700; line-height: 1; }
.result-label { font-size: 14px; }
.result-count { font-size: 16px; color: #333; margin: 0 0 6px; }
.result-info p { margin: 0 0 6px; }

.result-breakdown h4 { font-size: 14px; color: #666; margin: 0 0 12px; }
.breakdown-item { padding: 14px; margin-bottom: 10px; border-radius: 10px; }
.breakdown-item.bd-correct { background: #f0fdf4; border: 1px solid #bbf7d0; }
.breakdown-item.bd-wrong { background: #fef2f2; border: 1px solid #fecaca; }
.bd-header { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
.bd-icon { font-weight: 700; font-size: 16px; }
.icon-ok { color: #11998e; }
.icon-wrong { color: #dc2626; }
.bd-num { font-size: 12px; color: #999; }
.bd-content { font-size: 13px; color: #333; margin: 4px 0; }
.bd-answers { display: flex; gap: 20px; font-size: 13px; color: #666; }
.bd-explain { font-size: 12px; color: #999; margin: 6px 0 0; padding-top: 6px; border-top: 1px dashed #e8e8e8; }

.result-actions { display: flex; gap: 12px; justify-content: center; margin-top: 24px; }

/* History */
.section-title { font-size: 16px; font-weight: 600; color: #1a1a2e; margin: 0 0 16px; }
</style>
