/**
 * 增量式 SSE（Server-Sent Events）解析器。
 *
 * 核心设计：buffer / eventType / pendingData 等状态在多次 push 之间保持，
 * 避免"事件被网络分块拦腰截断后数据被静默丢弃"的经典 bug——
 * 若每次 push 都重置状态，跨块事件的 data: 行会丢失，表现为回答随机缺字。
 */

/**
 * @typedef {(type: string, data: string) => void} SseEventHandler
 * @param {string} type - 事件类型（如 delta / citations / done）
 * @param {string} data - 该事件所有 data: 行按 \n 连接后的内容
 */

/**
 * 创建增量 SSE 解析器。
 * @param {SseEventHandler} onEvent - 每个完整事件触发一次
 * @returns {{
 *   push: (chunk: string) => void,
 *   flush: () => void
 * }}
 */
export function createSseParser(onEvent) {
  let buffer = ''
  let eventType = ''
  let pendingData = []

  const flushEvent = () => {
    if (pendingData.length === 0) return
    // SSE 规范：同一事件的多条 data: 行用 \n 连接
    const data = pendingData.join('\n')
    pendingData = []
    onEvent(eventType, data)
  }

  const processLines = (lines) => {
    for (const line of lines) {
      // 兼容 "event: xxx"（带空格）与 "event:xxx"（Spring SseEmitter 无空格）
      if (line.startsWith('event:')) {
        flushEvent()
        eventType = line.slice(6).trim()
      } else if (line.startsWith('data:')) {
        pendingData.push(line.slice(5).replace(/^ /, ''))
      } else if (line === '') {
        // 空行 = 事件结束
        flushEvent()
      }
    }
  }

  return {
    /**
     * 喂入一段增量文本（通常是 decoder.decode(value, { stream: true }) 的结果）。
     * @param {string} chunk
     */
    push(chunk) {
      buffer += chunk
      const lines = buffer.split('\n')
      // 最后一行可能不完整，留到下次 push
      buffer = lines.pop() || ''
      processLines(lines)
    },

    /**
     * 流结束时调用：处理残留的最后一行并触发未冲刷的事件。
     */
    flush() {
      if (buffer.trim()) {
        processLines(buffer.split('\n'))
        buffer = ''
      }
      flushEvent()
    }
  }
}
