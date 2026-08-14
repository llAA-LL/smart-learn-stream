/**
 * 轻量 Markdown 渲染工具。
 *
 * 设计说明：先整体 HTML 转义再按「受控子集」替换，保证插入的标签由我们生成、
 * 用户输入永远只是文本，从而规避 v-html 的 XSS 风险。
 * 如需完整 Markdown 规范，可替换为 marked / markdown-it，当前项目只需上述子集。
 */

/**
 * HTML 转义，防止 XSS。
 * @param {string} text - 原始文本
 * @returns {string} 转义后的安全文本
 */
export function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

/**
 * 将受支持子集的 Markdown 渲染为 HTML 字符串。
 * 支持：代码块（```lang）、行内代码、加粗、H1-H3、无序列表、段落与换行。
 *
 * @param {string} text - 原始 Markdown 文本
 * @returns {string} 安全渲染后的 HTML
 */
export function renderMarkdown(text) {
  if (!text) return ''
  let html = escapeHtml(text)

  // 代码块（```lang\n...```）→ <pre><code>，并去掉结尾换行避免后续被替换成 <br>
  html = html.replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
    return '<pre><code>' + code.replace(/\n$/, '') + '</code></pre>'
  })
  // 行内代码
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>')
  // 加粗
  html = html.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>')
  // 标题
  html = html.replace(/^### (.+)$/gm, '<h4>$1</h4>')
  html = html.replace(/^## (.+)$/gm, '<h3>$1</h3>')
  html = html.replace(/^# (.+)$/gm, '<h2>$1</h2>')
  // 无序列表
  html = html.replace(/^- (.+)$/gm, '<li>$1</li>')
  // 段落与换行
  html = html.replace(/\n\n/g, '</p><p>')
  html = html.replace(/\n/g, '<br>')
  return '<p>' + html + '</p>'
}

export default renderMarkdown
