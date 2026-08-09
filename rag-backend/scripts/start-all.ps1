$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $root
$ps = Join-Path $PSHOME "powershell.exe"

Write-Host "[1/3] 启动 ChromaDB（端口 8000）..."
Start-Process -FilePath $ps -ArgumentList @(
    "-ExecutionPolicy", "Bypass",
    "-File", (Join-Path $root "scripts\start-chroma.ps1")
) -WindowStyle Hidden | Out-Null

Start-Sleep -Seconds 2

Write-Host "[2/3] 启动本地 Embedding 服务（端口 5003，首次加载模型约 20 秒）..."
Start-Process -FilePath $ps -ArgumentList @(
    "-ExecutionPolicy", "Bypass",
    "-File", (Join-Path $root "scripts\start-embedding.ps1")
) -WindowStyle Hidden | Out-Null

Write-Host "[3/3] 启动 RAG 后端（端口 9091）..."
& (Join-Path $root "scripts\start-app.ps1")
