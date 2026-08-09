<template>
  <div class="page">
    <div class="chat-container">
      <!-- Header -->
      <div class="chat-header">
        <div class="chat-header-left">
          <div class="agent-avatar">AI</div>
          <div>
            <h3>学习助手</h3>
            <p class="agent-desc">可查询知识库 · 查看学习数据 · 个性化建议</p>
          </div>
        </div>
        <el-button link @click="clearChat" :disabled="messages.length === 0">清空对话</el-button>
      </div>

      <!-- Messages -->
      <div ref="msgListRef" class="chat-messages">
        <div v-if="messages.length === 0" class="chat-welcome">
          <div class="welcome-icon">🤖</div>
          <h4>你好，我是你的 AI 学习助手</h4>
          <p>试试问我：</p>
          <div class="suggestion-list">
            <div v-for="s in suggestions" :key="s" class="suggestion-chip" @click="send(s)">{{ s }}</div>
          </div>
        </div>

        <div v-for="(m, idx) in messages" :key="idx" class="chat-msg" :class="m.role">
          <div class="msg-avatar">{{ m.role === 'user' ? '我' : 'AI' }}</div>
          <div class="msg-body">
            <div class="msg-content" v-html="renderMarkdown(m.content)" />
            <div v-if="m.citations && m.citations.length && !typing" class="citation-row">
              <span class="citation-label">参考知识点：</span>
              <el-tag v-for="(c, ci) in m.citations" :key="ci" size="small" type="info" effect="plain">
                {{ c.kpName }}
              </el-tag>
            </div>
            <div v-if="m.followUps && m.followUps.length && !typing" class="follow-up-row">
              <span class="follow-up-label">继续了解：</span>
              <el-button v-for="(q, qi) in m.followUps" :key="qi" size="small" round plain
                         @click="send(q)">{{ q }}</el-button>
            </div>
            <div v-if="m.role === 'assistant' && m.content && !typing" class="feedback-row">
              <el-button size="small" text :type="m.feedback === 'up' ? 'success' : 'info'"
                         @click="rateMessage(m, 'up')" :disabled="m.feedback">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M4.5 7v5.5a.5.5 0 0 0 .5.5h.5a.5.5 0 0 0 .5-.5V7.5a.5.5 0 0 0-.5-.5H5a.5.5 0 0 0-.5.5zm4-4.5c-.5 0-1 .3-1.2.7L5.8 6.5H4c-.6 0-1 .4-1 1v5c0 .6.4 1 1 1h6.5c.5 0 .9-.3 1-.7l1.3-3.8a1 1 0 0 0-1-1.3h-2.7l.3-1.5c.1-.4 0-.8-.3-1.1L8.5 2.5z" fill="currentColor"/></svg>
              </el-button>
              <el-button size="small" text :type="m.feedback === 'down' ? 'danger' : 'info'"
                         @click="rateMessage(m, 'down')" :disabled="m.feedback">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M11.5 9V3.5a.5.5 0 0 0-.5-.5h-.5a.5.5 0 0 0-.5.5V8.5a.5.5 0 0 0 .5.5h.5a.5.5 0 0 0 .5-.5zm-4 4.5c.5 0 1-.3 1.2-.7l1.5-3.3H12c.6 0 1-.4 1-1v-5c0-.6-.4-1-1-1H5.5c-.5 0-.9.3-1 .7L3.2 6.2a1 1 0 0 0 1 1.3h2.7l-.3 1.5c-.1.4 0 .8.3 1.1l.6.6z" fill="currentColor"/></svg>
              </el-button>
            </div>
            <div v-if="m.role === 'assistant' && idx === messages.length - 1 && typing" class="typing-dot">
              <span></span><span></span><span></span>
            </div>
            <div v-if="m.toolsCalled" class="msg-tools">
              <el-tag v-for="t in m.toolsCalled" :key="t" size="small" type="info" effect="plain">
                {{ t }}
              </el-tag>
            </div>
          </div>
        </div>
      </div>

      <!-- Input -->
      <div class="chat-input-area">
        <el-input v-model="input" placeholder="输入问题，如：什么是JVM？解释HashMap原理、我的学习进度怎么样..."
                  size="large" @keydown.enter.exact="send(input)" :disabled="loading"
                  clearable class="chat-input" />
        <el-button type="primary" size="large" @click="send(input)" :loading="loading" :disabled="!input.trim()">
          发送
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, watch } from 'vue'
import axios from 'axios'

