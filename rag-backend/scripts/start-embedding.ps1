$ErrorActionPreference = "Stop"

$venvPython = "E:\smart-learning-system\agent\.venv\Scripts\python.exe"
$appDir = "E:\smart-learning-system\rag-backend\scripts"
$workers = [System.Environment]::GetEnvironmentVariable("EMBEDDING_WORKERS")
if (-not $workers) { $workers = "2" }

if (-not (Test-Path $venvPython)) {
    Write-Error "未找到虚拟环境 Python：$venvPython（请确认 smart-learning-system\agent\.venv 存在）"
    exit 1
}

Write-Host "启动本地 Embedding/Rerank 服务（端口 5003，$workers worker，首次加载模型约 20-40 秒）..."
# 注意：Windows 上 uvicorn.run(workers>1) 会崩，必须用 CLI 形式
& $venvPython -m uvicorn embedding_server:app --host 127.0.0.1 --port 5003 --workers $workers --app-dir $appDir
