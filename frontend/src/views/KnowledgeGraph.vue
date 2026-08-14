<template>
  <div class="page">
    <div class="page-header">
      <h2>知识图谱</h2>
      <div class="header-actions">
        <span v-if="graphNodes.length" class="graph-stats">
          {{ graphNodes.length }} 个知识点 · {{ graphEdges.length }} 条依赖
        </span>
        <el-button size="large" @click="zoomIn">放大</el-button>
        <el-button size="large" @click="zoomOut">缩小</el-button>
        <el-button size="large" @click="resetView">重置视角</el-button>
        <el-select v-model="selectedCourse" placeholder="选择课程" size="large" style="width:220px" @change="renderGraph">
          <el-option label="全部课程" :value="null" />
          <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
        </el-select>
        <el-button v-if="isAdmin" type="primary" size="large" @click="openCreate">+ 添加知识点</el-button>
      </div>
    </div>

    <div class="graph-card card">
      <div v-if="graphError" class="graph-error">{{ graphError }}</div>
      <div v-else-if="graphNodes.length === 0" class="empty-state">
        <p>暂无知识点数据</p>
      </div>
      <template v-else>
        <div class="graph-hint">滚轮缩放 · 拖拽平移 · 悬停高亮依赖 · 点击节点查看详情</div>
        <div ref="viewportRef" class="graph-viewport"
             @wheel.prevent="onWheel" @mousedown="onDragStart"
             @mousemove="onDragMove" @mouseup="onDragEnd" @mouseleave="onDragEnd">
          <div class="graph-world" :style="worldStyle">
            <svg class="graph-edges" :width="worldW" :height="worldH">
              <defs>
                <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                  <path d="M0,0 L10,5 L0,10 z" fill="#aab4cc" />
                </marker>
              </defs>
              <line v-for="e in graphEdges" :key="edgeKey(e)" class="edge" :class="{ active: isEdgeActive(e) }"
                    :x1="cx(e.source)" :y1="cy(e.source)" :x2="cx(e.target)" :y2="cy(e.target)"
                    marker-end="url(#arrow)" />
            </svg>
            <div v-for="n in graphNodes" :key="n.id" class="graph-node"
                 :class="nodeClass(n)"
                 :style="{ left: nx(n.id) + 'px', top: ny(n.id) + 'px', background: levelColor(n.level) }"
                 @mouseenter="selectedId = n.id" @mouseleave="selectedId = null" @click.stop="onNodeClick(n)">
              <span class="node-name">{{ n.name }}</span>
            </div>
          </div>
        </div>
      </template>
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
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const router = useRouter()
const isAdmin = computed(() => userStore.user?.role === 'ADMIN')

const nodes = ref([])          // 全部知识点（用于编辑下拉）
const courses = ref([])
const graphNodes = ref([])
const graphEdges = ref([])
const graphError = ref('')
const selectedCourse = ref(null)
const viewportRef = ref(null)

const positions = ref({})      // id -> {x, y} 节点中心坐标
const adjacency = ref({})      // id -> 邻居id数组
const selectedId = ref(null)
const worldW = ref(1200)
const worldH = ref(720)
const scale = ref(1)
const pan = reactive({ x: 0, y: 0 })

const NODE_W = 110
const NODE_H = 40
const PAD = 90
const LEVEL_COLORS = ['#0d9488', '#4f46e5', '#d97706', '#e11d48', '#7c3aed']

const showDialog = ref(false)
const editing = ref(false)
const editingId = ref(null)
const form = reactive({ name: '', courseId: null, level: 0, description: '', prerequisiteIds: [] })
let autoFocused = false

const worldStyle = computed(() => ({
  width: worldW.value + 'px',
  height: worldH.value + 'px',
  transform: `translate(${pan.x}px, ${pan.y}px) scale(${scale.value})`,
  transformOrigin: '0 0'
}))

function levelColor(level) {
  return LEVEL_COLORS[Math.min(level ?? 0, 4)]
}

function cx(id) { return positions.value[id] ? positions.value[id].x : 0 }
function cy(id) { return positions.value[id] ? positions.value[id].y : 0 }
function nx(id) { return cx(id) - NODE_W / 2 }
function ny(id) { return cy(id) - NODE_H / 2 }
function edgeKey(e) { return e.source + '-' + e.target }
function isEdgeActive(e) { return selectedId.value === e.source || selectedId.value === e.target }
function nodeClass(n) {
  if (selectedId.value === null || selectedId.value === undefined) return ''
  if (selectedId.value === n.id) return 'active'
  return isNeighbor(selectedId.value, n.id) ? '' : 'dim'
}
function isNeighbor(a, b) {
  const list = adjacency.value[a]
  return !!list && list.includes(b)
}

