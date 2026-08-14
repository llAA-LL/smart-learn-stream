<template>
  <div class="page">
    <div class="page-header">
      <h2>{{ isAdmin ? '课程管理' : '课程浏览' }}</h2>
      <el-button v-if="isAdmin" type="primary" size="large" @click="openCreate">+ 添加课程</el-button>
    </div>

    <div v-if="courses.length === 0" class="empty-state">
      <div class="empty-icon">📚</div>
      <p>{{ isAdmin ? '暂无课程，点击上方按钮添加' : '暂无课程，请联系管理员添加' }}</p>
    </div>

    <div v-else class="courses-grid">
      <div v-for="course in courses" :key="course.id" class="course-card" :style="{ animationDelay: 0.05 * courses.indexOf(course) + 's' }">
        <div class="course-cover" :style="courseCoverStyle(course)">{{ course.name[0] }}</div>
        <div class="course-body">
          <div class="course-category">
            <el-tag size="small" effect="plain">{{ course.category || '未分类' }}</el-tag>
          </div>
          <h4 class="course-name">{{ course.name }}</h4>
          <p class="course-desc">{{ course.description || '暂无描述' }}</p>
        </div>
        <div class="course-actions">
          <template v-if="isAdmin">
            <el-button link type="primary" @click="editCourse(course)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(course.id)">删除</el-button>
          </template>
          <template v-else>
            <el-button type="primary" size="small" @click="openCourseDetail(course)">查看知识点</el-button>
          </template>
        </div>
      </div>
    </div>

    <div v-if="total > pageSize" class="pagination-wrap">
      <el-pagination background layout="prev, pager, next, total" :total="total"
                     :page-size="pageSize" :current-page="page" @current-change="onPageChange" />
    </div>

    <!-- Admin: Create/Edit dialog -->
    <el-dialog :modelValue="showDialog" @update:modelValue="showDialog = $event"
               :title="editing ? '编辑课程' : '添加课程'" width="480px" center>
      <el-form :model="form" label-position="top">
        <el-form-item label="课程名称">
          <el-input v-model="form.name" placeholder="输入课程名称" size="large" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.category" style="width:100%" size="large">
            <el-option label="计算机科学" value="计算机科学" />
            <el-option label="数学" value="数学" />
            <el-option label="外语" value="外语" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="课程简介" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- Student: Course detail with knowledge points -->
    <el-dialog :modelValue="showDetail" @update:modelValue="showDetail = $event"
               :title="selectedCourse?.name" width="600px" center>
      <div v-if="selectedCourse" class="course-detail">
        <p class="detail-desc">{{ selectedCourse.description || '暂无描述' }}</p>
        <el-divider />
        <h4 class="detail-section-title">知识点列表</h4>
        <div v-if="courseKps.length === 0" class="empty-state" style="padding:30px">
          <p>该课程暂无知识点</p>
        </div>
        <div v-else class="kp-select-list">
          <div v-for="kp in courseKps" :key="kp.id" class="kp-select-item"
               :class="{ selected: selectedKpIds.includes(kp.id) }"
               @click="toggleKp(kp.id)">
            <el-checkbox :modelValue="selectedKpIds.includes(kp.id)" @click.stop />
            <div class="kp-select-info">
              <span class="kp-select-name">{{ kp.name }}</span>
              <span class="kp-select-level">L{{ kp.level }} · {{ kp.prerequisiteIds?.length ? kp.prerequisiteIds.length + ' 个前置' : '无前置依赖' }}</span>
            </div>
          </div>
        </div>
        <el-divider />
        <el-form :model="planForm" label-position="top" inline>
          <el-form-item label="计划标题">
            <el-input v-model="planForm.title" placeholder="如：Java 进阶计划" style="width:200px" />
          </el-form-item>
          <el-form-item label="开始日期">
            <el-date-picker v-model="planForm.startDate" type="date" style="width:160px" />
          </el-form-item>
          <el-form-item label="结束日期">
            <el-date-picker v-model="planForm.endDate" type="date" style="width:160px" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="showDetail = false">取消</el-button>
        <el-button type="primary" @click="createPlanFromCourse" :disabled="selectedKpIds.length === 0">
          创建学习计划 (已选 {{ selectedKpIds.length }} 个知识点)
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { courseApi, kgApi, planApi } from '../api'
import { useUserStore } from '../stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const isAdmin = computed(() => userStore.user?.role === 'ADMIN')

const courses = ref([])
const page = ref(1)
const pageSize = ref(12)
const total = ref(0)
const showDialog = ref(false)
const editing = ref(false)
const editingId = ref(null)
const form = reactive({ name: '', category: '', description: '' })

