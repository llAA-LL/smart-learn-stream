<template>
  <div class="page">
    <div class="page-header">
      <h2>学习计划</h2>
      <el-button type="primary" size="large" @click="openCreate">+ 创建计划</el-button>
    </div>

    <div v-if="plans.length === 0" class="empty-state big-empty">
      <div class="empty-icon">📋</div><p>还没有学习计划</p>
      <el-button type="primary" @click="openCreate">创建第一个计划</el-button>
    </div>

    <div class="plans-grid" v-else>
      <div v-for="plan in plans" :key="plan.id" class="plan-card">
        <div class="plan-header">
          <h4 class="plan-title">{{ plan.title }}</h4>
          <el-tag :type="plan.status === 'ACTIVE' ? 'success' : 'info'" size="small" effect="plain">
            {{ plan.status === 'ACTIVE' ? '进行中' : plan.status === 'COMPLETED' ? '已完成' : '已暂停' }}
          </el-tag>
        </div>
        <p class="plan-desc">{{ plan.description || '暂无描述' }}</p>
        <el-progress :percentage="plan.progressPercent || 0" :stroke-width="8"
                     :color="['#0f766e', '#14b8a6']" style="margin:16px 0" />
        <div class="plan-date">{{ plan.startDate }} ~ {{ plan.endDate }}</div>
        <div class="plan-items">
          <div v-for="item in (plan.items || [])" :key="item.id" class="plan-item">
            <span class="item-status">
              <span v-if="item.completed" class="status-done">✓</span>
              <span v-else class="status-todo">○</span>
            </span>
            <span :class="['item-name', { done: item.completed }]">
              {{ item.courseName || item.kpName || '未命名' }}
            </span>
            <el-tag v-if="item.completed && item.completedScore" size="small" effect="dark"
                    :type="item.completedScore >= 60 ? 'success' : 'danger'" class="score-tag">
              {{ item.completedScore }}分
            </el-tag>
            <template v-if="!item.completed && item.kpId">
              <router-link :to="`/knowledge-point/${item.kpId}`" class="learn-link">学习</router-link>
              <el-button size="small" type="primary" plain
                       @click="startQuiz(plan, item)" class="quiz-btn">
                自测
              </el-button>
            </template>
            <el-tag v-if="item.completed && !item.kpId" size="small" type="success" effect="plain" class="score-tag">
              已完成
            </el-tag>
          </div>
        </div>
        <div class="plan-footer">
          <el-button link type="danger" @click="handleDelete(plan.id)">删除</el-button>
        </div>
      </div>
    </div>

    <!-- Create Plan Dialog -->
    <el-dialog :modelValue="showDialog" @update:modelValue="showDialog = $event" title="创建学习计划" width="520px" center>
      <el-form :model="form" label-position="top">
        <el-form-item label="标题">
          <el-input v-model="form.title" placeholder="如：Java 进阶学习计划" size="large" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" />
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="开始日期">
              <el-date-picker v-model="form.startDate" type="date" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结束日期">
              <el-date-picker v-model="form.endDate" type="date" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="计划内容">
          <div v-for="(item, idx) in form.items" :key="idx" class="item-row">
            <el-select v-model="item.itemType" style="width:90px" @change="item.courseId=null;item.kpId=null">
              <el-option label="课程" value="COURSE" /><el-option label="知识点" value="KNOWLEDGE_POINT" />
            </el-select>
            <el-select v-if="item.itemType==='COURSE'" v-model="item.courseId" style="flex:1" placeholder="选课程">
              <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
            </el-select>
            <el-select v-else v-model="item.kpId" style="flex:1" placeholder="选知识点">
              <el-option v-for="kp in kps" :key="kp.id" :label="kp.name" :value="kp.id" />
            </el-select>
            <el-button circle size="small" @click="form.items.splice(idx,1)">✕</el-button>
          </div>
          <el-button size="small" @click="form.items.push({itemType:'COURSE',courseId:null,kpId:null})">+ 添加</el-button>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleCreate">创建</el-button>
      </template>
    </el-dialog>

    <!-- Quiz Dialog -->
    <el-dialog :modelValue="quizActive" @update:modelValue="closeQuiz" title="知识点自测" width="640px" center
               :close-on-click-modal="false">
      <!-- Loading -->
      <div v-if="quizLoading" class="quiz-loading">
        <el-icon class="is-loading" :size="32"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg></el-icon>
        <p>正在生成题目...</p>
      </div>

      <!-- Questions -->
      <div v-else-if="!quizSubmitted" class="quiz-questions">
        <div v-for="(q, idx) in quizQuestions" :key="q.id" class="quiz-question">
          <div class="q-header">
            <span class="q-num">{{ idx + 1 }}</span>
            <el-tag size="small" :type="q.questionType === 'MULTI_CHOICE' ? 'warning' : 'primary'">
              {{ q.questionType === 'SINGLE_CHOICE' ? '单选' : q.questionType === 'MULTI_CHOICE' ? '多选' : '判断' }}
            </el-tag>
          </div>
          <p class="q-content">{{ q.content }}</p>
          <div class="q-options">
            <template v-if="q.questionType === 'TRUE_FALSE'">
              <el-radio-group v-model="quizAnswers[q.id]" class="option-group">
                <el-radio value="true" class="option-item">正确</el-radio>
                <el-radio value="false" class="option-item">错误</el-radio>
              </el-radio-group>
            </template>
            <template v-else-if="q.questionType === 'SINGLE_CHOICE'">
              <el-radio-group v-model="quizAnswers[q.id]" class="option-group">
                <el-radio v-for="opt in parseOptions(q.options)" :key="opt.key"
                          :value="opt.key" class="option-item">
                  {{ opt.key }}. {{ opt.text }}
                </el-radio>
              </el-radio-group>
            </template>
            <template v-else>
              <el-checkbox-group v-model="quizAnswers[q.id]" class="option-group">
                <el-checkbox v-for="opt in parseOptions(q.options)" :key="opt.key"
                             :label="opt.key" :value="opt.key" class="option-item">
                  {{ opt.key }}. {{ opt.text }}
                </el-checkbox>
              </el-checkbox-group>
            </template>
          </div>
        </div>
        <el-button type="primary" size="large" @click="submitQuiz" :loading="quizSubmitting"
                   :disabled="!allAnswered" style="width:100%;margin-top:16px">
          提交
        </el-button>
      </div>

      <!-- Results -->
      <div v-else class="quiz-result">
        <div class="result-score-wrap">
          <div class="result-circle" :class="quizResult.passed ? 'passed' : 'failed'">
            <span class="result-num">{{ quizResult.score }}</span>
            <span class="result-label">分</span>
          </div>
          <div class="result-detail">
            <p>{{ quizResult.correctCount }} / {{ quizResult.totalQuestions }} 正确</p>
            <el-tag :type="quizResult.passed ? 'success' : 'danger'" size="large">
              {{ quizResult.passed ? '已通过' : '未通过' }}
            </el-tag>
          </div>
        </div>
        <div v-if="quizResult.passed" class="result-hint">该知识点已标记为完成，计划进度已更新</div>
        <div class="result-breakdown">
          <div v-for="(a, idx) in quizResult.answers" :key="a.questionId" class="breakdown-item">
            <div class="bd-header">
              <span :class="['bd-icon', a.correct ? 'icon-ok' : 'icon-wrong']">
                {{ a.correct ? '✓' : '✗' }}
              </span>
              <span class="bd-num">第{{ idx + 1 }}题</span>
            </div>
            <p class="bd-content">{{ a.questionContent }}</p>
            <div class="bd-answers">
              <span class="bd-your">你的答案：<b :class="a.correct ? 'text-green' : 'text-red'">{{ a.userAnswer || '未作答' }}</b></span>
              <span v-if="!a.correct" class="bd-correct">正确答案：<b class="text-green">{{ a.correctAnswer }}</b></span>
            </div>
            <p v-if="a.explanation" class="bd-explain">{{ a.explanation }}</p>
          </div>
        </div>
        <el-button type="primary" size="large" @click="closeQuizAndRefresh" style="width:100%;margin-top:16px">
          完成
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { planApi, courseApi, kgApi, quizApi } from '../api'
import { ElMessage, ElMessageBox } from 'element-plus'

