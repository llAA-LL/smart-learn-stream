param([switch]$RejudgeOnly)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = "E:\smart-learning-system\rag-backend"
$utf8 = [System.Text.UTF8Encoding]::new($false)
$api = "http://localhost:9091"

Write-Host "=== RAG 评测 $(if ($RejudgeOnly) { '(仅重判)' } else { '(完整)' }) 开始 $(Get-Date -Format 'HH:mm:ss') ==="

[System.IO.File]::ReadAllLines("$root\.env", $utf8) | Where-Object {
    $_ -match '^[A-Za-z_][A-Za-z0-9_]*='
} | ForEach-Object {
    $kv = $_ -split '=', 2
    [System.Environment]::SetEnvironmentVariable($kv[0].Trim(), $kv[1].Trim())
}
$deepseekKey = [System.Environment]::GetEnvironmentVariable("DEEPSEEK_API_KEY")
$deepseekUrl = "https://api.deepseek.com/chat/completions"

$qa = [System.IO.File]::ReadAllLines("$root\eval\qa.jsonl", $utf8) | Where-Object { $_ -notmatch '^\s*$' } | ForEach-Object { $_ | ConvertFrom-Json }
$kps = [System.IO.File]::ReadAllText("$root\eval\knowledge-points.json", $utf8) | ConvertFrom-Json
$kpMap = @{}
foreach ($kp in $kps) { $kpMap[[string]$kp.id] = $kp }

$resultsPath = "$root\eval\results.json"
$results = @()
if (Test-Path $resultsPath) {
    $results = [System.IO.File]::ReadAllText($resultsPath, $utf8) | ConvertFrom-Json
}
$doneIds = @{}
foreach ($r in $results) { $doneIds[[string]$r.id] = $true }

function Invoke-DeepSeek([string]$system, [string]$user, [int]$maxTokens = 1024, [double]$temperature = 0.2) {
    $payload = @{
        model       = "deepseek-chat"
        messages    = @(@{ role = "system"; content = $system }, @{ role = "user"; content = $user })
        temperature = $temperature
        max_tokens  = $maxTokens
    } | ConvertTo-Json -Depth 6
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    $web = Invoke-WebRequest -Uri $deepseekUrl -Method POST -Headers @{ Authorization = "Bearer $deepseekKey" } -ContentType "application/json; charset=utf-8" -Body $bytes -UseBasicParsing -TimeoutSec 180
    $json = [System.IO.StreamReader]::new($web.RawContentStream, [System.Text.Encoding]::UTF8).ReadToEnd()
    $resp = $json | ConvertFrom-Json
    return [string]$resp.choices[0].message.content
}

function Invoke-Get([string]$url) {
    $web = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 120
    $json = [System.IO.StreamReader]::new($web.RawContentStream, [System.Text.Encoding]::UTF8).ReadToEnd()
    return $json | ConvertFrom-Json
}

function Invoke-PostJson([string]$url, [string]$json) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $web = Invoke-WebRequest -Uri $url -Method POST -ContentType "application/json; charset=utf-8" -Body $bytes -UseBasicParsing -TimeoutSec 300
    $json = [System.IO.StreamReader]::new($web.RawContentStream, [System.Text.Encoding]::UTF8).ReadToEnd()
    return $json | ConvertFrom-Json
}

function Get-Reference([string]$kpId) {
    $kp = $kpMap[$kpId]
    if ($null -eq $kp) { return "" }
    $content = ""
    if ($kp.learning_content) { $content = [string]$kp.learning_content }
    if ($content.Length -gt 900) { $content = $content.Substring(0, 900) + "…" }
    $ref = "知识点：$($kp.name)`n描述：$($kp.description)`n资料内容：$content"
    if ($ref.Length -gt 1400) { $ref = $ref.Substring(0, 1400) + "…" }
    return $ref
}

function Invoke-Judge($question, $reference, $bare, $rag) {
    $system = "你是一个严格的评测裁判，只能输出 JSON。"
    $user = @"
评测目标：比较两份回答对同一问题的质量。

问题：$question

课程资料要点（正确答案的参考依据）：
$reference

回答A（无检索增强的裸模型）：
$bare

回答B（RAG 检索增强，被要求严格依据课程资料回答）：
$rag

评分标准（0-10 整数）：
- 8-10：答案正确、完整、条理清晰
- 5-7：答案基本正确但不够完整
- 3-4：有相关内容但明显不完整，或与资料要点不符
- 0-2：答案错误、答非所问或编造事实

特别注意：
1. 如果回答B明确说明"根据现有资料无法完整回答"，这是资料覆盖不足时的诚实行为，不应按错误处理，按其实际提供的信息量和正确性给 4-6 分。
2. 如果回答A超出资料给出了正确细节，不算错误；但若与资料要点矛盾则扣分。
3. 编造不存在的概念、数据或事实是严重错误，应给 0-2 分。

只输出 JSON：{"bare": 分数, "rag": 分数}
"@
    $raw = Invoke-DeepSeek $system $user 160 0.0
    $bareScore = [regex]::Match($raw, '"bare"\s*:\s*(\d+)').Groups[1].Value
    $ragScore = [regex]::Match($raw, '"rag"\s*:\s*(\d+)').Groups[1].Value
    return @{ raw = $raw; bare = if ($bareScore) { [int]$bareScore } else { $null }; rag = if ($ragScore) { [int]$ragScore } else { $null } }
}

