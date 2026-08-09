<template>
  <div class="page">
    <div class="page-header">
      <h2>题库管理</h2>
      <el-button type="primary" size="large" @click="openCreate">+ 添加题目</el-button>
    </div>

    <!-- Filters -->
    <div class="filter-bar">
      <el-select v-model="filterCourse" placeholder="按课程筛选" clearable style="width:200px"
                 @change="onCourseChange">
        <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
      </el-select>
      <el-select v-model="filterKp" placeholder="按知识点筛选" clearable style="width:220px"
                 @change="loadQuestions">
        <el-option v-for="kp in filteredKps" :key="kp.id" :label="kp.name" :value="kp.id" />
      </el-select>
    </div>

    <!-- Questions table -->
    <div class="card">
      <el-table :data="questions" stripe style="width:100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="kpName" label="所属知识点" width="140" />
        <el-table-column label="类型" width="80">
          <template #default="{ row }">
            <el-tag size="small" :type="row.questionType === 'MULTI_CHOICE' ? 'warning' : 'primary'">
              {{ row.questionType === 'SINGLE_CHOICE' ? '单选' : row.questionType === 'MULTI_CHOICE' ? '多选' : '判断' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="content" label="题目内容" show-overflow-tooltip min-width="200" />
        <el-table-column prop="answer" label="答案" width="80" align="center" />
        <el-table-column label="难度" width="70" align="center">
          <template #default="{ row }">
            <span>{{ '★'.repeat(row.difficulty || 1) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openEdit(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div v-if="total > pageSize" class="pagination-wrap">
        <el-pagination background layout="prev, pager, next, total" :total="total"
                       :page-size="pageSize" :current-page="page" @current-change="onPageChange" />
      </div>
    </div>

    <!-- Add/Edit dialog -->
    <el-dialog :modelValue="showDialog" @update:modelValue="showDialog = $event"
               :title="editing ? '编辑题目' : '添加题目'" width="560px" center>
      <el-form :model="form" label-position="top">
        <el-form-item label="所属知识点">
          <el-select v-model="form.kpId" style="width:100%" placeholder="选择知识点">
            <el-option v-for="kp in kps" :key="kp.id" :label="kp.name" :value="kp.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="题目类型">
          <el-select v-model="form.questionType" style="width:100%">
            <el-option label="单选题 (SINGLE_CHOICE)" value="SINGLE_CHOICE" />
            <el-option label="多选题 (MULTI_CHOICE)" value="MULTI_CHOICE" />
            <el-option label="判断题 (TRUE_FALSE)" value="TRUE_FALSE" />
          </el-select>
        </el-form-item>
        <el-form-item label="题目内容">
          <el-input v-model="form.content" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item v-if="form.questionType !== 'TRUE_FALSE'" label="选项 (JSON格式)">
          <el-input v-model="form.options" type="textarea" :rows="4"
                    placeholder='[{"key":"A","text":"选项A"},{"key":"B","text":"选项B"}]' />
        </el-form-item>
        <el-form-item label="正确答案">
          <el-input v-model="form.answer" placeholder="单选填字母如A，多选填如ABC，判断填true/false" />
        </el-form-item>
        <el-form-item label="解析">
          <el-input v-model="form.explanation" type="textarea" :rows="2" placeholder="解释为什么是这个答案" />
        </el-form-item>
        <el-form-item label="难度">
          <el-rate v-model="form.difficulty" :max="3" show-text
                   :texts="['简单', '中等', '困难']" style="height:24px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { questionApi, courseApi, kgApi } from '../api'
import { ElMessage, ElMessageBox } from 'element-plus'

const questions = ref([])
const courses = ref([])
const kps = ref([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showDialog = ref(false)
const editing = ref(false)
const editingId = ref(null)
const filterCourse = ref(null)
const filterKp = ref(null)

const form = reactive({
  kpId: null, questionType: 'SINGLE_CHOICE', content: '', options: '',
  answer: '', explanation: '', difficulty: 1
})

const filteredKps = computed(() => {
  if (!filterCourse.value) return kps.value
  return kps.value.filter(k => k.courseId === filterCourse.value)
})

function onCourseChange() {
  filterKp.value = null
  loadQuestions()
}

async function loadAll() {
  const [c, k] = await Promise.all([courseApi.list({ page: 1, pageSize: 999 }), kgApi.listNodes()])
  courses.value = c.data.data.list; kps.value = k.data.data
  loadQuestions()
}

async function loadQuestions() {
  loading.value = true
  try {
    const res = await questionApi.list({ page: page.value, pageSize: pageSize.value, kpId: filterKp.value || undefined })
    questions.value = res.data.data.list || []
    total.value = res.data.data.total || 0
  } catch { questions.value = [] }
  loading.value = false
}

function onPageChange(p) {
  page.value = p
  loadQuestions()
}

function openCreate() {
  editing.value = false; editingId.value = null
  Object.assign(form, {
    kpId: filterKp.value || null, questionType: 'SINGLE_CHOICE',
    content: '', options: '', answer: '', explanation: '', difficulty: 1
  })
  showDialog.value = true
}

function openEdit(row) {
  editing.value = true; editingId.value = row.id
  Object.assign(form, {
    kpId: row.kpId, questionType: row.questionType, content: row.content,
    options: row.options || '', answer: row.answer,
    explanation: row.explanation || '', difficulty: row.difficulty || 1
  })
  showDialog.value = true
}

async function handleSave() {
  const data = { ...form }
  if (data.questionType === 'TRUE_FALSE') data.options = null
  if (editing.value) {
    await questionApi.update(editingId.value, data)
    ElMessage.success('更新成功')
  } else {
    await questionApi.create(data)
    ElMessage.success('添加成功')
  }
  showDialog.value = false
  loadQuestions()
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确定删除这道题？', '提示', { type: 'warning' })
  await questionApi.delete(id)
  ElMessage.success('已删除')
  loadQuestions()
}

onMounted(loadAll)
</script>

<style scoped>
.page { max-width: 1400px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #1a1a2e; margin: 0; }

.filter-bar { display: flex; gap: 12px; margin-bottom: 16px; }

.card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
</style>