const COVER_GRADIENTS = [
  'linear-gradient(135deg, #0f766e, #14b8a6)',
  'linear-gradient(135deg, #4338ca, #6366f1)',
  'linear-gradient(135deg, #7c3aed, #a855f7)',
  'linear-gradient(135deg, #b45309, #d97706)',
  'linear-gradient(135deg, #be123c, #e11d48)',
  'linear-gradient(135deg, #0369a1, #0ea5e9)'
]
function courseCoverStyle(course) {
  const idx = ((course.id || 0) % COVER_GRADIENTS.length + COVER_GRADIENTS.length) % COVER_GRADIENTS.length
  return { background: COVER_GRADIENTS[idx] }
}

async function load() {
  const res = await courseApi.list({ page: page.value, pageSize: pageSize.value })
  courses.value = res.data.data.list
  total.value = res.data.data.total
}
function onPageChange(p) {
  page.value = p
  load()
}
function openCreate() {
  editing.value = false; editingId.value = null
  Object.assign(form, { name: '', category: '', description: '' })
  showDialog.value = true
}
function editCourse(row) {
  editing.value = true; editingId.value = row.id
  Object.assign(form, { name: row.name, category: row.category, description: row.description })
  showDialog.value = true
}
async function handleSave() {
  if (editing.value) {
    await courseApi.update(editingId.value, { ...form })
    ElMessage.success('更新成功')
  } else {
    await courseApi.create({ ...form })
    ElMessage.success('创建成功')
  }
  showDialog.value = false
  load()
}
async function handleDelete(id) {
  await ElMessageBox.confirm('确定删除？', '提示', { type: 'warning' })
  await courseApi.delete(id)
  ElMessage.success('已删除')
  load()
}

// Student: Course detail & plan creation
const showDetail = ref(false)
const selectedCourse = ref(null)
const courseKps = ref([])
const selectedKpIds = ref([])
const planForm = reactive({ title: '', startDate: null, endDate: null })

async function openCourseDetail(course) {
  selectedCourse.value = course
  selectedKpIds.value = []
  planForm.title = course.name + ' 学习计划'
  planForm.startDate = null
  planForm.endDate = null
  try {
    const res = await kgApi.listNodes(course.id)
    courseKps.value = res.data.data || []
  } catch {
    courseKps.value = []
  }
  showDetail.value = true
}

function toggleKp(kpId) {
  const idx = selectedKpIds.value.indexOf(kpId)
  if (idx >= 0) {
    selectedKpIds.value.splice(idx, 1)
  } else {
    selectedKpIds.value.push(kpId)
  }
}

async function createPlanFromCourse() {
  if (selectedKpIds.value.length === 0) return
  await planApi.create({
    title: planForm.title || selectedCourse.value.name + ' 学习计划',
    description: '基于课程「' + selectedCourse.value.name + '」创建',
    startDate: planForm.startDate,
    endDate: planForm.endDate,
    items: selectedKpIds.value.map(kpId => ({ itemType: 'KNOWLEDGE_POINT', courseId: null, kpId }))
  })
  ElMessage.success('学习计划已创建')
  showDetail.value = false
}

onMounted(load)
</script>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; }
.pagination-wrap { display: flex; justify-content: center; margin-top: 16px; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #18181b; margin: 0; }

.courses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}
.course-card {
  background: #fff; border-radius: 16px; overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  transition: all 0.3s;
  animation: fadeUp 0.4s ease-out both;
}
.course-card:hover { transform: translateY(-4px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
.course-cover {
  height: 80px; display: flex; align-items: center; justify-content: center;
  font-size: 32px; font-weight: 700; color: #fff;
  background: linear-gradient(135deg, #0f766e, #14b8a6);
}
.course-body { padding: 16px 20px; }
.course-category { margin-bottom: 8px; }
.course-name { font-size: 16px; font-weight: 600; color: #18181b; margin: 0 0 6px; }
.course-desc { font-size: 13px; color: #999; margin: 0; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.course-actions { padding: 0 20px 16px; display: flex; gap: 8px; }

/* Course detail dialog */
.course-detail { }
.detail-desc { font-size: 14px; color: #666; line-height: 1.6; margin: 0; }
.detail-section-title { font-size: 15px; font-weight: 600; color: #18181b; margin: 0 0 12px; }

.kp-select-list { display: flex; flex-direction: column; gap: 6px; max-height: 300px; overflow-y: auto; }
.kp-select-item {
  display: flex; align-items: center; gap: 12px;
  padding: 10px 14px; border-radius: 10px;
  background: #f8f9fc; cursor: pointer;
  transition: all 0.2s;
}
.kp-select-item:hover { background: #f0fdfa; }
.kp-select-item.selected { background: #f0fdfa; border: 1px solid rgba(15, 118, 110, 0.25); }
.kp-select-info { display: flex; flex-direction: column; gap: 2px; }
.kp-select-name { font-size: 13px; font-weight: 500; color: #333; }
.kp-select-level { font-size: 11px; color: #999; }

.empty-state { text-align: center; padding: 80px 20px; color: #999; }
.empty-icon { font-size: 48px; margin-bottom: 12px; }
@keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
</style>