const plans = ref([]); const courses = ref([]); const kps = ref([])
const showDialog = ref(false)
const form = reactive({ title: '', description: '', startDate: null, endDate: null, items: [{ itemType: 'COURSE', courseId: null, kpId: null }] })

// Quiz state
const quizActive = ref(false)
const quizLoading = ref(false)
const quizSubmitting = ref(false)
const quizSubmitted = ref(false)
const quizQuestions = ref([])
const quizAnswers = reactive({})
const quizResult = ref({})
let currentPlan = null
let currentItem = null

async function load() {
  const [p, c, k] = await Promise.all([planApi.list(), courseApi.list({ page: 1, pageSize: 999 }), kgApi.listNodes()])
  plans.value = p.data.data; courses.value = c.data.data.list; kps.value = k.data.data
}

function openCreate() {
  Object.assign(form, { title: '', description: '', startDate: null, endDate: null, items: [{ itemType: 'COURSE', courseId: null, kpId: null }] })
  showDialog.value = true
}

async function handleCreate() {
  await planApi.create({ title: form.title, description: form.description, startDate: form.startDate, endDate: form.endDate, items: form.items.filter(i => i.courseId || i.kpId) })
  ElMessage.success('创建成功'); showDialog.value = false; load()
}

async function handleDelete(id) {
  await ElMessageBox.confirm('删除该计划？', '提示', { type: 'warning' })
  await planApi.delete(id)
  ElMessage.success('已删除')
  load()
}