if (-not $RejudgeOnly) {
    $index = 0
    foreach ($item in $qa) {
        $index++
        $id = [string]$item.id
        if ($doneIds.ContainsKey($id)) {
            Write-Host "[$id] 已完成，跳过"
            continue
        }
        $question = [string]$item.question
        $expectedId = [string]$item.expected_kp_id
        $qEnc = [System.Uri]::EscapeDataString($question)
        Write-Host "[$index/$($qa.Count)] $question"

        $row = @{
            id             = $id
            question       = $question
            expected_kp_id = $expectedId
            retrieval      = @{}
            answers        = @{}
            scores         = @{}
            error          = $null
        }

        try {
            $modes = @(
                @{ label = "dense";         mode = "dense";   rerank = $false },
                @{ label = "sparse";        mode = "sparse";  rerank = $false },
                @{ label = "hybrid";        mode = "hybrid";  rerank = $false },
                @{ label = "hybrid_rerank"; mode = "hybrid";  rerank = $true }
            )
            foreach ($m in $modes) {
                $url = "$api/api/rag/retrieve?question=$qEnc&topK=5&mode=$($m.mode)&rerank=$($m.rerank)"
                $chunks = @(Invoke-Get $url)
                $row.retrieval[$m.label] = @{ top = @($chunks | ForEach-Object { $_.kpId }) }
            }

            $bare = Invoke-DeepSeek "" $question 1024 0.2
            $row.answers.bare = $bare

            $chatJson = @{ conversationId = "eval-$id"; history = @(); question = $question } | ConvertTo-Json -Depth 4
            $chat = Invoke-PostJson "$api/api/rag/chat" $chatJson
            $row.answers.rag = [string]$chat.answer
            $row.answers.rag_citations = @($chat.citations | ForEach-Object { $_.kpId })
            $row.answers.rag_has_citation = ([string]$chat.answer).Contains("[1]")

            $reference = Get-Reference $expectedId
            $judge = Invoke-Judge $question $reference $bare ([string]$chat.answer)
            $row.scores.judge_raw = $judge.raw
            $row.scores.bare = $judge.bare
            $row.scores.rag = $judge.rag
        } catch {
            $row.error = $_.Exception.Message
            Write-Host "  [错误] $($_.Exception.Message)"
        }

        $results = @($results) + @($row)
        [System.IO.File]::WriteAllText($resultsPath, ($results | ConvertTo-Json -Depth 8), $utf8)
        Write-Host "  已保存进度 ($($results.Count)/$($qa.Count))"
    }
} else {
    Write-Host "重判模式：使用已保存的回答重新打分（$($results.Count) 题）"
    $out = @()
    foreach ($r in $results) {
        $id = [string]$r.id
        Write-Host "[$id] 重新打分..."
        $reference = Get-Reference ([string]$r.expected_kp_id)
        $judge = Invoke-Judge ([string]$r.question) $reference ([string]$r.answers.bare) ([string]$r.answers.rag)
        $r.scores.judge_raw = $judge.raw
        $r.scores.bare = $judge.bare
        $r.scores.rag = $judge.rag
        $out += $r
    }
    $results = $out
    [System.IO.File]::WriteAllText($resultsPath, ($results | ConvertTo-Json -Depth 8), $utf8)
}

# 5. 汇总（检索指标从 top 数组权威重算）
$total = $results.Count
$summary = @{ total = $total; retrieval = @{} }

function Test-Hit($r, $label, $level) {
    $exp = [string]$r.expected_kp_id
    $top = @($r.retrieval.$label.top)
    if ($level -eq 1) {
        return ($top.Count -gt 0 -and ([string]$top[0] -eq $exp))
    }
    foreach ($t in $top) { if ([string]$t -eq $exp) { return $true } }
    return $false
}

foreach ($label in @("dense", "sparse", "hybrid", "hybrid_rerank")) {
    $h1 = 0; $h5 = 0
    foreach ($r in $results) {
        if (Test-Hit $r $label 1) { $h1++ }
        if (Test-Hit $r $label 5) { $h5++ }
    }
    $summary.retrieval[$label] = @{ hit1 = $h1; hit5 = $h5; hit1_rate = [Math]::Round($h1 / $total * 100, 1); hit5_rate = [Math]::Round($h5 / $total * 100, 1) }
}

$g5 = 0
foreach ($r in $results) {
    $exp = [string]$r.expected_kp_id
    foreach ($t in @($r.answers.rag_citations)) { if ([string]$t -eq $exp) { $g5++; break } }
}
$summary.retrieval.rag_generation = @{ hit5 = $g5; hit5_rate = [Math]::Round($g5 / $total * 100, 1) }

