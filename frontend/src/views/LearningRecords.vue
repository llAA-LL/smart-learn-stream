<template>
  <div class="page">
    <div class="page-header">
      <h2>学习记录</h2>
      <el-button type="primary" size="large" @click="showDialog = true">+ 记录学习</el-button>
    </div>

    <!-- Mastery overview -->
    <div class="card mastery-card">
      <h3 class="section-title">知识点掌握度</h3>
      <div v-if="mastery.length === 0" class="empty-state">
        <div class="empty-icon">📊</div><p>暂无数据，先记录学习吧</p>
      </div>
      <div class="mastery-list" v-else>
        <div v-for="m in mastery" :key="m.id" class="mastery-item">
          <div class="mastery-info">
            <span class="mastery-name">{{ m.kpName }}</span>
            <span class="mastery-count">学习 {{ m.learnCount }} 次</span>
          </div>
          <el-progress
            :percentage="m.masteryScore"
            :stroke-width="10"
            :color="m.masteryScore >= 60 ? '#38ef7d' : '#f5576c'"
            style="flex:1;margin:0 20px"
          />
        </div>
      </div>
    </div>

    <!-- Records -->
    <div class="card">
      <h3 class="section-title">历史记录</h3>
      <el-table :data="records" stripe style="width:100%" v-loading="loading">
        <el-table-column prop="recordDate" label="日期" width="120" />
        <el-table-column prop="courseName" label="课程" />
        <el-table-column prop="kpName" label="知识点" />
        <el-table-column prop="durationMinutes" label="时长(分钟)" width="110" align="center" />
        <el-table-column prop="masteryLevel" label="掌握度" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.masteryLevel >= 60 ? 'success' : 'danger'" effect="plain" size="small">
              {{ row.masteryLevel || '-' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="notes" label="笔记" show-overflow-tooltip />
      </el-table>
      <div v-if="total > pageSize" class="pagination-wrap">
        <el-pagination background layout="prev, pager, next, total" :total="total"
                       :page-size="pageSize" :current-page="page" @current-change="onPageChange" />
      </div>
    </div>

    <!-- Add dialog -->
    <el-dialog :modelValue="showDialog" @update:modelValue="showDialog = $event" title="记录学习" width="460px" center>
      <el-form :model="form" label-position="top">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="课程">
              <el-select v-model="form.courseId" clearable placeholder="选择课程">
                <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="知识点">
              <el-select v-model="form.kpId" clearable placeholder="选择知识点">
                <el-option v-for="kp in filteredKps" :key="kp.id" :label="kp.name" :value="kp.id" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="学习时长 (分钟)">
          <el-input-number v-model="form.durationMinutes" :min="1" :max="600" size="large" style="width:100%" />
        </el-form-item>
        <el-form-item label="自评掌握度">
          <div class="slider-wrap">
            <span class="slider-val">{{ form.masteryLevel }}%</span>
            <el-slider v-model="form.masteryLevel" :min="0" :max="100" style="flex:1" />
          </div>
        </el-form-item>
        <el-form-item label="笔记">
          <el-input v-model="form.notes" type="textarea" :rows="2" placeholder="学习心得..." />
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
import { recordApi, courseApi, kgApi } from '../api'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'

const records = ref([]); const mastery = ref([])
const courses = ref([]); const kps = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const loading = ref(false); const showDialog = ref(false)
const form = reactive({ courseId: null, kpId: null, durationMinutes: 30, masteryLevel: 50, recordDate: new Date(), notes: '' })
const filteredKps = computed(() => {
  if (!form.courseId) return kps.value
  return kps.value.filter(k => k.courseId === form.courseId)
})

async function load() {
  const [r, m, c, k] = await Promise.all([
    recordApi.list({ page: page.value, pageSize: pageSize.value }),
    recordApi.mastery(), courseApi.list({ page: 1, pageSize: 999 }), kgApi.listNodes()
  ])
  records.value = r.data.data.list; mastery.value = m.data.data
  courses.value = c.data.data.list; kps.value = k.data.data
  total.value = r.data.data.total
}
function onPageChange(p) {
  page.value = p
  load()
}
async function handleSave() {
  const data = { ...form, recordDate: dayjs(form.recordDate).format('YYYY-MM-DD') }
  await recordApi.create(data)
  ElMessage.success('记录成功')
  showDialog.value = false
  Object.assign(form, { courseId: null, kpId: null, durationMinutes: 30, masteryLevel: 50, recordDate: new Date(), notes: '' })
  load()
}
onMounted(load)
</script>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #18181b; margin: 0; }

.card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); margin-bottom: 24px; }
.section-title { font-size: 16px; font-weight: 600; color: #18181b; margin: 0 0 20px; }

.mastery-item { display: flex; align-items: center; padding: 14px 0; border-bottom: 1px solid #f5f5f5; }
.mastery-item:last-child { border-bottom: none; }
.mastery-info { width: 200px; }
.mastery-name { font-size: 13px; font-weight: 500; color: #333; display: block; }
.mastery-count { font-size: 11px; color: #999; }

.slider-wrap { display: flex; align-items: center; gap: 12px; width: 100%; }
.slider-val { font-size: 14px; font-weight: 600; color: #0f766e; width: 40px; }

.empty-state { text-align: center; padding: 40px 20px; color: #999; }
.empty-icon { font-size: 40px; margin-bottom: 8px; }
</style>