async function load() {
  const [n, c] = await Promise.all([kgApi.listNodes(), courseApi.list({ page: 1, pageSize: 999 })])
  nodes.value = n.data.data
  courses.value = c.data.data.list
  if (!selectedCourse.value && nodes.value.length > 40 && !autoFocused) {
    autoFocused = true
    const counts = new Map()
    nodes.value.forEach(kp => counts.set(kp.courseId, (counts.get(kp.courseId) || 0) + 1))
    const best = courses.value
      .map(c => ({ course: c, count: counts.get(c.id) || 0 }))
      .sort((a, b) => b.count - a.count)[0]
    if (best && best.course && best.count > 0) {
      selectedCourse.value = best.course.id
      ElMessage.info(`节点较多，已自动聚焦到「${best.course.name}」，可切换"全部课程"浏览全貌`)
    }
  }
}

/**
 * 分层布局：行 = level，列 = 课程；同层按"被依赖数量 + id"排序。
 * 返回 id -> {x, y}（已缩放适配画布）。
 */
function buildPositions(nodeList, edgeList) {
  const byLevel = new Map()
  nodeList.forEach(n => {
    const lvl = n.level ?? 0
    if (!byLevel.has(lvl)) byLevel.set(lvl, [])
    byLevel.get(lvl).push(n)
  })
  const inDegree = new Map(nodeList.map(n => [n.id, 0]))
  edgeList.forEach(e => { if (inDegree.has(e.target)) inDegree.set(e.target, inDegree.get(e.target) + 1) })

  const levels = [...byLevel.keys()].sort((a, b) => a - b)
  const NODE_GAP = 190
  const COURSE_GAP = 320
  const ROW_GAP = 220
  const GROUP_PAD = 140
  const raw = new Map()

  levels.forEach((lvl, li) => {
    const list = byLevel.get(lvl).slice().sort((a, b) => {
      const c = String(a.category || '').localeCompare(String(b.category || ''))
      if (c !== 0) return c
      return ((inDegree.get(a.id) || 0) - (inDegree.get(b.id) || 0)) || (a.id - b.id)
    })
    const groups = new Map()
    list.forEach(n => {
      const k = n.category || ''
      if (!groups.has(k)) groups.set(k, [])
      groups.get(k).push(n)
    })
    const groupArr = [...groups.values()]
    const totalWidth = groupArr.reduce((w, arr) => w + (arr.length - 1) * NODE_GAP, 0)
      + (groupArr.length - 1) * COURSE_GAP + GROUP_PAD
    let cursor = -totalWidth / 2 + GROUP_PAD / 2
    groupArr.forEach(arr => {
      const start = cursor
      arr.forEach((n, i) => raw.set(n.id, { x: start + i * NODE_GAP, y: li * ROW_GAP }))
      cursor += (arr.length - 1) * NODE_GAP + COURSE_GAP
    })
  })

  // 缩放适配画布
  const xs = [...raw.values()].map(p => p.x)
  const ys = [...raw.values()].map(p => p.y)
  const minX = Math.min(...xs)
  const maxX = Math.max(...xs)
  const minY = Math.min(...ys)
  const maxY = Math.max(...ys)
  const vw = viewportRef.value ? viewportRef.value.clientWidth : 1200
  const vh = viewportRef.value ? viewportRef.value.clientHeight : 720
  worldW.value = vw
  worldH.value = vh
  const s = Math.min((vw - PAD * 2) / (maxX - minX || 1), (vh - PAD * 2) / (maxY - minY || 1), 1)
  const out = {}
  raw.forEach((p, id) => {
    out[id] = { x: (p.x - minX) * s + PAD, y: (p.y - minY) * s + PAD }
  })
  positions.value = out
}

function buildAdjacency(edgeList) {
  const map = {}
  edgeList.forEach(e => {
    ;(map[e.source] = map[e.source] || []).push(e.target)
    ;(map[e.target] = map[e.target] || []).push(e.source)
  })
  adjacency.value = map
}