$scored = @($results | Where-Object { $null -ne $_.scores.bare -and $null -ne $_.scores.rag })
$bareSum = 0
$ragSum = 0
foreach ($sc in $scored) {
    $bareSum += [int]$sc.scores.bare
    $ragSum += [int]$sc.scores.rag
}
$bareAvg = if ($scored.Count) { [Math]::Round($bareSum / $scored.Count, 2) } else { 0 }
$ragAvg = if ($scored.Count) { [Math]::Round($ragSum / $scored.Count, 2) } else { 0 }
$ragBetter = @($scored | Where-Object { $_.scores.rag -gt $_.scores.bare }).Count
$ragWorse = @($scored | Where-Object { $_.scores.rag -lt $_.scores.bare }).Count
$ragTie = @($scored | Where-Object { $_.scores.rag -eq $_.scores.bare }).Count
$citationCount = @($results | Where-Object { $_.answers.rag_has_citation }).Count

$summary.answers = @{
    scored_count      = $scored.Count
    bare_avg          = $bareAvg
    rag_avg           = $ragAvg
    rag_better        = $ragBetter
    rag_worse         = $ragWorse
    rag_tie           = $ragTie
    rag_citation_rate = [Math]::Round($citationCount / $total * 100, 1)
}

[System.IO.File]::WriteAllText("$root\eval\summary.json", ($summary | ConvertTo-Json -Depth 6), $utf8)

# 6. 生成 Markdown 报告
$lines = @()
$lines += "# RAG 评测报告"
$lines += ""
$lines += "生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += ""
$lines += "评测集：$total 道题（基于 MySQL 中真实知识点构造）"
$lines += ""
$lines += "## 一、检索命中率（Top-5 内是否包含正确答案知识点）"
$lines += ""
$lines += "| 检索模式 | Hit@1 | Hit@5 |"
$lines += "|---------|------:|------:|"
foreach ($label in @("dense", "sparse", "hybrid", "hybrid_rerank")) {
    $s = $summary.retrieval[$label]
    $labelName = switch ($label) { "dense" { "仅向量检索" } "sparse" { "仅关键词检索" } "hybrid" { "混合检索(RRF)" } "hybrid_rerank" { "混合+LLM重排" } }
    $lines += "| $labelName | $($s.hit1)/$total ($($s.hit1_rate)%) | $($s.hit5)/$total ($($s.hit5_rate)%) |"
}
$g = $summary.retrieval.rag_generation
$lines += "| RAG 生成时实际命中 | - | $($g.hit5)/$total ($($g.hit5_rate)%) |"
$lines += ""
$lines += "## 二、回答质量（LLM 裁判 0-10 分，公平规则）"
$lines += ""
$lines += "| 指标 | 数值 |"
$lines += "|------|-----:|"
$lines += "| 裸模型平均分 | $($summary.answers.bare_avg) |"
$lines += "| RAG 平均分 | $($summary.answers.rag_avg) |"
$lines += "| RAG 胜出题数 | $($summary.answers.rag_better) |"
$lines += "| 持平 | $($summary.answers.rag_tie) |"
$lines += "| RAG 落败 | $($summary.answers.rag_worse) |"
$lines += "| RAG 回答含引用率 | $($summary.answers.rag_citation_rate)% |"
$lines += ""
$lines += "## 三、逐题明细"
$lines += ""
$lines += "| # | 问题 | 期望知识点 | dense H5 | sparse H5 | hybrid H5 | hybrid+rerank H5 | 裸分 | RAG分 |"
$lines += "|---|------|-----------|:---:|:---:|:---:|:---:|:---:|:---:|"
foreach ($r in $results) {
    $name = ""
    $kp = $kpMap[[string]$r.expected_kp_id]
    if ($kp) { $name = $kp.name }
    $mk = { param($l) if (Test-Hit $r $l 5) { "✓" } else { "✗" } }
    $b = if ($null -ne $r.scores.bare) { $r.scores.bare } else { "-" }
    $g2 = if ($null -ne $r.scores.rag) { $r.scores.rag } else { "-" }
    $lines += "| $($r.id) | $($r.question) | $name | $(& $mk 'dense') | $(& $mk 'sparse') | $(& $mk 'hybrid') | $(& $mk 'hybrid_rerank') | $b | $g2 |"
}
[System.IO.File]::WriteAllText("$root\eval\report.md", ($lines -join "`n"), $utf8)

Write-Host ""
Write-Host "=== 评测完成 $(Get-Date -Format 'HH:mm:ss') ==="
Write-Host ("检索 Hit@5：dense=$($summary.retrieval.dense.hit5_rate)% sparse=$($summary.retrieval.sparse.hit5_rate)% hybrid=$($summary.retrieval.hybrid.hit5_rate)% hybrid+rerank=$($summary.retrieval.hybrid_rerank.hit5_rate)%")
Write-Host ("回答评分：裸模型=$bareAvg  RAG=$ragAvg  (RAG 胜出 $ragBetter/$($scored.Count))")
Write-Host "报告已生成：eval\report.md"