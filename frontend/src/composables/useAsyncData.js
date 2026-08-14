import { ref } from 'vue'

/**
 * @typedef {Object} AsyncDataState
 * @property {import('vue').Ref<*>} data - 数据本体
 * @property {import('vue').Ref<boolean>} loading - 是否加载中
 * @property {import('vue').Ref<null|string>} error - 错误信息
 * @property {(fetcher: () => Promise<*>) => Promise<*>} run - 执行加载：置 loading、记录错误、写入 data
 * @property {() => void} reset - 重置为初始状态
 */

/**
 * 通用异步数据加载器：统一管理 data / loading / error，
 * 避免每个页面各自维护一套状态样板代码。
 *
 * @example
 * const { data: stats, run: loadStats } = useAsyncData({})
 * onMounted(() => loadStats(() => recordApi.stats().then(r => r.data.data)))
 *
 * @param {*} [initial=null] - 初始数据值
 * @returns {AsyncDataState}
 */
export function useAsyncData(initial = null) {
  /** @type {import('vue').Ref<*>} */
  const data = ref(initial)
  /** @type {import('vue').Ref<boolean>} */
  const loading = ref(false)
  /** @type {import('vue').Ref<null|string>} */
  const error = ref(null)

  /**
   * 执行异步加载；成功写入 data，失败记录 error 并继续抛出（由调用方兜底）。
   * @param {() => Promise<*>} fetcher - 返回 Promise 的加载函数
   * @returns {Promise<*>} 加载结果
   */
  async function run(fetcher) {
    loading.value = true
    error.value = null
    try {
      const result = await fetcher()
      data.value = result
      return result
    } catch (e) {
      error.value = e && e.message ? e.message : String(e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /** 重置为初始状态。 */
  function reset() {
    data.value = initial
    error.value = null
    loading.value = false
  }

  return { data, loading, error, run, reset }
}
