$ErrorActionPreference = "Stop"

$venvDir = "E:\smart-learning-system\agent\.venv"
$chromaExe = Join-Path $venvDir "Scripts\chroma.exe"
$pythonExe = Join-Path $venvDir "Scripts\python.exe"
$dataDir = "E:\smart-learning-system\rag-backend\data\chroma"

if (-not (Test-Path $pythonExe)) {
    Write-Error "未找到 Python 虚拟环境：$pythonExe（请确认 smart-learning-system\agent\.venv 存在）"
    exit 1
}

New-Item -ItemType Directory -Force -Path $dataDir | Out-Null

Write-Host "启动 ChromaDB（端口 8000，数据目录 $dataDir）..."
if (Test-Path $chromaExe) {
    & $chromaExe run --host 127.0.0.1 --port 8000 --path $dataDir
} else {
    & $pythonExe -m chromadb.cli.cli run --host 127.0.0.1 --port 8000 --path $dataDir
}