async function renderGraph() {
  graphError.value = ''
  try {
    await nextTick()
    const res = await kgApi.graphData()
    const allNodes = res.data?.data?.nodes || []
    const allEdges = res.data?.data?.edges || []

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
    graphEdges.value = filteredEdges
    if (!filteredNodes.length) {
      graphError.value = '该课程暂无知识点数据'
      return
    }
    buildPositions(filteredNodes, filteredEdges)
    buildAdjacency(filteredEdges)
    resetView()
  } catch (e) {
    console.error('知识图谱加载失败:', e)
    graphError.value = '加载失败：' + (e && e.message ? e.message : e)
  }
}

function onNodeClick(n) {
  if (isAdmin.value) {
    const node = nodes.value.find(x => x.id === n.id)
    if (node) {
      editing.value = true
      editingId.value = node.id
      Object.assign(form, {
        name: node.name, courseId: node.courseId, level: node.level,
        description: node.description || '', prerequisiteIds: node.prerequisiteIds || []
      })
      showDialog.value = true
    }
  } else {
    router.push(`/knowledge-point/${n.id}`)
  }
}

function openCreate() {
  editing.value = false
  editingId.value = null
  Object.assign(form, { name: '', courseId: selectedCourse.value, level: 0, description: '', prerequisiteIds: [] })
  showDialog.value = true
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

// ---- 缩放与平移 ----
let dragging = false
let lastX = 0
let lastY = 0

function zoomIn() {
  scale.value = Math.min(3, scale.value * 1.2)
}
function zoomOut() {
  scale.value = Math.max(0.2, scale.value / 1.2)
}
function resetView() {
  scale.value = 1
  pan.x = 0
  pan.y = 0
}
function onWheel(e) {
  const rect = viewportRef.value.getBoundingClientRect()
  const ox = e.clientX - rect.left
  const oy = e.clientY - rect.top
  const old = scale.value
  const ns = Math.min(3, Math.max(0.2, old * (e.deltaY < 0 ? 1.12 : 0.9)))
  pan.x = ox - (ox - pan.x) * (ns / old)
  pan.y = oy - (oy - pan.y) * (ns / old)
  scale.value = ns
}
function onDragStart(e) {
  dragging = true
  lastX = e.clientX
  lastY = e.clientY
}
function onDragMove(e) {
  if (!dragging) return
  pan.x += e.clientX - lastX
  pan.y += e.clientY - lastY
  lastX = e.clientX
  lastY = e.clientY
}
function onDragEnd() {
  dragging = false
}

onMounted(async () => {
  await load()
  renderGraph()
})
</script>

<style scoped>
.page { max-width: 1400px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
.header-actions { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.graph-stats { font-size: 13px; color: var(--text-3); margin-right: 4px; }

.graph-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 24px;
}
.graph-hint {
  font-size: 12px;
  color: var(--text-3);
  margin-bottom: 12px;
  text-align: center;
}
.graph-viewport {
  position: relative;
  width: 100%;
  height: 720px;
  overflow: hidden;
  cursor: grab;
  background:
    radial-gradient(circle, rgba(15, 23, 42, 0.08) 1px, transparent 1px),
    linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
  background-size: 24px 24px, 100% 100%;
  border-radius: 12px;
  border: 1px solid var(--border);
  user-select: none;
}
.graph-viewport:active { cursor: grabbing; }
.graph-world { position: absolute; top: 0; left: 0; }
.graph-edges { position: absolute; top: 0; left: 0; overflow: visible; }
.edge {
  stroke: #94a3b8;
  stroke-width: 2;
  opacity: 0.45;
  transition: opacity .15s, stroke .15s, stroke-width .15s;
}
.edge.active { stroke: var(--accent); opacity: 1; stroke-width: 3; }
.graph-node {
  position: absolute;
  width: 110px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 0 2px 10px rgba(15, 23, 42, 0.18);
  cursor: pointer;
  z-index: 2;
  transition: transform .15s, opacity .15s, box-shadow .15s;
}
.graph-node.active {
  transform: scale(1.12);
  box-shadow: 0 6px 20px rgba(15, 23, 42, 0.3);
  z-index: 3;
}
.graph-node.dim { opacity: 0.25; }
.node-name {
  padding: 0 6px;
  text-align: center;
  line-height: 1.2;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
}
.graph-error { color: var(--rose); font-size: 14px; text-align: center; padding: 80px 0; }
.empty-state { text-align: center; padding: 100px 0; color: var(--text-3); font-size: 15px; }
</style>