function parseOptions(opts) {
  if (!opts) return []
  try {
    return typeof opts === 'string' ? JSON.parse(opts) : opts
  } catch { return [] }
}

// Quiz flow
async function startQuiz(plan, item) {
  currentPlan = plan; currentItem = item
  quizActive.value = true; quizLoading.value = true; quizSubmitted.value = false
  quizQuestions.value = []
  for (const k in quizAnswers) delete quizAnswers[k]
  try {
    const res = await quizApi.generate(item.kpId)
    quizQuestions.value = res.data.data
    // Initialize answers for multi-choice as arrays
    quizQuestions.value.forEach(q => {
      if (q.questionType === 'MULTI_CHOICE') {
        quizAnswers[q.id] = []
      }
    })
  } catch { quizActive.value = false }
  quizLoading.value = false
}

const allAnswered = computed(() => {
  return quizQuestions.value.every(q => {
    const a = quizAnswers[q.id]
    if (q.questionType === 'MULTI_CHOICE') return a && a.length > 0
    return !!a
  })
})

async function submitQuiz() {
  quizSubmitting.value = true
  const answers = quizQuestions.value.map(q => ({
    questionId: q.id,
    userAnswer: q.questionType === 'MULTI_CHOICE'
      ? (quizAnswers[q.id] || []).sort().join('')
      : quizAnswers[q.id] || ''
  }))
  try {
    const res = await quizApi.submit({ kpId: currentItem.kpId, answers })
    quizResult.value = res.data.data
    quizSubmitted.value = true
  } catch { /* error shown by interceptor */ }
  quizSubmitting.value = false
}

function closeQuiz() {
  if (!quizSubmitted.value || confirm('确定要退出吗？已答题目不会保存。')) {
    quizActive.value = false; quizSubmitted.value = false
  }
}

function closeQuizAndRefresh() {
  quizActive.value = false; quizSubmitted.value = false
  load()
}

onMounted(load)
</script>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #18181b; margin: 0; }