const messages = ref([])
const input = ref('')
const loading = ref(false)
const typing = ref(false)
const msgListRef = ref(null)
const conversationId = ref(localStorage.getItem('rag_conv_id') || '')

const suggestions = [
  '什么是JVM内存模型？',
  'HashMap的底层原理是什么？',
  '我的学习进度怎么样？',
  '我接下来应该学什么？',
  '解释一下动态规划算法',
  'CAP定理是什么意思？'
]

const history = ref([]) // persisted history for the agent context

async function send(text) {
  const content = (text || input.value).trim()
  if (!content || loading.value) return

  if (!conversationId.value) {
    conversationId.value = 'web-' + Date.now().toString(36)
    localStorage.setItem('rag_conv_id', conversationId.value)
  }

  input.value = ''
  messages.value.push({ role: 'user', content })
  history.value.push({ role: 'user', content })

  loading.value = true
  typing.value = true
  scrollBottom()

  // Add placeholder message for streaming
  const msgIdx = messages.value.length
  messages.value.push({ role: 'assistant', content: '' })

  try {
    const token = localStorage.getItem('token') || ''
    const resp = await fetch('/api/rag/chat/stream', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        conversationId: conversationId.value,
        history: history.value.slice(0, -1).slice(-16),
        question: content,
        token: localStorage.getItem('token') || ''
      })
    })

    const reader = resp.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      buffer += decoder.decode(value, { stream: true })

      const lines = buffer.split('\n')
      buffer = lines.pop() || ''

      let eventType = ''
      for (const line of lines) {
        // 兼容 "event: xxx"（带空格）与 "event:xxx"（Spring SseEmitter 无空格）两种格式
        if (line.startsWith('event:')) {
          eventType = line.slice(6).trim()
        } else if (line.startsWith('data:')) {
          const data = line.slice(5).replace(/^ /, '')
          if (eventType === 'citations') {
            try {
              messages.value[msgIdx].citations = JSON.parse(data)
            } catch {}
          } else if (eventType === 'delta') {
            messages.value[msgIdx].content += data
            scrollBottom()
          } else if (eventType === 'error') {
            messages.value[msgIdx].content = '抱歉，服务暂时不可用，请稍后再试。'
          } else if (eventType === 'done') {
            // 完成事件，无额外数据
          }
        }
      }
    }

    // Save to history
    const finalReply = messages.value[msgIdx].content
    if (finalReply) {
      history.value.push({ role: 'assistant', content: finalReply })
    }
  } catch {
    if (!messages.value[msgIdx].content) {
      messages.value[msgIdx].content = '抱歉，服务暂时不可用，请稍后再试。'
    }
  } finally {
    loading.value = false
    typing.value = false
    scrollBottom()
  }
}

function clearChat() {
  if (conversationId.value) {
    fetch('/api/rag/chat/' + conversationId.value, { method: 'DELETE' }).catch(() => {})
  }
  messages.value = []
  history.value = []
  conversationId.value = ''
  localStorage.removeItem('rag_conv_id')
}

async function rateMessage(m, rating) {
  m.feedback = rating
  // Find the preceding user message for question context
  const idx = messages.value.indexOf(m)
  const userMsg = idx > 0 ? messages.value[idx - 1] : null
  const question = userMsg && userMsg.role === 'user' ? userMsg.content : ''
  try {
    await axios.post('/api/rag/feedback', {
      conversationId: conversationId.value,
      question,
      answer: m.content,
      rating,
      sources: (m.citations || []).map(c => c.kpId)
    })
  } catch {}
}

function scrollBottom() {
  nextTick(() => {
    const el = msgListRef.value
    if (el) el.scrollTop = el.scrollHeight
  })
}

