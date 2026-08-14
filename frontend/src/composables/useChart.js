import { onBeforeUnmount, onMounted, ref } from 'vue'
import * as echarts from 'echarts/core'
import { BarChart, LineChart } from 'echarts/charts'
import { GridComponent, LegendComponent, TooltipComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

// 按需注册，避免引入 echarts 全量包（减小首屏 JS 体积）。
echarts.use([LineChart, BarChart, GridComponent, TooltipComponent, LegendComponent, CanvasRenderer])

/**
 * @typedef {Object} ChartController
 * @property {import('vue').Ref<HTMLElement|null>} el - 图表挂载节点
 * @property {(option: object) => void} render - 渲染/更新图表配置（懒初始化）
 * @property {() => void} resize - 手动触发自适应重绘
 * @property {() => void} dispose - 销毁图表实例（组件卸载时自动调用）
 */

/**
 * ECharts 生命周期封装：懒初始化 + ResizeObserver 自适应 + 卸载自动销毁。
 *
 * 解决两个常见问题：
 * 1. 在 onMounted 里 window.addEventListener('resize') 且不清理 → 重复注册/泄漏；
 * 2. 组件销毁后 chart.dispose() 未调用 → 内存泄漏。
 *
 * @param {import('vue').Ref<HTMLElement|null>|null} [targetRef=null] - 外部节点 ref；缺省时返回内部 ref
 * @param {Object} [options={}]
 * @param {boolean} [options.autoResize=true] - 是否随容器尺寸变化自动重绘
 * @returns {ChartController}
 */
export function useChart(targetRef = null, options = {}) {
  const { autoResize = true } = options
  /** @type {import('vue').Ref<HTMLElement|null>} */
  const el = targetRef || ref(null)

  /** @type {import('echarts').ECharts|null} */
  let chart = null
  /** @type {ResizeObserver|null} */
  let observer = null

  /** 确保实例存在（懒初始化，支持数据后到再渲染）。 */
  function ensureChart() {
    if (!chart && el.value) {
      chart = echarts.init(el.value)
      if (autoResize && typeof ResizeObserver !== 'undefined') {
        observer = new ResizeObserver(() => chart && chart.resize())
        observer.observe(el.value)
      }
    }
    return chart
  }

  /**
   * 渲染或更新图表配置。
   * @param {object} option - ECharts option 对象
   */
  function render(option) {
    const instance = ensureChart()
    if (instance && option) {
      instance.setOption(option)
    }
  }

  /** 手动触发一次尺寸重绘。 */
  function resize() {
    if (chart) chart.resize()
  }

  /** 销毁实例并断开观察器。 */
  function dispose() {
    if (observer) {
      observer.disconnect()
      observer = null
    }
    if (chart) {
      chart.dispose()
      chart = null
    }
  }

  onMounted(ensureChart)
  onBeforeUnmount(dispose)

  return { el, render, resize, dispose }
}
