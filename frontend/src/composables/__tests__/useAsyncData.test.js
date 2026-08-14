import { describe, it, expect } from 'vitest'
import { useAsyncData } from '../useAsyncData'

describe('useAsyncData', () => {
  it('加载成功时写入 data 并复位 loading/error', async () => {
    const { data, loading, error, run } = useAsyncData(null)

    const promise = run(() => Promise.resolve('ok'))
    expect(loading.value).toBe(true)

    await expect(promise).resolves.toBe('ok')
    expect(data.value).toBe('ok')
    expect(loading.value).toBe(false)
    expect(error.value).toBeNull()
  })

  it('加载失败时记录 error 并继续抛出', async () => {
    const { data, error, run } = useAsyncData(null)

    await expect(run(() => Promise.reject(new Error('boom')))).rejects.toThrow('boom')
    expect(error.value).toBe('boom')
    expect(data.value).toBeNull()
  })

  it('reset 恢复初始状态', async () => {
    const { data, error, run, reset } = useAsyncData([1])
    await run(() => Promise.resolve([2]))
    expect(data.value).toEqual([2])

    reset()
    expect(data.value).toEqual([1])
    expect(error.value).toBeNull()
  })
})
