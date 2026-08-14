import { describe, it, expect } from 'vitest'
import { createSseParser } from '../sse'

describe('createSseParser', () => {
  it('事件被网络分块截断时不丢数据（回归用例）', () => {
    const events = []
    const parser = createSseParser((type, data) => events.push([type, data]))

    // 模拟 3 字符小块，事件行被拦腰截断
    const raw = 'event:delta\ndata:根据现有学习资料\n\nevent:delta\ndata:方法区（Metaspace）\n\n'
    for (let i = 0; i < raw.length; i += 3) {
      parser.push(raw.slice(i, i + 3))
    }
    parser.flush()

    expect(events).toEqual([
      ['delta', '根据现有学习资料'],
      ['delta', '方法区（Metaspace）']
    ])
  })

  it('同一事件的多条 data: 行按 \\n 连接', () => {
    const events = []
    const parser = createSseParser((type, data) => events.push([type, data]))

    parser.push('event:delta\ndata:第一行\ndata:\ndata:第二行\n\n')
    parser.flush()

    expect(events).toEqual([['delta', '第一行\n\n第二行']])
  })

  it('兼容 event: 带空格与不带空格两种格式', () => {
    const events = []
    const parser = createSseParser((type, data) => events.push([type, data]))

    parser.push('event: citations\ndata:[1]\n\nevent:delta\ndata:ok\n\n')
    parser.flush()

    expect(events).toEqual([
      ['citations', '[1]'],
      ['delta', 'ok']
    ])
  })

  it('流结束没有空行时 flush 仍能冲刷事件', () => {
    const events = []
    const parser = createSseParser((type, data) => events.push([type, data]))

    parser.push('event:delta\ndata:结尾')
    parser.flush()

    expect(events).toEqual([['delta', '结尾']])
  })
})