.plans-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 20px; }
.plan-card {
  background: #fff; border-radius: 16px; padding: 24px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  animation: fadeUp 0.4s ease-out both;
  transition: all 0.3s;
}
.plan-card:hover { box-shadow: 0 8px 25px rgba(0,0,0,0.08); }
.plan-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.plan-title { font-size: 16px; font-weight: 600; color: #18181b; margin: 0; }
.plan-desc { font-size: 13px; color: #999; margin: 0 0 4px; }
.plan-date { font-size: 12px; color: #bbb; margin-bottom: 12px; }
.plan-items { margin-top: 8px; }
.plan-item { display: flex; align-items: center; gap: 8px; padding: 6px 0; }
.plan-item:last-child { margin-bottom: 0; }
.item-status { width: 20px; text-align: center; }
.status-done { color: #38ef7d; font-weight: 700; }
.status-todo { color: #ccc; }
.item-name { flex: 1; font-size: 13px; color: #333; }
.item-name.done { text-decoration: line-through; color: #bbb; }
.score-tag { margin-left: auto; }
.learn-link {
  margin-left: auto; font-size: 12px; color: #11998e; text-decoration: none;
  padding: 4px 10px; border: 1px solid #11998e44; border-radius: 6px;
  transition: all 0.2s;
}
.learn-link:hover { background: #11998e; color: #fff; }
.quiz-btn { flex-shrink: 0; }
.plan-footer { margin-top: 16px; text-align: right; }

.item-row { display: flex; gap: 8px; align-items: center; margin-bottom: 8px; }

.empty-state { text-align: center; color: #999; }
.big-empty { padding: 100px 20px; }
.empty-icon { font-size: 48px; margin-bottom: 12px; }

/* Quiz dialog */
.quiz-loading { text-align: center; padding: 60px 0; color: #999; }
.quiz-loading p { margin-top: 12px; }

.quiz-questions { max-height: 500px; overflow-y: auto; padding-right: 8px; }
.quiz-question { margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
.quiz-question:last-child { border-bottom: none; }
.q-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.q-num {
  width: 24px; height: 24px; border-radius: 50%;
  background: linear-gradient(135deg, #0f766e, #14b8a6);
  color: #fff; display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 600;
}
.q-content { font-size: 14px; color: #333; margin: 0 0 8px; line-height: 1.6; }
.option-group { display: flex; flex-direction: column; gap: 6px; width: 100%; }
.option-item { margin: 0; padding: 8px 12px; border-radius: 8px; transition: background 0.2s; }
.option-item:hover { background: #f5f5ff; }

/* Quiz results */
.quiz-result { max-height: 500px; overflow-y: auto; padding-right: 8px; }
.result-score-wrap { display: flex; align-items: center; gap: 20px; padding: 20px 0; border-bottom: 1px solid #f0f0f0; }
.result-circle {
  width: 80px; height: 80px; border-radius: 50%; display: flex; flex-direction: column;
  align-items: center; justify-content: center; color: #fff;
}
.result-circle.passed { background: linear-gradient(135deg, #11998e, #38ef7d); }
.result-circle.failed { background: linear-gradient(135deg, #f093fb, #f5576c); }
.result-num { font-size: 28px; font-weight: 700; line-height: 1; }
.result-label { font-size: 14px; }
.result-detail p { margin: 0 0 4px; font-size: 14px; color: #333; }
.result-hint { text-align: center; padding: 12px; margin: 12px 0; background: #f0fdf4; color: #11998e; border-radius: 8px; font-size: 13px; }

.result-breakdown { margin-top: 16px; }
.breakdown-item { padding: 12px; margin-bottom: 8px; border-radius: 8px; background: #f8f9fc; }
.bd-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.bd-icon { font-weight: 700; }
.icon-ok { color: #38ef7d; }
.icon-wrong { color: #f5576c; }
.bd-num { font-size: 12px; color: #999; }
.bd-content { font-size: 13px; color: #333; margin: 4px 0; }
.bd-answers { display: flex; gap: 16px; font-size: 12px; }
.bd-your, .bd-correct { color: #666; }
.text-green { color: #11998e; }
.text-red { color: #f5576c; }
.bd-explain { font-size: 12px; color: #999; margin: 4px 0 0; padding-top: 4px; border-top: 1px dashed #e8e8e8; }

@keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
</style>
