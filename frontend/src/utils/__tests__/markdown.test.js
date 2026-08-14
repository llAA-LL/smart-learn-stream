import { describe, it, expect } from 'vitest'
import { escapeHtml, renderMarkdown } from '../markdown'

describe('escapeHtml', () => {
  it('转义 HTML 特殊字符', () => {
    expect(escapeHtml('<script>alert("x")</script>')).toBe(
      '&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;'
    )
  })
})

describe('renderMarkdown', () => {
  it('空文本返回空字符串', () => {
    expect(renderMarkdown('')).toBe('')
    expect(renderMarkdown(null)).toBe('')
    expect(renderMarkdown(undefined)).toBe('')
  })

  it('渲染代码块与行内代码', () => {
    const html = renderMarkdown('```java\nSystem.out.println(1);\n```\n\n这是 `inline` 代码')
    expect(html).toContain('<pre><code>System.out.println(1);</code></pre>')
    expect(html).toContain('<code>inline</code>')
  })

  it('渲染加粗与标题', () => {
    const html = renderMarkdown('# 一级标题\n\n**加粗**')
    expect(html).toContain('<h2>一级标题</h2>')
    expect(html).toContain('<b>加粗</b>')
  })

  it('渲染无序列表', () => {
    const html = renderMarkdown('- 第一项\n- 第二项')
    expect(html).toContain('<li>第一项</li>')
    expect(html).toContain('<li>第二项</li>')
  })

  it('防止 HTML 注入', () => {
    const html = renderMarkdown('<img src=x onerror=alert(1)>')
    expect(html).not.toContain('<img')
    expect(html).toContain('&lt;img')
  })
})