function renderMarkdown(text) {
  if (!text) return ''
  let html = text
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  // Code blocks
  html = html.replace(/```(\w*)\n([\s\S]*?)```/g, '<pre><code>$2</code></pre>')
  // Inline code
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>')
  // Bold
  html = html.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>')
  // Headings
  html = html.replace(/^### (.+)$/gm, '<h4>$1</h4>')
  html = html.replace(/^## (.+)$/gm, '<h3>$1</h3>')
  html = html.replace(/^# (.+)$/gm, '<h2>$1</h2>')
  // List items
  html = html.replace(/^- (.+)$/gm, '<li>$1</li>')
  // Newlines
  html = html.replace(/\n\n/g, '</p><p>')
  html = html.replace(/\n/g, '<br>')
  return '<p>' + html + '</p>'
}

watch(messages, scrollBottom, { deep: true })
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; height: calc(100vh - 100px); }
.chat-container {
  background: #fff; border-radius: 16px; box-shadow: 0 2px 16px rgba(0,0,0,0.06);
  display: flex; flex-direction: column; height: 100%; overflow: hidden;
}

/* Header */
.chat-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 16px 20px; border-bottom: 1px solid #f0f0f0; flex-shrink: 0;
}
.chat-header-left { display: flex; align-items: center; gap: 12px; }
.chat-header-left h3 { font-size: 16px; font-weight: 600; color: #1a1a2e; margin: 0; }
.agent-desc { font-size: 12px; color: #999; margin: 2px 0 0; }
.agent-avatar {
  width: 40px; height: 40px; border-radius: 12px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff; display: flex; align-items: center; justify-content: center;
  font-weight: 700; font-size: 14px; flex-shrink: 0;
}

/* Messages */
.chat-messages { flex: 1; overflow-y: auto; padding: 20px; background: #fafbfc; }
.chat-welcome { text-align: center; padding: 40px 20px; }
.welcome-icon { font-size: 48px; margin-bottom: 12px; }
.chat-welcome h4 { font-size: 16px; color: #333; margin: 0 0 8px; }
.chat-welcome p { font-size: 13px; color: #999; margin: 0 0 12px; }
.suggestion-list { display: flex; flex-wrap: wrap; gap: 8px; justify-content: center; }
.suggestion-chip {
  font-size: 13px; padding: 6px 14px; background: #f0f0ff; color: #667eea;
  border-radius: 20px; cursor: pointer; transition: all 0.2s;
}
.citation-row { margin-top: 6px; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.citation-label { font-size: 12px; color: #999; flex-shrink: 0; }
.suggestion-chip:hover { background: #667eea; color: #fff; }

.chat-msg { display: flex; gap: 10px; margin-bottom: 16px; }
.chat-msg.user { flex-direction: row-reverse; }
.msg-avatar {
  width: 32px; height: 32px; border-radius: 8px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 600; color: #fff;
}
.chat-msg.user .msg-avatar { background: #667eea; }
.chat-msg.assistant .msg-avatar { background: linear-gradient(135deg, #11998e, #38ef7d); }
.msg-body { max-width: 85%; }
.msg-content {
  padding: 10px 14px; border-radius: 12px; font-size: 14px; line-height: 1.7; word-break: break-word;
}
.chat-msg.user .msg-content { background: #667eea; color: #fff; border-bottom-right-radius: 4px; }
.chat-msg.assistant .msg-content { background: #fff; color: #333; border: 1px solid #eee; border-bottom-left-radius: 4px; }
.msg-content :deep(h2) { font-size: 16px; margin: 8px 0 4px; }
.msg-content :deep(h3) { font-size: 15px; margin: 6px 0 4px; }
.msg-content :deep(h4) { font-size: 14px; margin: 4px 0 2px; }
.msg-content :deep(pre) {
  background: #1e1e2e; color: #e0e0e0; padding: 12px; border-radius: 8px;
  overflow-x: auto; font-size: 12px; margin: 8px 0;
}
.msg-content :deep(code) {
  background: #f0f0f0; padding: 2px 6px; border-radius: 4px; font-size: 12px;
}
.msg-content :deep(pre code) { background: none; padding: 0; }
.msg-content :deep(li) { margin: 2px 0 2px 16px; }
.msg-tools { margin-top: 6px; display: flex; gap: 4px; flex-wrap: wrap; }
.typing-dot { display: flex; gap: 4px; padding: 4px 0; }
.typing-dot span {
  width: 6px; height: 6px; border-radius: 50%; background: #ccc;
  animation: bounce 1.4s infinite both;
}
.typing-dot span:nth-child(2) { animation-delay: 0.2s; }
.typing-dot span:nth-child(3) { animation-delay: 0.4s; }

/* Feedback */
.feedback-row { margin-top: 6px; display: flex; gap: 2px; }
@keyframes bounce { 0%,80%,100% { transform: scale(0); } 40% { transform: scale(1); } }

/* Follow-up buttons */
.follow-up-row {
  margin-top: 10px; display: flex; flex-wrap: wrap; align-items: center; gap: 6px;
}
.follow-up-label {
  font-size: 12px; color: #999; margin-right: 2px;
}
.follow-up-row .el-button {
  font-size: 12px; height: 28px; padding: 0 12px;
}

/* Input */
.chat-input-area {
  display: flex; gap: 12px; padding: 16px 20px; border-top: 1px solid #f0f0f0; flex-shrink: 0;
}
.chat-input { flex: 1; }
</style>
