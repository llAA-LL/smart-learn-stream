// RAG 后端性能测试（Node 18+，使用内置 fetch）
// 用法：node scripts/perf-test.js
const BASE = 'http://localhost:9091';

const RETRIEVE_URLS = {
  hybrid: '/api/rag/retrieve?question=%E4%BB%80%E4%B9%88%E6%98%AF%E6%AD%BB%E9%94%81%EF%BC%9F&topK=5&mode=hybrid&rerank=false',
  rerank: '/api/rag/retrieve?question=%E4%BB%80%E4%B9%88%E6%98%AF%E6%AD%BB%E9%94%81%EF%BC%9F&topK=5&mode=hybrid&rerank=true'
};

const QUESTIONS = [
  '什么是死锁？产生死锁的四个必要条件是什么？',
  '什么是 B+ 树索引？它有什么特点？',
  'JVM 运行时内存区域有哪些？',
  'Java HashMap 的底层实现原理是什么？',
  'TCP 三次握手的过程是怎样的？'
];

function latency(url, opts = {}) {
  const start = Date.now();
  return fetch(url, opts).then(async (res) => {
    const text = await res.text();
    return { status: res.status, ms: Date.now() - start, body: text };
  }).catch((e) => ({ status: 0, ms: Date.now() - start, error: e.message }));
}

function pct(arr, p) {
  const s = [...arr].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.floor(s.length * p))];
}

function stats(label, arr) {
  const ok = arr.filter((x) => x.status === 200);
  const ms = ok.map((x) => x.ms);
  const avg = ms.reduce((a, b) => a + b, 0) / (ms.length || 1);
  const out = {
    label,
    total: arr.length,
    ok: ok.length,
    fail: arr.length - ok.length,
    avg_ms: +avg.toFixed(1),
    min_ms: ms.length ? Math.min(...ms) : 0,
    p50_ms: ms.length ? pct(ms, 0.5) : 0,
    p95_ms: ms.length ? pct(ms, 0.95) : 0,
    max_ms: ms.length ? Math.max(...ms) : 0
  };
  out.qps = ok.length ? +(1000 / avg).toFixed(1) : 0;
  return out;
}

async function workerPool(url, opts, total, concurrency) {
  const results = [];
  let next = 0;
  async function worker() {
    while (next < total) {
      const i = next++;
      results.push(await latency(url, opts));
    }
  }
  await Promise.all(Array.from({ length: concurrency }, worker));
  return results;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const report = { date: new Date().toISOString(), tests: [] };
  console.log('== RAG Performance Test ==', new Date().toLocaleString());
  const onlyRetrieve = process.argv[2] === 'retrieve';

  // 0. 预热
  await latency(BASE + RETRIEVE_URLS.hybrid);
  await sleep(500);

  // 1. 单请求延迟
  console.log('\n[1] single request latency');
  let arr = [];
  for (let i = 0; i < 10; i++) arr.push(await latency(BASE + RETRIEVE_URLS.hybrid));
  let s = stats('retrieve_hybrid', arr); console.log(JSON.stringify(s)); report.tests.push(s);

  arr = [];
  for (let i = 0; i < 5; i++) arr.push(await latency(BASE + RETRIEVE_URLS.rerank));
  s = stats('retrieve_hybrid_rerank', arr); console.log(JSON.stringify(s)); report.tests.push(s);

  arr = [];
  const chatElapsed = [];
  for (let i = 0; i < 5; i++) {
    const q = QUESTIONS[i % QUESTIONS.length];
    const r = await latency(BASE + '/api/rag/chat', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ conversationId: 'perf-' + Date.now(), history: [], question: q })
    });
    arr.push(r);
    if (r.status === 200) {
      try { chatElapsed.push(JSON.parse(r.body).elapsedMs); } catch {}
    }
  }
  s = stats('chat_client_side', arr); console.log(JSON.stringify(s)); report.tests.push(s);
  if (chatElapsed.length) {
    const es = stats('chat_server_elapsedMs', chatElapsed.map((x) => ({ status: 200, ms: x })));
    console.log(JSON.stringify(es)); report.tests.push(es);
  }

  // 2. 检索并发（hybrid，40 请求）
  console.log('\n[2] retrieval concurrency (40 requests)');
  for (const c of [1, 5, 10, 20]) {
    const r = await workerPool(BASE + RETRIEVE_URLS.hybrid, undefined, 40, c);
    const s = stats('retrieve_concurrency_' + c, r);
    console.log(JSON.stringify(s)); report.tests.push(s);
  }
  if (onlyRetrieve) {
    require('fs').writeFileSync(
      'E:/smart-learning-system/rag-backend/eval/perf-results.json',
      JSON.stringify(report, null, 2), 'utf8');
    console.log('\nReport saved: eval/perf-results.json');
    return;
  }

  // 3. chat 并发（20 请求，控制 DeepSeek 调用量）
  console.log('\n[3] chat concurrency (20 requests)');
  for (const c of [2, 4]) {
    const r = await workerPool(BASE + '/api/rag/chat', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ conversationId: 'perf-c-' + Date.now(), history: [], question: '什么是死锁？' })
    }, 20, c);
    const s = stats('chat_concurrency_' + c, r);
    console.log(JSON.stringify(s)); report.tests.push(s);
  }

  // 4. SSE 流式 TTFT
  console.log('\n[4] SSE streaming TTFT');
  const ttft = [];
  for (let i = 0; i < 3; i++) {
    const start = Date.now();
    const resp = await fetch(BASE + '/api/rag/chat/stream', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ conversationId: 'perf-s-' + Date.now(), history: [], question: '什么是死锁？' })
    });
    const reader = resp.body.getReader();
    const decoder = new TextDecoder();
    let firstDeltaMs = 0;
    let buf = '';
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buf += decoder.decode(value, { stream: true });
      if (!firstDeltaMs && buf.includes('event:delta')) firstDeltaMs = Date.now() - start;
    }
    const totalMs = Date.now() - start;
    ttft.push({ status: resp.status, ttft_ms: firstDeltaMs, total_ms: totalMs });
  }
  const ttftOk = ttft.filter((x) => x.status === 200);
  const ttftAvg = ttftOk.reduce((a, b) => a + b.ttft_ms, 0) / (ttftOk.length || 1);
  const totalAvg = ttftOk.reduce((a, b) => a + b.total_ms, 0) / (ttftOk.length || 1);
  const st = {
    label: 'sse_ttft', total: ttft.length, ok: ttftOk.length,
    avg_ttft_ms: +ttftAvg.toFixed(1), avg_total_ms: +totalAvg.toFixed(1), samples: ttft
  };
  console.log(JSON.stringify(st)); report.tests.push(st);

  require('fs').writeFileSync(
    'E:/smart-learning-system/rag-backend/eval/perf-results.json',
    JSON.stringify(report, null, 2), 'utf8');
  console.log('\nReport saved: eval/perf-results.json');
})();
