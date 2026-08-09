<template>
  <div class="page">
    <div class="page-header">
      <h2>知识图谱</h2>
      <div class="header-actions">
        <el-select v-model="selectedCourse" placeholder="选择课程" size="large" style="width:220px" @change="renderGraph">
          <el-option label="全部课程" :value="null" />
          <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
        </el-select>
        <el-button v-if="isAdmin" type="primary" size="large" @click="openCreate">+ 添加知识点</el-button>
      </div>
    </div>

    <div class="graph-card card">
      <div v-if="graphNodes.length === 0" class="empty-state">
        <p>暂无知识点数据</p>
      </div>
      <div ref="graphRef" class="graph-container" v-show="graphNodes.length > 0"></div>
    </div>

    <el-dialog :modelValue="showDialog" @update:modelValue="showDialog = $event"
               :title="editing ? '编辑知识点' : '添加知识点'" width="480px" center>
      <el-form :model="form" label-position="top">
        <el-form-item label="知识点名称">
          <el-input v-model="form.name" placeholder="如：二分查找" size="large" />
        </el-form-item>
        <el-form-item label="所属课程">
          <el-select v-model="form.courseId" style="width:100%" size="large">
            <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="层级深度">
          <el-input-number v-model="form.level" :min="0" :max="10" size="large" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="前置知识点">
          <el-select v-model="form.prerequisiteIds" multiple style="width:100%" placeholder="选择前置依赖(可选)">
            <el-option v-for="n in nodes" :key="n.id" :label="n.name" :value="n.id"
                       :disabled="n.id === editingId" />
          </el-select>
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
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { kgApi, courseApi } from '../api'
import { useUserStore } from '../stores/user'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const router = useRouter()
const isAdmin = computed(() => userStore.user?.role === 'ADMIN')

const nodes = ref([])
const courses = ref([])
const graphNodes = ref([])
const graphRef = ref(null)
const showDialog = ref(false)
const editing = ref(false)
const editingId = ref(null)
const selectedCourse = ref(null)
const form = reactive({ name: '', courseId: null, level: 0, description: '', prerequisiteIds: [] })
let chart = null

async function load() {
  const [n, c] = await Promise.all([kgApi.listNodes(), courseApi.list()])
  nodes.value = n.data.data
  courses.value = c.data.data
}

function openCreate() {
  editing.value = false; editingId.value = null
  Object.assign(form, { name: '', courseId: selectedCourse.value, level: 0, description: '', prerequisiteIds: [] })
  showDialog.value = true
}

async function renderGraph() {
  await nextTick()
  if (!graphRef.value) return
  if (chart) { chart.dispose(); chart = null }

  const res = await kgApi.graphData()
  const allNodes = res.data?.data?.nodes || []
  const allEdges = res.data?.data?.edges || []

  // 按课程过滤
  let filteredNodes, filteredEdges
  if (selectedCourse.value) {
    const course = courses.value.find(c => c.id === selectedCourse.value)
    const courseName = course?.name || ''
    filteredNodes = allNodes.filter(n => n.category === courseName)
    const nodeIds = new Set(filteredNodes.map(n => n.id))
    filteredEdges = allEdges.filter(e => nodeIds.has(e.source) && nodeIds.has(e.target))
  } else {
    filteredNodes = allNodes
    filteredEdges = allEdges
  }

  graphNodes.value = filteredNodes
  if (filteredNodes.length === 0) return

  const cats = [...new Set(filteredNodes.map(n => n.category))]
  const colors = ['#667eea', '#f56c6c', '#38ef7d', '#e6a23c', '#409eff']

  chart = echarts.init(graphRef.value)
  chart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: p => {
        if (p.dataType === 'node') {
          return `<b>${p.name}</b><br/>课程: ${p.data.category}<br/>层级: L${p.data.level}`
        }
        const src = filteredNodes.find(n => n.id === p.data.source)
        const tgt = filteredNodes.find(n => n.id === p.data.target)
        return `前置: ${src?.name || '?'} → ${tgt?.name || '?'}`
      }
    },
    legend: cats.length > 1 ? { data: cats, bottom: 0, textStyle: { fontSize: 12 } } : undefined,
    series: [{
      type: 'graph',
      layout: 'force',
      roam: true,
      draggable: true,
      categories: cats.map((c, i) => ({ name: c, itemStyle: { color: colors[i % colors.length] } })),
      data: filteredNodes.map(n => ({
        id: n.id, name: n.name, category: n.category,
        symbolSize: 36 + n.level * 6,
        label: { show: true, fontSize: 12, color: '#333' },
        itemStyle: { borderColor: '#fff', borderWidth: 2 }
      })),
      edges: filteredEdges.map(e => ({
        source: e.source, target: e.target,
        lineStyle: { color: '#ccc', width: 2, curveness: 0.2 }
      })),
      force: {
        repulsion: filteredNodes.length < 10 ? 400 : 250,
        gravity: 0.06,
        edgeLength: [100, 250],
        layoutAnimation: true
      },
      emphasis: {
        focus: 'adjacency',
        lineStyle: { width: 4 },
        itemStyle: { shadowBlur: 20, shadowColor: 'rgba(0,0,0,0.3)' }
      }
    }]
  })

  chart.on('click', (p) => {
    if (p.dataType === 'node') {
      if (isAdmin.value) {
        const node = nodes.value.find(n => n.id === p.data.id)
        if (node) {
          editing.value = true; editingId.value = node.id
          Object.assign(form, {
            name: node.name, courseId: node.courseId, level: node.level,
            description: node.description || '', prerequisiteIds: node.prerequisiteIds || []
          })
          showDialog.value = true
        }
      } else {
        router.push(`/knowledge-point/${p.data.id}`)
      }
    }
  })
}

async function handleSave() {
  if (editing.value) {
    await kgApi.updateNode(editingId.value, { ...form })
    ElMessage.success('更新成功')
  } else {
    await kgApi.createNode({ ...form })
    ElMessage.success('创建成功')
  }
  showDialog.value = false
  await load()
  renderGraph()
}

onMounted(async () => { await load(); renderGraph() })
</script>

<style scoped>
.page { max-width: 1400px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-header h2 { font-size: 20px; font-weight: 700; color: #1a1a2e; margin: 0; }
.header-actions { display: flex; gap: 12px; align-items: center; }

.graph-card { background: #fff; border-radius: 16px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); padding: 24px; }
.graph-container { width: 100%; height: 650px; }
.empty-state { text-align: center; padding: 100px 0; color: #999; font-size: 15px; }
</style>
